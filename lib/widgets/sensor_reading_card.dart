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
    this.unit,
  });

  final String label;
  final String value;
  final String? unit;
  final IconData icon;
  final PondStatus status;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final style = styleFor(status);
    return Container(
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
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: style.color),
                ),
                if (unit != null)
                  TextSpan(
                    text: unit,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: style.color),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Icon(icon, color: palette.primary, size: 22),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: palette.textPrimary),
          ),
        ],
      ),
    );
  }
}
