import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/l10n.dart';
import '../../models/sensor_reading.dart';
import '../../services/admin_service.dart';
import '../../services/pond_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/device_health.dart';
import '../../utils/maintenance.dart';
import '../../utils/pond_status.dart';
import '../../utils/time_format.dart';
import '../../widgets/maintenance_schedule_dialog.dart';
import '../../widgets/maintenance_widgets.dart';
import '../../widgets/rename_pond_dialog.dart';
import '../../widgets/sms_recipients_card.dart';
import 'admin_widgets.dart';

class AdminPondsTab extends StatefulWidget {
  const AdminPondsTab({super.key});

  @override
  State<AdminPondsTab> createState() => _AdminPondsTabState();
}

class _AdminPondsTabState extends State<AdminPondsTab> {
  static const _admin = AdminService();
  late final Stream<List<PondSummary>> _ponds = _admin.ponds();
  late final Stream<List<UserSummary>> _users = _admin.users();

  /// The pond shown below the picker; null means the first one.
  String? _selectedId;

  Future<void> _addPond(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final added = await showDialog<(String, String)>(context: context, builder: (_) => const _AddPondDialog());
    if (added == null) return;
    final (id, code) = added;
    setState(() => _selectedId = id);
    messenger.showSnackBar(
      SnackBar(content: Text(l10n.addPondAdded(PondService.formatCode(code))), duration: const Duration(seconds: 8)),
    );
  }

  Future<void> _pickPond(BuildContext context, List<PondSummary> ponds, Map<String, String?> phones) async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _PondPickerSheet(ponds: ponds, phones: phones, selectedId: _selectedId ?? ponds.first.id),
    );
    if (!context.mounted || picked == null) return;
    if (picked == _PondPickerSheet.addPond) {
      await _addPond(context);
    } else {
      setState(() => _selectedId = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return StreamBuilder<List<UserSummary>>(
      stream: _users,
      builder: (context, usersSnapshot) => StreamBuilder<List<PondSummary>>(
        stream: _ponds,
        builder: (context, snapshot) {
          final ponds = snapshot.data;
          final phones = {for (final user in usersSnapshot.data ?? const <UserSummary>[]) user.uid: user.phone};
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            children: [
              if (snapshot.hasError)
                AdminMessage(icon: Icons.cloud_off, text: l10n.loadError)
              else if (ponds == null)
                const Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator()))
              else if (ponds.isEmpty) ...[
                AdminMessage(icon: Icons.water_outlined, text: l10n.adminNoPonds),
                Center(
                  child: TextButton.icon(
                    onPressed: () => _addPond(context),
                    icon: const Icon(Icons.add),
                    label: Text(l10n.addPond),
                  ),
                ),
              ] else ...[
                // A pond that was just added may not have arrived yet.
                if (ponds.where((pond) => pond.id == _selectedId).firstOrNull ?? ponds.first case final pond) ...[
                  const SizedBox(height: 8),
                  _PondPickerField(pond: pond, phones: phones, onTap: () => _pickPond(context, ponds, phones)),
                  const SizedBox(height: 16),
                  // Keyed so a different pond starts with fresh cards.
                  _PondSection(key: ValueKey(pond.id), pond: pond, phones: phones),
                ],
              ],
            ],
          );
        },
      ),
    );
  }
}

class _PondSection extends StatelessWidget {
  const _PondSection({super.key, required this.pond, required this.phones});

  final PondSummary pond;

  /// Phone numbers from user profiles, for members who joined before phones
  /// were stored with the pond.
  final Map<String, String?> phones;

  String? _phoneOf(String uid) => pond.phones[uid] ?? phones[uid];

  /// "Mang Juan (09171234567)" when an admin named them, else the number.
  String _whoIs(String uid) {
    final name = pond.names[uid];
    final phone = _phoneOf(uid);
    if (name == null) return phone ?? uid;
    return phone == null ? name : '$name ($phone)';
  }

  Future<void> _changeCode(BuildContext context) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.membersChangeCodeTitle),
        content: Text(
          pond.code == null
              ? l10n.membersChangeCodeBodyUnknown
              : l10n.membersChangeCodeBody(PondService.formatCode(pond.code!)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: Text(l10n.commonCancel)),
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: Text(l10n.membersChangeCodeConfirm)),
        ],
      ),
    );
    if (confirmed != true) return;
    final code = await PondService().changeCode(pondId: pond.id, oldCode: pond.code);
    messenger.showSnackBar(
      SnackBar(
        content: Text(code == null ? l10n.membersChangeCodeError : l10n.membersNewCode(PondService.formatCode(code))),
      ),
    );
  }

  Future<void> _remove(BuildContext context, String uid, PondRole role) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final who = _whoIs(uid);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(role == PondRole.owner ? l10n.adminRemoveOwnerTitle : l10n.membersRemoveTitle),
        content: Text(role == PondRole.owner ? l10n.adminRemoveOwnerBody(who) : l10n.membersRemoveBody(who)),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: Text(l10n.commonCancel)),
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: Text(l10n.membersRemove)),
        ],
      ),
    );
    if (confirmed != true) return;
    final removed = await PondService().removeMemberAsAdmin(pondId: pond.id, uid: uid, role: role, label: who);
    messenger.showSnackBar(SnackBar(content: Text(removed ? l10n.adminMemberRemoved : l10n.membersRemoveError)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = AppPalette.of(context);

    Widget memberRow(String label, String? uid, PondRole role) => ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(role == PondRole.owner ? Icons.verified_user_outlined : Icons.badge_outlined, color: palette.primary),
      title: Text(
        uid == null ? l10n.adminSlotEmpty : [?pond.names[uid], _phoneOf(uid) ?? l10n.membersNoPhone].join(' · '),
        style: TextStyle(fontWeight: FontWeight.w700, color: uid == null ? palette.textSecondary : palette.textPrimary),
      ),
      subtitle: Text(label, style: TextStyle(color: palette.textSecondary)),
      trailing: uid == null
          ? null
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: l10n.memberRename,
                  onPressed: () => showRenameMemberDialog(
                    context,
                    pondId: pond.id,
                    uid: uid,
                    currentName: pond.names[uid],
                    phone: _phoneOf(uid),
                  ),
                  icon: Icon(Icons.edit_outlined, size: 20, color: palette.primary),
                ),
                TextButton(
                  onPressed: () => _remove(context, uid, role),
                  style: TextButton.styleFrom(foregroundColor: adminOfflineColor),
                  child: Text(l10n.membersRemove),
                ),
              ],
            ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AdminCard(
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
          child: Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.water_outlined, color: palette.primary),
                title: Text(pond.name, style: TextStyle(fontWeight: FontWeight.w700, color: palette.textPrimary)),
                subtitle: Text(l10n.pondNameLabel, style: TextStyle(color: palette.textSecondary)),
                trailing: IconButton(
                  tooltip: l10n.pondRename,
                  onPressed: () => showRenamePondDialog(context, pondId: pond.id, currentName: pond.name),
                  icon: Icon(Icons.edit_outlined, size: 20, color: palette.primary),
                ),
              ),
              Divider(height: 1, color: palette.divider),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.vpn_key_outlined, color: palette.primary),
                title: Text(
                  pond.code == null ? l10n.membersNoCode : PondService.formatCode(pond.code!),
                  style: TextStyle(fontWeight: FontWeight.w700, color: palette.textPrimary, letterSpacing: 1),
                ),
                subtitle: Text(l10n.pondCodeField, style: TextStyle(color: palette.textSecondary)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (pond.code != null)
                      IconButton(
                        tooltip: l10n.membersCopyCode,
                        onPressed: () async {
                          await Clipboard.setData(ClipboardData(text: PondService.formatCode(pond.code!)));
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.membersCodeCopied)));
                          }
                        },
                        icon: Icon(Icons.copy, size: 20, color: palette.primary),
                      ),
                    IconButton(
                      tooltip: l10n.membersChangeCode,
                      onPressed: () => _changeCode(context),
                      icon: Icon(Icons.autorenew, size: 20, color: palette.primary),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: palette.divider),
              memberRow(l10n.roleOwner, pond.ownerUid, PondRole.owner),
              Divider(height: 1, color: palette.divider),
              memberRow(l10n.roleCaretaker, pond.caretakerUid, PondRole.caretaker),
            ],
          ),
        ),
        const SizedBox(height: 10),
        _sectionTitle(l10n.adminSensorDevice, palette),
        _SensorDeviceCard(deviceId: pond.id),
        const SizedBox(height: 10),
        _sectionTitle(l10n.adminMaintenance, palette),
        AdminCard(
          padding: const EdgeInsets.fromLTRB(16, 4, 12, 4),
          child: Column(
            children: [
              for (final (index, record) in pond.maintenance.indexed) ...[
                if (index > 0) Divider(height: 1, color: palette.divider),
                _MaintenanceRow(record: record, pondId: pond.id),
              ],
            ],
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            l10n.smsTitle,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: palette.textSecondary),
          ),
        ),
        SmsRecipientsCard(pondId: pond.id),
      ],
    );
  }
}

Widget _sectionTitle(String text, AppPalette palette) => Padding(
  padding: const EdgeInsets.only(left: 4, bottom: 8),
  child: Text(text, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: palette.textSecondary)),
);

/// One maintenance task: its status and when it was last done. Tapping it
/// sets up or edits the schedule.
class _MaintenanceRow extends StatelessWidget {
  const _MaintenanceRow({required this.record, required this.pondId});

  final MaintenanceRecord record;
  final String pondId;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = AppPalette.of(context);
    final lastDone = record.lastDone;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      leading: Icon(maintenanceTaskIcon(record.task), color: palette.primary),
      title: Text(
        maintenanceTaskTitle(l10n, record.task),
        style: TextStyle(fontWeight: FontWeight.w700, color: palette.textPrimary),
      ),
      subtitle: lastDone == null
          ? Text(l10n.maintSetUp, style: TextStyle(color: palette.primary, fontWeight: FontWeight.w700))
          : Text(
              l10n.maintLastDone(dateLabel(l10n, lastDone), record.intervalDays),
              style: TextStyle(color: palette.textSecondary),
            ),
      trailing: MaintenanceStatusPill(record: record, now: DateTime.now()),
      onTap: () => showMaintenanceScheduleDialog(context, record: record, pondId: pondId),
    );
  }
}

/// Device ID (the key under `readings/`) and a name; returns the new
/// pond's join code.
class _AddPondDialog extends StatefulWidget {
  const _AddPondDialog();

  @override
  State<_AddPondDialog> createState() => _AddPondDialogState();
}

class _AddPondDialogState extends State<_AddPondDialog> {
  final _formKey = GlobalKey<FormState>();
  final _deviceId = TextEditingController();
  final _name = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _deviceId.dispose();
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    final result = await PondService().createPond(deviceId: _deviceId.text, name: _name.text);
    if (!mounted) return;
    if (result.code != null) {
      Navigator.of(context).pop((_deviceId.text.trim(), result.code!));
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
    final palette = AppPalette.of(context);
    return AlertDialog(
      title: Text(l10n.addPondTitle),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.addPondBody, style: TextStyle(fontSize: 13, color: palette.textSecondary)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _deviceId,
                autocorrect: false,
                enableSuggestions: false,
                decoration: InputDecoration(labelText: l10n.addPondDeviceId),
                validator: (value) =>
                    RegExp(r'^[A-Za-z0-9_-]{3,40}$').hasMatch(value?.trim() ?? '') ? null : l10n.addPondInvalidId,
              ),
              TextFormField(
                controller: _name,
                maxLength: PondService.maxNameLength,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(labelText: l10n.pondNameLabel),
                validator: (value) => PondService.validatePondName(l10n, value),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: _saving ? null : () => Navigator.of(context).pop(), child: Text(l10n.commonCancel)),
        TextButton(onPressed: _saving ? null : _save, child: Text(l10n.addPondCreate)),
      ],
    );
  }
}

/// The pond's sensor at a glance: online or offline, when it last reported,
/// and its latest values colored by the pond health ranges.
class _SensorDeviceCard extends StatefulWidget {
  const _SensorDeviceCard({required this.deviceId});

  final String deviceId;

  @override
  State<_SensorDeviceCard> createState() => _SensorDeviceCardState();
}

class _SensorDeviceCardState extends State<_SensorDeviceCard> {
  late Stream<SensorReading?> _latest = const AdminService().latestReading(widget.deviceId);

  // Keeps "online" and "2 min ago" current while no new reading arrives.
  Timer? _clock;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _clock = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void didUpdateWidget(_SensorDeviceCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.deviceId != widget.deviceId) _latest = const AdminService().latestReading(widget.deviceId);
  }

  @override
  void dispose() {
    _clock?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = AppPalette.of(context);
    return StreamBuilder<SensorReading?>(
      stream: _latest,
      builder: (context, snapshot) {
        final reading = snapshot.data;
        final loading = !snapshot.hasData && !snapshot.hasError && snapshot.connectionState == ConnectionState.waiting;
        final online = reading != null && _now.difference(reading.recordedAt) <= deviceOfflineAfter;
        return AdminCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  StatusPill(
                    text: loading ? l10n.commonChecking : (online ? l10n.healthOnline : l10n.healthOffline),
                    color: loading ? adminUnknownColor : (online ? adminOnlineColor : adminOfflineColor),
                    icon: online ? Icons.sensors : Icons.sensors_off,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      snapshot.hasError
                          ? l10n.loadError
                          : reading == null
                          ? (loading ? '' : l10n.dashboardNoReadingsTitle)
                          : l10n.healthLastReading(timeAgo(l10n, reading.recordedAt, _now)),
                      style: TextStyle(fontSize: 13, color: palette.textPrimary),
                    ),
                  ),
                ],
              ),
              if (reading != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    _ReadingValue(label: 'pH', value: reading.ph.toStringAsFixed(2), status: phStatus(reading.ph)),
                    _ReadingValue(
                      label: l10n.chartTemperature,
                      value: '${reading.temperature.toStringAsFixed(1)} °C',
                      status: temperatureStatus(reading.temperature),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _ReadingValue(
                      label: l10n.chartOxygenTitle,
                      value: '${reading.dissolvedOxygen.toStringAsFixed(2)} mg/L',
                      status: dissolvedOxygenStatus(reading.dissolvedOxygen),
                    ),
                    _ReadingValue(
                      label: l10n.chartAmmoniaTitle,
                      value: '${reading.ammonia.toStringAsFixed(3)} mg/L',
                      status: ammoniaStatus(reading.ammonia),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  [
                    dateTimeLabel(l10n, reading.recordedAt),
                    if (reading.batteryPercent != null) '${l10n.batteryLabel}: ${reading.batteryPercent}%',
                  ].join(' · '),
                  style: TextStyle(fontSize: 12, color: palette.textSecondary),
                ),
              ],
              const SizedBox(height: 4),
              SelectableText(
                '${l10n.addPondDeviceId}: ${widget.deviceId}',
                style: TextStyle(fontSize: 11, color: palette.textSecondary),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// One reading in the sensor card: name, value, and its status color.
class _ReadingValue extends StatelessWidget {
  const _ReadingValue({required this.label, required this.value, required this.status});

  final String label;
  final String value;
  final PondStatus status;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final color = statusAccent(status, darkMode: palette.isDark);
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: palette.textSecondary)),
          const SizedBox(height: 2),
          Row(
            children: [
              Icon(Icons.circle, size: 8, color: color),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  value,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: palette.textPrimary),
                ),
              ),
            ],
          ),
          Text(statusShortLabel(context.l10n, status), style: TextStyle(fontSize: 11, color: color)),
        ],
      ),
    );
  }
}

/// "Owner: Mang Juan" / "Owner: 09171234567" / "Owner: Empty".
String _ownerLine(AppLocalizations l10n, PondSummary pond, Map<String, String?> phones) {
  final uid = pond.ownerUid;
  final who = uid == null ? l10n.adminSlotEmpty : (pond.names[uid] ?? pond.phones[uid] ?? phones[uid] ?? uid);
  return '${l10n.roleOwner}: $who';
}

/// Shows the selected pond; tapping it opens [_PondPickerSheet].
class _PondPickerField extends StatelessWidget {
  const _PondPickerField({required this.pond, required this.phones, required this.onTap});

  final PondSummary pond;
  final Map<String, String?> phones;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = AppPalette.of(context);
    return Material(
      color: palette.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: palette.primary.withValues(alpha: 0.5), width: 1.2),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: palette.primary.withValues(alpha: 0.15),
                child: Icon(Icons.water_outlined, color: palette.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pond.name,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: palette.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${pond.id} · ${_ownerLine(l10n, pond, phones)}',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: palette.textSecondary),
                    ),
                  ],
                ),
              ),
              Icon(Icons.unfold_more_rounded, color: palette.primary),
            ],
          ),
        ),
      ),
    );
  }
}

/// Search box on top, the matching ponds, and "Add pond" at the bottom.
/// Returns the chosen pond's ID, or [addPond].
class _PondPickerSheet extends StatefulWidget {
  const _PondPickerSheet({required this.ponds, required this.phones, required this.selectedId});

  /// Can't be a pond ID ("+" isn't allowed in one).
  static const addPond = '+add';

  final List<PondSummary> ponds;
  final Map<String, String?> phones;
  final String selectedId;

  @override
  State<_PondPickerSheet> createState() => _PondPickerSheetState();
}

class _PondPickerSheetState extends State<_PondPickerSheet> {
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = AppPalette.of(context);
    final matches = [
      for (final pond in widget.ponds)
        if (pondMatchesSearch(pond, _query, userPhones: widget.phones)) pond,
    ];
    return Padding(
      // Keeps the list above the keyboard while searching.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.75),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.adminChoosePond,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: palette.textPrimary),
                    ),
                  ),
                  Text(
                    l10n.adminPondCount(widget.ponds.length),
                    style: TextStyle(fontSize: 12, color: palette.textSecondary),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _search,
                textInputAction: TextInputAction.search,
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(
                  hintText: l10n.adminPondSearchHint,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => setState(() {
                            _search.clear();
                            _query = '';
                          }),
                        ),
                  isDense: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: matches.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        l10n.adminNoPondMatch,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: palette.textSecondary),
                      ),
                    )
                  : ListView(
                      shrinkWrap: true,
                      children: [
                        for (final pond in matches)
                          ListTile(
                            leading: Icon(Icons.water_outlined, color: palette.primary),
                            title: Text(
                              pond.name,
                              style: TextStyle(fontWeight: FontWeight.w700, color: palette.textPrimary),
                            ),
                            subtitle: Text(
                              '${pond.id} · ${_ownerLine(l10n, pond, widget.phones)}',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: palette.textSecondary),
                            ),
                            trailing: pond.id == widget.selectedId ? Icon(Icons.check, color: palette.primary) : null,
                            onTap: () => Navigator.of(context).pop(pond.id),
                          ),
                      ],
                    ),
            ),
            Divider(height: 1, color: palette.divider),
            SafeArea(
              top: false,
              child: ListTile(
                leading: Icon(Icons.add_circle_outline, color: palette.primary),
                title: Text(l10n.addPond, style: TextStyle(fontWeight: FontWeight.w700, color: palette.primary)),
                onTap: () => Navigator.of(context).pop(_PondPickerSheet.addPond),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
