import 'package:isar_community/isar.dart';

part 'contri_folder.g.dart';

/// A contribution plan ("ambagan") with a target budget and a deadline.
@collection
class ContriFolder {
  Id id = Isar.autoIncrement;
  late String title;
  late double budget;
  late DateTime deadline;

  DateTime? startDate;

  /// [startDate] with a safe fallback for any row the backfill has not reached.
  ///
  /// `@ignore` is required: Isar serializes public getters as stored properties
  /// by default, which would persist a derived value that goes stale.
  @ignore
  DateTime get effectiveStart {
    final s = startDate;
    if (s == null || !s.isBefore(deadline)) {
      return deadline.subtract(const Duration(days: 30));
    }
    return s;
  }
}
