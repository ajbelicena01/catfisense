import 'pond_status.dart';
import 'sensor_history.dart';
import 'thresholds.dart';

/// Which water parameter went out of range, and in which direction.
enum AlertIssue { lowPh, highPh, lowTemperature, highTemperature, lowOxygen, highAmmonia }

extension AlertIssueInfo on AlertIssue {
  /// Whether the worst value is the highest one seen (else the lowest).
  bool get isHigh => this == AlertIssue.highPh || this == AlertIssue.highTemperature || this == AlertIssue.highAmmonia;
}

class AlertIssueSummary {
  const AlertIssueSummary({required this.issue, required this.worst, required this.extremeValue});

  final AlertIssue issue;
  final PondStatus worst;

  /// The lowest (for "low" issues) or highest value reached during the alert.
  final double extremeValue;
}

/// One stretch of time when the pond was not healthy.
class PondAlertEvent {
  const PondAlertEvent({
    required this.start,
    required this.end,
    required this.ongoing,
    required this.worst,
    required this.issues,
  });

  final DateTime start;

  /// The last unhealthy reading of the alert.
  final DateTime end;

  /// Still unhealthy as of the newest reading, and that reading is recent.
  final bool ongoing;
  final PondStatus worst;
  final List<AlertIssueSummary> issues;

  Duration get duration => end.difference(start);
}

/// Readings further apart than this split an alert in two: the sensor was
/// off in between, so nothing is known about that stretch.
const _maxGapWithinAlert = Duration(minutes: 10);

/// A reading this recent still counts as "now" for an ongoing alert.
const _ongoingWithin = Duration(minutes: 2);

/// Each out-of-range parameter of one reading, with its status and value.
Map<AlertIssue, (PondStatus, double)> _issuesOf(SensorHistoryPoint point) {
  final issues = <AlertIssue, (PondStatus, double)>{};
  void check(PondStatus status, AlertIssue low, AlertIssue high, double value, double middle) {
    if (status != PondStatus.healthy) issues[value > middle ? high : low] = (status, value);
  }

  // Midpoints of the healthy bands decide low vs high.
  final t = Thresholds.current;
  const d = Thresholds.defaults;
  check(phStatus(point.ph), AlertIssue.lowPh, AlertIssue.highPh, point.ph, t.ph.middle ?? d.ph.middle!);
  check(
    temperatureStatus(point.temperature),
    AlertIssue.lowTemperature,
    AlertIssue.highTemperature,
    point.temperature,
    t.temperature.middle ?? d.temperature.middle!,
  );
  final oxygen = dissolvedOxygenStatus(point.dissolvedOxygen);
  if (oxygen != PondStatus.healthy) issues[AlertIssue.lowOxygen] = (oxygen, point.dissolvedOxygen);
  final ammonia = ammoniaStatus(point.ammonia);
  if (ammonia != PondStatus.healthy) issues[AlertIssue.highAmmonia] = (ammonia, point.ammonia);
  return issues;
}

/// Groups oldest-first [points] into alert events, newest event first.
List<PondAlertEvent> detectAlerts(List<SensorHistoryPoint> points, {required DateTime now}) {
  final events = <PondAlertEvent>[];
  DateTime? start;
  DateTime? lastBad;
  final worstByIssue = <AlertIssue, (PondStatus, double)>{};

  void close({required bool ongoing}) {
    if (start == null) return;
    events.add(
      PondAlertEvent(
        start: start!,
        end: lastBad!,
        ongoing: ongoing,
        worst: worstOf([for (final entry in worstByIssue.values) entry.$1]),
        issues: [
          for (final MapEntry(key: issue, value: (status, value)) in worstByIssue.entries)
            AlertIssueSummary(issue: issue, worst: status, extremeValue: value),
        ]..sort((a, b) => b.worst.index.compareTo(a.worst.index)),
      ),
    );
    start = null;
    lastBad = null;
    worstByIssue.clear();
  }

  DateTime? previous;
  for (final point in points) {
    if (previous != null && point.time.difference(previous) > _maxGapWithinAlert) close(ongoing: false);
    previous = point.time;

    final issues = _issuesOf(point);
    if (issues.isEmpty) {
      close(ongoing: false);
      continue;
    }
    start ??= point.time;
    lastBad = point.time;
    for (final MapEntry(key: issue, value: (status, value)) in issues.entries) {
      final seen = worstByIssue[issue];
      final moreExtreme = seen == null || (issue.isHigh ? value > seen.$2 : value < seen.$2);
      worstByIssue[issue] = (
        seen == null || status.index > seen.$1.index ? status : seen.$1,
        moreExtreme ? value : seen.$2,
      );
    }
  }
  close(ongoing: lastBad != null && now.difference(lastBad!) <= _ongoingWithin);
  return events.reversed.toList();
}
