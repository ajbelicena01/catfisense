import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

import '../firebase_options.dart';
import '../models/sensor_reading.dart';

/// Reads/writes pond sensor data under `readings/<deviceId>/<epochMillis>`
/// in the Realtime Database. Keys are millisecond epoch timestamps —
/// naturally time-ordered and simple for the ESP32 firmware to construct
/// without any special ID-generation logic.
///
/// Single-device deployment: one pond, one ESP32, one owner. Data lives at
/// a fixed device path rather than being scoped per Firebase Auth user, so
/// the ESP32 never needs to know or re-sync a specific account's
/// credentials — it just writes to this fixed path, and the app reads from
/// it regardless of which account (if any) is logged in.
class SensorRepository {
  SensorRepository({FirebaseDatabase? database}) : _databaseOverride = database;

  final FirebaseDatabase? _databaseOverride;

  // Fixed device identifier. Change this if you ever support multiple
  // ponds/devices; for now there's exactly one, so it's a constant.
  static const String deviceId = 'pond1';

  // On Android, the default FirebaseApp can end up auto-initialized natively
  // from google-services.json (which has no Realtime Database URL in it), so
  // FirebaseDatabase.instance alone may not know which RTDB instance to use.
  // Pointing at the URL explicitly avoids depending on which app config won.
  FirebaseDatabase get _database =>
      _databaseOverride ??
      FirebaseDatabase.instanceFor(app: Firebase.app(), databaseURL: DefaultFirebaseOptions.currentPlatform.databaseURL);

  DatabaseReference get _readingsRef => _database.ref('readings/$deviceId');

  /// Live latest reading, or null if this pond has no readings yet.
  Stream<SensorReading?> latestReading() {
    return _readingsRef.orderByKey().limitToLast(1).onValue.map((event) {
      final data = event.snapshot.value;
      if (data is! Map || data.isEmpty) return null;
      return SensorReading.fromMap(data.values.first as Map);
    });
  }

  /// Live readings recorded within [start, end], oldest first.
  Stream<List<SensorReading>> history({required DateTime start, required DateTime end}) {
    return _readingsRef
        .orderByKey()
        .startAt(start.millisecondsSinceEpoch.toString())
        .endAt(end.millisecondsSinceEpoch.toString())
        .onValue
        .map((event) {
      final data = event.snapshot.value;
      if (data is! Map || data.isEmpty) return const <SensorReading>[];
      final entries = data.entries.toList()
        ..sort((a, b) => int.parse(a.key.toString()).compareTo(int.parse(b.key.toString())));
      return entries.map((e) => SensorReading.fromMap(e.value as Map)).toList();
    });
  }

  /// Manual test helper — pushes one fake reading when you tap refresh on
  /// an empty dashboard. Not run automatically; real data comes from the
  /// ESP32 writing to this same path.
  Future<void> pushSimulatedReading({
    required double ph,
    required double temperature,
    required double dissolvedOxygen,
    required double ammonia,
    int? batteryPercent,
  }) {
    final key = DateTime.now().millisecondsSinceEpoch.toString();
    return _readingsRef.child(key).set({
      'ph': ph,
      'temperature': temperature,
      'dissolvedOxygen': dissolvedOxygen,
      'ammonia': ammonia,
      'batteryPercent': ?batteryPercent,
      'recordedAt': ServerValue.timestamp,
    });
  }
}
