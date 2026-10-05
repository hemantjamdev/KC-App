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
import '../../../design/application/providers/design_like_providers.dart';
import '../../../design/application/providers/favorite_providers.dart';
import '../../../design/domain/models/design_model.dart';
import '../../application/providers/trending_pagination_provider.dart';
import 'double_tap_heart_overlay.dart';

/// Full-width Instagram-style Feed Card for Trending Listing Page.
/// Features clean double-tap without grey ink splash, like button, liked-by summary,
/// bookmark button, and details navigation.
class InstagramTrendingCard extends ConsumerStatefulWidget {
  const InstagramTrendingCard({
    super.key,
    required this.design,
    required this.rankIndex,
  });

  final DesignModel design;
  final int rankIndex;

  @override
  ConsumerState<InstagramTrendingCard> createState() =>
      _InstagramTrendingCardState();
}

class _InstagramTrendingCardState
    extends ConsumerState<InstagramTrendingCard> {
  bool _showHeartAnimation = false;

  Future<void> _handleDoubleTap() async {
    final isAuthenticated = ref.read(isAuthenticatedProvider);
    final user = ref.read(currentCustomerUserProvider);

    if (!isAuthenticated || user == null) {
      await GoogleAuthBottomSheet.show(
        context,
        title: 'Like this Style',
        message: 'Sign in with Google to like styles and save your preferences.',
      );
      return;
    }

    setState(() => _showHeartAnimation = true);
    await ref.read(trendingPaginationProvider.notifier).toggleLike(widget.design.id);
    await ref.read(toggleLikeNotifierProvider.notifier).toggle(widget.design.id);

    if (mounted) {
      AppToast.show(
        context,
        'Liked "${widget.design.name}"! ❤️',
        type: ToastType.success,
      );
    }
  }

  Future<void> _handleLikeTap() async {
    final isAuthenticated = ref.read(isAuthenticatedProvider);
    final user = ref.read(currentCustomerUserProvider);

    if (!isAuthenticated || user == null) {
      await GoogleAuthBottomSheet.show(
        context,
        title: 'Like this Style',
        message: 'Sign in with Google to like styles and save your preferences.',
      );
      return;
    }

    final isLiked = ref.read(isDesignLikedProvider(widget.design.id)).valueOrNull ?? false;
    await ref.read(trendingPaginationProvider.notifier).toggleLike(widget.design.id);
    await ref.read(toggleLikeNotifierProvider.notifier).toggle(widget.design.id);

    if (mounted) {
      AppToast.show(
        context,
        !isLiked ? 'Liked style ❤️' : 'Unliked style',
        type: !isLiked ? ToastType.success : ToastType.info,
      );
    }
  }

  Future<void> _handleFavoriteToggle() async {
    final isAuthenticated = ref.read(isAuthenticatedProvider);
    final user = ref.read(currentCustomerUserProvider);

    if (!isAuthenticated || user == null) {
      await GoogleAuthBottomSheet.show(
        context,
        title: 'Save to Favorites',
        message: 'Sign in with Google to bookmark garments across devices.',
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
        !isFav ? 'Added to your Wishlist' : 'Removed from Wishlist',
        type: !isFav ? ToastType.success : ToastType.info,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.design;
    final isLiked = ref.watch(isDesignLikedProvider(item.id)).valueOrNull ?? false;
    final isFav = ref.watch(isDesignFavoritedProvider(item.id));
    final likeSummary = ref.watch(likeSummaryTextProvider(item.id));

    final imgUrl = item.imageUrls.isNotEmpty
        ? item.imageUrls.first
        : (item.thumbnailUrl ?? '');
    final price = item.price > 0 ? '₹${item.price.toStringAsFixed(0)}' : 'Custom';

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderSoft),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 1. Top Instagram Header ─────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(2.5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                  child: const CircleAvatar(
                    radius: 17,
                    backgroundColor: AppColors.warmIvory,
                    child: Icon(
                      Icons.local_florist_rounded,
                      size: 18,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kapada Creation Studio',
                        style: GoogleFonts.montserrat(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.charcoal,
                        ),
                      ),
                      Text(
                        'Designer Atelier  •  Rank #${widget.rankIndex + 1}',
                        style: GoogleFonts.montserrat(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.brandGreen50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'TRENDING',
                    style: GoogleFonts.montserrat(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── 2. Media Image Container (NO InkWell => ZERO Grey Splash on Double Tap!) ──
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onDoubleTap: _handleDoubleTap,
            onTap: () {
              context.push(AppRoutes.customerDesignDetails, extra: item);
            },
            child: Container(
              height: 380,
              width: double.infinity,
              color: AppColors.warmIvory,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: imgUrl.isNotEmpty && imgUrl.startsWith('http')
                        ? CachedNetworkImage(
                            imageUrl: imgUrl,
                            fit: BoxFit.cover,
                            errorWidget: (ctx, err, stack) => Container(
                              color: AppColors.brandGreen50,
                              child: const Center(
                                child: Icon(
                                  Icons.checkroom_rounded,
                                  size: 48,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          )
                        : Container(
                            color: AppColors.brandGreen50,
                            child: const Center(
                              child: Icon(
                                Icons.checkroom_rounded,
                                size: 48,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                  ),

                  // Heart Burst Animation Overlay on Double Tap
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
          ),

          // ── 3. Action Bar ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
            child: Row(
              children: [
                // Like Button
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    size: 26,
                    color: isLiked ? AppColors.error : AppColors.charcoal,
                  ),
                  onPressed: _handleLikeTap,
                  tooltip: 'Like',
                ),
                const SizedBox(width: 16),

                // Details / Comment Button
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 23,
                    color: AppColors.charcoal,
                  ),
                  onPressed: () {
                    context.push(AppRoutes.customerDesignDetails, extra: item);
                  },
                  tooltip: 'View Details',
                ),
                const SizedBox(width: 16),

                // Share Button
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(
                    Icons.send_rounded,
                    size: 23,
                    color: AppColors.charcoal,
                  ),
                  onPressed: () {
                    AppToast.show(
                      context,
                      'Sharing "${item.name}"...',
                      type: ToastType.info,
                    );
                  },
                  tooltip: 'Share',
                ),

                const Spacer(),

                // Bookmark / Favorite Button
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    isFav ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                    size: 25,
                    color: isFav ? AppColors.primary : AppColors.charcoal,
                  ),
                  onPressed: _handleFavoriteToggle,
                  tooltip: 'Save to Wishlist',
                ),
              ],
            ),
          ),

          // ── 4. Liked-By Summary Line ──────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              likeSummary,
              style: GoogleFonts.montserrat(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: AppColors.charcoal,
              ),
            ),
          ),

          // ── 5. Garment Title, Price & Caption ─────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 2, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.charcoal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      price,
                      style: GoogleFonts.montserrat(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),

                if (item.shortDescription != null &&
                    item.shortDescription!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.shortDescription!,
                    style: GoogleFonts.montserrat(
                      fontSize: 11.5,
                      color: AppColors.textMuted,
                      height: 1.35,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                if (item.sizes.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: item.sizes.take(5).map((size) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.warmIvory,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.borderSoft),
                        ),
                        child: Text(
                          size,
                          style: GoogleFonts.montserrat(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.charcoal,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
