import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:kontri/data/isar_service.dart';
import 'package:kontri/models/app_meta.dart';
import 'package:kontri/models/contri_folder.dart';
import 'package:kontri/models/participant.dart';
import 'package:kontri/models/payment_record.dart';

import 'probe_support.dart';

/// Step 2 of the upgrade probe: reopen the file step 1 wrote, using the
/// `isar_community` engine v1.1 ships, then run the real migration over it.
///
/// This is the closest a headless test gets to installing v1.1 over v1.0.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('reads the v1.0 database with the new engine and migrates it', () async {
    final dir = ProbeSupport.databaseDir;
    expect(
      File('${dir.path}/default.isar').existsSync(),
      isTrue,
      reason: 'run step1_write_with_v1_engine_test.dart first',
    );

    await ProbeSupport.initialize(await ProbeSupport.v11Library());

    final isar = await Isar.open(
      [
        ContriFolderSchema,
        ParticipantSchema,
        PaymentRecordSchema,
        AppMetaSchema,
      ],
      directory: dir.path,
    );

    // Nothing was lost opening the old file with the new engine.
    expect(await isar.contriFolders.count(), 1);
    expect(await isar.participants.count(), 1);

    final folder = await isar.contriFolders.where().findFirst();
    expect(folder!.title, 'Christmas Party');
    expect(folder.budget, 10000);
    expect(folder.deadline, DateTime(2026, 12, 25));
    expect(folder.startDate, isNull, reason: 'not yet migrated');

    final maria = await isar.participants.where().findFirst();
    expect(maria!.name, 'Maria Santos');
    expect(maria.amountPaid, 1500);
    // ignore: deprecated_member_use
    expect(maria.paymentHistory, hasLength(2));

    await IsarService.migrate(isar);

    final migratedFolder = await isar.contriFolders.get(folder.id);
    expect(migratedFolder!.startDate, DateTime(2026, 9, 1));
    expect(await isar.paymentRecords.count(), 2);
    expect(
      (await isar.paymentRecords.where().findAll())
          .fold<double>(0, (s, r) => s + r.amount),
      closeTo(1500, 0.001),
    );

    await isar.close();
    stdout.writeln('PROBE STEP 2: v1.0 file opened and migrated cleanly');
  });
}
