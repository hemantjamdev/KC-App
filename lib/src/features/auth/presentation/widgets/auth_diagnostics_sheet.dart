import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../application/providers/auth_providers.dart';

/// Debug-only diagnostic sheet for inspecting Firebase Auth & Customer Profile state.
class AuthDiagnosticsSheet extends ConsumerWidget {
  const AuthDiagnosticsSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => const AuthDiagnosticsSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(customerSessionProvider);
    final user = session.mapOrNull(authenticated: (s) => s.firebaseUser);
    final customer = session.mapOrNull(authenticated: (s) => s.customer);

    final statusText = session.when(
      initializing: () => 'Initializing',
      guest: () => 'Guest',
      authenticated: (u, c, isLoading, failure) =>
          isLoading ? 'Authenticated (Loading Profile)' : 'Authenticated',
      failure: (f) => 'Failure',
    );

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Authentication Diagnostics',
                style: AppTypography.cardTitle,
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: AppSpacing.sm),
          _item('App Package ID', 'com.kapadacreation.app'),
          _item('Session State', statusText),
          _item('Firebase UID', user?.uid ?? 'None'),
          _item('Auth Email', user?.email ?? 'None'),
          _item('Customer Profile ID', customer?.id ?? 'None'),
          _item(
            'Customer Active Status',
            customer != null
                ? (customer.isActive ? 'Active' : 'Inactive')
                : 'None',
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }

  Widget _item(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.caption),
          Text(
            value,
            style: AppTypography.caption.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.charcoal,
            ),
          ),
        ],
      ),
    );
  }
}
