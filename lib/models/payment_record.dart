import 'package:isar_community/isar.dart';

part 'payment_record.g.dart';

/// A single contribution, replacing v1.0's formatted-string payment log.
///
/// Structured so the PDF report, the proof attachments and the ledger UI all
/// read the same rows. `Participant.amountPaid` remains the authoritative
/// running total; these records are the itemisation of it.
@collection
class PaymentRecord {
  Id id = Isar.autoIncrement;

  @Index()
  late int participantId;

  @Index()
  late int folderId;

  late double amount;
  late DateTime paidAt;

  String? note;

  /// Bare filename inside `<appDocuments>/kontri_proofs/`, never an absolute
  /// path: on iOS the app container UUID changes on every install and update,
  /// which would break a stored absolute path on exactly the upgrade this
  /// feature ships in. Resolve with `ProofStorage.resolve`.
  String? proofFileName;
}
