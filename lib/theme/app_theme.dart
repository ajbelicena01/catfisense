import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

ThemeData buildLightTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    textTheme: GoogleFonts.interTextTheme(),
    colorScheme: ColorScheme.fromSeed(seedColor: kBrandOrange),
  );
}

ThemeData buildDarkTheme() {
  final textTheme = GoogleFonts.interTextTheme(ThemeData(brightness: Brightness.dark).textTheme);
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: kDarkBackground,
    cardColor: kDarkSurface,
    dividerColor: kDarkBorder,
    textTheme: textTheme,
    colorScheme: ColorScheme.fromSeed(
      seedColor: kDarkPrimary,
      brightness: Brightness.dark,
      primary: kDarkPrimary,
      secondary: kDarkSecondary,
      tertiary: kDarkAccent,
      surface: kDarkSurface,
      outline: kDarkBorder,
    ),
  );
}

/// Centralizes the light/dark color mapping so pages don't each hand-roll
/// their own ternaries. One place to tweak if a role's color ever changes.
///
/// The farmer app uses [light] and [dark]. A part of the app can bring its
/// own colors by adding a palette to its theme's extensions (the admin area
/// does); dialogs and cards opened from there pick it up too.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.isDark,
    required this.background,
    required this.surface,
    required this.border,
    required this.primary,
    required this.primaryFill,
    required this.textPrimary,
    required this.textSecondary,
    required this.divider,
  });

  static const light = AppPalette(
    isDark: false,
    background: Colors.white,
    surface: Colors.white,
    border: Color(0xFFEAEAEA),
    primary: kBrandOrange,
    primaryFill: kBrandOrange,
    textPrimary: Color(0xFF1A1A1A),
    textSecondary: Color(0xFF595959),
    divider: Color(0xFFEAEAEA),
  );

  static const dark = AppPalette(
    isDark: true,
    background: kDarkBackground,
    surface: kDarkSurface,
    border: kDarkBorder,
    primary: kDarkPrimary,
    primaryFill: kDarkPrimary,
    textPrimary: Colors.white,
    textSecondary: Color(0xFFFDFDFD),
    divider: kDarkBorder,
  );

  factory AppPalette.of(BuildContext context) {
    final theme = Theme.of(context);
    return theme.extension<AppPalette>() ?? (theme.brightness == Brightness.dark ? dark : light);
  }

  final bool isDark;
  final Color background;
  final Color surface;
  final Color border;

  /// Icons, links, and other accents drawn on [surface].
  final Color primary;

  /// Behind white text, e.g. a filled button.
  final Color primaryFill;
  final Color textPrimary;
  final Color textSecondary;
  final Color divider;

  @override
  AppPalette copyWith({
    bool? isDark,
    Color? background,
    Color? surface,
    Color? border,
    Color? primary,
    Color? primaryFill,
    Color? textPrimary,
    Color? textSecondary,
    Color? divider,
  }) => AppPalette(
    isDark: isDark ?? this.isDark,
    background: background ?? this.background,
    surface: surface ?? this.surface,
    border: border ?? this.border,
    primary: primary ?? this.primary,
    primaryFill: primaryFill ?? this.primaryFill,
    textPrimary: textPrimary ?? this.textPrimary,
    textSecondary: textSecondary ?? this.textSecondary,
    divider: divider ?? this.divider,
  );

  /// Lets a theme switch fade between palettes.
  @override
  AppPalette lerp(AppPalette? other, double t) {
    if (other == null) return this;
    return AppPalette(
      isDark: t < 0.5 ? isDark : other.isDark,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      border: Color.lerp(border, other.border, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      primaryFill: Color.lerp(primaryFill, other.primaryFill, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
    );
  }
}
