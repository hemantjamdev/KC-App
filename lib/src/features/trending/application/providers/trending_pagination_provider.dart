import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../design/application/providers/design_providers.dart';
import '../../../design/domain/models/design_model.dart';
import '../../domain/models/trending_page_state.dart';

/// Riverpod Notifier managing paginated state for the Trending Listing Page.
/// List order remains static during interactions (likes) and only re-sorts on Pull-to-Refresh.
final trendingPaginationProvider =
    NotifierProvider<TrendingPaginationNotifier, TrendingPageState>(
      TrendingPaginationNotifier.new,
    );

class TrendingPaginationNotifier extends Notifier<TrendingPageState> {
  List<DesignModel> _masterRankedList = [];

  @override
  TrendingPageState build() {
    // Read initial snapshot once on initialization (ref.read prevents live jumping on like)
    _masterRankedList = List<DesignModel>.from(
      ref.read(trendingDesignListProvider),
    );

    final initialItems = _masterRankedList.take(8).toList();
    final hasMore = _masterRankedList.length > initialItems.length;

    return TrendingPageState(
      items: initialItems,
      page: 1,
      pageSize: 8,
      hasMore: hasMore,
      isLoading: false,
    );
  }

  /// Load next page of trending items without altering current item positions.
  void loadMore() {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);

    final nextPage = state.page + 1;
    final targetCount = nextPage * state.pageSize;
    final nextItems = _masterRankedList.take(targetCount).toList();
    final hasMore = _masterRankedList.length > nextItems.length;

    state = state.copyWith(
      items: nextItems,
      page: nextPage,
      hasMore: hasMore,
      isLoadingMore: false,
    );
  }

  /// Explicit Pull-to-Refresh: re-fetches from Firestore and re-scores list order.
  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    ref.invalidate(designListProvider);

    try {
      final updatedDesigns = await ref.read(designListProvider.future);
      final active = updatedDesigns.where((d) => d.isActive).toList();
      final now = DateTime.now();

      active.sort((a, b) {
        double score(DesignModel d) {
          final favScore = d.favoriteCount * 3.0;
          final likeScore = d.likeCount * 1.5;
          final daysOld = now.difference(d.createdAt).inDays;
          final recencyBonus = (14 - daysOld).clamp(0, 14) * 0.5;
          final hasTrendingTag = d.tags.any(
            (t) =>
                t.toLowerCase().contains('trending') ||
                t.toLowerCase().contains('bestseller') ||
                t.toLowerCase().contains('hero'),
          );
          final tagBonus = hasTrendingTag ? 10.0 : 0.0;
          final sortOrderPenalty = d.sortOrder * 0.1;

          return favScore + likeScore + recencyBonus + tagBonus - sortOrderPenalty;
        }

        return score(b).compareTo(score(a));
      });

      _masterRankedList = active;

      final newItems = _masterRankedList.take(state.pageSize).toList();
      state = state.copyWith(
        items: newItems,
        page: 1,
        hasMore: _masterRankedList.length > newItems.length,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to refresh styles: $e',
      );
    }
  }

  /// Toggle like on a design — updates like count in-place without re-sorting or jumping items.
  Future<void> toggleLike(String designId) async {
    final currentList = state.items;
    final index = currentList.indexWhere((d) => d.id == designId);
    if (index == -1) return;

    final targetDesign = currentList[index];
    final updatedLikeCount = targetDesign.likeCount + 1;
    final updatedDesign = targetDesign.copyWith(
      likeCount: updatedLikeCount,
      updatedAt: DateTime.now(),
    );

    // Update in-place in current state items
    final updatedItems = List<DesignModel>.from(currentList);
    updatedItems[index] = updatedDesign;
    state = state.copyWith(items: updatedItems);

    // Update in-place in master list to preserve position when loading more
    final masterIndex = _masterRankedList.indexWhere((d) => d.id == designId);
    if (masterIndex != -1) {
      _masterRankedList[masterIndex] = updatedDesign;
    }

    try {
      await ref.read(designRepositoryProvider).updateDesign(updatedDesign);
    } catch (_) {
      // Revert in-place if error occurs
      final revertedItems = List<DesignModel>.from(state.items);
      revertedItems[index] = targetDesign;
      state = state.copyWith(items: revertedItems);
      if (masterIndex != -1) {
        _masterRankedList[masterIndex] = targetDesign;
      }
    }
  }
}
