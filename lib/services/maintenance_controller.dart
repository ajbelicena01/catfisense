import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../utils/maintenance.dart';
import 'alert_preferences.dart';
import 'maintenance_service.dart';
import 'notification_service.dart';
import 'pond_service.dart';

/// Follows the signed-in member's pond maintenance schedule for the
/// Dashboard banner and the Maintenance page, and keeps the phone's
/// scheduled reminders matching it (only while push alerts are on).
class MaintenanceController extends ChangeNotifier {
  MaintenanceController(this._alerts) {
    _authSub = FirebaseAuth.instance.authStateChanges().listen(_onUser);
    _alerts.addListener(_syncReminders);
  }

  final AlertPreferences _alerts;
  StreamSubscription<User?>? _authSub;
  StreamSubscription<PondMembership?>? _membershipSub;
  StreamSubscription<List<MaintenanceRecord>>? _recordsSub;

  PondMembership? _membership;
  List<MaintenanceRecord>? _records;

  /// Null while signed out or not linked to a pond (admins included).
  PondMembership? get membership => _membership;

  /// Null until the schedule has loaded.
  List<MaintenanceRecord>? get records => _records;

  void _onUser(User? user) {
    _membershipSub?.cancel();
    _membershipSub = null;
    _setPond(null);
    if (user == null) return;
    _membershipSub = PondService().membership(user.uid).listen(_setPond, onError: (Object _) {});
  }

  void _setPond(PondMembership? membership) {
    final pondChanged = membership?.pondId != _membership?.pondId;
    _membership = membership;
    if (pondChanged) {
      _recordsSub?.cancel();
      _recordsSub = null;
      _records = null;
      if (membership != null) {
        _recordsSub = MaintenanceService().watch(membership.pondId).listen((records) {
          _records = records;
          notifyListeners();
          _syncReminders();
        }, onError: (Object _) {});
      } else {
        _syncReminders();
      }
    }
    notifyListeners();
  }

  void _syncReminders() {
    final records = _records;
    if (_membership == null || records == null || !_alerts.pushEnabled) {
      unawaited(NotificationService.instance.cancelMaintenanceReminders());
    } else {
      unawaited(NotificationService.instance.syncMaintenanceReminders(records));
    }
  }

  @override
  void dispose() {
    _alerts.removeListener(_syncReminders);
    _recordsSub?.cancel();
    _membershipSub?.cancel();
    _authSub?.cancel();
    super.dispose();
  }
}
