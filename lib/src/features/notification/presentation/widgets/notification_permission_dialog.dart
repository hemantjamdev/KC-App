import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';

/// Contextual explanation dialog for runtime notification permission requests.
class NotificationPermissionDialog extends StatelessWidget {
  const NotificationPermissionDialog({
    super.key,
    required this.onEnable,
    required this.onCancel,
  });

  final VoidCallback onEnable;
  final VoidCallback onCancel;

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => NotificationPermissionDialog(
        onEnable: () => Navigator.of(ctx).pop(true),
        onCancel: () => Navigator.of(ctx).pop(false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surfaceWhite,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderLg),
      contentPadding: const EdgeInsets.all(AppSpacing.xl),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: const BoxDecoration(
              color: AppColors.brandGreen50,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_active_rounded,
              size: 40,
              color: AppColors.brandGreen800,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Stay Updated',
            style: AppTypography.cardTitle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Get real-time updates when your stitching order progresses or when your boutique publishes new collections and announcements.',
            style: AppTypography.body.copyWith(color: AppColors.mutedText),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            text: 'Enable Notifications',
            icon: Icons.check_circle_rounded,
            onPressed: onEnable,
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton(
            onPressed: onCancel,
            child: Text(
              'Not Now',
              style: AppTypography.caption.copyWith(
                color: AppColors.mutedText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
