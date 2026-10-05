import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/kc_app_bar.dart';
import '../../../auth/application/providers/auth_providers.dart';
import '../../application/providers/notification_providers.dart';
import '../../domain/models/notification_model.dart';
import '../navigation/notification_destination_resolver.dart';

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

  @override
  Widget build(BuildContext context) {
    final notif = widget.notification;
    final user = ref.watch(currentCustomerUserProvider);
    final hasDestination = notif.relatedEntityType != null &&
        notif.relatedEntityType != NotificationDestinationType.none;

    final formattedDate = notif.publishedAt != null
        ? DateFormat('EEEE, d MMMM yyyy • h:mm a').format(notif.publishedAt!)
        : DateFormat('EEEE, d MMMM yyyy • h:mm a').format(notif.createdAt);

    return PopScope(
      canPop: context.canPop(),
      child: Scaffold(
        backgroundColor: AppColors.warmIvory,
        appBar: KCAppBar(
          title: notif.type.label,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 540),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Main Notification Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceWhite,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: AppColors.borderSoft),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.brandGreen50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.brandGreen800.withValues(
                                      alpha: 0.2,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  notif.type.label.toUpperCase(),
                                  style: GoogleFonts.montserrat(
                                    color: AppColors.brandGreen900,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.verified_rounded,
                                size: 18,
                                color: AppColors.goldBronze,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          Text(
                            notif.title,
                            style: GoogleFonts.playfairDisplay(
                              color: AppColors.charcoal,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 8),

                          Text(
                            formattedDate,
                            style: GoogleFonts.montserrat(
                              color: AppColors.mutedText,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Divider(
                              color: AppColors.borderSoft,
                              height: 1,
                            ),
                          ),

                          Text(
                            notif.body,
                            style: GoogleFonts.montserrat(
                              color: AppColors.charcoal,
                              fontSize: 14,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Destination CTA Action
                    if (hasDestination)
                      AppButton(
                        text: 'View ${notif.relatedEntityType!.label}',
                        icon: Icons.arrow_forward_rounded,
                        onPressed: () {
                          NotificationDestinationResolver.navigateToDestination(
                            context,
                            notif,
                            authenticatedCustomerId: user?.uid ?? '',
                          );
                        },
                      ),

                    const SizedBox(height: 32),
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
