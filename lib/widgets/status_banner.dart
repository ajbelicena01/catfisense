import 'package:flutter/material.dart';

import '../utils/pond_status.dart';

/// The pond-health banner. Driven entirely by [status] so the dashboard can
/// swap colors/text in place instead of navigating to a different screen
/// per health state.
class StatusBanner extends StatefulWidget {
  const StatusBanner({super.key, required this.status});

  final PondStatus status;

  @override
  State<StatusBanner> createState() => _StatusBannerState();
}

class _StatusBannerState extends State<StatusBanner> with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = styleFor(widget.status);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: style.color, width: 1.2),
      ),
      child: Column(
        children: [
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 400),
            style: TextStyle(color: style.color, fontSize: 16, fontWeight: FontWeight.w700),
            child: Text(style.label),
          ),
          const SizedBox(height: 10),
          ScaleTransition(
            scale: Tween(begin: 0.85, end: 1.15)
                .animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut)),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              width: 14,
              height: 14,
              decoration: BoxDecoration(color: style.dotColor, shape: BoxShape.circle),
            ),
          ),
        ],
      ),
    );
  }
}
