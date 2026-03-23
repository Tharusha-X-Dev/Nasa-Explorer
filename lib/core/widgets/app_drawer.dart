import 'package:flutter/material.dart';

enum DrawerSection { explore, favorites, settings }

class AppDrawer extends StatelessWidget {
  final DrawerSection selectedSection;
  final VoidCallback onExploreTap;
  final VoidCallback onFavoritesTap;
  final VoidCallback onSettingsTap;
  final String? profileImageAsset;
  final String? profileName;

  const AppDrawer({
    required this.selectedSection,
    required this.onExploreTap,
    required this.onFavoritesTap,
    required this.onSettingsTap,
    this.profileImageAsset,
    this.profileName,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Row(
              children: <Widget>[
                CircleAvatar(
                  radius: 24,
                  backgroundImage: AssetImage(
                    profileImageAsset ?? 'assets/profile/male.png',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'NASA Explorer',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      if (profileName != null && profileName!.isNotEmpty)
                        Text(
                          profileName!,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
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
