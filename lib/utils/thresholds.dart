import 'pond_status.dart';

/// One water parameter's bands. A null bound means "no limit on that side"
/// (dissolved oxygen has no upper limit, ammonia no lower one).
class ParamRange {
  const ParamRange({this.healthyMin, this.healthyMax, this.warningMin, this.warningMax});

  factory ParamRange.fromMap(Map<dynamic, dynamic> map) {
    double? read(String key) => (map[key] as num?)?.toDouble();
    return ParamRange(
      healthyMin: read('healthyMin'),
      healthyMax: read('healthyMax'),
      warningMin: read('warningMin'),
      warningMax: read('warningMax'),
    );
  }

  final double? healthyMin;
  final double? healthyMax;
  final double? warningMin;
  final double? warningMax;

  PondStatus statusOf(double value) {
    bool within(double? min, double? max) => (min == null || value >= min) && (max == null || value <= max);
    if (within(healthyMin, healthyMax)) return PondStatus.healthy;
    if (within(warningMin, warningMax)) return PondStatus.warning;
    return PondStatus.critical;
  }

  /// Splits "too low" from "too high" for parameters bounded on both sides.
  double? get middle => healthyMin != null && healthyMax != null ? (healthyMin! + healthyMax!) / 2 : null;

  /// Whether the bands are in order: warning outside healthy, min below max.
  bool get isValid {
    bool ordered(double? low, double? high) => low == null || high == null || low <= high;
    return ordered(warningMin, healthyMin) &&
        ordered(healthyMin, healthyMax) &&
        ordered(healthyMax, warningMax) &&
        (healthyMin == null || healthyMax == null || healthyMin! < healthyMax!);
  }

  Map<String, double> toMap() => {
    'healthyMin': ?healthyMin,
    'healthyMax': ?healthyMax,
    'warningMin': ?warningMin,
    'warningMax': ?warningMax,
  };

  @override
  bool operator ==(Object other) =>
      other is ParamRange &&
      other.healthyMin == healthyMin &&
      other.healthyMax == healthyMax &&
      other.warningMin == warningMin &&
      other.warningMax == warningMax;

  @override
  int get hashCode => Object.hash(healthyMin, healthyMax, warningMin, warningMax);
}

/// The pond-health bands for every parameter. Admins edit them at
/// `config/thresholds`; everything that judges a reading goes through
/// [Thresholds.current] (see pond_status.dart), which the app keeps in sync.
class Thresholds {
  const Thresholds({required this.ph, required this.temperature, required this.dissolvedOxygen, required this.ammonia});

  /// Reference ranges only — general aquaculture guidance for catfish, used
  /// until an admin saves project-specific values.
  static const defaults = Thresholds(
    ph: ParamRange(healthyMin: 6.5, healthyMax: 8.5, warningMin: 6.0, warningMax: 9.0),
    temperature: ParamRange(healthyMin: 25, healthyMax: 30, warningMin: 20, warningMax: 33),
    dissolvedOxygen: ParamRange(healthyMin: 5, warningMin: 3),
    ammonia: ParamRange(healthyMax: 0.02, warningMax: 0.05),
  );

  static Thresholds current = defaults;

  /// Missing or unreadable parameters fall back to their defaults.
  factory Thresholds.fromMap(Object? value) {
    if (value is! Map) return defaults;
    ParamRange read(String key, ParamRange fallback) {
      final map = value[key];
      if (map is! Map) return fallback;
      final range = ParamRange.fromMap(map);
      return range.isValid ? range : fallback;
    }

    return Thresholds(
      ph: read('ph', defaults.ph),
      temperature: read('temperature', defaults.temperature),
      dissolvedOxygen: read('dissolvedOxygen', defaults.dissolvedOxygen),
      ammonia: read('ammonia', defaults.ammonia),
    );
  }

  final ParamRange ph;
  final ParamRange temperature;
  final ParamRange dissolvedOxygen;
  final ParamRange ammonia;

  bool get isValid => ph.isValid && temperature.isValid && dissolvedOxygen.isValid && ammonia.isValid;

  Map<String, Map<String, double>> toMap() => {
    'ph': ph.toMap(),
    'temperature': temperature.toMap(),
    'dissolvedOxygen': dissolvedOxygen.toMap(),
    'ammonia': ammonia.toMap(),
  };

  @override
  bool operator ==(Object other) =>
      other is Thresholds &&
      other.ph == ph &&
      other.temperature == temperature &&
      other.dissolvedOxygen == dissolvedOxygen &&
      other.ammonia == ammonia;

  @override
  int get hashCode => Object.hash(ph, temperature, dissolvedOxygen, ammonia);
}

/// "6.5–8.5", "at least 5", "at most 0.02" style text for a healthy band, in
/// plain ASCII when [ascii] (for the PDF's Latin-1 font).
String healthyRangeText(ParamRange range, {String unit = '', bool ascii = false}) {
  String n(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();
  final suffix = unit.isEmpty ? '' : ' $unit';
  final (low, high) = (range.healthyMin, range.healthyMax);
  if (low != null && high != null) return '${n(low)}${ascii ? ' - ' : '–'}${n(high)}$suffix';
  if (low != null) return '${ascii ? '>= ' : '≥ '}${n(low)}$suffix';
  if (high != null) return '${ascii ? '<= ' : '≤ '}${n(high)}$suffix';
  return '-';
}
