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
class AppPalette {
  const AppPalette._(this.isDark);

  final bool isDark;

  factory AppPalette.of(BuildContext context) =>
      AppPalette._(Theme.of(context).brightness == Brightness.dark);

  Color get background => isDark ? kDarkBackground : Colors.white;
  Color get surface => isDark ? kDarkSurface : Colors.white;
  Color get border => isDark ? kDarkBorder : const Color(0xFFEAEAEA);
  Color get primary => isDark ? kDarkPrimary : kBrandOrange;
  Color get textPrimary => isDark ? Colors.white : const Color(0xFF1A1A1A);
  Color get textSecondary => isDark ? const Color(0xFFFDFDFD) : const Color(0xFF9A9A9A);
  Color get divider => isDark ? kDarkBorder : const Color(0xFFEAEAEA);
}
