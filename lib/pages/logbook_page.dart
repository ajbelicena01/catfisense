import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/logbook_service.dart';
import '../services/pond_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/maintenance.dart';
import '../utils/time_format.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_header.dart';

/// How far back the logbook list goes (the rules also refuse older times).
const _logbookWindow = Duration(days: 30);

IconData logTypeIcon(LogType type) => switch (type) {
  LogType.feeding => Icons.set_meal_outlined,
  LogType.waterChange => Icons.water_drop_outlined,
  LogType.aerator => Icons.air,
  LogType.treatment => Icons.science_outlined,
  LogType.maintenance => Icons.build_outlined,
  LogType.other => Icons.edit_note,
};

String logTypeLabel(AppLocalizations l10n, LogType type) => switch (type) {
  LogType.feeding => l10n.logTypeFeeding,
  LogType.waterChange => l10n.logTypeWaterChange,
  LogType.aerator => l10n.logTypeAerator,
  LogType.treatment => l10n.logTypeTreatment,
  LogType.maintenance => l10n.logTypeMaintenance,
  LogType.other => l10n.logTypeOther,
};

/// The entry's type, or for maintenance which task was done.
String logEntryLabel(AppLocalizations l10n, LogEntry entry) => switch (entry.task) {
  final task? when entry.type == LogType.maintenance => maintenanceDoneLabel(l10n, task),
  _ => logTypeLabel(l10n, entry.type),
};

class LogbookPage extends StatefulWidget {
  const LogbookPage({super.key});

  @override
  State<LogbookPage> createState() => _LogbookPageState();
}

class _LogbookPageState extends State<LogbookPage> {
  final _logbook = LogbookService();
  late final Stream<List<LogEntry>> _entries = _logbook.entries(
    start: DateTime.now().subtract(_logbookWindow),
  );
  late final Stream<PondMembership?> _membership;

  @override
  void initState() {
    super.initState();
    final uid = _logbook.currentUid;
    _membership = uid == null ? Stream.value(null) : PondService().membership(uid);
  }

  Future<void> _openAddSheet(PondRole role) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppPalette.of(context).surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _AddEntrySheet(logbook: _logbook, role: role),
    );
    if (saved == true) messenger.showSnackBar(SnackBar(content: Text(l10n.logbookSaved)));
  }

  Future<void> _confirmDelete(LogEntry entry) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.logbookDeleteConfirmTitle),
        content: Text(l10n.logbookDeleteConfirmBody),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: Text(l10n.commonCancel)),
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: Text(l10n.logbookDelete)),
        ],
      ),
    );
    if (confirmed != true) return;
    final deleted = await _logbook.delete(entry);
    messenger.showSnackBar(SnackBar(content: Text(deleted ? l10n.logbookDeleted : l10n.logbookDeleteError)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = AppPalette.of(context);

    return StreamBuilder<PondMembership?>(
      stream: _membership,
      builder: (context, membershipSnapshot) {
        final role = membershipSnapshot.data?.role;
        return Scaffold(
          backgroundColor: palette.background,
          drawer: const AppDrawer(),
          bottomNavigationBar: const AppBottomNav(current: null),
          floatingActionButton: role == null
              ? null
              : FloatingActionButton.extended(
                  onPressed: () => _openAddSheet(role),
                  backgroundColor: kBrandOrange,
                  foregroundColor: Colors.white,
                  icon: const Icon(Icons.add),
                  label: Text(l10n.logbookAdd, style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
          body: SafeArea(
            child: Column(
              children: [
                const AppHeader(),
                Expanded(
                  child: StreamBuilder<List<LogEntry>>(
                    stream: _entries,
                    builder: (context, snapshot) {
                      final entries = snapshot.data;
                      return ListView(
                        // Room at the bottom so the button never covers the last entry.
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                        children: [
                          Text(
                            l10n.logbookTitle,
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: palette.textPrimary),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.logbookSubtitle,
                            style: TextStyle(fontSize: 13, height: 1.4, color: palette.textSecondary),
                          ),
                          const SizedBox(height: 16),
                          if (snapshot.hasError)
                            _Empty(icon: Icons.cloud_off, text: l10n.loadError)
                          else if (entries == null)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 48),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          else if (entries.isEmpty)
                            _Empty(icon: Icons.menu_book_outlined, title: l10n.logbookEmptyTitle, text: l10n.logbookEmptyBody)
                          else
                            ..._grouped(context, entries, role),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _grouped(BuildContext context, List<LogEntry> entries, PondRole? role) {
    final l10n = AppLocalizations.of(context);
    final palette = AppPalette.of(context);
    final uid = _logbook.currentUid;
    final widgets = <Widget>[];
    DateTime? day;
    for (final entry in entries) {
      final entryDay = DateUtils.dateOnly(entry.at);
      if (entryDay != day) {
        day = entryDay;
        widgets.add(
          Padding(
            padding: EdgeInsets.only(top: widgets.isEmpty ? 0 : 12, bottom: 8, left: 4),
            child: Text(
              dayLabel(l10n, entryDay),
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: palette.textSecondary),
            ),
          ),
        );
      }
      final canDelete = entry.byUid == uid || role == PondRole.owner;
      widgets.add(
        _EntryTile(
          entry: entry,
          isMine: entry.byUid == uid,
          onDelete: canDelete ? () => _confirmDelete(entry) : null,
        ),
      );
      widgets.add(const SizedBox(height: 8));
    }
    return widgets;
  }
}

/// "Today", "Yesterday", or the date.
String dayLabel(AppLocalizations l10n, DateTime day) {
  final today = DateUtils.dateOnly(DateTime.now());
  if (day == today) return l10n.dayToday;
  if (day == today.subtract(const Duration(days: 1))) return l10n.dayYesterday;
  return dateLabel(l10n, day);
}

class _EntryTile extends StatelessWidget {
  const _EntryTile({required this.entry, required this.isMine, this.onDelete});

  final LogEntry entry;
  final bool isMine;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = AppPalette.of(context);
    final by = isMine
        ? l10n.logbookByYou
        : switch (entry.byRole) {
            PondRole.owner => l10n.logbookByOwner,
            PondRole.caretaker => l10n.logbookByCaretaker,
            null => null,
          };

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 4, 12),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: palette.primary.withValues(alpha: 0.15),
            child: Icon(logTypeIcon(entry.type), color: palette.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  logEntryLabel(l10n, entry),
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: palette.textPrimary),
                ),
                if (entry.note != null) ...[
                  const SizedBox(height: 2),
                  Text(entry.note!, style: TextStyle(fontSize: 13, color: palette.textPrimary)),
                ],
                const SizedBox(height: 4),
                Text(
                  [timeLabel(l10n, entry.at), ?by].join(' · '),
                  style: TextStyle(fontSize: 12, color: palette.textSecondary),
                ),
              ],
            ),
          ),
          if (onDelete != null)
            IconButton(
              tooltip: l10n.logbookDelete,
              onPressed: onDelete,
              icon: Icon(Icons.delete_outline, color: palette.textSecondary, size: 20),
            ),
        ],
      ),
    );
  }
}

class _AddEntrySheet extends StatefulWidget {
  const _AddEntrySheet({required this.logbook, required this.role});

  final LogbookService logbook;
  final PondRole role;

  @override
  State<_AddEntrySheet> createState() => _AddEntrySheetState();
}

class _AddEntrySheetState extends State<_AddEntrySheet> {
  final _noteController = TextEditingController();
  LogType _type = LogType.feeding;

  /// Null means "now".
  DateTime? _at;
  bool _saving = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_at ?? DateTime.now()));
    if (picked == null) return;
    final now = DateTime.now();
    final at = DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
    // Only earlier today: a time later than now would be in the future.
    setState(() => _at = at.isAfter(now) ? null : at);
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _saving = true);
    final saved = await widget.logbook.add(type: _type, role: widget.role, note: _noteController.text, at: _at);
    if (!mounted) return;
    setState(() => _saving = false);
    if (saved) {
      navigator.pop(true);
    } else {
      messenger.showSnackBar(SnackBar(content: Text(l10n.logbookSaveError)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = AppPalette.of(context);
    return Padding(
      // Lift the sheet above the keyboard while the note is being typed.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.logbookAdd,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: palette.textPrimary),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  // Maintenance entries come from the Maintenance page.
                  for (final type in LogType.values.where((type) => type != LogType.maintenance))
                    ChoiceChip(
                      avatar: Icon(logTypeIcon(type), size: 18),
                      label: Text(logTypeLabel(l10n, type)),
                      selected: _type == type,
                      onSelected: (_) => setState(() => _type = type),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _noteController,
                maxLength: LogbookService.maxNoteLength,
                minLines: 1,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: l10n.logbookNoteLabel,
                  hintText: l10n.logbookNoteHint,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 4),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.schedule, color: palette.primary),
                title: Text(l10n.logbookWhen, style: TextStyle(color: palette.textPrimary)),
                subtitle: Text(
                  _at == null ? l10n.logbookNow : l10n.logbookTodayAt(timeLabel(l10n, _at!)),
                  style: TextStyle(color: palette.textSecondary),
                ),
                trailing: Icon(Icons.edit_outlined, color: palette.textSecondary, size: 20),
                onTap: _pickTime,
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kBrandOrange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                        )
                      : Text(l10n.logbookSave, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.icon, required this.text, this.title});

  final IconData icon;
  final String? title;
  final String text;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
      child: Column(
        children: [
          Icon(icon, size: 44, color: palette.textSecondary),
          const SizedBox(height: 12),
          if (title != null) ...[
            Text(
              title!,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: palette.textPrimary),
            ),
            const SizedBox(height: 4),
          ],
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, height: 1.4, color: palette.textSecondary),
          ),
        ],
      ),
    );
  }
}
