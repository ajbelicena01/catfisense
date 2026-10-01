import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

import '../firebase_options.dart';
import '../utils/maintenance.dart';
import 'audit_service.dart';
import 'pond_service.dart';
import 'sensor_repository.dart';

/// What was done at the pond. The names are stored in the database and
/// checked by the rules, so rename only together with database.rules.json.
enum LogType {
  feeding,
  waterChange,
  aerator,
  treatment,

  /// Added by the Maintenance page, with [LogEntry.task] saying which one.
  maintenance,
  other;

  static LogType fromName(Object? name) =>
      LogType.values.where((type) => type.name == name).firstOrNull ?? LogType.other;
}

class LogEntry {
  const LogEntry({
    required this.id,
    required this.type,
    required this.at,
    required this.byUid,
    this.note,
    this.byPhone,
    this.byRole,
    this.task,
  });

  factory LogEntry.fromMap(String id, Map<dynamic, dynamic> map) {
    return LogEntry(
      id: id,
      type: LogType.fromName(map['type']),
      at: DateTime.fromMillisecondsSinceEpoch((map['at'] as num).toInt()),
      byUid: map['byUid'] as String? ?? '',
      note: map['note'] as String?,
      byPhone: map['byPhone'] as String?,
      byRole: PondRole.fromName(map['byRole']),
      task: MaintenanceTask.fromName(map['task']),
    );
  }

  final String id;
  final LogType type;
  final DateTime at;
  final String byUid;
  final String? note;
  final String? byPhone;
  final PondRole? byRole;

  /// Which maintenance was done, for [LogType.maintenance] entries.
  final MaintenanceTask? task;
}

/// The pond logbook at `ponds/<pondId>/logs/<pushId>`. Any member can add
/// entries; members can delete their own, and the owner can delete any.
class LogbookService {
  LogbookService({FirebaseAuth? auth, FirebaseDatabase? database})
    : _authOverride = auth,
      _databaseOverride = database;

  final FirebaseAuth? _authOverride;
  final FirebaseDatabase? _databaseOverride;

  // The logbook belongs to the same pond as the readings (see
  // SensorRepository.deviceId).
  static String get pondId => SensorRepository.deviceId;

  static const maxNoteLength = 200;

  FirebaseAuth get _auth => _authOverride ?? FirebaseAuth.instance;

  // See SensorRepository: point at the RTDB URL explicitly on Android.
  FirebaseDatabase get _database =>
      _databaseOverride ??
      FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: DefaultFirebaseOptions.currentPlatform.databaseURL,
      );

  DatabaseReference get _logsRef => _database.ref('ponds/$pondId/logs');

  String? get currentUid => _auth.currentUser?.uid;

  /// Live entries with [LogEntry.at] in [start, end], newest first.
  Stream<List<LogEntry>> entries({required DateTime start, DateTime? end}) {
    var query = _logsRef.orderByChild('at').startAt(start.millisecondsSinceEpoch);
    if (end != null) query = query.endAt(end.millisecondsSinceEpoch);
    return query.onValue.map((event) {
      final data = event.snapshot.value;
      if (data is! Map) return const <LogEntry>[];
      return [
        for (final MapEntry(:key, :value) in data.entries)
          if (value is Map && value['at'] is num) LogEntry.fromMap(key as String, value),
      ]..sort((a, b) => b.at.compareTo(a.at));
    });
  }

  /// Adds an entry; [at] null means "now" (the server's clock). Returns
  /// whether it was saved.
  Future<bool> add({required LogType type, required PondRole role, String? note, DateTime? at}) async {
    final user = _auth.currentUser;
    if (user == null) return false;
    final phone = user.email?.split('@').first;
    final trimmed = note?.trim();
    try {
      await _logsRef.push().set({
        'type': type.name,
        'at': at?.millisecondsSinceEpoch ?? ServerValue.timestamp,
        'byUid': user.uid,
        'byRole': role.name,
        'byPhone': ?phone,
        if (trimmed != null && trimmed.isNotEmpty) 'note': trimmed,
      });
      return true;
    } on FirebaseException {
      return false;
    }
  }

  /// Returns whether the entry was deleted. Deleting someone else's entry
  /// (an owner or admin tidying up) is recorded in the audit log.
  Future<bool> delete(LogEntry entry) async {
    try {
      await _logsRef.child(entry.id).remove();
      if (entry.byUid != currentUid) {
        await const AuditService().log(
          AuditAction.logEntryDeleted,
          pondId: pondId,
          target: '${entry.type.name} @ ${entry.at.toIso8601String()}',
          details: entry.note,
        );
      }
      return true;
    } on FirebaseException {
      return false;
    }
  }
}
