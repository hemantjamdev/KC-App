import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/app_routes.dart';
import '../../features/auth/application/providers/auth_providers.dart';
import '../../features/auth/presentation/widgets/google_auth_bottom_sheet.dart';
import '../../features/design/application/providers/favorite_providers.dart';
import '../../features/design/domain/models/design_model.dart';
import '../theme/app_colors.dart';

/// Immersive editorial product card for ready-made boutique garments.
class ProductCard extends ConsumerStatefulWidget {
  const ProductCard({
    super.key,
    required this.design,
    this.aspectRatio = 0.78,
    this.onTap,
  });

  final DesignModel design;
  final double aspectRatio;
  final VoidCallback? onTap;

  @override
  ConsumerState<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends ConsumerState<ProductCard> {
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isFavorited = ref.watch(isDesignFavoritedProvider(widget.design.id));
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    final imageUrls = widget.design.imageUrls.isNotEmpty
        ? widget.design.imageUrls
        : (widget.design.thumbnailUrl != null &&
                  widget.design.thumbnailUrl!.isNotEmpty
              ? [widget.design.thumbnailUrl!]
              : <String>[]);

    return GestureDetector(
      onTap:
          widget.onTap ??
          () => context.push(
            AppRoutes.customerDesignDetails,
            extra: widget.design,
          ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderSoft),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image Banner Area ──────────────────────────────
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(15),
                      ),
                      child: imageUrls.isNotEmpty
                          ? PageView.builder(
                              itemCount: imageUrls.length,
                              onPageChanged: (idx) {
                                setState(() => _currentImageIndex = idx);
                              },
                              itemBuilder: (ctx, idx) => CachedNetworkImage(
                                imageUrl: imageUrls[idx],
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: AppColors.softCream,
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.brandGreen800,
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: AppColors.softCream,
                                  child: const Center(
                                    child: Icon(
                                      Icons.checkroom_rounded,
                                      size: 32,
                                      color: AppColors.mutedText,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              color: AppColors.softCream,
                              child: const Center(
                                child: Icon(
                                  Icons.checkroom_rounded,
                                  size: 32,
                                  color: AppColors.mutedText,
                                ),
                              ),
                            ),
                    ),
                  ),

                  // Out of Stock Overlay
                  if (!widget.design.isActive)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.4),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(15),
                          ),
                        ),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceWhite,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'OUT OF STOCK',
                              style: GoogleFonts.montserrat(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.charcoal,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Multi-image Page Indicator
                  if (imageUrls.length > 1)
                    Positioned(
                      bottom: 8,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(imageUrls.length, (idx) {
                          final isActive = idx == _currentImageIndex;
                          return Container(
                            width: isActive ? 12 : 5,
                            height: 5,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? AppColors.surfaceWhite
                                  : AppColors.surfaceWhite.withValues(
                                      alpha: 0.5,
                                    ),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          );
                        }),
                      ),
                    ),

                  // Favorite Button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () async {
                        if (!isAuthenticated) {
                          final loggedIn = await GoogleAuthBottomSheet.show(
                            context,
                            title: 'Save Favorites',
                            message:
                                'Sign in with Google to save styles you love.',
                          );
                          if (!loggedIn) return;
                        }
                        await ref
                            .read(favoriteMutationProvider.notifier)
                            .toggleFavorite(widget.design.id);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceWhite.withValues(alpha: 0.85),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isFavorited
                              ? Icons.favorite_rounded
                              : Icons.favorite_outline_rounded,
                          size: 18,
                          color: isFavorited
                              ? const Color(0xFFCC4B37)
                              : AppColors.charcoal,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Text Content ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.design.name,
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.charcoal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (widget.design.price > 0)
                        Text(
                          '₹${widget.design.price.toStringAsFixed(0)}',
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.brandGreen900,
                          ),
                        )
                      else
                        Text(
                          'Bespoke',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                            color: AppColors.mutedGold,
                          ),
                        ),
                      if (widget.design.sizes.isNotEmpty)
                        Text(
                          widget.design.sizes.first,
                          style: GoogleFonts.montserrat(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.mutedText,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
