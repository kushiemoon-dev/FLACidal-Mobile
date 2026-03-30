import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../theme/flacidal_theme.dart';

/// Rich cover art widget with cached networking, Hero animation,
/// rounded corners, optional play overlay, and elevation.
class CoverArtTile extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final String? heroTag;
  final VoidCallback? onTap;
  final double borderRadius;
  final bool showPlayOverlay;
  final double elevation;

  const CoverArtTile({
    super.key,
    this.imageUrl,
    this.size = 120,
    this.heroTag,
    this.onTap,
    this.borderRadius = 12,
    this.showPlayOverlay = false,
    this.elevation = 0,
  });

  @override
  Widget build(BuildContext context) {
    Widget tile = _buildTile(context);

    if (heroTag != null) {
      tile = Hero(tag: heroTag!, child: tile);
    }

    if (onTap != null) {
      tile = GestureDetector(onTap: onTap, child: tile);
    }

    return tile;
  }

  Widget _buildTile(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);

    return Material(
      elevation: elevation,
      borderRadius: radius,
      shadowColor: Colors.black54,
      color: Colors.transparent,
      child: ClipRRect(
        borderRadius: radius,
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildImage(context),
              if (showPlayOverlay) _buildPlayOverlay(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    final url = imageUrl;
    if (url == null || url.isEmpty) {
      return _buildPlaceholder(context);
    }

    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      fadeInDuration: const Duration(milliseconds: 200),
      placeholder: (_, __) => _buildPlaceholder(context),
      errorWidget: (_, __, ___) => _buildPlaceholder(context),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      color: FlacColors.bgSecondary,
      child: Icon(
        Icons.album,
        size: size * 0.4,
        color: Colors.grey[600],
      ),
    );
  }

  Widget _buildPlayOverlay(BuildContext context) {
    final iconSize = size * 0.3;
    final circleSize = size * 0.4;

    return Center(
      child: Container(
        width: circleSize,
        height: circleSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withValues(alpha: 0.55),
        ),
        child: Icon(
          Icons.play_arrow_rounded,
          color: Colors.white,
          size: iconSize,
        ),
      ),
    );
  }
}
