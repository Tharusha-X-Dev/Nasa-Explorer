import 'package:flutter/material.dart';

import 'favorites_screen.dart';
import 'image_detail_screen.dart';
import '../models/nasa_image_model.dart';
import '../services/nasa_image_service.dart';
import '../widgets/error_state_widget.dart';
import '../widgets/media_state_widgets.dart';

class SearchResultsScreen extends StatefulWidget {
  final String query;

  const SearchResultsScreen({required this.query, super.key});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  final NasaImageService _nasaImageService = NasaImageService();
  final ScrollController _scrollController = ScrollController();

  final List<NasaImageModel> _results = <NasaImageModel>[];

  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasError = false;
  bool _isOffline = false;
  bool _hasMore = true;
  int _page = 1;

  @override
  void initState() {
    super.initState();
    _loadInitialResults();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialResults() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _isOffline = false;
      _page = 1;
      _results.clear();
      _hasMore = true;
    });

    try {
      final List<NasaImageModel> results = await _nasaImageService.searchMedia(
        query: widget.query,
        page: _page,
        limit: 12,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _results.addAll(results);
        _page++;
        _isLoading = false;
        _isOffline = false;
        _hasMore = results.isNotEmpty;
      });
    } catch (e) {
      final bool isOfflineError = e.toString().toLowerCase().contains(
        'no internet connection',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _hasError = true;
        _isOffline = isOfflineError;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || _isLoading || !_hasMore) {
      return;
    }

    setState(() {
      _isLoadingMore = true;
      _hasError = false;
      _isOffline = false;
    });

    try {
      final List<NasaImageModel> results = await _nasaImageService.searchMedia(
        query: widget.query,
        page: _page,
        limit: 12,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _results.addAll(results);
        _page++;
        _isLoadingMore = false;
        _isOffline = false;
        _hasMore = results.isNotEmpty;
      });
    } catch (e) {
      final bool isOfflineError = e.toString().toLowerCase().contains(
        'no internet connection',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isLoadingMore = false;
        _hasError = true;
        _isOffline = isOfflineError;
      });
    }
  }

  void _openFavorites() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const FavoritesScreen(),
      ),
    );
  }

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    final double threshold = _scrollController.position.maxScrollExtent - 250;
    if (_scrollController.position.pixels >= threshold) {
      _loadMore();
    }
  }

  Widget _buildMediaTile(NasaImageModel item) {
    final bool isVideo = item.mediaType == 'video';
    final String imageToShow = isVideo
        ? (item.thumbnailUrl?.isNotEmpty == true
              ? item.thumbnailUrl!
              : item.imageUrl)
        : item.imageUrl;

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (BuildContext context) => ImageDetailScreen(item: item),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            if (imageToShow.isNotEmpty)
              Image.network(
                imageToShow,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }
                  return const MediaLoadingIndicator();
                },
                errorBuilder: (context, error, stackTrace) {
                  return _buildVideoPlaceholder(isVideo: isVideo);
                },
              )
            else
              _buildVideoPlaceholder(isVideo: isVideo),
            if (isVideo)
              const Align(
                alignment: Alignment.center,
                child: Icon(
                  Icons.play_circle_fill,
                  color: Colors.white,
                  size: 44,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlaceholder({required bool isVideo}) {
    if (!isVideo) {
      return const MediaBrokenPlaceholder(iconSize: 24);
    }

    return const VideoAvailablePlaceholder();
  }

  Widget _buildResultsGrid() {
    if (_isLoading) {
      return const PaddedLoadingIndicator(verticalPadding: 40);
    }

    if (_results.isEmpty && (_isOffline || _hasError)) {
      if (_isOffline) {
        return ErrorStateWidget(
          message:
              'You are offline. Search results cannot be loaded right now.',
          subtitle: 'You can still open your saved favorites.',
          primaryButtonText: 'Open Favorites',
          onPrimaryPressed: _openFavorites,
          secondaryButtonText: 'Refresh',
          onSecondaryPressed: _loadInitialResults,
          verticalPadding: 40,
        );
      }

      return ErrorStateWidget(
        message: 'Failed to load search results from NASA.',
        subtitle: 'Pull down to refresh or try again.',
        primaryButtonText: 'Refresh',
        onPrimaryPressed: _loadInitialResults,
        verticalPadding: 40,
      );
    }

    if (_results.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: Text('No results found')),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _results.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      itemBuilder: (BuildContext context, int index) {
        return _buildMediaTile(_results[index]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text('Results for ${widget.query}'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadInitialResults,
        child: ListView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            _buildResultsGrid(),
            if (_isLoadingMore)
              const PaddedLoadingIndicator(verticalPadding: 16),
          ],
        ),
      ),
    );
  }
}
