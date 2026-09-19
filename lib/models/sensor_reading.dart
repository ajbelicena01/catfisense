/// A single pH/temperature/dissolved-oxygen/ammonia reading, as written to
/// the Realtime Database by the ESP32 (or, until that's wired up, by the
/// Dashboard's "simulate" button) under `readings/<uid>/<epochMillis>`.
class SensorReading {
  const SensorReading({
    required this.ph,
    required this.temperature,
    required this.dissolvedOxygen,
    required this.ammonia,
    required this.recordedAt,
    this.batteryPercent,
  });

  final double ph;
  final double temperature;
  final double dissolvedOxygen;
  final double ammonia;
  final int? batteryPercent;
  final DateTime recordedAt;

  factory SensorReading.fromMap(Map<dynamic, dynamic> map) {
    return SensorReading(
      ph: (map['ph'] as num).toDouble(),
      temperature: (map['temperature'] as num).toDouble(),
      dissolvedOxygen: (map['dissolvedOxygen'] as num).toDouble(),
      ammonia: (map['ammonia'] as num).toDouble(),
      batteryPercent: (map['batteryPercent'] as num?)?.toInt(),
      recordedAt: DateTime.fromMillisecondsSinceEpoch((map['recordedAt'] as num).toInt()),
    );
  }
}
