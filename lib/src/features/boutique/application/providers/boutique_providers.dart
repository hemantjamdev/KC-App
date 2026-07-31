import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kc_app/src/core/providers/firebase_providers.dart';
import 'package:kc_app/src/features/boutique/data/repositories/boutique_firestore_repository.dart';
import 'package:kc_app/src/features/boutique/data/repositories/branch_firestore_repository.dart';
import 'package:kc_app/src/features/boutique/domain/models/boutique_model.dart';
import 'package:kc_app/src/features/boutique/domain/models/branch_model.dart';

// ─────────────────────────────────────────────
// Repository providers
// ─────────────────────────────────────────────

/// Provides the [BoutiqueFirestoreRepository].
/// All boutique data access must go through this provider.
final boutiqueRepositoryProvider = Provider<BoutiqueFirestoreRepository>((ref) {
  return BoutiqueFirestoreRepository(
    firestore: ref.watch(firebaseFirestoreProvider),
  );
});

/// Provides the [BranchFirestoreRepository].
/// All branch data access must go through this provider.
final branchRepositoryProvider = Provider<BranchFirestoreRepository>((ref) {
  return BranchFirestoreRepository(
    firestore: ref.watch(firebaseFirestoreProvider),
  );
});

// ─────────────────────────────────────────────
// Session selection providers  (keepAlive — global session state)
// ─────────────────────────────────────────────

/// Holds the admin-selected [BoutiqueModel] for the current session.
/// keepAlive: true — survives route changes and widget rebuilds.
final selectedBoutiqueProvider =
    NotifierProvider<SelectedBoutiqueNotifier, BoutiqueModel?>(
      SelectedBoutiqueNotifier.new,
      name: 'selectedBoutiqueProvider',
    );

class SelectedBoutiqueNotifier extends Notifier<BoutiqueModel?> {
  @override
  BoutiqueModel? build() => null;

  void select(BoutiqueModel boutique) {
    if (!boutique.isActive) return;
    if (state?.id == boutique.id) return;
    state = boutique;
    // Changing boutique resets branch selection.
    ref.read(selectedBranchProvider.notifier).clear();
  }

  void clear() {
    state = null;
    ref.read(selectedBranchProvider.notifier).clear();
  }
}

/// Holds the admin-selected [BranchModel] for the current session.
final selectedBranchProvider =
    NotifierProvider<SelectedBranchNotifier, BranchModel?>(
      SelectedBranchNotifier.new,
    );

class SelectedBranchNotifier extends Notifier<BranchModel?> {
  @override
  BranchModel? build() => null;

  void select(BranchModel branch) {
    if (!branch.isActive) return;
    final boutique = ref.read(selectedBoutiqueProvider);
    if (boutique == null || branch.boutiqueId != boutique.id) return;
    state = branch;
  }

  void clear() => state = null;
}

// ─────────────────────────────────────────────
// Boutique list provider
// ─────────────────────────────────────────────

/// Provides the live stream of all [BoutiqueModel]s.
final boutiqueListProvider = StreamProvider<List<BoutiqueModel>>((ref) {
  return ref.watch(boutiqueRepositoryProvider).watchBoutiques();
});

/// Provides all active boutiques (derived from [boutiqueListProvider]).
final activeBoutiqueListProvider = Provider<List<BoutiqueModel>>((ref) {
  final all = ref.watch(boutiqueListProvider).valueOrNull ?? [];
  return all.where((b) => b.isActive).toList(growable: false);
});

/// Auto-selected boutique for single-shop mode.
final autoSelectedBoutiqueProvider = Provider<BoutiqueModel?>((ref) {
  final active = ref.watch(activeBoutiqueListProvider);
  return active.isNotEmpty ? active.first : null;
});

// ─────────────────────────────────────────────
// Branch list provider  (scoped to selected boutique)
// ─────────────────────────────────────────────

/// Provides all branches for the currently selected boutique.
final branchListProvider = FutureProvider<List<BranchModel>>((ref) async {
  final boutiqueId = ref.watch(selectedBoutiqueProvider)?.id;
  if (boutiqueId == null) return const [];
  return ref.watch(branchRepositoryProvider).getBranchesForBoutique(boutiqueId);
});

/// Provides all active branches for the currently selected boutique.
final activeBranchListProvider = Provider<List<BranchModel>>((ref) {
  final all = ref.watch(branchListProvider).valueOrNull ?? [];
  return all.where((b) => b.isActive).toList(growable: false);
});
