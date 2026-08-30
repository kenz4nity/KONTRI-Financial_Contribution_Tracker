import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:kontri/data/isar_service.dart';
import 'package:kontri/logic/schedule.dart';
import 'package:kontri/models/app_meta.dart';
import 'package:kontri/models/contri_folder.dart';
import 'package:kontri/models/participant.dart';
import 'package:kontri/models/payment_record.dart';

import 'isar_test_support.dart';

/// Exercises the v1.0 -> v1.1 backfill against a database populated exactly as
/// v1.0 left it: no `startDate`, no `PaymentRecord` rows, no `AppMeta`, and
/// payments held only as formatted log strings.
///
/// This is the test that protects the promise that upgrading does not reset
/// anyone's data. It covers the migration logic; the on-device install-over
/// check in the plan still covers Isar's own binary schema migration.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory dir;
  late Isar isar;

  setUpAll(initializeIsarForTests);

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('kontri_migration_test');
    isar = await Isar.open(
      [
        ContriFolderSchema,
        ParticipantSchema,
        PaymentRecordSchema,
        AppMetaSchema,
      ],
      directory: dir.path,
      name: 'test${DateTime.now().microsecondsSinceEpoch}',
    );
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  });

  /// Writes a plan and participants the way v1.0 would have.
  Future<ContriFolder> seedV1() async {
    final folder = ContriFolder()
      ..title = 'Christmas Party'
      ..budget = 10000
      ..deadline = DateTime(2026, 12, 25)
      ..startDate = null; // v1.0 had no such field

    await isar.writeTxn(() async {
      await isar.contriFolders.put(folder);

      await isar.participants.putAll([
        Participant()
          ..folderId = folder.id
          ..name = 'Maria Santos'
          ..amountExpected = 2500
          ..amountPaid = 1500
          ..isPaid = false
          ..datePaid = DateTime(2026, 9, 6, 19, 4)
          ..createdAt = DateTime(2026, 9, 1)
          ..frequency = 'Weekly'
          // ignore: deprecated_member_use
          ..paymentHistory = [
            'Sep 2, 2026 (7:04 PM): +₱500',
            'Sep 6, 2026 (7:04 PM): +₱1000',
          ],
        Participant()
          ..folderId = folder.id
          ..name = 'Juan dela Cruz'
          ..amountExpected = 2500
          ..amountPaid = 0
          ..isPaid = false
          ..createdAt = DateTime(2026, 9, 3)
          ..frequency = 'Monthly'
          // ignore: deprecated_member_use
          ..paymentHistory = [],
      ]);
    });
    return folder;
  }

  test('backfills a start date from the earliest participant join date',
      () async {
    final folder = await seedV1();
    await IsarService.migrate(isar);

    final migrated = await isar.contriFolders.get(folder.id);
    expect(migrated!.startDate, DateTime(2026, 9, 1));
  });

  test('rebuilds the ledger from v1.0 log strings', () async {
    await seedV1();
    await IsarService.migrate(isar);

    final maria = await isar.participants
        .filter()
        .nameEqualTo('Maria Santos')
        .findFirst();
    final records = await isar.paymentRecords
        .filter()
        .participantIdEqualTo(maria!.id)
        .findAll()
      ..sort((a, b) => a.paidAt.compareTo(b.paidAt));

    expect(records, hasLength(2));
    expect(records[0].amount, 500);
    expect(records[0].paidAt, DateTime(2026, 9, 2, 19, 4));
    expect(records[1].amount, 1000);
    expect(records.every((r) => r.folderId == maria.folderId), isTrue);
  });

  test('the rebuilt ledger sums to the running total the user already saw',
      () async {
    await seedV1();
    await IsarService.migrate(isar);

    for (final p in await isar.participants.where().findAll()) {
      final records =
          await isar.paymentRecords.filter().participantIdEqualTo(p.id).findAll();
      final sum = records.fold<double>(0, (s, r) => s + r.amount);
      expect(sum, closeTo(p.amountPaid, 0.001), reason: p.name);
    }
  });

  test('adds a balancing row when the log undershoots the total', () async {
    // v1.0 formatted amounts with toStringAsFixed(0), so centavos never made
    // it into the log. The itemisation must still reconcile.
    final folder = await seedV1();
    await isar.writeTxn(() async {
      await isar.participants.put(Participant()
        ..folderId = folder.id
        ..name = 'Ana Reyes'
        ..amountExpected = 2500
        ..amountPaid = 1234.56
        ..isPaid = false
        ..createdAt = DateTime(2026, 9, 2)
        ..frequency = 'Weekly'
        // ignore: deprecated_member_use
        ..paymentHistory = ['Sep 4, 2026 (8:00 AM): +₱1234']);
    });

    await IsarService.migrate(isar);

    final ana =
        await isar.participants.filter().nameEqualTo('Ana Reyes').findFirst();
    final records =
        await isar.paymentRecords.filter().participantIdEqualTo(ana!.id).findAll();

    expect(records, hasLength(2));
    expect(records.fold<double>(0, (s, r) => s + r.amount),
        closeTo(1234.56, 0.001));
    expect(
      records.any((r) => r.note == 'Opening balance (v1.0)'),
      isTrue,
    );
  });

  test('repairs pre-v1.0 rows with an epoch createdAt and empty frequency',
      () async {
    final folder = await seedV1();
    await isar.writeTxn(() async {
      await isar.participants.put(Participant()
        ..folderId = folder.id
        ..name = 'Legacy Row'
        ..amountExpected = 2500
        ..amountPaid = 0
        ..isPaid = false
        // What a property added later deserializes to.
        ..createdAt = DateTime.fromMillisecondsSinceEpoch(0)
        ..frequency = ''
        // ignore: deprecated_member_use
        ..paymentHistory = []);
    });

    await IsarService.migrate(isar);

    final legacy =
        await isar.participants.filter().nameEqualTo('Legacy Row').findFirst();
    expect(legacy!.createdAt.year, greaterThan(2000));
    expect(legacy.frequency, Cadence.oneTime.label);

    // Without the repair this participant would read as decades behind.
    final migratedFolder = await isar.contriFolders.get(folder.id);
    final schedule = ContributionSchedule(
      totalAmount: legacy.amountExpected,
      cadence: cadenceFromLabel(legacy.frequency),
      start: migratedFolder!.effectiveStart,
      end: migratedFolder.deadline,
    );
    expect(schedule.arrearsAt(DateTime(2026, 10, 1), 0), 0);
  });

  test('preserves every plan and participant untouched', () async {
    await seedV1();
    await IsarService.migrate(isar);

    expect(await isar.contriFolders.count(), 1);
    expect(await isar.participants.count(), 2);

    final folder = await isar.contriFolders.where().findFirst();
    expect(folder!.title, 'Christmas Party');
    expect(folder.budget, 10000);
    expect(folder.deadline, DateTime(2026, 12, 25));

    final maria = await isar.participants
        .filter()
        .nameEqualTo('Maria Santos')
        .findFirst();
    expect(maria!.amountPaid, 1500);
    expect(maria.amountExpected, 2500);
    expect(maria.frequency, 'Weekly');
  });

  test('is idempotent and does not duplicate the ledger on a second run',
      () async {
    await seedV1();
    await IsarService.migrate(isar);
    final firstPass = await isar.paymentRecords.count();

    await IsarService.migrate(isar);
    expect(await isar.paymentRecords.count(), firstPass);

    final meta = await isar.appMetas.get(0);
    expect(meta!.schemaVersion, IsarService.currentSchemaVersion);
  });

  test('an already-migrated database is left alone', () async {
    await seedV1();
    await isar.writeTxn(() async {
      await isar.appMetas.put(
        AppMeta()..schemaVersion = IsarService.currentSchemaVersion,
      );
    });

    await IsarService.migrate(isar);

    // The guard short-circuits, so no ledger is built and no start date set.
    expect(await isar.paymentRecords.count(), 0);
    final folder = await isar.contriFolders.where().findFirst();
    expect(folder!.startDate, isNull);
  });

  test('an empty database migrates cleanly', () async {
    await IsarService.migrate(isar);
    expect(await isar.contriFolders.count(), 0);
    final meta = await isar.appMetas.get(0);
    expect(meta!.schemaVersion, IsarService.currentSchemaVersion);
  });
}
