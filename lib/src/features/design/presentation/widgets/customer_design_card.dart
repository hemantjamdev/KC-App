import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/design_model.dart';

import '../../../../core/widgets/app_full_screen_image_dialog.dart';

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
    this.isOutOfStock,
  });

  final DesignModel design;
  final DesignCardVariant variant;
  final String? categoryName;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;
  final bool isFavorite;
  final bool? isOutOfStock;

  bool get _outOfStock => isOutOfStock ?? !design.isActive;

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

  Widget _buildImage(BuildContext context, double? height) {
    final imageUrl =
        design.thumbnailUrl ??
        (design.imageUrls.isNotEmpty ? design.imageUrls.first : null);
    final allUrls = design.imageUrls.isNotEmpty
        ? design.imageUrls
        : (imageUrl != null ? [imageUrl] : <String>[]);

    return GestureDetector(
      onTap: () {
        if (allUrls.isNotEmpty) {
          AppFullScreenImageDialog.show(context, imageUrls: allUrls);
        }
      },
      child: ClipRRect(
        borderRadius: variant == DesignCardVariant.editorial
            ? const BorderRadius.vertical(top: Radius.circular(16))
            : AppRadius.borderMd,
        child: SizedBox(
          width: double.infinity,
          height: height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              imageUrl != null && imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (c, o, s) => _buildPlaceholder(),
                    )
                  : _buildPlaceholder(),

              if (_outOfStock) ...[
                Container(
                  color: Colors.black.withValues(alpha: 0.35),
                ),
                Positioned(
                  top: AppSpacing.xs,
                  left: AppSpacing.xs,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDC2626), // Vivid Red
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Text(
                      'OUT OF STOCK',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
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
              _buildImage(context, 100),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.xs),
                child: Text(
                  design.name,
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
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
              Positioned.fill(child: _buildImage(context, null)),
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
                      style: AppTypography.sectionTitle.copyWith(
                        color: AppColors.surfaceWhite,
                      ),
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
            Expanded(child: _buildImage(context, null)),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (categoryName != null) ...[
                    Text(
                      categoryName!,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.brandGreen700,
                      ),
                    ),
                    const SizedBox(height: 2),
                  ],
                  Text(
                    design.name,
                    style: AppTypography.cardTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (design.shortDescription != null &&
                      design.shortDescription!.isNotEmpty) ...[
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
