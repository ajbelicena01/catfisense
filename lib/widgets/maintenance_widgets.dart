import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n.dart';
import '../pages/maintenance_page.dart';
import '../services/maintenance_controller.dart';
import '../theme/app_theme.dart';
import '../utils/maintenance.dart';
import '../utils/pond_status.dart';
import '../utils/slide_page_route.dart';

IconData maintenanceTaskIcon(MaintenanceTask task) => switch (task) {
  MaintenanceTask.doElectrolyte => Icons.bubble_chart_outlined,
  MaintenanceTask.phBuffer => Icons.science_outlined,
  MaintenanceTask.modemLoad => Icons.wifi,
  MaintenanceTask.gsmLoad => Icons.sim_card_outlined,
};

/// Colors a maintenance state like the pond statuses: fine is green, due
/// soon is the warning color, overdue is critical. Null for "not set up".
PondStatus? maintenanceStatusColorKey(MaintenanceState state) => switch (state) {
  MaintenanceState.notSet => null,
  MaintenanceState.ok => PondStatus.healthy,
  MaintenanceState.dueSoon => PondStatus.warning,
  MaintenanceState.overdue => PondStatus.critical,
};

/// "Due in 5 days" / "3 days overdue" / "Not set up", colored by urgency.
class MaintenanceStatusPill extends StatelessWidget {
  const MaintenanceStatusPill({super.key, required this.record, required this.now});

  final MaintenanceRecord record;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final key = maintenanceStatusColorKey(record.stateAt(now));
    final color = key == null ? palette.textSecondary : statusAccent(key, darkMode: palette.isDark);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        maintenanceStatusText(context.l10n, record, now),
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}

/// Dashboard banner listing the tasks due soon or overdue; opens the
/// Maintenance page. Takes no space when nothing needs attention.
class MaintenanceBanner extends StatelessWidget {
  const MaintenanceBanner({super.key, required this.now});

  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final records = context.watch<MaintenanceController>().records;
    final due = records == null ? const <MaintenanceRecord>[] : needingAttention(records, now);
    if (due.isEmpty) return const SizedBox.shrink();

    final l10n = context.l10n;
    final palette = AppPalette.of(context);
    final status = due.first.stateAt(now) == MaintenanceState.overdue ? PondStatus.critical : PondStatus.warning;
    final accent = statusAccent(status, darkMode: palette.isDark);
    final tasks = due
        .map((record) => '${maintenanceTaskTitle(l10n, record.task)} (${maintenanceStatusText(l10n, record, now).toLowerCase()})')
        .join(', ');

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: palette.isDark ? palette.surface : styleFor(status).background,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.of(context).push(slidePageRoute(const MaintenancePage())),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: accent, width: 1.2),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.build_outlined, color: accent, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.maintBannerTitle(due.length),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: palette.isDark ? palette.textPrimary : accent,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.maintBannerBody(tasks),
                        style: TextStyle(fontSize: 13, height: 1.35, color: palette.textPrimary),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: palette.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
