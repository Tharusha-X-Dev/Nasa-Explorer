import 'package:flutter/material.dart';

class MediaLoadingIndicator extends StatelessWidget {
  final double? size;
  final double strokeWidth;

  const MediaLoadingIndicator({this.size, this.strokeWidth = 4, super.key});

  @override
  Widget build(BuildContext context) {
    if (size == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(strokeWidth: strokeWidth),
    );
  }
}

class MediaBrokenPlaceholder extends StatelessWidget {
  final double iconSize;

  const MediaBrokenPlaceholder({this.iconSize = 42, super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black12,
      child: Center(child: Icon(Icons.broken_image, size: iconSize)),
    );
  }
}

class VideoAvailablePlaceholder extends StatelessWidget {
  final IconData icon;
  final double iconSize;
  final double spacing;
  final String label;

  const VideoAvailablePlaceholder({
    this.icon = Icons.play_circle_fill,
    this.iconSize = 42,
    this.spacing = 6,
    this.label = 'Video available',
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black12,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: iconSize),
            SizedBox(height: spacing),
            Text(label),
          ],
        ),
      ),
    );
  }
}

class PaddedLoadingIndicator extends StatelessWidget {
  final double verticalPadding;

  const PaddedLoadingIndicator({this.verticalPadding = 24, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}
