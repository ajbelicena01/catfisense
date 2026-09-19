import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/alert_preferences.dart';
import '../theme/app_theme.dart';
import 'themed_action_button.dart';

/// Shown once, the first time a signed-in user reaches the Dashboard. Lets
/// the farmer confirm they want push + SMS alerts (both default on) before
/// the app actually requests the OS notification permission.
Future<void> showAlertConsentDialog(BuildContext context) async {
  final prefs = context.read<AlertPreferences>();
  var pushChecked = prefs.pushEnabled;
  var smsChecked = prefs.smsEnabled;

  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      final palette = AppPalette.of(dialogContext);
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            backgroundColor: palette.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.notifications_active_outlined, color: palette.primary, size: 36),
                  const SizedBox(height: 16),
                  Text(
                    'Stay on top of your pond',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: palette.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "CatFiSense can alert you the moment a reading turns risky. Choose how you'd like to hear about it — you can change this anytime in Settings.",
                    style: TextStyle(fontSize: 13, color: palette.textSecondary, height: 1.4),
                  ),
                  const SizedBox(height: 20),
                  _ConsentSwitchRow(
                    icon: Icons.notifications_outlined,
                    label: 'Push notifications',
                    value: pushChecked,
                    palette: palette,
                    onChanged: (value) => setState(() => pushChecked = value),
                  ),
                  const SizedBox(height: 4),
                  _ConsentSwitchRow(
                    icon: Icons.sms_outlined,
                    label: 'SMS alerts',
                    value: smsChecked,
                    palette: palette,
                    onChanged: (value) => setState(() => smsChecked = value),
                  ),
                  const SizedBox(height: 24),
                  ThemedFilledButton(
                    label: 'CONTINUE',
                    onPressed: () async {
                      await prefs.setPushEnabled(pushChecked);
                      await prefs.setSmsEnabled(smsChecked);
                      await prefs.markConsentShown();
                      if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

class _ConsentSwitchRow extends StatelessWidget {
  const _ConsentSwitchRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.palette,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final bool value;
  final AppPalette palette;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: palette.textSecondary, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: palette.textPrimary)),
        ),
        Switch(value: value, activeThumbColor: palette.primary, onChanged: onChanged),
      ],
    );
  }
}
