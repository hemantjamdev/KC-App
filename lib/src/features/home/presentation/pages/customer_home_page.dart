import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

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
import '../../../stitching/presentation/widgets/stitching_request_bottom_sheet.dart';

/// Kapada Creation Customer App — Modern Redesigned Luxury Home Dashboard.
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
              // ── 1. Top Header ────────────────────────────────────
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
                            const SizedBox(height: 3),
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
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.brandGreen800,
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
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: PhosphorIcon(
                                PhosphorIcons.bellRinging(PhosphorIconsStyle.bold),
                                size: 20,
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
                              right: 2,
                              top: 2,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFDC2626),
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '$unreadNotificationCount',
                                  style: GoogleFonts.montserrat(
                                    color: Colors.white,
                                    fontSize: 10,
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

              // ── 2. Editorial Hero Featured Banner ────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            PhosphorIcon(
                              PhosphorIcons.sparkle(PhosphorIconsStyle.fill),
                              size: 14,
                              color: const Color(0xFFC5A880),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'KAPADA CREATION BOUTIQUE',
                              style: GoogleFonts.montserrat(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFC5A880),
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Bespoke Bridal Couture\n& Custom Tailoring',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Crafted with tradition, designed for timeless elegance.',
                          style: GoogleFonts.montserrat(
                            fontSize: 12.5,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () => StitchingRequestBottomSheet.show(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFC5A880),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Request Custom Stitching',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                PhosphorIcon(
                                  PhosphorIcons.arrowRight(PhosphorIconsStyle.bold),
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // ── 3. Category Filter Chips Bar ─────────────────────
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'EXPLORE COLLECTIONS',
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.mutedText,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          _buildCategoryPill(
                            label: 'All Garments',
                            slug: 'all',
                            isSelected: _selectedCategorySlug == 'all',
                          ),
                          ...categoriesWithProducts.map((cat) {
                            final slug = cat.slug.isNotEmpty ? cat.slug : cat.id;
                            return _buildCategoryPill(
                              label: cat.name,
                              slug: slug,
                              isSelected: _selectedCategorySlug == slug,
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 20)),

              // ── 4. Main Products Display ─────────────────────────
              if (isLoading)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.brandGreen800,
                      ),
                    ),
                  ),
                )
              else if (filteredDesigns.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: AppEmptyState(
                      title: 'No Garments Found',
                      message: 'No designs match the selected category.',
                      icon: Icons.style_outlined,
                    ),
                  ),
                )
              else ...[
                // Hero Highlight Card (if available)
                if (heroDesign != null && _selectedCategorySlug == 'all') ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'FEATURED HIGHLIGHT',
                            style: GoogleFonts.montserrat(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.mutedText,
                              letterSpacing: 1.1,
                            ),
                          ),
                          const SizedBox(height: 10),
                          _buildHeroFeaturedCard(context, heroDesign),
                        ],
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],

                // Product Catalog Grid
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CATALOG DESIGNS (${filteredDesigns.length})',
                          style: GoogleFonts.montserrat(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.mutedText,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.72,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return _buildGridProductCard(
                          context,
                          filteredDesigns[index],
                        );
                      },
                      childCount: filteredDesigns.length,
                    ),
                  ),
                ),
              ],

              const SliverToBoxAdapter(child: SizedBox(height: 28)),

              // ── 5. Studio Information Card ────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: StoreInfoCard(boutique: boutique),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        ),
      ),
    );
  }

  // ── Category Pill Widget ──────────────────────────────────────────────
  Widget _buildCategoryPill({
    required String label,
    required String slug,
    required bool isSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _selectedCategorySlug = slug),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.brandGreen800 : AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.brandGreen800 : AppColors.borderSoft,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.brandGreen800.withValues(alpha: 0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? Colors.white : AppColors.charcoal,
            ),
          ),
        ),
      ),
    );
  }

  // ── Hero Featured Card Widget ──────────────────────────────────────────
  Widget _buildHeroFeaturedCard(BuildContext context, DesignModel design) {
    final title = design.name;
    final price = '₹${design.price.toInt()}';
    final hasImg = design.imageUrls.isNotEmpty;
    final imgUrl = hasImg ? design.imageUrls.first : '';

    return GestureDetector(
      onTap: () => context.push(AppRoutes.customerDesignDetails, extra: design),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: const Color(0xFF1B5E20).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderSoft),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            children: [
              Positioned.fill(
                child: hasImg && imgUrl.startsWith('http')
                    ? Image.network(
                        imgUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) => Container(
                          color: AppColors.brandGreen800.withValues(alpha: 0.1),
                          child: const Icon(
                            Icons.checkroom_rounded,
                            color: AppColors.mutedText,
                            size: 40,
                          ),
                        ),
                      )
                    : Container(
                        color: AppColors.brandGreen800.withValues(alpha: 0.1),
                        child: const Icon(
                          Icons.checkroom_rounded,
                          color: AppColors.mutedText,
                          size: 40,
                        ),
                      ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withValues(alpha: 0.7),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.8),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 16,
                bottom: 16,
                right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFC5A880),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'FEATURED LOOK',
                              style: GoogleFonts.montserrat(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            title,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
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
                              color: const Color(0xFFC5A880),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        'View →',
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

  // ── Grid Product Card Widget ──────────────────────────────────────────
  Widget _buildGridProductCard(BuildContext context, DesignModel design) {
    final title = design.name;
    final price = '₹${design.price.toInt()}';
    final hasImg = design.imageUrls.isNotEmpty;
    final imgUrl = hasImg ? design.imageUrls.first : '';
    final isFav = ref.watch(isDesignFavoritedProvider(design.id));

    return GestureDetector(
      onTap: () => context.push(AppRoutes.customerDesignDetails, extra: design),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderSoft),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.brandGreen800.withValues(alpha: 0.06),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: hasImg && imgUrl.startsWith('http')
                            ? Image.network(
                                imgUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (ctx, err, stack) => Container(
                                  color: AppColors.brandGreen800.withValues(
                                    alpha: 0.08,
                                  ),
                                  child: const Icon(
                                    Icons.checkroom_rounded,
                                    color: AppColors.mutedText,
                                    size: 28,
                                  ),
                                ),
                              )
                            : Container(
                                color: AppColors.brandGreen800.withValues(
                                  alpha: 0.08,
                                ),
                                child: const Icon(
                                  Icons.checkroom_rounded,
                                  color: AppColors.mutedText,
                                  size: 28,
                                ),
                              ),
                      ),
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
                              color: AppColors.surfaceWhite.withValues(
                                alpha: 0.9,
                              ),
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
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 13.5,
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
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.brandGreen800,
                    ),
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
