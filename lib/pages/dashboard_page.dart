import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/sensor_reading.dart';
import '../services/alert_preferences.dart';
import '../services/notification_service.dart';
import '../services/sensor_repository.dart';
import '../theme/app_theme.dart';
import '../utils/pond_status.dart';
import '../utils/slide_page_route.dart';
import '../widgets/alert_consent_dialog.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_header.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/battery_status_row.dart';
import '../widgets/sensor_reading_card.dart';
import '../widgets/status_banner.dart';
import 'history_page.dart';
import 'recommendations_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _sensorRepository = SensorRepository();

  SensorReading? _latest;
  StreamSubscription<SensorReading?>? _readingSubscription;

  // Tracks the last status we actually notified about, so an ongoing
  // warning/critical condition doesn't re-notify on every new reading —
  // only on a transition (e.g. healthy -> warning, or warning -> critical).
  PondStatus _lastNotifiedStatus = PondStatus.healthy;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowAlertConsent());
    // Live-listens to readings/pond1 in Realtime Database. This is the
    // ESP32's actual data feed — no simulated/auto-generated readings run
    // automatically anymore. Use the refresh button below for a manual
    // test push if no hardware is connected yet.
    _readingSubscription = _sensorRepository.latestReading().listen(_onReading);
  }

  @override
  void dispose() {
    _readingSubscription?.cancel();
    super.dispose();
  }

  void _onReading(SensorReading? reading) {
    if (!mounted || reading == null) return;
    setState(() => _latest = reading);
    _checkForAlert(reading);
  }

  void _checkForAlert(SensorReading reading) {
    final overallStatus = worstOf([
      phStatus(reading.ph),
      temperatureStatus(reading.temperature),
      dissolvedOxygenStatus(reading.dissolvedOxygen),
      ammoniaStatus(reading.ammonia),
    ]);
    if (overallStatus != PondStatus.healthy && overallStatus != _lastNotifiedStatus) {
      if (context.read<AlertPreferences>().pushEnabled) {
        NotificationService.instance.showPondAlert(overallStatus);
      }
    }
    _lastNotifiedStatus = overallStatus;
  }

  Future<void> _maybeShowAlertConsent() async {
    if (!mounted) return;
    final prefs = context.read<AlertPreferences>();
    if (prefs.hasShownConsent) {
      // Already decided before; just keep the OS permission in sync with
      // their saved choice (calling this is a no-op once already granted).
      if (prefs.pushEnabled) await prefs.requestNotificationPermission();
      return;
    }
    if (!mounted) return;
    await showAlertConsentDialog(context);
  }

  /// Manual-only test helper (tap refresh on the empty state) for pushing
  /// one fake reading when no ESP32 is connected yet. Real data arrives
  /// on its own via the [_readingSubscription] stream above — nothing
  /// calls this automatically.
  Future<void> _simulateReading() async {
    final random = Random();
    await _sensorRepository.pushSimulatedReading(
      ph: 5.5 + random.nextDouble() * 4.5,
      temperature: 18 + random.nextDouble() * 20,
      dissolvedOxygen: random.nextDouble() * 8,
      ammonia: random.nextDouble() * 0.1,
      batteryPercent: 60 + random.nextInt(41),
    );
  }

  String _formatTime(DateTime time) {
    final hour12 = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour12:$minute$period';
  }

  void _openRecommendations() {
    final reading = _latest;
    if (reading == null) return;
    Navigator.of(context).push(slidePageRoute(RecommendationsPage(
      ph: reading.ph,
      temperature: reading.temperature,
      dissolvedOxygen: reading.dissolvedOxygen,
      ammonia: reading.ammonia,
    )));
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final reading = _latest;

    return Scaffold(
      backgroundColor: palette.background,
      drawer: const AppDrawer(),
      bottomNavigationBar: const AppBottomNav(current: BottomNavTab.home),
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: reading == null
                    ? _EmptyState(palette: palette)
                    : _Loaded(
                        reading: reading,
                        palette: palette,
                        onTap: _openRecommendations,
                        updatedLabel: _formatTime(reading.recordedAt),
                        onHistoryTap: () => Navigator.of(context)
                            .push(MaterialPageRoute(builder: (_) => const HistoryPage())),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.palette});

  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: Column(
        children: [
          Icon(Icons.sensors_off_outlined, size: 48, color: palette.textSecondary),
          const SizedBox(height: 16),
          Text(
            'No readings yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: palette.textPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            'Tap the refresh button below to simulate a reading\nuntil the pond sensor is connected.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: palette.textSecondary, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _Loaded extends StatelessWidget {
  const _Loaded({
    required this.reading,
    required this.palette,
    required this.onTap,
    required this.updatedLabel,
    required this.onHistoryTap,
  });

  final SensorReading reading;
  final AppPalette palette;
  final VoidCallback onTap;
  final String updatedLabel;
  final VoidCallback onHistoryTap;

  @override
  Widget build(BuildContext context) {
    final phStat = phStatus(reading.ph);
    final tempStat = temperatureStatus(reading.temperature);
    final doStat = dissolvedOxygenStatus(reading.dissolvedOxygen);
    final ammoniaStat = ammoniaStatus(reading.ammonia);
    final overallStatus = worstOf([phStat, tempStat, doStat, ammoniaStat]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Column(
            children: [
              StatusBanner(status: overallStatus),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    overallStatus == PondStatus.healthy ? 'View recommendations' : 'See what to do',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: palette.primary),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward_ios, size: 10, color: palette.primary),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Sensor Readings',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: palette.textPrimary),
        ),
        const SizedBox(height: 4),
        Text(
          'Updated as of $updatedLabel',
          style: TextStyle(fontSize: 13, color: palette.textSecondary),
        ),
        const SizedBox(height: 12),
        BatteryStatusRow(percent: reading.batteryPercent),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: SensorReadingCard(
                label: 'pH Level',
                value: reading.ph.toStringAsFixed(1),
                icon: Icons.science_outlined,
                status: phStat,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SensorReadingCard(
                label: 'Temperature',
                value: reading.temperature.toStringAsFixed(0),
                unit: '°C',
                icon: Icons.thermostat_outlined,
                status: tempStat,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: SensorReadingCard(
                label: 'DO',
                value: reading.dissolvedOxygen.toStringAsFixed(1),
                icon: Icons.bubble_chart_outlined,
                status: doStat,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SensorReadingCard(
                label: 'Ammonia',
                value: reading.ammonia.toStringAsFixed(2),
                icon: Icons.warning_amber_outlined,
                status: ammoniaStat,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Divider(height: 1, color: palette.divider),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: onHistoryTap,
          child: Text(
            'History',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: palette.textPrimary),
          ),
        ),
      ],
    );
  }
}
