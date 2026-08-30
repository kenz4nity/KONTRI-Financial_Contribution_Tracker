import 'dart:convert';
import 'dart:ffi' show Abi;
import 'dart:io';

import 'package:isar_community/isar.dart';

/// Shared setup for the two-step upgrade probe.
///
/// The probe answers the one question the in-repo migration tests cannot:
/// can the database file written by v1.0's Isar engine still be opened by the
/// `isar_community` engine v1.1 ships? `isar_community` bumped libmdbx, and a
/// storage-format break there would reset every user's data on upgrade.
///
/// Step 1 writes with the old `isar` 3.1.0+1 native library; step 2 reopens the
/// very same files with the new one. Run them in order, as separate processes,
/// because the native core can only be initialised once per process:
///
/// ```
/// flutter test tool/upgrade_probe/step1_write_with_v1_engine_test.dart
/// flutter test tool/upgrade_probe/step2_read_with_v11_engine_test.dart
/// ```
abstract final class ProbeSupport {
  /// A fixed location that survives between the two processes.
  static Directory get databaseDir =>
      Directory('build/upgrade_probe')..createSync(recursive: true);

  /// Native library shipped by `isar` 3.1.0+1 — what v1.0 wrote with.
  static Future<String> v1Library() =>
      _libraryFor('isar_flutter_libs', windows: 'isar.dll');

  /// Native library shipped by `isar_community` 3.3.2 — what v1.1 reads with.
  static Future<String> v11Library() =>
      _libraryFor('isar_community_flutter_libs', windows: 'libisar.dll');

  static Future<void> initialize(String libraryPath) async {
    if (!File(libraryPath).existsSync()) {
      throw StateError(
        'Native library not found at $libraryPath.\n'
        'The v1.0 engine comes from the pub cache; if it has been evicted, '
        'run `dart pub cache add isar_flutter_libs -v 3.1.0+1` first.',
      );
    }
    await Isar.initializeIsarCore(libraries: {Abi.current(): libraryPath});
  }

  static Future<String> _libraryFor(
    String packageName, {
    required String windows,
  }) async {
    final config = jsonDecode(
      File('.dart_tool/package_config.json').readAsStringSync(),
    ) as Map<String, dynamic>;

    final packages =
        (config['packages'] as List).cast<Map<String, dynamic>>();
    final match = packages.where((p) => p['name'] == packageName).firstOrNull;

    // `isar_flutter_libs` is no longer a dependency, so it will not appear in
    // the package config. Fall back to locating it directly in the pub cache.
    final Uri root;
    if (match != null) {
      root = Directory.current.uri
          .resolve('.dart_tool/')
          .resolve('${match['rootUri']}/');
    } else {
      root = _pubCacheDir(packageName);
    }

    return switch (Platform.operatingSystem) {
      'windows' => root.resolve('windows/$windows'),
      'macos' => root.resolve('macos/libisar.dylib'),
      _ => root.resolve('linux/libisar.so'),
    }.toFilePath();
  }

  static Uri _pubCacheDir(String packageName) {
    final cache = Platform.environment['PUB_CACHE'] ??
        (Platform.isWindows
            ? '${Platform.environment['LOCALAPPDATA']}/Pub/Cache'
            : '${Platform.environment['HOME']}/.pub-cache');
    final hosted = Directory('$cache/hosted/pub.dev');
    final candidates = hosted
        .listSync()
        .whereType<Directory>()
        .where((d) => d.path
            .split(Platform.pathSeparator)
            .last
            .startsWith('$packageName-'))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));
    if (candidates.isEmpty) {
      throw StateError('$packageName not found in the pub cache at $hosted');
    }
    return Directory(candidates.last.path).uri;
  }
}
