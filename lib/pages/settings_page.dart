import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/alert_preferences.dart';
import '../theme/app_theme.dart';
import '../theme/theme_controller.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_header.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final theme = context.watch<ThemeController>();
    final alerts = context.watch<AlertPreferences>();

    return Scaffold(
      backgroundColor: palette.background,
      drawer: const AppDrawer(),
      bottomNavigationBar: const AppBottomNav(current: BottomNavTab.settings),
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'Settings',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: palette.textPrimary),
                  ),
                  const SizedBox(height: 20),
                  _SectionLabel('Appearance', palette: palette),
                  _SettingsCard(
                    palette: palette,
                    children: [
                      _SwitchRow(
                        icon: Icons.dark_mode_outlined,
                        label: 'Dark Mode',
                        subtitle: 'Easier on the eyes at night',
                        value: theme.isDarkMode,
                        palette: palette,
                        onChanged: theme.setDarkMode,
                      ),
                      Divider(height: 1, color: palette.divider),
                      _TextSizeControl(theme: theme, palette: palette),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _SectionLabel('Notifications', palette: palette),
                  _SettingsCard(
                    palette: palette,
                    children: [
                      _SwitchRow(
                        icon: Icons.notifications_outlined,
                        label: 'Push Notifications',
                        subtitle: 'In-app alerts when a reading turns risky',
                        value: alerts.pushEnabled,
                        palette: palette,
                        onChanged: alerts.setPushEnabled,
                      ),
                      Divider(height: 1, color: palette.divider),
                      _SwitchRow(
                        icon: Icons.sms_outlined,
                        label: 'SMS Alerts',
                        subtitle: 'Text messages straight from the pond device',
                        value: alerts.smsEnabled,
                        palette: palette,
                        onChanged: alerts.setSmsEnabled,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text, {required this.palette});

  final String text;
  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Text(
        text,
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: palette.textSecondary),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children, required this.palette});

  final List<Widget> children;
  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.border),
      ),
      child: Column(children: children),
    );
  }
}

class _TextSizeControl extends StatelessWidget {
  const _TextSizeControl({required this.theme, required this.palette});

  final ThemeController theme;
  final AppPalette palette;

  static const _labels = ['Small', 'Default', 'Large', 'Extra large'];

  @override
  Widget build(BuildContext context) {
    final index = ((theme.textScale - minAppTextScale) / 0.15)
        .round()
        .clamp(0, _labels.length - 1);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.text_fields, color: palette.primary, size: 22),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Text size',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: palette.textPrimary),
                ),
              ),
              Text(_labels[index], style: TextStyle(fontSize: 13, color: palette.textSecondary)),
            ],
          ),
          Semantics(
            label: 'App text size',
            value: _labels[index],
            child: Slider(
              min: minAppTextScale,
              max: maxAppTextScale,
              divisions: 3,
              value: theme.textScale,
              label: _labels[index],
              onChanged: theme.setTextScale,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('A', style: TextStyle(fontSize: 13, color: palette.textSecondary)),
              Text('A', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700, color: palette.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.palette,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final bool value;
  final AppPalette palette;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: palette.primary, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: palette.textPrimary)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(fontSize: 12, color: palette.textSecondary)),
              ],
            ),
          ),
          Switch(value: value, activeThumbColor: palette.primary, onChanged: onChanged),
        ],
      ),
    );
  }
}
