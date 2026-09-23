import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'notification_service.dart';

const _pushKey = 'pushAlertsEnabled';
const _smsKey = 'smsAlertsEnabled';
const _consentShownKey = 'alertConsentShown';

/// Push and SMS alerts are tracked as two independent preferences (the
/// hardware also sends SMS directly from the SIM7000G module, outside the
/// app, so "SMS alerts" here is just the farmer's in-app opt-in — there's no
/// OS permission for receiving ordinary SMS, unlike push notifications which
/// do require one).
class AlertPreferences extends ChangeNotifier {
  AlertPreferences({
    required bool pushEnabled,
    required bool smsEnabled,
    required bool consentShown,
  }) : _pushEnabled = pushEnabled,
       _smsEnabled = smsEnabled,
       _consentShown = consentShown;

  bool _pushEnabled;
  bool _smsEnabled;
  bool _consentShown;

  bool get pushEnabled => _pushEnabled;
  bool get smsEnabled => _smsEnabled;
  bool get hasShownConsent => _consentShown;

  static Future<AlertPreferences> load() async {
    final prefs = await SharedPreferences.getInstance();
    return AlertPreferences(
      pushEnabled: prefs.getBool(_pushKey) ?? true,
      smsEnabled: prefs.getBool(_smsKey) ?? true,
      consentShown: prefs.getBool(_consentShownKey) ?? false,
    );
  }

  Future<void> setPushEnabled(bool value) async {
    _pushEnabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_pushKey, value);
    if (!value) {
      await NotificationService.instance.cancelPersistentMonitoring();
      return;
    }

    final granted = await requestNotificationPermission();
    if (granted) {
      await NotificationService.instance.showPersistentMonitoring(
        body: 'Waiting for the latest pond sensor reading.',
      );
    }
  }

  Future<void> setSmsEnabled(bool value) async {
    _smsEnabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_smsKey, value);
  }

  Future<void> markConsentShown() async {
    _consentShown = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_consentShownKey, true);
  }

  /// Safe to call repeatedly — the OS only shows its permission dialog the
  /// first time (or after the user resets permissions); afterwards this just
  /// returns the cached decision.
  Future<bool> requestNotificationPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }
}
