import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../domain/models/category_model.dart';

/// Reusable editorial category section for the customer home page.
class HomeCategorySection extends StatelessWidget {
  const HomeCategorySection({
    super.key,
    required this.categories,
    required this.onViewAll,
    required this.onCategoryTap,
  });

  final List<CategoryModel> categories;
  final VoidCallback onViewAll;
  final void Function(CategoryModel) onCategoryTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.xl, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Explore Categories',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Browse by collection type',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: onViewAll,
                  child: const Text(
                    'View All',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Horizontal scroll of category cards
          if (categories.isEmpty)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.lg),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadius.borderXl,
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: const Center(
                  child: Text(
                    'Categories are being prepared for this boutique.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                  ),
                ),
              ),
            )
          else
            SizedBox(
              height: 148,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(right: AppSpacing.lg),
                physics: const BouncingScrollPhysics(),
                itemCount: categories.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(width: AppSpacing.md),
                itemBuilder: (context, index) {
                  return _HomeCategoryCard(
                    category: categories[index],
                    onTap: () => onCategoryTap(categories[index]),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _HomeCategoryCard extends StatelessWidget {
  const _HomeCategoryCard({required this.category, required this.onTap});

  final CategoryModel category;
  final VoidCallback onTap;

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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          width: 112,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.borderXl,
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: AppRadius.borderXl,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image or Fallback
                Expanded(
                  child: category.imageUrl != null
                      ? Image.network(
                          category.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _buildFallback(),
                        )
                      : _buildFallback(),
                ),

                // Name label
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  color: AppColors.surfaceLight,
                  child: Text(
                    category.name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFallback() {
    return Container(
      color: AppColors.surfaceLight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _initials,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: AppSpacing.xs - 2),
          const Icon(
            Icons.auto_awesome_rounded,
            color: AppColors.primary,
            size: 14,
          ),
        ],
      ),
    );
  }
}
