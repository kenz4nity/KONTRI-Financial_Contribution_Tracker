import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:kontri/data/contribution_repository.dart';
import 'package:kontri/logic/schedule.dart';
import 'package:kontri/models/contri_folder.dart';
import 'package:kontri/models/participant.dart';
import 'package:kontri/models/payment_record.dart';
import 'package:kontri/services/pdf_report.dart';

/// Builds a plan that exercises every branch of the report: someone paid up,
/// someone behind, someone who has never paid, and a one-time contributor.
FolderDetail _sampleDetail({bool empty = false}) {
  final folder = ContriFolder()
    ..id = 1
    ..title = 'Christmas Party 2026'
    ..budget = 10000
    ..startDate = DateTime(2026, 8, 30)
    ..deadline = DateTime(2026, 9, 30);

  if (empty) {
    return FolderDetail(
      folder: folder,
      participants: const [],
      collected: 0,
      arrears: 0,
    );
  }

  final now = DateTime(2026, 9, 20);

  ParticipantView build(
    int id,
    String name,
    Cadence cadence,
    double paid,
    List<PaymentRecord> payments,
  ) {
    final p = Participant()
      ..id = id
      ..folderId = 1
      ..name = name
      ..amountExpected = 2500
      ..amountPaid = paid
      ..isPaid = paid >= 2500
      ..createdAt = DateTime(2026, 8, 30)
      ..frequency = cadence.label;

    return ParticipantView(
      participant: p,
      schedule: ContributionSchedule(
        totalAmount: 2500,
        cadence: cadence,
        start: folder.effectiveStart,
        end: folder.deadline,
      ),
      payments: payments,
      now: now,
    );
  }

  PaymentRecord record(int id, int participantId, double amount, String? proof) =>
      PaymentRecord()
        ..id = id
        ..participantId = participantId
        ..folderId = 1
        ..amount = amount
        ..paidAt = DateTime(2026, 9, 6, 14, 30)
        ..proofFileName = proof;

  final participants = [
    build(1, 'Maria Santos', Cadence.weekly, 2500, [
      record(1, 1, 1250, 'proof_a.jpg'),
      record(2, 1, 1250, null),
    ]),
    build(2, 'Juan dela Cruz', Cadence.weekly, 625, [record(3, 2, 625, null)]),
    build(3, 'Ana Reyes', Cadence.monthly, 0, const []),
    build(4, 'Noli Bautista', Cadence.oneTime, 0, const []),
  ];

  return FolderDetail(
    folder: folder,
    participants: participants,
    collected: participants.fold(0.0, (s, v) => s + v.participant.amountPaid),
    arrears: participants.fold(0.0, (s, v) => s + v.arrears),
  );
}

void main() {
  // rootBundle needs a binding to serve the bundled fonts and logo.
  TestWidgetsFlutterBinding.ensureInitialized();

  test('renders a valid PDF for a populated plan', () async {
    final bytes = await PdfReport.build(_sampleDetail());

    expect(latin1.decode(bytes.take(5).toList()), '%PDF-');
    // A report carrying an embedded TrueType subset is comfortably over 10 KB;
    // anything smaller means the font failed to embed.
    expect(bytes.length, greaterThan(10000));
  });

  test('embeds the bundled Noto Sans face rather than falling back', () async {
    final bytes = await PdfReport.build(_sampleDetail());
    final haystack = latin1.decode(bytes, allowInvalid: true);

    // Helvetica has no peso glyph, so a Helvetica-only document would render
    // every amount as a blank box. Assert Noto Sans actually made it in.
    expect(haystack, contains('NotoSans'));
    expect(haystack.contains('/BaseFont /Helvetica'), isFalse);
  });

  test('renders a plan with no participants without throwing', () async {
    final bytes = await PdfReport.build(_sampleDetail(empty: true));
    expect(latin1.decode(bytes.take(5).toList()), '%PDF-');
  });

  test('includeProofs is safe when the image files are absent', () async {
    // ProofStorage is uninitialised in tests, so every lookup misses. The
    // report must still build rather than blowing up mid-export.
    final bytes = await PdfReport.build(_sampleDetail(), includeProofs: true);
    expect(latin1.decode(bytes.take(5).toList()), '%PDF-');
  });

  test('builds a filesystem-safe filename from the plan title', () {
    final name = PdfReport.fileNameFor(_sampleDetail());
    expect(name, startsWith('Kontri-Christmas-Party-2026-'));
    expect(name, endsWith('.pdf'));
    expect(RegExp(r'[\\/:*?"<>|]').hasMatch(name), isFalse);
  });
}
