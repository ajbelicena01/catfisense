import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../services/threshold_controller.dart';
import '../theme/app_theme.dart';
import '../utils/alert_history.dart';
import '../utils/pond_status.dart';
import '../utils/sensor_history.dart';
import '../utils/time_format.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_header.dart';
import '../widgets/time_range_selector.dart';
import '../widgets/history_view_pill.dart';

/// Every stretch of time the pond was in Warning or Critical, worked out
/// from the stored readings for the chosen period.
class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  HistoryRange _range = HistoryRange.weekly;
  late Stream<List<SensorHistoryPoint>> _history = watchHistory(_range);

  void _setRange(HistoryRange range) {
    if (range == _range) return;
    setState(() {
      _range = range;
      _history = watchHistory(range);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Redraw when an admin changes the pond health ranges.
    context.watch<ThresholdController>();
    final l10n = AppLocalizations.of(context);
    final palette = AppPalette.of(context);

    return Scaffold(
      backgroundColor: palette.background,
      drawer: const AppDrawer(),
      bottomNavigationBar: const AppBottomNav(current: null),
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(),
            Expanded(
              child: StreamBuilder<List<SensorHistoryPoint>>(
                stream: _history,
                builder: (context, snapshot) {
                  final points = snapshot.data;
                  final events = points == null ? null : detectAlerts(points, now: DateTime.now());
                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: HistoryViewPill(current: HistoryView.alerts),
                      ),
                      const SizedBox(height: 16),
                      TimeRangeSelector(selected: _range, onChanged: _setRange),
                      const SizedBox(height: 16),
                      if (snapshot.hasError)
                        _Message(icon: Icons.cloud_off, text: l10n.alertsLoadError)
                      else if (events == null)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 48),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (points!.isEmpty)
                        _Message(icon: Icons.sensors_off_outlined, text: l10n.alertsNoReadings)
                      else if (events.isEmpty)
                        _Message(
                          icon: styleFor(PondStatus.healthy).icon,
                          iconColor: statusAccent(PondStatus.healthy, darkMode: palette.isDark),
                          title: l10n.alertsNoneTitle,
                          text: l10n.alertsNoneBody,
                        )
                      else ...[
                        _Summary(events: events),
                        const SizedBox(height: 12),
                        for (final event in events) ...[_AlertCard(event: event), const SizedBox(height: 10)],
                      ],
                    ],
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

String _issueName(AppLocalizations l10n, AlertIssue issue) => switch (issue) {
  AlertIssue.lowPh => l10n.issueLowPh,
  AlertIssue.highPh => l10n.issueHighPh,
  AlertIssue.lowTemperature => l10n.issueLowTemperature,
  AlertIssue.highTemperature => l10n.issueHighTemperature,
  AlertIssue.lowOxygen => l10n.issueLowOxygen,
  AlertIssue.highAmmonia => l10n.issueHighAmmonia,
};

String _issueValue(AlertIssueSummary summary) => switch (summary.issue) {
  AlertIssue.lowPh || AlertIssue.highPh => summary.extremeValue.toStringAsFixed(1),
  AlertIssue.lowTemperature || AlertIssue.highTemperature => '${summary.extremeValue.toStringAsFixed(1)} °C',
  AlertIssue.lowOxygen => '${summary.extremeValue.toStringAsFixed(1)} mg/L',
  AlertIssue.highAmmonia => '${summary.extremeValue.toStringAsFixed(2)} mg/L',
};

class _Summary extends StatelessWidget {
  const _Summary({required this.events});

  final List<PondAlertEvent> events;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = AppPalette.of(context);
    final critical = events.where((event) => event.worst == PondStatus.critical).length;
    final total = events.fold(Duration.zero, (sum, event) => sum + event.duration);
    return Text(
      [
        l10n.alertsCount(events.length),
        if (critical > 0) l10n.alertsCriticalCount(critical),
        l10n.alertsTotalTime(durationLabel(l10n, total)),
      ].join(' · '),
      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: palette.textSecondary),
    );
  }
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({required this.event});

  final PondAlertEvent event;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = AppPalette.of(context);
    final accent = statusAccent(event.worst, darkMode: palette.isDark);
    final when = event.ongoing
        ? l10n.alertStartedAt(dateTimeLabel(l10n, event.start))
        : '${dateTimeLabel(l10n, event.start)} · ${l10n.alertLasted(durationLabel(l10n, event.duration))}';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.isDark ? palette.border : accent.withValues(alpha: 0.6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(styleFor(event.worst).icon, color: accent, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        statusShortLabel(l10n, event.worst),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: palette.isDark ? palette.textPrimary : accent,
                        ),
                      ),
                    ),
                    if (event.ongoing)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          l10n.alertOngoing,
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: accent),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                for (final issue in event.issues)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      '${_issueName(l10n, issue.issue)} — '
                      '${issue.issue.isHigh ? l10n.alertHighest(_issueValue(issue)) : l10n.alertLowest(_issueValue(issue))}',
                      style: TextStyle(fontSize: 13, color: palette.textPrimary),
                    ),
                  ),
                const SizedBox(height: 4),
                Text(when, style: TextStyle(fontSize: 12, color: palette.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.text, this.title, this.iconColor});

  final IconData icon;
  final Color? iconColor;
  final String? title;
  final String text;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
      child: Column(
        children: [
          Icon(icon, size: 44, color: iconColor ?? palette.textSecondary),
          const SizedBox(height: 12),
          if (title != null) ...[
            Text(
              title!,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: palette.textPrimary),
            ),
            const SizedBox(height: 4),
          ],
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, height: 1.4, color: palette.textSecondary),
          ),
        ],
      ),
    );
  }
}
