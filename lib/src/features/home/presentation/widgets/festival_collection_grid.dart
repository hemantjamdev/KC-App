import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../category/domain/models/category_model.dart';

/// Festival Collection Grid displaying real category details from Firestore.
class FestivalCollectionGrid extends StatelessWidget {
  const FestivalCollectionGrid({super.key, required this.festiveCategory});

  final CategoryModel festiveCategory;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(
        AppRoutes.customerCategoryDesigns,
        extra: festiveCategory,
      ),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Positioned.fill(
                child: festiveCategory.imageUrl != null &&
                        festiveCategory.imageUrl!.startsWith('http')
                    ? CachedNetworkImage(
                        imageUrl: festiveCategory.imageUrl!,
                        fit: BoxFit.cover,
                        errorWidget: (ctx, err, stack) => Container(
                          color: AppColors.brandGreen900,
                        ),
                      )
                    : Container(
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
                      ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.8),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      festiveCategory.name,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.surfaceWhite,
                      ),
                    ),
                    if (festiveCategory.description != null &&
                        festiveCategory.description!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        festiveCategory.description!,
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
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
  }
}
