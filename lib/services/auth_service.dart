import 'package:firebase_auth/firebase_auth.dart';

import 'network_service.dart';

class AuthServiceException implements Exception {
  final String message;

  const AuthServiceException(this.message);

  @override
  String toString() {
    return message;
  }
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NetworkService _networkService = NetworkService();

  // Sign up with email and password
  Future<User?> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      await _ensureInternetConnection();

      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Update user profile with display name
      await userCredential.user?.updateDisplayName('$firstName $lastName');
      await userCredential.user?.reload();

      return _auth.currentUser;
    } on FirebaseAuthException catch (e) {
      throw AuthServiceException(_handleAuthError(e));
    } on AuthServiceException {
      rethrow;
    } catch (_) {
      throw const AuthServiceException(
        'Authentication failed. Please try again.',
      );
    }
  }

  // Sign in with email and password
  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _ensureInternetConnection();

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw AuthServiceException(_handleAuthError(e));
    } on AuthServiceException {
      rethrow;
    } catch (_) {
      throw const AuthServiceException(
        'Authentication failed. Please try again.',
      );
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      throw AuthServiceException(_handleAuthError(e));
    } catch (_) {
      throw const AuthServiceException('Unable to sign out right now.');
    }
  }

  Future<void> updateDisplayName(String newDisplayName) async {
    try {
      await _ensureInternetConnection();

      final User? user = _auth.currentUser;
      if (user == null) {
        throw const AuthServiceException('You need to sign in first.');
      }

      await user.updateDisplayName(newDisplayName);
      await user.reload();
    } on FirebaseAuthException catch (e) {
      throw AuthServiceException(_handleAuthError(e));
    } on AuthServiceException {
      rethrow;
    } catch (_) {
      throw const AuthServiceException('Unable to update profile right now.');
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _ensureInternetConnection();

      final User? user = _auth.currentUser;
      if (user == null) {
        throw const AuthServiceException('You need to sign in first.');
      }

      final String? email = user.email;
      if (email == null || email.isEmpty) {
        throw const AuthServiceException('User email is not available.');
      }

      final AuthCredential credential = EmailAuthProvider.credential(
        email: email,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw AuthServiceException(_handleAuthError(e));
    } on AuthServiceException {
      rethrow;
    } catch (_) {
      throw const AuthServiceException('Unable to change password right now.');
    }
  }

  Future<void> _ensureInternetConnection() async {
    final bool hasConnection = await _networkService.hasInternetConnection();
    if (!hasConnection) {
      throw const AuthServiceException(
        'No internet connection. Please check your network and try again.',
      );
    }
  }

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Check if user is logged in
  bool isLoggedIn() {
    return _auth.currentUser != null;
  }

  String getFriendlyErrorMessage(Object error) {
    if (error is AuthServiceException) {
      return error.message;
    }

    return 'Authentication failed. Please try again.';
  }

  // Handle Firebase Auth errors
  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Password is too weak.';
      case 'email-already-in-use':
        return 'Account already exists.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'The user account has been disabled.';
      case 'user-not-found':
        return 'User not found.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'requires-recent-login':
        return 'Please sign in again and retry this action.';
      default:
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }
}
