import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/pond_status.dart';

class SensorReadingCard extends StatelessWidget {
  const SensorReadingCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.status,
    required this.description,
    required this.pondImpact,
    required this.optimalRange,
    this.unit,
  });

  final String label;
  final String value;
  final String? unit;
  final IconData icon;
  final PondStatus status;
  final String description;
  final String pondImpact;
  final String optimalRange;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final style = styleFor(status);
    final accent = statusAccent(status, darkMode: palette.isDark);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showInfo(context, palette),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: palette.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: accent),
                ),
                if (unit != null)
                  TextSpan(
                    text: unit,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: accent),
                  ),
              ],
            ),
            textScaler: MediaQuery.textScalerOf(context),
          ),
          const SizedBox(height: 10),
          Icon(icon, color: palette.primary, size: 22),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: palette.textPrimary),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(style.icon, size: 16, color: accent),
              const SizedBox(width: 5),
              Text(
                style.shortLabel,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: palette.isDark ? palette.textSecondary : accent,
                ),
              ),
            ],
          ),
            ],
          ),
        ),
      ),
    );
  }

  void _showInfo(BuildContext context, AppPalette palette) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: palette.surface,
        title: Row(
          children: [
            Icon(icon, color: palette.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(color: palette.textPrimary, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _InfoSection(title: 'What it measures', body: description, palette: palette),
              const SizedBox(height: 16),
              _InfoSection(title: 'Why it matters', body: pondImpact, palette: palette),
              const SizedBox(height: 16),
              _InfoSection(title: 'Optimal range', body: optimalRange, palette: palette),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('CLOSE', style: TextStyle(color: palette.primary)),
          ),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.title, required this.body, required this.palette});

  final String title;
  final String body;
  final AppPalette palette;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.w700, color: palette.textPrimary)),
          const SizedBox(height: 4),
          Text(body, style: TextStyle(color: palette.textSecondary, height: 1.4)),
        ],
      );
}
