import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design/application/providers/design_providers.dart';
import 'browse_more_trending_card.dart';
import 'trending_hero_card.dart';

/// Horizontal Luxury Carousel for Home Page Trending Section.
/// Displays top-ranked boutique garments + Browse More Trending card.
class TrendingCarousel extends ConsumerWidget {
  const TrendingCarousel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trendingList = ref.watch(trendingDesignListProvider);
    if (trendingList.isEmpty) return const SizedBox.shrink();

    // Display top 6 trending designs in the home carousel
    final displayList = trendingList.take(6).toList();
    final totalCount = trendingList.length;

    return SizedBox(
      height: 330,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(left: 20),
        itemCount: displayList.length + 1,
        separatorBuilder: (ctx, idx) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          if (index < displayList.length) {
            return TrendingHeroCard(
              design: displayList[index],
              rankIndex: index + 1,
            );
          }
          return BrowseMoreTrendingCard(totalCount: totalCount);
        },
      ),
    );
  }
}
