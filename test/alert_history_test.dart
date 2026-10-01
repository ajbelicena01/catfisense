import 'package:catfisense/utils/alert_history.dart';
import 'package:catfisense/utils/pond_status.dart';
import 'package:catfisense/utils/sensor_history.dart';
import 'package:flutter_test/flutter_test.dart';

final _t0 = DateTime(2026, 9, 30, 8);

SensorHistoryPoint _point(int minute, {double ph = 7.2, double temp = 28, double oxygen = 6, double ammonia = 0.01}) =>
    SensorHistoryPoint(
      time: _t0.add(Duration(minutes: minute)),
      ph: ph,
      temperature: temp,
      ammonia: ammonia,
      dissolvedOxygen: oxygen,
      phi: 2,
    );

void main() {
  test('a healthy pond has no alerts', () {
    expect(detectAlerts([_point(0), _point(1), _point(2)], now: _t0), isEmpty);
  });

  test('one continuous bad stretch is one alert with its worst status and extreme values', () {
    final events = detectAlerts([
      _point(0),
      _point(1, oxygen: 4.5),
      _point(2, oxygen: 2.5, ammonia: 0.03),
      _point(3, oxygen: 4),
      _point(4),
    ], now: _t0.add(const Duration(hours: 1)));

    expect(events, hasLength(1));
    final event = events.single;
    expect(event.start, _t0.add(const Duration(minutes: 1)));
    expect(event.end, _t0.add(const Duration(minutes: 3)));
    expect(event.worst, PondStatus.critical);
    expect(event.ongoing, isFalse);
    final oxygen = event.issues.firstWhere((issue) => issue.issue == AlertIssue.lowOxygen);
    expect(oxygen.worst, PondStatus.critical);
    expect(oxygen.extremeValue, 2.5);
    final ammonia = event.issues.firstWhere((issue) => issue.issue == AlertIssue.highAmmonia);
    expect(ammonia.worst, PondStatus.warning);
    expect(ammonia.extremeValue, 0.03);
    // Worst issue first.
    expect(event.issues.first.issue, AlertIssue.lowOxygen);
  });

  test('high and low readings are told apart', () {
    final events = detectAlerts([_point(0, ph: 9.5, temp: 22)], now: _t0.add(const Duration(hours: 1)));
    expect(events.single.issues.map((issue) => issue.issue), containsAll([AlertIssue.highPh, AlertIssue.lowTemperature]));
  });

  test('a healthy reading or a long gap splits alerts; newest comes first', () {
    final events = detectAlerts([
      _point(0, oxygen: 4),
      _point(1),
      _point(2, oxygen: 4),
      _point(30, oxygen: 4), // sensor was off for 28 minutes in between
    ], now: _t0.add(const Duration(hours: 1)));
    expect(events, hasLength(3));
    expect(events.first.start, _t0.add(const Duration(minutes: 30)));
  });

  test('an alert still going at the newest, recent reading is ongoing', () {
    final events = detectAlerts([_point(0), _point(1, ammonia: 0.1)], now: _t0.add(const Duration(minutes: 2)));
    expect(events.single.ongoing, isTrue);
    expect(detectAlerts([_point(1, ammonia: 0.1)], now: _t0.add(const Duration(hours: 2))).single.ongoing, isFalse);
  });
}
