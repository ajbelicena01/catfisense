import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n.dart';
import '../models/sensor_reading.dart';
import '../services/alert_preferences.dart';
import '../services/notification_service.dart';
import '../services/sensor_repository.dart';
import '../services/threshold_controller.dart';
import '../theme/app_theme.dart';
import '../utils/pond_status.dart';
import '../utils/sensor_history.dart';
import '../utils/slide_page_route.dart';
import '../utils/thresholds.dart';
import '../utils/time_format.dart';
import '../widgets/alert_consent_dialog.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_header.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/data_freshness_banner.dart';
import '../widgets/maintenance_widgets.dart';
import '../widgets/phi_history_chart.dart';
import '../widgets/sensor_reading_card.dart';
import '../widgets/status_banner.dart';
import 'alerts_page.dart';
import 'history_page.dart';
import 'recommendations_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _sensorRepository = SensorRepository();
  late final Stream<List<SensorHistoryPoint>> _phiHistoryStream;

  SensorReading? _latest;
  StreamSubscription<SensorReading?>? _readingSubscription;

  // Ticks so "Updated 3 min ago" and the sensor-offline banner stay current
  // while the page is open, even when no new readings arrive.
  Timer? _clock;
  DateTime _now = DateTime.now();

  // Tracks the last status we actually notified about, so an ongoing
  // warning/critical condition doesn't re-notify on every new reading —
  // only on a transition (e.g. healthy -> warning, or warning -> critical).
  PondStatus _lastNotifiedStatus = PondStatus.healthy;

  @override
  void initState() {
    super.initState();
    _phiHistoryStream = watchHistory(
      HistoryRange.daily,
      repository: _sensorRepository,
    );
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _maybeShowAlertConsent(),
    );
    // Live-listens to readings/pond1 in Realtime Database. This is the
    // ESP32's actual data feed. The refresh button only fetches the latest
    // RTDB record; it never creates a simulated reading.
    // Signing out or leaving the pond ends this with a permission error;
    // the app has already moved on by then, so it is ignored.
    _readingSubscription = _sensorRepository.latestReading().listen(_onReading, onError: (Object _) {});
    _clock = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _clock?.cancel();
    _readingSubscription?.cancel();
    super.dispose();
  }

  void _onReading(SensorReading? reading) {
    if (!mounted || reading == null) return;
    setState(() {
      _latest = reading;
      _now = DateTime.now();
    });
    _checkForAlert(reading);
    if (context.read<AlertPreferences>().pushEnabled) {
      NotificationService.instance.showPersistentMonitoring(
        body: context.l10n.monitoringLatest(
          reading.ph.toStringAsFixed(1),
          reading.temperature.toStringAsFixed(0),
          reading.dissolvedOxygen.toStringAsFixed(1),
        ),
      );
    }
  }

  void _checkForAlert(SensorReading reading) {
    final overallStatus = worstOf([
      phStatus(reading.ph),
      temperatureStatus(reading.temperature),
      dissolvedOxygenStatus(reading.dissolvedOxygen),
      ammoniaStatus(reading.ammonia),
    ]);
    if (overallStatus != PondStatus.healthy &&
        overallStatus != _lastNotifiedStatus) {
      if (context.read<AlertPreferences>().pushEnabled) {
        NotificationService.instance.showPondAlert(overallStatus);
      }
    }
    _lastNotifiedStatus = overallStatus;
  }

  Future<void> _maybeShowAlertConsent() async {
    if (!mounted) return;
    final prefs = context.read<AlertPreferences>();
    final l10n = context.l10n;
    if (prefs.hasShownConsent) {
      // Already decided before; just keep the OS permission in sync with
      // their saved choice (calling this is a no-op once already granted).
      if (prefs.pushEnabled) {
        final granted = await prefs.requestNotificationPermission();
        if (granted) {
          await NotificationService.instance.showPersistentMonitoring(
            body: _latest == null ? l10n.monitoringWaiting : l10n.monitoringActive,
          );
        }
      }
      return;
    }
    if (!mounted) return;
    await showAlertConsentDialog(context);
  }

  void _openRecommendations() {
    final reading = _latest;
    if (reading == null) return;
    Navigator.of(context).push(
      slidePageRoute(
        RecommendationsPage(initialReading: reading),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Redraw when an admin changes the pond health ranges.
    context.watch<ThresholdController>();
    final palette = AppPalette.of(context);
    final l10n = AppLocalizations.of(context);
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
                child: Column(
                  children: [
                    DataFreshnessBanner(lastReadingAt: reading?.recordedAt, now: _now),
                    MaintenanceBanner(now: _now),
                    if (reading == null)
                      _EmptyState(palette: palette)
                    else
                      _Loaded(
                        reading: reading,
                        palette: palette,
                        onTap: _openRecommendations,
                        updatedLabel: l10n.freshnessUpdated(timeAgo(l10n, reading.recordedAt, _now)),
                        phiHistoryStream: _phiHistoryStream,
                        onHistoryTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const HistoryPage(),
                          ),
                        ),
                      ),
                  ],
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
          Icon(
            Icons.sensors_off_outlined,
            size: 48,
            color: palette.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.dashboardNoReadingsTitle,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: palette.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            context.l10n.dashboardNoReadingsBody,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: palette.textSecondary,
              height: 1.4,
            ),
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
    required this.phiHistoryStream,
    required this.onHistoryTap,
  });

  final SensorReading reading;
  final AppPalette palette;
  final VoidCallback onTap;
  final String updatedLabel;
  final Stream<List<SensorHistoryPoint>> phiHistoryStream;
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
                    overallStatus == PondStatus.healthy
                        ? context.l10n.dashboardViewRecommendations
                        : context.l10n.dashboardSeeWhatToDo,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: palette.isDark ? palette.textPrimary : palette.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 10,
                    color: palette.isDark ? palette.textSecondary : palette.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          context.l10n.dashboardSensorReadings,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: palette.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          updatedLabel,
          style: TextStyle(fontSize: 13, color: palette.textSecondary),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: SensorReadingCard(
                label: context.l10n.cardPhLabel,
                value: reading.ph.toStringAsFixed(1),
                icon: Icons.science_outlined,
                status: phStat,
                description: context.l10n.cardPhDescription,
                pondImpact: context.l10n.cardPhImpact,
                optimalRange: healthyRangeText(Thresholds.current.ph, unit: 'pH'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SensorReadingCard(
                label: context.l10n.paramTemperature,
                value: reading.temperature.toStringAsFixed(0),
                unit: '°C',
                icon: Icons.thermostat_outlined,
                status: tempStat,
                description: context.l10n.cardTemperatureDescription,
                pondImpact: context.l10n.cardTemperatureImpact,
                optimalRange: healthyRangeText(Thresholds.current.temperature, unit: '°C'),
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
                description: context.l10n.cardOxygenDescription,
                pondImpact: context.l10n.cardOxygenImpact,
                optimalRange: healthyRangeText(Thresholds.current.dissolvedOxygen, unit: 'mg/L'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SensorReadingCard(
                label: context.l10n.paramAmmonia,
                value: reading.ammonia.toStringAsFixed(2),
                icon: Icons.warning_amber_outlined,
                status: ammoniaStat,
                description: context.l10n.cardAmmoniaDescription,
                pondImpact: context.l10n.cardAmmoniaImpact,
                optimalRange: healthyRangeText(Thresholds.current.ammonia, unit: 'mg/L'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          context.l10n.dashboardPhiTrend,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: palette.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          context.l10n.dashboardPhiSubtitle,
          style: TextStyle(fontSize: 13, color: palette.textSecondary),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: palette.isDark ? palette.border : palette.primary),
          ),
          child: StreamBuilder<List<SensorHistoryPoint>>(
            stream: phiHistoryStream,
            builder: (context, snapshot) {
              final points = snapshot.data ?? const <SensorHistoryPoint>[];
              if (!snapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 42),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (points.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Text(
                      context.l10n.dashboardPhiEmpty,
                      style: TextStyle(fontSize: 13, color: palette.textSecondary),
                    ),
                  ),
                );
              }
              return PhiHistoryChart(
                points: points,
                range: HistoryRange.daily,
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        Divider(height: 1, color: palette.divider),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: onHistoryTap,
          child: Text(
            context.l10n.dashboardViewAllReadings,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: palette.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AlertsPage())),
          child: Text(
            context.l10n.alertsLink,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: palette.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
