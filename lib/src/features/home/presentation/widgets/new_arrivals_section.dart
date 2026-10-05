import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../design/application/providers/favorite_providers.dart';
import '../../../design/domain/models/design_model.dart';

/// New Arrivals Section displaying side-by-side real garment cards.
class NewArrivalsSection extends ConsumerWidget {
  const NewArrivalsSection({super.key, required this.designs});

  final List<DesignModel> designs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (designs.isEmpty) return const SizedBox.shrink();

    final first = designs[0];
    final second = designs.length > 1 ? designs[1] : null;

    return Row(
      children: [
        Expanded(
          child: _NewArrivalCard(design: first),
        ),
        if (second != null) ...[
          const SizedBox(width: 12),
          Expanded(
            child: _NewArrivalCard(design: second),
          ),
        ],
      ],
    );
  }
}

class _NewArrivalCard extends ConsumerWidget {
  const _NewArrivalCard({required this.design});

  final DesignModel design;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = design.name;
    final price = design.price > 0 ? '₹${design.price.toStringAsFixed(0)}' : 'Custom';
    final imgUrl = design.imageUrls.isNotEmpty
        ? design.imageUrls.first
        : (design.thumbnailUrl ?? '');

    final isFav = ref.watch(isDesignFavoritedProvider(design.id));

    return GestureDetector(
      onTap: () => context.push(AppRoutes.customerDesignDetails, extra: design),
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
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
                            size: 36,
                          ),
                        ),
                      ),
              ),

              // Gradient Overlay
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

              // Content Details
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.surfaceWhite,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      price,
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.brandGreen100,
                      ),
                    ),
                  ],
                ),
              ),

              // Heart Icon Button
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceWhite.withValues(alpha: 0.85),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isFav
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    size: 16,
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
