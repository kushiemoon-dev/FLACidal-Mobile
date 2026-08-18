import 'package:flutter/material.dart';

import '../theme/flacidal_theme.dart';

class CircularDownloadIndicator extends StatelessWidget {
  final double progress; // 0.0 - 1.0
  final String status; // downloading, completed, error, queued
  final String? speed;
  final String? eta;
  final double size;

  const CircularDownloadIndicator({
    super.key,
    required this.progress,
    required this.status,
    this.speed,
    this.eta,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: size, height: size, child: _buildContent(context));
  }

  Widget _buildContent(BuildContext context) {
    final color = _statusColor(context);

    if (status == 'completed') {
      return _IconIndicator(
        icon: Icons.check_rounded,
        color: color,
        size: size,
      );
    }
    if (status == 'error') {
      return _IconIndicator(
        icon: Icons.error_outline_rounded,
        color: color,
        size: size,
      );
    }
    if (status == 'queued') {
      return _IconIndicator(
        icon: Icons.hourglass_empty_rounded,
        color: color,
        size: size,
      );
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: progress),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      builder: (context, animatedProgress, _) {
        final pct = (animatedProgress * 100).round();
        return Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                value: animatedProgress,
                strokeWidth: size * 0.08,
                backgroundColor: color.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
            Text(
              '$pct',
              style: TextStyle(
                fontSize: size * 0.26,
                fontWeight: FontWeight.bold,
                color: color,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        );
      },
    );
  }

  Color _statusColor(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return switch (status) {
      'downloading' => cs.primary,
      'completed' => FlacColors.success,
      'error' => cs.error,
      'queued' => FlacColors.textTertiary,
      _ => cs.onSurface,
    };
  }
}

class _IconIndicator extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;

  const _IconIndicator({
    required this.icon,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.12),
      ),
      child: Center(
        child: Icon(icon, size: size * 0.5, color: color),
      ),
    );
  }
}
