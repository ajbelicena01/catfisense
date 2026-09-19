import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/pond_status.dart';
import '../utils/recommendations.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_header.dart';
import '../widgets/recommendation_card.dart';

/// Shows the farmer what to do, ranked by urgency, whenever a sensor reading
/// drifts into warning/critical territory. Reached from the Dashboard's
/// "Insights" nav icon (and by tapping the status banner) so the readings
/// shown here always match what the farmer just saw on the Dashboard.
class RecommendationsPage extends StatefulWidget {
  const RecommendationsPage({
    super.key,
    this.ph = 7.2,
    this.temperature = 27,
    this.dissolvedOxygen = 5.5,
    this.ammonia = 0.01,
  });

  final double ph;
  final double temperature;
  final double dissolvedOxygen;
  final double ammonia;

  @override
  State<RecommendationsPage> createState() => _RecommendationsPageState();
}

class _RecommendationsPageState extends State<RecommendationsPage> with SingleTickerProviderStateMixin {
  late final AnimationController _headerController;
  late final Animation<double> _headerFade;
  late final Animation<Offset> _headerSlide;

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(vsync: this, duration: const Duration(milliseconds: 450));
    _headerFade = CurvedAnimation(parent: _headerController, curve: Curves.easeOut);
    _headerSlide = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(parent: _headerController, curve: Curves.easeOutCubic));
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
    final palette = AppPalette.of(context);
    final recommendations = buildRecommendations(
      ph: widget.ph,
      temperature: widget.temperature,
      dissolvedOxygen: widget.dissolvedOxygen,
      ammonia: widget.ammonia,
    );
    // Already sorted critical-first by buildRecommendations.
    final overallStatus = recommendations.isEmpty ? PondStatus.healthy : recommendations.first.status;

    return Scaffold(
      backgroundColor: palette.background,
      drawer: const AppDrawer(),
      bottomNavigationBar: const AppBottomNav(current: BottomNavTab.insights),
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(),
            Expanded(
              child: SingleChildScrollView(
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
                        'What you should do',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: palette.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Sorted by urgency — handle critical items first.',
                        style: TextStyle(fontSize: 13, color: palette.textSecondary),
                      ),
                      const SizedBox(height: 16),
                      for (var i = 0; i < recommendations.length; i++)
                        RecommendationCard(recommendation: recommendations[i], index: i),
                    ],
                    const SizedBox(height: 4),
                    const _GeneralTipsCard(),
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

class _RecommendationsSummary extends StatelessWidget {
  const _RecommendationsSummary({required this.status, required this.issueCount});

  final PondStatus status;
  final int issueCount;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final style = styleFor(status);
    final plural = issueCount == 1 ? '' : 's';
    final (title, subtitle, icon) = switch (status) {
      PondStatus.healthy => (
          'No action needed',
          'All sensor readings are within the healthy range.',
          Icons.verified_outlined,
        ),
      PondStatus.warning => (
          '$issueCount parameter$plural need attention',
          'Take the steps below soon to keep the pond healthy.',
          Icons.lightbulb_outline,
        ),
      PondStatus.critical => (
          '$issueCount parameter$plural critical',
          'Act now — fish health may be at risk.',
          Icons.error_outline,
        ),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: style.color, width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: Icon(icon, color: style.color, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: style.color)),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: palette.isDark ? const Color(0xFF3A3A3A) : const Color(0xFF4A4A4A),
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
            'Pond conditions look great',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: palette.textPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            'No corrective action needed right now. Keep up the good care!',
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
                'General Pond Care Tips',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: palette.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...generalPondCareTips.map(
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
