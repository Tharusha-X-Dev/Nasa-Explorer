import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:version_1_0/features/auth/models/user_profile_model.dart';
import 'package:version_1_0/features/auth/services/auth_service.dart';
import 'package:version_1_0/core/utils/snackbar_utils.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  bool _isSaving = false;
  String _selectedGender = 'male';

  @override
  void initState() {
    super.initState();
    _loadCurrentDisplayName();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentDisplayName() async {
    final UserProfileModel? profile = await _authService
        .getCurrentUserProfile();

    if (!mounted) {
      return;
    }

    if (profile != null) {
      setState(() {
        _firstNameController.text = profile.firstName;
        _lastNameController.text = profile.lastName;
        _selectedGender = profile.gender.isEmpty ? 'male' : profile.gender;
      });
      return;
    }

    final User? currentUser = FirebaseAuth.instance.currentUser;
    final List<String> nameParts = (currentUser?.displayName ?? '')
        .trim()
        .split(RegExp(r'\s+'));

    setState(() {
      _firstNameController.text = nameParts.isNotEmpty ? nameParts.first : '';
      _lastNameController.text = nameParts.length > 1
          ? nameParts.sublist(1).join(' ')
          : '';
      _selectedGender = 'male';
    });
  }

  Future<void> _saveProfile() async {
    final String firstName = _firstNameController.text.trim();
    final String lastName = _lastNameController.text.trim();

    if (firstName.isEmpty || lastName.isEmpty) {
      SnackbarUtils.showError(
        context,
        'First name and last name cannot be empty.',
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _authService.updateUserProfile(
        firstName: firstName,
        lastName: lastName,
        gender: _selectedGender,
      );

      if (!mounted) {
        return;
      }

      SnackbarUtils.showInfo(context, 'Profile updated successfully.');

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) {
        return;
      }

      SnackbarUtils.showError(context, _authService.getFriendlyErrorMessage(e));
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          const SizedBox(height: 12),
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: Image.asset(
                _selectedGender == 'female'
                    ? 'assets/profile/female.png'
                    : 'assets/profile/male.png',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _firstNameController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'First Name',
              hintText: 'Enter your first name',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _lastNameController,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: 'Last Name',
              hintText: 'Enter your last name',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            initialValue: _selectedGender,
            decoration: const InputDecoration(
              labelText: 'Gender',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.wc),
            ),
            items: const <DropdownMenuItem<String>>[
              DropdownMenuItem<String>(value: 'male', child: Text('Male')),
              DropdownMenuItem<String>(value: 'female', child: Text('Female')),
            ],
            onChanged: (String? value) {
              if (value == null) {
                return;
              }

              setState(() {
                _selectedGender = value;
              });
            },
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: _isSaving ? null : _saveProfile,
              child: _isSaving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }
}
