import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../auth/presentation/controllers/customer_auth_controller.dart';
import '../../../boutique/presentation/controllers/boutique_selection_controller.dart';

/// Welcome Page for Kapada Creation Customer application.
class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
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
    final selection = BoutiqueSelectionScope.of(context);
    final boutiqueId = selection.selectedBoutique?.id ?? 'boutique_01';
    final branchId = selection.selectedBranch?.id ?? 'branch_01';

    final success = await _authController.signInWithGoogle(
      defaultBoutiqueId: boutiqueId,
      defaultBranchId: branchId,
    );

    if (success && mounted) {
      context.go(AppRoutes.customerHome);
    } else if (mounted && _authController.authError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_authController.authError!),
          backgroundColor: AppColors.surfaceLight,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom -
                    AppSpacing.lg * 2,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top Brand Header
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.md),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.auto_awesome_rounded,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          'KAPADA CREATION',
                          style: TextStyle(
                            color: AppColors.textPrimary.withValues(alpha: 0.9),
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.5,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        const Icon(
                          Icons.auto_awesome_rounded,
                          size: 16,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),

                  // Hero Visual Area
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.xl,
                    ),
                    child: Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 400),
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.surfaceLight, AppColors.surface],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: AppRadius.borderXl,
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.35),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.accentGlow,
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.4),
                              ),
                            ),
                            child: const Icon(
                              Icons.style_rounded,
                              size: 36,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          const Text(
                            'Discover Exclusive\nBoutique Designs',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              height: 1.25,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          const Text(
                            'Explore curated collections, traditional craftsmanship, and custom tailoring tailored just for you.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Action Buttons Section
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Column(
                      children: [
                        // Primary Action: Explore Designs
                        AppButton(
                          text: 'Explore Designs',
                          icon: Icons.explore_outlined,
                          onPressed: () =>
                              context.go(AppRoutes.customerSelectBoutique),
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Secondary Action: Sign in with Google
                        AppButton(
                          text: 'Sign in with Google',
                          variant: AppButtonVariant.secondary,
                          icon: Icons.g_mobiledata_rounded,
                          isLoading: _authController.isLoading,
                          onPressed: _authController.isLoading
                              ? null
                              : _handleGoogleSignIn,
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Browsing Info Note
                        const Text(
                          'You can browse all designs freely without signing in.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
