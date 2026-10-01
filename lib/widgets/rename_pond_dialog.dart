import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../services/pond_service.dart';

/// Asks for a new pond name and saves it. Used by the owner's Settings and
/// the admin Ponds tab.
Future<void> showRenamePondDialog(BuildContext context, {required String pondId, String? currentName}) async {
  final l10n = context.l10n;
  await _showNameDialog(
    context,
    title: l10n.pondRename,
    label: l10n.pondNameLabel,
    currentName: currentName,
    validator: (value) => PondService.validatePondName(l10n, value),
    save: (name) => PondService().renamePond(pondId: pondId, name: name, oldName: currentName),
    errorText: l10n.pondNameError,
    savedText: l10n.pondNameSaved,
  );
}

/// Admin only: the name shown for a pond member instead of their phone
/// number ([phone], also what the audit log shows). Blank clears it.
Future<void> showRenameMemberDialog(
  BuildContext context, {
  required String pondId,
  required String uid,
  String? currentName,
  String? phone,
}) async {
  final l10n = context.l10n;
  await _showNameDialog(
    context,
    title: l10n.memberRename,
    label: l10n.memberNameLabel,
    helper: l10n.memberRenameHint,
    currentName: currentName,
    validator: (value) => PondService.normalizeName(value ?? '').length > PondService.maxNameLength
        ? l10n.pondNameTooLong(PondService.maxNameLength)
        : null,
    save: (name) => PondService().setMemberName(pondId: pondId, uid: uid, name: name, oldName: currentName, label: phone),
    errorText: l10n.memberNameError,
    savedText: l10n.memberNameSaved,
    // A cleared name is stored as no name at all.
    unchanged: (name) => name == (currentName ?? ''),
  );
}

Future<void> _showNameDialog(
  BuildContext context, {
  required String title,
  required String label,
  String? helper,
  String? currentName,
  required FormFieldValidator<String> validator,
  required Future<bool> Function(String name) save,
  required String errorText,
  required String savedText,
  bool Function(String name)? unchanged,
}) async {
  final saved = await showDialog<bool>(
    context: context,
    builder: (_) => _NameDialog(
      title: title,
      label: label,
      helper: helper,
      currentName: currentName,
      validator: validator,
      save: save,
      errorText: errorText,
      unchanged: unchanged ?? (name) => name == currentName,
    ),
  );
  if (saved == true && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(savedText)));
  }
}

class _NameDialog extends StatefulWidget {
  const _NameDialog({
    required this.title,
    required this.label,
    required this.currentName,
    required this.validator,
    required this.save,
    required this.errorText,
    required this.unchanged,
    this.helper,
  });

  final String title;
  final String label;
  final String? helper;
  final String? currentName;
  final FormFieldValidator<String> validator;
  final Future<bool> Function(String name) save;
  final String errorText;
  final bool Function(String name) unchanged;

  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.currentName);
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final name = PondService.normalizeName(_name.text);
    if (widget.unchanged(name)) {
      Navigator.of(context).pop(false);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final saved = await widget.save(name);
    if (!mounted) return;
    if (saved) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _saving = false;
        _error = widget.errorText;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _name,
              autofocus: true,
              maxLength: PondService.maxNameLength,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(labelText: widget.label, helperText: widget.helper, helperMaxLines: 3),
              validator: widget.validator,
              onFieldSubmitted: (_) => _saving ? null : _save(),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: _saving ? null : () => Navigator.of(context).pop(false), child: Text(l10n.commonCancel)),
        TextButton(onPressed: _saving ? null : _save, child: Text(l10n.commonSave)),
      ],
    );
  }
}
