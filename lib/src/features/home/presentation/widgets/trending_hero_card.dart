import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/widgets/google_auth_bottom_sheet.dart';
import '../../../design/application/providers/favorite_providers.dart';
import '../../../design/domain/models/design_model.dart';

/// Ultra-luxury portrait Trending Garment Card for Customer Home Carousel.
/// Showcases full-bleed boutique imagery without obscuring the garment.
class TrendingHeroCard extends ConsumerWidget {
  const TrendingHeroCard({
    super.key,
    required this.design,
    this.rankIndex = 1,
  });

  final DesignModel? design;
  final int rankIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (design == null) return const SizedBox.shrink();

    final item = design!;
    final title = item.name;
    final price = item.price > 0 ? '₹${item.price.toStringAsFixed(0)}' : 'Custom Price';
    final imgUrl = item.imageUrls.isNotEmpty
        ? item.imageUrls.first
        : (item.thumbnailUrl ?? '');

    final isFav = ref.watch(isDesignFavoritedProvider(item.id));
    final displayColors = item.colors;

    return GestureDetector(
      onTap: () {
        context.push(AppRoutes.customerDesignDetails, extra: item);
      },
      child: Container(
        width: 250,
        height: 330,
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: AppColors.borderSoft,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: [
              // 1. Full Garment Photo
              Positioned.fill(
                child: imgUrl.isNotEmpty && imgUrl.startsWith('http')
                    ? CachedNetworkImage(
                        imageUrl: imgUrl,
                        fit: BoxFit.cover,
                        errorWidget: (ctx, err, stack) => _buildFallback(),
                      )
                    : _buildFallback(),
              ),

              // 2. Elegant Bottom Gradient (Vignette)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.1),
                        Colors.black.withValues(alpha: 0.75),
                        Colors.black.withValues(alpha: 0.92),
                      ],
                      stops: const [0.0, 0.45, 0.75, 1.0],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),

              // 3. Top Rank Badge (#1 TRENDING)
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.goldAccent.withValues(alpha: 0.6),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.local_fire_department_rounded,
                        size: 13,
                        color: AppColors.goldAccent,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '#$rankIndex TRENDING',
                        style: GoogleFonts.montserrat(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.surfaceWhite,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 4. Top Right Favorite Heart Button
              Positioned(
                top: 12,
                right: 12,
                child: GestureDetector(
                  onTap: () async {
                    final success = await ref
                        .read(favoriteMutationProvider.notifier)
                        .toggleFavorite(item.id);
                    if (!success && context.mounted) {
                      await GoogleAuthBottomSheet.show(context);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      isFav
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      size: 17,
                      color: isFav ? AppColors.error : AppColors.surfaceWhite,
                    ),
                  ),
                ),
              ),

              // 5. Floating Bottom Information Overlay
              Positioned(
                left: 14,
                right: 14,
                bottom: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (item.tags.isNotEmpty)
                      Text(
                        item.tags.first.toUpperCase(),
                        style: GoogleFonts.montserrat(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.goldAccent,
                          letterSpacing: 1.1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 3),
                    Text(
                      title,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.surfaceWhite,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          price,
                          style: GoogleFonts.montserrat(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.surfaceWhite,
                          ),
                        ),
                        if (displayColors.isNotEmpty)
                          Row(
                            children: displayColors.take(3).map((cStr) {
                              Color c = AppColors.brandGreen100;
                              try {
                                String clean = cStr.trim().replaceAll('#', '');
                                if (clean.startsWith('0x')) clean = clean.substring(2);
                                if (clean.length == 6) clean = 'FF$clean';
                                c = Color(int.parse(clean, radix: 16));
                              } catch (_) {}
                              return Container(
                                margin: const EdgeInsets.only(left: 4),
                                width: 9,
                                height: 9,
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
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFallback() {
    return Container(
      color: AppColors.brandGreen900,
      child: const Center(
        child: Icon(
          Icons.checkroom_rounded,
          color: AppColors.brandGreen100,
          size: 48,
        ),
      ),
    );
  }
}
