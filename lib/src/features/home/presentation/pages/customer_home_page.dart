import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../auth/application/providers/auth_providers.dart';
import '../../../auth/presentation/widgets/google_auth_bottom_sheet.dart';
import '../../../boutique/application/providers/boutique_providers.dart';
import '../../../boutique/presentation/widgets/store_info_card.dart';
import '../../../category/application/providers/category_providers.dart';
import '../../../category/domain/models/category_model.dart';
import '../../../design/application/providers/design_providers.dart';
import '../../../design/application/providers/favorite_providers.dart';
import '../../../design/domain/models/design_model.dart';
import '../../../notification/application/providers/notification_providers.dart';

/// Kapada Creation Customer App — Clean, Elegant Luxury Home Dashboard.
class CustomerHomePage extends ConsumerStatefulWidget {
  const CustomerHomePage({super.key});

  @override
  ConsumerState<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends ConsumerState<CustomerHomePage> {
  String _selectedCategorySlug = 'all';

  static String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentCustomerUserProvider);
    final customerProfile = ref.watch(customerProfileProvider).valueOrNull;
    final unreadNotificationCount = ref.watch(unreadNotificationCountProvider);
    final boutique = ref.watch(selectedBoutiqueProvider) ??
        ref.watch(autoSelectedBoutiqueProvider);

    final designsAsync = ref.watch(designListProvider);
    final designs = designsAsync.valueOrNull ?? [];
    final isLoading = designsAsync.isLoading;

    final categories = ref.watch(activeCategoryListProvider);

    // Customer Display Name
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
            : 'Guest';

    // Active designs from Firestore
    final activeDesigns = designs.where((d) => d.isActive).toList();

    // Only include categories that actually contain products
    final categoriesWithProducts = categories.where((cat) {
      final slug = cat.slug.isNotEmpty ? cat.slug : cat.id;
      return activeDesigns.any((d) =>
          d.categoryId == cat.id ||
          d.categoryId == slug ||
          d.tags.contains(slug) ||
          d.tags.contains(cat.name.toLowerCase()));
    }).toList();

    // Filtering designs based on category pill selection
    final filteredDesigns = _selectedCategorySlug == 'all'
        ? activeDesigns
        : activeDesigns.where((d) {
            final cat = categoriesWithProducts.firstWhere(
              (c) =>
                  c.slug == _selectedCategorySlug ||
                  c.id == _selectedCategorySlug,
              orElse: () => CategoryModel(
                id: '',
                boutiqueId: '',
                name: '',
                slug: '',
                sortOrder: 0,
                isActive: true,
                isSystem: false,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
            );
            if (cat.id.isNotEmpty && d.categoryId == cat.id) return true;
            return d.tags.contains(_selectedCategorySlug) ||
                d.tags.contains(cat.name.toLowerCase());
          }).toList();

    // Hero Design (Featured)
    final heroDesign = activeDesigns.isNotEmpty ? activeDesigns.first : null;

    // New Arrivals
    final newArrivals = activeDesigns.length > 1
        ? activeDesigns.skip(1).take(6).toList()
        : activeDesigns;

    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.charcoal,
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
              // ── 1. Top Header (Matches Admin App Header) ─────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back',
                              style: GoogleFonts.montserrat(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.mutedText,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: '${_greeting()},\n',
                                    style: GoogleFonts.playfairDisplay(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.charcoal,
                                      height: 1.2,
                                    ),
                                  ),
                                  TextSpan(
                                    text: formattedCustomerName,
                                    style: GoogleFonts.playfairDisplay(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.mutedText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Notification Bell
                      Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.surfaceWhite,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.borderSoft),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.notifications_none_rounded,
                                size: 22,
                                color: AppColors.charcoal,
                              ),
                              onPressed: () => context.push(
                                AppRoutes.customerNotificationList,
                              ),
                              tooltip: 'Notifications',
                            ),
                          ),
                          if (unreadNotificationCount > 0)
                            Positioned(
                              right: 6,
                              top: 6,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: AppColors.error,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '$unreadNotificationCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // ── 2. Category Filter Bar ──────────────────────────
              SliverToBoxAdapter(
                child: Container(
                  height: 42,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildCategoryChip(
                        label: 'All Styles',
                        slug: 'all',
                        isSelected: _selectedCategorySlug == 'all',
                      ),
                      ...categoriesWithProducts.map((cat) {
                        return _buildCategoryChip(
                          label: cat.name,
                          slug: cat.slug.isNotEmpty ? cat.slug : cat.id,
                          isSelected: _selectedCategorySlug == (cat.slug.isNotEmpty ? cat.slug : cat.id),
                        );
                      }),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 12)),

              if (isLoading)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.charcoal,
                      strokeWidth: 2,
                    ),
                  ),
                )
              else if (activeDesigns.isEmpty)
                SliverFillRemaining(
                  child: AppEmptyState(
                    icon: Icons.checkroom_rounded,
                    title: 'No designs available',
                    message:
                        'The studio collection is currently being updated. Please check back shortly.',
                    actionLabel: 'Refresh',
                    onAction: () => ref.invalidate(designListProvider),
                  ),
                )
              else ...[
                // If a specific category filter is selected, show filtered grid directly
                if (_selectedCategorySlug != 'all') ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'FILTERED RESULTS (${filteredDesigns.length})',
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.mutedText,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList.separated(
                      itemCount: filteredDesigns.length,
                      separatorBuilder: (ctx, idx) =>
                          const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        return _buildHorizontalProductTile(
                            context, filteredDesigns[index]);
                      },
                    ),
                  ),
                ] else ...[
                  // ── 3. Featured Hero Showcase Card ──────────────────
                  if (heroDesign != null) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildHeroCard(context, heroDesign),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  ],

                  // ── 4. New Arrivals Section ────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildSectionHeader(
                        title: 'NEW ARRIVALS',
                        onViewAll: () => context.push(
                          '${AppRoutes.customerSectionListing}?section=${Uri.encodeComponent('New Arrivals')}',
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 240,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        physics: const BouncingScrollPhysics(),
                        itemCount: newArrivals.length,
                        separatorBuilder: (ctx, idx) =>
                            const SizedBox(width: 14),
                        itemBuilder: (context, index) {
                          return SizedBox(
                            width: 155,
                            child: _buildProductCard(context, newArrivals[index]),
                          );
                        },
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 28)),

                  // ── 5. All Studio Collections List ──────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildSectionHeader(
                        title: 'CURATED COLLECTION',
                        onViewAll: () => context.push(
                          '${AppRoutes.customerSectionListing}?section=${Uri.encodeComponent('Curated Collection')}',
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),

                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList.separated(
                      itemCount: activeDesigns.length,
                      separatorBuilder: (ctx, idx) =>
                          const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final design = activeDesigns[index];
                        return _buildHorizontalProductTile(context, design);
                      },
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 28)),

                  // ── 6. Studio Location & Store Info ────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'VISIT OUR STUDIO',
                            style: GoogleFonts.montserrat(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.mutedText,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 10),
                          StoreInfoCard(boutique: boutique),
                        ],
                      ),
                    ),
                  ),
                ],

                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ── Category Filter Chip ─────────────────────────────────────
  Widget _buildCategoryChip({
    required String label,
    required String slug,
    required bool isSelected,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        showCheckmark: false,
        label: Text(label),
        labelStyle: GoogleFonts.montserrat(
          fontSize: 11,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected ? const Color(0xFF1B5E20) : AppColors.charcoal,
        ),
        backgroundColor: AppColors.surfaceWhite,
        selectedColor: const Color(0xFF2E7D32).withValues(alpha: 0.2),
        side: BorderSide(
          color: isSelected
              ? const Color(0xFF2E7D32).withValues(alpha: 0.5)
              : AppColors.borderSoft,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        onSelected: (selected) {
          setState(() {
            _selectedCategorySlug = slug;
          });
        },
      ),
    );
  }

  // ── Section Header Helper ────────────────────────────────────
  Widget _buildSectionHeader({
    required String title,
    required VoidCallback onViewAll,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.montserrat(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.charcoal,
            letterSpacing: 1.3,
          ),
        ),
        GestureDetector(
          onTap: onViewAll,
          child: Row(
            children: [
              Text(
                'View all',
                style: GoogleFonts.montserrat(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.mutedText,
                ),
              ),
              const SizedBox(width: 2),
              const Icon(
                Icons.chevron_right_rounded,
                size: 16,
                color: AppColors.mutedText,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Hero Banner Card ─────────────────────────────────────────
  Widget _buildHeroCard(BuildContext context, DesignModel design) {
    final title = design.name;
    final price = '₹${design.price.toInt()}';
    final hasImg = design.imageUrls.isNotEmpty;
    final imgUrl = hasImg ? design.imageUrls.first : '';
    final isFav = ref.watch(isDesignFavoritedProvider(design.id));

    return GestureDetector(
      onTap: () => context.push(AppRoutes.customerDesignDetails, extra: design),
      child: Container(
        height: 210,
        decoration: BoxDecoration(
          color: const Color(0xFF2E7D32).withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Background Image
              Positioned.fill(
                child: hasImg && imgUrl.startsWith('http')
                    ? Image.network(
                        imgUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) => Container(
                          color: const Color(0xFF2E7D32).withValues(alpha: 0.2),
                        ),
                      )
                    : Container(
                        color: const Color(0xFF2E7D32).withValues(alpha: 0.2),
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

              // Top Left Badge with Green 0.2 Opacity
              Positioned(
                top: 14,
                left: 14,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    'FEATURED LOOK',
                    style: GoogleFonts.montserrat(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),

              // Top Right Favorite Button
              Positioned(
                top: 12,
                right: 12,
                child: GestureDetector(
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
                      color: AppColors.surfaceWhite,
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
              ),

              // Bottom Info
              Positioned(
                bottom: 14,
                left: 14,
                right: 14,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 18,
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
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.surfaceWhite,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D32).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Text(
                        'Explore →',
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
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

  // ── Clean Standard Product Card ──────────────────────────────
  Widget _buildProductCard(BuildContext context, DesignModel design) {
    final title = design.name;
    final price = '₹${design.price.toInt()}';
    final hasImg = design.imageUrls.isNotEmpty;
    final imgUrl = hasImg ? design.imageUrls.first : '';
    final isFav = ref.watch(isDesignFavoritedProvider(design.id));

    return GestureDetector(
      onTap: () => context.push(AppRoutes.customerDesignDetails, extra: design),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Box
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderSoft),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: hasImg && imgUrl.startsWith('http')
                          ? Image.network(
                              imgUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, err, stack) => Container(
                                color: const Color(0xFF2E7D32).withValues(alpha: 0.2),
                                child: const Icon(
                                  Icons.checkroom_rounded,
                                  color: AppColors.mutedText,
                                  size: 28,
                                ),
                              ),
                            )
                          : Container(
                              color: const Color(0xFF2E7D32).withValues(alpha: 0.2),
                              child: const Icon(
                                Icons.checkroom_rounded,
                                color: AppColors.mutedText,
                                size: 28,
                              ),
                            ),
                    ),

                    // Favorite Button Top Right
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () async {
                          final success = await ref
                              .read(favoriteMutationProvider.notifier)
                              .toggleFavorite(design.id);
                          if (!success && context.mounted) {
                            await GoogleAuthBottomSheet.show(context);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceWhite.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isFav
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            size: 14,
                            color: isFav ? AppColors.error : AppColors.charcoal,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Title & Price
          Text(
            title,
            style: GoogleFonts.playfairDisplay(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.charcoal,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            price,
            style: GoogleFonts.montserrat(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.charcoal,
            ),
          ),
        ],
      ),
    );
  }

  // ── Clean Horizontal Product List Tile ───────────────────────
  Widget _buildHorizontalProductTile(BuildContext context, DesignModel design) {
    final title = design.name;
    final price = '₹${design.price.toInt()}';
    final hasImg = design.imageUrls.isNotEmpty;
    final imgUrl = hasImg ? design.imageUrls.first : '';
    final isFav = ref.watch(isDesignFavoritedProvider(design.id));

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
                  ? Image.network(
                      imgUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, stack) => const Center(
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
                    title,
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
                    price,
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

            // Favorite Button
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
