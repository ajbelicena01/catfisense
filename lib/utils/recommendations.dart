import 'package:flutter/material.dart';

import 'pond_status.dart';

/// Expert-style corrective guidance shown on the Recommendations page when a
/// sensor reading drifts into the warning/critical range. Wording is a
/// reasonable placeholder based on general catfish-pond husbandry practice —
/// swap in the exact corrective actions from your aquaculture specialist
/// once that reference list is finalized (see the disclaimer in
/// pond_status.dart for the matching threshold caveat).
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

List<ParameterRecommendation> buildRecommendations({
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
        parameter: 'pH Level',
        value: ph.toStringAsFixed(1),
        icon: Icons.science_outlined,
        status: phStat,
        actions: _phActions(ph, phStat),
      ),
    if (tempStat != PondStatus.healthy)
      ParameterRecommendation(
        parameter: 'Temperature',
        value: '${temperature.toStringAsFixed(0)}°C',
        icon: Icons.thermostat_outlined,
        status: tempStat,
        actions: _temperatureActions(temperature, tempStat),
      ),
    if (doStat != PondStatus.healthy)
      ParameterRecommendation(
        parameter: 'Dissolved Oxygen',
        value: '${dissolvedOxygen.toStringAsFixed(1)} mg/L',
        icon: Icons.bubble_chart_outlined,
        status: doStat,
        actions: _doActions(doStat),
      ),
    if (ammoniaStat != PondStatus.healthy)
      ParameterRecommendation(
        parameter: 'Ammonia',
        value: '${ammonia.toStringAsFixed(2)} mg/L',
        icon: Icons.warning_amber_outlined,
        status: ammoniaStat,
        actions: _ammoniaActions(ammoniaStat),
      ),
  ];

  const severityOrder = {PondStatus.critical: 0, PondStatus.warning: 1, PondStatus.healthy: 2};
  recommendations.sort((a, b) => severityOrder[a.status]!.compareTo(severityOrder[b.status]!));
  return recommendations;
}

List<String> _phActions(double ph, PondStatus status) {
  final critical = status == PondStatus.critical;
  if (ph < 6.5) {
    return critical
        ? const [
            'Apply agricultural lime immediately to raise pH and stop feeding until levels recover.',
            'Increase water exchange to dilute acidity.',
            'Re-test pH after 2-3 hours, then again the next morning.',
          ]
        : const [
            'Add agricultural lime in small doses and recheck after a few hours.',
            'Avoid adding more feed than the fish can finish in 15-20 minutes.',
          ];
  }
  return critical
      ? const [
          'Perform a partial water change immediately to bring pH back down.',
          'Hold off on liming, fertilizing, or feeding until pH stabilizes.',
          'Re-test pH after 2-3 hours, then again the next morning.',
        ]
      : const [
          'Partially replace pond water with fresh water to ease pH back into range.',
          'Avoid liming or fertilizing the pond until the next reading.',
        ];
}

List<String> _temperatureActions(double celsius, PondStatus status) {
  final critical = status == PondStatus.critical;
  if (celsius < 25) {
    return critical
        ? const [
            'Shield the pond from cold wind and avoid handling fish until the water warms up.',
            'Reduce or pause feeding — digestion slows sharply in cold water.',
          ]
        : const [
            'Reduce feeding frequency slightly while the water stays cool.',
            'Watch for sluggish feeding behavior, an early sign of cold stress.',
          ];
  }
  return critical
      ? const [
          'Increase aeration immediately and add cooler water if available.',
          'Stop feeding until temperature drops back into range.',
        ]
      : const [
          'Increase aeration and consider shading part of the pond.',
          'Feed during cooler hours — early morning or late afternoon.',
        ];
}

List<String> _doActions(PondStatus status) {
  final critical = status == PondStatus.critical;
  return critical
      ? const [
          'Run aerators or paddle the surface immediately — fish are at risk of suffocation.',
          'Stop feeding until oxygen levels recover.',
          'Check for algae die-off or overcrowding as a likely cause.',
        ]
      : const [
          'Turn on aeration, especially in the early morning when DO is lowest.',
          'Reduce feeding slightly to limit oxygen demand from waste breakdown.',
        ];
}

List<String> _ammoniaActions(PondStatus status) {
  final critical = status == PondStatus.critical;
  return critical
      ? const [
          'Perform an immediate partial water change to dilute ammonia.',
          'Stop feeding and remove any leftover feed or decaying matter.',
          'Re-test after the water change and hold off on restocking until levels drop.',
        ]
      : const [
          'Reduce the feeding amount and remove uneaten feed promptly.',
          'Check for overfeeding or waste buildup at the pond bottom.',
        ];
}

/// Always-shown good-practice reminders, independent of the current readings.
const generalPondCareTips = [
  'Test water quality at the same time each day so trends stay comparable.',
  'Keep a feeding log — overfeeding is the most common cause of ammonia spikes.',
  'Clean and recalibrate sensors regularly to keep readings trustworthy.',
  'Aerate before sunrise, when dissolved oxygen naturally dips lowest.',
];
