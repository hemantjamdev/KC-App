import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/firebase_providers.dart';
import '../../../auth/application/providers/auth_providers.dart';
import '../../data/repositories/favorite_firestore_repository.dart';
import '../../domain/models/design_model.dart';
import 'design_providers.dart';

final favoriteRepositoryProvider = Provider<FavoriteFirestoreRepository>((ref) {
  return FavoriteFirestoreRepository(
    firestore: ref.watch(firebaseFirestoreProvider),
  );
});

/// Stream of favorite design IDs for the currently logged in customer.
final customerFavoriteIdsProvider = StreamProvider<List<String>>((ref) {
  final user = ref.watch(currentCustomerUserProvider);
  if (user == null) return Stream.value([]);
  return ref
      .watch(favoriteRepositoryProvider)
      .watchCustomerFavoriteIds(user.uid);
});

/// Returns boolean indicating if a design is favorited by the logged in customer.
final isDesignFavoritedProvider = Provider.family<bool, String>((
  ref,
  designId,
) {
  final favoriteIds = ref.watch(customerFavoriteIdsProvider).valueOrNull ?? [];
  return favoriteIds.contains(designId);
});

/// Stream of full DesignModels favorited by the customer.
final customerFavoriteDesignsProvider = FutureProvider<List<DesignModel>>((
  ref,
) async {
  final favoriteIds = ref.watch(customerFavoriteIdsProvider).valueOrNull ?? [];
  if (favoriteIds.isEmpty) return [];
  final repo = ref.watch(designRepositoryProvider);
  return repo.getDesignsByIds(favoriteIds);
});

/// Mutation notifier for toggling favorites.
final favoriteMutationProvider =
    NotifierProvider<FavoriteMutationNotifier, AsyncValue<void>>(
      FavoriteMutationNotifier.new,
    );

class FavoriteMutationNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<bool> toggleFavorite(String designId) async {
    final user = ref.read(currentCustomerUserProvider);
    if (user == null) return false; // trigger auth sheet

    final isFav = ref.read(isDesignFavoritedProvider(designId));
    final repo = ref.read(favoriteRepositoryProvider);

    state = const AsyncValue.loading();
    if (isFav) {
      state = await AsyncValue.guard(
        () => repo.removeFavorite(customerId: user.uid, designId: designId),
      );
    } else {
      state = await AsyncValue.guard(
        () => repo.addFavorite(customerId: user.uid, designId: designId),
      );
    }

    if (!state.hasError) {
      ref.invalidate(customerFavoriteIdsProvider);
      ref.invalidate(customerFavoriteDesignsProvider);
    }
    return true;
  }
}
