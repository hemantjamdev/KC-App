import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../auth/application/providers/auth_providers.dart';
import '../../../auth/presentation/widgets/google_auth_bottom_sheet.dart';
import '../../../design/application/providers/favorite_providers.dart';
import '../../../design/domain/models/design_model.dart';
import '../../application/providers/trending_pagination_provider.dart';
import 'double_tap_heart_overlay.dart';

/// Luxury Grid Card Item for the Paginated Trending Listing Page.
/// Features double-tap to like with heart animation overlay, bookmark button,
/// rank badge, and details page navigation.
class TrendingGridItem extends ConsumerStatefulWidget {
  const TrendingGridItem({
    super.key,
    required this.design,
    required this.rankIndex,
  });

  final DesignModel design;
  final int rankIndex;

  @override
  ConsumerState<TrendingGridItem> createState() => _TrendingGridItemState();
}

class _TrendingGridItemState extends ConsumerState<TrendingGridItem> {
  bool _showHeartAnimation = false;

  void _handleDoubleTap() {
    setState(() => _showHeartAnimation = true);

    ref
        .read(trendingPaginationProvider.notifier)
        .toggleLike(widget.design.id);

    AppToast.show(
      context,
      'Liked "${widget.design.name}"! ❤️',
      type: ToastType.success,
    );
  }

  Future<void> _handleFavoriteToggle() async {
    final isAuthenticated = ref.read(isAuthenticatedProvider);
    final user = ref.read(currentCustomerUserProvider);

    if (!isAuthenticated || user == null) {
      await GoogleAuthBottomSheet.show(
        context,
        title: 'Save to Favorites',
        message: 'Sign in with Google to save this trending style across devices.',
      );
      return;
    }

    final isFav = ref.read(isDesignFavoritedProvider(widget.design.id));
    await ref
        .read(favoriteMutationProvider.notifier)
        .toggleFavorite(widget.design.id);

    if (mounted) {
      AppToast.show(
        context,
        !isFav ? 'Added to your Favorites' : 'Removed from Favorites',
        type: !isFav ? ToastType.success : ToastType.info,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.design;
    final isFav = ref.watch(isDesignFavoritedProvider(item.id));
    final imgUrl = item.imageUrls.isNotEmpty
        ? item.imageUrls.first
        : (item.thumbnailUrl ?? '');
    final price = item.price > 0 ? '₹${item.price.toStringAsFixed(0)}' : 'Custom';

    return GestureDetector(
      onTap: () {
        context.push(AppRoutes.customerDesignDetails, extra: item);
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderSoft),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. Image Container with Double-Tap Listener ──
            Expanded(
              child: Stack(
                children: [
                  GestureDetector(
                    onDoubleTap: _handleDoubleTap,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: double.infinity,
                        child: imgUrl.isNotEmpty && imgUrl.startsWith('http')
                            ? CachedNetworkImage(
                                imageUrl: imgUrl,
                                fit: BoxFit.cover,
                                errorWidget: (ctx, err, stack) => Container(
                                  color: AppColors.brandGreen50,
                                  child: const Icon(
                                    Icons.checkroom_rounded,
                                    color: AppColors.primary,
                                  ),
                                ),
                              )
                            : Container(
                                color: AppColors.brandGreen50,
                                child: const Center(
                                  child: Icon(
                                    Icons.checkroom_rounded,
                                    color: AppColors.primary,
                                    size: 36,
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ),

                  // Rank Badge on Top Left
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.local_fire_department_rounded,
                            size: 11,
                            color: AppColors.surfaceWhite,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '#${widget.rankIndex + 1}',
                            style: GoogleFonts.montserrat(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppColors.surfaceWhite,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Favorite / Bookmark Button on Top Right
                  Positioned(
                    top: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: _handleFavoriteToggle,
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceWhite.withValues(alpha: 0.92),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Icon(
                          isFav
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_border_rounded,
                          size: 18,
                          color: isFav ? AppColors.primary : AppColors.charcoal,
                        ),
                      ),
                    ),
                  ),

                  // Double Tap Heart Explosion Animation Overlay
                  Center(
                    child: DoubleTapHeartOverlay(
                      isAnimating: _showHeartAnimation,
                      onAnimationComplete: () {
                        setState(() => _showHeartAnimation = false);
                      },
                    ),
                  ),
                ],
              ),
            ),

            // ── 2. Card Content Details ──
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.charcoal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        price,
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),

                      // Like Count Badge
                      Row(
                        children: [
                          const Icon(
                            Icons.favorite_rounded,
                            size: 12,
                            color: AppColors.error,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${item.likeCount}',
                            style: GoogleFonts.montserrat(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
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
