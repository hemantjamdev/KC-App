import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kc_app/src/core/errors/failure_mapper.dart';
import '../../../../core/providers/firebase_providers.dart';
import '../../../customer/application/providers/customer_providers.dart';
import '../../../customer/domain/models/customer_model.dart';
import '../../../design/application/providers/favorite_providers.dart';
import '../../domain/models/customer_session_state.dart';

void _logAuth(String message) {
  if (kDebugMode) {
    debugPrint('[CustomerSession] $message');
  }
}

/// Single authoritative customer authentication session provider.
final customerSessionProvider =
    NotifierProvider<CustomerSessionNotifier, CustomerSessionState>(
      CustomerSessionNotifier.new,
    );

class CustomerSessionNotifier extends Notifier<CustomerSessionState> {
  StreamSubscription<User?>? _authSubscription;

  @override
  CustomerSessionState build() {
    final auth = ref.watch(firebaseAuthProvider);

    // Subscribe to auth state changes from FirebaseAuth
    _authSubscription?.cancel();
    _authSubscription = auth.authStateChanges().listen(_handleAuthStateChange);

    ref.onDispose(() {
      _authSubscription?.cancel();
    });

    final currentUser = auth.currentUser;
    if (currentUser == null) {
      _logAuth('Initial auth state: guest');
      return const CustomerSessionState.guest();
    } else {
      _logAuth('Initial auth state: authenticated (${currentUser.uid})');
      Future.microtask(() => _resolveOrCreateCustomerProfile(currentUser));
      return CustomerSessionState.authenticated(
        firebaseUser: currentUser,
        isProfileLoading: true,
      );
    }
  }

  void _handleAuthStateChange(User? user) {
    _logAuth('Auth-state emission: ${user?.uid ?? "null"}');
    if (user == null) {
      _transitionTo(const CustomerSessionState.guest());
    } else {
      final current = state;
      if (current is CustomerSessionAuthenticated &&
          current.firebaseUser.uid == user.uid) {
        _transitionTo(current.copyWith(firebaseUser: user));
      } else {
        _transitionTo(
          CustomerSessionState.authenticated(
            firebaseUser: user,
            isProfileLoading: true,
          ),
        );
        _resolveOrCreateCustomerProfile(user);
      }
    }
  }

  void _transitionTo(CustomerSessionState newState) {
    _logAuth('Session state transition: $newState');
    state = newState;
  }

  Future<void> _resolveOrCreateCustomerProfile(User user) async {
    _logAuth('Customer upsert start for UID: ${user.uid}');
    try {
      final customerRepo = ref.read(customerRepositoryProvider);

      // 1. Try lookup by Firebase UID first (the most reliable key).
      CustomerModel? existing = await customerRepo.getCustomerByFirebaseUid(
        user.uid,
      );

      // 2. Fallback: if no record with this UID, check by email.
      //    This handles the case where admin pre-created the customer without UID.
      if (existing == null && user.email != null) {
        existing = await customerRepo.getCustomerByEmail(user.email!);
        if (existing != null) {
          _logAuth(
            'Found existing customer by email (${user.email}), merging UID.',
          );
          // Merge the Firebase UID into the existing admin-created record.
          final merged = existing.copyWith(
            firebaseUid: user.uid,
            displayName: user.displayName ?? existing.displayName,
            photoUrl: user.photoURL ?? existing.photoUrl,
            updatedAt: DateTime.now(),
            updatedBy: user.uid,
          );
          existing = await customerRepo.updateCustomer(merged);
        }
      }

      CustomerModel customer;
      if (existing == null) {
        // 3. Truly new customer — create a fresh record keyed by Firebase UID.
        final now = DateTime.now();
        final newCustomer = CustomerModel(
          id: user.uid,
          firebaseUid: user.uid,
          displayName: user.displayName ?? 'Valued Customer',
          email: user.email,
          phone: user.phoneNumber,
          photoUrl: user.photoURL,
          boutiqueIds: const ['default'],
          branchIds: const [],
          source: CustomerSource.google,
          isActive: true,
          createdAt: now,
          updatedAt: now,
          createdBy: user.uid,
          updatedBy: user.uid,
        );
        customer = await customerRepo.createCustomer(newCustomer);
      } else {
        // 4. Already exists — refresh display name / photo if changed.
        final updatedName = user.displayName ?? existing.displayName;
        final updatedPhoto = user.photoURL ?? existing.photoUrl;
        if (updatedName != existing.displayName ||
            updatedPhoto != existing.photoUrl) {
          final merged = existing.copyWith(
            displayName: updatedName,
            photoUrl: updatedPhoto,
            updatedAt: DateTime.now(),
            updatedBy: user.uid,
          );
          customer = await customerRepo.updateCustomer(merged);
        } else {
          customer = existing;
        }
      }

      _logAuth('Customer upsert success for ID: ${customer.id}');
      if (state is CustomerSessionAuthenticated) {
        final current = state as CustomerSessionAuthenticated;
        if (current.firebaseUser.uid == user.uid) {
          _transitionTo(
            CustomerSessionState.authenticated(
              firebaseUser: user,
              customer: customer,
              isProfileLoading: false,
            ),
          );
        }
      }
    } catch (e, st) {
      _logAuth('Customer upsert failure for UID ${user.uid}: $e');
      final failure = FailureMapper.map(e, st);
      if (state is CustomerSessionAuthenticated) {
        final current = state as CustomerSessionAuthenticated;
        if (current.firebaseUser.uid == user.uid) {
          _transitionTo(
            CustomerSessionState.authenticated(
              firebaseUser: user,
              customer: current.customer,
              isProfileLoading: false,
              profileFailure: failure,
            ),
          );
        }
      }
    }
  }

  Future<bool> signInWithGoogle({
    String defaultBoutiqueId = 'default',
    String defaultBranchId = '',
  }) async {
    _logAuth('Google Sign-In initiated');
    try {
      final googleSignIn = GoogleSignIn();
      final googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        _logAuth('Google account result: cancelled by user');
        if (state is! CustomerSessionAuthenticated) {
          _transitionTo(const CustomerSessionState.guest());
        }
        return false;
      }

      _logAuth('Google account result: ${googleUser.email}');
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      _logAuth('Firebase credential sign-in start');
      final auth = ref.read(firebaseAuthProvider);
      final userCredential = await auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        _logAuth('Firebase credential result: UID ${user.uid}');
        return true;
      } else {
        _logAuth('Firebase credential result: null user');
        return false;
      }
    } catch (e, st) {
      _logAuth('Google Sign-In error: $e');
      final failure = FailureMapper.map(e, st);
      if (state is! CustomerSessionAuthenticated) {
        _transitionTo(CustomerSessionState.failure(failure));
      }
      return false;
    }
  }

  Future<void> signOut() async {
    _logAuth('Sign out initiated');
    try {
      await GoogleSignIn().signOut();
    } catch (_) {}
    try {
      await ref.read(firebaseAuthProvider).signOut();
    } catch (_) {}

    ref.invalidate(customerFavoriteIdsProvider);
    ref.invalidate(customerProfileProvider);

    _transitionTo(const CustomerSessionState.guest());
  }
}

/// Legacy stream of FirebaseAuth user state changes.
final firebaseAuthStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

/// Current authenticated User (or null for guest), derived from customerSessionProvider.
final currentCustomerUserProvider = Provider<User?>((ref) {
  final session = ref.watch(customerSessionProvider);
  return session.mapOrNull(authenticated: (s) => s.firebaseUser);
});

/// Returns boolean indicating if user is authenticated.
final isAuthenticatedProvider = Provider<bool>((ref) {
  final session = ref.watch(customerSessionProvider);
  return session.maybeMap(authenticated: (_) => true, orElse: () => false);
});

/// Stream of current logged-in customer profile from Firestore.
final customerProfileProvider = StreamProvider<CustomerModel?>((ref) {
  final user = ref.watch(currentCustomerUserProvider);
  if (user == null) return Stream.value(null);
  return ref.watch(customerRepositoryProvider).watchCustomer(user.uid);
});

/// Google Sign-In & Customer Auth Notifier for backwards compatibility.
final googleAuthNotifierProvider =
    NotifierProvider<GoogleAuthNotifier, AsyncValue<User?>>(
      GoogleAuthNotifier.new,
    );

class GoogleAuthNotifier extends Notifier<AsyncValue<User?>> {
  @override
  AsyncValue<User?> build() {
    final user = ref.watch(currentCustomerUserProvider);
    return AsyncValue.data(user);
  }

  Future<User?> signInWithGoogle() async {
    state = const AsyncValue.loading();
    final success = await ref
        .read(customerSessionProvider.notifier)
        .signInWithGoogle();
    final user = ref.read(currentCustomerUserProvider);
    if (success && user != null) {
      state = AsyncValue.data(user);
      return user;
    } else {
      state = AsyncValue.data(ref.read(currentCustomerUserProvider));
      return null;
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    await ref.read(customerSessionProvider.notifier).signOut();
    state = const AsyncValue.data(null);
  }
}
