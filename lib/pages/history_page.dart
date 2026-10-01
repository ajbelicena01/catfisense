import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n.dart';
import '../services/logbook_service.dart';
import '../services/report_service.dart';
import '../services/threshold_controller.dart';
import '../theme/app_theme.dart';
import '../utils/sensor_history.dart';
import '../utils/time_format.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_header.dart';
import '../widgets/sensor_history_chart.dart';
import '../widgets/time_range_selector.dart';
import '../widgets/history_view_pill.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final _logbook = LogbookService();
  HistoryRange _range = HistoryRange.daily;
  DateTimeRange? _customRange;

  // Kept in state so rebuilds don't restart the downloads; replaced only
  // when the range changes.
  late Stream<List<SensorHistoryPoint>> _history;
  late Stream<List<LogEntry>> _logs;

  @override
  void initState() {
    super.initState();
    _watchRange();
  }

  void _watchRange() {
    final (start, end) = historyWindow(_range, customRange: _customRange);
    _history = watchHistory(_range, customRange: _customRange);
    _logs = _logbook.entries(start: start, end: end);
  }

  Future<void> _onCustomTap() async {
    final now = DateTime.now();
    final primary = AppPalette.of(context).primary;
    final picked = await showDateRangePicker(
      context: context,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now,
      initialDateRange: _customRange ?? DateTimeRange(start: now.subtract(const Duration(days: 6)), end: now),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(colorScheme: Theme.of(context).colorScheme.copyWith(primary: primary)),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _customRange = picked;
        _range = HistoryRange.custom;
        _watchRange();
      });
    }
  }

  Future<void> _openExport() async {
    final l10n = AppLocalizations.of(context);
    final palette = AppPalette.of(context);
    final (start, end) = historyWindow(_range, customRange: _customRange);
    final period = '${dateLabel(l10n, start)} - ${dateLabel(l10n, end)}';
    final pdf = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: palette.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 20, 8, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  l10n.exportTitle,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: palette.textPrimary),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Text(l10n.exportPeriod(period), style: TextStyle(fontSize: 13, color: palette.textSecondary)),
              ),
              ListTile(
                leading: Icon(Icons.picture_as_pdf_outlined, color: palette.primary),
                title: Text(l10n.exportPdf, style: TextStyle(fontWeight: FontWeight.w700, color: palette.textPrimary)),
                subtitle: Text(l10n.exportPdfHint, style: TextStyle(color: palette.textSecondary)),
                onTap: () => Navigator.of(sheetContext).pop(true),
              ),
              ListTile(
                leading: Icon(Icons.table_chart_outlined, color: palette.primary),
                title: Text(l10n.exportCsv, style: TextStyle(fontWeight: FontWeight.w700, color: palette.textPrimary)),
                subtitle: Text(l10n.exportCsvHint, style: TextStyle(color: palette.textSecondary)),
                onTap: () => Navigator.of(sheetContext).pop(false),
              ),
            ],
          ),
        ),
      ),
    );
    if (pdf == null || !mounted) return;
    await _export(pdf: pdf, start: start, end: end);
  }

  Future<void> _export({required bool pdf, required DateTime start, required DateTime end}) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(SnackBar(content: Text(l10n.exportWorking)));
    try {
      final points = await watchHistory(_range, customRange: _customRange).first;
      if (points.isEmpty) {
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(SnackBar(content: Text(l10n.exportNoData)));
        return;
      }
      // A missing logbook shouldn't block the report.
      final logs = await _logbook.entries(start: start, end: end).first.catchError((Object _) => <LogEntry>[]);
      final data = ReportData(start: start, end: end, points: points, logs: logs, generatedAt: DateTime.now());
      messenger.hideCurrentSnackBar();
      if (pdf) {
        await const ReportService().sharePdf(l10n, data);
      } else {
        await const ReportService().shareCsv(l10n, data);
      }
    } catch (_) {
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(SnackBar(content: Text(l10n.exportError)));
    }
  }

  String _formatCustomLabel(DateTimeRange range) {
    final format = DateFormat.MMMd(context.l10n.localeName);
    return '${format.format(range.start)} - ${format.format(range.end)}';
  }

  @override
  Widget build(BuildContext context) {
    // Redraw when an admin changes the pond health ranges.
    context.watch<ThresholdController>();
    final palette = AppPalette.of(context);
    final customLabel = _customRange == null ? null : _formatCustomLabel(_customRange!);
    final selector = TimeRangeSelector(
      selected: _range,
      onChanged: (range) => setState(() {
        _range = range;
        _watchRange();
      }),
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
              child: StreamBuilder<List<LogEntry>>(
                stream: _logs,
                builder: (context, logsSnapshot) => StreamBuilder<List<SensorHistoryPoint>>(
                  stream: _history,
                  builder: (context, snapshot) {
                    final points = snapshot.data ?? const [];
                    final markers = [for (final entry in logsSnapshot.data ?? const <LogEntry>[]) entry.at];
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Expanded(
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: HistoryViewPill(current: HistoryView.parameters),
                                ),
                              ),
                              IconButton(
                                tooltip: AppLocalizations.of(context).exportTooltip,
                                onPressed: _openExport,
                                icon: Icon(Icons.ios_share, color: palette.primary),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _ChartCard(child: selector),
                          if (markers.isNotEmpty && points.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Text(
                              AppLocalizations.of(context).logbookChartLegend,
                              style: TextStyle(fontSize: 12, color: palette.textSecondary),
                            ),
                          ],
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
                                    AppLocalizations.of(context).historyNoReadings,
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
                                      metric.title(AppLocalizations.of(context)),
                                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: metric.color),
                                    ),
                                    const SizedBox(height: 12),
                                    SensorHistoryChart(points: points, range: _range, metric: metric, markers: markers),
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
