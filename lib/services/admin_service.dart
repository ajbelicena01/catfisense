import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

import '../firebase_options.dart';
import '../models/sensor_reading.dart';
import '../utils/device_health.dart';
import '../utils/maintenance.dart';
import 'pond_service.dart';

class AdminProfile {
  const AdminProfile({required this.uid, required this.username});

  final String uid;
  final String username;
}

class PondSummary {
  const PondSummary({
    required this.id,
    required this.name,
    this.code,
    this.ownerUid,
    this.caretakerUid,
    this.phones = const {},
    this.maintenance = const [],
    this.names = const {},
  });

  factory PondSummary.fromMap(String id, Map<dynamic, dynamic> map) {
    final phones = map['memberPhones'];
    final names = map['memberNames'];
    return PondSummary(
      id: id,
      name: map['name'] as String? ?? id,
      code: map['code'] as String?,
      ownerUid: map['ownerUid'] as String?,
      caretakerUid: map['caretakerUid'] as String?,
      phones: phones is Map ? {for (final e in phones.entries) e.key as String: e.value.toString()} : const {},
      maintenance: maintenanceRecords(map['maintenance']),
      names: names is Map ? {for (final e in names.entries) e.key as String: e.value.toString()} : const {},
    );
  }

  final String id;
  final String name;
  final String? code;
  final String? ownerUid;
  final String? caretakerUid;

  /// Phone numbers members stored when joining (older joins may lack one).
  final Map<String, String> phones;

  /// Upkeep schedule, one record per [MaintenanceTask].
  final List<MaintenanceRecord> maintenance;

  /// Names admins gave members, shown instead of their phone numbers.
  final Map<String, String> names;
}

class UserSummary {
  const UserSummary({required this.uid, this.phone, this.createdAt, this.pondId});

  final String uid;
  final String? phone;
  final DateTime? createdAt;
  final String? pondId;
}

class SmsQueueEntry {
  const SmsQueueEntry({required this.status, this.createdAt, this.error});

  final String status;
  final DateTime? createdAt;
  final String? error;
}

/// Read access for the admin screens. The database rules only allow these
/// reads for accounts listed under `admins/`.
class AdminService {
  const AdminService();

  static FirebaseDatabase get _database => FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: DefaultFirebaseOptions.currentPlatform.databaseURL,
  );

  static DateTime? _time(Object? value) => value is num ? DateTime.fromMillisecondsSinceEpoch(value.toInt()) : null;

  /// Live values of [query], converted by [convert]. Every listener gets its
  /// own database listener (and so the current value straight away), so a
  /// widget that is rebuilt, or scrolled out of a list and back, can listen
  /// again; a plain `onValue` stream can only be listened to once.
  static Stream<T> _watch<T>(Query query, T Function(Object? value) convert) => Stream.multi((controller) {
    final sub = query.onValue.listen(
      (event) => controller.add(convert(event.snapshot.value)),
      onError: controller.addError,
      onDone: controller.close,
    );
    controller.onCancel = sub.cancel;
  });

  /// Whether [uid] is an admin. Anyone may read their own entry.
  Stream<bool> isAdmin(String uid) => _watch(_database.ref('admins/$uid'), (value) => value != null);

  Stream<List<AdminProfile>> admins() => _watch(_database.ref('admins'), (data) {
    if (data is! Map) return const <AdminProfile>[];
    return [
      for (final MapEntry(:key, :value) in data.entries)
        AdminProfile(uid: key as String, username: value is Map ? value['username'] as String? ?? key : key),
    ]..sort((a, b) => a.username.compareTo(b.username));
  });

  Stream<List<PondSummary>> ponds() => _watch(_database.ref('ponds'), (data) {
    if (data is! Map) return const <PondSummary>[];
    return [
      for (final MapEntry(:key, :value) in data.entries)
        if (value is Map) PondSummary.fromMap(key as String, value),
    ]..sort((a, b) => a.id.compareTo(b.id));
  });

  Stream<List<UserSummary>> users() => _watch(_database.ref('users'), (data) {
    if (data is! Map) return const <UserSummary>[];
    return [
      for (final MapEntry(:key, :value) in data.entries)
        if (value is Map && value['phone'] is String)
          UserSummary(
            uid: key as String,
            phone: value['phone'] as String,
            createdAt: _time(value['createdAt']),
            pondId: value['pondId'] as String?,
          ),
    ]..sort((a, b) => (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)));
  });

  /// The newest reading from [deviceId], live; null before its first one.
  Stream<SensorReading?> latestReading(String deviceId) =>
      _watch(_database.ref('readings/$deviceId').orderByKey().limitToLast(1), (data) {
        if (data is! Map || data.isEmpty) return null;
        try {
          return SensorReading.fromMap(data.values.first as Map);
        } catch (_) {
          return null; // A malformed entry shows as no reading.
        }
      });

  /// When the SMS gateway phone last checked in (it writes every minute).
  Stream<DateTime?> gatewayLastSeen(String pondId) => _watch(_database.ref('gatewayStatus/$pondId/lastSeen'), _time);

  Stream<SmsQueueEntry?> lastSms(String pondId) => _watch(_database.ref('smsQueue/$pondId').limitToLast(1), (data) {
    if (data is! Map || data.isEmpty) return null;
    final entry = data.values.first;
    if (entry is! Map) return null;
    return SmsQueueEntry(
      status: entry['status']?.toString() ?? '?',
      createdAt: _time(entry['createdAt']),
      error: entry['error']?.toString(),
    );
  });

  /// Readings stored since [since], oldest first, as upload timing samples.
  /// Reading keys are the ESP32's own send time in epoch milliseconds.
  Stream<List<UploadSample>> uploads({required String deviceId, required DateTime since}) {
    final query = _database.ref('readings/$deviceId').orderByKey().startAt(since.millisecondsSinceEpoch.toString());
    return _watch(query, (data) {
      if (data is! Map) return const <UploadSample>[];
      final samples = <UploadSample>[];
      for (final MapEntry(:key, :value) in data.entries) {
        final sentMs = int.tryParse(key.toString());
        final storedAt = value is Map ? _time(value['recordedAt']) : null;
        if (sentMs == null || storedAt == null) continue;
        samples.add(
          UploadSample(
            sentAt: DateTime.fromMillisecondsSinceEpoch(sentMs),
            storedAt: storedAt,
            batteryPercent: value is Map ? (value['batteryPercent'] as num?)?.toInt() : null,
          ),
        );
      }
      return samples..sort((a, b) => a.storedAt.compareTo(b.storedAt));
    });
  }

  /// The role [uid] holds in [pond], if any.
  static PondRole? roleIn(PondSummary pond, String uid) => pond.ownerUid == uid
      ? PondRole.owner
      : pond.caretakerUid == uid
      ? PondRole.caretaker
      : null;
}

/// Whether [pond] matches an admin's search: any part of its name, ID or
/// join code, or of a member's name or phone number ([userPhones] fills in
/// numbers the pond itself lacks). Spaces and dashes in numbers and codes
/// don't matter. A blank search matches everything.
bool pondMatchesSearch(PondSummary pond, String query, {Map<String, String?> userPhones = const {}}) {
  final text = query.trim().toLowerCase();
  if (text.isEmpty) return true;
  final compact = text.replaceAll(RegExp(r'[\s-]'), '');
  final members = [?pond.ownerUid, ?pond.caretakerUid];
  final fields = [
    pond.name,
    pond.id,
    ?pond.code,
    ...pond.names.values,
    for (final uid in members) ?(pond.phones[uid] ?? userPhones[uid]),
  ];
  return fields.any((field) {
    final value = field.toLowerCase();
    return value.contains(text) || (compact.isNotEmpty && value.replaceAll(RegExp(r'[\s-]'), '').contains(compact));
  });
}
