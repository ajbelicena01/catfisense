import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../services/auth_service.dart';
import '../services/language_controller.dart';
import '../utils/validators.dart';

String languageName(AppLocalizations l10n, String? code) => switch (code) {
  'en' => 'English',
  'fil' => 'Filipino',
  _ => l10n.settingsLanguageSystem,
};

Future<void> pickLanguage(BuildContext context, LanguageController language) async {
  final l10n = context.l10n;
  // Wrapped in a record so "phone default" (null) differs from a dismissed dialog.
  final picked = await showDialog<(String?,)>(
    context: context,
    builder: (dialogContext) => SimpleDialog(
      title: Text(l10n.settingsLanguage),
      children: [
        for (final code in [null, ...LanguageController.supportedCodes])
          SimpleDialogOption(
            onPressed: () => Navigator.of(dialogContext).pop((code,)),
            child: Row(
              children: [
                Expanded(child: Text(languageName(l10n, code))),
                if (language.languageCode == code) const Icon(Icons.check, size: 20),
              ],
            ),
          ),
      ],
    ),
  );
  if (picked != null) await language.setLanguage(picked.$1);
}

/// Current password, new password twice. Used by admins, whose accounts
/// start with a password the team handed out.
Future<void> showChangePasswordDialog(BuildContext context) async {
  final changed = await showDialog<bool>(context: context, builder: (_) => const _ChangePasswordDialog());
  if (changed == true && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.passwordChanged)));
  }
}

class _ChangePasswordDialog extends StatefulWidget {
  const _ChangePasswordDialog();

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    final result = await AuthService().updatePassword(currentPassword: _current.text, newPassword: _next.text);
    if (!mounted) return;
    if (result.success) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _saving = false;
        _error = result.error!.message(context.l10n);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.passwordChangeTitle),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _current,
                obscureText: true,
                decoration: InputDecoration(labelText: l10n.passwordCurrent),
                validator: (value) => (value ?? '').isEmpty ? l10n.loginPasswordRequired : null,
              ),
              TextFormField(
                controller: _next,
                obscureText: true,
                decoration: InputDecoration(labelText: l10n.passwordNew),
                validator: (value) => validatePassword(l10n, value),
              ),
              TextFormField(
                controller: _confirm,
                obscureText: true,
                decoration: InputDecoration(labelText: l10n.signupConfirmPassword),
                validator: (value) => value != _next.text ? l10n.signupPasswordsMismatch : null,
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: _saving ? null : () => Navigator.of(context).pop(false), child: Text(l10n.commonCancel)),
        TextButton(onPressed: _saving ? null : _save, child: Text(l10n.passwordSave)),
      ],
    );
  }
}
