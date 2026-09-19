import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/pond_status.dart';

/// The IoT device's own power level — shown as its own slim row rather than
/// a 5th sensor card, since it's device health, not water-quality data.
class BatteryStatusRow extends StatelessWidget {
  const BatteryStatusRow({super.key, required this.percent});

  /// Null when the device hasn't reported a battery level (e.g. an older
  /// reading written before this field existed) — renders nothing.
  final int? percent;

  @override
  Widget build(BuildContext context) {
    final value = percent;
    if (value == null) return const SizedBox.shrink();

    final palette = AppPalette.of(context);
    final status = batteryStatus(value);
    final style = styleFor(status);
    final icon = switch (status) {
      PondStatus.healthy => Icons.battery_full,
      PondStatus.warning => Icons.battery_3_bar,
      PondStatus.critical => Icons.battery_alert,
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: style.color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Device Battery',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: palette.textPrimary),
            ),
          ),
          Text('$value%', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: style.color)),
        ],
      ),
    );
  }
}
