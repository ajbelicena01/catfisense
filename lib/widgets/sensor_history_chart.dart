import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/sensor_history.dart';

const phColor = Color(0xFF9C27B0);
const temperatureColor = Color(0xFF009688);
const ammoniaColor = Color(0xFFFF5722);
const doColor = Color(0xFFFFB300);
const phiColor = Color(0xFF03A9F4);

enum SensorMetric {
  ph('pH', 'pH', phColor, 1, 0, 14, 2),
  temperature('Temperature (°C)', 'Temperature (°C)', temperatureColor, 1, 0, 40, 10),
  ammonia('Ammonia (NH₃)', 'Ammonia (mg/L)', ammoniaColor, 2, 0, 2, 0.5),
  dissolvedOxygen('Dissolved Oxygen (DO)', 'Dissolved Oxygen (mg/L)', doColor, 1, 0, 15, 5);

  const SensorMetric(
    this.title,
    this.axisTitle,
    this.color,
    this.decimals,
    this.minY,
    this.maxY,
    this.interval,
  );

  final String title;
  final String axisTitle;
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
  });

  final List<SensorHistoryPoint> points;
  final HistoryRange range;
  final SensorMetric metric;

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
            'No readings within the displayed range.',
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
                metric.axisTitle,
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
              axisNameWidget: Text('Time', style: TextStyle(fontSize: 11, color: axisColor)),
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
                      chartPoints[index].label(range),
                      style: TextStyle(fontSize: 10, color: axisColor),
                    ),
                  );
                },
              ),
            ),
          ),
          lineTouchData: const LineTouchData(enabled: false),
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
