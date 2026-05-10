import 'dart:io';

import 'package:flutter/material.dart';

import 'package:version_1_0/features/favorites/models/favorite_model.dart';
import 'package:version_1_0/features/explore/models/nasa_image_model.dart';
import 'package:version_1_0/features/explore/screens/image_detail_screen.dart';
import 'package:version_1_0/features/settings/screens/settings_screen.dart';
import 'package:version_1_0/features/favorites/services/favorites_service.dart';
import 'package:version_1_0/core/widgets/app_drawer.dart';
import 'package:version_1_0/core/widgets/media_state_widgets.dart';

class FavoritesScreen extends StatefulWidget {
  final ValueChanged<bool>? onThemeChanged;
  final bool useInternalDrawer;
  final VoidCallback? onMenuTap;
  final VoidCallback? onNavigateExplore;
  final VoidCallback? onNavigateSettings;

  const FavoritesScreen({
    this.onThemeChanged,
    this.useInternalDrawer = true,
    this.onMenuTap,
    this.onNavigateExplore,
    this.onNavigateSettings,
    super.key,
  });

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FavoritesService _favoritesService = FavoritesService();

  bool _isLoading = true;
  bool _hasError = false;
  final List<FavoriteModel> _favorites = <FavoriteModel>[];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    // Listen for external changes to the favorites list (add/remove)
    _favoritesService.addListener(_loadFavorites);
  }

  @override
  void dispose() {
    _favoritesService.removeListener(_loadFavorites);
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final List<FavoriteModel> items = await _favoritesService.getFavorites();

      if (!mounted) {
        return;
      }

      setState(() {
        _favorites
          ..clear()
          ..addAll(items);
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  void _goToExplore() {
    if (widget.onNavigateExplore != null) {
      widget.onNavigateExplore!.call();
      return;
    }

    Navigator.of(context).popUntil((Route<dynamic> route) => route.isFirst);
  }

  void _openSettings() {
    if (widget.onNavigateSettings != null) {
      widget.onNavigateSettings!.call();
      return;
    }

    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) =>
            SettingsScreen(onThemeChanged: widget.onThemeChanged),
      ),
    );
  }

  Future<void> _openFavoriteDetails(FavoriteModel item) async {
    final String detailImagePath =
        (item.localImagePath != null && item.localImagePath!.isNotEmpty)
        ? item.localImagePath!
        : item.imageUrl;

    final NasaImageModel detailItem = NasaImageModel(
      title: item.title,
      description: item.description,
      dateCreated: item.date ?? '',
      nasaId: item.nasaId ?? '',
      center: '',
      photographer: '',
      keywords: item.keywords,
      mediaType: item.mediaType,
      imageUrl: detailImagePath,
      thumbnailUrl: detailImagePath,
      mediaUrl: item.mediaUrl,
    );

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => ImageDetailScreen(item: detailItem),
      ),
    );

    if (mounted) {
      _loadFavorites();
    }
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const MediaLoadingIndicator();
    }

    if (_hasError) {
      return const Center(child: Text('Unable to load favorites'));
    }

    if (_favorites.isEmpty) {
      return const Center(child: Text('No favorites saved yet'));
    }

    return RefreshIndicator(
      onRefresh: _loadFavorites,
      child: TabBarView(children: <Widget>[_buildTilesTab(), _buildListTab()]),
    );
  }

  Widget _buildImageWithFallback({
    required FavoriteModel item,
    required double width,
    required double height,
    required BoxFit fit,
  }) {
    // Try to use local image if available
    if (item.localImagePath != null && item.localImagePath!.isNotEmpty) {
      final File localFile = File(item.localImagePath!);
      return FutureBuilder<bool>(
        future: localFile.exists(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SizedBox(
              width: width,
              height: height,
              child: const MediaLoadingIndicator(),
            );
          }

          if (snapshot.hasData && snapshot.data == true) {
            // Local file exists, use it
            return Image.file(
              localFile,
              width: width,
              height: height,
              fit: fit,
              errorBuilder:
                  (BuildContext context, Object error, StackTrace? stackTrace) {
                    // Local file exists but can't be read, fall back to network
                    return _buildNetworkImage(item, width, height, fit);
                  },
            );
          }
          // Local file doesn't exist or check failed, use network
          return _buildNetworkImage(item, width, height, fit);
        },
      );
    }

    // No local image, use network
    return _buildNetworkImage(item, width, height, fit);
  }

  Widget _buildNetworkImage(
    FavoriteModel item,
    double width,
    double height,
    BoxFit fit,
  ) {
    return Image.network(
      item.imageUrl,
      fit: fit,
      width: width,
      height: height,
      loadingBuilder:
          (
            BuildContext context,
            Widget child,
            ImageChunkEvent? loadingProgress,
          ) {
            if (loadingProgress == null) {
              return child;
            }
            return SizedBox(
              width: width,
              height: height,
              child: const MediaLoadingIndicator(),
            );
          },
      errorBuilder:
          (BuildContext context, Object error, StackTrace? stackTrace) {
            return SizedBox(
              width: width,
              height: height,
              child: const MediaBrokenPlaceholder(iconSize: 24),
            );
          },
    );
  }

  Widget _buildTilesTab() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _favorites.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.74,
      ),
      itemBuilder: (BuildContext context, int index) {
        final FavoriteModel item = _favorites[index];

        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            _openFavoriteDetails(item);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: ColoredBox(
                    color: Colors.black12,
                    child: _buildImageWithFallback(
                      item: item,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                item.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildListTab() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _favorites.length,
      separatorBuilder: (BuildContext context, int index) {
        return const SizedBox(height: 10);
      },
      itemBuilder: (BuildContext context, int index) {
        final FavoriteModel item = _favorites[index];

        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            _openFavoriteDetails(item);
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            child: Row(
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _buildImageWithFallback(
                    item: item,
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
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
          title: const Text('Favorites'),
          centerTitle: true,
          bottom: const TabBar(
            tabs: <Widget>[
              Tab(text: 'Tiles'),
              Tab(text: 'List'),
            ],
          ),
        ),
        drawer: widget.useInternalDrawer
            ? AppDrawer(
                selectedSection: DrawerSection.favorites,
                onExploreTap: _goToExplore,
                onFavoritesTap: () {
                  Navigator.of(context).pop();
                },
                onSettingsTap: _openSettings,
              )
            : null,
        body: _buildBody(),
      ),
    );
  }
}
