import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design/application/providers/design_providers.dart';
import 'browse_more_trending_card.dart';
import 'trending_hero_card.dart';

/// Horizontal Luxury Carousel for Home Page Trending Section.
/// Displays top scored hero card + Browse More Trending card.
class TrendingCarousel extends ConsumerWidget {
  const TrendingCarousel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trendingList = ref.watch(trendingDesignListProvider);
    if (trendingList.isEmpty) return const SizedBox.shrink();

    final heroDesign = trendingList.first;
    final totalCount = trendingList.length;

    return SizedBox(
      height: 290,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(left: 20),
        children: [
          // Hero Card (#1 Ranked Design)
          SizedBox(
            width: MediaQuery.of(context).size.width - 40,
            child: TrendingHeroCard(design: heroDesign),
          ),
          const SizedBox(width: 14),

          // 2nd / End Card: Browse More Trending
          BrowseMoreTrendingCard(totalCount: totalCount),
        ],
      ),
    );
  }
}
