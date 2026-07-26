import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../boutique/presentation/controllers/boutique_selection_controller.dart';
import '../../domain/models/category_model.dart';

/// Category Preview Page — shown until Slice 4 implements design listings.
class CategoryPreviewPage extends StatelessWidget {
  const CategoryPreviewPage({super.key, required this.category});

  final CategoryModel category;

  String get _initials {
    final parts = category.name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return category.name
        .substring(0, category.name.length.clamp(1, 2))
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final controller = BoutiqueSelectionScope.of(context);
    final boutique = controller.selectedBoutique;
    final branch = controller.selectedBranch;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          category.name,
          style: const TextStyle(
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
          onPressed: () => context.go(AppRoutes.customerCategoryList),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Category image or fallback
                  ClipRRect(
                    borderRadius: AppRadius.borderXl,
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.2),
                        ),
                        borderRadius: AppRadius.borderXl,
                      ),
                      child: category.imageUrl != null
                          ? Image.network(
                              category.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => _buildFallbackHero(),
                            )
                          : _buildFallbackHero(),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Category name & description
                  Text(
                    category.name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                  if (category.description != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      category.description!,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ],

                  const SizedBox(height: AppSpacing.xl),

                  // Context info
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppRadius.borderLg,
                      border: Border.all(color: AppColors.surfaceBorder),
                    ),
                    child: Column(
                      children: [
                        _InfoRow(
                          icon: Icons.storefront_rounded,
                          label: 'Boutique',
                          value: boutique?.name ?? '—',
                        ),
                        const Divider(
                          color: AppColors.surfaceBorder,
                          height: AppSpacing.lg,
                        ),
                        _InfoRow(
                          icon: Icons.location_on_rounded,
                          label: 'Branch',
                          value: branch?.name ?? '—',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Coming-soon notice
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.accentGlow,
                      borderRadius: AppRadius.borderLg,
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.35),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.auto_awesome_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            'Designs for this category will be added in Slice 4.',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  AppButton(
                    text: 'Back to categories',
                    variant: AppButtonVariant.secondary,
                    icon: Icons.arrow_back_rounded,
                    onPressed: () => context.go(AppRoutes.customerCategoryList),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackHero() {
    return Container(
      color: AppColors.surfaceLight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _initials,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 48,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Icon(
            Icons.auto_awesome_rounded,
            color: AppColors.primary,
            size: 20,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: AppSpacing.sm),
        Text(
          '$label:',
          style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
