import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../theme/app_theme.dart';
import '../utils/pond_status.dart';

// Keep in sync with `version:` in pubspec.yaml.
const _appVersion = '1.0.0';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final l10n = context.l10n;
    final darkMode = palette.isDark;

    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                IconButton(
                  tooltip: l10n.commonBack,
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.arrow_back, color: palette.primary),
                ),
                const SizedBox(width: 4),
                Text(
                  l10n.settingsAbout,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: palette.textPrimary),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _Card(
              palette: palette,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  children: [
                    Image.asset('assets/images/logo_header.png', height: 88),
                    const SizedBox(height: 12),
                    Text(
                      l10n.aboutTagline,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: palette.textPrimary),
                    ),
                    const SizedBox(height: 6),
                    Text(l10n.aboutVersion(_appVersion), style: TextStyle(fontSize: 12, color: palette.textSecondary)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _SectionLabel(l10n.aboutWhatItDoes, palette: palette),
            _Card(
              palette: palette,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  l10n.aboutWhatItDoesBody,
                  style: TextStyle(fontSize: 14, height: 1.45, color: palette.textPrimary),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _SectionLabel(l10n.aboutWhatItMonitors, palette: palette),
            _Card(
              palette: palette,
              child: Column(
                children: [
                  _InfoRow(
                    icon: Icons.science_outlined,
                    iconColor: palette.primary,
                    title: 'pH',
                    body: l10n.aboutPhBody,
                    palette: palette,
                  ),
                  Divider(height: 1, color: palette.divider),
                  _InfoRow(
                    icon: Icons.thermostat,
                    iconColor: palette.primary,
                    title: l10n.paramTemperature,
                    body: l10n.aboutTemperatureBody,
                    palette: palette,
                  ),
                  Divider(height: 1, color: palette.divider),
                  _InfoRow(
                    icon: Icons.air,
                    iconColor: palette.primary,
                    title: l10n.paramOxygen,
                    body: l10n.aboutOxygenBody,
                    palette: palette,
                  ),
                  Divider(height: 1, color: palette.divider),
                  _InfoRow(
                    icon: Icons.water_drop_outlined,
                    iconColor: palette.primary,
                    title: l10n.paramAmmonia,
                    body: l10n.aboutAmmoniaBody,
                    palette: palette,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _SectionLabel(l10n.aboutPondStatus, palette: palette),
            _Card(
              palette: palette,
              child: Column(
                children: [
                  _statusRow(l10n, PondStatus.healthy, l10n.aboutStatusGood, palette, darkMode),
                  Divider(height: 1, color: palette.divider),
                  _statusRow(
                    l10n,
                    PondStatus.warning,
                    l10n.aboutStatusWarning,
                    palette,
                    darkMode,
                  ),
                  Divider(height: 1, color: palette.divider),
                  _statusRow(
                    l10n,
                    PondStatus.critical,
                    l10n.aboutStatusCritical,
                    palette,
                    darkMode,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _SectionLabel(l10n.aboutHowItWorks, palette: palette),
            _Card(
              palette: palette,
              child: Column(
                children: [
                  _InfoRow(
                    icon: Icons.sensors,
                    iconColor: palette.primary,
                    title: l10n.aboutStepMeasure,
                    body: l10n.aboutStepMeasureBody,
                    palette: palette,
                  ),
                  Divider(height: 1, color: palette.divider),
                  _InfoRow(
                    icon: Icons.cloud_upload_outlined,
                    iconColor: palette.primary,
                    title: l10n.aboutStepSend,
                    body: l10n.aboutStepSendBody,
                    palette: palette,
                  ),
                  Divider(height: 1, color: palette.divider),
                  _InfoRow(
                    icon: Icons.phone_android,
                    iconColor: palette.primary,
                    title: l10n.aboutStepAlert,
                    body: l10n.aboutStepAlertBody,
                    palette: palette,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Text('© 2026 CatfiSense', style: TextStyle(fontSize: 12, color: palette.textSecondary)),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _statusRow(AppLocalizations l10n, PondStatus status, String body, AppPalette palette, bool darkMode) {
    final style = styleFor(status);
    return _InfoRow(
      icon: style.icon,
      iconColor: statusAccent(status, darkMode: darkMode),
      title: statusShortLabel(l10n, status),
      body: body,
      palette: palette,
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

class _Card extends StatelessWidget {
  const _Card({required this.child, required this.palette});

  final Widget child;
  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.border),
      ),
      child: child,
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
    required this.palette,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;
  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: palette.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(body, style: TextStyle(fontSize: 12, height: 1.4, color: palette.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
