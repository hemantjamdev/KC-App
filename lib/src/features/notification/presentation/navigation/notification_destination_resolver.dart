import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../domain/models/notification_model.dart';

/// Navigation resolver for notification destinations with security & entity availability checks in KC-App.
abstract class NotificationDestinationResolver {
  static void navigateToDestination(
    BuildContext context,
    NotificationModel notification, {
    required String? authenticatedCustomerId,
  }) {
    final type =
        notification.relatedEntityType ?? NotificationDestinationType.none;
    final entityId = notification.relatedEntityId;

    switch (type) {
      case NotificationDestinationType.none:
        return;

      case NotificationDestinationType.customerProfile:
        context.push(AppRoutes.customerProfile);
        return;

      case NotificationDestinationType.design:
        if (entityId == null || entityId.isEmpty) {
          _showUnavailable(context, 'This design is no longer available.');
          return;
        }
        context.push(AppRoutes.customerHome);
        return;

      case NotificationDestinationType.section:
        if (entityId == null || entityId.isEmpty) {
          _showUnavailable(context, 'This collection is no longer available.');
          return;
        }
        context.push(AppRoutes.customerHome);
        return;

      case NotificationDestinationType.stitchingOrder:
        if (entityId == null || entityId.isEmpty) {
          _showUnavailable(context, 'This stitching order is unavailable.');
          return;
        }
        context.push(AppRoutes.customerStitchingList);
        return;
    }
  }

  static void _showUnavailable(BuildContext context, String message) {
    AppToast.show(context, message, type: ToastType.warning);
  }
}
