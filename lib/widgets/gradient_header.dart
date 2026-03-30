import 'package:flutter/material.dart';

import '../theme/flacidal_theme.dart';

/// Reusable SliverAppBar with gradient overlay and optional Hero animation.
///
/// Displays a large cover image as background with a gradient fade,
/// pinned title on scroll, and subtitle in the expanded state.
class GradientHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? coverUrl;
  final Color? dominantColor;
  final String? heroTag;
  final List<Widget>? actions;
  final double expandedHeight;

  const GradientHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.coverUrl,
    this.dominantColor,
    this.heroTag,
    this.actions,
    this.expandedHeight = 300,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: expandedHeight,
      pinned: true,
      actions: actions,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          title,
          style: const TextStyle(fontSize: 16),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            _buildCoverImage(context),
            _buildGradientOverlay(context),
            if (subtitle != null)
              Positioned(
                bottom: 60,
                left: 16,
                right: 16,
                child: Text(
                  subtitle!,
                  style: const TextStyle(color: FlacColors.textSecondary, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverImage(BuildContext context) {
    final url = coverUrl;
    if (url == null || url.isEmpty) {
      return Container(color: Colors.grey[900]);
    }

    final image = Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(color: Colors.grey[900]),
    );

    if (heroTag != null) {
      return Hero(tag: heroTag!, child: image);
    }

    return image;
  }

  Widget _buildGradientOverlay(BuildContext context) {
    final fallback = Theme.of(context).colorScheme.primary;
    final targetColor = dominantColor ?? fallback;

    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(begin: Colors.black87, end: targetColor),
      duration: const Duration(milliseconds: 500),
      builder: (context, color, _) {
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, color ?? Colors.black87],
            ),
          ),
        );
      },
    );
  }
}
