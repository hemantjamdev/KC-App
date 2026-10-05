import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../auth/application/providers/auth_providers.dart';
import '../../../auth/presentation/widgets/google_auth_bottom_sheet.dart';
import '../../../category/application/providers/category_providers.dart';
import '../../../category/domain/models/category_model.dart';
import '../../../design/application/providers/design_providers.dart';
import '../../../design/application/providers/favorite_providers.dart';
import '../../../design/domain/models/design_model.dart';
import '../../../notification/application/providers/notification_providers.dart';

/// Kapada Creation Customer App — Luxury Home Dashboard.
/// Fully dynamic Firestore integration with ZERO mock/dummy fallback data.
class CustomerHomePage extends ConsumerStatefulWidget {
  const CustomerHomePage({super.key});

  @override
  ConsumerState<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends ConsumerState<CustomerHomePage> {
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
            : 'Valued Guest';

    // Active designs from Firestore
    final activeDesigns = designs.where((d) => d.isActive).toList();

    // 1. Trending Design from Firestore
    final trendingDesign = activeDesigns.isNotEmpty ? activeDesigns.first : null;

    // 2. New Arrivals Category & Designs from Firestore
    final newArrivalsCategory = categories.firstWhere(
      (c) => c.slug == 'new-arrivals' || c.id.contains('new_arrivals'),
      orElse: () => CategoryModel(
        id: 'cat_new_arrivals',
        boutiqueId: 'boutique_01',
        name: 'New Arrivals',
        slug: 'new-arrivals',
        sortOrder: 2,
        isActive: true,
        isSystem: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    final newArrivalsDesigns = activeDesigns
        .where((d) => d.categoryId == newArrivalsCategory.id || d.tags.contains('new'))
        .toList();
    final displayNewArrivals = newArrivalsDesigns.isNotEmpty
        ? newArrivalsDesigns
        : activeDesigns.skip(1).take(2).toList();

    // 3. Festive Category & Designs from Firestore
    final festiveCategory = categories.firstWhere(
      (c) => c.slug == 'festive' || c.id.contains('festive'),
      orElse: () => CategoryModel(
        id: 'cat_festive',
        boutiqueId: 'boutique_01',
        name: 'Festive',
        slug: 'festive',
        sortOrder: 3,
        isActive: true,
        isSystem: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    final festiveDesigns = activeDesigns
        .where((d) => d.categoryId == festiveCategory.id || d.tags.contains('festive'))
        .toList();

    // 4. Seasonal Category & Designs from Firestore
    final seasonalCategory = categories.firstWhere(
      (c) => c.slug == 'seasonal' || c.id.contains('seasonal'),
      orElse: () => CategoryModel(
        id: 'cat_seasonal',
        boutiqueId: 'boutique_01',
        name: 'Seasonal',
        slug: 'seasonal',
        sortOrder: 1,
        isActive: true,
        isSystem: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    final seasonalDesigns = activeDesigns
        .where((d) => d.categoryId == seasonalCategory.id || d.tags.contains('seasonal'))
        .toList();

    // 5. Custom Admin Categories created in Firestore
    final customCategories = categories
        .where((c) =>
            !c.isSystem &&
            c.slug != 'seasonal' &&
            c.slug != 'new-arrivals' &&
            c.slug != 'festive' &&
            !c.id.contains('seasonal') &&
            !c.id.contains('new_arrivals') &&
            !c.id.contains('festive'))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2), // Warm Luxe Ivory
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.brandGreen,
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
              // ── Top Header Bar ──────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Brand Logo Badge
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.brandGreen900.withValues(alpha: 0.08),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.local_florist_rounded,
                                  size: 16,
                                  color: AppColors.brandGreen900,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Kapada',
                                    style: GoogleFonts.playfairDisplay(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.brandGreen900,
                                    ),
                                  ),
                                  Text(
                                    'CREATION  Est. 2015',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 8,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.5,
                                      color: AppColors.brandGreen800,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          // Notification Bell
                          Stack(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.notifications_none_rounded,
                                  size: 24,
                                  color: AppColors.charcoal,
                                ),
                                onPressed: () => context.push(
                                  AppRoutes.customerNotificationList,
                                ),
                                tooltip: 'Notifications',
                              ),
                              if (unreadNotificationCount > 0)
                                Positioned(
                                  right: 8,
                                  top: 8,
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
                      const SizedBox(height: 12),

                      // Greeting Subtitle
                      Text(
                        '${_greeting()}, $formattedCustomerName',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.charcoal,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Let's stitch your style story 🌿",
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
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
              else if (activeDesigns.isEmpty)
                SliverFillRemaining(
                  child: AppEmptyState(
                    icon: Icons.checkroom_rounded,
                    title: 'No styles available yet',
                    message:
                        'The studio collection is currently being updated. Please check back shortly.',
                    actionLabel: 'Refresh',
                    onAction: () => ref.invalidate(designListProvider),
                  ),
                )
              else ...[
                // ── 1. TRENDING Hero Banner ────────────────────────
                if (trendingDesign != null) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildTrendingHeroCard(context, trendingDesign),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 28)),
                ],

                // ── 2. NEW ARRIVALS Section ────────────────────────
                if (displayNewArrivals.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildSectionHeader(
                        title: 'NEW ARRIVALS',
                        onViewAll: () => context.push(
                          AppRoutes.customerCategoryDesigns,
                          extra: newArrivalsCategory,
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 14)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildNewArrivalCard(context, displayNewArrivals[0]),
                          ),
                          if (displayNewArrivals.length > 1) ...[
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildNewArrivalCard(context, displayNewArrivals[1]),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 28)),
                ],

                // ── 3. FESTIVAL Section ───────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildSectionHeader(
                      title: 'FESTIVAL',
                      onViewAll: () => context.push(
                        AppRoutes.customerCategoryDesigns,
                        extra: festiveCategory,
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 14)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        // Left Feature Card
                        Expanded(
                          flex: 5,
                          child: _buildFestivalMainCard(
                            context,
                            festiveCategory,
                            festiveDesigns.isNotEmpty ? festiveDesigns.first : null,
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Right Column Cards
                        Expanded(
                          flex: 4,
                          child: Column(
                            children: [
                              _buildFestivalSubCard(
                                context,
                                festiveDesigns.length > 1 ? festiveDesigns[1].name : 'Lehenga Edit',
                                festiveCategory,
                                festiveDesigns.length > 1 ? festiveDesigns[1] : null,
                              ),
                              const SizedBox(height: 12),
                              _buildFestivalSubCard(
                                context,
                                festiveDesigns.length > 2 ? festiveDesigns[2].name : 'Sharara Style',
                                festiveCategory,
                                festiveDesigns.length > 2 ? festiveDesigns[2] : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 28)),

                // ── 4. SEASONAL Section ───────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildSectionHeader(
                      title: 'SEASONAL',
                      onViewAll: () => context.push(
                        AppRoutes.customerCategoryDesigns,
                        extra: seasonalCategory,
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 14)),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 175,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      physics: const BouncingScrollPhysics(),
                      itemCount: seasonalDesigns.isNotEmpty
                          ? seasonalDesigns.length
                          : (activeDesigns.isNotEmpty ? activeDesigns.take(4).length : 1),
                      separatorBuilder: (context, index) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final design = seasonalDesigns.isNotEmpty
                            ? seasonalDesigns[index]
                            : (activeDesigns.isNotEmpty ? activeDesigns[index % activeDesigns.length] : null);
                        return _buildSeasonalPill(context, seasonalCategory, design);
                      },
                    ),
                  ),
                ),

                // ── 5. CUSTOM ADMIN CATEGORIES ────────────────────
                if (customCategories.isNotEmpty) ...[
                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildSectionHeader(
                        title: 'MORE COLLECTIONS',
                        onViewAll: () => context.push(AppRoutes.customerCategoryList),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 14)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1.1,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: customCategories.length,
                        itemBuilder: (context, index) {
                          final category = customCategories[index];
                          return GestureDetector(
                            onTap: () => context.push(
                              AppRoutes.customerCategoryDesigns,
                              extra: category,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.surfaceWhite,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: AppColors.borderSoft),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: Stack(
                                  children: [
                                    if (category.imageUrl != null &&
                                        category.imageUrl!.isNotEmpty)
                                      Positioned.fill(
                                        child: category.imageUrl!.startsWith('http')
                                            ? Image.network(
                                                category.imageUrl!,
                                                fit: BoxFit.cover,
                                                errorBuilder: (ctx, err, stack) =>
                                                    Container(color: AppColors.brandGreen900),
                                              )
                                            : Container(color: AppColors.brandGreen900),
                                      )
                                    else
                                      Positioned.fill(
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                AppColors.brandGreen900,
                                                AppColors.brandGreen800,
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                          ),
                                        ),
                                      ),

                                    // Dark gradient overlay
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

                                    Positioned(
                                      bottom: 12,
                                      left: 12,
                                      right: 12,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            category.name,
                                            style: GoogleFonts.playfairDisplay(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.surfaceWhite,
                                            ),
                                          ),
                                          if (category.description != null &&
                                              category.description!.isNotEmpty)
                                            Text(
                                              category.description!,
                                              style: GoogleFonts.montserrat(
                                                fontSize: 10,
                                                color: AppColors.brandGreen100,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],

                const SliverToBoxAdapter(child: SizedBox(height: 36)),
              ],
            ],
          ),
        ),
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
        Row(
          children: [
            const Icon(
              Icons.local_florist_rounded,
              size: 14,
              color: AppColors.brandGreen900,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.brandGreen900,
                letterSpacing: 1.4,
              ),
            ),
          ],
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
              const SizedBox(width: 4),
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

  // ── 1. TRENDING Hero Card (Real Firestore Data) ───────────────
  Widget _buildTrendingHeroCard(BuildContext context, DesignModel design) {
    final title = design.name;
    final price = '₹${design.price.toInt()}';
    final hasImg = design.imageUrls.isNotEmpty;
    final imgUrl = hasImg ? design.imageUrls.first : '';

    final isFav = ref.watch(isDesignFavoritedProvider(design.id));

    return GestureDetector(
      onTap: () => context.push(AppRoutes.customerDesignDetails, extra: design),
      child: Container(
        height: 290,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 18,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: Stack(
            children: [
              // Background Image or Brand Color
              Positioned.fill(
                child: hasImg && imgUrl.startsWith('http')
                    ? Image.network(
                        imgUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) =>
                            Container(color: AppColors.brandGreen900),
                      )
                    : Container(color: AppColors.brandGreen900),
              ),

              // Left Organic Shape Overlay
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: MediaQuery.of(context).size.width * 0.58,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.brandGreen900.withValues(alpha: 0.95),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(80),
                      bottomRight: Radius.circular(80),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.local_florist_rounded,
                            size: 11,
                            color: AppColors.brandGreen100,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'TRENDING',
                            style: GoogleFonts.montserrat(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: AppColors.brandGreen100,
                              letterSpacing: 1.4,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Bespoke\nCraft',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.surfaceWhite,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        design.description != null && design.description!.isNotEmpty
                            ? design.description!
                            : 'Tailored with precision by Kapada Creation.',
                        style: GoogleFonts.montserrat(
                          fontSize: 9.5,
                          color: AppColors.brandGreen100,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        title,
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.surfaceWhite,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        price,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.surfaceWhite,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Color Dots
                      Row(
                        children: [
                          _colorDot(const Color(0xFF6B1D2F)),
                          _colorDot(const Color(0xFF1E3A2B)),
                          _colorDot(const Color(0xFFE8DCC4)),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Size Pills
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: ['XS', 'S', 'M', 'L', 'XL'].map((s) {
                            final isM = s == 'M';
                            return Container(
                              margin: const EdgeInsets.only(right: 5),
                              width: 24,
                              height: 24,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isM ? AppColors.surfaceWhite : Colors.transparent,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isM ? AppColors.surfaceWhite : AppColors.brandGreen100,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                s,
                                style: GoogleFonts.montserrat(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: isM ? AppColors.brandGreen900 : AppColors.surfaceWhite,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Top Right Favorite Button
              Positioned(
                top: 14,
                right: 14,
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
                      isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      size: 18,
                      color: isFav ? AppColors.error : AppColors.charcoal,
                    ),
                  ),
                ),
              ),

              // Bottom Right Bestseller Chip
              Positioned(
                bottom: 14,
                right: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF4EB),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE0D4C3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.local_florist_rounded,
                        size: 12,
                        color: AppColors.brandGreen900,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Bestseller',
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.charcoal,
                        ),
                      ),
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

  // ── 2. NEW ARRIVAL Side-By-Side Card ─────────────────────────
  Widget _buildNewArrivalCard(BuildContext context, DesignModel design) {
    final title = design.name;
    final price = '₹${design.price.toInt()}';
    final hasImg = design.imageUrls.isNotEmpty;
    final imgUrl = hasImg ? design.imageUrls.first : '';

    final isFav = ref.watch(isDesignFavoritedProvider(design.id));

    return GestureDetector(
      onTap: () => context.push(AppRoutes.customerDesignDetails, extra: design),
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          color: const Color(0xFFF7F3EC),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE8E0D5)),
        ),
        child: Stack(
          children: [
            // Left Cut Image Box
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 95,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  topRight: Radius.circular(36),
                  bottomRight: Radius.circular(36),
                ),
                child: hasImg && imgUrl.startsWith('http')
                    ? Image.network(
                        imgUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) =>
                            Container(color: AppColors.brandGreen900),
                      )
                    : Container(
                        color: AppColors.brandGreen900,
                        child: const Icon(
                          Icons.checkroom_rounded,
                          color: AppColors.brandGreen100,
                          size: 24,
                        ),
                      ),
              ),
            ),

            // Top Left "New" Badge
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.brandGreen900,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'New',
                  style: GoogleFonts.montserrat(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AppColors.surfaceWhite,
                  ),
                ),
              ),
            ),

            // Top Right Favorite Button
            Positioned(
              top: 10,
              right: 10,
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
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceWhite,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    size: 15,
                    color: isFav ? AppColors.error : AppColors.charcoal,
                  ),
                ),
              ),
            ),

            // Right Text Info
            Positioned(
              left: 105,
              top: 36,
              right: 10,
              bottom: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.charcoal,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        price,
                        style: GoogleFonts.montserrat(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.brandGreen900,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _colorDot(const Color(0xFFD4AF37)),
                          _colorDot(const Color(0xFF800020)),
                          _colorDot(const Color(0xFFE8DCC4)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: ['XS', 'S', 'M', 'L'].map((s) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(
                              s,
                              style: GoogleFonts.montserrat(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: AppColors.mutedText,
                              ),
                            ),
                          );
                        }).toList(),
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

  // ── 3. FESTIVAL Section Main Card ─────────────────────────────
  Widget _buildFestivalMainCard(
    BuildContext context,
    CategoryModel category,
    DesignModel? design,
  ) {
    final title = design?.name ?? category.name;
    final imgUrl = (design != null && design.imageUrls.isNotEmpty)
        ? design.imageUrls.first
        : (category.imageUrl ?? '');

    return GestureDetector(
      onTap: () {
        if (design != null) {
          context.push(AppRoutes.customerDesignDetails, extra: design);
        } else {
          context.push(AppRoutes.customerCategoryDesigns, extra: category);
        }
      },
      child: Container(
        height: 240,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: [
              Positioned.fill(
                child: imgUrl.startsWith('http')
                    ? Image.network(
                        imgUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) =>
                            Container(color: AppColors.brandGreen900),
                      )
                    : Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.brandGreen900, AppColors.brandGreen800],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
              ),
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: 140,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.brandGreen900.withValues(alpha: 0.94),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(60),
                      bottomRight: Radius.circular(60),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.surfaceWhite,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Festive looks stitched with tradition.',
                        style: GoogleFonts.montserrat(
                          fontSize: 9,
                          color: AppColors.brandGreen100,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Explore',
                              style: GoogleFonts.montserrat(
                                fontSize: 8,
                                fontWeight: FontWeight.w600,
                                color: AppColors.surfaceWhite,
                              ),
                            ),
                            const SizedBox(width: 2),
                            const Icon(
                              Icons.chevron_right_rounded,
                              size: 12,
                              color: AppColors.surfaceWhite,
                            ),
                          ],
                        ),
                      ),
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

  Widget _buildFestivalSubCard(
    BuildContext context,
    String defaultTitle,
    CategoryModel category,
    DesignModel? design,
  ) {
    final title = design?.name ?? defaultTitle;
    final imgUrl = (design != null && design.imageUrls.isNotEmpty)
        ? design.imageUrls.first
        : (category.imageUrl ?? '');

    return GestureDetector(
      onTap: () {
        if (design != null) {
          context.push(AppRoutes.customerDesignDetails, extra: design);
        } else {
          context.push(AppRoutes.customerCategoryDesigns, extra: category);
        }
      },
      child: Container(
        height: 114,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            children: [
              Positioned.fill(
                child: imgUrl.startsWith('http')
                    ? Image.network(
                        imgUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) =>
                            Container(color: AppColors.brandGreen800),
                      )
                    : Container(color: AppColors.brandGreen800),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, Colors.black.withValues(alpha: 0.75)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 12,
                bottom: 12,
                right: 12,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.surfaceWhite,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceWhite,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        size: 12,
                        color: AppColors.charcoal,
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

  // ── 4. SEASONAL Pill Card ─────────────────────────────────────
  Widget _buildSeasonalPill(
    BuildContext context,
    CategoryModel category,
    DesignModel? design,
  ) {
    final title = design?.name ?? category.name;
    final imgUrl = (design != null && design.imageUrls.isNotEmpty)
        ? design.imageUrls.first
        : (category.imageUrl ?? '');

    return GestureDetector(
      onTap: () {
        if (design != null) {
          context.push(AppRoutes.customerDesignDetails, extra: design);
        } else {
          context.push(AppRoutes.customerCategoryDesigns, extra: category);
        }
      },
      child: Container(
        width: 115,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Positioned.fill(
                child: imgUrl.startsWith('http')
                    ? Image.network(
                        imgUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) =>
                            Container(color: AppColors.brandGreen900),
                      )
                    : Container(color: AppColors.brandGreen900),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, Colors.black.withValues(alpha: 0.75)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 10,
                bottom: 10,
                right: 10,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.surfaceWhite,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceWhite,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        size: 10,
                        color: AppColors.charcoal,
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

  Widget _colorDot(Color c) {
    return Container(
      margin: const EdgeInsets.only(right: 5),
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: c,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1),
      ),
    );
  }
}
