import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/favorite_model.dart';
import '../models/nasa_image_model.dart';
import '../services/favorites_service.dart';
import '../services/nasa_image_service.dart';
import '../widgets/media_state_widgets.dart';

class ImageDetailScreen extends StatefulWidget {
  final NasaImageModel item;

  const ImageDetailScreen({required this.item, super.key});

  @override
  State<ImageDetailScreen> createState() => _ImageDetailScreenState();
}

class _ImageDetailScreenState extends State<ImageDetailScreen> {
  final FavoritesService _favoritesService = FavoritesService();
  final NasaImageService _nasaImageService = NasaImageService();
  bool _isFavorite = false;
  bool _isResolvingVideo = false;

  NasaImageModel get _item => widget.item;

  @override
  void initState() {
    super.initState();
    _loadFavoriteState();
  }

  FavoriteModel _toFavoriteModel() {
    return FavoriteModel(
      title: _item.title,
      description: _item.description,
      imageUrl: (_item.thumbnailUrl != null && _item.thumbnailUrl!.isNotEmpty)
          ? _item.thumbnailUrl!
          : _item.imageUrl,
      mediaType: _item.mediaType.isEmpty ? 'image' : _item.mediaType,
      mediaUrl: _item.mediaUrl,
      date: _item.dateCreated,
      nasaId: _item.nasaId.isEmpty ? null : _item.nasaId,
      keywords: _item.keywords,
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isFavorite ? 'Added to favorites' : 'Removed from favorites',
        ),
      ),
    );
  }

  Future<void> _openVideoUrl(BuildContext context) async {
    final String rawUrl = (_item.mediaUrl != null && _item.mediaUrl!.isNotEmpty)
        ? _item.mediaUrl!
        : _item.imageUrl;

    try {
      setState(() {
        _isResolvingVideo = true;
      });

      final String? playableUrl = await _nasaImageService.getPlayableVideoUrl(
        rawUrl,
      );

      if (playableUrl == null) {
        throw Exception('No playable video url');
      }

      final Uri? videoUri = Uri.tryParse(playableUrl);
      if (videoUri == null) {
        throw Exception('Invalid resolved video URL');
      }

      bool launched = await launchUrl(
        videoUri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        launched = await launchUrl(videoUri, mode: LaunchMode.platformDefault);
      }

      if (!launched && context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Unable to open video')));
      }
    } catch (_) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Unable to open video')));
    } finally {
      if (mounted) {
        setState(() {
          _isResolvingVideo = false;
        });
      }
    }
  }

  Widget _buildMedia(BuildContext context) {
    final bool isVideo = _item.mediaType == 'video';
    final String imageToShow = isVideo
        ? ((_item.thumbnailUrl != null && _item.thumbnailUrl!.isNotEmpty)
              ? _item.thumbnailUrl!
              : _item.imageUrl)
        : (_item.imageUrl.isNotEmpty
              ? _item.imageUrl
              : ((_item.thumbnailUrl != null && _item.thumbnailUrl!.isNotEmpty)
                    ? _item.thumbnailUrl!
                    : _item.imageUrl));

    final Widget mediaWidget = _buildMediaImage(imageToShow);

    if (!isVideo) {
      return mediaWidget;
    }

    return InkWell(
      onTap: () {
        _openVideoUrl(context);
      },
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          mediaWidget,
          if (_isResolvingVideo)
            const MediaLoadingIndicator(size: 28, strokeWidth: 3)
          else
            const Icon(Icons.play_circle_fill, color: Colors.white, size: 64),
        ],
      ),
    );
  }

  Widget _buildMediaImage(String pathOrUrl) {
    final bool isLocalPath = pathOrUrl.startsWith('/');

    if (isLocalPath) {
      return Image.file(
        File(pathOrUrl),
        fit: BoxFit.contain,
        errorBuilder:
            (BuildContext context, Object error, StackTrace? stackTrace) {
              final String? fallbackUrl =
                  (_item.thumbnailUrl != null && _item.thumbnailUrl!.isNotEmpty)
                  ? _item.thumbnailUrl
                  : null;

              if (fallbackUrl != null && fallbackUrl != pathOrUrl) {
                return _buildNetworkMediaImage(fallbackUrl);
              }

              return const MediaBrokenPlaceholder(iconSize: 46);
            },
      );
    }

    return _buildNetworkMediaImage(pathOrUrl);
  }

  Widget _buildNetworkMediaImage(String url) {
    return Image.network(
      url,
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

  Widget _buildKeywords() {
    if (_item.keywords.isEmpty) {
      return const Text('No keywords available');
    }

    return Wrap(
      spacing: 10,
      runSpacing: 6,
      children: _item.keywords
          .map(
            (String keyword) =>
                Text(keyword, style: const TextStyle(color: Colors.blue)),
          )
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String detailsTitle = _item.mediaType == 'video'
        ? 'Video Details'
        : 'Image Details';

    return Scaffold(
      appBar: AppBar(
        title: Text(detailsTitle),
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
            _item.title.isEmpty ? 'Untitled' : _item.title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Date: ${_item.dateCreated.isEmpty ? 'Unknown' : _item.dateCreated}',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'NASA ID: ${_item.nasaId.isEmpty ? 'Unknown' : _item.nasaId}',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Center: ${_item.center.isEmpty ? 'Unknown' : _item.center}',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Photographer: ${_item.photographer.isEmpty ? 'NASA' : _item.photographer}',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          const Text('Keywords', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          _buildKeywords(),
          const SizedBox(height: 14),
          const Text(
            'Description',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            _item.description.isEmpty
                ? 'No description available'
                : _item.description,
            textAlign: TextAlign.left,
            style: const TextStyle(height: 1.5),
            maxLines: null,
          ),
        ],
      ),
    );
  }
}
