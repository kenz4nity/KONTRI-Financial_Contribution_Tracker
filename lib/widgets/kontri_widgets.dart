import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme/app_theme.dart';

/// Standard bottom-sheet chrome: grabber, rounded-28 surface, keyboard inset.
///
/// v1.0 copy-pasted this three times; three more sheets ship in v1.1, so it is
/// a widget now.
class KontriSheet extends StatelessWidget {
  const KontriSheet({super.key, required this.child, this.title});

  final Widget child;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(KontriRadius.sheet)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            if (title != null) ...[
              Text(title!,
                  style: KontriText.sectionTitle.copyWith(color: scheme.onSurface)),
              const SizedBox(height: 20),
            ],
            Flexible(child: child),
          ],
        ),
      ),
    );
  }
}

/// Presents [builder] inside a [KontriSheet].
Future<T?> showKontriSheet<T>({
  required BuildContext context,
  String? title,
  required WidgetBuilder builder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) =>
        KontriSheet(title: title, child: builder(sheetContext)),
  );
}

/// The 52px filled action button used at the foot of every sheet.
class KontriPrimaryButton extends StatelessWidget {
  const KontriPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          disabledBackgroundColor: scheme.onSurfaceVariant.withValues(alpha: 0.2),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(KontriRadius.button)),
          elevation: 0,
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18),
              const SizedBox(width: 8),
            ],
            Text(label, style: KontriText.button),
          ],
        ),
      ),
    );
  }
}

class KontriTextField extends StatelessWidget {
  const KontriTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.onChanged,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      autofocus: autofocus,
      style: TextStyle(color: scheme.onSurface, fontSize: 15),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, size: 18, color: scheme.onSurfaceVariant),
        hintText: label,
        hintStyle: TextStyle(color: scheme.onSurfaceVariant),
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KontriRadius.field),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

/// Tappable row that opens a wheel date picker — visually a sibling of
/// [KontriTextField].
class KontriDateField extends StatelessWidget {
  const KontriDateField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.minimumDate,
    this.maximumDate,
    this.icon = CupertinoIcons.calendar,
  });

  final String label;
  final DateTime value;
  final ValueChanged<DateTime> onChanged;
  final DateTime? minimumDate;
  final DateTime? maximumDate;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () async {
        final picked = await pickKontriDate(
          context,
          initial: value,
          minimumDate: minimumDate,
          maximumDate: maximumDate,
        );
        if (picked != null) onChanged(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(KontriRadius.field),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: scheme.onSurfaceVariant),
            const SizedBox(width: 10),
            Text(label,
                style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 15)),
            const Spacer(),
            Text(
              DateFormat('MMM d, yyyy').format(value),
              style: KontriText.bodyStrong.copyWith(color: scheme.onSurface),
            ),
          ],
        ),
      ),
    );
  }
}

/// iOS wheel date picker in a bottom sheet.
///
/// [minimumDate] is a parameter rather than a hardcoded `DateTime.now()`: a
/// plan's start date is usually in the past, and v1.0's fixed floor made such
/// a date impossible to pick.
Future<DateTime?> pickKontriDate(
  BuildContext context, {
  required DateTime initial,
  DateTime? minimumDate,
  DateTime? maximumDate,
}) {
  var temp = initial;
  final scheme = Theme.of(context).colorScheme;
  return showModalBottomSheet<DateTime>(
    context: context,
    backgroundColor: scheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(KontriRadius.sheet)),
    ),
    builder: (sheetContext) {
      return SizedBox(
        height: 320,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(sheetContext),
                  child: const Text('Cancel'),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: TextButton(
                    onPressed: () => Navigator.pop(sheetContext, temp),
                    child: const Text('Done',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: initial,
                minimumDate: minimumDate,
                maximumDate: maximumDate,
                onDateTimeChanged: (value) => temp = value,
              ),
            ),
          ],
        ),
      );
    },
  );
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: scheme.primary),
            ),
            const SizedBox(height: 20),
            Text(title,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface)),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

/// The blue-to-teal gradient shell shared by both screens' hero cards.
class GradientHeroCard extends StatelessWidget {
  const GradientHeroCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: KontriSpace.gutter),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [KontriColors.gradientStart, KontriColors.gradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(KontriRadius.sheet),
        boxShadow: [
          BoxShadow(
            color: KontriColors.gradientStart.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Small tinted badge, e.g. the arrears chip on a hero card.
class StatPill extends StatelessWidget {
  const StatPill({
    super.key,
    required this.label,
    this.icon,
    this.background,
    this.foreground,
  });

  final String label;
  final IconData? icon;
  final Color? background;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fg = foreground ?? scheme.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background ?? scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(KontriRadius.bar),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: fg),
            const SizedBox(width: 4),
          ],
          Text(label, style: KontriText.pill.copyWith(color: fg)),
        ],
      ),
    );
  }
}
