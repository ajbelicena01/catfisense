import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n.dart';
import '../models/sensor_reading.dart';
import '../services/sensor_repository.dart';
import '../services/threshold_controller.dart';
import '../theme/app_theme.dart';
import '../utils/pond_status.dart';
import '../utils/recommendations.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_header.dart';
import '../widgets/recommendation_card.dart';

/// Shows the farmer what to do, ranked by urgency, whenever a sensor reading
/// drifts into warning/critical territory. It follows the pond's latest
/// reading live, wherever it is opened from (Dashboard, bottom bar, menu).
class RecommendationsPage extends StatefulWidget {
  const RecommendationsPage({super.key, this.initialReading});

  /// The reading the caller is already showing, so the page opens without
  /// waiting for the database.
  final SensorReading? initialReading;

  @override
  State<RecommendationsPage> createState() => _RecommendationsPageState();
}

class _RecommendationsPageState extends State<RecommendationsPage> with SingleTickerProviderStateMixin {
  late final AnimationController _headerController;
  late final Animation<double> _headerFade;
  late final Animation<Offset> _headerSlide;
  late final Stream<SensorReading?> _latest = SensorRepository().latestReading();

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(vsync: this, duration: const Duration(milliseconds: 450));
    _headerFade = CurvedAnimation(parent: _headerController, curve: Curves.easeOut);
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _headerController, curve: Curves.easeOutCubic));
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _headerController.forward();
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Redraw when an admin changes the pond health ranges.
    context.watch<ThresholdController>();
    final palette = AppPalette.of(context);

    return Scaffold(
      backgroundColor: palette.background,
      drawer: const AppDrawer(),
      bottomNavigationBar: const AppBottomNav(current: BottomNavTab.insights),
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(),
            Expanded(
              child: StreamBuilder<SensorReading?>(
                stream: _latest,
                builder: (context, snapshot) {
                  final reading = snapshot.data ?? widget.initialReading;
                  if (reading == null) {
                    return snapshot.connectionState == ConnectionState.waiting
                        ? const Center(child: CircularProgressIndicator())
                        : _NoReadings(palette: palette);
                  }
                  return _content(context, reading);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _content(BuildContext context, SensorReading reading) {
    final palette = AppPalette.of(context);
    final recommendations = buildRecommendations(
      context.l10n,
      ph: reading.ph,
      temperature: reading.temperature,
      dissolvedOxygen: reading.dissolvedOxygen,
      ammonia: reading.ammonia,
    );
    // Already sorted critical-first by buildRecommendations.
    final overallStatus = recommendations.isEmpty ? PondStatus.healthy : recommendations.first.status;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeTransition(
            opacity: _headerFade,
            child: SlideTransition(
              position: _headerSlide,
              child: _RecommendationsSummary(status: overallStatus, issueCount: recommendations.length),
            ),
          ),
          const SizedBox(height: 20),
          if (recommendations.isEmpty)
            const _AllClearCard()
          else ...[
            Text(
              context.l10n.recWhatToDo,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: palette.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(context.l10n.recSortedByUrgency, style: TextStyle(fontSize: 13, color: palette.textSecondary)),
            const SizedBox(height: 16),
            for (var i = 0; i < recommendations.length; i++)
              RecommendationCard(recommendation: recommendations[i], index: i),
          ],
          const SizedBox(height: 4),
          const _GeneralTipsCard(),
        ],
      ),
    );
  }
}

/// Instead of advice, when the pond's sensor has not sent anything yet.
class _NoReadings extends StatelessWidget {
  const _NoReadings({required this.palette});

  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sensors_off_outlined, size: 44, color: palette.textSecondary),
          const SizedBox(height: 12),
          Text(
            context.l10n.dashboardNoReadingsTitle,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: palette.textPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            context.l10n.dashboardNoReadingsBody,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, height: 1.4, color: palette.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _RecommendationsSummary extends StatelessWidget {
  const _RecommendationsSummary({required this.status, required this.issueCount});

  final PondStatus status;
  final int issueCount;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final style = styleFor(status);
    final accent = statusAccent(status, darkMode: palette.isDark);
    final l10n = context.l10n;
    final (title, subtitle, icon) = switch (status) {
      PondStatus.healthy => (l10n.recNoActionTitle, l10n.recNoActionBody, Icons.verified_outlined),
      PondStatus.warning => (l10n.recWarningTitle(issueCount), l10n.recWarningBody, Icons.lightbulb_outline),
      PondStatus.critical => (l10n.recCriticalTitle(issueCount), l10n.recCriticalBody, Icons.error_outline),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: palette.isDark ? palette.surface : style.background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent, width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: palette.isDark ? palette.background : Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: accent, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: palette.isDark ? palette.textPrimary : accent,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: palette.isDark ? palette.textSecondary : const Color(0xFF4A4A4A),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AllClearCard extends StatefulWidget {
  const _AllClearCard();

  @override
  State<_AllClearCard> createState() => _AllClearCardState();
}

class _AllClearCardState extends State<_AllClearCard> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final style = styleFor(PondStatus.healthy);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        children: [
          ScaleTransition(
            scale: CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: style.background, shape: BoxShape.circle),
              child: Icon(Icons.check_rounded, color: style.color, size: 40),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            context.l10n.recAllClearTitle,
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: palette.textPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            context.l10n.recAllClearBody,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: palette.textSecondary, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _GeneralTipsCard extends StatelessWidget {
  const _GeneralTipsCard();

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: palette.isDark ? palette.primary.withValues(alpha: 0.12) : const Color(0xFFFFF7EC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: palette.isDark ? palette.primary.withValues(alpha: 0.4) : const Color(0xFFF6D9AE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: palette.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                context.l10n.recTipsTitle,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: palette.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...generalPondCareTips(context.l10n).map(
            (tip) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Icon(Icons.circle, size: 6, color: palette.primary),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(tip, style: TextStyle(fontSize: 13, color: palette.textSecondary, height: 1.4)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
