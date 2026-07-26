import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kc_app/src/features/auth/presentation/controllers/customer_auth_controller.dart';
import 'package:kc_app/src/features/boutique/presentation/controllers/boutique_selection_controller.dart';
import 'package:kc_app/src/features/notification/domain/models/notification_model.dart';
import 'package:kc_app/src/features/notification/presentation/controllers/notification_controller.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_loading_indicator.dart';

/// Customer Notifications Inbox Page ("Notifications").
class CustomerNotificationListPage extends StatefulWidget {
  const CustomerNotificationListPage({super.key});

  @override
  State<CustomerNotificationListPage> createState() =>
      _CustomerNotificationListPageState();
}

class _CustomerNotificationListPageState
    extends State<CustomerNotificationListPage> {
  late final CustomerAuthController _authController;
  NotificationController? _notificationController;

  @override
  void initState() {
    super.initState();
    _authController = CustomerAuthController();
    _authController.addListener(_onUpdate);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scope = BoutiqueSelectionScope.of(context);
    final boutiqueId = scope.selectedBoutique?.id ?? 'boutique_01';
    final branchId = scope.selectedBranch?.id;
    final customerId = _authController.currentCustomer?.id ?? 'cust_01';

    if (_authController.isAuthenticated) {
      _notificationController?.removeListener(_onUpdate);
      _notificationController = NotificationController(
        boutiqueId: boutiqueId,
        branchId: branchId,
        authenticatedCustomerId: customerId,
      );
      _notificationController?.addListener(_onUpdate);
    }
  }

  void _onUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _notificationController?.removeListener(_onUpdate);
    _notificationController?.dispose();
    _authController.removeListener(_onUpdate);
    _authController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAuth = _authController.isAuthenticated;
    final notifications =
        _notificationController?.visibleNotificationsForCustomer ?? [];
    final unreadCount = _notificationController?.unreadCount ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(
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
        actions: [
          if (isAuth && unreadCount > 0)
            TextButton(
              onPressed: () => _notificationController?.markAllAsRead(),
              child: const Text(
                'Mark all read',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: !isAuth
            ? _buildGuestCard()
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.sm,
                      AppSpacing.lg,
                      0,
                    ),
                    child: Column(
                      children: [
                        // Unread count indicator & Read Filter Chips
                        Row(
                          children: [
                            if (unreadCount > 0)
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
                                  '$unreadCount Unread',
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            const Spacer(),
                            _readFilterChip(NotificationReadFilter.all, 'All'),
                            const SizedBox(width: AppSpacing.xs),
                            _readFilterChip(
                              NotificationReadFilter.unread,
                              'Unread',
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            _readFilterChip(
                              NotificationReadFilter.read,
                              'Read',
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _notificationController?.isLoading == true
                        ? const Center(child: AppLoadingIndicator(size: 32))
                        : notifications.isEmpty
                        ? _buildEmptyState()
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(
                              AppSpacing.lg,
                              AppSpacing.sm,
                              AppSpacing.lg,
                              AppSpacing.xxl,
                            ),
                            physics: const BouncingScrollPhysics(),
                            itemCount: notifications.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: AppSpacing.sm),
                            itemBuilder: (context, i) {
                              final notif = notifications[i];
                              final isRead =
                                  _notificationController?.isNotificationRead(
                                    notif.id,
                                  ) ??
                                  false;

                              return _CustomerNotificationCard(
                                notification: notif,
                                isRead: isRead,
                                onTap: () {
                                  _notificationController?.markAsRead(notif.id);
                                  context.push(
                                    AppRoutes.customerNotificationDetails,
                                    extra: notif,
                                  );
                                },
                                onToggleRead: () {
                                  if (isRead) {
                                    _notificationController?.markAsUnread(
                                      notif.id,
                                    );
                                  } else {
                                    _notificationController?.markAsRead(
                                      notif.id,
                                    );
                                  }
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _readFilterChip(NotificationReadFilter filter, String label) {
    final selected = _notificationController?.selectedReadFilter == filter;
    return GestureDetector(
      onTap: () => _notificationController?.filterByReadState(filter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: AppRadius.borderPill,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.surfaceBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.background : AppColors.textMuted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildGuestCard() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.borderXl,
              border: Border.all(color: AppColors.surfaceBorder),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.notifications_active_rounded,
                  size: 56,
                  color: AppColors.primary,
                ),
                const SizedBox(height: AppSpacing.md),
                const Text(
                  'Sign in to view boutique updates',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                const Text(
                  'Connect your Google account to receive stitching progress notifications and boutique announcements.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                AppButton(
                  text: 'Sign in with Google',
                  icon: Icons.login_rounded,
                  onPressed: () => context.push(AppRoutes.customerProfile),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextButton(
                  onPressed: () => context.pop(),
                  child: const Text(
                    'Continue Browsing',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final filter = _notificationController?.selectedReadFilter;
    final message = switch (filter) {
      NotificationReadFilter.unread => 'You have read all your notifications.',
      NotificationReadFilter.read =>
        'You do not have any read notifications yet.',
      _ => 'You do not have any notifications yet.',
    };

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.notifications_off_rounded,
              color: AppColors.textMuted,
              size: 48,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomerNotificationCard extends StatelessWidget {
  const _CustomerNotificationCard({
    required this.notification,
    required this.isRead,
    required this.onTap,
    required this.onToggleRead,
  });

  final NotificationModel notification;
  final bool isRead;
  final VoidCallback onTap;
  final VoidCallback onToggleRead;

  String _formatRelativeTime(DateTime? dt) {
    if (dt == null) return 'Recent';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final icon = switch (notification.type) {
      NotificationType.general => Icons.notifications_none_rounded,
      NotificationType.stitchingUpdate => Icons.content_cut_rounded,
      NotificationType.designUpdate => Icons.style_rounded,
      NotificationType.boutiqueAnnouncement => Icons.campaign_rounded,
    };

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.borderLg,
          border: Border.all(
            color: isRead
                ? AppColors.surfaceBorder
                : AppColors.primary.withValues(alpha: 0.35),
            width: isRead ? 1.0 : 1.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xs + 2),
              decoration: BoxDecoration(
                color: isRead
                    ? AppColors.surfaceLight
                    : AppColors.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 20,
                color: isRead ? AppColors.textMuted : AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: isRead
                                ? FontWeight.w600
                                : FontWeight.bold,
                          ),
                        ),
                      ),
                      if (!isRead)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(left: 6),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.body,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatRelativeTime(
                          notification.publishedAt ?? notification.createdAt,
                        ),
                        style: const TextStyle(
                          color: AppColors.textHint,
                          fontSize: 11,
                        ),
                      ),
                      if (notification.relatedEntityType != null &&
                          notification.relatedEntityType !=
                              NotificationDestinationType.none)
                        Text(
                          notification.relatedEntityType!.label,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
