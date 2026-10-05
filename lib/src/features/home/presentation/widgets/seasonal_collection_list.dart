import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../category/domain/models/category_model.dart';

/// Horizontal scrollable Seasonal Category card display.
class SeasonalCollectionList extends StatelessWidget {
  const SeasonalCollectionList({super.key, required this.seasonalCategory});

  final CategoryModel seasonalCategory;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () => context.push(
          AppRoutes.customerCategoryDesigns,
          extra: seasonalCategory,
        ),
        child: Container(
          height: 140,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              children: [
                Positioned.fill(
                  child: seasonalCategory.imageUrl != null &&
                          seasonalCategory.imageUrl!.startsWith('http')
                      ? CachedNetworkImage(
                          imageUrl: seasonalCategory.imageUrl!,
                          fit: BoxFit.cover,
                          errorWidget: (ctx, err, stack) => Container(
                            color: AppColors.brandGreen900,
                          ),
                        )
                      : Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.brandGreen800,
                                AppColors.brandGreen900,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.75),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 14,
                  left: 14,
                  right: 14,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        seasonalCategory.name,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.surfaceWhite,
                        ),
                      ),
                      if (seasonalCategory.description != null &&
                          seasonalCategory.description!.isNotEmpty)
                        Text(
                          seasonalCategory.description!,
                          style: GoogleFonts.montserrat(
                            fontSize: 11,
                            color: AppColors.brandGreen100,
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
        ),
      ),
    );
  }
}
