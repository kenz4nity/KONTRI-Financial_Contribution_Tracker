import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../logic/schedule.dart';
import '../theme/app_theme.dart';

/// Live "what will this actually cost" preview for a whole plan, shown in the
/// New/Edit Plan sheet before any participants exist.
///
/// Answers the question the budget field alone cannot: 10,000 over one month is
/// 2,500 a week.
class PacePreviewCard extends StatelessWidget {
  const PacePreviewCard({
    super.key,
    required this.budget,
    required this.start,
    required this.end,
  });

  final double budget;
  final DateTime start;
  final DateTime end;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasBudget = budget > 0;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(KontriRadius.field),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(CupertinoIcons.chart_pie_fill,
                  size: 15, color: scheme.primary),
              const SizedBox(width: 8),
              Text('Contribution pace',
                  style: KontriText.label.copyWith(color: scheme.onSurface)),
              const Spacer(),
              Text(
                hasBudget
                    ? '${end.difference(start).inDays} days'
                    : 'Enter a budget',
                style: KontriText.micro
                    .copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // A fixed 2x2 grid keeps the sheet height stable as the user types.
          Row(
            children: [
              Expanded(child: _tile(context, Cadence.daily, hasBudget)),
              const SizedBox(width: 8),
              Expanded(child: _tile(context, Cadence.weekly, hasBudget)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _tile(context, Cadence.monthly, hasBudget)),
              const SizedBox(width: 8),
              Expanded(child: _tile(context, Cadence.oneTime, hasBudget)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, Cadence cadence, bool hasBudget) {
    final scheme = Theme.of(context).colorScheme;
    final schedule = ContributionSchedule(
      totalAmount: budget,
      cadence: cadence,
      start: start,
      end: end,
    );
    final periods = schedule.periodCount;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(KontriRadius.chip),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            cadence == Cadence.oneTime ? 'One-time' : cadence.label,
            style: KontriText.pill.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 4),
          Text(
            hasBudget ? formatCompact(schedule.perPeriodAmount) : '--',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: KontriText.captionStrong.copyWith(
              color: hasBudget ? scheme.onSurface : scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            cadence == Cadence.oneTime
                ? 'in full'
                : '$periods ${periods == 1 ? 'payment' : 'payments'}',
            style: TextStyle(fontSize: 10, color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

/// One participant's own pace, shown live under the frequency picker.
///
/// This is the "tell me my exact contribution" panel: the person's share of the
/// budget, divided by the periods their chosen cadence produces.
class ParticipantPacePanel extends StatelessWidget {
  const ParticipantPacePanel({
    super.key,
    required this.share,
    required this.cadence,
    required this.start,
    required this.end,
  });

  final double share;
  final Cadence cadence;
  final DateTime start;
  final DateTime end;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final schedule = ContributionSchedule(
      totalAmount: share,
      cadence: cadence,
      start: start,
      end: end,
    );
    final periods = schedule.periodCount;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      switchInCurve: Curves.easeOutCubic,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SizeTransition(
          sizeFactor: animation,
          alignment: Alignment.topCenter,
          child: child,
        ),
      ),
      child: Container(
        // Keying on the cadence is what drives the switch animation.
        key: ValueKey(cadence),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: scheme.primary.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(KontriRadius.field),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Flexible(
                  child: Text(
                    kCurrency.format(schedule.perPeriodAmount),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: KontriText.heroAmountSmall
                        .copyWith(color: scheme.primary),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  cadence == Cadence.oneTime ? 'in total' : 'per ${cadence.unit}',
                  style: KontriText.captionStrong.copyWith(color: scheme.primary),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              _subtitle(periods),
              style: KontriText.micro.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  String _subtitle(int periods) {
    final until = DateFormat('MMM d, yyyy').format(end);
    if (cadence == Cadence.oneTime) return 'One payment, due $until';
    return '$periods ${periods == 1 ? 'payment' : 'payments'} '
        '· ends $until';
  }
}

/// Compact arrears badge: "600 behind - 6 missed monthly".
class ArrearsBadge extends StatelessWidget {
  const ArrearsBadge({
    super.key,
    required this.arrears,
    required this.missedPeriods,
    required this.cadence,
  });

  final double arrears;
  final int missedPeriods;
  final Cadence cadence;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: KontriColors.behind.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(KontriRadius.bar),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(CupertinoIcons.exclamationmark_triangle_fill,
              size: 11, color: KontriColors.behind),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              '${formatCompact(arrears)} behind'
              '${missedPeriods > 0 && cadence != Cadence.oneTime ? ' · $missedPeriods missed ${cadence.adverb}' : ''}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: KontriText.micro.copyWith(
                color: KontriColors.behind,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
