import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../design/application/providers/favorite_providers.dart';
import '../../../design/domain/models/design_model.dart';

/// Luxury organic fluid overlay Trending Hero Card for Customer Home.
class TrendingHeroCard extends ConsumerWidget {
  const TrendingHeroCard({super.key, required this.design});

  final DesignModel? design;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (design == null) return const SizedBox.shrink();

    final item = design!;
    final title = item.name;
    final price = item.price > 0 ? '₹${item.price.toStringAsFixed(0)}' : 'Custom';
    final imgUrl = item.imageUrls.isNotEmpty
        ? item.imageUrls.first
        : (item.thumbnailUrl ?? '');

    final isFav = ref.watch(isDesignFavoritedProvider(item.id));
    final displayColors = item.colors;
    final displaySizes = item.sizes;

    return GestureDetector(
      onTap: () {
        context.push(AppRoutes.customerDesignDetails, extra: item);
      },
      child: Container(
        height: 290,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 18,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: Stack(
            children: [
              // Background Image
              Positioned.fill(
                child: imgUrl.isNotEmpty && imgUrl.startsWith('http')
                    ? CachedNetworkImage(
                        imageUrl: imgUrl,
                        fit: BoxFit.cover,
                        errorWidget: (ctx, err, stack) => Container(
                          color: AppColors.brandGreen900,
                        ),
                      )
                    : Container(
                        color: AppColors.brandGreen900,
                        child: const Center(
                          child: Icon(
                            Icons.checkroom_rounded,
                            color: AppColors.brandGreen100,
                            size: 48,
                          ),
                        ),
                      ),
              ),

              // Left Organic Overlay Shape
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: MediaQuery.of(context).size.width * 0.58,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.brandGreen900.withValues(alpha: 0.95),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(80),
                      bottomRight: Radius.circular(80),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.local_florist_rounded,
                            size: 11,
                            color: AppColors.brandGreen100,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'TRENDING',
                            style: GoogleFonts.montserrat(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: AppColors.brandGreen100,
                              letterSpacing: 1.4,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Timeless\nElegance',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.surfaceWhite,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.shortDescription ?? 'Exclusive boutique collection.',
                        style: GoogleFonts.montserrat(
                          fontSize: 9.5,
                          color: AppColors.brandGreen100,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        title,
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.surfaceWhite,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        price,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.surfaceWhite,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Colors Swatches (if present on model)
                      if (displayColors.isNotEmpty)
                        Row(
                          children: displayColors.take(4).map((cStr) {
                            Color c = AppColors.brandGreen100;
                            try {
                              String clean = cStr.trim().replaceAll('#', '');
                              if (clean.startsWith('0x')) clean = clean.substring(2);
                              if (clean.length == 6) clean = 'FF$clean';
                              c = Color(int.parse(clean, radix: 16));
                            } catch (_) {}
                            return Container(
                              margin: const EdgeInsets.only(right: 6),
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: c,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.surfaceWhite,
                                  width: 1,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      if (displayColors.isNotEmpty) const SizedBox(height: 10),

                      // Sizes Pills (if present on model)
                      if (displaySizes.isNotEmpty)
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: displaySizes.take(5).map((s) {
                              return Container(
                                margin: const EdgeInsets.only(right: 4),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: AppColors.brandGreen100
                                        .withValues(alpha: 0.4),
                                  ),
                                ),
                                child: Text(
                                  s,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.brandGreen100,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Right Heart Favorite Icon
              Positioned(
                top: 14,
                right: 14,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceWhite.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isFav
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    size: 18,
                    color: isFav ? AppColors.error : AppColors.charcoal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
