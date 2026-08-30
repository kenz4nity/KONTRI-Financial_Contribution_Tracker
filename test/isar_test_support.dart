import 'dart:convert';
import 'dart:ffi' show Abi;
import 'dart:io';

import 'package:isar_community/isar.dart';

/// Loads the Isar native library for tests.
///
/// `TestWidgetsFlutterBinding` stubs out HTTP, so Isar's auto-download cannot
/// work. Point it at the desktop binary `isar_community_flutter_libs` already
/// ships, located through the package config `flutter pub get` writes.
Future<void> initializeIsarForTests() async {
  final config = jsonDecode(
    File('.dart_tool/package_config.json').readAsStringSync(),
  ) as Map<String, dynamic>;

  final package = (config['packages'] as List)
      .cast<Map<String, dynamic>>()
      .firstWhere((p) => p['name'] == 'isar_community_flutter_libs');

  // rootUri is relative to .dart_tool/.
  final packageRoot = Directory.current.uri
      .resolve('.dart_tool/')
      .resolve('${package['rootUri']}/');

  final library = switch (Platform.operatingSystem) {
    'windows' => packageRoot.resolve('windows/libisar.dll'),
    'macos' => packageRoot.resolve('macos/libisar.dylib'),
    _ => packageRoot.resolve('linux/libisar.so'),
  };

  await Isar.initializeIsarCore(
    libraries: {Abi.current(): library.toFilePath()},
  );
}
