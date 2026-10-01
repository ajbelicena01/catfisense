import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

import '../firebase_options.dart';
import '../models/sensor_reading.dart';

/// Reads/writes pond sensor data under `readings/<deviceId>/<epochMillis>`
/// in the Realtime Database. Keys are millisecond epoch timestamps —
/// naturally time-ordered and simple for the ESP32 firmware to construct
/// without any special ID-generation logic.
///
/// Each pond's ID is its device's ID, so a pond's readings are at
/// `readings/<pondId>`. The first ESP32 writes to the fixed `pond1`; newer
/// devices write under their own Firebase login UID, which an admin then
/// adds as a pond.
class SensorRepository {
  SensorRepository({FirebaseDatabase? database}) : _databaseOverride = database;

  final FirebaseDatabase? _databaseOverride;

  static const String defaultDeviceId = 'pond1';

  /// The signed-in member's pond. [AuthGate] sets it before opening the
  /// farmer screens, which all read this pond's data.
  static String deviceId = defaultDeviceId;

  // On Android, the default FirebaseApp can end up auto-initialized natively
  // from google-services.json (which has no Realtime Database URL in it), so
  // FirebaseDatabase.instance alone may not know which RTDB instance to use.
  // Pointing at the URL explicitly avoids depending on which app config won.
  FirebaseDatabase get _database =>
      _databaseOverride ??
      FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: DefaultFirebaseOptions.currentPlatform.databaseURL,
      );

  DatabaseReference get _readingsRef => _database.ref('readings/$deviceId');

  /// Whether this phone currently has a live connection to the database.
  /// Starts false and flips to true within a second or so of opening.
  Stream<bool> connected() {
    return _database.ref('.info/connected').onValue.map((event) => event.snapshot.value == true);
  }

  /// Live latest reading, or null if this pond has no readings yet.
  Stream<SensorReading?> latestReading() {
    return _readingsRef
        .orderByKey()
        .limitToLast(1)
        .onValue
        .map((event) => _latestFromSnapshot(event.snapshot));
  }

  /// Fetches the newest reading from RTDB on demand, without creating or
  /// changing any data. The live [latestReading] stream continues separately.
  Future<SensorReading?> fetchLatestReading() async {
    final snapshot = await _readingsRef.orderByKey().limitToLast(1).get();
    return _latestFromSnapshot(snapshot);
  }

  SensorReading? _latestFromSnapshot(DataSnapshot snapshot) {
    final data = snapshot.value;
    if (data is! Map || data.isEmpty) return null;
    return SensorReading.fromMap(data.values.first as Map);
  }

  /// Live readings recorded within [start, end], oldest first.
  Stream<List<SensorReading>> history({
    required DateTime start,
    required DateTime end,
  }) {
    return _readingsRef
        .orderByKey()
        .startAt(start.millisecondsSinceEpoch.toString())
        .endAt(end.millisecondsSinceEpoch.toString())
        .onValue
        .map((event) {
          final data = event.snapshot.value;
          if (data is! Map || data.isEmpty) return const <SensorReading>[];
          final entries = data.entries.toList()
            ..sort(
              (a, b) => int.parse(
                a.key.toString(),
              ).compareTo(int.parse(b.key.toString())),
            );
          return entries
              .map((e) => SensorReading.fromMap(e.value as Map))
              .toList();
        });
  }
}
