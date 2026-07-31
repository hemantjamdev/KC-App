import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kc_app/src/features/auth/application/providers/auth_providers.dart';
import 'package:kc_app/src/features/notification/application/providers/notification_providers.dart';
import 'package:kc_app/src/features/notification/domain/models/notification_model.dart';
import 'package:kc_app/src/features/notification/presentation/navigation/notification_destination_resolver.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/kc_app_bar.dart';

/// Customer Notification Details Page — displays notification content and destination action.
class CustomerNotificationDetailsPage extends ConsumerStatefulWidget {
  const CustomerNotificationDetailsPage({
    super.key,
    required this.notification,
  });
  final NotificationModel notification;

  @override
  ConsumerState<CustomerNotificationDetailsPage> createState() =>
      _CustomerNotificationDetailsPageState();
}

class _CustomerNotificationDetailsPageState
    extends ConsumerState<CustomerNotificationDetailsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final user = ref.read(currentCustomerUserProvider);
      if (user != null) {
        ref
            .read(notificationRepositoryProvider)
            .markAsRead(widget.notification.id, user.uid);
      }
    });
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    return '${dt.day}/${dt.month}/${dt.year} at ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final notif = widget.notification;
    final user = ref.watch(currentCustomerUserProvider);
    final hasDestination =
        notif.relatedEntityType != null &&
        notif.relatedEntityType != NotificationDestinationType.none;

    return PopScope(
      canPop: context.canPop(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: KCAppBar(
          title: notif.type.label,
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
                                style: GoogleFonts.montserrat(
                                  color: AppColors.primary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              _formatDate(notif.publishedAt ?? notif.createdAt),
                              style: GoogleFonts.montserrat(
                                color: AppColors.textHint,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          notif.title,
                          style: GoogleFonts.playfairDisplay(
                            color: AppColors.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          notif.body,
                          style: GoogleFonts.montserrat(
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
                          authenticatedCustomerId: user?.uid ?? '',
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
    ),
  );
}
}
