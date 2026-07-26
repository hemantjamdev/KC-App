import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/design_model.dart';

enum DesignCardVariant { compact, grid, featured, editorial }

/// Reusable branded design card component for KC-App.
class CustomerDesignCard extends StatelessWidget {
  const CustomerDesignCard({
    super.key,
    required this.design,
    this.variant = DesignCardVariant.grid,
    this.categoryName,
    this.onTap,
    this.onFavoriteToggle,
    this.isFavorite = false,
  });

  final DesignModel design;
  final DesignCardVariant variant;
  final String? categoryName;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;
  final bool isFavorite;

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.brandGreen50,
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.checkroom_rounded,
              color: AppColors.brandGreen700,
              size: 32,
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              'Kapada Creation',
              style: TextStyle(
                color: AppColors.brandGreen800,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(double? height) {
    final imageUrl = design.thumbnailUrl ?? (design.imageUrls.isNotEmpty ? design.imageUrls.first : null);

    return ClipRRect(
      borderRadius: variant == DesignCardVariant.editorial
          ? const BorderRadius.vertical(top: Radius.circular(16))
          : AppRadius.borderMd,
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: imageUrl != null && imageUrl.isNotEmpty
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (c, o, s) => _buildPlaceholder(),
              )
            : _buildPlaceholder(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (variant == DesignCardVariant.compact) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: 140,
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: AppRadius.borderMd,
            border: Border.all(color: AppColors.borderSoft),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImage(100),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.xs),
                child: Text(
                  design.name,
                  style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (variant == DesignCardVariant.featured) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 220,
          decoration: BoxDecoration(
            borderRadius: AppRadius.borderLg,
            border: Border.all(color: AppColors.borderSoft),
          ),
          child: Stack(
            children: [
              Positioned.fill(child: _buildImage(null)),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: AppRadius.borderLg,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: AppSpacing.md,
                left: AppSpacing.md,
                right: AppSpacing.md,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (categoryName != null)
                      Text(
                        categoryName!.toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.brandGreen100,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    Text(
                      design.name,
                      style: AppTypography.sectionTitle.copyWith(color: AppColors.surfaceWhite),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Default Grid or Editorial card
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: AppRadius.borderLg,
          border: Border.all(color: AppColors.borderSoft),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildImage(null)),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (categoryName != null) ...[
                    Text(
                      categoryName!,
                      style: AppTypography.caption.copyWith(color: AppColors.brandGreen700),
                    ),
                    const SizedBox(height: 2),
                  ],
                  Text(
                    design.name,
                    style: AppTypography.cardTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (design.shortDescription != null && design.shortDescription!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      design.shortDescription!,
                      style: AppTypography.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
