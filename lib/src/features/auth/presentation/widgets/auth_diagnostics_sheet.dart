import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../controllers/customer_auth_controller.dart';

/// Debug-only diagnostic sheet for inspecting Firebase Auth & Customer Profile state.
class AuthDiagnosticsSheet extends StatelessWidget {
  const AuthDiagnosticsSheet({
    super.key,
    required this.authController,
  });

  final CustomerAuthController authController;

  static void show(BuildContext context, CustomerAuthController authController) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => AuthDiagnosticsSheet(authController: authController),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = authController.currentFirebaseUser;
    final customer = authController.currentCustomer;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Authentication Diagnostics', style: AppTypography.cardTitle),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: AppSpacing.sm),
          _item('App Package ID', 'com.kapadacreation.app'),
          _item('Firebase Auth Status', user != null ? 'Authenticated' : 'Unauthenticated'),
          _item('Firebase UID', user?.uid ?? 'None'),
          _item('Auth Email', user?.email ?? 'None'),
          _item('Customer Profile ID', customer?.id ?? 'None'),
          _item('Customer Active Status', customer != null ? (customer.isActive ? 'Active' : 'Inactive') : 'None'),
          _item('Last Error Category', authController.errorCategory?.name ?? 'None'),
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
