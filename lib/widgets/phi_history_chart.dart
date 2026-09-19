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
    final labelStep = (points.length / 6).ceil().clamp(1, points.length);

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
                  axisNameWidget: Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text('Reading', style: TextStyle(fontSize: 12, color: axisColor)),
                  ),
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
                      if (i < 0 || i >= points.length || i % labelStep != 0) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          points[i].label(range),
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
                  spots: [for (var i = 0; i < points.length; i++) FlSpot(i.toDouble(), points[i].phi)],
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
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.circle, color: phiColor, size: 10),
            SizedBox(width: 6),
            Text('Overall PHI', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: phiColor)),
          ],
        ),
      ],
    );
  }
}
