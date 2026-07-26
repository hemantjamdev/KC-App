import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../boutique/presentation/controllers/boutique_selection_controller.dart';
import 'package:kc_app/src/features/auth/presentation/controllers/customer_auth_controller.dart';
import 'package:kc_app/src/features/customer/domain/models/customer_model.dart';

/// Customer Profile Page for KC-App — displays account info, guest sign-in, restricted account state, and sign-out.
class CustomerProfilePage extends StatefulWidget {
  const CustomerProfilePage({super.key});

  @override
  State<CustomerProfilePage> createState() => _CustomerProfilePageState();
}

class _CustomerProfilePageState extends State<CustomerProfilePage> {
  late final CustomerAuthController _authController;

  @override
  void initState() {
    super.initState();
    _authController = CustomerAuthController();
    _authController.addListener(_onUpdate);
  }

  void _onUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _authController.removeListener(_onUpdate);
    _authController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn() async {
    final scope = BoutiqueSelectionScope.of(context);
    final boutiqueId = scope.selectedBoutique?.id ?? 'boutique_01';
    final branchId = scope.selectedBranch?.id ?? 'branch_01';

    final success = await _authController.signInWithGoogle(
      defaultBoutiqueId: boutiqueId,
      defaultBranchId: branchId,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Signed in successfully!'),
          backgroundColor: AppColors.surfaceLight,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _handleSignOut() async {
    await _authController.signOut();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Signed out.'),
          backgroundColor: AppColors.surfaceLight,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  String get _initials {
    final customer = _authController.currentCustomer;
    final name =
        customer?.displayName ??
        _authController.currentFirebaseUser?.displayName ??
        'C';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length.clamp(1, 2)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final selection = BoutiqueSelectionScope.of(context);
    final boutique = selection.selectedBoutique;
    final branch = selection.selectedBranch;

    final isAuth = _authController.isAuthenticated;
    final customer = _authController.currentCustomer;
    final isInactive = _authController.isCustomerInactive;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Customer Profile',
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
          if (isAuth && !isInactive)
            IconButton(
              icon: const Icon(Icons.edit_rounded, color: AppColors.primary),
              tooltip: 'Edit Profile',
              onPressed: () async {
                await context.push(AppRoutes.customerProfileEdit);
                await _authController.refreshProfile();
              },
            ),
        ],
      ),
      body: SafeArea(
        child: _authController.isLoading
            ? const Center(child: AppLoadingIndicator(size: 32))
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (!isAuth) ...[
                          _buildGuestCard(),
                        ] else if (isInactive) ...[
                          _buildInactiveCard(),
                        ] else ...[
                          _buildProfileCard(customer),
                        ],
                        const SizedBox(height: AppSpacing.lg),

                        // Location context card
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: AppRadius.borderLg,
                            border: Border.all(color: AppColors.surfaceBorder),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'SELECTED LOCATION',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                boutique?.name ?? 'No Boutique Selected',
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (branch != null)
                                Text(
                                  '${branch.name} • ${branch.city}',
                                  style: const TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 13,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // My Stitching Orders Card
                        GestureDetector(
                          onTap: () =>
                              context.push(AppRoutes.customerStitchingList),
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: AppRadius.borderLg,
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.3),
                              ),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.content_cut_rounded,
                                  color: AppColors.primary,
                                  size: 24,
                                ),
                                SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'My Stitching Orders',
                                        style: TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'Track progress and view measurements',
                                        style: TextStyle(
                                          color: AppColors.textMuted,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  color: AppColors.primary,
                                ),
                              ],
                            ),
                          ),
                        ),

                        if (isAuth) ...[
                          const SizedBox(height: AppSpacing.xl),
                          AppButton(
                            text: 'Sign Out',
                            variant: AppButtonVariant.secondary,
                            icon: Icons.logout_rounded,
                            onPressed: _handleSignOut,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildGuestCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderXl,
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.account_circle_outlined,
            size: 64,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Sign in to manage your profile',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          const Text(
            'Connect your Google account to save custom preferences and view boutique updates.',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 13,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            text: 'Sign in with Google',
            icon: Icons.login_rounded,
            onPressed: _handleGoogleSignIn,
          ),
        ],
      ),
    );
  }

  Widget _buildInactiveCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderXl,
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            size: 48,
            color: AppColors.warning,
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Account Restricted',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Your customer profile is currently inactive. You can continue browsing or contact the boutique for assistance.',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 14,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(CustomerModel? customer) {
    final user = _authController.currentFirebaseUser;
    final displayName =
        customer?.displayName ?? user?.displayName ?? 'Customer';
    final email = customer?.email ?? user?.email ?? 'No email';
    final phone = customer?.phone ?? user?.phoneNumber;
    final photoUrl = customer?.photoUrl ?? user?.photoURL;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderXl,
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.surfaceLight,
            backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
            child: photoUrl == null
                ? Text(
                    _initials,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            displayName,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
          if (phone != null) ...[
            const SizedBox(height: 2),
            Text(
              phone,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.15),
              borderRadius: AppRadius.borderPill,
            ),
            child: const Text(
              'Signed in with Google',
              style: TextStyle(
                color: AppColors.success,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
