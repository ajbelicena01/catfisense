import 'package:flutter/material.dart' show DateTimeRange;
import 'package:intl/intl.dart';

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

  /// The chart's x-axis label for this point, in [locale]: "7 AM", "Mon", or "9/30".
  String label(HistoryRange range, String locale) => switch (range) {
    HistoryRange.daily => DateFormat.j(locale).format(time),
    HistoryRange.weekly => DateFormat.E(locale).format(time),
    HistoryRange.monthly || HistoryRange.custom => DateFormat.Md(locale).format(time),
  };
}

/// The start and end time a history range covers.
(DateTime start, DateTime end) historyWindow(HistoryRange range, {DateTimeRange? customRange}) {
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
  final (start, end) = historyWindow(range, customRange: customRange);
  return (repository ?? SensorRepository())
      .history(start: start, end: end)
      .map((readings) => readings.map(SensorHistoryPoint.fromReading).toList());
}
