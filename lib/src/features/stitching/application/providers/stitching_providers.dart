import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kc_app/src/core/errors/app_failure.dart';
import 'package:kc_app/src/core/errors/failure_mapper.dart';
import 'package:kc_app/src/core/providers/firebase_providers.dart';
import 'package:kc_app/src/features/auth/application/providers/auth_providers.dart';
import 'package:kc_app/src/features/boutique/application/providers/boutique_providers.dart';
import 'package:kc_app/src/features/customer/application/providers/customer_providers.dart';
import 'package:kc_app/src/features/stitching/data/repositories/stitching_order_firestore_repository.dart';
import 'package:kc_app/src/features/stitching/domain/models/stitching_order_model.dart';
import 'package:kc_app/src/features/stitching/domain/models/stitching_submission_state.dart';

// ─────────────────────────────────────────────
// Repository provider
// ─────────────────────────────────────────────

final stitchingRepositoryProvider = Provider<StitchingOrderFirestoreRepository>(
  (ref) {
    return StitchingOrderFirestoreRepository(
      firestore: ref.watch(firebaseFirestoreProvider),
    );
  },
);

// ─────────────────────────────────────────────
// Order filter state
// ─────────────────────────────────────────────

class OrderFilterState {
  const OrderFilterState({this.searchQuery = '', this.statusFilter});
  final String searchQuery;
  final StitchingOrderStatus? statusFilter;

  OrderFilterState copyWith({
    String? searchQuery,
    Object? statusFilter = _sentinel,
  }) => OrderFilterState(
    searchQuery: searchQuery ?? this.searchQuery,
    statusFilter: statusFilter == _sentinel
        ? this.statusFilter
        : statusFilter as StitchingOrderStatus?,
  );
}

const _sentinel = Object();

// ─────────────────────────────────────────────
// Admin order list — live stream
// ─────────────────────────────────────────────

final adminOrderListProvider = StreamProvider<List<StitchingOrderModel>>((ref) {
  final boutiqueId =
      ref.watch(selectedBoutiqueProvider)?.id ??
      ref.watch(autoSelectedBoutiqueProvider)?.id ??
      'boutique_01';
  final branch = ref.watch(selectedBranchProvider);
  return ref
      .watch(stitchingRepositoryProvider)
      .watchAdminOrders(boutiqueId, branch?.id);
});

// ─────────────────────────────────────────────
// Order filter notifier (admin)
// ─────────────────────────────────────────────

final orderFilterProvider =
    NotifierProvider<OrderFilterNotifier, OrderFilterState>(
      OrderFilterNotifier.new,
    );

class OrderFilterNotifier extends Notifier<OrderFilterState> {
  @override
  OrderFilterState build() => const OrderFilterState();

  void search(String q) => state = state.copyWith(searchQuery: q.trim());

  void filterByStatus(StitchingOrderStatus? s) =>
      state = state.copyWith(statusFilter: s);

  void reset() => state = const OrderFilterState();
}

// ─────────────────────────────────────────────
// Derived: filtered admin order list
// ─────────────────────────────────────────────

final filteredOrderListProvider = Provider<List<StitchingOrderModel>>((ref) {
  final all = ref.watch(adminOrderListProvider).valueOrNull ?? [];
  final filter = ref.watch(orderFilterProvider);

  var result = all.where((o) {
    if (filter.statusFilter != null && o.status != filter.statusFilter) {
      return false;
    }
    if (filter.searchQuery.isNotEmpty) {
      final q = filter.searchQuery.toLowerCase();
      return o.orderNumber.toLowerCase().contains(q) ||
          o.designReferences.any(
            (d) => d.designName.toLowerCase().contains(q),
          ) ||
          (o.notes?.toLowerCase().contains(q) ?? false);
    }
    return true;
  }).toList();

  result.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  return result;
});

// ─────────────────────────────────────────────
// Customer order list — live stream (KC-App)
// ─────────────────────────────────────────────

final customerOrderListProvider =
    StreamProvider.family<List<StitchingOrderModel>, String>((ref, customerId) {
      final boutiqueId =
          ref.watch(selectedBoutiqueProvider)?.id ??
          ref.watch(autoSelectedBoutiqueProvider)?.id ??
          'boutique_01';
      return ref
          .watch(stitchingRepositoryProvider)
          .watchCustomerOrders(boutiqueId, customerId);
    });

// ─────────────────────────────────────────────
// Dedicated Stitching Submission Notifier
// ─────────────────────────────────────────────

final stitchingSubmissionProvider =
    NotifierProvider<StitchingSubmissionNotifier, StitchingSubmissionState>(
      StitchingSubmissionNotifier.new,
    );

class StitchingSubmissionNotifier extends Notifier<StitchingSubmissionState> {
  @override
  StitchingSubmissionState build() => const StitchingSubmissionState.idle();

  void reset() => state = const StitchingSubmissionState.idle();

  Future<bool> submitRequest({
    required String? title,
    required String? category,
    required String phone,
    String? notes,
  }) async {
    final user = ref.read(currentCustomerUserProvider);
    if (user == null) {
      state = const StitchingSubmissionState.failure(
        AppFailure.authentication(
          message: 'Authentication required to submit stitching request.',
        ),
      );
      return false;
    }

    final trimmedTitle = title?.trim() ?? '';
    if (trimmedTitle.isEmpty) {
      state = const StitchingSubmissionState.failure(
        AppFailure.validation(
          message: 'Please enter a request title / garment name.',
        ),
      );
      return false;
    }

    if (category == null || category.trim().isEmpty) {
      state = const StitchingSubmissionState.failure(
        AppFailure.validation(message: 'Please select an apparel category.'),
      );
      return false;
    }

    final trimmedPhone = phone.trim();
    if (trimmedPhone.isEmpty) {
      state = const StitchingSubmissionState.failure(
        AppFailure.validation(
          message: 'Please provide a contact phone number for updates.',
        ),
      );
      return false;
    }

    final trimmedNotes = notes?.trim();
    if (trimmedNotes != null && trimmedNotes.length > 200) {
      state = const StitchingSubmissionState.failure(
        AppFailure.validation(
          message: 'Stitching note cannot exceed 200 characters.',
        ),
      );
      return false;
    }

    state = const StitchingSubmissionState.submitting();

    try {
      final customer = ref.read(customerProfileProvider).valueOrNull;
      if (customer != null && customer.phone != trimmedPhone) {
        await ref
            .read(customerRepositoryProvider)
            .updateCustomer(customer.copyWith(phone: trimmedPhone));
      }

      // Resolve boutique ID (prefer explicitly selected or auto-selected, fall back to default).
      final boutique =
          ref.read(selectedBoutiqueProvider) ??
          ref.read(autoSelectedBoutiqueProvider);
      final boutiqueId = boutique?.id ?? 'boutique_01';

      final now = DateTime.now();
      final orderId = 'stitch_${now.millisecondsSinceEpoch}';
      final orderNum =
          'KC-ST-${now.millisecondsSinceEpoch.toString().substring(7)}';

      final garmentName = '$trimmedTitle ($category)';
      final sanitizedNotes = (trimmedNotes != null && trimmedNotes.isNotEmpty)
          ? (trimmedNotes.length > 200
              ? trimmedNotes.substring(0, 200)
              : trimmedNotes)
          : null;

      final newOrder = StitchingOrderModel(
        id: orderId,
        boutiqueId: boutiqueId,
        branchId: '',
        customerId: user.uid,
        orderNumber: orderNum,
        status: StitchingOrderStatus.requested,
        designReferences: [
          DesignReferenceModel(designName: garmentName, quantity: 1),
        ],
        notes: sanitizedNotes,
        createdAt: now,
        updatedAt: now,
        createdBy: user.uid,
      );

      final repo = ref.read(stitchingRepositoryProvider);
      await repo.createOrderWithHistory(
        order: newOrder,
        initialNote: 'Customer submitted request for $garmentName',
        createdBy: user.uid,
      );

      ref.invalidate(customerOrderListProvider);
      state = StitchingSubmissionState.success(newOrder);
      return true;
    } catch (e, st) {
      final failure = FailureMapper.map(e, st);
      state = StitchingSubmissionState.failure(failure);
      return false;
    }
  }
}

// ─────────────────────────────────────────────
// Admin Mutation notifier
// ─────────────────────────────────────────────

final stitchingMutationProvider =
    NotifierProvider<StitchingMutationNotifier, AsyncValue<void>>(
      StitchingMutationNotifier.new,
    );

class StitchingMutationNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  StitchingOrderFirestoreRepository get _repo =>
      ref.read(stitchingRepositoryProvider);

  Future<void> createOrder({
    required StitchingOrderModel order,
    required String initialNote,
    required String createdBy,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _repo.createOrderWithHistory(
        order: order,
        initialNote: initialNote,
        createdBy: createdBy,
      ),
    );
    if (!state.hasError) ref.invalidate(adminOrderListProvider);
  }

  Future<void> updateStatus({
    required String orderId,
    required StitchingOrderStatus newStatus,
    required String updatedBy,
    String? notes,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _repo.updateOrderStatusWithHistory(
        orderId: orderId,
        newStatus: newStatus,
        updatedBy: updatedBy,
        note: notes,
      ),
    );
    if (!state.hasError) ref.invalidate(adminOrderListProvider);
  }
}
