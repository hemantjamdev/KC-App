import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/navigation/navigation_extensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../data/repositories/boutique_firestore_repository.dart';
import '../../domain/models/boutique_model.dart';
import '../controllers/boutique_selection_controller.dart';

/// Customer Boutique Selection Page for Slice 2.
class CustomerBoutiqueSelectionPage extends StatefulWidget {
  const CustomerBoutiqueSelectionPage({super.key});

  @override
  State<CustomerBoutiqueSelectionPage> createState() =>
      _CustomerBoutiqueSelectionPageState();
}

class _CustomerBoutiqueSelectionPageState
    extends State<CustomerBoutiqueSelectionPage> {
  final _repository = BoutiqueFirestoreRepository();
  bool _isLoading = true;
  List<BoutiqueModel> _activeBoutiques = [];

  @override
  void initState() {
    super.initState();
    _loadBoutiques();
  }

  Future<void> _loadBoutiques() async {
    final list = await _repository.getBoutiques();
    if (!mounted) return;

    setState(() {
      _activeBoutiques = list.where((b) => b.isActive).toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = BoutiqueSelectionScope.of(context);
    final selectedBoutique = controller.selectedBoutique;

    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (context.mounted) context.popOrGo(AppRoutes.welcome);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(
            'Select Boutique',
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
            onPressed: () => context.popOrGo(AppRoutes.welcome),
          ),
        ),
        body: SafeArea(
          child: _isLoading
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppLoadingIndicator(size: 32),
                      SizedBox(height: AppSpacing.md),
                      Text(
                        'Loading boutique collections...',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Header banner
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: AppRadius.borderLg,
                              border: Border.all(
                                color: AppColors.surfaceBorder,
                              ),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.storefront_rounded,
                                  color: AppColors.primary,
                                  size: 24,
                                ),
                                SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Text(
                                    'Choose a boutique to view tailored catalog items and location-based details.',
                                    style: TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 13,
                                      height: 1.35,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: AppSpacing.xl),

                          // Boutique Cards List
                          if (_activeBoutiques.isEmpty)
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.xl),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: AppRadius.borderLg,
                                border: Border.all(
                                  color: AppColors.surfaceBorder,
                                ),
                              ),
                              child: const Column(
                                children: [
                                  Icon(
                                    Icons.info_outline_rounded,
                                    color: AppColors.textMuted,
                                    size: 36,
                                  ),
                                  SizedBox(height: AppSpacing.md),
                                  Text(
                                    'No active boutiques available right now.',
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _activeBoutiques.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: AppSpacing.md),
                              itemBuilder: (context, index) {
                                final boutique = _activeBoutiques[index];
                                final isSelected =
                                    selectedBoutique?.id == boutique.id;

                                return _CustomerBoutiqueCard(
                                  boutique: boutique,
                                  isSelected: isSelected,
                                  onTap: () =>
                                      controller.selectBoutique(boutique),
                                );
                              },
                            ),

                          const SizedBox(height: AppSpacing.xxl),

                          // Primary Action Button
                          AppButton(
                            text: 'Continue',
                            icon: Icons.arrow_forward_rounded,
                            onPressed: selectedBoutique == null
                                ? null
                                : () => context.push(
                                    AppRoutes.customerSelectBranch,
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

class _CustomerBoutiqueCard extends StatelessWidget {
  const _CustomerBoutiqueCard({
    required this.boutique,
    required this.isSelected,
    required this.onTap,
  });

  final BoutiqueModel boutique;
  final bool isSelected;
  final VoidCallback onTap;

  String get _initials {
    final parts = boutique.name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return boutique.name.substring(0, 2).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.surfaceLight : AppColors.surface,
        borderRadius: AppRadius.borderXl,
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.surfaceBorder,
          width: isSelected ? 2.0 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.25)
                : Colors.black.withValues(alpha: 0.2),
            blurRadius: isSelected ? 16 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          borderRadius: AppRadius.borderXl,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                // Fashion Emblem Avatar
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [AppColors.primaryLight, AppColors.primary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: isSelected ? null : AppColors.surfaceBorder,
                  ),
                  child: Center(
                    child: Text(
                      _initials,
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.background
                            : AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),

                // Boutique details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        boutique.name,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs - 2),
                      Text(
                        boutique.subtitle,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: AppSpacing.sm),

                // Radio Indicator
                Icon(
                  isSelected
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: isSelected ? AppColors.primary : AppColors.textMuted,
                  size: 26,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
