import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/notification_model.dart';

/// Modular Customer Notification Card widget.
class CustomerNotificationCard extends StatelessWidget {
  const CustomerNotificationCard({super.key, required this.notification});

  final NotificationModel notification;

  @override
  Widget build(BuildContext context) {
    final formattedTime = notification.publishedAt != null
        ? DateFormat('d MMM, h:mm a').format(notification.publishedAt!)
        : DateFormat('d MMM, h:mm a').format(notification.createdAt);

    final hasLink = notification.relatedEntityType != null &&
        notification.relatedEntityType != NotificationDestinationType.none;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderSoft),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            context.push(
              AppRoutes.customerNotificationDetails,
              extra: notification,
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _badgeBgColor(notification.type),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _iconForType(notification.type),
                        size: 20,
                        color: _badgeIconColor(notification.type),
                      ),
                    ),
                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                notification.type.label.toUpperCase(),
                                style: GoogleFonts.montserrat(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.goldBronze,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              Text(
                                formattedTime,
                                style: GoogleFonts.montserrat(
                                  fontSize: 10,
                                  color: AppColors.mutedText,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            notification.title,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.charcoal,
                              height: 1.25,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                Text(
                  notification.body,
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: AppColors.mutedText,
                    height: 1.45,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (hasLink)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.brandGreen50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.link_rounded,
                              size: 12,
                              color: AppColors.brandGreen900,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              notification.relatedEntityType!.label,
                              style: GoogleFonts.montserrat(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.brandGreen900,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      const SizedBox.shrink(),

                    Row(
                      children: [
                        Text(
                          'Read More',
                          style: GoogleFonts.montserrat(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.brandGreen900,
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(
                          Icons.chevron_right_rounded,
                          size: 16,
                          color: AppColors.brandGreen900,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _badgeBgColor(NotificationType type) {
    return switch (type) {
      NotificationType.general => AppColors.brandGreen50,
      NotificationType.stitchingUpdate => const Color(0xFFFBF4E8),
      NotificationType.designUpdate => AppColors.brandGreen50,
      NotificationType.boutiqueAnnouncement => const Color(0xFFFDF0ED),
    };
  }

  Color _badgeIconColor(NotificationType type) {
    return switch (type) {
      NotificationType.general => AppColors.brandGreen800,
      NotificationType.stitchingUpdate => AppColors.goldBronze,
      NotificationType.designUpdate => AppColors.brandGreen800,
      NotificationType.boutiqueAnnouncement => AppColors.error,
    };
  }

  IconData _iconForType(NotificationType type) {
    return switch (type) {
      NotificationType.general => Icons.notifications_active_rounded,
      NotificationType.stitchingUpdate => Icons.design_services_rounded,
      NotificationType.designUpdate => Icons.checkroom_rounded,
      NotificationType.boutiqueAnnouncement => Icons.campaign_rounded,
    };
  }
}
