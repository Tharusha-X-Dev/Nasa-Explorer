import 'package:flutter/material.dart';

import '../services/settings_service.dart';
import '../widgets/app_drawer.dart';
import '../widgets/section_heading_widget.dart';
import 'about_screen.dart';
import 'favorites_screen.dart';

class SettingsScreen extends StatefulWidget {
  final ValueChanged<bool>? onThemeChanged;

  const SettingsScreen({this.onThemeChanged, super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsService _settingsService = SettingsService();
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadDarkMode();
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

  @override
  Widget build(BuildContext context) {
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
          IconButton(icon: const Icon(Icons.logout), onPressed: () {}),
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
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'John Doe',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text('johndoe123@gmail.com'),
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
            onTap: () {},
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.lock_outline),
            title: const Text('Change Password'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
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
