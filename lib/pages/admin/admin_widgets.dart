import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class AdminSectionLabel extends StatelessWidget {
  const AdminSectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8, left: 4),
      child: Text(text, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: palette.textSecondary)),
    );
  }
}

class AdminCard extends StatelessWidget {
  const AdminCard({super.key, required this.child, this.padding = const EdgeInsets.all(16)});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.border),
      ),
      child: child,
    );
  }
}

/// A small coloured label such as "Online" or "Offline".
class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.text, required this.color, this.icon});

  final String text;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 14, color: color), const SizedBox(width: 4)],
          Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: color)),
        ],
      ),
    );
  }
}

/// A labelled number, laid out in rows of three on the health screen.
class AdminStat extends StatelessWidget {
  const AdminStat({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: palette.textPrimary),
        ),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 11, color: palette.textSecondary)),
      ],
    );
  }
}

/// Loading, error and empty states for a whole tab.
class AdminMessage extends StatelessWidget {
  const AdminMessage({super.key, required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
      child: Column(
        children: [
          Icon(icon, size: 40, color: palette.textSecondary),
          const SizedBox(height: 10),
          Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: palette.textSecondary)),
        ],
      ),
    );
  }
}

const adminOnlineColor = Color(0xFF16A34A);
const adminOfflineColor = Color(0xFFDC2626);
const adminUnknownColor = Color(0xFF6B7280);

/// "1.2 s" or "340 ms".
String delayLabel(Duration delay) {
  final ms = delay.inMilliseconds;
  return ms.abs() >= 1000 ? '${(ms / 1000).toStringAsFixed(1)} s' : '$ms ms';
}
