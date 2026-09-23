import 'package:flutter/material.dart';

import '../pages/history_page.dart';
import '../pages/recommendations_page.dart';
import '../pages/settings_page.dart';
import '../services/sensor_repository.dart';
import '../theme/app_theme.dart';

enum BottomNavTab { home, history, insights, settings }

/// Persistent bottom navigation shown on every main screen (Home, History,
/// Insights, Settings). It owns its navigation and can explicitly refresh the
/// newest RTDB reading without writing test data.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key, required this.current});

  final BottomNavTab current;

  void _goHome(BuildContext context) {
    if (current == BottomNavTab.home) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _push(BuildContext context, BottomNavTab tab, Widget page) {
    if (current == tab) return;
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  Future<void> _openInsights(BuildContext context) async {
    if (current == BottomNavTab.insights) return;
    final reading = await SensorRepository().latestReading().first;
    if (!context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => reading == null
            ? const RecommendationsPage()
            : RecommendationsPage(
                ph: reading.ph,
                temperature: reading.temperature,
                dissolvedOxygen: reading.dissolvedOxygen,
                ammonia: reading.ammonia,
              ),
      ),
    );
  }

  Future<void> _refreshLatestReading(BuildContext context) async {
    try {
      final reading = await SensorRepository().fetchLatestReading();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            reading == null
                ? 'No sensor readings are available yet.'
                : 'Latest sensor reading refreshed.',
          ),
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not refresh sensor readings.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: palette.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavIcon(
              icon: Icons.home,
              active: current == BottomNavTab.home,
              onTap: () => _goHome(context),
            ),
            _NavIcon(
              icon: Icons.show_chart,
              active: current == BottomNavTab.history,
              onTap: () =>
                  _push(context, BottomNavTab.history, const HistoryPage()),
            ),
            _CenterRefreshButton(onTap: () => _refreshLatestReading(context)),
            _NavIcon(
              icon: Icons.lightbulb_outline,
              active: current == BottomNavTab.insights,
              onTap: () => _openInsights(context),
            ),
            _NavIcon(
              icon: Icons.settings_outlined,
              active: current == BottomNavTab.settings,
              onTap: () =>
                  _push(context, BottomNavTab.settings, const SettingsPage()),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({
    required this.icon,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return IconButton(
      onPressed: onTap,
      icon: Icon(
        icon,
        color: active ? palette.primary : palette.textSecondary,
        size: 24,
      ),
    );
  }
}

class _CenterRefreshButton extends StatefulWidget {
  const _CenterRefreshButton({required this.onTap});

  final Future<void> Function() onTap;

  @override
  State<_CenterRefreshButton> createState() => _CenterRefreshButtonState();
}

class _CenterRefreshButtonState extends State<_CenterRefreshButton> {
  double _turns = 0;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Transform.translate(
      offset: const Offset(0, -14),
      child: GestureDetector(
        onTap: () {
          setState(() => _turns += 1);
          widget.onTap();
        },
        child: AnimatedRotation(
          turns: _turns,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: palette.primary,
              boxShadow: [
                BoxShadow(
                  color: palette.primary.withValues(alpha: 0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.refresh, color: Colors.white, size: 28),
          ),
        ),
      ),
    );
  }
}
