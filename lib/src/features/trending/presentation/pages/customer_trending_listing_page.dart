import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/customer_empty_state.dart';
import '../../application/providers/trending_pagination_provider.dart';
import '../widgets/instagram_trending_card.dart';

/// Dedicated Paginated Trending Listing Screen with Instagram-style Feed Layout.
/// Displays top-ranked boutique garments with double-tap like (no grey splash),
/// real-time like counts, "Liked by..." customer summary, and bookmarking.
class CustomerTrendingListingPage extends ConsumerStatefulWidget {
  const CustomerTrendingListingPage({super.key});

  @override
  ConsumerState<CustomerTrendingListingPage> createState() =>
      _CustomerTrendingListingPageState();
}

class _CustomerTrendingListingPageState
    extends ConsumerState<CustomerTrendingListingPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 250) {
      ref.read(trendingPaginationProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(trendingPaginationProvider);
    final items = state.items;

    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceWhite,
        foregroundColor: AppColors.charcoal,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trending Collection',
              style: GoogleFonts.playfairDisplay(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            Text(
              'Ranked by popularity & customer engagement',
              style: GoogleFonts.montserrat(
                fontSize: 10,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: state.isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 2.5,
                ),
              )
            : items.isEmpty
                ? CustomerEmptyState(
                    icon: Icons.local_fire_department_rounded,
                    title: 'No trending styles found',
                    subtitle:
                        'Check back soon as customer favorites are updated live.',
                  )
                : RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () async {
                      await ref
                          .read(trendingPaginationProvider.notifier)
                          .refresh();
                    },
                    child: CustomScrollView(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Double-tap image to like ❤️',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 11,
                                    fontStyle: FontStyle.italic,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.brandGreen50,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '${items.length} STYLES',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Instagram Feed Cards List
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                return InstagramTrendingCard(
                                  design: items[index],
                                  rankIndex: index,
                                );
                              },
                              childCount: items.length,
                            ),
                          ),
                        ),

                        if (state.isLoadingMore)
                          const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.primary,
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          )
                        else if (!state.hasMore && items.isNotEmpty)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Center(
                                child: Text(
                                  '• You have reached the end of trending styles •',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 11,
                                    color: AppColors.textMuted,
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
}
