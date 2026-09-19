import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../utils/pond_status.dart';

/// Fires a local (on-device) notification when a sensor reading drifts into
/// warning/critical territory. This is separate from the SMS alerts, which
/// the ESP32 + SIM7000G hardware sends directly over the cellular network —
/// the app doesn't need to (and can't) originate those itself.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      // Permission is already requested via permission_handler in the
      // alert-consent dialog; don't prompt a second time here.
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      settings: const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );
    _initialized = true;
  }

  /// Showing a notification is a best-effort enhancement — a platform quirk
  /// here (e.g. browser permission state on web) should never take down the
  /// auto-refresh loop that calls this, so failures are swallowed.
  Future<void> showPondAlert(PondStatus status) async {
    if (status == PondStatus.healthy) return;
    try {
      await _ensureInitialized();

      final critical = status == PondStatus.critical;
      const androidDetails = AndroidNotificationDetails(
        'pond_alerts',
        'Pond Alerts',
        channelDescription: 'Warnings and critical alerts about pond water quality',
        importance: Importance.high,
        priority: Priority.high,
      );
      const iosDetails = DarwinNotificationDetails();

      await _plugin.show(
        id: critical ? 1 : 0,
        title: critical ? 'Pond health is critical' : 'Pond health warning',
        body: critical
            ? 'One or more readings are critical — check the app and act now.'
            : 'A reading has drifted out of the healthy range. Tap to see what to do.',
        notificationDetails: const NotificationDetails(android: androidDetails, iOS: iosDetails),
      );
    } catch (e) {
      debugPrint('NotificationService.showPondAlert failed: $e');
    }
  }
}
