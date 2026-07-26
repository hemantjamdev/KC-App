import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:kc_app/src/features/notification/data/repositories/device_token_repository.dart';

/// Delegate for handling notification tap navigation.
typedef NotificationTapHandler = void Function(String notificationId, Map<String, dynamic> payload);

/// Service handling Firebase Cloud Messaging initialization, permission, tokens, and messages.
class FirebaseMessagingService {
  FirebaseMessagingService({
    FirebaseMessaging? messaging,
    DeviceTokenRepository? deviceTokenRepository,
  })  : _messaging = messaging ?? FirebaseMessaging.instance,
        _deviceTokenRepository = deviceTokenRepository ?? DeviceTokenRepository();

  final FirebaseMessaging _messaging;
  final DeviceTokenRepository _deviceTokenRepository;

  String? _currentToken;
  NotificationTapHandler? _onTapHandler;

  String? get currentToken => _currentToken;

  /// Inspect current notification permission status.
  Future<NotificationSettings> getPermissionStatus() async {
    return await _messaging.getNotificationSettings();
  }

  /// Contextual runtime permission request.
  Future<bool> requestPermission() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[FirebaseMessagingService] Permission request failed: $e');
      }
      return false;
    }
  }

  /// Initializes messaging listeners and token registration for authenticated customer.
  Future<void> initialize({
    required String customerId,
    String? firebaseUid,
    NotificationTapHandler? onTapHandler,
  }) async {
    _onTapHandler = onTapHandler;

    try {
      final token = await _messaging.getToken();
      if (token != null) {
        _currentToken = token;
        await _deviceTokenRepository.registerToken(
          customerId: customerId,
          firebaseUid: firebaseUid,
          token: token,
        );
      }

      // Token refresh listener
      _messaging.onTokenRefresh.listen((newToken) async {
        _currentToken = newToken;
        await _deviceTokenRepository.registerToken(
          customerId: customerId,
          firebaseUid: firebaseUid,
          token: newToken,
        );
      });

      // Handle notification taps when app was launched from terminated state
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleMessageTap(initialMessage);
      }

      // Handle notification taps when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageTap);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[FirebaseMessagingService] Initialization error: $e');
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
      await _deviceTokenRepository.deactivateToken(_currentToken!);
      _currentToken = null;
    }
  }
}
