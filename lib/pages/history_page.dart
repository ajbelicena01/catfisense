import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/sensor_history.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_header.dart';
import '../widgets/sensor_history_chart.dart';
import '../widgets/time_range_selector.dart';

const _monthAbbr = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  HistoryRange _range = HistoryRange.daily;
  DateTimeRange? _customRange;

  Future<void> _onCustomTap() async {
    final now = DateTime.now();
    final primary = AppPalette.of(context).primary;
    final picked = await showDateRangePicker(
      context: context,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now,
      initialDateRange: _customRange ??
          DateTimeRange(start: now.subtract(const Duration(days: 6)), end: now),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(primary: primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _customRange = picked;
        _range = HistoryRange.custom;
      });
    }
  }

  String _formatCustomLabel(DateTimeRange range) {
    final start = range.start;
    final end = range.end;
    if (start.year == end.year && start.month == end.month) {
      return '${_monthAbbr[start.month - 1]} ${start.day}-${end.day}';
    }
    return '${start.month}/${start.day}-${end.month}/${end.day}';
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final customLabel = _customRange == null ? null : _formatCustomLabel(_customRange!);
    final selector = TimeRangeSelector(
      selected: _range,
      onChanged: (range) => setState(() => _range = range),
      onCustomTap: _onCustomTap,
      customLabel: customLabel,
    );

    return Scaffold(
      backgroundColor: palette.background,
      drawer: const AppDrawer(),
      bottomNavigationBar: const AppBottomNav(current: BottomNavTab.history),
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(),
            Expanded(
              child: StreamBuilder<List<SensorHistoryPoint>>(
                stream: watchHistory(_range, customRange: _customRange),
                builder: (context, snapshot) {
                  final points = snapshot.data ?? const [];
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Water Parameter History',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: palette.textPrimary),
                        ),
                        const SizedBox(height: 16),
                        _ChartCard(
                          child: selector,
                        ),
                        const SizedBox(height: 20),
                        if (!snapshot.hasData)
                          _ChartCard(
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 48),
                              child: Center(child: CircularProgressIndicator()),
                            ),
                          )
                        else if (points.isEmpty)
                          _ChartCard(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 36),
                              child: Center(
                                child: Text(
                                  'No readings recorded in this range yet.',
                                  style: TextStyle(fontSize: 13, color: palette.textSecondary),
                                ),
                              ),
                            ),
                          )
                        else
                          for (final metric in SensorMetric.values) ...[
                            _ChartCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    metric.title,
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                      color: metric.color,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  SensorHistoryChart(
                                    points: points,
                                    range: _range,
                                    metric: metric,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: palette.primary),
      ),
      child: child,
    );
  }
}
