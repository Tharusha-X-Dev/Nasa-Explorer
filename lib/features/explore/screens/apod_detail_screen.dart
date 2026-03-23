import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:version_1_0/features/explore/models/apod_model.dart';
import 'package:version_1_0/features/favorites/models/favorite_model.dart';
import 'package:version_1_0/features/favorites/services/favorites_service.dart';
import 'package:version_1_0/features/explore/services/nasa_image_service.dart';
import 'package:version_1_0/core/utils/snackbar_utils.dart';
import 'package:version_1_0/core/widgets/media_state_widgets.dart';

class ApodDetailScreen extends StatefulWidget {
  final ApodModel apod;

  const ApodDetailScreen({required this.apod, super.key});

  @override
  State<ApodDetailScreen> createState() => _ApodDetailScreenState();
}

class _ApodDetailScreenState extends State<ApodDetailScreen> {
  final FavoritesService _favoritesService = FavoritesService();
  final NasaImageService _nasaImageService = NasaImageService();
  bool _isFavorite = false;
  bool _isResolvingVideo = false;

  ApodModel get _apod => widget.apod;

  @override
  void initState() {
    super.initState();
    _loadFavoriteState();
  }

  FavoriteModel _toFavoriteModel() {
    return FavoriteModel(
      title: _apod.title.isEmpty ? 'APOD' : _apod.title,
      description: _apod.explanation,
      imageUrl: (_apod.thumbnailUrl != null && _apod.thumbnailUrl!.isNotEmpty)
          ? _apod.thumbnailUrl!
          : _apod.url,
      mediaType: _apod.mediaType.isEmpty ? 'image' : _apod.mediaType,
      mediaUrl: _apod.url,
      date: _apod.date,
      nasaId: _apod.date.isEmpty ? 'apod' : 'apod-${_apod.date}',
      keywords: const <String>[],
    );
  }

  Future<void> _loadFavoriteState() async {
    final bool exists = await _favoritesService.containsFavorite(
      _toFavoriteModel(),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isFavorite = exists;
    });
  }

  Future<void> _toggleFavorite() async {
    final FavoriteModel favoriteItem = _toFavoriteModel();

    if (_isFavorite) {
      await _favoritesService.removeFavorite(favoriteItem);
    } else {
      await _favoritesService.addFavorite(favoriteItem);
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _isFavorite = !_isFavorite;
    });

    SnackbarUtils.showFavoriteStateChanged(context, _isFavorite);
  }

  Future<void> _openVideoUrl(BuildContext context) async {
    try {
      final Uri? uri = Uri.tryParse(_apod.url);

      if (uri == null) {
        if (context.mounted) {
          SnackbarUtils.showVideoOpenError(context);
        }
        return;
      }

      setState(() {
        _isResolvingVideo = true;
      });

      Uri launchUri = uri;
      final String lowerUrl = uri.toString().toLowerCase();

      if (lowerUrl.contains('collection.json')) {
        final String? playableUrl = await _nasaImageService.getPlayableVideoUrl(
          uri.toString(),
        );

        if (playableUrl == null) {
          throw Exception('No playable video url');
        }

        final Uri? resolvedUri = Uri.tryParse(playableUrl);
        if (resolvedUri == null) {
          throw Exception('Invalid resolved video URL');
        }

        launchUri = resolvedUri;
      }

      bool launched = await launchUrl(
        launchUri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        launched = await launchUrl(launchUri, mode: LaunchMode.platformDefault);
      }

      if (!launched && context.mounted) {
        SnackbarUtils.showVideoOpenError(context);
      }
    } catch (_) {
      if (!context.mounted) {
        return;
      }

      SnackbarUtils.showVideoOpenError(context);
    } finally {
      if (mounted) {
        setState(() {
          _isResolvingVideo = false;
        });
      }
    }
  }

  Widget _buildMedia(BuildContext context) {
    if (_apod.mediaType == 'video') {
      return InkWell(
        onTap: () {
          _openVideoUrl(context);
        },
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            if (_apod.thumbnailUrl != null && _apod.thumbnailUrl!.isNotEmpty)
              Image.network(
                _apod.thumbnailUrl!,
                fit: BoxFit.contain,
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
                errorBuilder:
                    (
                      BuildContext context,
                      Object error,
                      StackTrace? stackTrace,
                    ) {
                      return _buildVideoFallback();
                    },
              )
            else
              _buildVideoFallback(),
            if (_isResolvingVideo)
              const MediaLoadingIndicator(size: 28, strokeWidth: 3)
            else
              const Icon(Icons.play_circle_fill, color: Colors.white, size: 64),
          ],
        ),
      );
    }

    final String imageUrl = (_apod.hdUrl != null && _apod.hdUrl!.isNotEmpty)
        ? _apod.hdUrl!
        : _apod.url;

    return Image.network(
      imageUrl,
      fit: BoxFit.contain,
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
      errorBuilder:
          (BuildContext context, Object error, StackTrace? stackTrace) {
            return const MediaBrokenPlaceholder(iconSize: 46);
          },
    );
  }

  Widget _buildVideoFallback() {
    return const VideoAvailablePlaceholder(
      icon: Icons.play_circle_outline,
      iconSize: 64,
      spacing: 0,
      label: '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('APOD Details'),
        actions: <Widget>[
          IconButton(
            icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(10),
            constraints: const BoxConstraints(minHeight: 220, maxHeight: 420),
            child: _buildMedia(context),
          ),
          const SizedBox(height: 12),
          Text(
            _apod.title.isEmpty ? 'Untitled' : _apod.title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Date: ${_apod.date.isEmpty ? 'Unknown' : _apod.date}',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Credit: ${((_apod.copyright ?? '').trim().isNotEmpty) ? _apod.copyright : 'NASA'}',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Description',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            _apod.explanation.isEmpty
                ? 'No description available'
                : _apod.explanation,
            textAlign: TextAlign.left,
            style: const TextStyle(height: 1.5),
          ),
        ],
      ),
    );
  }
}
