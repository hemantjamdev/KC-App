import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
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
        context.push(AppRoutes.customerAllDesigns);
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.surfaceLight,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
