import 'dart:developer' as developer;
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

/// Stores payment-proof images inside the app's documents directory.
abstract final class ProofStorage {
  static const _dirName = 'kontri_proofs';
  static late final Directory _dir;
  static bool _ready = false;

  /// Must be awaited during startup, before any UI reads a proof.
  static Future<void> init() async {
    final docs = await getApplicationDocumentsDirectory();
    _dir = Directory('${docs.path}${Platform.pathSeparator}$_dirName');
    if (!await _dir.exists()) {
      await _dir.create(recursive: true);
    }
    _ready = true;
  }

  /// Absolute path for a stored proof. Returns null before [init] completes.
  static String? pathFor(String? fileName) {
    if (!_ready || fileName == null || fileName.isEmpty) return null;
    return '${_dir.path}${Platform.pathSeparator}$fileName';
  }

  /// A [File] for a stored proof, or null if it is missing from disk.
  static File? fileFor(String? fileName) {
    final path = pathFor(fileName);
    if (path == null) return null;
    final file = File(path);
    return file.existsSync() ? file : null;
  }

  /// Picks an image and copies it into app storage.
  ///
  /// Downscaling happens natively at pick time via [maxWidth]/[imageQuality],
  /// so a full-resolution screenshot does not need a compression package.
  /// Returns the stored filename, or null if the user cancelled.
  static Future<String?> pickAndStore(ImageSource source) async {
    final picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (picked == null) return null;

    final extension = _extensionOf(picked.name);
    final fileName =
        'proof_${DateTime.now().microsecondsSinceEpoch}$extension';
    await File(picked.path).copy('${_dir.path}${Platform.pathSeparator}$fileName');
    return fileName;
  }

  /// Removes a stored proof. Missing files are not an error.
  static Future<void> delete(String? fileName) async {
    final path = pathFor(fileName);
    if (path == null) return;
    try {
      final file = File(path);
      if (await file.exists()) await file.delete();
    } catch (error) {
      // Storage hygiene only — a stranded file must never block the database
      // write that removed the record pointing at it.
      developer.log('Could not delete proof $fileName',
          name: 'ProofStorage', error: error);
    }
  }

  static Future<void> deleteAll(Iterable<String?> fileNames) async {
    for (final name in fileNames) {
      await delete(name);
    }
  }

  static String _extensionOf(String name) {
    final dot = name.lastIndexOf('.');
    if (dot == -1 || dot == name.length - 1) return '.jpg';
    final ext = name.substring(dot).toLowerCase();
    return ext.length <= 5 ? ext : '.jpg';
  }
}
