import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kontri/logic/schedule.dart';
import 'package:kontri/theme/app_theme.dart';
import 'package:kontri/widgets/kontri_widgets.dart';
import 'package:kontri/widgets/pace_widgets.dart';

/// Renders the widgets that surface v1.1's new numbers, in both themes.
///
/// These are deliberately the *pure* widgets. Both screens load from Isar in
/// `initState`, and `testWidgets` fakes timers in a way that never lets a
/// pending native Isar future complete, so pumping a whole screen only spins
/// its loading indicator. Screen-level rendering is covered by running the app
/// on a device (see the plan's verification steps); what matters most here is
/// that the maths reaches the pixels correctly, which is what these widgets do.
void main() {
  final start = DateTime(2026, 8, 30);
  final end = DateTime(2026, 9, 30);

  Future<void> pumpInBothThemes(
    WidgetTester tester,
    Widget child,
    Future<void> Function() expectations,
  ) async {
    for (final brightness in Brightness.values) {
      await tester.pumpWidget(MaterialApp(
        theme: buildKontriTheme(brightness),
        home: Scaffold(body: Center(child: child)),
      ));
      await tester.pumpAndSettle();
      await expectations();
      expect(tester.takeException(), isNull, reason: brightness.name);
    }
  }

  group('PacePreviewCard', () {
    testWidgets('shows the plan pace for all four cadences', (tester) async {
      await pumpInBothThemes(
        tester,
        PacePreviewCard(budget: 10000, start: start, end: end),
        () async {
          expect(find.text('Contribution pace'), findsOneWidget);
          // The example from the brief: 10,000 over one month.
          expect(find.textContaining('2,500'), findsOneWidget); // weekly
          expect(find.textContaining('322'), findsOneWidget); // daily
          expect(find.text('4 payments'), findsOneWidget);
          expect(find.text('31 payments'), findsOneWidget);
        },
      );
    });

    testWidgets('prompts for a budget instead of showing zeroes',
        (tester) async {
      await pumpInBothThemes(
        tester,
        PacePreviewCard(budget: 0, start: start, end: end),
        () async {
          expect(find.text('Enter a budget'), findsOneWidget);
          expect(find.text('--'), findsNWidgets(4));
        },
      );
    });

    testWidgets('survives a zero-length plan window', (tester) async {
      await pumpInBothThemes(
        tester,
        PacePreviewCard(budget: 5000, start: start, end: start),
        () async => expect(find.text('Contribution pace'), findsOneWidget),
      );
    });
  });

  group('ParticipantPacePanel', () {
    testWidgets('states the exact per-week contribution', (tester) async {
      await pumpInBothThemes(
        tester,
        ParticipantPacePanel(
          share: 2500,
          cadence: Cadence.weekly,
          start: start,
          end: end,
        ),
        () async {
          // A 2,500 share across four weekly periods.
          expect(find.text('₱625.00'), findsOneWidget);
          expect(find.text('per week'), findsOneWidget);
          expect(find.textContaining('4 payments'), findsOneWidget);
          expect(find.textContaining('Sep 30, 2026'), findsOneWidget);
        },
      );
    });

    testWidgets('describes a one-time contribution differently',
        (tester) async {
      await pumpInBothThemes(
        tester,
        ParticipantPacePanel(
          share: 2500,
          cadence: Cadence.oneTime,
          start: start,
          end: end,
        ),
        () async {
          expect(find.text('₱2,500.00'), findsOneWidget);
          expect(find.text('in total'), findsOneWidget);
          expect(find.textContaining('One payment, due'), findsOneWidget);
        },
      );
    });

    testWidgets('animates between cadences without throwing', (tester) async {
      Widget panel(Cadence cadence) => MaterialApp(
            theme: buildKontriTheme(Brightness.dark),
            home: Scaffold(
              body: ParticipantPacePanel(
                share: 2500,
                cadence: cadence,
                start: start,
                end: end,
              ),
            ),
          );

      await tester.pumpWidget(panel(Cadence.weekly));
      await tester.pumpAndSettle();
      expect(find.text('₱625.00'), findsOneWidget);

      await tester.pumpWidget(panel(Cadence.monthly));
      await tester.pumpAndSettle();
      expect(find.text('₱2,500.00'), findsOneWidget);
      expect(find.text('per month'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('ArrearsBadge', () {
    testWidgets('reads as pesos behind plus missed periods', (tester) async {
      await pumpInBothThemes(
        tester,
        const ArrearsBadge(
          arrears: 600,
          missedPeriods: 6,
          cadence: Cadence.monthly,
        ),
        () async {
          // The exact case from the brief: 100 a month, six months missed.
          expect(find.textContaining('₱600'), findsOneWidget);
          expect(find.textContaining('6 missed monthly'), findsOneWidget);
        },
      );
    });

    testWidgets('omits the period clause for a one-time contribution',
        (tester) async {
      await pumpInBothThemes(
        tester,
        const ArrearsBadge(
          arrears: 2500,
          missedPeriods: 1,
          cadence: Cadence.oneTime,
        ),
        () async {
          expect(find.textContaining('behind'), findsOneWidget);
          expect(find.textContaining('missed'), findsNothing);
        },
      );
    });

    testWidgets('does not overflow when squeezed into a narrow tile',
        (tester) async {
      // The badge sits in a participant row beside a name and a Pay button,
      // so it has to survive being squeezed.
      await tester.pumpWidget(MaterialApp(
        theme: buildKontriTheme(Brightness.dark),
        home: const Scaffold(
          body: Center(
            child: SizedBox(
              width: 120,
              child: ArrearsBadge(
                arrears: 1234567,
                missedPeriods: 52,
                cadence: Cadence.weekly,
              ),
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  group('shared widgets', () {
    testWidgets('EmptyState renders in both themes', (tester) async {
      await pumpInBothThemes(
        tester,
        const EmptyState(
          icon: Icons.folder,
          title: 'No folders yet',
          message: 'Tap New Plan to start.',
        ),
        () async => expect(find.text('No folders yet'), findsOneWidget),
      );
    });

    testWidgets('a disabled primary button exposes no callback',
        (tester) async {
      await pumpInBothThemes(
        tester,
        const KontriPrimaryButton(label: 'Create Plan', onPressed: null),
        () async {
          final button =
              tester.widget<ElevatedButton>(find.byType(ElevatedButton));
          expect(button.onPressed, isNull);
        },
      );
    });

    testWidgets('StatPill renders a per-period label', (tester) async {
      await pumpInBothThemes(
        tester,
        const StatPill(label: '₱625 / wk'),
        () async => expect(find.text('₱625 / wk'), findsOneWidget),
      );
    });
  });
}
