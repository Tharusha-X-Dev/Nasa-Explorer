import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_profile_model.dart';

class UserProfileService {
  static const String _usersCollection = 'users';
  static const String _firstNameKey = 'profile_firstName';
  static const String _lastNameKey = 'profile_lastName';
  static const String _genderKey = 'profile_gender';
  static const String _emailKey = 'profile_email';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createUserProfile({
    required String uid,
    required UserProfileModel profile,
  }) async {
    await _firestore.collection(_usersCollection).doc(uid).set(
      <String, dynamic>{
        ...profile.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      },
    );

    await cacheProfile(profile);
  }

  Future<void> updateUserProfile({
    required String uid,
    required UserProfileModel profile,
  }) async {
    await _firestore
        .collection(_usersCollection)
        .doc(uid)
        .set(profile.toMap(), SetOptions(merge: true));

    await cacheProfile(profile);
  }

  Future<UserProfileModel?> fetchUserProfile(String uid) async {
    final DocumentSnapshot<Map<String, dynamic>> snapshot = await _firestore
        .collection(_usersCollection)
        .doc(uid)
        .get();

    if (!snapshot.exists) {
      return null;
    }

    final Map<String, dynamic>? data = snapshot.data();
    if (data == null) {
      return null;
    }

    final UserProfileModel profile = UserProfileModel.fromMap(data);
    await cacheProfile(profile);
    return profile;
  }

  Future<void> cacheProfile(UserProfileModel profile) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_firstNameKey, profile.firstName);
    await prefs.setString(_lastNameKey, profile.lastName);
    await prefs.setString(_genderKey, profile.gender);
    await prefs.setString(_emailKey, profile.email);
  }

  Future<UserProfileModel?> getCachedProfile() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final String firstName = prefs.getString(_firstNameKey) ?? '';
    final String lastName = prefs.getString(_lastNameKey) ?? '';
    final String gender = prefs.getString(_genderKey) ?? 'male';
    final String email = prefs.getString(_emailKey) ?? '';

    if (firstName.isEmpty && lastName.isEmpty && email.isEmpty) {
      return null;
    }

    return UserProfileModel(
      firstName: firstName,
      lastName: lastName,
      gender: gender,
      email: email,
    );
  }

  Future<void> clearCachedProfile() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_firstNameKey);
    await prefs.remove(_lastNameKey);
    await prefs.remove(_genderKey);
    await prefs.remove(_emailKey);
  }
}
