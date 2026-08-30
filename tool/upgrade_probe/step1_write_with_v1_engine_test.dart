import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:kontri/models/app_meta.dart';
import 'package:kontri/models/contri_folder.dart';
import 'package:kontri/models/participant.dart';
import 'package:kontri/models/payment_record.dart';

import 'probe_support.dart';

/// Step 1 of the upgrade probe: write a database using the native engine that
/// Kontri v1.0 shipped (`isar` 3.1.0+1). See probe_support.dart.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('writes a v1.0-era database with the old engine', () async {
    final dir = ProbeSupport.databaseDir;
    // Start from a clean slate so step 2 cannot pass on stale files.
    for (final entity in dir.listSync()) {
      entity.deleteSync(recursive: true);
    }

    await ProbeSupport.initialize(await ProbeSupport.v1Library());

    final isar = await Isar.open(
      [
        ContriFolderSchema,
        ParticipantSchema,
        PaymentRecordSchema,
        AppMetaSchema,
      ],
      directory: dir.path,
    );

    final folder = ContriFolder()
      ..title = 'Christmas Party'
      ..budget = 10000
      ..deadline = DateTime(2026, 12, 25);

    await isar.writeTxn(() async {
      await isar.contriFolders.put(folder);
      await isar.participants.put(Participant()
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
        ]);
    });

    expect(await isar.contriFolders.count(), 1);
    expect(await isar.participants.count(), 1);
    await isar.close();

    expect(File('${dir.path}/default.isar').existsSync(), isTrue,
        reason: 'the old engine should have produced default.isar');
    stdout.writeln('PROBE STEP 1: wrote ${dir.path} with the v1.0 engine');
  });
}
