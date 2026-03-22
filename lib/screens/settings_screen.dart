import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/user_profile_model.dart';
import '../services/auth_service.dart';
import '../services/settings_service.dart';
import '../utils/snackbar_utils.dart';
import '../widgets/app_drawer.dart';
import '../widgets/section_heading_widget.dart';
import 'about_screen.dart';
import 'change_password_screen.dart';
import 'edit_profile_screen.dart';
import 'favorites_screen.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  final ValueChanged<bool>? onThemeChanged;
  final bool useInternalDrawer;
  final VoidCallback? onMenuTap;
  final VoidCallback? onNavigateExplore;
  final VoidCallback? onNavigateFavorites;

  const SettingsScreen({
    this.onThemeChanged,
    this.useInternalDrawer = true,
    this.onMenuTap,
    this.onNavigateExplore,
    this.onNavigateFavorites,
    super.key,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsService _settingsService = SettingsService();
  final AuthService _authService = AuthService();
  bool _isDarkMode = false;
  UserProfileModel? _profile;

  @override
  void initState() {
    super.initState();
    _guardAuthenticatedUser();
    _loadDarkMode();
    _loadUserProfile();
  }

  void _guardAuthenticatedUser() {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (BuildContext context) =>
              LoginScreen(onThemeChanged: widget.onThemeChanged ?? (_) {}),
        ),
        (Route<dynamic> route) => false,
      );
    });
  }

  Future<void> _loadDarkMode() async {
    final bool value = await _settingsService.getDarkMode();

    if (!mounted) {
      return;
    }

    setState(() {
      _isDarkMode = value;
    });
  }

  Future<void> _loadUserProfile() async {
    final UserProfileModel? profile = await _authService
        .getCurrentUserProfile();

    if (!mounted) {
      return;
    }

    setState(() {
      _profile = profile;
    });
  }

  Future<void> _updateDarkMode(bool value) async {
    setState(() {
      _isDarkMode = value;
    });

    await _settingsService.setDarkMode(value);
    widget.onThemeChanged?.call(value);
  }

  void _goToExplore() {
    if (widget.onNavigateExplore != null) {
      widget.onNavigateExplore!.call();
      return;
    }

    Navigator.of(context).popUntil((Route<dynamic> route) => route.isFirst);
  }

  void _openFavorites() {
    if (widget.onNavigateFavorites != null) {
      widget.onNavigateFavorites!.call();
      return;
    }

    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) =>
            FavoritesScreen(onThemeChanged: widget.onThemeChanged),
      ),
    );
  }

  Future<void> _openEditProfile() async {
    final bool? updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (BuildContext context) => const EditProfileScreen(),
      ),
    );

    if (updated == true && mounted) {
      await _loadUserProfile();
    }
  }

  Future<void> _openChangePassword() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const ChangePasswordScreen(),
      ),
    );
  }

  Future<void> _handleLogout() async {
    showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    ).then((bool? shouldLogout) async {
      if (shouldLogout == true) {
        try {
          await _authService.signOut();
          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute<void>(
                builder: (BuildContext context) => LoginScreen(
                  onThemeChanged: widget.onThemeChanged ?? (_) {},
                ),
              ),
              (Route<dynamic> route) => false,
            );
          }
        } catch (e) {
          if (mounted) {
            SnackbarUtils.showError(context, 'Error logging out: $e');
          }
        }
      }
    });
  }

  void _showFeatureComingSoon() {
    SnackbarUtils.showInfo(context, 'Feature coming soon!');
  }

  String _getCurrentUserDisplayName() {
    if (_profile != null) {
      return _profile!.displayName;
    }

    final User? user = FirebaseAuth.instance.currentUser;
    return user?.displayName ?? 'User';
  }

  String _getCurrentUserEmail() {
    if (_profile != null && _profile!.email.isNotEmpty) {
      return _profile!.email;
    }

    final User? user = FirebaseAuth.instance.currentUser;
    return user?.email ?? 'No email';
  }

  String _getProfileIconAsset() {
    final String gender = (_profile?.gender ?? 'male').toLowerCase();
    return gender == 'female'
        ? 'assets/profile/female.png'
        : 'assets/profile/male.png';
  }

  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser == null) {
      return const SizedBox.shrink();
    }

    return Scaffold(
      drawer: widget.useInternalDrawer
          ? AppDrawer(
              selectedSection: DrawerSection.settings,
              profileImageAsset: _getProfileIconAsset(),
              profileName: _getCurrentUserDisplayName(),
              onExploreTap: _goToExplore,
              onFavoritesTap: _openFavorites,
              onSettingsTap: () {
                Navigator.of(context).pop();
              },
            )
          : null,
      appBar: AppBar(
        leading: widget.useInternalDrawer
            ? Builder(
                builder: (BuildContext context) {
                  return IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                  );
                },
              )
            : (widget.onMenuTap != null
                  ? IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: widget.onMenuTap,
                    )
                  : null),
        title: const Text('Settings'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(icon: const Icon(Icons.logout), onPressed: _handleLogout),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Row(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(36),
                child: Image.asset(
                  _getProfileIconAsset(),
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      _getCurrentUserDisplayName(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(_getCurrentUserEmail()),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const SectionHeadingWidget(text: 'Account', fontSize: 18),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.person_outline),
            title: const Text('Edit Profile'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _openEditProfile,
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.lock_outline),
            title: const Text('Change Password'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _openChangePassword,
          ),
          const SizedBox(height: 16),
          const SectionHeadingWidget(text: 'Preferences', fontSize: 18),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Dark Mode'),
            value: _isDarkMode,
            onChanged: _updateDarkMode,
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.language),
            title: const Text('Language'),
            trailing: const Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('English'),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
            onTap: _showFeatureComingSoon,
          ),
          const SizedBox(height: 16),
          const SectionHeadingWidget(text: 'Support', fontSize: 18),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.mail_outline),
            title: const Text('Contact Us'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _showFeatureComingSoon,
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.star_border),
            title: const Text('Rate Us'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _showFeatureComingSoon,
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.info_outline),
            title: const Text('About Us'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => const AboutScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 18),
          const Center(child: Text('Version 1.0')),
        ],
      ),
    );
  }
}
