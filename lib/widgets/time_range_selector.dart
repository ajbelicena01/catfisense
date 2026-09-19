import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/sensor_history.dart';

class TimeRangeSelector extends StatelessWidget {
  const TimeRangeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
    required this.onCustomTap,
    this.customLabel,
  });

  final HistoryRange selected;
  final ValueChanged<HistoryRange> onChanged;
  final VoidCallback onCustomTap;

  /// Shown in place of "Custom" once a date range has been picked.
  final String? customLabel;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: palette.isDark ? kDarkBorder.withValues(alpha: 0.35) : const Color(0xFFF7E0C2),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          _option(context, 'Daily', HistoryRange.daily, onTap: () => onChanged(HistoryRange.daily)),
          _option(context, 'Weekly', HistoryRange.weekly, onTap: () => onChanged(HistoryRange.weekly)),
          _option(context, 'Monthly', HistoryRange.monthly, onTap: () => onChanged(HistoryRange.monthly)),
          _option(
            context,
            customLabel ?? 'Custom',
            HistoryRange.custom,
            onTap: onCustomTap,
          ),
        ],
      ),
    );
  }

  Widget _option(BuildContext context, String label, HistoryRange range, {required VoidCallback onTap}) {
    final palette = AppPalette.of(context);
    final isActive = selected == range;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive
                ? (palette.isDark ? palette.primary.withValues(alpha: 0.35) : const Color(0xFFF1C183))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: palette.textPrimary),
          ),
        ),
      ),
    );
  }
}
