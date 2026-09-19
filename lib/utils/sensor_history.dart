import 'package:flutter/material.dart' show DateTimeRange;

import '../models/sensor_reading.dart';
import '../services/sensor_repository.dart';
import 'phi.dart';

enum HistoryRange { daily, weekly, monthly, custom }

class SensorHistoryPoint {
  const SensorHistoryPoint({
    required this.time,
    required this.ph,
    required this.temperature,
    required this.ammonia,
    required this.dissolvedOxygen,
    required this.phi,
  });

  final DateTime time;
  final double ph;
  final double temperature;
  final double ammonia;
  final double dissolvedOxygen;

  /// 0-4 scale: 0/4 = critical (low/high), 1/3 = warning (low/high), 2 = healthy center.
  final double phi;

  factory SensorHistoryPoint.fromReading(SensorReading reading) {
    return SensorHistoryPoint(
      time: reading.recordedAt,
      ph: reading.ph,
      temperature: reading.temperature,
      ammonia: reading.ammonia,
      dissolvedOxygen: reading.dissolvedOxygen,
      phi: computePhi(
        ph: reading.ph,
        temperature: reading.temperature,
        dissolvedOxygen: reading.dissolvedOxygen,
        ammonia: reading.ammonia,
      ),
    );
  }

  String label(HistoryRange range) {
    switch (range) {
      case HistoryRange.daily:
        final hour12 = time.hour % 12 == 0 ? 12 : time.hour % 12;
        final period = time.hour >= 12 ? 'PM' : 'AM';
        return '$hour12$period';
      case HistoryRange.weekly:
        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        return days[time.weekday - 1];
      case HistoryRange.monthly:
      case HistoryRange.custom:
        return '${time.month}/${time.day}';
    }
  }
}

(DateTime start, DateTime end) _windowFor(HistoryRange range, {DateTimeRange? customRange}) {
  final now = DateTime.now();
  switch (range) {
    case HistoryRange.daily:
      return (now.subtract(const Duration(hours: 24)), now);
    case HistoryRange.weekly:
      return (now.subtract(const Duration(days: 7)), now);
    case HistoryRange.monthly:
      return (now.subtract(const Duration(days: 30)), now);
    case HistoryRange.custom:
      final picked = customRange!;
      return (picked.start, picked.end.add(const Duration(days: 1)));
  }
}

/// Live history for the given range, sourced from the Realtime Database.
Stream<List<SensorHistoryPoint>> watchHistory(
  HistoryRange range, {
  DateTimeRange? customRange,
  SensorRepository? repository,
}) {
  final (start, end) = _windowFor(range, customRange: customRange);
  return (repository ?? SensorRepository())
      .history(start: start, end: end)
      .map((readings) => readings.map(SensorHistoryPoint.fromReading).toList());
}
