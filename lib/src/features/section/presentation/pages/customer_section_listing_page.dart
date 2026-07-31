import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/customer_empty_state.dart';
import '../../../auth/presentation/widgets/google_auth_bottom_sheet.dart';
import '../../../design/application/providers/design_providers.dart';
import '../../../design/application/providers/favorite_providers.dart';
import '../../../design/domain/models/design_model.dart';
import '../../domain/models/section_model.dart';

/// Paginated section listing page for ready-made boutique garments.
/// Opens from "See All" on Home sections: Trending, New Arrivals, Festival, Seasonal.
class CustomerSectionListingPage extends ConsumerStatefulWidget {
  const CustomerSectionListingPage({super.key, this.section, this.sectionName});

  final SectionModel? section;
  final String? sectionName;

  @override
  ConsumerState<CustomerSectionListingPage> createState() =>
      _CustomerSectionListingPageState();
}

class _CustomerSectionListingPageState
    extends ConsumerState<CustomerSectionListingPage> {
  final _scrollController = ScrollController();
  int _visibleItemCount = 10;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  void _loadMore() {
    if (_isLoadingMore) return;
    setState(() {
      _isLoadingMore = true;
      _visibleItemCount += 6;
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _isLoadingMore = false);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.section?.title ?? widget.sectionName ?? 'Collection';
    final designsAsync = ref.watch(designListProvider);
    final allDesigns = designsAsync.valueOrNull ?? [];
    final isLoading = designsAsync.isLoading;

    // Filter active designs based on section name
    final filtered = _filterForSection(allDesigns, title);
    final displayed = filtered.take(_visibleItemCount).toList();
    final hasMore = displayed.length < filtered.length;

    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceWhite,
        foregroundColor: AppColors.charcoal,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        iconTheme: const IconThemeData(color: AppColors.charcoal),
        title: Text(
          title,
          style: GoogleFonts.playfairDisplay(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.charcoal,
          ),
        ),
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.brandGreen800,
                  strokeWidth: 2,
                ),
              )
            : filtered.isEmpty
            ? CustomerEmptyState(
                icon: Icons.grid_view_rounded,
                title: 'No products in $title',
                subtitle:
                    'Check back soon for new additions to this boutique collection.',
              )
            : RefreshIndicator(
                color: AppColors.brandGreen800,
                onRefresh: () async {
                  ref.invalidate(designListProvider);
                },
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Showing ${displayed.length} of ${filtered.length} garments',
                              style: GoogleFonts.montserrat(
                                fontSize: 12,
                                color: AppColors.mutedText,
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
                                'Curated',
                                style: GoogleFonts.montserrat(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.brandGreen800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      sliver: SliverList.separated(
                        itemCount: displayed.length,
                        separatorBuilder: (ctx, idx) =>
                            const SizedBox(height: 14),
                        itemBuilder: (ctx, idx) =>
                            _SectionProductListItem(design: displayed[idx]),
                      ),
                    ),
                    if (hasMore)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Center(
                            child: _isLoadingMore
                                ? const CircularProgressIndicator(
                                    color: AppColors.brandGreen800,
                                    strokeWidth: 2,
                                  )
                                : TextButton(
                                    onPressed: _loadMore,
                                    child: Text(
                                      'Load More Styles ↓',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.brandGreen800,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    const SliverToBoxAdapter(child: SizedBox(height: 32)),
                  ],
                ),
              ),
      ),
    );
  }

  List<DesignModel> _filterForSection(
    List<DesignModel> designs,
    String sectionName,
  ) {
    final active = designs.where((d) => d.isActive).toList();
    final lower = sectionName.toLowerCase();

    if (lower.contains('trending')) {
      return active;
    } else if (lower.contains('new')) {
      active.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return active;
    } else if (lower.contains('festival')) {
      final matches = active
          .where(
            (d) =>
                d.tags.any((t) => t.toLowerCase().contains('festival')) ||
                d.tags.any((t) => t.toLowerCase().contains('bridal')) ||
                d.searchKeywords.any((k) => k.contains('festival')),
          )
          .toList();
      return matches.isNotEmpty ? matches : active;
    } else if (lower.contains('seasonal')) {
      final matches = active
          .where(
            (d) =>
                d.tags.any((t) => t.toLowerCase().contains('seasonal')) ||
                d.tags.any((t) => t.toLowerCase().contains('silk')) ||
                d.tags.any((t) => t.toLowerCase().contains('summer')),
          )
          .toList();
      return matches.isNotEmpty ? matches : active;
    }
    return active;
  }
}

class _SectionProductListItem extends ConsumerWidget {
  const _SectionProductListItem({required this.design});

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
                      errorWidget: (ctx, err, stack) => const Center(
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
