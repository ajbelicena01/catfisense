import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'thresholds.dart';

enum PondStatus { healthy, warning, critical }

class PondStatusStyle {
  const PondStatusStyle({
    required this.color,
    required this.background,
    required this.dotColor,
    required this.icon,
  });

  final Color color;
  final Color background;
  final Color dotColor;
  final IconData icon;
}

const _statusStyles = {
  PondStatus.healthy: PondStatusStyle(
    color: Color(0xFF087443),
    background: Color(0xFFC9FFE5),
    dotColor: Color(0xFF6BE5B3),
    icon: Icons.check_circle,
  ),
  PondStatus.warning: PondStatusStyle(
    color: Color(0xFF804800),
    background: Color(0xFFFFF0CC),
    dotColor: Color(0xFFFBD195),
    icon: Icons.warning_amber_rounded,
  ),
  PondStatus.critical: PondStatusStyle(
    color: Color(0xFFB42335),
    background: Color(0xFFFFDBDB),
    dotColor: Color(0xFFFC98A1),
    icon: Icons.error,
  ),
};

PondStatusStyle styleFor(PondStatus status) => _statusStyles[status]!;

/// "Good", "Warning", "Critical" in the app's language.
String statusShortLabel(AppLocalizations l10n, PondStatus status) => switch (status) {
  PondStatus.healthy => l10n.statusGood,
  PondStatus.warning => l10n.statusWarning,
  PondStatus.critical => l10n.statusCritical,
};

/// The dashboard banner's sentence for [status].
String statusBannerLabel(AppLocalizations l10n, PondStatus status) => switch (status) {
  PondStatus.healthy => l10n.statusBannerGood,
  PondStatus.warning => l10n.statusBannerWarning,
  PondStatus.critical => l10n.statusBannerCritical,
};

/// Status accents stay visible on dark surfaces. Text labels still carry the
/// meaning, so users do not have to distinguish colors alone.
Color statusAccent(PondStatus status, {required bool darkMode}) {
  if (!darkMode) return styleFor(status).color;
  return switch (status) {
    PondStatus.healthy => const Color(0xFF58D6A0),
    PondStatus.warning => const Color(0xFFFFC56E),
    PondStatus.critical => const Color(0xFFFF7D8A),
  };
}

// The bands come from Thresholds.current: the admins' saved values, or the
// reference defaults in thresholds.dart until they save their own.
PondStatus phStatus(double ph) => Thresholds.current.ph.statusOf(ph);

PondStatus temperatureStatus(double celsius) => Thresholds.current.temperature.statusOf(celsius);

PondStatus dissolvedOxygenStatus(double milligramsPerLiter) =>
    Thresholds.current.dissolvedOxygen.statusOf(milligramsPerLiter);

PondStatus ammoniaStatus(double milligramsPerLiter) => Thresholds.current.ammonia.statusOf(milligramsPerLiter);

// Battery thresholds aren't water-quality-derived like the others — this is
// the device's own power level (solar + LiFePO4), shown separately from pond
// health rather than folded into worstOf(), since a low battery means "the
// monitor might stop reporting soon," not "the water is unsafe."
PondStatus batteryStatus(int percent) {
  if (percent > 40) return PondStatus.healthy;
  if (percent > 15) return PondStatus.warning;
  return PondStatus.critical;
}

PondStatus worstOf(List<PondStatus> statuses) {
  if (statuses.contains(PondStatus.critical)) return PondStatus.critical;
  if (statuses.contains(PondStatus.warning)) return PondStatus.warning;
  return PondStatus.healthy;
}
