import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'pond_status.dart';
import 'thresholds.dart';

/// Expert-style corrective guidance shown on the Recommendations page when a
/// sensor reading drifts into the warning/critical range. Wording is a
/// reasonable placeholder based on general catfish-pond husbandry practice —
/// swap in the exact corrective actions from your aquaculture specialist
/// once that reference list is finalized (see the disclaimer in
/// pond_status.dart for the matching threshold caveat). The text itself lives
/// in lib/l10n/app_*.arb under the `rec*` keys.
class ParameterRecommendation {
  const ParameterRecommendation({
    required this.parameter,
    required this.value,
    required this.icon,
    required this.status,
    required this.actions,
  });

  final String parameter;
  final String value;
  final IconData icon;
  final PondStatus status;
  final List<String> actions;
}

List<ParameterRecommendation> buildRecommendations(
  AppLocalizations l10n, {
  required double ph,
  required double temperature,
  required double dissolvedOxygen,
  required double ammonia,
}) {
  final phStat = phStatus(ph);
  final tempStat = temperatureStatus(temperature);
  final doStat = dissolvedOxygenStatus(dissolvedOxygen);
  final ammoniaStat = ammoniaStatus(ammonia);

  final recommendations = <ParameterRecommendation>[
    if (phStat != PondStatus.healthy)
      ParameterRecommendation(
        parameter: l10n.cardPhLabel,
        value: ph.toStringAsFixed(1),
        icon: Icons.science_outlined,
        status: phStat,
        actions: _phActions(l10n, ph, phStat),
      ),
    if (tempStat != PondStatus.healthy)
      ParameterRecommendation(
        parameter: l10n.paramTemperature,
        value: '${temperature.toStringAsFixed(0)}°C',
        icon: Icons.thermostat_outlined,
        status: tempStat,
        actions: _temperatureActions(l10n, temperature, tempStat),
      ),
    if (doStat != PondStatus.healthy)
      ParameterRecommendation(
        parameter: l10n.paramOxygen,
        value: '${dissolvedOxygen.toStringAsFixed(1)} mg/L',
        icon: Icons.bubble_chart_outlined,
        status: doStat,
        actions: _doActions(l10n, doStat),
      ),
    if (ammoniaStat != PondStatus.healthy)
      ParameterRecommendation(
        parameter: l10n.paramAmmonia,
        value: '${ammonia.toStringAsFixed(2)} mg/L',
        icon: Icons.warning_amber_outlined,
        status: ammoniaStat,
        actions: _ammoniaActions(l10n, ammoniaStat),
      ),
  ];

  const severityOrder = {PondStatus.critical: 0, PondStatus.warning: 1, PondStatus.healthy: 2};
  recommendations.sort((a, b) => severityOrder[a.status]!.compareTo(severityOrder[b.status]!));
  return recommendations;
}

List<String> _phActions(AppLocalizations l10n, double ph, PondStatus status) {
  final critical = status == PondStatus.critical;
  if (ph < (Thresholds.current.ph.middle ?? Thresholds.defaults.ph.middle!)) {
    return critical
        ? [l10n.recPhLowCritical1, l10n.recPhLowCritical2, l10n.recRetestPh]
        : [l10n.recPhLowWarning1, l10n.recPhLowWarning2];
  }
  return critical
      ? [l10n.recPhHighCritical1, l10n.recPhHighCritical2, l10n.recRetestPh]
      : [l10n.recPhHighWarning1, l10n.recPhHighWarning2];
}

List<String> _temperatureActions(AppLocalizations l10n, double celsius, PondStatus status) {
  final critical = status == PondStatus.critical;
  if (celsius < (Thresholds.current.temperature.middle ?? Thresholds.defaults.temperature.middle!)) {
    return critical
        ? [l10n.recTempLowCritical1, l10n.recTempLowCritical2]
        : [l10n.recTempLowWarning1, l10n.recTempLowWarning2];
  }
  return critical
      ? [l10n.recTempHighCritical1, l10n.recTempHighCritical2]
      : [l10n.recTempHighWarning1, l10n.recTempHighWarning2];
}

List<String> _doActions(AppLocalizations l10n, PondStatus status) {
  return status == PondStatus.critical
      ? [l10n.recDoCritical1, l10n.recDoCritical2, l10n.recDoCritical3]
      : [l10n.recDoWarning1, l10n.recDoWarning2];
}

List<String> _ammoniaActions(AppLocalizations l10n, PondStatus status) {
  return status == PondStatus.critical
      ? [l10n.recAmmoniaCritical1, l10n.recAmmoniaCritical2, l10n.recAmmoniaCritical3]
      : [l10n.recAmmoniaWarning1, l10n.recAmmoniaWarning2];
}

/// Always-shown good-practice reminders, independent of the current readings.
List<String> generalPondCareTips(AppLocalizations l10n) => [
  l10n.recTip1,
  l10n.recTip2,
  l10n.recTip3,
  l10n.recTip4,
];
