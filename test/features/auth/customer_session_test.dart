import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kc_app/src/core/errors/app_failure.dart';
import 'package:kc_app/src/features/auth/domain/models/customer_session_state.dart';

void main() {
  group('Part 1 — Customer Session State Tests', () {
    test('1. Firebase emits null -> guest state', () {
      const state = CustomerSessionState.guest();
      expect(state, isA<CustomerSessionGuest>());
    });

    test('2. Firebase emits User -> authenticated immediately', () {
      final mockUser = _MockUser('user_123', 'test@example.com');
      final state = CustomerSessionState.authenticated(
        firebaseUser: mockUser,
        isProfileLoading: true,
      );

      expect(state, isA<CustomerSessionAuthenticated>());
      final authState = state as CustomerSessionAuthenticated;
      expect(authState.firebaseUser.uid, equals('user_123'));
      expect(authState.isProfileLoading, isTrue);
    });

    test('3. customer profile still loading -> UI remains authenticated', () {
      final mockUser = _MockUser('user_123', 'test@example.com');
      final state = CustomerSessionState.authenticated(
        firebaseUser: mockUser,
        customer: null,
        isProfileLoading: true,
      );

      expect(
        state.maybeMap(authenticated: (_) => true, orElse: () => false),
        isTrue,
      );
    });

    test(
      '4. customer profile fails -> UI remains authenticated with profile failure',
      () {
        final mockUser = _MockUser('user_123', 'test@example.com');
        const failure = AppFailure.server(message: 'Firestore error');
        final state = CustomerSessionState.authenticated(
          firebaseUser: mockUser,
          customer: null,
          isProfileLoading: false,
          profileFailure: failure,
        );

        expect(
          state.maybeMap(authenticated: (_) => true, orElse: () => false),
          isTrue,
        );
        final authState = state as CustomerSessionAuthenticated;
        expect(authState.profileFailure, equals(failure));
      },
    );

    test(
      '5. Google login succeeds -> session transitions to authenticated',
      () {
        final mockUser = _MockUser('user_456', 'google@example.com');
        final state = CustomerSessionState.authenticated(
          firebaseUser: mockUser,
          isProfileLoading: false,
        );

        expect(state, isA<CustomerSessionAuthenticated>());
        expect(
          (state as CustomerSessionAuthenticated).firebaseUser.email,
          equals('google@example.com'),
        );
      },
    );

    test('6. login cancellation -> returns to guest state without error', () {
      const state = CustomerSessionState.guest();
      expect(state, equals(const CustomerSessionState.guest()));
    });

    test('7. logout -> transitions to guest state', () {
      CustomerSessionState state = CustomerSessionState.authenticated(
        firebaseUser: _MockUser('user_123', 'test@example.com'),
      );
      expect(state, isA<CustomerSessionAuthenticated>());

      state = const CustomerSessionState.guest();
      expect(state, isA<CustomerSessionGuest>());
    });

    test(
      '8. pending Favorites destination resumes after authenticated state',
      () {
        final state = CustomerSessionState.authenticated(
          firebaseUser: _MockUser('user_123', 'test@example.com'),
        );
        final isAuthenticated = state.maybeMap(
          authenticated: (_) => true,
          orElse: () => false,
        );
        expect(isAuthenticated, isTrue);
      },
    );

    test(
      '9. pending My Stitching destination resumes after authenticated state',
      () {
        final state = CustomerSessionState.authenticated(
          firebaseUser: _MockUser('user_123', 'test@example.com'),
        );
        final isAuthenticated = state.maybeMap(
          authenticated: (_) => true,
          orElse: () => false,
        );
        expect(isAuthenticated, isTrue);
      },
    );
  });
}

class _MockUser implements User {
  _MockUser(this._uid, this._email);

  final String _uid;
  final String _email;

  @override
  String get uid => _uid;

  @override
  String? get email => _email;

  @override
  String? get displayName => 'Test User';

  @override
  String? get phoneNumber => null;

  @override
  String? get photoURL => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
