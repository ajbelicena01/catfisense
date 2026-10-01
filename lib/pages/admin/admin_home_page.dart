import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/l10n.dart';
import '../../services/auth_service.dart';
import '../../services/language_controller.dart';
import '../../theme/app_theme.dart';
import '../../theme/theme_controller.dart';
import '../../utils/logout.dart';
import '../../widgets/account_dialogs.dart';
import 'admin_audit_tab.dart';
import 'admin_health_tab.dart';
import 'admin_ponds_tab.dart';
import 'admin_theme.dart';
import 'admin_thresholds_tab.dart';
import 'admin_users_tab.dart';

enum _AdminMenu { password, language, logout }

/// The admin area: shown by [AuthGate] instead of the farmer screens for
/// accounts listed under `admins/`. Every admin has the same access.
class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _tab = 0;

  static const _tabs = [
    AdminHealthTab(),
    AdminPondsTab(),
    AdminUsersTab(),
    AdminThresholdsTab(),
    AdminAuditTab(),
  ];

  // [context] is from inside the admin theme, so the dialogs are blue too.
  Future<void> _onMenu(BuildContext context, _AdminMenu item) async {
    switch (item) {
      case _AdminMenu.password:
        await showChangePasswordDialog(context);
      case _AdminMenu.language:
        await pickLanguage(context, context.read<LanguageController>());
      case _AdminMenu.logout:
        await confirmAndLogout(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // The admin area has its own blue palette, in light and dark mode.
    final dark = context.watch<ThemeController>().isDarkMode;
    return AnimatedTheme(data: adminTheme(dark: dark), child: Builder(builder: _scaffold));
  }

  Widget _scaffold(BuildContext context) {
    final l10n = context.l10n;
    final palette = AppPalette.of(context);
    final username = AuthService().currentPhoneDigits ?? '';

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: palette.surface,
        foregroundColor: palette.textPrimary,
        elevation: 0,
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.adminTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            Text(username, style: TextStyle(fontSize: 12, color: palette.textSecondary)),
          ],
        ),
        actions: [
          Builder(
            builder: (context) {
              final theme = context.watch<ThemeController>();
              final dark = theme.isDarkMode;
              // Shows what a tap switches to: the sun in dark mode, the moon in light.
              return IconButton(
                tooltip: dark ? l10n.adminLightMode : l10n.adminDarkMode,
                onPressed: () => theme.setDarkMode(!dark),
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, animation) => RotationTransition(
                    turns: Tween<double>(begin: 0.75, end: 1).animate(animation),
                    child: FadeTransition(opacity: animation, child: child),
                  ),
                  child: Icon(
                    dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                    key: ValueKey(dark),
                  ),
                ),
              );
            },
          ),
          PopupMenuButton<_AdminMenu>(
            onSelected: (item) => _onMenu(context, item),
            itemBuilder: (_) => [
              PopupMenuItem(value: _AdminMenu.password, child: Text(l10n.passwordChangeTitle)),
              PopupMenuItem(value: _AdminMenu.language, child: Text(l10n.settingsLanguage)),
              PopupMenuItem(value: _AdminMenu.logout, child: Text(l10n.logoutConfirm)),
            ],
          ),
        ],
      ),
      // IndexedStack keeps each tab's live data and scroll position when switching.
      body: SafeArea(child: IndexedStack(index: _tab, children: _tabs)),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (index) => setState(() => _tab = index),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.monitor_heart_outlined), label: l10n.adminTabHealth),
          NavigationDestination(icon: const Icon(Icons.water_outlined), label: l10n.adminTabPonds),
          NavigationDestination(icon: const Icon(Icons.people_outline), label: l10n.adminTabUsers),
          NavigationDestination(icon: const Icon(Icons.tune), label: l10n.adminTabThresholds),
          NavigationDestination(icon: const Icon(Icons.history), label: l10n.adminTabAudit),
        ],
      ),
    );
  }
}
