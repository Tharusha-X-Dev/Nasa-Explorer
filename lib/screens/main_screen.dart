import 'package:flutter/material.dart';

import '../models/user_profile_model.dart';
import '../services/auth_service.dart';
import '../widgets/app_drawer.dart';
import 'favorites_screen.dart';
import 'home_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  final ValueChanged<bool> onThemeChanged;

  const MainScreen({required this.onThemeChanged, super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final AuthService _authService = AuthService();
  int _selectedIndex = 0;
  late final List<Widget> _pages;
  UserProfileModel? _profile;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _pages = <Widget>[
      HomeScreen(
        onThemeChanged: widget.onThemeChanged,
        useInternalDrawer: false,
        onMenuTap: _openDrawer,
        onNavigateFavorites: () {
          _selectPage(1);
        },
        onNavigateSettings: () {
          _selectPage(2);
        },
      ),
      FavoritesScreen(
        onThemeChanged: widget.onThemeChanged,
        useInternalDrawer: false,
        onMenuTap: _openDrawer,
        onNavigateExplore: () {
          _selectPage(0);
        },
        onNavigateSettings: () {
          _selectPage(2);
        },
      ),
      SettingsScreen(
        onThemeChanged: widget.onThemeChanged,
        useInternalDrawer: false,
        onMenuTap: _openDrawer,
        onNavigateExplore: () {
          _selectPage(0);
        },
        onNavigateFavorites: () {
          _selectPage(1);
        },
      ),
    ];
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

  String _getDrawerProfileAsset() {
    final String gender = (_profile?.gender ?? 'male').toLowerCase();
    return gender == 'female'
        ? 'assets/profile/female.png'
        : 'assets/profile/male.png';
  }

  DrawerSection get _selectedSection {
    switch (_selectedIndex) {
      case 1:
        return DrawerSection.favorites;
      case 2:
        return DrawerSection.settings;
      case 0:
      default:
        return DrawerSection.explore;
    }
  }

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  void _selectPage(int index) {
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    }

    if (_selectedIndex == index) {
      return;
    }

    setState(() {
      _selectedIndex = index;
    });

    _loadUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: AppDrawer(
        selectedSection: _selectedSection,
        profileImageAsset: _getDrawerProfileAsset(),
        profileName: _profile?.displayName,
        onExploreTap: () {
          _selectPage(0);
        },
        onFavoritesTap: () {
          _selectPage(1);
        },
        onSettingsTap: () {
          _selectPage(2);
        },
      ),
      body: IndexedStack(index: _selectedIndex, children: _pages),
    );
  }
}
