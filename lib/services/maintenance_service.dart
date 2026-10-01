import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

import '../firebase_options.dart';
import '../utils/maintenance.dart';
import 'audit_service.dart';
import 'logbook_service.dart';
import 'pond_service.dart';

/// The pond's upkeep schedule at `ponds/<pondId>/maintenance/<task>`:
/// `{lastDone, intervalDays, byUid, updatedAt, note?}`. Any member or admin
/// can update it.
class MaintenanceService {
  MaintenanceService({FirebaseAuth? auth, FirebaseDatabase? database})
    : _authOverride = auth,
      _databaseOverride = database;

  final FirebaseAuth? _authOverride;
  final FirebaseDatabase? _databaseOverride;

  static const maxNoteLength = 200;

  FirebaseAuth get _auth => _authOverride ?? FirebaseAuth.instance;

  // See SensorRepository: point at the RTDB URL explicitly on Android.
  FirebaseDatabase get _database =>
      _databaseOverride ??
      FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: DefaultFirebaseOptions.currentPlatform.databaseURL,
      );

  /// All four tasks, live.
  Stream<List<MaintenanceRecord>> watch(String pondId) =>
      _database.ref('ponds/$pondId/maintenance').onValue.map((event) => maintenanceRecords(event.snapshot.value));

  /// Records that [task] was done on [doneOn] and should repeat every
  /// [intervalDays]. With [role] (the caller's pond role), it also goes in
  /// the logbook, as long as [doneOn] is recent enough for the logbook's
  /// 30-day window. Without [role] (setting up or editing the schedule, or
  /// an admin), the change goes in the audit log instead, compared with
  /// [previous]. Returns whether it saved.
  Future<bool> save({
    required String pondId,
    required MaintenanceTask task,
    required DateTime doneOn,
    required int intervalDays,
    String? note,
    PondRole? role,
    MaintenanceRecord? previous,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return false;
    final now = DateTime.now();
    final isToday = doneOn.year == now.year && doneOn.month == now.month && doneOn.day == now.day;
    // Today means "just now" (the server's clock); an earlier day is kept
    // at noon so time zones can't move it to a neighbouring date.
    final Object at = isToday
        ? ServerValue.timestamp
        : DateTime(doneOn.year, doneOn.month, doneOn.day, 12).millisecondsSinceEpoch;
    final trimmed = note?.trim();
    final text = trimmed == null || trimmed.isEmpty ? null : trimmed;
    final logged = role != null && now.difference(doneOn) < const Duration(days: 29);
    final logs = _database.ref('ponds/$pondId/logs');

    try {
      await _database.ref().update({
        'ponds/$pondId/maintenance/${task.name}': {
          'lastDone': at,
          'intervalDays': intervalDays,
          'byUid': user.uid,
          'updatedAt': ServerValue.timestamp,
          'note': ?text,
        },
        if (logged)
          'ponds/$pondId/logs/${logs.push().key}': {
            'type': LogType.maintenance.name,
            'task': task.name,
            'at': at,
            'byUid': user.uid,
            'byRole': role.name,
            'byPhone': ?user.email?.split('@').first,
            'note': ?text,
          },
      });
      if (role == null) {
        String day(DateTime? d) => d == null ? '-' : '${d.year}-${d.month}-${d.day}';
        final before = previous?.lastDone == null ? '-' : '${day(previous!.lastDone)} / ${previous.intervalDays}d';
        await const AuditService().log(
          AuditAction.maintenanceChanged,
          pondId: pondId,
          target: task.name,
          details: '$before -> ${day(doneOn)} / ${intervalDays}d',
        );
      }
      return true;
    } on FirebaseException {
      return false;
    }
  }
}
