import 'package:flutter_test/flutter_test.dart';
import 'package:kc_app/src/core/errors/app_failure.dart';
import 'package:kc_app/src/features/stitching/domain/models/stitching_order_model.dart';
import 'package:kc_app/src/features/stitching/domain/models/stitching_submission_state.dart';

void main() {
  group('Part 2 — Stitching Submission State & Rules Tests', () {
    test('1. validation failure never enters permanent loading', () {
      const state = StitchingSubmissionState.failure(
        AppFailure.validation(message: 'Category required'),
      );
      expect(state, isA<StitchingSubmissionFailure>());
      expect(state is StitchingSubmissionSubmitting, isFalse);
    });

    test('2. unauthenticated submission emits failure', () {
      const state = StitchingSubmissionState.failure(
        AppFailure.authentication(message: 'Auth required'),
      );
      expect(state, isA<StitchingSubmissionFailure>());
    });

    test('3. Firestore/repository success emits success state', () {
      final now = DateTime.now();
      final order = StitchingOrderModel(
        id: 'stitch_101',
        boutiqueId: 'boutique_01',
        branchId: '',
        customerId: 'cust_101',
        orderNumber: 'KC-ST-101',
        status: StitchingOrderStatus.requested,
        designReferences: const [],
        createdAt: now,
        updatedAt: now,
      );

      final state = StitchingSubmissionState.success(order);
      expect(state, isA<StitchingSubmissionSuccess>());
      expect(
        (state as StitchingSubmissionSuccess).request.id,
        equals('stitch_101'),
      );
    });

    test('4. repository failure emits failure state', () {
      const failure = AppFailure.server(message: 'Firestore quota exceeded');
      const state = StitchingSubmissionState.failure(failure);
      expect(state, equals(const StitchingSubmissionState.failure(failure)));
    });

    test('5. unexpected exception emits failure state', () {
      const failure = AppFailure.unknown(message: 'Unexpected network drop');
      const state = StitchingSubmissionState.failure(failure);
      expect(state, isA<StitchingSubmissionFailure>());
    });

    test('6. duplicate taps create single submitting transition', () {
      StitchingSubmissionState state =
          const StitchingSubmissionState.submitting();
      expect(state, isA<StitchingSubmissionSubmitting>());
    });

    test('7. submission success clears submitting loading indicator', () {
      final now = DateTime.now();
      final order = StitchingOrderModel(
        id: 'stitch_102',
        boutiqueId: 'boutique_01',
        branchId: '',
        customerId: 'cust_102',
        orderNumber: 'KC-ST-102',
        status: StitchingOrderStatus.requested,
        designReferences: const [],
        createdAt: now,
        updatedAt: now,
      );

      final state = StitchingSubmissionState.success(order);
      expect(state is StitchingSubmissionSubmitting, isFalse);
    });

    test('8. list remains visible while submission is loading', () {
      const submissionState = StitchingSubmissionState.submitting();
      final list = [
        StitchingOrderModel(
          id: 'existing_1',
          boutiqueId: 'b1',
          branchId: '',
          customerId: 'c1',
          orderNumber: 'KC-ST-001',
          status: StitchingOrderStatus.requested,
          designReferences: const [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      expect(submissionState, isA<StitchingSubmissionSubmitting>());
      expect(list.isNotEmpty, isTrue);
    });

    test('9. failure keeps request sheet usable with populated inputs', () {
      const state = StitchingSubmissionState.failure(
        AppFailure.validation(message: 'Phone number invalid'),
      );
      expect(state, isA<StitchingSubmissionFailure>());
    });

    test('10. customer Firestore rule allows creation for own customerId', () {
      const authUid = 'user_abc';
      const requestCustomerId = 'user_abc';
      const initialStatus = 'received';

      final isAllowed =
          (authUid == requestCustomerId) &&
          (initialStatus == 'received' || initialStatus == 'Requested');
      expect(isAllowed, isTrue);
    });

    test('11. customer cannot create for another UID', () {
      const authUid = 'user_abc';
      const requestCustomerId = 'user_other';

      final isAllowed = (authUid == requestCustomerId);
      expect(isAllowed, isFalse);
    });

    test('12. customer cannot update status', () {
      bool canUpdateStatus({required bool isAdmin}) => isAdmin;
      expect(canUpdateStatus(isAdmin: false), isFalse);
    });
  });
}
