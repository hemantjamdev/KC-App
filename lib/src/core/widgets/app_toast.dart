import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../theme/app_colors.dart';

enum ToastType { success, error, warning, info }

/// Reusable toast notification component for Kapada Creation.
/// Features dynamic border colors based on ToastType (success, error, warning, info).
class AppToast {
  const AppToast._();

  static void show(
    BuildContext context,
    String message, {
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    final (iconData, borderColor, iconColor) = switch (type) {
      ToastType.success => (
        PhosphorIcons.checkCircle(PhosphorIconsStyle.bold),
        const Color(0xFF10B981),
        const Color(0xFF10B981),
      ),
      ToastType.error => (
        PhosphorIcons.warningCircle(PhosphorIconsStyle.bold),
        const Color(0xFFDC2626),
        const Color(0xFFDC2626),
      ),
      ToastType.warning => (
        PhosphorIcons.warning(PhosphorIconsStyle.bold),
        const Color(0xFFD97706),
        const Color(0xFFD97706),
      ),
      ToastType.info => (
        PhosphorIcons.info(PhosphorIconsStyle.bold),
        AppColors.primary,
        AppColors.primary,
      ),
    };

    messenger.showSnackBar(
      SnackBar(
        duration: duration,
        elevation: 0,
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: EdgeInsets.zero,
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              PhosphorIcon(iconData, color: iconColor, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: GoogleFonts.montserrat(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
