import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../auth/application/providers/auth_providers.dart';
import '../../../category/application/providers/category_providers.dart';
import '../../../category/domain/models/category_model.dart';
import '../../../design/application/providers/design_providers.dart';
import '../../../notification/application/providers/notification_providers.dart';
import '../widgets/custom_categories_grid.dart';
import '../widgets/festival_collection_grid.dart';
import '../widgets/home_top_bar.dart';
import '../widgets/new_arrivals_section.dart';
import '../widgets/seasonal_collection_list.dart';
import '../widgets/section_header_row.dart';
import '../widgets/trending_carousel.dart';

/// Kapada Creation Customer App — Luxury Home Dashboard.
/// Parity with KC-Admin header & authentic Firestore models.
class CustomerHomePage extends ConsumerWidget {
  const CustomerHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentCustomerUserProvider);
    final customerProfile = ref.watch(customerProfileProvider).valueOrNull;
    final unreadNotificationCount = ref.watch(unreadNotificationCountProvider);

    final designsAsync = ref.watch(designListProvider);
    final designs = designsAsync.valueOrNull ?? [];
    final isLoading = designsAsync.isLoading;

    final categories = ref.watch(activeCategoryListProvider);

    final cName = customerProfile?.displayName;
    final customerName = (cName != null && cName.trim().isNotEmpty)
        ? cName.trim().split(' ').first
        : (user?.displayName != null && user!.displayName!.trim().isNotEmpty
            ? user.displayName!.trim().split(' ').first
            : (user?.email != null && user!.email!.contains('@')
                ? user.email!.split('@').first
                : null));

    final String formattedCustomerName =
        (customerName != null && customerName.isNotEmpty)
            ? '${customerName[0].toUpperCase()}${customerName.substring(1)}'
            : 'Valued Customer';

    final String? photoUrl = customerProfile?.photoUrl ?? user?.photoURL;

    final activeDesigns = designs.where((d) => d.isActive).toList();
    final trendingDesign = ref.watch(trendingHeroDesignProvider);
    final newArrivalsDesigns = activeDesigns.take(4).toList();

    final CategoryModel? festiveCat = categories.where((c) =>
          c.slug.contains('festive') ||
          c.name.toLowerCase().contains('festive') ||
          c.slug.contains('wedding')).firstOrNull ?? (categories.isNotEmpty ? categories.first : null);

    final CategoryModel? seasonalCat = categories.where((c) =>
          c.slug.contains('seasonal') ||
          c.name.toLowerCase().contains('seasonal') ||
          c.slug.contains('summer')).firstOrNull ?? (categories.length > 1 ? categories[1] : null);

    final hasRealCategories = categories.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: AppColors.surfaceWhite,
          onRefresh: () async {
            ref.invalidate(designListProvider);
            ref.invalidate(customerProfileProvider);
            ref.invalidate(categoryListProvider);
            await ref.read(designListProvider.future);
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              // Parity SliverPersistentHeader (matches KC-Admin home header)
              SliverPersistentHeader(
                pinned: true,
                delegate: CustomerHomeHeaderDelegate(
                  customerName: formattedCustomerName,
                  photoUrl: photoUrl,
                  unreadNotificationCount: unreadNotificationCount,
                  isAuthenticated: user != null,
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              if (isLoading)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2,
                    ),
                  ),
                )
              else if (activeDesigns.isEmpty)
                SliverFillRemaining(
                  child: AppEmptyState(
                    icon: Icons.checkroom_rounded,
                    title: 'No styles available yet',
                    message:
                        'Boutique collections are being prepared by Kapada Creation. Check again soon.',
                    actionLabel: 'Refresh',
                    onAction: () => ref.invalidate(designListProvider),
                  ),
                )
              else ...[
                // 1. TRENDING Section Carousel
                if (trendingDesign != null) ...[
                  const SliverToBoxAdapter(
                    child: TrendingCarousel(),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 28)),
                ],

                // 2. NEW ARRIVALS Section
                if (newArrivalsDesigns.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SectionHeaderRow(
                        title: 'NEW ARRIVALS',
                        onViewAll: () =>
                            context.push(AppRoutes.customerSectionListing),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 14)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: NewArrivalsSection(designs: newArrivalsDesigns),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 28)),
                ],

                // 3. FESTIVAL Section (The Festive Edit)
                if (hasRealCategories && festiveCat != null) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: FestivalCollectionGrid(
                        festiveCategory: festiveCat,
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 28)),
                ],

                // 4. SEASONAL Section (Real Category)
                if (hasRealCategories && seasonalCat != null && seasonalCat.id != festiveCat?.id) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SectionHeaderRow(
                        title: seasonalCat.name.toUpperCase(),
                        onViewAll: () => context.push(
                          AppRoutes.customerCategoryDesigns,
                          extra: seasonalCat,
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 14)),
                  SliverToBoxAdapter(
                    child: SeasonalCollectionList(
                      seasonalCategory: seasonalCat,
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 28)),
                ],

                // 5. ALL OTHER REAL CATEGORIES
                if (categories.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SectionHeaderRow(
                        title: 'BOUTIQUE COLLECTIONS',
                        onViewAll: () =>
                            context.push(AppRoutes.customerCategoryList),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: CustomCategoriesGrid(categories: categories),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 36)),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
