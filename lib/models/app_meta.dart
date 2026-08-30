import 'package:isar_community/isar.dart';

part 'app_meta.g.dart';

/// Single-row bookkeeping so one-time migrations run exactly once.
@collection
class AppMeta {
  /// Fixed id — there is only ever one row.
  Id id = 0;

  /// 0 = pristine v1.0 database, 2 = v1.1 migration applied.
  int schemaVersion = 0;
}
