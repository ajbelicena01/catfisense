import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/sensor_repository.dart';
import '../theme/app_theme.dart';
import '../utils/pond_status.dart';
import '../utils/time_format.dart';

/// The ESP32 sends a reading every 5 seconds, so a couple of minutes of
/// silence means it has stopped (no power, no Wi-Fi, or a fault).
const sensorOfflineAfter = Duration(minutes: 2);

/// After this long without readings the banner turns from warning to critical.
const _sensorLongOfflineAfter = Duration(hours: 1);

/// `.info/connected` reports false for a moment on every app start; only
/// call the phone offline once it has stayed disconnected this long.
const _offlineGrace = Duration(seconds: 4);

/// Warns when the numbers on screen may not be current: the phone has no
/// connection, or the sensor has stopped sending. Shows nothing otherwise.
class DataFreshnessBanner extends StatefulWidget {
  const DataFreshnessBanner({super.key, required this.lastReadingAt, required this.now});

  final DateTime? lastReadingAt;

  /// Passed in by the page's own clock so "9 hours ago" keeps moving.
  final DateTime now;

  @override
  State<DataFreshnessBanner> createState() => _DataFreshnessBannerState();
}

class _DataFreshnessBannerState extends State<DataFreshnessBanner> {
  StreamSubscription<bool>? _connectionSub;
  Timer? _graceTimer;
  bool _phoneOffline = false;

  @override
  void initState() {
    super.initState();
    _connectionSub = SensorRepository().connected().listen((connected) {
      _graceTimer?.cancel();
      if (connected) {
        if (_phoneOffline) setState(() => _phoneOffline = false);
      } else {
        _graceTimer = Timer(_offlineGrace, () {
          if (mounted) setState(() => _phoneOffline = true);
        });
      }
    });
  }

  @override
  void dispose() {
    _graceTimer?.cancel();
    _connectionSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = AppPalette.of(context);
    final lastReadingAt = widget.lastReadingAt;
    final silence = lastReadingAt == null ? null : widget.now.difference(lastReadingAt);

    // Offline wins: while the phone can't connect, "the sensor stopped" can't
    // be told apart from "we just can't see new readings".
    final Widget? banner;
    if (_phoneOffline) {
      banner = _Banner(
        icon: Icons.wifi_off,
        accent: palette.textSecondary,
        background: palette.isDark ? palette.surface : const Color(0xFFF1F1F4),
        title: l10n.freshnessNoInternetTitle,
        body: l10n.freshnessNoInternetBody,
      );
    } else if (silence != null && silence > sensorOfflineAfter) {
      final status = silence > _sensorLongOfflineAfter ? PondStatus.critical : PondStatus.warning;
      banner = _Banner(
        icon: Icons.sensors_off_outlined,
        accent: statusAccent(status, darkMode: palette.isDark),
        background: palette.isDark ? palette.surface : styleFor(status).background,
        title: l10n.freshnessSensorOfflineTitle,
        body: l10n.freshnessSensorOfflineBody(timeAgo(l10n, lastReadingAt!, widget.now)),
      );
    } else {
      banner = null;
    }

    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      alignment: Alignment.topCenter,
      child: banner == null
          ? const SizedBox(width: double.infinity)
          : Padding(padding: const EdgeInsets.only(bottom: 12), child: banner),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({
    required this.icon,
    required this.accent,
    required this.background,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final Color accent;
  final Color background;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accent, width: 1.2),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: accent, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: palette.isDark ? palette.textPrimary : accent,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(body, style: TextStyle(fontSize: 13, height: 1.35, color: palette.textPrimary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
