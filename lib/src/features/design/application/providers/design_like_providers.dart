import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/firebase_providers.dart';
import '../../../auth/application/providers/auth_providers.dart';
import '../../data/repositories/design_like_repository.dart';
import 'design_providers.dart';

final designLikeRepositoryProvider = Provider<DesignLikeRepository>((ref) {
  return DesignLikeRepository(
    firestore: ref.watch(firebaseFirestoreProvider),
  );
});

/// Streams whether current customer has liked a design.
final isDesignLikedProvider = StreamProvider.family<bool, String>((
  ref,
  designId,
) {
  final user = ref.watch(currentCustomerUserProvider);
  if (user == null) return Stream.value(false);
  return ref
      .watch(designLikeRepositoryProvider)
      .watchIsLiked(designId: designId, customerId: user.uid);
});

/// Streams recent likes for a design to show customer names.
final recentDesignLikesProvider =
    StreamProvider.family<List<DesignLikeModel>, String>((ref, designId) {
      return ref
          .watch(designLikeRepositoryProvider)
          .watchRecentLikes(designId);
    });

/// Formats the "Liked by..." summary text for Instagram-style feed.
final likeSummaryTextProvider = Provider.family<String, String>((
  ref,
  designId,
) {
  final design = ref.watch(designDetailsProvider(designId));
  final totalLikes = design?.likeCount ?? 0;
  final isLikedByMe = ref.watch(isDesignLikedProvider(designId)).valueOrNull ?? false;
  final recentLikes = ref.watch(recentDesignLikesProvider(designId)).valueOrNull ?? [];

  if (totalLikes <= 0) {
    return 'Be the first to like this style';
  }

  if (isLikedByMe) {
    if (totalLikes == 1) return 'Liked by You';
    final othersCount = totalLikes - 1;
    return 'Liked by You and $othersCount other${othersCount > 1 ? 's' : ''}';
  }

  if (recentLikes.isNotEmpty) {
    final firstCustomerName = recentLikes.first.customerName;
    if (totalLikes == 1) return 'Liked by $firstCustomerName';
    final othersCount = totalLikes - 1;
    return 'Liked by $firstCustomerName and $othersCount other${othersCount > 1 ? 's' : ''}';
  }

  return 'Liked by $totalLikes member${totalLikes > 1 ? 's' : ''}';
});

/// Mutation notifier for toggling design likes.
final toggleLikeNotifierProvider =
    NotifierProvider<ToggleLikeNotifier, AsyncValue<void>>(
      ToggleLikeNotifier.new,
    );

class ToggleLikeNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<bool> toggle(String designId) async {
    final user = ref.read(currentCustomerUserProvider);
    final profile = ref.read(customerProfileProvider).valueOrNull;
    if (user == null) return false;

    final customerName = (profile?.displayName != null &&
            profile!.displayName.trim().isNotEmpty)
        ? profile.displayName
        : (user.displayName ?? 'Customer');

    final repo = ref.read(designLikeRepositoryProvider);

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => repo.toggleLike(
        designId: designId,
        customerId: user.uid,
        customerName: customerName,
      ),
    );

    if (!state.hasError) {
      ref.invalidate(designListProvider);
      ref.invalidate(isDesignLikedProvider(designId));
      ref.invalidate(recentDesignLikesProvider(designId));
    }
    return true;
  }
}
