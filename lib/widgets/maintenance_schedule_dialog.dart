import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/l10n.dart';
import '../services/maintenance_service.dart';
import '../services/pond_service.dart';
import '../theme/app_theme.dart';
import '../utils/maintenance.dart';
import '../utils/time_format.dart';

/// "Mark done" ([markDone], defaults to today and goes in the logbook as
/// [role]) or setting up / editing [record]'s schedule. Changing a schedule
/// that is already set up asks for confirmation first. Admins pass no
/// [role] and never mark done.
Future<void> showMaintenanceScheduleDialog(
  BuildContext context, {
  required MaintenanceRecord record,
  required String pondId,
  PondRole? role,
  bool markDone = false,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  final l10n = context.l10n;
  final saved = await showDialog<bool>(
    context: context,
    builder: (_) => _ScheduleDialog(record: record, pondId: pondId, role: role, markDone: markDone),
  );
  if (saved == true) messenger.showSnackBar(SnackBar(content: Text(l10n.maintSaved)));
}

class _ScheduleDialog extends StatefulWidget {
  const _ScheduleDialog({required this.record, required this.pondId, required this.role, required this.markDone});

  final MaintenanceRecord record;
  final String pondId;
  final PondRole? role;
  final bool markDone;

  @override
  State<_ScheduleDialog> createState() => _ScheduleDialogState();
}

class _ScheduleDialogState extends State<_ScheduleDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _interval = TextEditingController(
    text: '${widget.record.lastDone == null ? widget.record.task.defaultIntervalDays : widget.record.intervalDays}',
  );
  late final _note = TextEditingController(text: widget.markDone ? '' : widget.record.note);
  late DateTime _doneOn = DateUtils.dateOnly(
    widget.markDone ? DateTime.now() : widget.record.lastDone ?? DateTime.now(),
  );
  bool _saving = false;
  String? _error;

  bool get _isLoad => widget.record.task == MaintenanceTask.modemLoad || widget.record.task == MaintenanceTask.gsmLoad;

  @override
  void dispose() {
    _interval.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: _doneOn,
      // The database keeps dates up to a year back.
      firstDate: today.subtract(const Duration(days: 364)),
      lastDate: today,
    );
    if (picked != null) setState(() => _doneOn = picked);
  }

  /// What editing an existing schedule would change, one line each; empty
  /// when nothing would.
  List<String> _changes(AppLocalizations l10n, int interval, String note) {
    final record = widget.record;
    final lastDone = record.lastDone;
    if (lastDone == null) return const [];
    final oldNote = record.note ?? '';
    return [
      if (!DateUtils.isSameDay(lastDone, _doneOn))
        l10n.maintChangeLastDone(dateLabel(l10n, lastDone), dateLabel(l10n, _doneOn)),
      if (interval != record.intervalDays) l10n.maintChangeInterval(record.intervalDays, interval),
      if (note != oldNote) l10n.maintChangeNote(oldNote.isEmpty ? '-' : oldNote, note.isEmpty ? '-' : note),
    ];
  }

  Future<bool> _confirm(AppLocalizations l10n, List<String> changes) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.maintConfirmTitle),
        content: Text(
          [l10n.maintConfirmBody(maintenanceTaskTitle(l10n, widget.record.task)), '', ...changes.map((c) => '• $c')]
              .join('\n'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: Text(l10n.commonCancel)),
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: Text(l10n.maintConfirmYes)),
        ],
      ),
    );
    return confirmed == true;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = context.l10n;
    final interval = int.parse(_interval.text.trim());
    final note = _note.text.trim();

    // Editing a schedule that is already set up: say what changes first.
    if (!widget.markDone && widget.record.lastDone != null) {
      final changes = _changes(l10n, interval, note);
      if (changes.isEmpty) {
        Navigator.of(context).pop(false);
        return;
      }
      if (!await _confirm(l10n, changes) || !mounted) return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });
    final saved = await MaintenanceService().save(
      pondId: widget.pondId,
      task: widget.record.task,
      doneOn: _doneOn,
      intervalDays: interval,
      note: note,
      role: widget.markDone ? widget.role : null,
      previous: widget.record,
    );
    if (!mounted) return;
    if (saved) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _saving = false;
        _error = l10n.maintSaveError;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = AppPalette.of(context);
    return AlertDialog(
      title: Text(maintenanceTaskTitle(l10n, widget.record.task)),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.event, color: palette.primary),
                title: Text(widget.markDone ? l10n.maintDoneOn : l10n.maintLastDoneOn),
                subtitle: Text(dateLabel(l10n, _doneOn)),
                trailing: Icon(Icons.edit_outlined, color: palette.textSecondary, size: 20),
                onTap: _saving ? null : _pickDate,
              ),
              TextFormField(
                controller: _interval,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(labelText: l10n.maintEvery),
                validator: (value) {
                  final days = int.tryParse(value?.trim() ?? '');
                  return days == null || days < 1 || days > maxMaintenanceIntervalDays
                      ? l10n.maintEveryInvalid(maxMaintenanceIntervalDays)
                      : null;
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _note,
                maxLength: MaintenanceService.maxNoteLength,
                minLines: 1,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: l10n.logbookNoteLabel,
                  hintText: _isLoad ? l10n.maintNoteHintLoad : l10n.maintNoteHintProbe,
                ),
              ),
              if (widget.markDone)
                Text(l10n.maintLogNote, style: TextStyle(fontSize: 12, color: palette.textSecondary)),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: _saving ? null : () => Navigator.of(context).pop(false), child: Text(l10n.commonCancel)),
        TextButton(
          onPressed: _saving ? null : _save,
          child: Text(widget.markDone ? l10n.maintMarkDone : l10n.commonSave),
        ),
      ],
    );
  }
}
