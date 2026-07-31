import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_full_screen_image_dialog.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/stitch_line_divider.dart';
import '../../../auth/application/providers/auth_providers.dart';
import '../../../auth/presentation/widgets/google_auth_bottom_sheet.dart';
import '../../application/providers/favorite_providers.dart';
import '../../domain/models/design_model.dart';

/// Ready-made product details page for Kapada Creation Customer App.
/// Pure ready-made apparel showcase: images, price, description, colors, sizes, favorite, share.
class CustomerDesignDetailsPage extends ConsumerStatefulWidget {
  const CustomerDesignDetailsPage({super.key, required this.design});

  final DesignModel design;

  @override
  ConsumerState<CustomerDesignDetailsPage> createState() =>
      _CustomerDesignDetailsPageState();
}

class _CustomerDesignDetailsPageState
    extends ConsumerState<CustomerDesignDetailsPage> {
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

    return PopScope(
      canPop: context.canPop(),
      child: Scaffold(
        backgroundColor: AppColors.warmIvory,
        body: SafeArea(
        child: Column(
          children: [
            // ── Top Navigation Bar ──────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: AppColors.charcoal,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      widget.design.name,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.charcoal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      isFavorited
                          ? Icons.favorite_rounded
                          : Icons.favorite_outline_rounded,
                      color: isFavorited
                          ? const Color(0xFFCC4B37)
                          : AppColors.charcoal,
                    ),
                    onPressed: () async {
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
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.share_outlined,
                      color: AppColors.charcoal,
                    ),
                    onPressed: () {
                      AppToast.show(
                        context,
                        'Sharing "${widget.design.name}"...',
                        type: ToastType.info,
                      );
                    },
                  ),
                ],
              ),
            ),

            // ── Scrollable Body ─────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Image Gallery Carousel ─────────────────────────
                    SizedBox(
                      height: 380,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: imageUrls.isNotEmpty
                                ? PageView.builder(
                                    itemCount: imageUrls.length,
                                    onPageChanged: (idx) {
                                      setState(() => _currentImageIndex = idx);
                                    },
                                    itemBuilder: (ctx, idx) {
                                      return GestureDetector(
                                        onTap: () => _openFullscreenGallery(
                                          context,
                                          imageUrls,
                                          idx,
                                        ),
                                        child: CachedNetworkImage(
                                          imageUrl: imageUrls[idx],
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              Container(
                                                color: AppColors.softCream,
                                                child: const Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                        color: AppColors
                                                            .brandGreen800,
                                                        strokeWidth: 2,
                                                      ),
                                                ),
                                              ),
                                          errorWidget: (context, url, error) =>
                                              Container(
                                                color: AppColors.softCream,
                                                child: const Center(
                                                  child: Icon(
                                                    Icons.checkroom_rounded,
                                                    size: 48,
                                                    color: AppColors.mutedText,
                                                  ),
                                                ),
                                              ),
                                        ),
                                      );
                                    },
                                  )
                                : Container(
                                    color: AppColors.softCream,
                                    child: const Center(
                                      child: Icon(
                                        Icons.checkroom_rounded,
                                        size: 48,
                                        color: AppColors.mutedText,
                                      ),
                                    ),
                                  ),
                          ),

                          // Image Page Indicator
                          if (imageUrls.length > 1)
                            Positioned(
                              bottom: 12,
                              left: 0,
                              right: 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(imageUrls.length, (
                                  idx,
                                ) {
                                  final isActive = idx == _currentImageIndex;
                                  return Container(
                                    width: isActive ? 16 : 6,
                                    height: 6,
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 3,
                                    ),
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
                        ],
                      ),
                    ),

                    // ── Details Section ────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Availability & Category Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: widget.design.isActive
                                      ? AppColors.success.withValues(
                                          alpha: 0.12,
                                        )
                                      : AppColors.error.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: widget.design.isActive
                                        ? AppColors.success.withValues(
                                            alpha: 0.3,
                                          )
                                        : AppColors.error.withValues(
                                            alpha: 0.3,
                                          ),
                                  ),
                                ),
                                child: Text(
                                  widget.design.isActive
                                      ? 'AVAILABLE IN STUDIO'
                                      : 'OUT OF STOCK',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: widget.design.isActive
                                        ? AppColors.success
                                        : AppColors.error,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),

                              Text(
                                'Kapada Creation Studio',
                                style: GoogleFonts.montserrat(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.mutedText,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Product Title
                          Text(
                            widget.design.name,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              color: AppColors.charcoal,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Price
                          if (widget.design.price > 0)
                            Text(
                              '₹${widget.design.price.toStringAsFixed(0)}',
                              style: GoogleFonts.montserrat(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: AppColors.brandGreen900,
                              ),
                            )
                          else
                            Text(
                              'Bespoke Pricing in Studio',
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                                color: AppColors.mutedGold,
                              ),
                            ),

                          const StitchLineDivider(
                            margin: EdgeInsets.symmetric(vertical: 20),
                          ),

                          // Artisan Note / Description
                          if (widget.design.shortDescription != null &&
                              widget.design.shortDescription!.isNotEmpty) ...[
                            Text(
                              "ARTISAN'S NOTE",
                              style: GoogleFonts.montserrat(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.mutedText,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              widget.design.shortDescription!,
                              style: GoogleFonts.montserrat(
                                fontSize: 13,
                                color: AppColors.charcoal,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          if (widget.design.description != null &&
                              widget.design.description!.isNotEmpty) ...[
                            Text(
                              'DESCRIPTION & CRAFTSMANSHIP',
                              style: GoogleFonts.montserrat(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.mutedText,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              widget.design.description!,
                              style: GoogleFonts.montserrat(
                                fontSize: 13,
                                color: AppColors.mutedText,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Colors Swatches (Visual Swatches, not code text)
                          if (widget.design.colors.isNotEmpty) ...[
                            Text(
                              'AVAILABLE COLORS',
                              style: GoogleFonts.montserrat(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.mutedText,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: widget.design.colors.map((colorStr) {
                                Color swatchColor = AppColors.brandGreen800;
                                try {
                                  String clean = colorStr.trim().replaceAll('#', '');
                                  if (clean.startsWith('0x')) clean = clean.substring(2);
                                  if (clean.length == 6) clean = 'FF$clean';
                                  swatchColor = Color(int.parse(clean, radix: 16));
                                } catch (_) {}

                                return Tooltip(
                                  message: colorStr,
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: swatchColor,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.borderSoft,
                                        width: 1.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.12),
                                          blurRadius: 5,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Sizes Tags
                          if (widget.design.sizes.isNotEmpty) ...[
                            Text(
                              'AVAILABLE TAILORED SIZES',
                              style: GoogleFonts.montserrat(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.mutedText,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: widget.design.sizes.map((size) {
                                return Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: AppColors.brandGreen900,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      size,
                                      style: GoogleFonts.montserrat(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.surfaceWhite,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Boutique Info Note
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.softCream,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.borderSoft),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.storefront_rounded,
                                  color: AppColors.brandGreen800,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Available at Physical Studio',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.charcoal,
                                        ),
                                      ),
                                      Text(
                                        'Visit Kapada Creation to try on or request custom tailoring based on this design.',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 11,
                                          color: AppColors.mutedText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  void _openFullscreenGallery(
    BuildContext context,
    List<String> urls,
    int initialIndex,
  ) {
    AppFullScreenImageDialog.show(
      context,
      imageUrls: urls,
      initialIndex: initialIndex,
    );
  }
}
