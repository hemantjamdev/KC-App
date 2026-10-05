import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/application/providers/auth_providers.dart';

/// Modular Sign Out Button & Confirmation Dialog widget.
class ProfileSignOutButton extends ConsumerWidget {
  const ProfileSignOutButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text(
                'Sign Out',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              content: Text(
                'Are you sure you want to sign out of Kapada Creation?',
                style: GoogleFonts.montserrat(fontSize: 13),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                  ),
                  child: const Text('Sign Out'),
                ),
              ],
            ),
          );

          if (confirm == true) {
            await ref.read(googleAuthNotifierProvider.notifier).signOut();
            if (context.mounted) {
              context.go(AppRoutes.customerHome);
            }
          }
        },
        icon: const Icon(
          Icons.logout_rounded,
          color: AppColors.error,
          size: 18,
        ),
        label: Text(
          'Logout Account',
          style: GoogleFonts.montserrat(
            color: AppColors.error,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.error),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
