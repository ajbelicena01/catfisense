import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../pages/history_page.dart';
import '../pages/recommendations_page.dart';
import '../pages/settings_page.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

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

  Future<void> _logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text("You'll need to log in again to access your pond data."),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: const Text('Log out')),
        ],
      ),
    );
    if (confirmed != true) return;
    await AuthService().signOut();
    if (context.mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
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
            _DrawerItem(icon: Icons.home_outlined, label: 'Home', palette: palette, onTap: () => _goHome(context)),
            _DrawerItem(
              icon: Icons.show_chart,
              label: 'History',
              palette: palette,
              onTap: () => _push(context, const HistoryPage()),
            ),
            _DrawerItem(
              icon: Icons.lightbulb_outline,
              label: 'Insights',
              palette: palette,
              onTap: () => _push(context, const RecommendationsPage()),
            ),
            _DrawerItem(
              icon: Icons.settings_outlined,
              label: 'Settings',
              palette: palette,
              onTap: () => _push(context, const SettingsPage()),
            ),
            const Spacer(),
            Divider(height: 1, color: palette.divider),
            _DrawerItem(
              icon: Icons.logout,
              label: 'Logout',
              palette: palette,
              danger: true,
              onTap: () => _logout(context),
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
