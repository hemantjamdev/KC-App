import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/customer_empty_state.dart';
import '../../../auth/application/providers/auth_providers.dart';
import '../../../auth/presentation/widgets/google_auth_bottom_sheet.dart';
import '../../application/providers/favorite_providers.dart';
import '../widgets/favorite_design_card.dart';

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
                      return FavoriteDesignCard(design: designs[idx]);
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
