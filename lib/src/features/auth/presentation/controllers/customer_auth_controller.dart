import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:kc_app/src/features/auth/data/services/google_auth_service.dart';
import 'package:kc_app/src/features/customer/data/repositories/customer_repository_impl.dart';
import 'package:kc_app/src/features/customer/domain/models/customer_model.dart';
import 'package:kc_app/src/features/customer/domain/repositories/customer_repository.dart';

/// Customer Authentication & Profile Controller for KC-App.
class CustomerAuthController extends ChangeNotifier {
  CustomerAuthController({
    FirebaseAuth? auth,
    GoogleAuthService? googleAuthService,
    CustomerRepository? repository,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _googleAuthService = googleAuthService ?? GoogleAuthService(),
       _repository = repository ?? CustomerRepositoryImpl() {
    restoreSession();
  }

  final FirebaseAuth _auth;
  final GoogleAuthService _googleAuthService;
  final CustomerRepository _repository;

  User? _currentFirebaseUser;
  CustomerModel? _currentCustomer;
  bool _isLoading = false;
  String? _authError;
  GoogleAuthErrorCategory? _errorCategory;

  User? get currentFirebaseUser => _currentFirebaseUser;
  CustomerModel? get currentCustomer => _currentCustomer;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentFirebaseUser != null;
  String? get authError => _authError;
  GoogleAuthErrorCategory? get errorCategory => _errorCategory;

  bool get isCustomerInactive =>
      _currentCustomer != null && !_currentCustomer!.isActive;

  void clearError() {
    if (_authError != null || _errorCategory != null) {
      _authError = null;
      _errorCategory = null;
      notifyListeners();
    }
  }

  /// Restores existing Firebase Auth session and loads customer profile.
  Future<void> restoreSession() async {
    _currentFirebaseUser = _auth.currentUser;
    if (_currentFirebaseUser != null) {
      await _resolveCustomerProfile(_currentFirebaseUser!);
    }
    notifyListeners();
  }

  /// Sign in using Google Sign-In and resolve or create customer record.
  Future<bool> signInWithGoogle({
    required String defaultBoutiqueId,
    required String defaultBranchId,
  }) async {
    if (_isLoading) return false;
    _isLoading = true;
    _authError = null;
    _errorCategory = null;
    notifyListeners();

    final result = await _googleAuthService.signIn();

    if (!result.isSuccess) {
      _isLoading = false;
      if (result.errorCategory == GoogleAuthErrorCategory.cancelled) {
        notifyListeners();
        return false;
      }

      _errorCategory = result.errorCategory;
      _authError = result.errorMessage ?? 'Sign-in failed. Please try again.';
      notifyListeners();
      return false;
    }

    final user = result.user!;
    _currentFirebaseUser = user;

    await _resolveOrCreateCustomerProfile(
      user,
      defaultBoutiqueId: defaultBoutiqueId,
      defaultBranchId: defaultBranchId,
    );

    _isLoading = false;
    notifyListeners();
    return true;
  }

  /// Resolve existing customer by exact [firebaseUid] or create new record.
  Future<void> _resolveOrCreateCustomerProfile(
    User user, {
    required String defaultBoutiqueId,
    required String defaultBranchId,
  }) async {
    final existing = await _repository.getCustomerByFirebaseUid(user.uid);
    if (existing != null) {
      _currentCustomer = existing;
      return;
    }

    // Create a new Google customer record with UUID document ID
    final now = DateTime.now();
    final newCustomer = CustomerModel(
      id: const Uuid().v4(),
      firebaseUid: user.uid,
      displayName: user.displayName ?? 'Customer',
      email: user.email,
      phone: user.phoneNumber,
      photoUrl: user.photoURL,
      boutiqueIds: [defaultBoutiqueId],
      branchIds: [defaultBranchId],
      source: CustomerSource.google,
      isActive: true,
      createdAt: now,
      updatedAt: now,
      createdBy: user.uid,
      updatedBy: user.uid,
    );

    _currentCustomer = await _repository.createCustomer(newCustomer);
  }

  Future<void> _resolveCustomerProfile(User user) async {
    try {
      _currentCustomer = await _repository.getCustomerByFirebaseUid(user.uid);
    } catch (_) {
      _currentCustomer = null;
    }
  }

  /// Refreshes current customer profile from Firestore.
  Future<void> refreshProfile() async {
    if (_currentFirebaseUser == null) return;
    await _resolveCustomerProfile(_currentFirebaseUser!);
    notifyListeners();
  }

  /// Updates profile (display name, phone).
  Future<bool> updateProfile({
    required String displayName,
    String? phone,
  }) async {
    if (_currentCustomer == null) return false;
    _isLoading = true;
    notifyListeners();

    try {
      final now = DateTime.now();
      final updated = _currentCustomer!.copyWith(
        displayName: displayName.trim(),
        phone: phone?.trim().isEmpty == true ? null : phone?.trim(),
        updatedAt: now,
        updatedBy: _currentFirebaseUser?.uid ?? _currentCustomer!.id,
        clearPhone: phone?.trim().isEmpty == true,
      );

      _currentCustomer = await _repository.updateCustomer(updated);

      // Keep Firebase Auth display name synchronized
      if (_currentFirebaseUser != null &&
          displayName != _currentFirebaseUser!.displayName) {
        await _currentFirebaseUser!.updateDisplayName(displayName.trim());
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _authError = 'Could not update profile. Please try again.';
      notifyListeners();
      return false;
    }
  }

  /// Signs out from Firebase Auth and Google Sign-In.
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _googleAuthService.signOut();
    } catch (_) {}

    _currentFirebaseUser = null;
    _currentCustomer = null;
    _isLoading = false;
    notifyListeners();
  }
}
