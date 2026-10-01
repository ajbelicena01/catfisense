import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../../services/admin_service.dart';
import '../../services/pond_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/time_format.dart';
import 'admin_widgets.dart';

class AdminUsersTab extends StatefulWidget {
  const AdminUsersTab({super.key});

  @override
  State<AdminUsersTab> createState() => _AdminUsersTabState();
}

class _AdminUsersTabState extends State<AdminUsersTab> {
  static const _admin = AdminService();
  late final Stream<List<AdminProfile>> _admins = _admin.admins();
  late final Stream<List<UserSummary>> _users = _admin.users();
  late final Stream<List<PondSummary>> _ponds = _admin.ponds();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = AppPalette.of(context);
    final me = FirebaseAuth.instance.currentUser?.uid;

    return StreamBuilder<List<PondSummary>>(
      stream: _ponds,
      builder: (context, pondsSnapshot) {
        final ponds = pondsSnapshot.data ?? const <PondSummary>[];
        final names = {for (final pond in ponds) ...pond.names};
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            StreamBuilder<List<AdminProfile>>(
              stream: _admins,
              builder: (context, snapshot) {
                final admins = snapshot.data ?? const <AdminProfile>[];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AdminSectionLabel(l10n.adminAdmins(admins.length)),
                    AdminCard(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Column(
                        children: [
                          for (final admin in admins)
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                              leading: Icon(Icons.admin_panel_settings_outlined, color: palette.primary),
                              title: Text(admin.username, style: TextStyle(color: palette.textPrimary)),
                              trailing: admin.uid == me ? StatusPill(text: l10n.adminYou, color: palette.primary) : null,
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            StreamBuilder<List<UserSummary>>(
              stream: _users,
              builder: (context, snapshot) {
                final users = snapshot.data;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AdminSectionLabel(l10n.adminFarmers(users?.length ?? 0)),
                    if (snapshot.hasError)
                      AdminMessage(icon: Icons.cloud_off, text: l10n.loadError)
                    else if (users == null)
                      const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator()))
                    else
                      AdminCard(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: Column(
                          children: [
                            for (final user in users)
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Icon(Icons.person_outline, color: palette.primary),
                                title: Text(names[user.uid] ?? user.phone ?? user.uid, style: TextStyle(color: palette.textPrimary)),
                                subtitle: Text(
                                  [
                                    if (names[user.uid] != null) ?user.phone,
                                    _membership(l10n, ponds, user.uid),
                                    if (user.createdAt != null) l10n.adminJoined(dateLabel(l10n, user.createdAt!)),
                                  ].join(' · '),
                                  style: TextStyle(fontSize: 12, color: palette.textSecondary),
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }

  static String _membership(AppLocalizations l10n, List<PondSummary> ponds, String uid) {
    for (final pond in ponds) {
      final role = AdminService.roleIn(pond, uid);
      if (role != null) return '${role == PondRole.owner ? l10n.roleOwner : l10n.roleCaretaker}, ${pond.name}';
    }
    return l10n.settingsRoleNone;
  }
}
