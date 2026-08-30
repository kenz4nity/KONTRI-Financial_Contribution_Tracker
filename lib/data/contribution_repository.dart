import 'package:isar_community/isar.dart';

import '../logic/schedule.dart';
import '../models/contri_folder.dart';
import '../models/participant.dart';
import '../models/payment_record.dart';
import '../services/calendar_sync.dart';
import '../services/proof_storage.dart';

/// A participant with everything the UI needs already derived once.
class ParticipantView {
  ParticipantView({
    required this.participant,
    required this.schedule,
    required this.payments,
    required DateTime now,
  })  : arrears = schedule.arrearsAt(now, participant.amountPaid),
        missedPeriods = schedule.missedPeriodsAt(now, participant.amountPaid),
        nextDueDate = schedule.nextDueDateAt(now);

  final Participant participant;
  final ContributionSchedule schedule;
  final List<PaymentRecord> payments;
  final double arrears;
  final int missedPeriods;
  final DateTime? nextDueDate;

  Cadence get cadence => schedule.cadence;
  double get perPeriodAmount => schedule.perPeriodAmount;
  bool get isBehind => arrears > 0.005;

  bool get isFullyPaid =>
      participant.amountExpected > 0 &&
      participant.amountPaid >= participant.amountExpected;

  double get remaining {
    final left = participant.amountExpected - participant.amountPaid;
    return left > 0 ? left : 0;
  }

  double get progress => participant.amountExpected > 0
      ? (participant.amountPaid / participant.amountExpected).clamp(0.0, 1.0)
      : 0.0;

  int get proofCount =>
      payments.where((p) => (p.proofFileName ?? '').isNotEmpty).length;
}

/// Aggregate figures for one plan.
class FolderSummary {
  const FolderSummary({
    required this.collected,
    required this.participantCount,
    required this.paidCount,
    required this.arrears,
  });

  static const empty = FolderSummary(
    collected: 0,
    participantCount: 0,
    paidCount: 0,
    arrears: 0,
  );

  final double collected;
  final int participantCount;
  final int paidCount;
  final double arrears;
}

class DashboardData {
  const DashboardData({
    required this.folders,
    required this.summaries,
    required this.totalCollected,
    required this.totalBudget,
    required this.totalArrears,
  });

  static const empty = DashboardData(
    folders: [],
    summaries: {},
    totalCollected: 0,
    totalBudget: 0,
    totalArrears: 0,
  );

  final List<ContriFolder> folders;
  final Map<int, FolderSummary> summaries;
  final double totalCollected;
  final double totalBudget;
  final double totalArrears;
}

class FolderDetail {
  const FolderDetail({
    required this.folder,
    required this.participants,
    required this.collected,
    required this.arrears,
  });

  final ContriFolder folder;
  final List<ParticipantView> participants;
  final double collected;
  final double arrears;

  int get paidCount => participants.where((p) => p.isFullyPaid).length;
  int get behindCount => participants.where((p) => p.isBehind).length;
}

/// Every database mutation in the app goes through here, so the even-split rule
/// and the "recompute isPaid afterwards" rule each live in exactly one place.
class ContributionRepository {
  ContributionRepository(this.isar);

  final Isar isar;

  /// The even split. v1.0 inlined this formula in three separate places that
  /// could drift apart; this is now the single definition.
  static double splitAmount(double budget, int participantCount) =>
      participantCount <= 0 ? 0 : budget / participantCount;

  ContributionSchedule scheduleFor(ContriFolder folder, Participant p) =>
      ContributionSchedule(
        totalAmount: p.amountExpected,
        cadence: cadenceFromLabel(p.frequency),
        start: folder.effectiveStart,
        end: folder.deadline,
      );

  /// The whole plan's pace, used by the New Plan preview before anyone exists.
  static ContributionSchedule planSchedule({
    required double budget,
    required Cadence cadence,
    required DateTime start,
    required DateTime end,
  }) =>
      ContributionSchedule(
        totalAmount: budget,
        cadence: cadence,
        start: start,
        end: end,
      );

  // ----------------------------------------------------------------- reads

  Future<DashboardData> loadDashboard() async {
    final now = DateTime.now();
    final folders = await isar.contriFolders.where().findAll();
    final participants = await isar.participants.where().findAll();

    final byFolder = <int, List<Participant>>{};
    for (final p in participants) {
      byFolder.putIfAbsent(p.folderId, () => []).add(p);
    }

    final summaries = <int, FolderSummary>{};
    var totalCollected = 0.0;
    var totalBudget = 0.0;
    var totalArrears = 0.0;

    for (final folder in folders) {
      totalBudget += folder.budget;
      final members = byFolder[folder.id] ?? const <Participant>[];

      var collected = 0.0;
      var paidCount = 0;
      var arrears = 0.0;
      for (final p in members) {
        collected += p.amountPaid;
        if (p.amountExpected > 0 && p.amountPaid >= p.amountExpected) {
          paidCount++;
        }
        arrears += scheduleFor(folder, p).arrearsAt(now, p.amountPaid);
      }

      summaries[folder.id] = FolderSummary(
        collected: collected,
        participantCount: members.length,
        paidCount: paidCount,
        arrears: arrears,
      );
      totalCollected += collected;
      totalArrears += arrears;
    }

    return DashboardData(
      folders: folders,
      summaries: summaries,
      totalCollected: totalCollected,
      totalBudget: totalBudget,
      totalArrears: totalArrears,
    );
  }

  Future<FolderDetail> loadFolder(ContriFolder folder) async {
    final now = DateTime.now();
    final fresh = await isar.contriFolders.get(folder.id) ?? folder;
    final participants =
        await isar.participants.filter().folderIdEqualTo(fresh.id).findAll();
    final records =
        await isar.paymentRecords.filter().folderIdEqualTo(fresh.id).findAll();

    final byParticipant = <int, List<PaymentRecord>>{};
    for (final r in records) {
      byParticipant.putIfAbsent(r.participantId, () => []).add(r);
    }

    var collected = 0.0;
    var arrears = 0.0;
    final views = <ParticipantView>[];
    for (final p in participants) {
      final payments = byParticipant[p.id] ?? <PaymentRecord>[];
      payments.sort((a, b) => b.paidAt.compareTo(a.paidAt));
      final view = ParticipantView(
        participant: p,
        schedule: scheduleFor(fresh, p),
        payments: payments,
        now: now,
      );
      collected += p.amountPaid;
      arrears += view.arrears;
      views.add(view);
    }

    return FolderDetail(
      folder: fresh,
      participants: views,
      collected: collected,
      arrears: arrears,
    );
  }

  // ---------------------------------------------------------------- writes

  /// Creates or updates a plan, re-splitting the budget across existing
  /// participants in the *same* transaction so a failure cannot leave shares
  /// inconsistent with the budget.
  Future<void> saveFolder({
    ContriFolder? existing,
    required String title,
    required double budget,
    required DateTime startDate,
    required DateTime deadline,
  }) async {
    final folder = existing ?? ContriFolder();
    folder
      ..title = title
      ..budget = budget
      ..startDate = startDate
      ..deadline = deadline;

    await isar.writeTxn(() async {
      await isar.contriFolders.put(folder);
      if (existing == null) return;

      final members =
          await isar.participants.filter().folderIdEqualTo(folder.id).findAll();
      if (members.isEmpty) return;

      final share = splitAmount(budget, members.length);
      for (final p in members) {
        p.amountExpected = share;
        p.isPaid = p.amountPaid >= share;
      }
      await isar.participants.putAll(members);
    });
  }

  Future<void> deleteFolder(ContriFolder folder) async {
    final records =
        await isar.paymentRecords.filter().folderIdEqualTo(folder.id).findAll();
    await isar.writeTxn(() async {
      await isar.paymentRecords.filter().folderIdEqualTo(folder.id).deleteAll();
      await isar.participants.filter().folderIdEqualTo(folder.id).deleteAll();
      await isar.contriFolders.delete(folder.id);
    });
    await ProofStorage.deleteAll(records.map((r) => r.proofFileName));
  }

  Future<void> addParticipant(
    ContriFolder folder,
    String name,
    Cadence cadence,
  ) async {
    await isar.writeTxn(() async {
      final members =
          await isar.participants.filter().folderIdEqualTo(folder.id).findAll();
      final joined = Participant()
        ..folderId = folder.id
        ..name = name
        ..amountExpected = 0
        ..amountPaid = 0
        ..isPaid = false
        ..createdAt = DateTime.now()
        ..frequency = cadence.label;

      final all = [...members, joined];
      final share = splitAmount(folder.budget, all.length);
      for (final p in all) {
        p.amountExpected = share;
        // v1.0 skipped this on add and on delete, so lowering everyone's share
        // could leave an already-covered participant still flagged unpaid.
        p.isPaid = p.amountPaid >= share;
      }
      await isar.participants.putAll(all);
    });
  }

  Future<void> updateParticipant(
    Participant p,
    String name,
    Cadence cadence,
  ) async {
    await isar.writeTxn(() async {
      p
        ..name = name
        ..frequency = cadence.label;
      await isar.participants.put(p);
    });
  }

  Future<void> deleteParticipant(ContriFolder folder, Participant p) async {
    final records =
        await isar.paymentRecords.filter().participantIdEqualTo(p.id).findAll();

    await isar.writeTxn(() async {
      await isar.paymentRecords
          .filter()
          .participantIdEqualTo(p.id)
          .deleteAll();
      await isar.participants.delete(p.id);

      final remaining =
          await isar.participants.filter().folderIdEqualTo(folder.id).findAll();
      if (remaining.isEmpty) return;

      final share = splitAmount(folder.budget, remaining.length);
      for (final other in remaining) {
        other.amountExpected = share;
        other.isPaid = other.amountPaid >= share;
      }
      await isar.participants.putAll(remaining);
    });

    await ProofStorage.deleteAll(records.map((r) => r.proofFileName));
  }

  Future<void> recordPayment({
    required ContriFolder folder,
    required Participant p,
    required double amount,
    String? proofFileName,
    String? note,
  }) async {
    final paidAt = DateTime.now();
    await isar.writeTxn(() async {
      p
        ..amountPaid += amount
        ..isPaid = p.amountPaid >= p.amountExpected
        ..datePaid = paidAt;
      await isar.participants.put(p);
      await isar.paymentRecords.put(PaymentRecord()
        ..participantId = p.id
        ..folderId = folder.id
        ..amount = amount
        ..paidAt = paidAt
        ..note = note
        ..proofFileName = proofFileName);
    });

    await CalendarSync.logPayment(
      participantName: p.name,
      planTitle: folder.title,
      amount: amount,
      totalPaid: p.amountPaid,
    );
  }

  /// Deletes one ledger entry and rolls its amount back out of the running total.
  Future<void> deletePayment(Participant p, PaymentRecord record) async {
    await isar.writeTxn(() async {
      final rolled = p.amountPaid - record.amount;
      p
        ..amountPaid = rolled > 0 ? rolled : 0
        ..isPaid = p.amountPaid >= p.amountExpected;
      await isar.participants.put(p);
      await isar.paymentRecords.delete(record.id);
    });
    await ProofStorage.delete(record.proofFileName);
  }

  Future<void> resetPayment(Participant p) async {
    final records =
        await isar.paymentRecords.filter().participantIdEqualTo(p.id).findAll();
    await isar.writeTxn(() async {
      p
        ..isPaid = false
        ..amountPaid = 0
        ..datePaid = null;
      await isar.participants.put(p);
      await isar.paymentRecords
          .filter()
          .participantIdEqualTo(p.id)
          .deleteAll();
    });
    await ProofStorage.deleteAll(records.map((r) => r.proofFileName));
  }
}
