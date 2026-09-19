import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/sensor_history.dart';

const phColor = Color(0xFF9C27B0);
const temperatureColor = Color(0xFF009688);
const ammoniaColor = Color(0xFFFF5722);
const doColor = Color(0xFFFFEB3B);
const phiColor = Color(0xFF03A9F4);

/// Overlays all 5 metrics on one chart. Each is normalized to its own
/// reasonable full-scale range (0-1) since pH, °C, mg/L ammonia, mg/L oxygen,
/// and the PHI score live on wildly different scales — without normalizing,
/// most lines would be flat at the bottom. The y-axis intentionally has no
/// numeric labels for this reason; it's a trend overview, not a value readout.
class SensorHistoryChart extends StatelessWidget {
  const SensorHistoryChart({super.key, required this.points, required this.range});

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
              maxY: 1,
              gridData: const FlGridData(drawVerticalLine: false),
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
                  sideTitles: const SideTitles(showTitles: false),
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
                _series((p) => p.ph / 14, phColor),
                _series((p) => p.temperature / 40, temperatureColor),
                _series((p) => p.ammonia / 0.1, ammoniaColor),
                _series((p) => p.dissolvedOxygen / 10, doColor),
                _series((p) => p.phi / 4, phiColor),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 16,
          runSpacing: 8,
          children: const [
            _LegendItem(color: phColor, label: 'pH'),
            _LegendItem(color: temperatureColor, label: 'Temperature'),
            _LegendItem(color: ammoniaColor, label: 'Ammonia'),
            _LegendItem(color: doColor, label: 'DO'),
            _LegendItem(color: phiColor, label: 'Overall PHI'),
          ],
        ),
      ],
    );
  }

  LineChartBarData _series(double Function(SensorHistoryPoint) selector, Color color) {
    return LineChartBarData(
      spots: [for (var i = 0; i < points.length; i++) FlSpot(i.toDouble(), selector(points[i]).clamp(0, 1))],
      isCurved: true,
      color: color,
      barWidth: 2,
      dotData: const FlDotData(show: false),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
      ],
    );
  }
}
