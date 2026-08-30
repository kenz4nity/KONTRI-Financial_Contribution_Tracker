import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Philippine peso formatting.
final NumberFormat kCurrency =
    NumberFormat.currency(locale: 'en_PH', symbol: '\u20B1', decimalDigits: 2);

/// Compact variant for tight chips: no decimals when the amount is whole.
String formatCompact(double amount) {
  if (amount == amount.roundToDouble()) {
    return NumberFormat.currency(
      locale: 'en_PH',
      symbol: '\u20B1',
      decimalDigits: 0,
    ).format(amount);
  }
  return kCurrency.format(amount);
}

/// Semantic colours. 
abstract final class KontriColors {
  static const blue = Color(0xFF0A84FF);
  static const green = Color(0xFF34C759);

  /// Destructive only — delete, remove, reset. Never "owes money".
  static const danger = Color(0xFFFF3B30);

  /// Deadline approaching.
  static const warning = Color(0xFFFF9500);

  /// Behind on contributions. Deliberately distinct from [danger] so an
  /// arrears badge does not read as a delete affordance.
  static const behind = Color(0xFFFF9F0A);

  static const gradientStart = Color(0xFF0A84FF);
  static const gradientEnd = Color(0xFF30D6C8);

  static const avatarPalette = <Color>[
    Color(0xFFFF9500),
    Color(0xFF34C759),
    Color(0xFF0A84FF),
    Color(0xFFFF375F),
    Color(0xFFAF52DE),
    Color(0xFF5AC8FA),
    Color(0xFFFFCC00),
    Color(0xFF30D158),
  ];
}

/// Stable per-name accent colour.
Color colorForName(String name) {
  if (name.isEmpty) return KontriColors.avatarPalette.first;
  final sum = name.codeUnits.fold<int>(0, (a, b) => a + b);
  return KontriColors.avatarPalette[sum % KontriColors.avatarPalette.length];
}

/// Corner radii used across the app.
abstract final class KontriRadius {
  static const sheet = 28.0;
  static const card = 20.0;
  static const tile = 18.0;
  static const button = 16.0;
  static const field = 14.0;
  static const chip = 10.0;
  static const bar = 6.0;
}

abstract final class KontriSpace {
  /// Horizontal page gutter.
  static const gutter = 20.0;

  /// Bottom list padding so the FAB never covers the last row.
  static const fabClearance = 110.0;
}

/// Colour is applied at the call site from the active [ColorScheme].
abstract final class KontriText {
  static const screenTitle =
      TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -1);
  static const heroAmount =
      TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5);
  static const heroAmountSmall =
      TextStyle(fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.5);
  static const sectionTitle = TextStyle(fontSize: 20, fontWeight: FontWeight.w800);
  static const cardTitle = TextStyle(fontSize: 16, fontWeight: FontWeight.w700);
  static const button = TextStyle(fontSize: 16, fontWeight: FontWeight.w700);
  static const body = TextStyle(fontSize: 15);
  static const bodyStrong = TextStyle(fontSize: 15, fontWeight: FontWeight.w600);
  static const label = TextStyle(fontSize: 14, fontWeight: FontWeight.w600);
  static const caption = TextStyle(fontSize: 13);
  static const captionStrong = TextStyle(fontSize: 13, fontWeight: FontWeight.w600);
  static const micro = TextStyle(fontSize: 12, fontWeight: FontWeight.w600);
  static const pill = TextStyle(fontSize: 10, fontWeight: FontWeight.w700);
}

/// iOS-flavoured Material 3 theme, adapting to light and dark.
ThemeData buildKontriTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;

  final Color pageBackground =
      isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F7);
  final Color surfaceBackground = isDark ? const Color(0xFF1C1C1E) : Colors.white;
  final Color onSurfaceColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
  final Color onSurfaceMuted =
      isDark ? const Color(0xFF98989D) : const Color(0xFF6D6D72);

  final colorScheme = ColorScheme.fromSeed(
    seedColor: KontriColors.blue,
    brightness: brightness,
  ).copyWith(
    primary: KontriColors.blue,
    onPrimary: Colors.white,
    secondary: KontriColors.green,
    onSecondary: Colors.white,
    error: KontriColors.danger,
    onError: Colors.white,
    surface: surfaceBackground,
    onSurface: onSurfaceColor,
    surfaceContainerHighest:
        isDark ? const Color(0xFF2C2C2E) : const Color(0xFFEFEFF4),
    onSurfaceVariant: onSurfaceMuted,
    outline: onSurfaceMuted.withValues(alpha: 0.3),
    outlineVariant: onSurfaceMuted.withValues(alpha: 0.15),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: pageBackground,
    // Native iOS system font on iOS; falls back to the platform default
    // (e.g. Roboto) elsewhere.
    fontFamily: '.SF Pro Text',
    splashFactory: NoSplash.splashFactory,
    appBarTheme: AppBarTheme(
      backgroundColor: pageBackground,
      foregroundColor: onSurfaceColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: onSurfaceColor,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: surfaceBackground,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(KontriRadius.card)),
      margin: EdgeInsets.zero,
    ),
    dividerTheme: DividerThemeData(
      color: onSurfaceMuted.withValues(alpha: 0.15),
      space: 1,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: KontriColors.blue,
      foregroundColor: Colors.white,
      elevation: 2,
      extendedTextStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(KontriRadius.card)),
    ),
    listTileTheme: ListTileThemeData(
      iconColor: onSurfaceMuted,
      textColor: onSurfaceColor,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: isDark ? const Color(0xFF2C2C2E) : const Color(0xFF1C1C1E),
      contentTextStyle:
          const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(KontriRadius.field)),
    ),
    textTheme: (isDark ? ThemeData.dark() : ThemeData.light()).textTheme.apply(
          bodyColor: onSurfaceColor,
          displayColor: onSurfaceColor,
        ),
  );
}
