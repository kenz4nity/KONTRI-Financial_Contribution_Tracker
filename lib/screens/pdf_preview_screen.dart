import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../data/contribution_repository.dart';
import '../services/pdf_report.dart';
import '../theme/app_theme.dart';

/// Renders the plan's PDF summary and hands off sharing, saving and printing
/// to [PdfPreview], which already provides those actions natively.
class PdfPreviewScreen extends StatelessWidget {
  const PdfPreviewScreen({
    super.key,
    required this.detail,
    this.includeProofs = false,
  });

  final FolderDetail detail;
  final bool includeProofs;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(CupertinoIcons.back, color: scheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Summary Report',
                style: KontriText.cardTitle.copyWith(color: scheme.onSurface)),
            Text(
              detail.folder.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
      body: PdfPreview(
        build: (_) => PdfReport.build(detail, includeProofs: includeProofs),
        pdfFileName: PdfReport.fileNameFor(detail),
        canDebug: false,
        canChangeOrientation: false,
        canChangePageFormat: false,
        loadingWidget: const Center(child: CupertinoActivityIndicator()),
        previewPageMargin: const EdgeInsets.all(12),
        actionBarTheme: PdfActionBarTheme(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          iconColor: scheme.primary,
          elevation: 0,
        ),
        onError: (context, error) => Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(CupertinoIcons.exclamationmark_triangle,
                  size: 40, color: scheme.error),
              const SizedBox(height: 12),
              Text(
                'The report could not be generated.',
                textAlign: TextAlign.center,
                style: KontriText.bodyStrong.copyWith(color: scheme.onSurface),
              ),
              const SizedBox(height: 6),
              Text(
                '$error',
                textAlign: TextAlign.center,
                style:
                    KontriText.micro.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
