import 'package:flutter_test/flutter_test.dart';
import 'package:kontri/logic/schedule.dart';

void main() {
  group('cadenceFromLabel', () {
    test('resolves the labels persisted by v1.0', () {
      expect(cadenceFromLabel('One-time'), Cadence.oneTime);
      expect(cadenceFromLabel('Daily'), Cadence.daily);
      expect(cadenceFromLabel('Weekly'), Cadence.weekly);
      expect(cadenceFromLabel('Monthly'), Cadence.monthly);
    });

    test('falls back to one-time for pre-v1.0 rows and junk', () {
      // Rows written before `frequency` existed deserialize to ''. Any other
      // reading would invent arrears for a participant who owes nothing yet.
      expect(cadenceFromLabel(''), Cadence.oneTime);
      expect(cadenceFromLabel(null), Cadence.oneTime);
      expect(cadenceFromLabel('  '), Cadence.oneTime);
      expect(cadenceFromLabel('fortnightly'), Cadence.oneTime);
    });

    test('tolerates case and spacing variants', () {
      expect(cadenceFromLabel('weekly'), Cadence.weekly);
      expect(cadenceFromLabel(' Monthly '), Cadence.monthly);
    });
  });

  group('per-period amount', () {
    final start = DateTime(2026, 8, 30);
    final end = DateTime(2026, 9, 30);

    ContributionSchedule scheduleAt(Cadence cadence, {double total = 10000}) =>
        ContributionSchedule(
          totalAmount: total,
          cadence: cadence,
          start: start,
          end: end,
        );

    test('10,000 over one month paid weekly is 2,500 per week', () {
      final s = scheduleAt(Cadence.weekly);
      expect(s.periodCount, 4);
      expect(s.perPeriodAmount, 2500);
    });

    test('10,000 over one month paid monthly is one payment of 10,000', () {
      final s = scheduleAt(Cadence.monthly);
      expect(s.periodCount, 1);
      expect(s.perPeriodAmount, 10000);
    });

    test('daily splits across every day in the window', () {
      final s = scheduleAt(Cadence.daily);
      expect(s.periodCount, 31);
      expect(s.perPeriodAmount, closeTo(322.58, 0.01));
    });

    test('one-time is always a single payment', () {
      final s = scheduleAt(Cadence.oneTime);
      expect(s.periodCount, 1);
      expect(s.perPeriodAmount, 10000);
    });

    test('rounds the period count down so the goal is met by the deadline', () {
      // 31 days is 4.43 weeks. Rounding periods down (4) rounds the payment up
      // (2,500), which reaches 10,000 by the deadline. Rounding up (5) would
      // give 2,000/week and land short.
      final s = scheduleAt(Cadence.weekly);
      expect(s.perPeriodAmount * s.periodCount, greaterThanOrEqualTo(10000));
    });
  });

  group('degenerate windows', () {
    test('a zero-length plan still yields one period, never a divide by zero',
        () {
      final day = DateTime(2026, 8, 30);
      for (final cadence in Cadence.values) {
        final s = ContributionSchedule(
          totalAmount: 500,
          cadence: cadence,
          start: day,
          end: day,
        );
        expect(s.periodCount, 1, reason: '$cadence');
        expect(s.perPeriodAmount, 500, reason: '$cadence');
      }
    });

    test('an inverted window does not produce negative periods', () {
      final s = ContributionSchedule(
        totalAmount: 500,
        cadence: Cadence.weekly,
        start: DateTime(2026, 9, 30),
        end: DateTime(2026, 8, 30),
      );
      expect(s.periodCount, 1);
    });

    test('a zero budget yields a zero payment rather than NaN', () {
      final s = ContributionSchedule(
        totalAmount: 0,
        cadence: Cadence.weekly,
        start: DateTime(2026, 1, 1),
        end: DateTime(2026, 3, 1),
      );
      expect(s.perPeriodAmount, 0);
      expect(s.arrearsAt(DateTime(2026, 2, 1), 0), 0);
      expect(s.missedPeriodsAt(DateTime(2026, 2, 1), 0), 0);
    });
  });

  group('arrears', () {
    // 1,200 over twelve months is 100 a month.
    final s = ContributionSchedule(
      totalAmount: 1200,
      cadence: Cadence.monthly,
      start: DateTime(2026, 1, 1),
      end: DateTime(2027, 1, 1),
    );

    test('twelve monthly periods of 100', () {
      expect(s.periodCount, 12);
      expect(s.perPeriodAmount, 100);
    });

    test('100 a month with six months missed is 600 pending', () {
      final now = DateTime(2026, 7, 1);
      expect(s.periodsElapsedAt(now), 6);
      expect(s.expectedToDateAt(now), 600);
      expect(s.arrearsAt(now, 0), 600);
      expect(s.missedPeriodsAt(now, 0), 6);
    });

    test('paying on time clears the arrears', () {
      final now = DateTime(2026, 7, 1);
      expect(s.arrearsAt(now, 600), 0);
      expect(s.missedPeriodsAt(now, 600), 0);
    });

    test('a single lump sum settles many periods at once', () {
      // The v1.0 calculator counted payment *events*, so one lump sum covering
      // six months still read as five missed periods. Amount-based maths does
      // not have that failure.
      final now = DateTime(2026, 7, 1);
      expect(s.arrearsAt(now, 600), 0);
      expect(s.missedPeriodsAt(now, 600), 0);
    });

    test('many tiny payments do not fake being caught up', () {
      // The mirror of the bug above: five 1-peso payments used to mark five
      // periods covered.
      final now = DateTime(2026, 7, 1);
      expect(s.arrearsAt(now, 5), 595);
      expect(s.missedPeriodsAt(now, 5), 6);
    });

    test('partial payment leaves a partial period outstanding', () {
      final now = DateTime(2026, 7, 1);
      expect(s.arrearsAt(now, 550), 50);
      expect(s.missedPeriodsAt(now, 550), 1);
    });

    test('nothing is due before the plan starts', () {
      expect(s.arrearsAt(DateTime(2025, 12, 1), 0), 0);
      expect(s.periodsElapsedAt(DateTime(2025, 12, 1)), 0);
    });

    test('the whole balance falls due once the deadline passes', () {
      final past = DateTime(2027, 6, 1);
      expect(s.periodsElapsedAt(past), 12);
      expect(s.expectedToDateAt(past), 1200);
      expect(s.arrearsAt(past, 0), 1200);
    });

    test('expected-to-date never exceeds the total owed', () {
      for (var month = 1; month <= 12; month++) {
        final now = DateTime(2026, month, 15);
        expect(s.expectedToDateAt(now), lessThanOrEqualTo(1200));
      }
    });

    test('a one-time contribution is not behind until the deadline', () {
      final oneTime = ContributionSchedule(
        totalAmount: 500,
        cadence: Cadence.oneTime,
        start: DateTime(2026, 1, 1),
        end: DateTime(2026, 12, 1),
      );
      expect(oneTime.arrearsAt(DateTime(2026, 6, 1), 0), 0);
      expect(oneTime.arrearsAt(DateTime(2026, 12, 2), 0), 500);
    });
  });

  group('month arithmetic', () {
    test('a partial trailing month does not count as elapsed', () {
      // Added Jan 31, checked Feb 1: v1.0 reported one whole month elapsed.
      final s = ContributionSchedule(
        totalAmount: 1200,
        cadence: Cadence.monthly,
        start: DateTime(2026, 1, 31),
        end: DateTime(2027, 1, 31),
      );
      expect(s.periodsElapsedAt(DateTime(2026, 2, 1)), 0);
      expect(s.periodsElapsedAt(DateTime(2026, 2, 28)), 0);
      expect(s.periodsElapsedAt(DateTime(2026, 3, 31)), 2);
    });

    test('addPeriods clamps to the last day of a short month', () {
      expect(
        addPeriods(DateTime(2026, 1, 31), Cadence.monthly, 1),
        DateTime(2026, 2, 28),
      );
      expect(
        addPeriods(DateTime(2024, 1, 31), Cadence.monthly, 1),
        DateTime(2024, 2, 29),
      );
    });
  });

  group('next due date', () {
    final s = ContributionSchedule(
      totalAmount: 400,
      cadence: Cadence.weekly,
      start: DateTime(2026, 1, 1),
      end: DateTime(2026, 1, 29),
    );

    test('advances one period at a time', () {
      expect(s.periodCount, 4);
      expect(s.nextDueDateAt(DateTime(2026, 1, 1)), DateTime(2026, 1, 8));
      expect(s.nextDueDateAt(DateTime(2026, 1, 10)), DateTime(2026, 1, 15));
    });

    test('is null once the schedule is complete', () {
      expect(s.nextDueDateAt(DateTime(2026, 2, 10)), isNull);
    });

    test('never runs past the deadline', () {
      final next = s.nextDueDateAt(DateTime(2026, 1, 28));
      expect(next, isNotNull);
      expect(next!.isAfter(DateTime(2026, 1, 29)), isFalse);
    });
  });
}
