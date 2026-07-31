import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:kc_app/src/features/notification/data/repositories/device_token_repository.dart';
import '../../../../../firebase_options.dart';

/// Top-level background message handler for FCM.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (kDebugMode) {
    debugPrint('[FCM Background] Received message: ${message.messageId}');
  }
}

/// Delegate for handling notification tap navigation.
typedef NotificationTapHandler =
    void Function(String notificationId, Map<String, dynamic> payload);

/// Service handling Firebase Cloud Messaging initialization, permission, tokens, and local presentation.
class FirebaseMessagingService {
  FirebaseMessagingService({
    FirebaseMessaging? messaging,
    DeviceTokenRepository? deviceTokenRepository,
    FlutterLocalNotificationsPlugin? localNotifications,
  }) : _messaging = messaging ?? FirebaseMessaging.instance,
       _deviceTokenRepository =
           deviceTokenRepository ?? DeviceTokenRepository(),
       _localNotifications =
           localNotifications ?? FlutterLocalNotificationsPlugin();

  final FirebaseMessaging _messaging;
  final DeviceTokenRepository _deviceTokenRepository;
  final FlutterLocalNotificationsPlugin _localNotifications;

  String? _currentToken;
  NotificationTapHandler? _onTapHandler;
  bool _isInitialized = false;

  String? get currentToken => _currentToken;

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'stitching_updates',
    'Stitching & Boutique Updates',
    description:
        'Notifications for stitching order progress and boutique updates',
    importance: Importance.max,
  );

  /// Inspect current notification permission status.
  Future<NotificationSettings> getPermissionStatus() async {
    return await _messaging.getNotificationSettings();
  }

  /// Contextual runtime permission request.
  Future<NotificationSettings> requestPermission() async {
    try {
      final status = await Permission.notification.request();
      if (kDebugMode) {
        debugPrint('[FirebaseMessagingService] permission_handler status: $status');
      }
      return await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[FirebaseMessagingService] Permission request failed: $e');
      }
      return await _messaging.getNotificationSettings();
    }
  }

  /// Initializes messaging listeners, local notification presentation, and token registration.
  Future<void> initialize({
    required String customerId,
    String? firebaseUid,
    NotificationTapHandler? onTapHandler,
  }) async {
    _onTapHandler = onTapHandler;

    if (_isInitialized) {
      // Re-register token if user changed
      if (customerId.isNotEmpty) {
        await _registerTokenForUser(
          customerId: customerId,
          firebaseUid: firebaseUid,
        );
      }
      return;
    }

    try {
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // Initialize local notifications for foreground presentation
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      const darwinSettings = DarwinInitializationSettings();
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
      );

      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (response) {
          final payloadStr = response.payload;
          if (payloadStr != null &&
              payloadStr.isNotEmpty &&
              _onTapHandler != null) {
            _onTapHandler!(payloadStr, {});
          }
        },
      );

      // Create Android Notification Channel
      final androidImplementation = _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (androidImplementation != null) {
        await androidImplementation.createNotificationChannel(_channel);
      }

      // Foreground message listener
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        final title = message.notification?.title ?? message.data['title'] as String?;
        final body = message.notification?.body ?? message.data['body'] as String?;

        if (kDebugMode) {
          debugPrint(
            '[FCM Foreground] Received: $title - $body',
          );
        }

        if (title != null && title.isNotEmpty && !kIsWeb) {
          _localNotifications.show(
            message.hashCode,
            title,
            body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                _channel.id,
                _channel.name,
                channelDescription: _channel.description,
                importance: Importance.max,
                priority: Priority.high,
                icon: '@mipmap/ic_launcher',
              ),
              iOS: const DarwinNotificationDetails(
                presentAlert: true,
                presentBadge: true,
                presentSound: true,
              ),
            ),
            payload: jsonEncode(message.data),
          );
        }
      });

      // Token registration for customer
      await _registerTokenForUser(
        customerId: customerId.isNotEmpty ? customerId : 'guest',
        firebaseUid: firebaseUid,
      );

      // Token refresh listener
      _messaging.onTokenRefresh.listen((newToken) async {
        _currentToken = newToken;
        final targetUid = (firebaseUid != null && firebaseUid.isNotEmpty)
            ? firebaseUid
            : (customerId.isNotEmpty ? customerId : 'guest');
        await _deviceTokenRepository.registerToken(
          uid: targetUid,
          role: 'customer',
          appId: 'kc_app',
          token: newToken,
        );
      });

      // Notification taps when app launched from terminated state
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleMessageTap(initialMessage);
      }

      // Notification taps when app in background
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageTap);

      _isInitialized = true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[FirebaseMessagingService] Initialization error: $e');
      }
    }
  }

  Future<void> _registerTokenForUser({
    required String customerId,
    String? firebaseUid,
  }) async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        _currentToken = token;
        await _deviceTokenRepository.registerToken(
          uid: firebaseUid ?? customerId,
          role: 'customer',
          appId: 'kc_app',
          token: token,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[FirebaseMessagingService] Token registration failed: $e');
      }
    }
  }

  void _handleMessageTap(RemoteMessage message) {
    final notificationId = message.data['notificationId'] as String? ?? '';
    if (notificationId.isNotEmpty && _onTapHandler != null) {
      _onTapHandler!(notificationId, message.data);
    }
  }

  /// Deactivates token and clears state on logout.
  Future<void> onLogout() async {
    if (_currentToken != null) {
      try {
        await _deviceTokenRepository.deactivateToken(_currentToken!);
      } catch (_) {}
      _currentToken = null;
    }
  }
}
