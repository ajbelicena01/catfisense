import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../l10n/app_localizations.dart';
import '../pages/alerts_page.dart';
import '../pages/history_page.dart';
import '../pages/logbook_page.dart';
import '../pages/maintenance_page.dart';
import '../pages/recommendations_page.dart';
import '../pages/settings_page.dart';
import '../theme/app_theme.dart';
import '../utils/logout.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  void _goHome(BuildContext context) {
    Navigator.of(context).pop();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _push(BuildContext context, Widget page) {
    Navigator.of(context).pop();
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final l10n = AppLocalizations.of(context);
    return Drawer(
      backgroundColor: palette.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              child: Text(
                'CatfiSense',
                style: GoogleFonts.orbitron(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: palette.primary,
                  letterSpacing: 1,
                ),
              ),
            ),
            Divider(height: 1, color: palette.divider),
            const SizedBox(height: 8),
            _DrawerItem(icon: Icons.home_outlined, label: l10n.navHome, palette: palette, onTap: () => _goHome(context)),
            _DrawerItem(
              icon: Icons.show_chart,
              label: l10n.navHistory,
              palette: palette,
              onTap: () => _push(context, const HistoryPage()),
            ),
            _DrawerItem(
              icon: Icons.notifications_none,
              label: l10n.alertsNav,
              palette: palette,
              onTap: () => _push(context, const AlertsPage()),
            ),
            _DrawerItem(
              icon: Icons.menu_book_outlined,
              label: l10n.logbookNav,
              palette: palette,
              onTap: () => _push(context, const LogbookPage()),
            ),
            _DrawerItem(
              icon: Icons.build_outlined,
              label: l10n.maintenanceNav,
              palette: palette,
              onTap: () => _push(context, const MaintenancePage()),
            ),
            _DrawerItem(
              icon: Icons.lightbulb_outline,
              label: l10n.navInsights,
              palette: palette,
              onTap: () => _push(context, const RecommendationsPage()),
            ),
            _DrawerItem(
              icon: Icons.settings_outlined,
              label: l10n.settingsTitle,
              palette: palette,
              onTap: () => _push(context, const SettingsPage()),
            ),
            const Spacer(),
            Divider(height: 1, color: palette.divider),
            _DrawerItem(
              icon: Icons.logout,
              label: l10n.logoutConfirm,
              palette: palette,
              danger: true,
              onTap: () => confirmAndLogout(context),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.palette,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final AppPalette palette;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    const dangerColor = Color(0xFFF95668);
    final color = danger ? dangerColor : palette.textPrimary;
    final iconColor = danger ? dangerColor : palette.primary;
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: color)),
      onTap: onTap,
    );
  }
}
