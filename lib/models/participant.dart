import 'package:isar_community/isar.dart';

part 'participant.g.dart';

/// One person contributing to a [ContriFolder], linked by [folderId].
///
/// No per-period or arrears fields live here on purpose: both are derived from
/// the plan window by `ContributionSchedule`, so they cannot drift out of sync
/// with the budget when it is edited or the participant count changes.
@collection
class Participant {
  Id id = Isar.autoIncrement;

  @Index()
  late int folderId;

  late String name;
  late double amountExpected;
  late double amountPaid;
  late bool isPaid;
  DateTime? datePaid;

  /// v1.0 payment log: pre-formatted display strings such as
  /// `'Aug 2, 2026 (7:04 PM): +PHP 500'`.
  ///
  /// Superseded by the `PaymentRecord` collection. Still declared because
  /// removing an Isar property drops its data, and the v1.1 migration parses
  /// this to rebuild the ledger. Nothing writes to it any more.
  @Deprecated('Use PaymentRecord. Retained so the v1.1 migration can read it.')
  List<String> paymentHistory = [];

  late DateTime createdAt;

  /// One of the `Cadence.label` values. Read it through `cadenceFromLabel`,
  /// never by direct string comparison — pre-v1.0 rows deserialize to `''`.
  late String frequency;
}
