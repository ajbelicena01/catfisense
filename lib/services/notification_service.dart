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

  static const _monitoringNotificationId = 2;

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      // Permission is already requested via permission_handler in the
      // alert-consent dialog; don't prompt a second time here.
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );
    _initialized = true;
  }

  /// Prepares the native notification plugin for callers that need to show a
  /// notification outside the pond-status flow (for example, an FCM alert).
  Future<void> initialize() => _ensureInitialized();

  Future<void> show({
    required int id,
    required String title,
    required String body,
  }) async {
    await _ensureInitialized();
    const androidDetails = AndroidNotificationDetails(
      'pond_alerts',
      'Pond Alerts',
      channelDescription:
          'Warnings and critical alerts about pond water quality',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      ),
    );
  }

  /// Shows Android's ongoing notification while the pond is being monitored.
  /// It deliberately has no sound and cannot be dismissed by swiping it away.
  Future<void> showPersistentMonitoring({required String body}) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    try {
      await _ensureInitialized();
      const androidDetails = AndroidNotificationDetails(
        'pond_monitoring',
        'Pond Monitoring',
        channelDescription: 'Ongoing pond-monitoring status',
        importance: Importance.low,
        priority: Priority.low,
        ongoing: true,
        autoCancel: false,
        onlyAlertOnce: true,
        playSound: false,
      );
      await _plugin.show(
        id: _monitoringNotificationId,
        title: 'Pond monitoring active',
        body: body,
        notificationDetails: const NotificationDetails(android: androidDetails),
      );
    } catch (error) {
      debugPrint('Unable to show persistent monitoring notification: $error');
    }
  }

  Future<void> cancelPersistentMonitoring() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    await _plugin.cancel(id: _monitoringNotificationId);
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
        channelDescription:
            'Warnings and critical alerts about pond water quality',
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
        notificationDetails: const NotificationDetails(
          android: androidDetails,
          iOS: iosDetails,
        ),
      );
    } catch (e) {
      debugPrint('NotificationService.showPondAlert failed: $e');
    }
  }
}
