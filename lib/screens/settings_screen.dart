import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/settings_service.dart';
import '../widgets/app_drawer.dart';
import '../widgets/section_heading_widget.dart';
import 'about_screen.dart';
import 'change_password_screen.dart';
import 'edit_profile_screen.dart';
import 'favorites_screen.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  final ValueChanged<bool>? onThemeChanged;

  const SettingsScreen({this.onThemeChanged, super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsService _settingsService = SettingsService();
  final AuthService _authService = AuthService();
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _guardAuthenticatedUser();
    _loadDarkMode();
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

  Future<void> _updateDarkMode(bool value) async {
    setState(() {
      _isDarkMode = value;
    });

    await _settingsService.setDarkMode(value);
    widget.onThemeChanged?.call(value);
  }

  void _goToExplore() {
    Navigator.of(context).popUntil((Route<dynamic> route) => route.isFirst);
  }

  void _openFavorites() {
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
      setState(() {});
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
    // Show confirmation dialog
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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error logging out: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    });
  }

  String _getCurrentUserDisplayName() {
    final User? user = FirebaseAuth.instance.currentUser;
    return user?.displayName ?? 'User';
  }

  String _getCurrentUserEmail() {
    final User? user = FirebaseAuth.instance.currentUser;
    return user?.email ?? 'No email';
  }

  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser == null) {
      return const SizedBox.shrink();
    }

    return Scaffold(
      drawer: AppDrawer(
        selectedSection: DrawerSection.settings,
        onExploreTap: _goToExplore,
        onFavoritesTap: _openFavorites,
        onSettingsTap: () {
          Navigator.of(context).pop();
        },
      ),
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
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
                  'assets/profile/male.png',
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
            onTap: () {},
          ),
          const SizedBox(height: 16),
          const SectionHeadingWidget(text: 'Support', fontSize: 18),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.mail_outline),
            title: const Text('Contact Us'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.star_border),
            title: const Text('Rate Us'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
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
