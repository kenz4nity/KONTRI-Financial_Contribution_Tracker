import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../data/contribution_repository.dart';
import '../logic/schedule.dart';
import '../models/payment_record.dart';
import '../theme/app_theme.dart';
import 'proof_storage.dart';

/// Builds the per-plan PDF summary report.
abstract final class PdfReport {
  static const _blue = PdfColor.fromInt(0xFF0A84FF);
  static const _teal = PdfColor.fromInt(0xFF30D6C8);
  static const _green = PdfColor.fromInt(0xFF34C759);
  static const _behind = PdfColor.fromInt(0xFFE07C00);
  static const _ink = PdfColor.fromInt(0xFF1C1C1E);
  static const _muted = PdfColor.fromInt(0xFF6D6D72);
  static const _hairline = PdfColor.fromInt(0xFFE3E3E8);
  static const _tint = PdfColor.fromInt(0xFFF2F2F7);

  static final _dateFormat = DateFormat('MMM d, yyyy');
  static final _dateTimeFormat = DateFormat('MMM d, yyyy · h:mm a');

  /// Suggested filename, e.g. `Kontri-Christmas-Party-20260830.pdf`.
  static String fileNameFor(FolderDetail detail) {
    final slug = detail.folder.title
        .replaceAll(RegExp(r'[^A-Za-z0-9 ]'), '')
        .trim()
        .replaceAll(RegExp(r'\s+'), '-');
    final stamp = DateFormat('yyyyMMdd').format(DateTime.now());
    return 'Kontri-${slug.isEmpty ? 'Plan' : slug}-$stamp.pdf';
  }

  /// Renders the report.
  ///
  /// [includeProofs] appends the attached payment images; it is off by default
  /// because a dozen screenshots can turn a 40 KB report into several MB.
  static Future<Uint8List> build(
    FolderDetail detail, {
    bool includeProofs = false,
  }) async {
    // Helvetica, the pdf package's built-in face, has no glyph for the peso
    // sign and would render every amount with a blank box.
    final regular =
        pw.Font.ttf(await rootBundle.load('assets/fonts/NotoSans-Regular.ttf'));
    final bold =
        pw.Font.ttf(await rootBundle.load('assets/fonts/NotoSans-Bold.ttf'));
    final logo = pw.MemoryImage(
      (await rootBundle.load('assets/logo.png')).buffer.asUint8List(),
    );

    final proofImages = includeProofs ? await _loadProofs(detail) : const {};

    final doc = pw.Document(
      title: '${detail.folder.title} - Kontri summary',
      author: 'Kontri',
    );

    doc.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.fromLTRB(32, 32, 32, 40),
          theme: pw.ThemeData.withFont(base: regular, bold: bold),
        ),
        header: (context) =>
            context.pageNumber == 1 ? pw.SizedBox() : _runningHeader(detail),
        footer: (context) => _footer(context),
        build: (context) => [
          _header(detail, logo),
          pw.SizedBox(height: 20),
          _summary(detail),
          pw.SizedBox(height: 22),
          _sectionTitle('Participants'),
          pw.SizedBox(height: 8),
          _participantTable(detail),
          pw.SizedBox(height: 22),
          _sectionTitle('Payment ledger'),
          pw.SizedBox(height: 8),
          _ledger(detail),
          if (includeProofs && proofImages.isNotEmpty) ...[
            pw.SizedBox(height: 22),
            _sectionTitle('Proof of payment'),
            pw.SizedBox(height: 8),
            _proofGallery(detail, proofImages.cast<int, pw.MemoryImage>()),
          ],
        ],
      ),
    );

    return doc.save();
  }

  static Future<Map<int, pw.MemoryImage>> _loadProofs(
    FolderDetail detail,
  ) async {
    final images = <int, pw.MemoryImage>{};
    for (final view in detail.participants) {
      for (final payment in view.payments) {
        final file = ProofStorage.fileFor(payment.proofFileName);
        if (file == null) continue;
        try {
          images[payment.id] = pw.MemoryImage(await file.readAsBytes());
        } catch (_) {
          // A single unreadable image must not fail the whole export.
        }
      }
    }
    return images;
  }

  // -------------------------------------------------------------- sections

  static pw.Widget _header(FolderDetail detail, pw.MemoryImage logo) {
    final folder = detail.folder;
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: const pw.BoxDecoration(
        gradient: pw.LinearGradient(colors: [_blue, _teal]),
        borderRadius: pw.BorderRadius.all(pw.Radius.circular(14)),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 40,
            height: 40,
            decoration: const pw.BoxDecoration(
              color: PdfColors.white,
              borderRadius: pw.BorderRadius.all(pw.Radius.circular(10)),
            ),
            padding: const pw.EdgeInsets.all(4),
            child: pw.Image(logo),
          ),
          pw.SizedBox(width: 14),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Kontri summary report',
                    style: const pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 10,
                        letterSpacing: 0.6)),
                pw.SizedBox(height: 3),
                pw.Text(folder.title,
                    style: const pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
                pw.Text(
                  '${_dateFormat.format(folder.effectiveStart)}  to  '
                  '${_dateFormat.format(folder.deadline)}',
                  style: const pw.TextStyle(
                      color: PdfColors.white, fontSize: 10),
                ),
              ],
            ),
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text('Generated',
                  style: const pw.TextStyle(
                      color: PdfColors.white, fontSize: 8)),
              pw.SizedBox(height: 2),
              pw.Text(_dateFormat.format(DateTime.now()),
                  style: const pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _runningHeader(FolderDetail detail) => pw.Container(
        margin: const pw.EdgeInsets.only(bottom: 12),
        padding: const pw.EdgeInsets.only(bottom: 6),
        decoration: const pw.BoxDecoration(
          border: pw.Border(bottom: pw.BorderSide(color: _hairline)),
        ),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(detail.folder.title,
                style: const pw.TextStyle(
                    fontSize: 9,
                    color: _muted,
                    fontWeight: pw.FontWeight.bold)),
            pw.Text('Kontri summary report',
                style: const pw.TextStyle(fontSize: 9, color: _muted)),
          ],
        ),
      );

  static pw.Widget _footer(pw.Context context) => pw.Container(
        alignment: pw.Alignment.centerRight,
        margin: const pw.EdgeInsets.only(top: 10),
        child: pw.Text(
          'Page ${context.pageNumber} of ${context.pagesCount}',
          style: const pw.TextStyle(fontSize: 9, color: _muted),
        ),
      );

  static pw.Widget _sectionTitle(String text) => pw.Text(
        text,
        style: const pw.TextStyle(
            fontSize: 13, fontWeight: pw.FontWeight.bold, color: _ink),
      );

  static pw.Widget _summary(FolderDetail detail) {
    final folder = detail.folder;
    final remaining = (folder.budget - detail.collected).clamp(
      0.0,
      double.infinity,
    );
    final pct = folder.budget > 0
        ? (detail.collected / folder.budget * 100).clamp(0, 100)
        : 0;
    final daysLeft = folder.deadline.difference(DateTime.now()).inDays;

    return pw.Column(
      children: [
        pw.Row(
          children: [
            _statCard('Goal', kCurrency.format(folder.budget), _ink),
            pw.SizedBox(width: 8),
            _statCard('Collected', kCurrency.format(detail.collected), _green),
            pw.SizedBox(width: 8),
            _statCard('Remaining', kCurrency.format(remaining), _ink),
            pw.SizedBox(width: 8),
            _statCard(
              'Behind',
              detail.arrears > 0 ? kCurrency.format(detail.arrears) : '--',
              detail.arrears > 0 ? _behind : _muted,
            ),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: const pw.BoxDecoration(
            color: _tint,
            borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _inlineStat('Progress', '${pct.toStringAsFixed(0)}%'),
              _inlineStat('Participants', '${detail.participants.length}'),
              _inlineStat('Fully paid',
                  '${detail.paidCount} of ${detail.participants.length}'),
              _inlineStat('Behind', '${detail.behindCount}'),
              _inlineStat(
                daysLeft < 0 ? 'Overdue by' : 'Days left',
                '${daysLeft.abs()}',
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _statCard(String label, String value, PdfColor color) =>
      pw.Expanded(
        child: pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: _hairline),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(label,
                  style: const pw.TextStyle(fontSize: 8, color: _muted)),
              pw.SizedBox(height: 4),
              pw.Text(value,
                  style: pw.TextStyle(
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                      color: color)),
            ],
          ),
        ),
      );

  static pw.Widget _inlineStat(String label, String value) => pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text('$label: ',
              style: const pw.TextStyle(fontSize: 9, color: _muted)),
          pw.Text(value,
              style: const pw.TextStyle(
                  fontSize: 9, fontWeight: pw.FontWeight.bold, color: _ink)),
        ],
      );

  static pw.Widget _participantTable(FolderDetail detail) {
    if (detail.participants.isEmpty) {
      return _emptyNote('No participants have been added to this plan yet.');
    }

    return pw.TableHelper.fromTextArray(
      border: null,
      headerDecoration: const pw.BoxDecoration(color: _tint),
      headerHeight: 22,
      cellHeight: 20,
      headerStyle: const pw.TextStyle(
          fontSize: 8, fontWeight: pw.FontWeight.bold, color: _ink),
      cellStyle: const pw.TextStyle(fontSize: 8.5, color: _ink),
      rowDecoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: _hairline)),
      ),
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.centerRight,
        3: pw.Alignment.centerRight,
        4: pw.Alignment.centerRight,
        5: pw.Alignment.centerRight,
        6: pw.Alignment.centerRight,
        7: pw.Alignment.centerLeft,
      },
      headers: const [
        'Name',
        'Frequency',
        'Per period',
        'Expected',
        'Paid',
        'Balance',
        'Behind',
        'Status',
      ],
      data: detail.participants.map((view) {
        final p = view.participant;
        return [
          p.name,
          view.cadence == Cadence.oneTime ? 'One-time' : view.cadence.label,
          kCurrency.format(view.perPeriodAmount),
          kCurrency.format(p.amountExpected),
          kCurrency.format(p.amountPaid),
          kCurrency.format(view.remaining),
          view.arrears > 0 ? kCurrency.format(view.arrears) : '--',
          view.isFullyPaid
              ? 'Paid'
              : view.isBehind
                  ? 'Behind'
                  : 'On track',
        ];
      }).toList(),
    );
  }

  static pw.Widget _ledger(FolderDetail detail) {
    final names = <int, String>{
      for (final v in detail.participants) v.participant.id: v.participant.name,
    };
    final entries = <PaymentRecord>[
      for (final v in detail.participants) ...v.payments,
    ]..sort((a, b) => b.paidAt.compareTo(a.paidAt));

    if (entries.isEmpty) {
      return _emptyNote('No payments have been recorded yet.');
    }

    return pw.TableHelper.fromTextArray(
      border: null,
      headerDecoration: const pw.BoxDecoration(color: _tint),
      headerHeight: 22,
      cellHeight: 19,
      headerStyle: const pw.TextStyle(
          fontSize: 8, fontWeight: pw.FontWeight.bold, color: _ink),
      cellStyle: const pw.TextStyle(fontSize: 8.5, color: _ink),
      rowDecoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: _hairline)),
      ),
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.centerRight,
        3: pw.Alignment.center,
        4: pw.Alignment.centerLeft,
      },
      headers: const ['Date', 'Participant', 'Amount', 'Proof', 'Note'],
      data: entries
          .map((e) => [
                _dateTimeFormat.format(e.paidAt),
                names[e.participantId] ?? 'Unknown',
                kCurrency.format(e.amount),
                (e.proofFileName ?? '').isNotEmpty ? 'Yes' : '--',
                e.note ?? '',
              ])
          .toList(),
    );
  }

  static pw.Widget _proofGallery(
    FolderDetail detail,
    Map<int, pw.MemoryImage> images,
  ) {
    final tiles = <pw.Widget>[];
    for (final view in detail.participants) {
      for (final payment in view.payments) {
        final image = images[payment.id];
        if (image == null) continue;
        tiles.add(
          pw.Container(
            width: 150,
            padding: const pw.EdgeInsets.all(6),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: _hairline),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.ClipRRect(
                  horizontalRadius: 4,
                  verticalRadius: 4,
                  child: pw.Image(image, height: 150, fit: pw.BoxFit.cover),
                ),
                pw.SizedBox(height: 5),
                pw.Text(view.participant.name,
                    style: const pw.TextStyle(
                        fontSize: 8.5, fontWeight: pw.FontWeight.bold)),
                pw.Text(
                  '${kCurrency.format(payment.amount)} · '
                  '${_dateFormat.format(payment.paidAt)}',
                  style: const pw.TextStyle(fontSize: 8, color: _muted),
                ),
              ],
            ),
          ),
        );
      }
    }

    return pw.Wrap(spacing: 8, runSpacing: 8, children: tiles);
  }

  static pw.Widget _emptyNote(String text) => pw.Container(
        width: double.infinity,
        padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: const pw.BoxDecoration(
          color: _tint,
          borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
        ),
        child: pw.Text(text,
            style: const pw.TextStyle(fontSize: 9, color: _muted)),
      );
}
