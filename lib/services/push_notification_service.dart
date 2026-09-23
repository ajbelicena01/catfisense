import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../firebase_options.dart';
import 'notification_service.dart';

/// Registers this Android device with FCM and keeps its registration token in
/// the signed-in user's profile. The Cloud Function uses those tokens to send
/// notifications even when Flutter is no longer running.
class PushNotificationService {
  PushNotificationService._();
  static final instance = PushNotificationService._();

  final _messaging = FirebaseMessaging.instance;
  bool _initialized = false;
  bool _enabled = false;
  StreamSubscription<String>? _tokenRefreshSubscription;

  FirebaseDatabase get _database => FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: DefaultFirebaseOptions.currentPlatform.databaseURL,
  );

  Future<void> initialize({required bool enabled}) async {
    if (_initialized) {
      await setEnabled(enabled);
      return;
    }
    _initialized = true;
    await NotificationService.instance.initialize();
    _tokenRefreshSubscription = _messaging.onTokenRefresh.listen((token) async {
      if (_enabled) await _saveToken(token);
    });
    FirebaseMessaging.onMessage.listen(_showForegroundMessage);
    await setEnabled(enabled);
  }

  Future<bool> setEnabled(bool enabled) async {
    _enabled = enabled;
    if (!enabled) {
      await _removeCurrentToken();
      return false;
    }

    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    final granted =
        settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
    if (!granted) {
      _enabled = false;
      return false;
    }
    final token = await _messaging.getToken();
    if (token != null) await _saveToken(token);
    return true;
  }

  Future<void> _showForegroundMessage(RemoteMessage message) async {
    if (!_enabled || message.notification == null) return;
    try {
      await NotificationService.instance.show(
        id: message.messageId?.hashCode ?? 0,
        title: message.notification?.title ?? 'Pond alert',
        body: message.notification?.body ?? 'A new pond alert has arrived.',
      );
    } catch (error) {
      debugPrint('Unable to show foreground FCM notification: $error');
    }
  }

  String _tokenKey(String token) =>
      base64Url.encode(utf8.encode(token)).replaceAll('=', '');

  Future<void> _saveToken(String token) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await _database.ref('users/${user.uid}/fcmTokens/${_tokenKey(token)}').set({
      'token': token,
      'updatedAt': ServerValue.timestamp,
    });
  }

  Future<void> _removeCurrentToken() async {
    final user = FirebaseAuth.instance.currentUser;
    final token = await _messaging.getToken();
    if (user != null && token != null) {
      await _database
          .ref('users/${user.uid}/fcmTokens/${_tokenKey(token)}')
          .remove();
    }
  }

  void dispose() => _tokenRefreshSubscription?.cancel();
}
