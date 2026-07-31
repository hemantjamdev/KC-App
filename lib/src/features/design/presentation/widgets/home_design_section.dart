import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/app_full_screen_image_dialog.dart';
import '../../domain/models/design_model.dart';

/// Horizontal scrollable widget for "Recently Added" designs on Customer Home.
class HomeDesignSection extends StatelessWidget {
  const HomeDesignSection({
    super.key,
    required this.designs,
    required this.onViewAllTap,
  });

  final List<DesignModel> designs;
  final VoidCallback onViewAllTap;

  @override
  Widget build(BuildContext context) {
    if (designs.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recently Added',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: onViewAllTap,
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
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 190,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: designs.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, index) {
              final design = designs[index];
              return _RecentDesignCard(
                design: design,
                onTap: () => context.push(
                  AppRoutes.customerDesignDetails,
                  extra: design,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _RecentDesignCard extends StatelessWidget {
  const _RecentDesignCard({required this.design, required this.onTap});

  final DesignModel design;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.borderLg,
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  final urls = design.imageUrls.isNotEmpty
                      ? design.imageUrls
                      : (design.thumbnailUrl != null ? [design.thumbnailUrl!] : <String>[]);
                  if (urls.isNotEmpty) {
                    AppFullScreenImageDialog.show(context, imageUrls: urls);
                  }
                },
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    design.thumbnailUrl != null
                        ? Image.network(
                            design.thumbnailUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => _fallbackImage(),
                          )
                        : _fallbackImage(),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              AppColors.background.withValues(alpha: 0.6),
                            ],
                            stops: const [0.5, 1.0],
                          ),
                        ),
                      ),
                    ),
                    if (!design.isActive) ...[
                      Container(
                        color: Colors.black.withValues(alpha: 0.3),
                      ),
                      Positioned(
                        top: AppSpacing.xs,
                        left: AppSpacing.xs,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDC2626),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'OUT OF STOCK',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    design.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (design.shortDescription != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      design.shortDescription!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 10,
                      ),
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

  Widget _fallbackImage() {
    return Container(
      color: AppColors.surfaceLight,
      child: const Center(
        child: Icon(Icons.style_outlined, color: AppColors.textMuted, size: 28),
      ),
    );
  }
}
