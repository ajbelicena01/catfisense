/// Computes the 0-4 diverging Pond Health Index used by the History charts,
/// from raw readings — the Realtime Database only stores raw sensor values,
/// not a precomputed index.
///
/// Placeholder formula, same caveat as the thresholds in pond_status.dart:
/// the boundary numbers (and the choice to take the single worst-deviating
/// parameter rather than averaging) aren't yet confirmed against real
/// aquaculture-specialist guidance. Taking the worst parameter — rather than
/// averaging all four — is deliberate: it keeps this chart consistent with
/// the dashboard's worstOf() status, so one critical parameter can't get
/// diluted into looking like a "warning" here while the dashboard says
/// "critical" for the same moment.
double computePhi({
  required double ph,
  required double temperature,
  required double dissolvedOxygen,
  required double ammonia,
}) {
  final scores = [
    _diverging(value: ph, criticalLow: 5.0, warningLow: 6.0, healthyLow: 6.5, healthyHigh: 8.5, warningHigh: 9.0, criticalHigh: 10.0),
    _diverging(value: temperature, criticalLow: 15, warningLow: 20, healthyLow: 25, healthyHigh: 30, warningHigh: 33, criticalHigh: 38),
    _lowIsBad(value: dissolvedOxygen, criticalMin: 1.0, warningMin: 3.0, healthyMin: 5.0),
    _highIsBad(value: ammonia, healthyMax: 0.02, warningMax: 0.05, criticalMax: 0.08),
  ];
  return scores.reduce((a, b) => (a - 2).abs() >= (b - 2).abs() ? a : b);
}

double _lerp(double value, double fromX, double toX, double fromY, double toY) {
  final t = (value - fromX) / (toX - fromX);
  return fromY + t * (toY - fromY);
}

/// For parameters where both too-low and too-high are unhealthy (pH, temperature).
double _diverging({
  required double value,
  required double criticalLow,
  required double warningLow,
  required double healthyLow,
  required double healthyHigh,
  required double warningHigh,
  required double criticalHigh,
}) {
  if (value <= criticalLow) return 0;
  if (value <= warningLow) return _lerp(value, criticalLow, warningLow, 0, 1);
  if (value <= healthyLow) return _lerp(value, warningLow, healthyLow, 1, 2);
  if (value <= healthyHigh) return 2;
  if (value <= warningHigh) return _lerp(value, healthyHigh, warningHigh, 2, 3);
  if (value <= criticalHigh) return _lerp(value, warningHigh, criticalHigh, 3, 4);
  return 4;
}

/// For parameters where only LOW values are unhealthy (dissolved oxygen).
double _lowIsBad({required double value, required double criticalMin, required double warningMin, required double healthyMin}) {
  if (value >= healthyMin) return 2;
  if (value >= warningMin) return _lerp(value, warningMin, healthyMin, 1, 2);
  if (value >= criticalMin) return _lerp(value, criticalMin, warningMin, 0, 1);
  return 0;
}

/// For parameters where only HIGH values are unhealthy (ammonia).
double _highIsBad({required double value, required double healthyMax, required double warningMax, required double criticalMax}) {
  if (value <= healthyMax) return 2;
  if (value <= warningMax) return _lerp(value, healthyMax, warningMax, 2, 1);
  if (value <= criticalMax) return _lerp(value, warningMax, criticalMax, 1, 0);
  return 0;
}
