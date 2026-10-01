import 'thresholds.dart';

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
///
/// The healthy and warning bands come from [Thresholds.current]; the point
/// where the index bottoms out (0 or 4) sits one more band-width beyond the
/// warning edge.
double computePhi({
  required double ph,
  required double temperature,
  required double dissolvedOxygen,
  required double ammonia,
}) {
  final t = Thresholds.current;
  const d = Thresholds.defaults;
  final scores = [
    _divergingFor(ph, t.ph, d.ph),
    _divergingFor(temperature, t.temperature, d.temperature),
    () {
      final healthy = t.dissolvedOxygen.healthyMin ?? d.dissolvedOxygen.healthyMin!;
      final warning = t.dissolvedOxygen.warningMin ?? d.dissolvedOxygen.warningMin!;
      return _lowIsBad(value: dissolvedOxygen, criticalMin: warning - (healthy - warning), warningMin: warning, healthyMin: healthy);
    }(),
    () {
      final healthy = t.ammonia.healthyMax ?? d.ammonia.healthyMax!;
      final warning = t.ammonia.warningMax ?? d.ammonia.warningMax!;
      return _highIsBad(value: ammonia, healthyMax: healthy, warningMax: warning, criticalMax: warning + (warning - healthy));
    }(),
  ];
  return scores.reduce((a, b) => (a - 2).abs() >= (b - 2).abs() ? a : b);
}

double _lerp(double value, double fromX, double toX, double fromY, double toY) {
  // Two band edges set to the same value leave no room to interpolate.
  if (toX == fromX) return toY;
  final t = (value - fromX) / (toX - fromX);
  return fromY + t * (toY - fromY);
}

double _divergingFor(double value, ParamRange range, ParamRange fallback) {
  final healthyLow = range.healthyMin ?? fallback.healthyMin!;
  final healthyHigh = range.healthyMax ?? fallback.healthyMax!;
  final warningLow = range.warningMin ?? fallback.warningMin!;
  final warningHigh = range.warningMax ?? fallback.warningMax!;
  return _diverging(
    value: value,
    criticalLow: warningLow - (healthyLow - warningLow),
    warningLow: warningLow,
    healthyLow: healthyLow,
    healthyHigh: healthyHigh,
    warningHigh: warningHigh,
    criticalHigh: warningHigh + (warningHigh - healthyHigh),
  );
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
