import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../application/providers/auth_providers.dart';

/// Editorial Google Auth Bottom Sheet shown when guest attempts a protected action
/// (Favorites, My Stitching, Create Stitching Request).
class GoogleAuthBottomSheet extends ConsumerWidget {
  const GoogleAuthBottomSheet({super.key, this.title, this.message});

  final String? title;
  final String? message;

  static Future<bool> show(
    BuildContext context, {
    String? title,
    String? message,
  }) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.surfaceWhite,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => GoogleAuthBottomSheet(title: title, message: message),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(googleAuthNotifierProvider);
    final isLoading = authState.isLoading;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.borderSoft,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Logo / Icon
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              color: AppColors.brandGreen50,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_outline_rounded,
              color: AppColors.brandGreen800,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            title ?? 'Sign in to Continue',
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.charcoal,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Message
          Text(
            message ??
                'Save your favorite boutique styles and track your custom stitching orders seamlessly.',
            style: GoogleFonts.montserrat(
              fontSize: 13,
              color: AppColors.mutedText,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),

          // Google Sign-In Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.brandGreen800,
                      strokeWidth: 2,
                    ),
                  )
                : ElevatedButton(
                    onPressed: () async {
                      final success = await ref
                          .read(customerSessionProvider.notifier)
                          .signInWithGoogle();
                      if (success && context.mounted) {
                        Navigator.pop(context, true);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandGreen900,
                      foregroundColor: AppColors.surfaceWhite,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.surfaceWhite,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            'G',
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.brandGreen900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Continue with Google',
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: 12),

          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Explore as Guest',
              style: GoogleFonts.montserrat(
                fontSize: 13,
                color: AppColors.mutedText,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}
