import 'package:flutter/material.dart';

enum PondStatus { healthy, warning, critical }

class PondStatusStyle {
  const PondStatusStyle({
    required this.label,
    required this.shortLabel,
    required this.color,
    required this.background,
    required this.dotColor,
    required this.icon,
  });

  final String label;
  final String shortLabel;
  final Color color;
  final Color background;
  final Color dotColor;
  final IconData icon;
}

const _statusStyles = {
  PondStatus.healthy: PondStatusStyle(
    label: 'Pond health is good.',
    shortLabel: 'Good',
    color: Color(0xFF087443),
    background: Color(0xFFC9FFE5),
    dotColor: Color(0xFF6BE5B3),
    icon: Icons.check_circle,
  ),
  PondStatus.warning: PondStatusStyle(
    label: 'Pond health warning.',
    shortLabel: 'Warning',
    color: Color(0xFF804800),
    background: Color(0xFFFFF0CC),
    dotColor: Color(0xFFFBD195),
    icon: Icons.warning_amber_rounded,
  ),
  PondStatus.critical: PondStatusStyle(
    label: 'Pond health is critical.',
    shortLabel: 'Critical',
    color: Color(0xFFB42335),
    background: Color(0xFFFFDBDB),
    dotColor: Color(0xFFFC98A1),
    icon: Icons.error,
  ),
};

PondStatusStyle styleFor(PondStatus status) => _statusStyles[status]!;

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

// Reference ranges only — general aquaculture guidance for catfish, not yet
// confirmed against your actual project research. Adjust these once you have
// real numbers.
PondStatus phStatus(double ph) {
  if (ph >= 6.5 && ph <= 8.5) return PondStatus.healthy;
  if (ph >= 6.0 && ph <= 9.0) return PondStatus.warning;
  return PondStatus.critical;
}

PondStatus temperatureStatus(double celsius) {
  if (celsius >= 25 && celsius <= 30) return PondStatus.healthy;
  if (celsius >= 20 && celsius <= 33) return PondStatus.warning;
  return PondStatus.critical;
}

PondStatus dissolvedOxygenStatus(double milligramsPerLiter) {
  if (milligramsPerLiter >= 5) return PondStatus.healthy;
  if (milligramsPerLiter >= 3) return PondStatus.warning;
  return PondStatus.critical;
}

PondStatus ammoniaStatus(double milligramsPerLiter) {
  if (milligramsPerLiter <= 0.02) return PondStatus.healthy;
  if (milligramsPerLiter <= 0.05) return PondStatus.warning;
  return PondStatus.critical;
}

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
