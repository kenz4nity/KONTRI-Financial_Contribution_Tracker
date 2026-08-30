import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/proof_storage.dart';
import '../theme/app_theme.dart';

/// Asks whether to use the camera or the photo library, then picks and stores
/// the image. Returns the stored filename, or null if cancelled.
Future<String?> pickProof(BuildContext context) async {
  final source = await showCupertinoModalPopup<ImageSource>(
    context: context,
    builder: (popupContext) => CupertinoActionSheet(
      title: const Text('Attach proof of payment'),
      message: const Text('Add a receipt screenshot or a photo.'),
      actions: [
        CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(popupContext, ImageSource.camera),
          child: const Text('Take Photo'),
        ),
        CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(popupContext, ImageSource.gallery),
          child: const Text('Choose from Library'),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        isDefaultAction: true,
        onPressed: () => Navigator.pop(popupContext),
        child: const Text('Cancel'),
      ),
    ),
  );
  if (source == null) return null;
  return ProofStorage.pickAndStore(source);
}

/// Square thumbnail of a stored proof, with a graceful placeholder when the
/// file is missing (the user cleared app storage, say).
class ProofThumbnail extends StatelessWidget {
  const ProofThumbnail({
    super.key,
    required this.fileName,
    this.size = 44,
    this.radius = KontriRadius.chip,
  });

  final String? fileName;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final file = ProofStorage.fileFor(fileName);

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        width: size,
        height: size,
        child: file == null
            ? Container(
                color: scheme.surfaceContainerHighest,
                child: Icon(CupertinoIcons.photo,
                    size: size * 0.42, color: scheme.onSurfaceVariant),
              )
            : Image.file(file, fit: BoxFit.cover),
      ),
    );
  }
}

/// The attach/replace control inside the payment sheet.
class ProofAttachmentField extends StatelessWidget {
  const ProofAttachmentField({
    super.key,
    required this.fileName,
    required this.onPick,
    required this.onClear,
  });

  final String? fileName;
  final VoidCallback onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasProof = (fileName ?? '').isNotEmpty;

    return Material(
      color: scheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(KontriRadius.field),
      child: InkWell(
        borderRadius: BorderRadius.circular(KontriRadius.field),
        onTap: onPick,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              if (hasProof)
                ProofThumbnail(fileName: fileName)
              else
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(KontriRadius.chip),
                  ),
                  child: Icon(CupertinoIcons.paperclip,
                      size: 18, color: scheme.primary),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasProof ? 'Proof attached' : 'Attach proof',
                      style:
                          KontriText.bodyStrong.copyWith(color: scheme.onSurface),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasProof ? 'Tap to replace' : 'Screenshot or photo',
                      style: KontriText.micro
                          .copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              if (hasProof)
                IconButton(
                  icon: Icon(CupertinoIcons.clear_circled_solid,
                      size: 20, color: scheme.onSurfaceVariant),
                  onPressed: onClear,
                  tooltip: 'Remove proof',
                )
              else
                Icon(CupertinoIcons.chevron_right,
                    size: 16, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

/// Full-screen, pinch-zoomable proof viewer.
///
/// Uses [InteractiveViewer] rather than adding a photo-viewer package.
class ProofViewerScreen extends StatelessWidget {
  const ProofViewerScreen({
    super.key,
    required this.fileName,
    required this.title,
    this.subtitle,
  });

  final String fileName;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final file = ProofStorage.fileFor(fileName);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700)),
            if (subtitle != null)
              Text(subtitle!,
                  style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
        leading: IconButton(
          icon: const Icon(CupertinoIcons.xmark, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: file == null
            ? const _MissingProof()
            : Hero(
                tag: 'proof-$fileName',
                child: InteractiveViewer(
                  minScale: 1,
                  maxScale: 5,
                  child: Image.file(file, fit: BoxFit.contain),
                ),
              ),
      ),
    );
  }
}

class _MissingProof extends StatelessWidget {
  const _MissingProof();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(CupertinoIcons.photo, size: 48, color: Colors.white38),
          SizedBox(height: 12),
          Text(
            'This proof image is no longer on the device.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

/// Opens [ProofViewerScreen] for a stored proof.
///
/// Pushed even when the file is missing: the viewer explains why the image is
/// gone, which is more useful than a tap that appears to do nothing.
void openProof(
  BuildContext context, {
  required String fileName,
  required String title,
  String? subtitle,
}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ProofViewerScreen(
        fileName: fileName,
        title: title,
        subtitle: subtitle,
      ),
    ),
  );
}
