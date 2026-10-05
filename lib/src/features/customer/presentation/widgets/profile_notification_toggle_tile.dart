import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../auth/application/providers/auth_providers.dart';
import '../../../auth/presentation/widgets/google_auth_bottom_sheet.dart';
import '../../../notification/application/providers/notification_providers.dart';
import '../../application/providers/customer_providers.dart';

/// Fully functional Push Notification Toggle Tile for Customer Profile.
class ProfileNotificationToggleTile extends ConsumerStatefulWidget {
  const ProfileNotificationToggleTile({super.key});

  @override
  ConsumerState<ProfileNotificationToggleTile> createState() =>
      _ProfileNotificationToggleTileState();
}

class _ProfileNotificationToggleTileState
    extends ConsumerState<ProfileNotificationToggleTile> {
  bool _isToggling = false;

  Future<void> _handleToggle(bool targetState) async {
    final isAuthenticated = ref.read(isAuthenticatedProvider);
    final user = ref.read(currentCustomerUserProvider);
    final profile = ref.read(customerProfileProvider).valueOrNull;

    if (!isAuthenticated || user == null) {
      await GoogleAuthBottomSheet.show(
        context,
        title: 'Notification Settings',
        message: 'Sign in with Google to customize your push notification preferences.',
      );
      return;
    }

    if (_isToggling) return;
    setState(() => _isToggling = true);

    try {
      if (targetState == true) {
        // Checking system notification permission status
        final permStatus = await Permission.notification.status;
        if (permStatus.isPermanentlyDenied) {
          if (mounted) {
            AppToast.show(
              context,
              'Notification permission is disabled in system settings. Opening App Settings...',
              type: ToastType.warning,
            );
          }
          await openAppSettings();
          setState(() => _isToggling = false);
          return;
        }

        // Request system permission if needed
        if (!permStatus.isGranted) {
          await ref
              .read(notificationPermissionProvider.notifier)
              .requestPermission(customerUid: user.uid);
        }

        // Initialize FCM Token & Messaging
        await ref
            .read(notificationMessagingProvider.notifier)
            .initializeForUser(uid: user.uid);

        // Update Firestore profile preference
        if (profile != null) {
          final updated = profile.copyWith(
            notificationsEnabled: true,
            updatedAt: DateTime.now(),
            updatedBy: user.uid,
          );
          await ref.read(customerRepositoryProvider).updateCustomer(updated);
        }

        ref.invalidate(customerProfileProvider);

        if (mounted) {
          AppToast.show(
            context,
            'Push notifications enabled for tailoring updates',
            type: ToastType.success,
          );
        }
      } else {
        // Deactivate FCM token & update Firestore
        await ref.read(firebaseMessagingServiceProvider).onLogout();

        if (profile != null) {
          final updated = profile.copyWith(
            notificationsEnabled: false,
            updatedAt: DateTime.now(),
            updatedBy: user.uid,
          );
          await ref.read(customerRepositoryProvider).updateCustomer(updated);
        }

        ref.invalidate(customerProfileProvider);

        if (mounted) {
          AppToast.show(
            context,
            'Push notifications turned off',
            type: ToastType.info,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        AppToast.show(
          context,
          'Failed to update notification settings: $e',
          type: ToastType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isToggling = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(customerProfileProvider).valueOrNull;
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    final bool isNotificationsOn =
        isAuthenticated ? (profile?.notificationsEnabled ?? true) : false;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSoft),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isNotificationsOn
                  ? AppColors.brandGreen50
                  : AppColors.warmIvory,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isNotificationsOn
                  ? Icons.notifications_active_rounded
                  : Icons.notifications_off_outlined,
              size: 22,
              color: isNotificationsOn
                  ? AppColors.primary
                  : AppColors.textMuted,
            ),
          ),
          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        'Push Notifications',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isNotificationsOn
                            ? AppColors.success.withValues(alpha: 0.12)
                            : AppColors.textMuted.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        isNotificationsOn ? 'ACTIVE' : 'OFF',
                        style: GoogleFonts.montserrat(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: isNotificationsOn
                              ? AppColors.success
                              : AppColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  isNotificationsOn
                      ? 'Receiving stitching status & studio alerts'
                      : 'All push notifications disabled for this device',
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          _isToggling
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.primary,
                  ),
                )
              : Switch.adaptive(
                  value: isNotificationsOn,
                  activeThumbColor: AppColors.primary,
                  activeTrackColor: AppColors.brandGreen100,
                  onChanged: (val) => _handleToggle(val),
                ),
        ],
      ),
    );
  }
}
