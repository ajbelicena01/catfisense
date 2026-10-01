/// One stored reading, as far as device health is concerned: when the ESP32
/// sent it (its NTP clock, which is also the reading's key) and when
/// Firebase stored it (`recordedAt`, the server's clock).
class UploadSample {
  const UploadSample({required this.sentAt, required this.storedAt, this.batteryPercent});

  final DateTime sentAt;
  final DateTime storedAt;
  final int? batteryPercent;

  /// How long the reading took to reach Firebase. Can be slightly negative
  /// when the ESP32's clock runs a little ahead of Google's.
  Duration get delay => storedAt.difference(sentAt);
}

class DataGap {
  const DataGap({required this.from, required this.to});

  final DateTime from;
  final DateTime to;
  Duration get length => to.difference(from);
}

/// The ESP32 firmware sends one reading every 5 seconds.
const sensorSendInterval = Duration(seconds: 5);

/// Same limit as the Dashboard's sensor-offline banner.
const deviceOfflineAfter = Duration(minutes: 2);

class DeviceHealth {
  const DeviceHealth({
    required this.lastSeen,
    required this.online,
    required this.latestDelay,
    required this.averageDelay,
    required this.maxDelay,
    required this.readingsLast10Minutes,
    required this.gaps,
    required this.batteryPercent,
    required this.delaySeries,
  });

  final DateTime? lastSeen;
  final bool online;
  final Duration? latestDelay;

  /// Over the last hour of readings (or the newest 100, if the device was
  /// off for the past hour).
  final Duration? averageDelay;
  final Duration? maxDelay;
  final int readingsLast10Minutes;

  /// Silences longer than [deviceOfflineAfter], newest first.
  final List<DataGap> gaps;
  final int? batteryPercent;

  /// The newest delays, oldest first, for the chart.
  final List<UploadSample> delaySeries;

  static int get expectedPer10Minutes => const Duration(minutes: 10).inSeconds ~/ sensorSendInterval.inSeconds;
}

/// [samples] oldest first.
DeviceHealth computeDeviceHealth(List<UploadSample> samples, DateTime now) {
  if (samples.isEmpty) {
    return const DeviceHealth(
      lastSeen: null,
      online: false,
      latestDelay: null,
      averageDelay: null,
      maxDelay: null,
      readingsLast10Minutes: 0,
      gaps: [],
      batteryPercent: null,
      delaySeries: [],
    );
  }
  final last = samples.last;
  var recent = samples.where((s) => now.difference(s.storedAt) <= const Duration(hours: 1)).toList();
  if (recent.isEmpty) recent = samples.sublist(samples.length > 100 ? samples.length - 100 : 0);
  final delays = recent.map((s) => s.delay.inMilliseconds).toList();

  final gaps = <DataGap>[];
  for (var i = 1; i < samples.length; i++) {
    final gap = DataGap(from: samples[i - 1].storedAt, to: samples[i].storedAt);
    if (gap.length > deviceOfflineAfter) gaps.add(gap);
  }
  // An ongoing silence counts too.
  if (now.difference(last.storedAt) > deviceOfflineAfter) gaps.add(DataGap(from: last.storedAt, to: now));

  return DeviceHealth(
    lastSeen: last.storedAt,
    online: now.difference(last.storedAt) <= deviceOfflineAfter,
    latestDelay: last.delay,
    averageDelay: Duration(milliseconds: delays.reduce((a, b) => a + b) ~/ delays.length),
    maxDelay: Duration(milliseconds: delays.reduce((a, b) => a > b ? a : b)),
    readingsLast10Minutes: samples.where((s) => now.difference(s.storedAt) <= const Duration(minutes: 10)).length,
    gaps: gaps.reversed.toList(),
    batteryPercent: samples.lastWhere((s) => s.batteryPercent != null, orElse: () => last).batteryPercent,
    delaySeries: samples.sublist(samples.length > 60 ? samples.length - 60 : 0),
  );
}
