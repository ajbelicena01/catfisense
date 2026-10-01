import 'package:catfisense/utils/device_health.dart';
import 'package:flutter_test/flutter_test.dart';

final _now = DateTime(2026, 9, 30, 12);

UploadSample _sample(Duration beforeNow, {int delayMs = 400, int? battery}) {
  final stored = _now.subtract(beforeNow);
  return UploadSample(
    sentAt: stored.subtract(Duration(milliseconds: delayMs)),
    storedAt: stored,
    batteryPercent: battery,
  );
}

void main() {
  test('no readings: offline with nothing measured', () {
    final health = computeDeviceHealth(const [], _now);
    expect(health.online, isFalse);
    expect(health.lastSeen, isNull);
    expect(health.readingsLast10Minutes, 0);
  });

  test('a device sending every 5 s is online with the expected counts and delays', () {
    final samples = [
      for (var s = 600; s >= 5; s -= 5) _sample(Duration(seconds: s), delayMs: s == 5 ? 900 : 400, battery: 87),
    ];
    final health = computeDeviceHealth(samples, _now);
    expect(health.online, isTrue);
    expect(health.readingsLast10Minutes, 120);
    expect(DeviceHealth.expectedPer10Minutes, 120);
    expect(health.latestDelay, const Duration(milliseconds: 900));
    expect(health.maxDelay, const Duration(milliseconds: 900));
    expect(health.averageDelay!.inMilliseconds, inInclusiveRange(400, 410));
    expect(health.gaps, isEmpty);
    expect(health.batteryPercent, 87);
    expect(health.delaySeries, hasLength(60));
  });

  test('silences over 2 minutes are gaps, including an ongoing one, newest first', () {
    final samples = [
      _sample(const Duration(hours: 5)),
      _sample(const Duration(hours: 4)), // 1-hour gap before this
      _sample(const Duration(hours: 4) - const Duration(seconds: 5)),
    ];
    final health = computeDeviceHealth(samples, _now);
    expect(health.online, isFalse);
    expect(health.gaps, hasLength(2));
    expect(health.gaps.first.to, _now); // still silent now
    expect(health.gaps.last.length, const Duration(hours: 1));
    // Nothing in the last hour, so delay stats fall back to the newest readings.
    expect(health.averageDelay, const Duration(milliseconds: 400));
  });
}
