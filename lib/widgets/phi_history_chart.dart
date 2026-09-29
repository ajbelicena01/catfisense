import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/sensor_history.dart';
import 'sensor_history_chart.dart' show phiColor;

const _phiBandLabels = ['Critical', 'Warning', 'Healthy', 'Warning', 'Critical'];

/// The Overall PHI is plotted on a diverging 0-4 scale where 2 (Healthy) is
/// the center band, since the index can be unhealthy by being too high or
/// too low, not just low.
class PhiHistoryChart extends StatelessWidget {
  const PhiHistoryChart({super.key, required this.points, required this.range});

  final List<SensorHistoryPoint> points;
  final HistoryRange range;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final axisColor = palette.textSecondary;
    final chartPoints = points.where((point) =>
      point.ph >= 0 && point.ph <= 14 &&
      point.temperature >= 0 && point.temperature <= 40 &&
      point.ammonia >= 0 && point.ammonia <= 2 &&
      point.dissolvedOxygen >= 0 && point.dissolvedOxygen <= 15
    ).toList();
    if (chartPoints.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Text(
            'No readings within the displayed parameter ranges.',
            style: TextStyle(fontSize: 13, color: palette.textSecondary),
          ),
        ),
      );
    }
    final labelStep = (chartPoints.length / 6).ceil().clamp(1, chartPoints.length);

    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1.4,
          child: LineChart(
            LineChartData(
              minY: 0,
              maxY: 4,
              gridData: const FlGridData(drawVerticalLine: false, horizontalInterval: 1),
              borderData: FlBorderData(
                show: true,
                border: Border(bottom: BorderSide(color: axisColor), left: BorderSide(color: axisColor)),
              ),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 56,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      final i = value.toInt();
                      if (i < 0 || i > 4) return const SizedBox.shrink();
                      return Text(
                        _phiBandLabels[4 - i],
                        style: TextStyle(fontSize: 11, color: axisColor),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  axisNameWidget: Text('Time', style: TextStyle(fontSize: 12, color: axisColor)),
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: labelStep.toDouble(),
                    getTitlesWidget: (value, meta) {
                      final i = value.toInt();
                      if (i < 0 || i >= chartPoints.length || i % labelStep != 0) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          chartPoints[i].label(range),
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
                  spots: [for (var i = 0; i < chartPoints.length; i++) FlSpot(i.toDouble(), chartPoints[i].phi)],
                  isCurved: true,
                  color: phiColor,
                  barWidth: 2.5,
                  dotData: const FlDotData(show: false),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.circle, color: phiColor, size: 10),
            const SizedBox(width: 6),
            Text(
              'Overall PHI',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: palette.isDark ? palette.textSecondary : phiColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
