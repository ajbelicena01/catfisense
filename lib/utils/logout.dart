import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../services/auth_service.dart';

/// Asks for confirmation, signs out, and returns to the first route, where
/// [AuthGate] switches to the welcome screen.
Future<void> confirmAndLogout(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(context.l10n.logoutTitle),
      content: Text(context.l10n.logoutBody),
      actions: [
        TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: Text(context.l10n.commonCancel)),
        TextButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: Text(context.l10n.logoutConfirm)),
      ],
    ),
  );
  if (confirmed != true) return;
  await AuthService().signOut();
  if (context.mounted) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}
