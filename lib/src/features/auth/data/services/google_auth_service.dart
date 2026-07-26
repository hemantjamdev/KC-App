import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Categories of Google Sign-In errors for safe diagnostic reporting.
enum GoogleAuthErrorCategory {
  cancelled,
  network,
  developerConfiguration,
  accountDisabled,
  credentialConflict,
  firebaseUnavailable,
  permissionDenied,
  customerInactive,
  unknown,
}

/// Diagnostic result from Google Sign-In authentication.
class GoogleAuthResult {
  const GoogleAuthResult.success(this.user)
      : isSuccess = true,
        errorCategory = null,
        errorMessage = null;

  const GoogleAuthResult.failure(this.errorCategory, this.errorMessage)
      : isSuccess = false,
        user = null;

  final bool isSuccess;
  final User? user;
  final GoogleAuthErrorCategory? errorCategory;
  final String? errorMessage;
}

/// Service dedicated to Google Sign-In and Firebase Auth integration.
class GoogleAuthService {
  GoogleAuthService({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  bool _isOperationInProgress = false;

  bool get isOperationInProgress => _isOperationInProgress;

  /// Signs in with Google and returns a structured result.
  Future<GoogleAuthResult> signIn() async {
    if (_isOperationInProgress) {
      return const GoogleAuthResult.failure(
        GoogleAuthErrorCategory.unknown,
        'Sign-in operation is already in progress.',
      );
    }

    _isOperationInProgress = true;

    try {
      final googleAccount = await _googleSignIn.signIn();
      if (googleAccount == null) {
        _isOperationInProgress = false;
        return const GoogleAuthResult.failure(
          GoogleAuthErrorCategory.cancelled,
          'Sign-in was cancelled by user.',
        );
      }

      final googleAuth = await googleAccount.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      _isOperationInProgress = false;

      if (user == null) {
        return const GoogleAuthResult.failure(
          GoogleAuthErrorCategory.firebaseUnavailable,
          'Firebase Authentication returned a null user.',
        );
      }

      return GoogleAuthResult.success(user);
    } on FirebaseAuthException catch (e) {
      _isOperationInProgress = false;
      if (kDebugMode) {
        debugPrint('[GoogleAuthService] FirebaseAuthException: ${e.code} - ${e.message}');
      }

      final category = switch (e.code) {
        'account-exists-with-different-credential' => GoogleAuthErrorCategory.credentialConflict,
        'user-disabled' => GoogleAuthErrorCategory.accountDisabled,
        'network-request-failed' => GoogleAuthErrorCategory.network,
        'invalid-credential' => GoogleAuthErrorCategory.developerConfiguration,
        _ => GoogleAuthErrorCategory.unknown,
      };

      return GoogleAuthResult.failure(category, e.message ?? 'Authentication failed.');
    } catch (e) {
      _isOperationInProgress = false;
      if (kDebugMode) {
        debugPrint('[GoogleAuthService] Error: $e');
      }

      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('network') || errorStr.contains('socket')) {
        return const GoogleAuthResult.failure(
          GoogleAuthErrorCategory.network,
          'Network connection error. Please check your internet connection.',
        );
      } else if (errorStr.contains('api_exception') || errorStr.contains('10')) {
        return const GoogleAuthResult.failure(
          GoogleAuthErrorCategory.developerConfiguration,
          'Developer configuration error. Verify SHA-1 fingerprint in Firebase Console.',
        );
      }

      return GoogleAuthResult.failure(
        GoogleAuthErrorCategory.unknown,
        'Google Sign-In failed. Please try again.',
      );
    }
  }

  /// Signs out from Google Sign-In and Firebase Auth.
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[GoogleAuthService] SignOut Exception: $e');
      }
    }
  }
}
