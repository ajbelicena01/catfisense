import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

// The admin area's blue palette (the farmer app keeps its orange one).
// Light: pale blues with navy text. Dark: near-black, navy cards, deep blue
// lines, grey-blue secondary text.
const _navy = Color(0xFF15223B);
const _deepBlue = Color(0xFF0A345F);
const _blue = Color(0xFF0869A3);
const _strongBlue = Color(0xFF08519C);
const _midBlue = Color(0xFF3182BD);
const _skyBlue = Color(0xFF6BAED6);
const _paleBlue = Color(0xFFC6DBEF);
const _mistBlue = Color(0xFFEFF3FF);
const _greyBlue = Color(0xFFA6BFD4);
const _nearBlack = Color(0xFF0C0D0C);

const adminLightPalette = AppPalette(
  isDark: false,
  background: _mistBlue,
  surface: Colors.white,
  border: _paleBlue,
  primary: _strongBlue,
  primaryFill: _strongBlue,
  textPrimary: _navy,
  textSecondary: Color(0xFF4B6584),
  divider: _paleBlue,
);

const adminDarkPalette = AppPalette(
  isDark: true,
  background: _nearBlack,
  surface: _navy,
  border: _deepBlue,
  // The palette's #0869A3 is too dim for small icons and text on navy, so
  // accents use the lighter sky blue; it still fills buttons and tabs.
  primary: _skyBlue,
  primaryFill: _blue,
  textPrimary: _mistBlue,
  textSecondary: _greyBlue,
  divider: _deepBlue,
);

ThemeData _build(bool dark) {
  final palette = dark ? adminDarkPalette : adminLightPalette;
  // Built on the app's own themes so fonts and text styles stay the same.
  final base = dark ? buildDarkTheme() : buildLightTheme();
  final highlight = dark ? _blue : _paleBlue;
  final onHighlight = dark ? Colors.white : _strongBlue;
  final scheme = ColorScheme.fromSeed(
    seedColor: _strongBlue,
    brightness: dark ? Brightness.dark : Brightness.light,
  ).copyWith(
    primary: palette.primary,
    onPrimary: dark ? _nearBlack : Colors.white,
    secondary: _midBlue,
    secondaryContainer: highlight,
    onSecondaryContainer: onHighlight,
    surface: palette.surface,
    onSurface: palette.textPrimary,
    onSurfaceVariant: palette.textSecondary,
    outline: palette.border,
    outlineVariant: palette.divider,
    surfaceContainerHigh: palette.surface,
  );
  return base.copyWith(
    colorScheme: scheme,
    scaffoldBackgroundColor: palette.background,
    cardColor: palette.surface,
    dividerColor: palette.divider,
    extensions: [palette],
    appBarTheme: AppBarTheme(backgroundColor: palette.surface, foregroundColor: palette.textPrimary),
    dialogTheme: DialogThemeData(backgroundColor: palette.surface),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: palette.primary),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: palette.surface,
      indicatorColor: highlight,
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(color: states.contains(WidgetState.selected) ? onHighlight : palette.textSecondary),
      ),
    ),
  );
}

final _light = _build(false);
final _dark = _build(true);

/// The admin area's theme for light or dark mode.
ThemeData adminTheme({required bool dark}) => dark ? _dark : _light;
