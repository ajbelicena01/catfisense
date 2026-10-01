import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../services/sms_recipients_service.dart';
import '../theme/app_theme.dart';

/// The numbers the SMS gateway texts alerts to, with add and remove. Shown to
/// pond owners in Settings and to admins on each pond.
class SmsRecipientsCard extends StatefulWidget {
  const SmsRecipientsCard({super.key, required this.pondId});

  final String pondId;

  @override
  State<SmsRecipientsCard> createState() => _SmsRecipientsCardState();
}

class _SmsRecipientsCardState extends State<SmsRecipientsCard> {
  static const _service = SmsRecipientsService();
  late Stream<List<String>> _numbers = _service.watch(widget.pondId);

  @override
  void didUpdateWidget(SmsRecipientsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pondId != widget.pondId) _numbers = _service.watch(widget.pondId);
  }

  Future<void> _add() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final number = await showDialog<String>(context: context, builder: (_) => const _AddNumberDialog());
    if (number == null) return;
    final saved = await _service.add(widget.pondId, number);
    messenger.showSnackBar(SnackBar(content: Text(saved ? l10n.smsAdded : l10n.smsSaveError)));
  }

  Future<void> _remove(String number, {required bool isLast}) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.smsRemoveTitle),
        content: Text(
          isLast
              ? l10n.smsRemoveLastBody(SmsRecipientsService.display(number))
              : l10n.smsRemoveBody(SmsRecipientsService.display(number)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: Text(l10n.commonCancel)),
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: Text(l10n.membersRemove)),
        ],
      ),
    );
    if (confirmed != true) return;
    final removed = await _service.remove(widget.pondId, number);
    messenger.showSnackBar(SnackBar(content: Text(removed ? l10n.smsRemoved : l10n.smsSaveError)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = AppPalette.of(context);
    return StreamBuilder<List<String>>(
      stream: _numbers,
      builder: (context, snapshot) {
        final numbers = snapshot.data;
        return Container(
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: palette.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                child: Text(l10n.smsHint, style: TextStyle(fontSize: 12, height: 1.4, color: palette.textSecondary)),
              ),
              if (snapshot.hasError)
                ListTile(title: Text(l10n.loadError, style: TextStyle(color: palette.textSecondary)))
              else if (numbers == null)
                const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator()))
              else if (numbers.isEmpty)
                ListTile(
                  leading: Icon(Icons.warning_amber_rounded, color: palette.primary),
                  title: Text(l10n.smsNone, style: TextStyle(color: palette.textPrimary)),
                )
              else
                for (final number in numbers)
                  ListTile(
                    leading: Icon(Icons.sms_outlined, color: palette.primary),
                    title: Text(
                      SmsRecipientsService.display(number),
                      style: TextStyle(fontWeight: FontWeight.w700, color: palette.textPrimary),
                    ),
                    trailing: IconButton(
                      tooltip: l10n.membersRemove,
                      onPressed: () => _remove(number, isLast: numbers.length == 1),
                      icon: Icon(Icons.delete_outline, color: palette.textSecondary),
                    ),
                  ),
              Divider(height: 1, color: palette.divider),
              TextButton.icon(
                onPressed: _add,
                icon: const Icon(Icons.add),
                label: Text(l10n.smsAdd),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Asks for one phone number; returns it as +639XXXXXXXXX. Owns its text
/// field so nothing it uses is thrown away while it is still closing.
class _AddNumberDialog extends StatefulWidget {
  const _AddNumberDialog();

  @override
  State<_AddNumberDialog> createState() => _AddNumberDialogState();
}

class _AddNumberDialogState extends State<_AddNumberDialog> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop(SmsRecipientsService.normalize(_controller.text));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.smsAddTitle),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(labelText: l10n.fieldPhone, hintText: '09XX XXX XXXX'),
          validator: (value) => SmsRecipientsService.normalize(value ?? '') == null ? l10n.validatePhone : null,
          onFieldSubmitted: (_) => _submit(),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.commonCancel)),
        TextButton(onPressed: _submit, child: Text(l10n.smsAdd)),
      ],
    );
  }
}
