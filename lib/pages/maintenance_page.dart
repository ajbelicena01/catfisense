import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n.dart';
import '../services/maintenance_controller.dart';
import '../services/pond_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/maintenance.dart';
import '../utils/time_format.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_header.dart';
import '../widgets/maintenance_schedule_dialog.dart';
import '../widgets/maintenance_widgets.dart';

String _taskHint(AppLocalizations l10n, MaintenanceTask task) => switch (task) {
  MaintenanceTask.doElectrolyte => l10n.maintTaskDoElectrolyteHint,
  MaintenanceTask.phBuffer => l10n.maintTaskPhBufferHint,
  MaintenanceTask.modemLoad => l10n.maintTaskModemLoadHint,
  MaintenanceTask.gsmLoad => l10n.maintTaskGsmLoadHint,
};

/// The pond's upkeep schedule: sensor probes every few months, prepaid load
/// for the modem and the SMS gateway. Any member can mark a task done.
class MaintenancePage extends StatelessWidget {
  const MaintenancePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = AppPalette.of(context);
    final controller = context.watch<MaintenanceController>();
    final membership = controller.membership;
    final records = controller.records;
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: palette.background,
      drawer: const AppDrawer(),
      bottomNavigationBar: const AppBottomNav(current: null),
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    l10n.maintenanceTitle,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: palette.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.maintenanceSubtitle,
                    style: TextStyle(fontSize: 13, height: 1.4, color: palette.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  if (membership == null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Text(
                        l10n.maintNotLinked,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: palette.textSecondary),
                      ),
                    )
                  else if (records == null)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 48),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else
                    for (final record in records) ...[
                      _TaskCard(record: record, membership: membership, now: now),
                      const SizedBox(height: 12),
                    ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({required this.record, required this.membership, required this.now});

  final MaintenanceRecord record;
  final PondMembership membership;
  final DateTime now;

  Future<void> _open(BuildContext context, {required bool markDone}) => showMaintenanceScheduleDialog(
    context,
    record: record,
    pondId: membership.pondId,
    role: membership.role,
    markDone: markDone,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = AppPalette.of(context);
    final lastDone = record.lastDone;
    final dueOn = record.dueOn;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: palette.primary.withValues(alpha: 0.15),
                child: Icon(maintenanceTaskIcon(record.task), color: palette.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      maintenanceTaskTitle(l10n, record.task),
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: palette.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _taskHint(l10n, record.task),
                      style: TextStyle(fontSize: 12, height: 1.35, color: palette.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          MaintenanceStatusPill(record: record, now: now),
          const SizedBox(height: 8),
          if (lastDone == null || dueOn == null)
            Text(l10n.maintNotSetBody, style: TextStyle(fontSize: 13, color: palette.textPrimary))
          else ...[
            Text(
              l10n.maintLastDone(dateLabel(l10n, lastDone), record.intervalDays),
              style: TextStyle(fontSize: 13, color: palette.textPrimary),
            ),
            Text(
              l10n.maintNextDue(dateLabel(l10n, dueOn)),
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: palette.textPrimary),
            ),
            if (record.note != null) ...[
              const SizedBox(height: 4),
              Text(
                record.note!,
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: palette.textSecondary),
              ),
            ],
          ],
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (lastDone != null)
                TextButton(onPressed: () => _open(context, markDone: false), child: Text(l10n.maintEdit)),
              const SizedBox(width: 4),
              ElevatedButton.icon(
                onPressed: () => _open(context, markDone: lastDone != null),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kBrandOrange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                icon: Icon(lastDone == null ? Icons.event_available : Icons.check, size: 18),
                label: Text(lastDone == null ? l10n.maintSetUp : l10n.maintMarkDone),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
