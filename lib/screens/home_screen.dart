import 'dart:math';

import 'package:flutter/material.dart';

import '../models/apod_model.dart';
import '../models/nasa_image_model.dart';
import 'apod_detail_screen.dart';
import 'favorites_screen.dart';
import 'image_detail_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';
import '../services/nasa_api_service.dart';
import '../services/nasa_image_service.dart';
import '../widgets/app_drawer.dart';
import '../widgets/error_state_widget.dart';
import '../widgets/media_state_widgets.dart';
import '../widgets/section_heading_widget.dart';

class HomeScreen extends StatefulWidget {
  final ValueChanged<bool> onThemeChanged;

  const HomeScreen({required this.onThemeChanged, super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NasaApiService _nasaApiService = NasaApiService();
  final NasaImageService _nasaImageService = NasaImageService();
  final ScrollController _scrollController = ScrollController();

  late Future<ApodModel> _apodFuture;

  final List<String> _topics = <String>[
    'galaxies',
    'mars',
    'nebula',
    'saturn',
    'black hole',
    'earth',
  ];

  final List<NasaImageModel> _images = <NasaImageModel>[];

  String _currentTopic = 'space';
  bool _isInitialGridLoading = true;
  bool _isLoadingMore = false;
  bool _hasGridError = false;
  bool _isOffline = false;
  bool _hasMoreImages = true;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _apodFuture = _nasaApiService.fetchApod();
    _loadInitialImages(topic: _currentTopic);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialImages({required String topic}) async {
    setState(() {
      _currentTopic = topic;
      _images.clear();
      _currentPage = 1;
      _isInitialGridLoading = true;
      _isLoadingMore = false;
      _hasGridError = false;
      _isOffline = false;
      _hasMoreImages = true;
    });

    try {
      final List<NasaImageModel> initialImages = await _nasaImageService
          .fetchImages(topic: _currentTopic, page: _currentPage);

      setState(() {
        _images.addAll(initialImages);
        _currentPage++;
        _isInitialGridLoading = false;
        _isOffline = false;
        _hasMoreImages = initialImages.isNotEmpty;
      });
    } catch (e) {
      final bool isOfflineError = e.toString().toLowerCase().contains(
        'no internet connection',
      );

      setState(() {
        _isInitialGridLoading = false;
        _hasGridError = true;
        _isOffline = isOfflineError;
      });
    }
  }

  Future<void> _loadMoreImages() async {
    if (_isLoadingMore || _isInitialGridLoading || !_hasMoreImages) {
      return;
    }

    setState(() {
      _isLoadingMore = true;
      _hasGridError = false;
      _isOffline = false;
    });

    try {
      final List<NasaImageModel> newImages = await _nasaImageService
          .fetchImages(topic: _currentTopic, page: _currentPage);

      setState(() {
        _images.addAll(newImages);
        _currentPage++;
        _isLoadingMore = false;
        _isOffline = false;
        _hasMoreImages = newImages.isNotEmpty;
      });
    } catch (e) {
      final bool isOfflineError = e.toString().toLowerCase().contains(
        'no internet connection',
      );

      setState(() {
        _isLoadingMore = false;
        _hasGridError = true;
        _isOffline = isOfflineError;
      });
    }
  }

  Future<void> _refreshExplore() async {
    final Random random = Random();
    String nextTopic = _topics[random.nextInt(_topics.length)];

    if (_topics.length > 1) {
      while (nextTopic == _currentTopic) {
        nextTopic = _topics[random.nextInt(_topics.length)];
      }
    }

    setState(() {
      _apodFuture = _nasaApiService.fetchApod();
    });

    await _loadInitialImages(topic: nextTopic);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    final double threshold = _scrollController.position.maxScrollExtent - 250;
    if (_scrollController.position.pixels >= threshold) {
      _loadMoreImages();
    }
  }

  void _openFavoritesFromDrawer() {
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) =>
            FavoritesScreen(onThemeChanged: widget.onThemeChanged),
      ),
    );
  }

  void _openSettingsFromDrawer() {
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) =>
            SettingsScreen(onThemeChanged: widget.onThemeChanged),
      ),
    );
  }

  void _openFavorites() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) =>
            FavoritesScreen(onThemeChanged: widget.onThemeChanged),
      ),
    );
  }

  Widget _buildApodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SectionHeadingWidget(text: 'Astronomy Picture of the Day'),
        const SizedBox(height: 6),
        FutureBuilder<ApodModel>(
          future: _apodFuture,
          builder: (BuildContext context, AsyncSnapshot<ApodModel> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const PaddedLoadingIndicator(verticalPadding: 40);
            }

            if (snapshot.hasError || !snapshot.hasData) {
              if (_isOffline) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'You are offline. APOD cannot be loaded right now.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              return ErrorStateWidget(
                message: 'Failed to load APOD from NASA.',
                primaryButtonText: 'Refresh',
                onPrimaryPressed: _refreshExplore,
              );
            }

            final ApodModel apod = snapshot.data!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  apod.date,
                  style: TextStyle(
                    fontSize: 15,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: _buildApodMedia(apod),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Title',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(apod.title),
                const SizedBox(height: 10),
                const Text(
                  'Description',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  apod.explanation,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (BuildContext context) =>
                              ApodDetailScreen(apod: apod),
                        ),
                      );
                    },
                    child: const Text('View Details'),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildApodMedia(ApodModel apod) {
    if (apod.mediaType == 'video') {
      if (apod.thumbnailUrl != null && apod.thumbnailUrl!.isNotEmpty) {
        return Image.network(
          apod.thumbnailUrl!,
          fit: BoxFit.cover,
          loadingBuilder:
              (
                BuildContext context,
                Widget child,
                ImageChunkEvent? loadingProgress,
              ) {
                if (loadingProgress == null) {
                  return child;
                }

                return const MediaLoadingIndicator();
              },
          errorBuilder: (context, error, stackTrace) {
            return _buildVideoFallback();
          },
        );
      }
      return _buildVideoFallback();
    }

    return Image.network(
      apod.url,
      fit: BoxFit.cover,
      loadingBuilder:
          (
            BuildContext context,
            Widget child,
            ImageChunkEvent? loadingProgress,
          ) {
            if (loadingProgress == null) {
              return child;
            }

            return const MediaLoadingIndicator();
          },
      errorBuilder: (context, error, stackTrace) {
        return const MediaBrokenPlaceholder();
      },
    );
  }

  Widget _buildVideoFallback() {
    return const VideoAvailablePlaceholder(iconSize: 52, spacing: 8);
  }

  Widget _buildImageGridSection() {
    if (_isInitialGridLoading) {
      return const PaddedLoadingIndicator(verticalPadding: 20);
    }

    if (_hasGridError && _images.isEmpty) {
      if (_isOffline) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Center(
            child: Text(
              'You are offline. NASA image grid cannot be loaded right now.',
              textAlign: TextAlign.center,
            ),
          ),
        );
      }

      return ErrorStateWidget(
        message: 'Failed to load NASA image grid.',
        primaryButtonText: 'Refresh',
        onPrimaryPressed: () {
          _loadInitialImages(topic: _currentTopic);
        },
        verticalPadding: 20,
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _images.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      itemBuilder: (BuildContext context, int index) {
        final NasaImageModel imageItem = _images[index];

        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (BuildContext context) =>
                    ImageDetailScreen(item: imageItem),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: ColoredBox(
              color: Colors.black12,
              child: Image.network(
                imageItem.imageUrl,
                fit: BoxFit.cover,
                loadingBuilder:
                    (
                      BuildContext context,
                      Widget child,
                      ImageChunkEvent? loadingProgress,
                    ) {
                      if (loadingProgress == null) {
                        return child;
                      }
                      return const MediaLoadingIndicator();
                    },
                errorBuilder: (context, error, stackTrace) {
                  return const MediaBrokenPlaceholder(iconSize: 24);
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildExploreTab() {
    return RefreshIndicator(
      onRefresh: _refreshExplore,
      child: ListView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          if (_isOffline) ...<Widget>[
            ErrorStateWidget(
              message:
                  'No internet connection. You can still view your saved favorites.',
              primaryButtonText: 'Open Favorites',
              onPrimaryPressed: _openFavorites,
              secondaryButtonText: 'Refresh',
              onSecondaryPressed: _refreshExplore,
              verticalPadding: 0,
            ),
            const SizedBox(height: 16),
          ],
          _buildApodSection(),
          const SizedBox(height: 24),
          const SectionHeadingWidget(text: 'NASA Image Grid'),
          const SizedBox(height: 12),
          _buildImageGridSection(),
          if (_isLoadingMore) const PaddedLoadingIndicator(verticalPadding: 16),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        drawer: AppDrawer(
          selectedSection: DrawerSection.explore,
          onExploreTap: () {
            Navigator.of(context).pop();
          },
          onFavoritesTap: _openFavoritesFromDrawer,
          onSettingsTap: 
          _openSettingsFromDrawer,
        ),
        appBar: AppBar(
          title: const Text('Explore the Cosmos'),
          centerTitle: true,
          actions: <Widget>[
            IconButton(
              onPressed: () {},
              icon: const CircleAvatar(
                radius: 14,
                backgroundImage: AssetImage('assets/profile/male.png'),
              ),
            ),
          ],
          bottom: const TabBar(
            tabs: <Widget>[
              Tab(text: 'Explore'),
              Tab(text: 'Search'),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[_buildExploreTab(), const SearchScreen()],
        ),
      ),
    );
  }
}
