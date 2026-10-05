import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_empty_state.dart';
import 'package:kc_app/src/core/widgets/kc_app_bar.dart';
import '../../application/providers/notification_providers.dart';
import '../../domain/models/notification_model.dart';

/// Customer Notifications Page.
/// Displays general public announcements and customer-specific stitching & favorite alerts from Firestore.
class CustomerNotificationListPage extends ConsumerWidget {
  const CustomerNotificationListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationListProvider);
    final notifications = notificationsAsync.valueOrNull ?? [];
    final visible = notifications;

    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      appBar: const KCAppBar(
        title: 'Notifications & Updates',
      ),
      body: SafeArea(
        child: notificationsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(
              color: AppColors.brandGreen800,
              strokeWidth: 2,
            ),
          ),
          error: (err, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    size: 48,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Couldn’t load notifications',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.charcoal,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Check your connection and try again.',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: AppColors.mutedText,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(notificationListProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
          data: (_) {
            if (visible.isEmpty) {
              return RefreshIndicator(
                color: AppColors.brandGreen800,
                onRefresh: () async {
                  ref.invalidate(notificationListProvider);
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.7,
                    alignment: Alignment.center,
                    child: const AppEmptyState(
                      icon: Icons.notifications_none_rounded,
                      title: 'You’re all caught up',
                      message: 'Updates from Kapada Creation will appear here.',
                    ),
                  ),
                ),
              );
            }
            return RefreshIndicator(
              color: AppColors.brandGreen800,
              onRefresh: () async {
                ref.invalidate(notificationListProvider);
              },
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.all(20),
                itemCount: visible.length,
                itemBuilder: (ctx, idx) {
                  return _NotificationCard(notification: visible[idx]);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.notification});

  final NotificationModel notification;

  @override
  Widget build(BuildContext context) {
    final formattedTime = notification.publishedAt != null
        ? DateFormat('d MMM, h:mm a').format(notification.publishedAt!)
        : DateFormat('d MMM').format(notification.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.brandGreen50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _iconForType(notification.type),
                  size: 18,
                  color: AppColors.brandGreen800,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  notification.title,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.charcoal,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Text(
            notification.body,
            style: GoogleFonts.montserrat(
              fontSize: 12,
              color: AppColors.mutedText,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formattedTime,
                style: GoogleFonts.montserrat(
                  fontSize: 10,
                  color: AppColors.mutedText,
                ),
              ),
              if (notification.relatedEntityType != null &&
                  notification.relatedEntityType !=
                      NotificationDestinationType.none)
                GestureDetector(
                  onTap: () => _handleDeepLink(context, notification),
                  child: Row(
                    children: [
                      Text(
                        'View Details',
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.brandGreen800,
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 14,
                        color: AppColors.brandGreen800,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _iconForType(NotificationType type) {
    return switch (type) {
      NotificationType.general => Icons.notifications_none_rounded,
      NotificationType.stitchingUpdate ||
      NotificationType.stitchingStatusUpdated =>
        Icons.design_services_rounded,
      NotificationType.designUpdate => Icons.checkroom_rounded,
      NotificationType.boutiqueAnnouncement => Icons.campaign_rounded,
      NotificationType.newStitchingRequest => Icons.mark_email_unread_rounded,
    };
  }

  void _handleDeepLink(BuildContext context, NotificationModel notification) {
    final dest = notification.relatedEntityType;
    if (dest == NotificationDestinationType.stitchingOrder) {
      context.go(AppRoutes.customerStitchingList);
    } else {
      context.go(AppRoutes.customerHome);
    }
  }
}
