import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/customer_empty_state.dart';
import '../../../auth/application/providers/auth_providers.dart';
import '../../../auth/presentation/widgets/google_auth_bottom_sheet.dart';
import '../../application/providers/favorite_providers.dart';
import '../../domain/models/design_model.dart';

/// Customer Favorites Tab Screen.
/// Protected action: Requires Google Auth.
/// Reads customer favorited product IDs and displays a real-time list of saved items.
class CustomerFavoritesPage extends ConsumerWidget {
  const CustomerFavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final favoriteDesignsAsync = ref.watch(customerFavoriteDesignsProvider);

    if (!isAuthenticated) {
      return Scaffold(
        backgroundColor: AppColors.warmIvory,
        body: SafeArea(
          child: CustomerEmptyState(
            icon: Icons.favorite_outline_rounded,
            title: 'Save Your Favorite Styles',
            subtitle:
                'Sign in with Google to bookmark garments you love and view them across devices.',
            actionLabel: 'Continue with Google',
            action: () => GoogleAuthBottomSheet.show(context),
          ),
        ),
      );
    }

    final designs = favoriteDesignsAsync.valueOrNull ?? [];
    final isLoading = favoriteDesignsAsync.isLoading;

    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.brandGreen,
          backgroundColor: AppColors.surfaceWhite,
          onRefresh: () async {
            ref.invalidate(customerFavoriteDesignsProvider);
            await ref.read(customerFavoriteDesignsProvider.future);
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              // ── Header ─────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Favorites',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          color: AppColors.charcoal,
                        ),
                      ),
                      Text(
                        'Your curated boutique wishlist',
                        style: GoogleFonts.montserrat(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: AppColors.mutedText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (isLoading)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.brandGreen800,
                      strokeWidth: 2,
                    ),
                  ),
                )
              else if (designs.isEmpty)
                const SliverFillRemaining(
                  child: AppEmptyState(
                    icon: Icons.favorite_outline_rounded,
                    title: 'Your favorites are waiting',
                    message:
                        'Tap the heart on any style you love and it will appear here.',
                  ),
                )
              else ...[
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList.separated(
                    itemCount: designs.length,
                    separatorBuilder: (ctx, idx) =>
                        const SizedBox(height: 14),
                    itemBuilder: (ctx, idx) {
                      final design = designs[idx];
                      return _FavoriteListItem(design: design);
                    },
                  ),
                ),
              ],

              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        ),
      ),
    );
  }
}

class _FavoriteListItem extends ConsumerWidget {
  const _FavoriteListItem({required this.design});

  final DesignModel design;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFav = ref.watch(isDesignFavoritedProvider(design.id));
    final hasImg = design.imageUrls.isNotEmpty ||
        (design.thumbnailUrl != null && design.thumbnailUrl!.isNotEmpty);
    final imgUrl = design.imageUrls.isNotEmpty
        ? design.imageUrls.first
        : (design.thumbnailUrl ?? '');

    return GestureDetector(
      onTap: () => context.push(AppRoutes.customerDesignDetails, extra: design),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderSoft),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Thumbnail Image Box with 0.2 Green Opacity
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: hasImg && imgUrl.startsWith('http')
                  ? CachedNetworkImage(
                      imageUrl: imgUrl,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => const Center(
                        child: Icon(
                          Icons.checkroom_rounded,
                          color: AppColors.mutedText,
                          size: 28,
                        ),
                      ),
                    )
                  : const Center(
                      child: Icon(
                        Icons.checkroom_rounded,
                        color: AppColors.mutedText,
                        size: 28,
                      ),
                    ),
            ),
            const SizedBox(width: 14),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    design.name,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.charcoal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (design.tags.isNotEmpty)
                    Text(
                      design.tags.first.toUpperCase(),
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.mutedText,
                      ),
                    ),
                  const SizedBox(height: 6),
                  Text(
                    '₹${design.price.toInt()}',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.charcoal,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Remove Favorite Heart Button
            GestureDetector(
              onTap: () async {
                final success = await ref
                    .read(favoriteMutationProvider.notifier)
                    .toggleFavorite(design.id);
                if (!success && context.mounted) {
                  await GoogleAuthBottomSheet.show(context);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.warmIvory,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isFav
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  size: 18,
                  color: isFav ? AppColors.error : AppColors.mutedText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
