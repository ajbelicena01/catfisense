import '../l10n/app_localizations.dart';

/// Upkeep the pond setup needs on a schedule. The names are stored in the
/// database and checked by the rules, so rename only together with
/// database.rules.json.
enum MaintenanceTask {
  doElectrolyte,
  phBuffer,
  modemLoad,
  gsmLoad;

  /// Probe upkeep is roughly every 3 months; prepaid load usually lasts a
  /// month. Each pond can change these.
  int get defaultIntervalDays => switch (this) {
    MaintenanceTask.doElectrolyte || MaintenanceTask.phBuffer => 90,
    MaintenanceTask.modemLoad || MaintenanceTask.gsmLoad => 30,
  };

  static MaintenanceTask? fromName(Object? name) =>
      MaintenanceTask.values.where((task) => task.name == name).firstOrNull;
}

enum MaintenanceState { notSet, ok, dueSoon, overdue }

const maxMaintenanceIntervalDays = 365;

/// The last time a task was done and how often it repeats, from
/// `ponds/<pondId>/maintenance/<task>`.
class MaintenanceRecord {
  const MaintenanceRecord({required this.task, required this.intervalDays, this.lastDone, this.note});

  const MaintenanceRecord.notSet(this.task) : intervalDays = 0, lastDone = null, note = null;

  /// Null when the stored value is unusable, so the task shows as not set.
  static MaintenanceRecord? fromMap(MaintenanceTask task, Object? value) {
    if (value is! Map) return null;
    final lastDone = value['lastDone'];
    final interval = value['intervalDays'];
    if (lastDone is! num || interval is! num || interval < 1) return null;
    return MaintenanceRecord(
      task: task,
      lastDone: DateTime.fromMillisecondsSinceEpoch(lastDone.toInt()),
      intervalDays: interval.toInt(),
      note: value['note'] as String?,
    );
  }

  final MaintenanceTask task;
  final DateTime? lastDone;
  final int intervalDays;
  final String? note;

  /// The day it is next due (midnight, local time).
  DateTime? get dueOn {
    final done = lastDone;
    if (done == null) return null;
    return DateTime(done.year, done.month, done.day + intervalDays);
  }

  /// How many days ahead of the due day the reminder starts.
  int get remindDaysBefore => intervalDays >= 60 ? 7 : 3;

  /// Calendar days from [now]'s day to the due day: 0 is today, negative
  /// is overdue.
  int? daysLeft(DateTime now) {
    final due = dueOn;
    if (due == null) return null;
    // Compared as UTC dates so a daylight-saving change can't skew the count.
    return DateTime.utc(due.year, due.month, due.day).difference(DateTime.utc(now.year, now.month, now.day)).inDays;
  }

  MaintenanceState stateAt(DateTime now) {
    final left = daysLeft(now);
    if (left == null) return MaintenanceState.notSet;
    if (left < 0) return MaintenanceState.overdue;
    if (left <= remindDaysBefore) return MaintenanceState.dueSoon;
    return MaintenanceState.ok;
  }
}

/// All four tasks, in [MaintenanceTask] order, from the pond's
/// `maintenance` map; missing ones are [MaintenanceRecord.notSet].
List<MaintenanceRecord> maintenanceRecords(Object? data) => [
  for (final task in MaintenanceTask.values)
    (data is Map ? MaintenanceRecord.fromMap(task, data[task.name]) : null) ?? MaintenanceRecord.notSet(task),
];

/// Tasks due soon or overdue, most urgent first.
List<MaintenanceRecord> needingAttention(List<MaintenanceRecord> records, DateTime now) => [
  for (final record in records)
    if (record.stateAt(now) case MaintenanceState.dueSoon || MaintenanceState.overdue) record,
]..sort((a, b) => a.daysLeft(now)!.compareTo(b.daysLeft(now)!));

String maintenanceTaskTitle(AppLocalizations l10n, MaintenanceTask task) => switch (task) {
  MaintenanceTask.doElectrolyte => l10n.maintTaskDoElectrolyte,
  MaintenanceTask.phBuffer => l10n.maintTaskPhBuffer,
  MaintenanceTask.modemLoad => l10n.maintTaskModemLoad,
  MaintenanceTask.gsmLoad => l10n.maintTaskGsmLoad,
};

/// What the logbook shows once the task is done.
String maintenanceDoneLabel(AppLocalizations l10n, MaintenanceTask task) => switch (task) {
  MaintenanceTask.doElectrolyte => l10n.maintDoneDoElectrolyte,
  MaintenanceTask.phBuffer => l10n.maintDonePhBuffer,
  MaintenanceTask.modemLoad => l10n.maintDoneModemLoad,
  MaintenanceTask.gsmLoad => l10n.maintDoneGsmLoad,
};

/// "Due in 5 days", "Due today", "3 days overdue", or "Not set up".
String maintenanceStatusText(AppLocalizations l10n, MaintenanceRecord record, DateTime now) {
  final left = record.daysLeft(now);
  if (left == null) return l10n.maintStatusNotSet;
  return left < 0 ? l10n.maintOverdueBy(-left) : l10n.maintDueIn(left);
}
