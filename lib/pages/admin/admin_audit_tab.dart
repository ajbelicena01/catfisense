import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../../services/audit_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/time_format.dart';
import 'admin_widgets.dart';

class AdminAuditTab extends StatefulWidget {
  const AdminAuditTab({super.key});

  @override
  State<AdminAuditTab> createState() => _AdminAuditTabState();
}

class _AdminAuditTabState extends State<AdminAuditTab> {
  late final Stream<List<AuditEntry>> _entries = const AuditService().recent();

  static IconData _icon(AuditAction action) => switch (action) {
    AuditAction.thresholdsChanged || AuditAction.thresholdsReset => Icons.tune,
    AuditAction.caretakerRemoved || AuditAction.ownerRemoved => Icons.person_remove_outlined,
    AuditAction.codeChanged => Icons.vpn_key_outlined,
    AuditAction.pondAdded => Icons.add_box_outlined,
    AuditAction.pondRenamed => Icons.edit_outlined,
    AuditAction.memberRenamed => Icons.badge_outlined,
    AuditAction.maintenanceChanged => Icons.build_outlined,
    AuditAction.recipientAdded || AuditAction.recipientRemoved => Icons.sms_outlined,
    AuditAction.logEntryDeleted => Icons.delete_outline,
    AuditAction.other => Icons.history,
  };

  static String _title(AppLocalizations l10n, AuditAction action) => switch (action) {
    AuditAction.thresholdsChanged => l10n.auditThresholdsChanged,
    AuditAction.thresholdsReset => l10n.auditThresholdsReset,
    AuditAction.caretakerRemoved => l10n.auditCaretakerRemoved,
    AuditAction.ownerRemoved => l10n.auditOwnerRemoved,
    AuditAction.codeChanged => l10n.auditCodeChanged,
    AuditAction.pondAdded => l10n.auditPondAdded,
    AuditAction.pondRenamed => l10n.auditPondRenamed,
    AuditAction.memberRenamed => l10n.auditMemberRenamed,
    AuditAction.maintenanceChanged => l10n.auditMaintenanceChanged,
    AuditAction.recipientAdded => l10n.auditRecipientAdded,
    AuditAction.recipientRemoved => l10n.auditRecipientRemoved,
    AuditAction.logEntryDeleted => l10n.auditLogEntryDeleted,
    AuditAction.other => l10n.auditOther,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = AppPalette.of(context);
    return StreamBuilder<List<AuditEntry>>(
      stream: _entries,
      builder: (context, snapshot) {
        final entries = snapshot.data;
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            AdminSectionLabel(l10n.auditSubtitle),
            if (snapshot.hasError)
              AdminMessage(icon: Icons.cloud_off, text: l10n.loadError)
            else if (entries == null)
              const Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator()))
            else if (entries.isEmpty)
              AdminMessage(icon: Icons.history, text: l10n.auditEmpty)
            else
              for (final entry in entries) ...[
                AdminCard(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(_icon(entry.action), color: palette.primary, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _title(l10n, entry.action),
                              style: TextStyle(fontWeight: FontWeight.w800, color: palette.textPrimary),
                            ),
                            if (entry.target != null || entry.pondId != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                [?entry.target, ?entry.pondId].join(' · '),
                                style: TextStyle(fontSize: 13, color: palette.textPrimary),
                              ),
                            ],
                            if (entry.details != null) ...[
                              const SizedBox(height: 2),
                              Text(entry.details!, style: TextStyle(fontSize: 12, color: palette.textSecondary)),
                            ],
                            const SizedBox(height: 4),
                            Text(
                              l10n.auditBy(entry.byName, dateTimeLabel(l10n, entry.at)),
                              style: TextStyle(fontSize: 11, color: palette.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
          ],
        );
      },
    );
  }
}
