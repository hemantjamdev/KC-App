import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/app_routes.dart';
import '../../domain/models/notification_payload_model.dart';

/// Navigation router for FCM and local notification tap handling in KC-App.
class NotificationRouter {
  static NotificationPayloadModel? parsePayload(String rawPayload) {
    try {
      if (rawPayload.isEmpty) return null;
      final map = jsonDecode(rawPayload) as Map<String, dynamic>;
      final notifId = map['notificationId'] as String? ?? '';
      final type = map['type'] as String? ?? 'general';
      final route = map['route'] as String? ?? map['relatedEntityType'] as String? ?? 'home';
      final targetId = map['targetId'] as String? ?? map['relatedEntityId'] as String?;

      return NotificationPayloadModel(
        notificationId: notifId,
        type: type,
        route: route,
        targetId: targetId,
        rawData: map,
      );
    } catch (_) {
      return null;
    }
  }

  static void handleNotificationTap(BuildContext context, NotificationPayloadModel payload) {
    switch (payload.route) {
      case 'myStitching':
      case 'stitchingDetails':
      case 'stitchingOrder':
        context.go(AppRoutes.customerStitchingList);
        break;
      case 'favorites':
        context.go(AppRoutes.customerFavorites);
        break;
      case 'profile':
        context.go(AppRoutes.customerProfile);
        break;
      case 'home':
      default:
        context.go(AppRoutes.customerHome);
        break;
    }
  }
}
