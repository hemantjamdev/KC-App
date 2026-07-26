import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kc_app/src/features/auth/presentation/controllers/customer_auth_controller.dart';
import 'package:kc_app/src/features/boutique/presentation/controllers/boutique_selection_controller.dart';
import 'package:kc_app/src/features/notification/domain/models/notification_model.dart';
import 'package:kc_app/src/features/notification/presentation/controllers/notification_controller.dart';
import 'package:kc_app/src/features/notification/presentation/navigation/notification_destination_resolver.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';

/// Customer Notification Details Page — displays notification content and destination action.
class CustomerNotificationDetailsPage extends StatefulWidget {
  const CustomerNotificationDetailsPage({
    super.key,
    required this.notification,
  });
  final NotificationModel notification;

  @override
  State<CustomerNotificationDetailsPage> createState() =>
      _CustomerNotificationDetailsPageState();
}

class _CustomerNotificationDetailsPageState
    extends State<CustomerNotificationDetailsPage> {
  late final CustomerAuthController _authController;
  NotificationController? _controller;

  @override
  void initState() {
    super.initState();
    _authController = CustomerAuthController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scope = BoutiqueSelectionScope.of(context);
    final boutiqueId = scope.selectedBoutique?.id ?? 'boutique_01';
    final branchId = scope.selectedBranch?.id;
    final customerId = _authController.currentCustomer?.id ?? 'cust_01';

    _controller = NotificationController(
      boutiqueId: boutiqueId,
      branchId: branchId,
      authenticatedCustomerId: customerId,
    );
    // Auto mark read on view
    _controller?.markAsRead(widget.notification.id);
  }

  @override
  void dispose() {
    _controller?.dispose();
    _authController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    return '${dt.day}/${dt.month}/${dt.year} at ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final notif = widget.notification;
    final hasDestination =
        notif.relatedEntityType != null &&
        notif.relatedEntityType != NotificationDestinationType.none;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          notif.type.label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Main Notification Card
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppRadius.borderXl,
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(
                                  alpha: 0.15,
                                ),
                                borderRadius: AppRadius.borderPill,
                              ),
                              child: Text(
                                notif.type.label,
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              _formatDate(notif.publishedAt ?? notif.createdAt),
                              style: const TextStyle(
                                color: AppColors.textHint,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          notif.title,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          notif.body,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Destination CTA Action
                  if (hasDestination)
                    AppButton(
                      text: 'View ${notif.relatedEntityType!.label}',
                      icon: Icons.open_in_new_rounded,
                      onPressed: () {
                        NotificationDestinationResolver.navigateToDestination(
                          context,
                          notif,
                          authenticatedCustomerId:
                              _authController.currentCustomer?.id ?? 'cust_01',
                        );
                      },
                    ),

                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
