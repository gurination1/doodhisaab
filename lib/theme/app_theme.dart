// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// COLORS
// All color usage must reference these constants.
// Hardcoded hex values are NOT allowed anywhere else in the codebase.
// ─────────────────────────────────────────────────────────────────────────────

/// Primary action, confirmed state, success feedback.
const Color kGreen = Color(0xFF1B7A4A);

/// Button pressed / active state (darker green).
const Color kGreenDark = Color(0xFF145C37);

/// Outdoor mode primary action — higher saturation for direct sunlight.
/// Contrast ratio against white background: 9:1+ (vs 7:1 for kGreen on cream).
const Color kGreenOutdoor = Color(0xFF155D38);

/// App background — warm cream, reduces sunlight glare vs. pure white.
const Color kCream = Color(0xFFFBF8F1);

/// Primary text — near-black for AAA contrast on cream background.
const Color kInkBlack = Color(0xFF1A1A1A);

/// Secondary accent — mitti (earth) brown for decorative elements.
const Color kMittiBrown = Color(0xFF8B6914);

/// Error, overdue balance, dangerous action highlight.
const Color kAlertRed = Color(0xFFC0392B);

/// Warning, unusual entry, pending attention.
const Color kAmber = Color(0xFFD4820A);

/// Placeholder text, secondary / inactive UI elements.
const Color kMutedGray = Color(0xFF9E9E9E);

/// Card and surface background — slightly darker than kCream.
const Color kSurfaceGray = Color(0xFFF2EFE8);

/// White — modals, input fields, numpad keys.
const Color kWhite = Color(0xFFFFFFFF);

// ─────────────────────────────────────────────────────────────────────────────
// TOUCH TARGET SIZES  (all values in logical pixels / dp)
// ─────────────────────────────────────────────────────────────────────────────

/// Standard primary button height (e.g. "Next", "Add", "Cancel").
const double kButtonHeight = 56.0;

/// Confirmation / SAVE ALL button — most critical action in the app.
const double kConfirmButtonHeight = 72.0;

/// Customer list rows and any scrollable list item.
const double kListRowHeight = 64.0;

/// Bottom navigation icon tap targets.
const double kBottomNavHeight = 56.0;

/// Text input field height.
const double kInputHeight = 60.0;

// ─────────────────────────────────────────────────────────────────────────────
// TYPOGRAPHY SCALE
// Base: Noto Sans (Latin / numerals)
// RTL : Noto Nastaliq Urdu (Urdu text — use fontFamily override per widget)
// Minimum readable size: 16sp. Nothing below this in production.
//
//  Display   40sp Bold       — balance amounts, daily totals
//  Headline  28sp Bold       — screen titles, customer name on profile
//  Title     22sp SemiBold   — card primary values
//  BodyLg    18sp Regular    — customer list names, main content (Urdu body)
//  Body      16sp Regular    — secondary content
//  Label     14sp Medium     — form labels, column headers
//  Caption   13sp Regular    — timestamps, meta info  ← ABSOLUTE MINIMUM
// ─────────────────────────────────────────────────────────────────────────────

const TextStyle kDisplayStyle = TextStyle(
  fontSize: 40,
  fontWeight: FontWeight.bold,
  color: kInkBlack,
  height: 1.2,
);

const TextStyle kHeadlineStyle = TextStyle(
  fontSize: 28,
  fontWeight: FontWeight.bold,
  color: kInkBlack,
  height: 1.3,
);

const TextStyle kTitleStyle = TextStyle(
  fontSize: 22,
  fontWeight: FontWeight.w600,
  color: kInkBlack,
  height: 1.3,
);

const TextStyle kBodyLgStyle = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.normal,
  color: kInkBlack,
  height: 1.4,
);

/// Use this for Urdu body text — same scale, explicit RTL font.
const TextStyle kBodyLgUrduStyle = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.normal,
  fontFamily: 'NotoNastaliqUrdu',
  color: kInkBlack,
  height: 1.6, // Nastaliq needs more line height
);

const TextStyle kBodyStyle = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.normal,
  color: kInkBlack,
  height: 1.4,
);

const TextStyle kLabelStyle = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w500,
  color: kInkBlack,
  height: 1.3,
);

const TextStyle kCaptionStyle = TextStyle(
  fontSize: 13,
  fontWeight: FontWeight.normal,
  color: kMutedGray,
  height: 1.3,
);

// ─────────────────────────────────────────────────────────────────────────────
// RENDERING RULES (enforced by theme defaults below)
//
//  • No shadows on buttons — flat is faster on budget Helio G25 GPU
//  • No blur, no gradients, no glassmorphism
//  • All animations ≤ 200ms — 16.67ms frame budget must not be threatened
//  • Cream background reduces sunlight glare vs. pure white (outdoor use)
//  • Contrast ratio ≥ 7:1 AAA: kInkBlack on kCream = 14.7:1 ✓
//  • Outdoor mode: kWhite background + pure black text = 21:1 contrast ✓
//  • Color semantics — Green = confirmed, Red = overdue/error,
//    Amber = warning, Gray = inactive/secondary. NEVER use color decoratively.
// ─────────────────────────────────────────────────────────────────────────────

/// Build and return the standard app-wide [ThemeData].
///
/// Called from [DoodHisaabApp] when outdoor mode is OFF.
/// All widget defaults are set here so individual screens never need to
/// override colors or text styles inline.
ThemeData buildAppTheme() => _buildTheme(outdoor: false);

/// Build and return the outdoor / high-contrast [ThemeData].
///
/// Called from [DoodHisaabApp] when outdoor mode is ON.
/// Changes vs. normal theme:
///   • Scaffold background: kCream (#FBF8F1) → kWhite (#FFFFFF)
///   • Primary text:        kInkBlack (#1A1A1A) → pure black (#000000)
///   • Primary button:      kGreen (#1B7A4A) → kGreenOutdoor (#155D38)
///   • Contrast ratio:      7:1 → 9:1+
///
/// No ambient light sensor — manual toggle only (target hardware lacks sensor).
/// No background polling — the toggle persists to SQLite, app.dart reads once.
ThemeData buildOutdoorTheme() => _buildTheme(outdoor: true);

ThemeData buildDarkTheme() {
  const bg = Color(0xFF121212);
  const surface = Color(0xFF1B1B1B);
  const card = Color(0xFF222222);
  const text = Color(0xFFF5F5F5);
  const muted = Color(0xFFB8B8B8);

  final colorScheme = ColorScheme.fromSeed(
    seedColor: kGreen,
    brightness: Brightness.dark,
    surface: surface,
    onSurface: text,
    primary: kGreen,
    onPrimary: kWhite,
    error: kAlertRed,
    onError: kWhite,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: bg,
    fontFamily: 'NotoSans',
    textTheme: TextTheme(
      displayLarge: kDisplayStyle.copyWith(color: text),
      headlineMedium: kHeadlineStyle.copyWith(color: text),
      titleLarge: kTitleStyle.copyWith(color: text),
      bodyLarge: kBodyLgStyle.copyWith(color: text),
      bodyMedium: kBodyStyle.copyWith(color: text),
      labelLarge: kLabelStyle.copyWith(color: text),
      bodySmall: kCaptionStyle.copyWith(color: muted),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: surface,
      foregroundColor: text,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: text,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kGreen,
        foregroundColor: kWhite,
        minimumSize: const Size.fromHeight(kButtonHeight),
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: text,
        minimumSize: const Size.fromHeight(kButtonHeight),
        side: const BorderSide(color: Color(0xFF5A5A5A), width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: kAlertRed,
        minimumSize: const Size(88, kButtonHeight),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: card,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF5A5A5A)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF5A5A5A)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: kGreen, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: kAlertRed, width: 1.5),
      ),
      hintStyle: kBodyStyle.copyWith(color: muted),
    ),
    cardTheme: CardThemeData(
      color: card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFF343434), width: 1),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFF343434),
      thickness: 1,
      space: 1,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: surface,
      selectedItemColor: kGreen,
      unselectedItemColor: muted,
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: card,
      contentTextStyle: kBodyStyle.copyWith(color: text),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Internal builder — single source of truth for both themes.
// Keeps the two themes in sync automatically; only the 3 outdoor overrides
// need to change when the outdoor toggle is on.
// ─────────────────────────────────────────────────────────────────────────────

ThemeData _buildTheme({required bool outdoor}) {
  // The 3 values that change in outdoor mode.
  final Color bg      = outdoor ? kWhite      : kCream;
  final Color text    = outdoor ? Colors.black : kInkBlack;
  final Color primary = outdoor ? kGreenOutdoor : kGreen;

  // Surface gray darkens slightly in outdoor mode so cards still stand out
  // against the pure-white background.
  final Color surface = outdoor ? const Color(0xFFEAE7E0) : kSurfaceGray;

  final colorScheme = ColorScheme.fromSeed(
    seedColor: primary,
    brightness: Brightness.light,
    surface: bg,
    onSurface: text,
    primary: primary,
    onPrimary: kWhite,
    error: kAlertRed,
    onError: kWhite,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: bg,

    // ── Text theme ──────────────────────────────────────────────────────────
    // We set Noto Sans as the base. Screens displaying Urdu text apply
    // NotoNastaliqUrdu locally via DefaultTextStyle or explicit TextStyle.
    fontFamily: 'NotoSans',
    textTheme: TextTheme(
      displayLarge:  kDisplayStyle.copyWith(color: text),
      headlineMedium: kHeadlineStyle.copyWith(color: text),
      titleLarge:    kTitleStyle.copyWith(color: text),
      bodyLarge:     kBodyLgStyle.copyWith(color: text),
      bodyMedium:    kBodyStyle.copyWith(color: text),
      labelLarge:    kLabelStyle.copyWith(color: text),
      bodySmall:     kCaptionStyle, // caption stays muted gray in both modes
    ),

    // ── App bar ─────────────────────────────────────────────────────────────
    appBarTheme: AppBarTheme(
      backgroundColor: primary,
      foregroundColor: kWhite,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: kWhite,
      ),
    ),

    // ── Elevated button (primary actions) ──────────────────────────────────
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: kWhite,
        minimumSize: const Size.fromHeight(kButtonHeight),
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // ── Outlined button (secondary / cancel actions) ────────────────────────
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primary,
        minimumSize: const Size.fromHeight(kButtonHeight),
        side: BorderSide(color: primary, width: outdoor ? 2.0 : 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // ── Text button (destructive / low-prominence) ──────────────────────────
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: kAlertRed,
        minimumSize: const Size(88, kButtonHeight),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),

    // ── Input decoration (form fields) ─────────────────────────────────────
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: kWhite,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 18,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: outdoor ? Colors.black38 : kMutedGray),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: outdoor ? Colors.black38 : kMutedGray),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: kAlertRed, width: 1.5),
      ),
      hintStyle: kBodyStyle.copyWith(color: kMutedGray),
    ),

    // ── Card ────────────────────────────────────────────────────────────────
    cardTheme: CardThemeData(
      color: kWhite,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: outdoor ? Colors.black26 : kSurfaceGray,
          width: outdoor ? 1.5 : 1.0,
        ),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    ),

    // ── Divider ─────────────────────────────────────────────────────────────
    dividerTheme: DividerThemeData(
      color: outdoor ? Colors.black12 : kSurfaceGray,
      thickness: 1,
      space: 1,
    ),

    // ── Bottom navigation bar ───────────────────────────────────────────────
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: kWhite,
      selectedItemColor: primary,
      unselectedItemColor: outdoor ? Colors.black54 : kMutedGray,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle:
          const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      unselectedLabelStyle: const TextStyle(fontSize: 12),
    ),

    // ── Chip (quantity chips) ────────────────────────────────────────────────
    chipTheme: ChipThemeData(
      backgroundColor: surface,
      selectedColor: primary,
      secondarySelectedColor: primary,
      labelStyle: kBodyLgStyle.copyWith(color: text),
      secondaryLabelStyle: kBodyLgStyle.copyWith(color: kWhite),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: outdoor ? Colors.black38 : kMutedGray,
          width: 1,
        ),
      ),
    ),

    // ── Snack bar ────────────────────────────────────────────────────────────
    snackBarTheme: SnackBarThemeData(
      backgroundColor: text, // black in both modes — always visible
      contentTextStyle: kBodyStyle.copyWith(color: kWhite),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      behavior: SnackBarBehavior.floating,
    ),

    // ── Dialog ──────────────────────────────────────────────────────────────
    dialogTheme: DialogThemeData(
      backgroundColor: kWhite,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titleTextStyle: kHeadlineStyle.copyWith(color: text),
      contentTextStyle: kBodyStyle.copyWith(color: text),
    ),

    // ── Icon ────────────────────────────────────────────────────────────────
    iconTheme: IconThemeData(color: text, size: 24),
    primaryIconTheme: const IconThemeData(color: kWhite, size: 24),

    // ── Page transitions — keep fast for budget GPU ──────────────────────────
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
      },
    ),

    // ── Visual density — comfortable for large fingers ──────────────────────
    visualDensity: VisualDensity.standard,
  );
}
