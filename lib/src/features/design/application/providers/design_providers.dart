import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kc_app/src/core/providers/firebase_providers.dart';
import 'package:kc_app/src/features/boutique/application/providers/boutique_providers.dart';
import 'package:kc_app/src/features/category/application/providers/category_providers.dart';
import 'package:kc_app/src/features/design/data/repositories/design_firestore_repository.dart';
import 'package:kc_app/src/features/design/domain/models/design_availability_model.dart';
import 'package:kc_app/src/features/design/domain/models/design_model.dart';

// ─────────────────────────────────────────────
// Repository provider
// ─────────────────────────────────────────────

final designRepositoryProvider = Provider<DesignFirestoreRepository>((ref) {
  return DesignFirestoreRepository(
    firestore: ref.watch(firebaseFirestoreProvider),
  );
});

// ─────────────────────────────────────────────
// Filter state
// ─────────────────────────────────────────────

enum DesignStatusFilter { all, active, inactive }

enum AvailabilityFilter { all, available, unavailable, hidden, notConfigured }

class DesignFilterState {
  const DesignFilterState({
    this.searchQuery = '',
    this.statusFilter = DesignStatusFilter.all,
    this.selectedCategoryId,
    this.availabilityFilter = AvailabilityFilter.all,
    this.filterBranchId,
  });
  final String searchQuery;
  final DesignStatusFilter statusFilter;
  final String? selectedCategoryId;
  final AvailabilityFilter availabilityFilter;
  final String? filterBranchId;

  DesignFilterState copyWith({
    String? searchQuery,
    DesignStatusFilter? statusFilter,
    Object? selectedCategoryId = _sentinel,
    AvailabilityFilter? availabilityFilter,
    Object? filterBranchId = _sentinel,
  }) => DesignFilterState(
    searchQuery: searchQuery ?? this.searchQuery,
    statusFilter: statusFilter ?? this.statusFilter,
    selectedCategoryId: selectedCategoryId == _sentinel
        ? this.selectedCategoryId
        : selectedCategoryId as String?,
    availabilityFilter: availabilityFilter ?? this.availabilityFilter,
    filterBranchId: filterBranchId == _sentinel
        ? this.filterBranchId
        : filterBranchId as String?,
  );
}

const _sentinel = Object();

// ─────────────────────────────────────────────
// Design list — live stream for selected boutique
// ─────────────────────────────────────────────

final designListProvider = StreamProvider<List<DesignModel>>((ref) {
  final boutiqueId =
      ref.watch(selectedBoutiqueProvider)?.id ??
      ref.watch(autoSelectedBoutiqueProvider)?.id ??
      'boutique_01';
  return ref.watch(designRepositoryProvider).watchDesigns(boutiqueId);
});

// ─────────────────────────────────────────────
// Design availability — per boutique
// ─────────────────────────────────────────────

final designAvailabilityListProvider =
    FutureProvider<List<DesignAvailabilityModel>>((ref) async {
      // Availability is loaded per-page when needed (design_availability_page).
      // This provider is a placeholder — pages that need availability load it directly.
      return const [];
    });

// ─────────────────────────────────────────────
// Filter notifier
// ─────────────────────────────────────────────

final designFilterProvider =
    NotifierProvider<DesignFilterNotifier, DesignFilterState>(
      DesignFilterNotifier.new,
    );

class DesignFilterNotifier extends Notifier<DesignFilterState> {
  @override
  DesignFilterState build() => const DesignFilterState();

  void search(String q) => state = state.copyWith(searchQuery: q.trim());

  void filterByStatus(DesignStatusFilter f) =>
      state = state.copyWith(statusFilter: f);

  void filterByCategory(String? categoryId) =>
      state = state.copyWith(selectedCategoryId: categoryId);

  void filterByAvailability(AvailabilityFilter f, {String? branchId}) =>
      state = state.copyWith(availabilityFilter: f, filterBranchId: branchId);

  void reset() => state = const DesignFilterState();
}

// ─────────────────────────────────────────────
// Derived: filtered design list
// ─────────────────────────────────────────────

final filteredDesignListProvider = Provider<List<DesignModel>>((ref) {
  final all = ref.watch(designListProvider).valueOrNull ?? [];
  final filter = ref.watch(designFilterProvider);

  var result = all.where((d) {
    switch (filter.statusFilter) {
      case DesignStatusFilter.active:
        if (!d.isActive) return false;
      case DesignStatusFilter.inactive:
        if (d.isActive) return false;
      case DesignStatusFilter.all:
        break;
    }
    if (filter.selectedCategoryId != null &&
        d.categoryId != filter.selectedCategoryId) {
      return false;
    }
    if (filter.searchQuery.isNotEmpty) {
      final q = filter.searchQuery.toLowerCase();
      return d.name.toLowerCase().contains(q) ||
          d.slug.toLowerCase().contains(q) ||
          d.tags.any((t) => t.toLowerCase().contains(q)) ||
          d.searchKeywords.any((k) => k.toLowerCase().contains(q));
    }
    return true;
  }).toList();

  result.sort((a, b) {
    final s = a.sortOrder.compareTo(b.sortOrder);
    return s != 0 ? s : a.name.compareTo(b.name);
  });

  return result;
});

/// Active designs for a given branch — used by customer-facing pages.
final availableDesignsForBranchProvider =
    Provider.family<List<DesignModel>, String>((ref, branchId) {
      final all = ref.watch(designListProvider).valueOrNull ?? [];
      final avail = ref.watch(designAvailabilityListProvider).valueOrNull ?? [];
      final activeCategories = ref.watch(activeCategoryListProvider);
      final activeCategoryIds = activeCategories.map((c) => c.id).toSet();
      final now = DateTime.now();

      return all
          .where((d) {
            if (activeCategoryIds.isNotEmpty &&
                !activeCategoryIds.contains(d.categoryId)) {
              return false;
            }
            try {
              final a = avail.firstWhere(
                (a) => a.branchId == branchId && a.designId == d.id,
              );
              if (a.status == AvailabilityStatus.hidden) return false;
              if (a.availableFrom != null && now.isBefore(a.availableFrom!)) {
                return false;
              }
              if (a.availableUntil != null && now.isAfter(a.availableUntil!)) {
                return false;
              }
              return true;
            } catch (_) {
              return true;
            }
          })
          .toList(growable: false);
    });

// ─────────────────────────────────────────────
// Design details — family by ID
// ─────────────────────────────────────────────

final designDetailsProvider = Provider.family<DesignModel?, String>((
  ref,
  designId,
) {
  final all = ref.watch(designListProvider).valueOrNull ?? [];
  try {
    return all.firstWhere((d) => d.id == designId);
  } catch (_) {
    return null;
  }
});

// ─────────────────────────────────────────────
// Mutation notifier (admin)
// ─────────────────────────────────────────────

final designMutationProvider =
    NotifierProvider<DesignMutationNotifier, AsyncValue<void>>(
      DesignMutationNotifier.new,
    );

class DesignMutationNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  DesignFirestoreRepository get _repo => ref.read(designRepositoryProvider);

  Future<void> create(DesignModel design) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.createDesign(design));
    if (!state.hasError) ref.invalidate(designListProvider);
  }

  Future<void> update(DesignModel design) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.updateDesign(design));
    if (!state.hasError) ref.invalidate(designListProvider);
  }

  Future<void> upsertAvailability({
    required String boutiqueId,
    required String branchId,
    required String designId,
    required String status,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _repo.upsertAvailability(
        boutiqueId: boutiqueId,
        branchId: branchId,
        designId: designId,
        status: status,
      ),
    );
  }

  Future<void> reorder(List<DesignModel> reordered) async {
    final updated = List<DesignModel>.generate(
      reordered.length,
      (i) => reordered[i].copyWith(sortOrder: i, updatedAt: DateTime.now()),
    );
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      for (final d in updated) {
        await _repo.updateDesign(d);
      }
    });
    if (!state.hasError) ref.invalidate(designListProvider);
  }
}

// ─────────────────────────────────────────────
// Derived: Trending Ranked Design List & Hero Design
// ─────────────────────────────────────────────

/// Ranks active designs for the Trending section based on engagement (favorites, likes),
/// recency, tag bonuses ('trending', 'bestseller', 'hero'), and sort order.
final trendingDesignListProvider = Provider<List<DesignModel>>((ref) {
  final all = ref.watch(designListProvider).valueOrNull ?? [];
  final active = all.where((d) => d.isActive).toList();
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

  return active;
});

final trendingHeroDesignProvider = Provider<DesignModel?>((ref) {
  final trendingList = ref.watch(trendingDesignListProvider);
  return trendingList.isNotEmpty ? trendingList.first : null;
});

