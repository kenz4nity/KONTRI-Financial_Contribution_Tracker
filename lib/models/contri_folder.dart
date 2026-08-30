import 'package:isar_community/isar.dart';

part 'contri_folder.g.dart';

/// A contribution plan ("ambagan") with a target budget and a deadline.
///
/// The class name is the Isar collection identity — renaming it would orphan
/// every v1.0 row on every user's device.
@collection
class ContriFolder {
  Id id = Isar.autoIncrement;
  late String title;
  late double budget;
  late DateTime deadline;

  /// When contributions begin. Added in v1.1 to give the schedule a window to
  /// divide, since a deadline alone cannot answer "how many weeks?".
  ///
  /// Nullable so v1.0 rows deserialize; backfilled once by [IsarService].
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
