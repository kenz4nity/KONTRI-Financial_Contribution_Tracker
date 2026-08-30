import 'dart:developer' as developer;

import 'package:intl/intl.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../logic/schedule.dart';
import '../models/app_meta.dart';
import '../models/contri_folder.dart';
import '../models/participant.dart';
import '../models/payment_record.dart';

/// Opens the Isar database and brings a v1.0 database up to the v1.1 shape.
///
/// Data-safety rules this file exists to enforce — breaking any of them resets
/// a real user's records on upgrade:
///
///  * open with `directory: dir.path` and **no** `name:`, so the instance stays
///    `default` and points at the same files v1.0 wrote;
///  * never rename [ContriFolder] or [Participant] — Isar derives a
///    collection's identity from the class name;
///  * add only nullable fields or fields with Dart defaults;
///  * never call `isar.clear()` or delete the `.isar` file.
abstract final class IsarService {
  /// Bumped when a new one-time backfill is added. 0 = untouched v1.0 database.
  static const currentSchemaVersion = 2;

  static Future<Isar> open() async {
    final dir = await getApplicationDocumentsDirectory();
    final isar = await Isar.open(
      [
        ContriFolderSchema,
        ParticipantSchema,
        PaymentRecordSchema,
        AppMetaSchema,
      ],
      directory: dir.path,
    );
    await migrate(isar);
    return isar;
  }

  /// v1.0 log lines look like `Aug 2, 2026 (7:04 PM): +<peso>500`.
  static final _legacyDateFormat = DateFormat('MMM d, yyyy (h:mm a)');
  // Raw string: RegExp understands the \uHHHH escape for the peso sign
  // itself, so no Dart-level string escaping is involved.
  static final _legacyLogPattern =
      RegExp(r'^(.+?):\s*\+\u20B1\s*([0-9]+(?:\.[0-9]+)?)\s*$');

  /// Applies the v1.0 -> v1.1 backfill to an already-open database.
  ///
  /// Idempotent: guarded by [AppMeta.schemaVersion], so calling it twice is a
  /// no-op. [open] calls it automatically; it is public so the migration tests
  /// and the upgrade probe in `tool/upgrade_probe/` can drive it against a
  /// database they opened themselves.
  static Future<void> migrate(Isar isar) async {
    // A failed migration must leave the database exactly as it was. Every
    // step below is additive or corrective; nothing deletes user records.
    try {
      final meta = await isar.appMetas.get(0) ?? AppMeta();
      if (meta.schemaVersion >= currentSchemaVersion) return;

      await isar.writeTxn(() async {
        final folders = await isar.contriFolders.where().findAll();
        final participants = await isar.participants.where().findAll();

        final byFolder = <int, List<Participant>>{};
        for (final p in participants) {
          byFolder.putIfAbsent(p.folderId, () => []).add(p);
        }

        // 1. Give every plan a start date, so the schedule has a window.
        for (final folder in folders) {
          if (folder.startDate != null) continue;
          final members = byFolder[folder.id] ?? const <Participant>[];
          final joinDates = members
              .map((p) => p.createdAt)
              .where((d) => d.year > 2000)
              .toList()
            ..sort();
          var start = joinDates.isNotEmpty ? joinDates.first : DateTime.now();
          if (!start.isBefore(folder.deadline)) {
            start = folder.deadline.subtract(const Duration(days: 30));
          }
          folder.startDate = start;
          await isar.contriFolders.put(folder);
        }

        final foldersById = {for (final f in folders) f.id: f};

        for (final p in participants) {
          var dirty = false;

          // 2. Repair rows written before `createdAt`/`frequency` existed.
          // Those deserialize to the Isar epoch and '', which would otherwise
          // read as decades of missed payments.
          if (p.createdAt.year < 2000) {
            p.createdAt =
                foldersById[p.folderId]?.effectiveStart ?? DateTime.now();
            dirty = true;
          }
          if (p.frequency.trim().isEmpty ||
              !Cadence.values.any((c) => c.label == p.frequency)) {
            p.frequency = Cadence.oneTime.label;
            dirty = true;
          }
          if (dirty) await isar.participants.put(p);

          // 3. Rebuild the ledger from the v1.0 formatted log strings.
          final existing = await isar.paymentRecords
              .filter()
              .participantIdEqualTo(p.id)
              .count();
          if (existing > 0) continue;

          final rebuilt = <PaymentRecord>[];
          var parsedTotal = 0.0;
          // ignore: deprecated_member_use_from_same_package
          for (final line in p.paymentHistory) {
            final match = _legacyLogPattern.firstMatch(line.trim());
            if (match == null) continue;
            final amount = double.tryParse(match.group(2)!);
            if (amount == null || amount <= 0) continue;
            DateTime paidAt;
            try {
              paidAt = _legacyDateFormat.parse(match.group(1)!.trim());
            } on FormatException {
              paidAt = p.datePaid ?? p.createdAt;
            }
            parsedTotal += amount;
            rebuilt.add(PaymentRecord()
              ..participantId = p.id
              ..folderId = p.folderId
              ..amount = amount
              ..paidAt = paidAt
              ..note = 'Imported from v1.0');
          }

          // `amountPaid` stays authoritative. Where the log was lossy — v1.0
          // rounded amounts to whole pesos when formatting — one balancing row
          // keeps the itemisation summing to the total the user already sees.
          final remainder = p.amountPaid - parsedTotal;
          if (remainder.abs() >= 0.01) {
            rebuilt.add(PaymentRecord()
              ..participantId = p.id
              ..folderId = p.folderId
              ..amount = remainder
              ..paidAt = p.datePaid ?? p.createdAt
              ..note = 'Opening balance (v1.0)');
          }

          if (rebuilt.isNotEmpty) {
            await isar.paymentRecords.putAll(rebuilt);
          }
        }

        meta.schemaVersion = currentSchemaVersion;
        await isar.appMetas.put(meta);
      });
    } catch (error, stack) {
      // Leave schemaVersion untouched so the next launch retries. The app
      // still runs on the un-migrated data rather than losing it.
      developer.log(
        'Kontri v1.1 migration failed; database left unchanged',
        name: 'IsarService',
        error: error,
        stackTrace: stack,
      );
    }
  }
}
