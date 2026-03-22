import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_profile_model.dart';
import 'network_service.dart';
import 'user_profile_service.dart';

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
  final UserProfileService _profileService = UserProfileService();

  // Sign up with email and password
  Future<User?> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String gender,
  }) async {
    try {
      await _ensureInternetConnection();

      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      final User? user = userCredential.user;
      if (user == null) {
        throw const AuthServiceException('Unable to create account.');
      }

      final UserProfileModel profile = UserProfileModel(
        firstName: firstName,
        lastName: lastName,
        gender: gender,
        email: email,
      );

      // Update user profile with display name
      await user.updateDisplayName(profile.displayName);
      await _profileService.createUserProfile(uid: user.uid, profile: profile);
      await user.reload();

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

      final User? user = userCredential.user;
      if (user != null) {
        await _syncUserProfile(user);
      }

      return user;
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
      await _profileService.clearCachedProfile();
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

      final UserProfileModel? cachedProfile = await _profileService
          .getCachedProfile();

      final List<String> nameParts = newDisplayName.trim().split(
        RegExp(r'\s+'),
      );
      final String firstName = nameParts.isNotEmpty ? nameParts.first : '';
      final String lastName = nameParts.length > 1
          ? nameParts.sublist(1).join(' ')
          : (cachedProfile?.lastName ?? '');

      final UserProfileModel profile = UserProfileModel(
        firstName: firstName,
        lastName: lastName,
        gender: cachedProfile?.gender ?? 'male',
        email: user.email ?? cachedProfile?.email ?? '',
      );

      await _profileService.updateUserProfile(uid: user.uid, profile: profile);
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

  Future<void> updateUserProfile({
    required String firstName,
    required String lastName,
    required String gender,
  }) async {
    try {
      await _ensureInternetConnection();

      final User? user = _auth.currentUser;
      if (user == null) {
        throw const AuthServiceException('You need to sign in first.');
      }

      final UserProfileModel profile = UserProfileModel(
        firstName: firstName,
        lastName: lastName,
        gender: gender,
        email: user.email ?? '',
      );

      await user.updateDisplayName(profile.displayName);
      await _profileService.updateUserProfile(uid: user.uid, profile: profile);
      await user.reload();
    } on FirebaseAuthException catch (e) {
      throw AuthServiceException(_handleAuthError(e));
    } on AuthServiceException {
      rethrow;
    } catch (_) {
      throw const AuthServiceException('Unable to update profile right now.');
    }
  }

  Future<UserProfileModel?> getCurrentUserProfile() async {
    final User? user = _auth.currentUser;
    if (user == null) {
      return await _profileService.getCachedProfile();
    }

    final UserProfileModel? cachedProfile = await _profileService
        .getCachedProfile();

    final bool hasConnection = await _networkService.hasInternetConnection();
    if (!hasConnection) {
      return cachedProfile;
    }

    try {
      final UserProfileModel? remoteProfile = await _profileService
          .fetchUserProfile(user.uid);

      if (remoteProfile != null) {
        return remoteProfile;
      }
    } catch (_) {
      // Fall back to cache when Firestore cannot be reached.
    }

    return cachedProfile;
  }

  Future<void> _syncUserProfile(User user) async {
    final UserProfileModel? remoteProfile = await _profileService
        .fetchUserProfile(user.uid);

    if (remoteProfile != null) {
      await _profileService.cacheProfile(remoteProfile);
      return;
    }

    final List<String> nameParts = (user.displayName ?? '').trim().split(
      RegExp(r'\s+'),
    );

    final UserProfileModel fallbackProfile = UserProfileModel(
      firstName: nameParts.isNotEmpty ? nameParts.first : '',
      lastName: nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '',
      gender: 'male',
      email: user.email ?? '',
    );

    await _profileService.createUserProfile(
      uid: user.uid,
      profile: fallbackProfile,
    );
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
