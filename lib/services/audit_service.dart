import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

import '../firebase_options.dart';

/// What happened. Stored as the name, so rename only with care: old entries
/// keep the old name (unknown names show as [AuditAction.other]).
enum AuditAction {
  thresholdsChanged,
  thresholdsReset,
  caretakerRemoved,
  ownerRemoved,
  codeChanged,
  pondAdded,
  pondRenamed,
  memberRenamed,
  maintenanceChanged,
  recipientAdded,
  recipientRemoved,
  logEntryDeleted,
  other;

  static AuditAction fromName(Object? name) =>
      AuditAction.values.where((action) => action.name == name).firstOrNull ?? AuditAction.other;
}

class AuditEntry {
  const AuditEntry({
    required this.id,
    required this.at,
    required this.byName,
    required this.action,
    this.pondId,
    this.target,
    this.details,
  });

  factory AuditEntry.fromMap(String id, Map<dynamic, dynamic> map) => AuditEntry(
    id: id,
    at: DateTime.fromMillisecondsSinceEpoch((map['at'] as num? ?? 0).toInt()),
    byName: map['byName'] as String? ?? '?',
    action: AuditAction.fromName(map['action']),
    pondId: map['pondId'] as String?,
    target: map['target'] as String?,
    details: map['details'] as String?,
  );

  final String id;
  final DateTime at;
  final String byName;
  final AuditAction action;
  final String? pondId;
  final String? target;
  final String? details;
}

/// The append-only change log at `auditLog/<pushId>`. Admins and pond owners
/// write to it when they change something; only admins can read it. The
/// rules refuse edits and deletions, so an entry, once written, stays.
class AuditService {
  const AuditService();

  static FirebaseDatabase get _database => FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: DefaultFirebaseOptions.currentPlatform.databaseURL,
  );

  static DatabaseReference get _ref => _database.ref('auditLog');

  /// Records a change. Never throws: a failed log entry must not undo or
  /// block the change itself.
  Future<void> log(AuditAction action, {String? pondId, String? target, String? details}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    // Admins log in as admin_<name>@…, farmers as <phone>@…: either way the
    // part before the @ is the readable name.
    final name = user.email?.split('@').first ?? user.uid;
    try {
      await _ref.push().set({
        'at': ServerValue.timestamp,
        'byUid': user.uid,
        'byName': name.length > 40 ? name.substring(0, 40) : name,
        'action': action.name,
        'pondId': ?pondId,
        'target': ?target,
        if (details != null) 'details': details.length > 500 ? details.substring(0, 500) : details,
      });
    } on FirebaseException {
      // Owners can only log about their own pond; nothing else to do.
    }
  }

  /// Newest first.
  Stream<List<AuditEntry>> recent({int limit = 200}) {
    return _ref.orderByChild('at').limitToLast(limit).onValue.map((event) {
      final data = event.snapshot.value;
      if (data is! Map) return const <AuditEntry>[];
      return [
        for (final MapEntry(:key, :value) in data.entries)
          if (value is Map) AuditEntry.fromMap(key as String, value),
      ]..sort((a, b) => b.at.compareTo(a.at));
    });
  }
}
