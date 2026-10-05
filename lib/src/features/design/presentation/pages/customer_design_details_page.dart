import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/stitch_line_divider.dart';
import '../../../auth/application/providers/auth_providers.dart';
import '../../../auth/presentation/widgets/google_auth_bottom_sheet.dart';
import '../../application/providers/favorite_providers.dart';
import '../../domain/models/design_model.dart';
import '../widgets/design_color_swatches.dart';
import '../widgets/design_image_carousel.dart';

/// Ready-made product details page for Kapada Creation Customer App.
/// Pure ready-made apparel showcase: images, price, description, colors, sizes, favorite, share.
class CustomerDesignDetailsPage extends ConsumerWidget {
  const CustomerDesignDetailsPage({super.key, required this.design});

  final DesignModel design;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorited = ref.watch(isDesignFavoritedProvider(design.id));
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    final imageUrls = design.imageUrls.isNotEmpty
        ? design.imageUrls
        : (design.thumbnailUrl != null && design.thumbnailUrl!.isNotEmpty
            ? [design.thumbnailUrl!]
            : <String>[]);

    return PopScope(
      canPop: context.canPop(),
      child: Scaffold(
        backgroundColor: AppColors.warmIvory,
        body: SafeArea(
          child: Column(
            children: [
              // ── Top Navigation Bar ────────────────────────────
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                        design.name,
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
                            .toggleFavorite(design.id);
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
                          'Sharing "${design.name}"...',
                          type: ToastType.info,
                        );
                      },
                    ),
                  ],
                ),
              ),

              // ── Scrollable Body ───────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image Gallery Carousel Widget
                      DesignImageCarousel(imageUrls: imageUrls),

                      // Details Section
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Availability Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: design.isActive
                                        ? AppColors.success.withValues(
                                            alpha: 0.12,
                                          )
                                        : AppColors.error.withValues(
                                            alpha: 0.12,
                                          ),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: design.isActive
                                          ? AppColors.success.withValues(
                                              alpha: 0.3,
                                            )
                                          : AppColors.error.withValues(
                                              alpha: 0.3,
                                            ),
                                    ),
                                  ),
                                  child: Text(
                                    design.isActive
                                        ? 'AVAILABLE IN STUDIO'
                                        : 'OUT OF STOCK',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: design.isActive
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
                              design.name,
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                color: AppColors.charcoal,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Price
                            if (design.price > 0)
                              Text(
                                '₹${design.price.toStringAsFixed(0)}',
                                style: GoogleFonts.montserrat(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.brandGreen900,
                                ),
                              )
                            else
                              Text(
                                'Custom Pricing in Studio',
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 16,
                                  fontStyle: FontStyle.italic,
                                  color: AppColors.mutedGold,
                                ),
                              ),

                            const StitchLineDivider(
                              margin: EdgeInsets.symmetric(vertical: 20),
                            ),

                            // Artisan Note
                            if (design.shortDescription != null &&
                                design.shortDescription!.isNotEmpty) ...[
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
                                design.shortDescription!,
                                style: GoogleFonts.montserrat(
                                  fontSize: 13,
                                  color: AppColors.charcoal,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],

                            if (design.description != null &&
                                design.description!.isNotEmpty) ...[
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
                                design.description!,
                                style: GoogleFonts.montserrat(
                                  fontSize: 13,
                                  color: AppColors.mutedText,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Color Swatches Widget
                            DesignColorSwatches(colors: design.colors),

                            // Size Selector Pills
                            if (design.sizes.isNotEmpty) ...[
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
                                children: design.sizes.map((size) {
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

                            // Studio Info Note
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
}
