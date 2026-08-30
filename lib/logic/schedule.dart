/// Pure contribution-schedule math: how much is due each period, how much
/// *should* have been paid by now, and how far behind that leaves someone.

library;

import 'dart:math' as math;

/// How often a participant contributes.
///
/// [label] is the value persisted in `Participant.frequency` and used as the
/// segmented-control key. It must not change: v1.0 rows already contain these
/// exact strings.
enum Cadence {
  oneTime('One-time', 'one-time', 'total', 'total'),
  daily('Daily', 'daily', 'day', 'day'),
  weekly('Weekly', 'weekly', 'week', 'wk'),
  monthly('Monthly', 'monthly', 'month', 'mo');

  const Cadence(this.label, this.adverb, this.unit, this.shortUnit);

  /// Persisted value, e.g. `'Weekly'`.
  final String label;

  /// Used in sentences: "6 missed *weekly* payments".
  final String adverb;

  /// Used after an amount: "per *week*".
  final String unit;

  /// Compact form for tight chips: "/ *wk*".
  final String shortUnit;

  /// Label shown in the segmented control ('One-time' is too wide).
  String get pickerLabel => this == Cadence.oneTime ? '1-Time' : label;
}

/// Resolves a persisted frequency string to a [Cadence].
///
/// Never throws. Unknown or empty values — which is what pre-v1.0 rows
/// deserialize to, since `frequency` was added as a non-nullable `late` field —
/// fall back to [Cadence.oneTime], the only interpretation that cannot invent
/// arrears out of nothing.
Cadence cadenceFromLabel(String? raw) {
  if (raw == null) return Cadence.oneTime;
  final normalized = raw.trim().toLowerCase();
  for (final c in Cadence.values) {
    if (c.label.toLowerCase() == normalized) return c;
  }
  // Tolerate a few plausible variants rather than silently reporting
  // "never behind" for a value that merely differs in punctuation.
  switch (normalized) {
    case 'onetime':
    case 'one time':
    case 'once':
      return Cadence.oneTime;
    default:
      return Cadence.oneTime;
  }
}

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Whole calendar months from [start] to [end], not counting a partial trailing
/// month. Jan 31 -> Feb 1 is 0 months, not 1.
int _wholeMonthsBetween(DateTime start, DateTime end) {
  var months = (end.year - start.year) * 12 + (end.month - start.month);
  if (end.day < start.day) months -= 1;
  return months;
}

/// [start] advanced by [n] whole periods of [cadence].
///
/// Month arithmetic clamps the day so Jan 31 + 1 month is Feb 28/29 rather than
/// rolling into March, which is what a naive `DateTime(y, m + n, d)` would do.
DateTime addPeriods(DateTime start, Cadence cadence, int n) {
  switch (cadence) {
    case Cadence.oneTime:
      return start;
    case Cadence.daily:
      return DateTime(start.year, start.month, start.day + n);
    case Cadence.weekly:
      return DateTime(start.year, start.month, start.day + n * 7);
    case Cadence.monthly:
      final target = DateTime(start.year, start.month + n, 1);
      final lastDayOfTarget = DateTime(target.year, target.month + 1, 0).day;
      return DateTime(
        target.year,
        target.month,
        math.min(start.day, lastDayOfTarget),
      );
  }
}

/// One participant's (or one whole plan's) payment schedule.
///
/// Every figure is derived from [totalAmount], [cadence] and the [start]/[end]
/// window — nothing is stored, so a per-period amount can never drift out of
/// sync with the budget it came from.
class ContributionSchedule {
  ContributionSchedule({
    required this.totalAmount,
    required this.cadence,
    required DateTime start,
    required DateTime end,
  })  : start = _dateOnly(start),
        end = _dateOnly(end);

  final double totalAmount;
  final Cadence cadence;
  final DateTime start;
  final DateTime end;

  /// Number of payments the participant is expected to make.
  ///
  /// Rounds the period count *down* (minimum 1), which rounds the per-period
  /// amount *up*. That is the intentional direction: the plan then reaches its
  /// goal on or before the deadline instead of landing short. A 31-day window
  /// paid weekly is 4 periods, so PHP 10,000 becomes PHP 2,500/week.
  int get periodCount {
    if (cadence == Cadence.oneTime) return 1;
    final days = end.difference(start).inDays;
    if (days <= 0) return 1;
    switch (cadence) {
      case Cadence.oneTime:
        return 1;
      case Cadence.daily:
        return math.max(1, days);
      case Cadence.weekly:
        return math.max(1, days ~/ 7);
      case Cadence.monthly:
        return math.max(1, _wholeMonthsBetween(start, end));
    }
  }

  /// Amount due at each period. Zero for a non-positive budget.
  double get perPeriodAmount {
    if (totalAmount <= 0) return 0;
    return totalAmount / periodCount;
  }

  /// Periods that have already come due as of [now], clamped to [periodCount].
  ///
  /// Once the deadline passes the entire balance is due, so this saturates.
  int periodsElapsedAt(DateTime now) {
    final today = _dateOnly(now);
    if (!today.isAfter(start)) return 0;
    if (!today.isBefore(end)) return periodCount;

    final int elapsed;
    switch (cadence) {
      case Cadence.oneTime:
        // A one-time contribution is due at the deadline, not before.
        elapsed = 0;
      case Cadence.daily:
        elapsed = today.difference(start).inDays;
      case Cadence.weekly:
        elapsed = today.difference(start).inDays ~/ 7;
      case Cadence.monthly:
        elapsed = _wholeMonthsBetween(start, today);
    }
    return elapsed.clamp(0, periodCount);
  }

  /// How much should have been contributed by [now].
  double expectedToDateAt(DateTime now) {
    final expected = perPeriodAmount * periodsElapsedAt(now);
    return math.min(expected, totalAmount);
  }

  /// Unpaid portion of what was already due — the "you are PHP X behind" figure.
  ///
  /// Derived from amounts rather than payment counts, so a single lump sum
  /// covering ten periods and ten separate payments both settle correctly.
  double arrearsAt(DateTime now, double amountPaid) {
    final behind = expectedToDateAt(now) - amountPaid;
    return behind > 0 ? behind : 0;
  }

  /// [arrearsAt] expressed as a whole number of missed periods, for wording
  /// like "6 missed monthly payments".
  int missedPeriodsAt(DateTime now, double amountPaid) {
    final perPeriod = perPeriodAmount;
    if (perPeriod <= 0) return 0;
    final behind = arrearsAt(now, amountPaid);
    if (behind <= 0) return 0;
    // Tolerate float dust so PHP 599.9999999 does not read as 6 periods.
    final periods = (behind / perPeriod - 1e-9).ceil();
    return periods.clamp(0, periodCount);
  }

  /// When the next payment falls due, or `null` once the schedule is complete.
  DateTime? nextDueDateAt(DateTime now) {
    final elapsed = periodsElapsedAt(now);
    if (elapsed >= periodCount) return null;
    if (cadence == Cadence.oneTime) return end;
    final next = addPeriods(start, cadence, elapsed + 1);
    return next.isAfter(end) ? end : next;
  }
}
