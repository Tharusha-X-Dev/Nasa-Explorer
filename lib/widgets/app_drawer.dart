import 'package:flutter/material.dart';

enum DrawerSection { explore, favorites, settings }

class AppDrawer extends StatelessWidget {
  final DrawerSection selectedSection;
  final VoidCallback onExploreTap;
  final VoidCallback onFavoritesTap;
  final VoidCallback onSettingsTap;

  const AppDrawer({
    required this.selectedSection,
    required this.onExploreTap,
    required this.onFavoritesTap,
    required this.onSettingsTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                'NASA Explorer',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.explore),
            title: const Text('Explore'),
            selected: selectedSection == DrawerSection.explore,
            onTap: onExploreTap,
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('Favorites'),
            selected: selectedSection == DrawerSection.favorites,
            onTap: onFavoritesTap,
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            selected: selectedSection == DrawerSection.settings,
            onTap: onSettingsTap,
          ),
        ],
      ),
    );
  }
}
