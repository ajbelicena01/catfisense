import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

import '../l10n/app_localizations.dart';
import '../utils/maintenance.dart';
import '../utils/pond_status.dart';

/// Fires a local (on-device) notification when a sensor reading drifts into
/// warning/critical territory. This is separate from the SMS alerts, which
/// the ESP32 + SIM7000G hardware sends directly over the cellular network —
/// the app doesn't need to (and can't) originate those itself.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  static const _monitoringNotificationId = 2;

  /// Notifications are shown outside any screen, so the app hands over its
  /// current strings whenever the language changes (see main.dart).
  AppLocalizations l10n = lookupAppLocalizations(const Locale('en'));

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
    final androidDetails = AndroidNotificationDetails(
      'pond_alerts',
      l10n.notifAlertsChannel,
      channelDescription: l10n.notifAlertsChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
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
      final androidDetails = AndroidNotificationDetails(
        'pond_monitoring',
        l10n.notifMonitoringChannel,
        channelDescription: l10n.notifMonitoringChannelDescription,
        importance: Importance.low,
        priority: Priority.low,
        ongoing: true,
        autoCancel: false,
        onlyAlertOnce: true,
        playSound: false,
      );
      await _plugin.show(
        id: _monitoringNotificationId,
        title: l10n.notifMonitoringTitle,
        body: body,
        notificationDetails: NotificationDetails(android: androidDetails),
      );
    } catch (error) {
      debugPrint('Unable to show persistent monitoring notification: $error');
    }
  }

  // Three per task (due soon, due today, overdue), in MaintenanceTask order.
  static const _maintenanceIdBase = 3000;
  static const _maintenanceIdsPerTask = 3;
  static const _reminderHour = 9;
  static const _overdueReminderAfterDays = 3;

  /// Replaces the scheduled maintenance reminders with ones for [records]:
  /// 9 AM on the day the "due soon" window opens, on the due day, and a few
  /// days after. Android shows them even while the app is closed.
  Future<void> syncMaintenanceReminders(List<MaintenanceRecord> records) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    try {
      await cancelMaintenanceReminders();
      final now = DateTime.now();
      final date = DateFormat.MMMd(l10n.localeName);
      final details = NotificationDetails(
        android: AndroidNotificationDetails(
          'maintenance_reminders',
          l10n.notifMaintChannel,
          channelDescription: l10n.notifMaintChannelDescription,
          importance: Importance.high,
          priority: Priority.high,
        ),
      );
      for (final record in records) {
        final due = record.dueOn;
        if (due == null) continue;
        final task = maintenanceTaskTitle(l10n, record.task);
        final reminders = [
          (
            DateTime(due.year, due.month, due.day - record.remindDaysBefore, _reminderHour),
            l10n.notifMaintSoonTitle,
            l10n.notifMaintSoonBody(task, date.format(due)),
          ),
          (DateTime(due.year, due.month, due.day, _reminderHour), l10n.notifMaintDueTitle, l10n.notifMaintDueBody(task)),
          (
            DateTime(due.year, due.month, due.day + _overdueReminderAfterDays, _reminderHour),
            l10n.notifMaintOverdueTitle,
            l10n.notifMaintOverdueBody(task, date.format(due)),
          ),
        ];
        for (final (index, (at, title, body)) in reminders.indexed) {
          if (!at.isAfter(now)) continue;
          await _plugin.zonedSchedule(
            id: _maintenanceIdBase + record.task.index * _maintenanceIdsPerTask + index,
            // The exact moment matters, not the zone it is written in, so
            // UTC avoids needing the phone's time zone database.
            scheduledDate: tz.TZDateTime.from(at, tz.UTC),
            notificationDetails: details,
            // Inexact is fine for a daily-scale reminder and needs no
            // exact-alarm permission.
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            title: title,
            body: body,
          );
        }
      }
    } catch (e) {
      debugPrint('NotificationService.syncMaintenanceReminders failed: $e');
    }
  }

  Future<void> cancelMaintenanceReminders() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    await _ensureInitialized();
    for (var i = 0; i < MaintenanceTask.values.length * _maintenanceIdsPerTask; i++) {
      await _plugin.cancel(id: _maintenanceIdBase + i);
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
      final androidDetails = AndroidNotificationDetails(
        'pond_alerts',
        l10n.notifAlertsChannel,
        channelDescription: l10n.notifAlertsChannelDescription,
        importance: Importance.high,
        priority: Priority.high,
      );
      const iosDetails = DarwinNotificationDetails();

      await _plugin.show(
        id: critical ? 1 : 0,
        title: critical ? l10n.notifCriticalTitle : l10n.notifWarningTitle,
        body: critical ? l10n.notifCriticalBody : l10n.notifWarningBody,
        notificationDetails: NotificationDetails(
          android: androidDetails,
          iOS: iosDetails,
        ),
      );
    } catch (e) {
      debugPrint('NotificationService.showPondAlert failed: $e');
    }
  }
}
