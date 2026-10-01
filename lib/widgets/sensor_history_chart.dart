import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../theme/app_theme.dart';
import '../utils/sensor_history.dart';

const phColor = Color(0xFF9C27B0);
const temperatureColor = Color(0xFF009688);
const ammoniaColor = Color(0xFFFF5722);
const doColor = Color(0xFFFFB300);
const phiColor = Color(0xFF03A9F4);

enum SensorMetric {
  ph(phColor, 1, 0, 14, 2),
  temperature(temperatureColor, 1, 0, 40, 10),
  ammonia(ammoniaColor, 2, 0, 2, 0.5),
  dissolvedOxygen(doColor, 1, 0, 15, 5);

  const SensorMetric(
    this.color,
    this.decimals,
    this.minY,
    this.maxY,
    this.interval,
  );

  String title(AppLocalizations l10n) => switch (this) {
    SensorMetric.ph => 'pH',
    SensorMetric.temperature => l10n.chartTemperature,
    SensorMetric.ammonia => l10n.chartAmmoniaTitle,
    SensorMetric.dissolvedOxygen => l10n.chartOxygenTitle,
  };

  String axisTitle(AppLocalizations l10n) => switch (this) {
    SensorMetric.ph => 'pH',
    SensorMetric.temperature => l10n.chartTemperature,
    SensorMetric.ammonia => l10n.chartAmmoniaAxis,
    SensorMetric.dissolvedOxygen => l10n.chartOxygenAxis,
  };
  final Color color;
  final int decimals;
  final double minY;
  final double maxY;
  final double interval;

  double value(SensorHistoryPoint point) => switch (this) {
    SensorMetric.ph => point.ph,
    SensorMetric.temperature => point.temperature,
    SensorMetric.dissolvedOxygen => point.dissolvedOxygen,
    SensorMetric.ammonia => point.ammonia,
  };

  bool contains(SensorHistoryPoint point) {
    final reading = value(point);
    return reading >= minY && reading <= maxY;
  }

}

/// A single water parameter on its own numeric scale.
class SensorHistoryChart extends StatelessWidget {
  const SensorHistoryChart({
    super.key,
    required this.points,
    required this.range,
    required this.metric,
    this.markers = const [],
  });

  final List<SensorHistoryPoint> points;
  final HistoryRange range;
  final SensorMetric metric;

  /// Times drawn as dashed vertical lines (logbook entries).
  final List<DateTime> markers;

  /// The x position of [time]: the first plotted reading at or after it, or
  /// null when it falls outside the plotted readings. The x axis counts
  /// readings rather than time, so a marker sits on the reading it precedes.
  static double? _markerX(List<SensorHistoryPoint> chartPoints, DateTime time) {
    if (time.isBefore(chartPoints.first.time) || time.isAfter(chartPoints.last.time)) return null;
    var low = 0;
    var high = chartPoints.length - 1;
    while (low < high) {
      final mid = (low + high) ~/ 2;
      if (chartPoints[mid].time.isBefore(time)) {
        low = mid + 1;
      } else {
        high = mid;
      }
    }
    return low.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final axisColor = palette.textSecondary;
    final chartPoints = points.where(metric.contains).toList();
    if (chartPoints.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Text(
            context.l10n.chartNoReadingsInRange,
            style: TextStyle(fontSize: 13, color: palette.textSecondary),
          ),
        ),
      );
    }
    final values = chartPoints.map(metric.value).toList();
    final labelStep = (chartPoints.length / 6).ceil().clamp(1, chartPoints.length);

    return AspectRatio(
      aspectRatio: 1.65,
      child: LineChart(
        LineChartData(
          minY: metric.minY,
          maxY: metric.maxY,
          gridData: FlGridData(
            drawVerticalLine: false,
            horizontalInterval: metric.interval,
          ),
          borderData: FlBorderData(
            show: true,
            border: Border(
              bottom: BorderSide(color: axisColor),
              left: BorderSide(color: axisColor),
            ),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              // Keep the title within fl_chart's 16px default title slot.
              // Extra vertical padding here was causing descenders (p, y, g)
              // to be clipped after the left title was rotated.
              axisNameWidget: Text(
                metric.axisTitle(context.l10n),
                style: TextStyle(fontSize: 11, color: axisColor, height: 1),
              ),
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 48,
                interval: metric.interval,
                getTitlesWidget: (value, meta) => Text(
                  value.toStringAsFixed(metric.decimals),
                  style: TextStyle(fontSize: 10, color: axisColor),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              axisNameWidget: Text(context.l10n.chartTime, style: TextStyle(fontSize: 11, color: axisColor)),
              sideTitles: SideTitles(
                showTitles: true,
                interval: labelStep.toDouble(),
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= chartPoints.length || index % labelStep != 0) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      chartPoints[index].label(range, context.l10n.localeName),
                      style: TextStyle(fontSize: 10, color: axisColor),
                    ),
                  );
                },
              ),
            ),
          ),
          lineTouchData: const LineTouchData(enabled: false),
          extraLinesData: ExtraLinesData(
            verticalLines: [
              for (final marker in markers)
                if (_markerX(chartPoints, marker) case final x?)
                  VerticalLine(
                    x: x,
                    color: axisColor.withValues(alpha: 0.7),
                    strokeWidth: 1.2,
                    dashArray: const [4, 4],
                  ),
            ],
          ),
          lineBarsData: [
            LineChartBarData(
              spots: [
                for (var index = 0; index < chartPoints.length; index++)
                  FlSpot(index.toDouble(), values[index]),
              ],
              isCurved: true,
              color: metric.color,
              barWidth: 2.5,
              dotData: const FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}
