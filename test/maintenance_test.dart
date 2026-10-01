import 'package:catfisense/l10n/app_localizations.dart';
import 'package:catfisense/utils/maintenance.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

MaintenanceRecord _record(MaintenanceTask task, DateTime lastDone, int days) =>
    MaintenanceRecord(task: task, lastDone: lastDone, intervalDays: days);

void main() {
  final now = DateTime(2026, 9, 30, 15);
  final l10n = lookupAppLocalizations(const Locale('en'));

  test('due date is the interval after the day it was done', () {
    final record = _record(MaintenanceTask.doElectrolyte, DateTime(2026, 7, 2, 18, 30), 90);
    expect(record.dueOn, DateTime(2026, 9, 30));
    expect(record.daysLeft(now), 0);
    expect(maintenanceStatusText(l10n, record, now), 'Due today');
  });

  test('states: fine, due soon, overdue, not set', () {
    // 90-day tasks warn a week ahead, 30-day ones 3 days ahead.
    expect(_record(MaintenanceTask.phBuffer, DateTime(2026, 7, 15), 90).stateAt(now), MaintenanceState.ok);
    expect(_record(MaintenanceTask.phBuffer, DateTime(2026, 7, 8), 90).stateAt(now), MaintenanceState.dueSoon);
    expect(_record(MaintenanceTask.modemLoad, DateTime(2026, 9, 5), 30).stateAt(now), MaintenanceState.ok);
    expect(_record(MaintenanceTask.modemLoad, DateTime(2026, 9, 3), 30).stateAt(now), MaintenanceState.dueSoon);
    expect(_record(MaintenanceTask.gsmLoad, DateTime(2026, 8, 20), 30).stateAt(now), MaintenanceState.overdue);
    expect(const MaintenanceRecord.notSet(MaintenanceTask.gsmLoad).stateAt(now), MaintenanceState.notSet);
  });

  test('status text', () {
    expect(maintenanceStatusText(l10n, _record(MaintenanceTask.gsmLoad, DateTime(2026, 8, 20), 30), now), '11 days overdue');
    expect(maintenanceStatusText(l10n, _record(MaintenanceTask.gsmLoad, DateTime(2026, 9, 1), 30), now), 'Due tomorrow');
    expect(maintenanceStatusText(l10n, const MaintenanceRecord.notSet(MaintenanceTask.gsmLoad), now), 'Not set up');
  });

  test('reads the database map, skipping unusable values', () {
    final records = maintenanceRecords({
      'doElectrolyte': {'lastDone': DateTime(2026, 9, 1).millisecondsSinceEpoch, 'intervalDays': 90, 'note': 'new bottle'},
      'phBuffer': {'lastDone': 'yesterday', 'intervalDays': 90},
      'modemLoad': {'lastDone': 1, 'intervalDays': 0},
    });
    expect(records.map((r) => r.task), MaintenanceTask.values);
    expect(records[0].dueOn, DateTime(2026, 11, 30));
    expect(records[0].note, 'new bottle');
    expect(records.skip(1).every((r) => r.lastDone == null), isTrue);
    expect(maintenanceRecords(null).every((r) => r.stateAt(now) == MaintenanceState.notSet), isTrue);
  });

  test('attention list is most urgent first and skips fine tasks', () {
    final due = needingAttention([
      _record(MaintenanceTask.doElectrolyte, DateTime(2026, 7, 15), 90),
      _record(MaintenanceTask.modemLoad, DateTime(2026, 9, 2), 30),
      _record(MaintenanceTask.gsmLoad, DateTime(2026, 8, 20), 30),
      const MaintenanceRecord.notSet(MaintenanceTask.phBuffer),
    ], now);
    expect(due.map((r) => r.task), [MaintenanceTask.gsmLoad, MaintenanceTask.modemLoad]);
  });
}
