import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../firebase_options.dart';
import '../utils/thresholds.dart';

const _cacheKey = 'thresholdsCache';

/// Keeps [Thresholds.current] in sync with `config/thresholds` while someone
/// is signed in, and remembers the last values on the phone so an offline
/// start still judges readings with the admins' ranges. Listeners (the
/// MaterialApp) rebuild the screens when the ranges change.
class ThresholdController extends ChangeNotifier {
  ThresholdController._();

  StreamSubscription<User?>? _authSub;
  StreamSubscription<DatabaseEvent>? _configSub;

  Thresholds get thresholds => Thresholds.current;

  static Future<ThresholdController> load() async {
    final controller = ThresholdController._();
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(_cacheKey);
      if (cached != null) Thresholds.current = Thresholds.fromMap(jsonDecode(cached));
    } catch (_) {
      // A bad cache just means the defaults until the live values arrive.
    }
    controller._authSub = FirebaseAuth.instance.authStateChanges().listen(controller._onUser);
    return controller;
  }

  static FirebaseDatabase get _database => FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: DefaultFirebaseOptions.currentPlatform.databaseURL,
  );

  static DatabaseReference get _ref => _database.ref('config/thresholds');

  void _onUser(User? user) {
    _configSub?.cancel();
    _configSub = null;
    if (user == null) return;
    _configSub = _ref.onValue.listen((event) => _apply(event.snapshot.value), onError: (Object _) {});
  }

  Future<void> _apply(Object? value) async {
    final next = Thresholds.fromMap(value);
    if (next == Thresholds.current) return;
    Thresholds.current = next;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKey, jsonEncode(next.toMap()));
  }

  /// Admins only (the rules refuse anyone else). Returns whether it saved.
  static Future<bool> save(Thresholds thresholds) async {
    try {
      await _ref.set(thresholds.toMap());
      return true;
    } on FirebaseException {
      return false;
    }
  }

  @override
  void dispose() {
    _configSub?.cancel();
    _authSub?.cancel();
    super.dispose();
  }
}
