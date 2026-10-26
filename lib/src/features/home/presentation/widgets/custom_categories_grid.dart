import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../category/domain/models/category_model.dart';

/// Grid displaying curated boutique categories on the home page.
class CustomCategoriesGrid extends StatelessWidget {
  const CustomCategoriesGrid({
    super.key,
    required this.categories,
    this.maxCount = 4,
    this.onViewAll,
  });

  final List<CategoryModel> categories;
  final int? maxCount;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();

    final displayList = maxCount != null ? categories.take(maxCount!).toList() : categories;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.15,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: displayList.length,
            itemBuilder: (context, index) {
              final category = displayList[index];
              final hasImg = category.imageUrl != null &&
                  category.imageUrl!.startsWith('http');

              return GestureDetector(
                onTap: () => context.push(
                  AppRoutes.customerCategoryDesigns,
                  extra: category,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceWhite,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.borderSoft),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      children: [
                        if (hasImg)
                          Positioned.fill(
                            child: CachedNetworkImage(
                              imageUrl: category.imageUrl!,
                              fit: BoxFit.cover,
                              errorWidget: (ctx, err, stack) =>
                                  _buildFallbackGradient(),
                            ),
                          )
                        else
                          Positioned.fill(
                            child: _buildFallbackGradient(),
                          ),

                        // Elegant Luxury Dark Overlay Gradient
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.2),
                                  Colors.black.withValues(alpha: 0.78),
                                ],
                                stops: const [0.0, 0.45, 1.0],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ),

                        Positioned(
                          bottom: 12,
                          left: 12,
                          right: 12,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                category.name,
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.surfaceWhite,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (category.description != null &&
                                  category.description!.trim().isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  category.description!.trim(),
                                  style: GoogleFonts.montserrat(
                                    fontSize: 10,
                                    color: AppColors.brandGreen100,
                                  ),
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
                ),
              );
            },
          ),
          if (onViewAll != null) ...[
            const SizedBox(height: 12),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onViewAll,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.brandGreen900.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.grid_view_rounded,
                      size: 15,
                      color: AppColors.brandGreen900,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Browse All Collections (${categories.length})',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.brandGreen900,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 14,
                      color: AppColors.brandGreen900,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFallbackGradient() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.brandGreen900,
            AppColors.brandGreen800,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.checkroom_rounded,
          color: AppColors.brandGreen100,
          size: 32,
        ),
      ),
    );
  }
}
