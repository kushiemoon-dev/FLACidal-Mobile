import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Polished track row with selection state, download action, and haptic feedback.
class TrackListTile extends StatelessWidget {
  final int trackNumber;
  final String title;
  final String artist;
  final int duration; // seconds
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback? onDownload;
  final VoidCallback? onLongPress;
  final void Function(String quality)? onQualityDownload;
  final String? coverUrl;

  /// Local file path — when set, shows a play/pause button.
  final String? localFilePath;

  /// Whether this track is currently playing.
  final bool isPlaying;

  /// Callback when play/pause is tapped.
  final VoidCallback? onPlayPause;

  static const qualities = ['HI_RES_MAX', 'HI_RES_LOSSLESS', 'LOSSLESS', 'HIGH'];

  const TrackListTile({
    super.key,
    required this.trackNumber,
    required this.title,
    this.artist = '',
    this.duration = 0,
    this.selected = false,
    this.onTap,
    this.onDownload,
    this.onLongPress,
    this.onQualityDownload,
    this.coverUrl,
    this.localFilePath,
    this.isPlaying = false,
    this.onPlayPause,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Material(
      color: isPlaying
          ? cs.primary.withValues(alpha: 0.12)
          : selected
              ? cs.primary.withValues(alpha: 0.08)
              : Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap?.call();
        },
        onLongPress: onLongPress ?? (onQualityDownload != null
            ? () => _showQualityPicker(context)
            : null),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // Track number badge
              _TrackBadge(
                number: trackNumber,
                selected: selected,
              ),
              const SizedBox(width: 14),
              // Title + artist
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tt.bodyLarge?.copyWith(
                        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    if (artist.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        artist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Duration
              if (duration > 0) ...[
                const SizedBox(width: 8),
                Text(
                  _formatDuration(duration),
                  style: tt.bodySmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.5),
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
              // Play/Pause button (only for local files)
              if (localFilePath != null && onPlayPause != null) ...[
                const SizedBox(width: 4),
                IconButton(
                  icon: Icon(
                    isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_filled,
                    color: isPlaying ? cs.primary : cs.onSurface.withValues(alpha: 0.6),
                    size: 28,
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    onPlayPause!.call();
                  },
                  visualDensity: VisualDensity.compact,
                  splashRadius: 20,
                  tooltip: isPlaying ? 'Pause' : 'Play',
                ),
              ],
              // Download button
              if (onDownload != null) ...[
                const SizedBox(width: 4),
                IconButton(
                  icon: Icon(
                    Icons.download_rounded,
                    color: cs.primary,
                    size: 20,
                  ),
                  onPressed: onDownload,
                  visualDensity: VisualDensity.compact,
                  splashRadius: 20,
                  tooltip: 'Download',
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showQualityPicker(BuildContext context) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Download quality',
                style: Theme.of(ctx).textTheme.titleMedium),
          ),
          ...qualities.map((q) => ListTile(
                leading: const Icon(Icons.high_quality),
                title: Text(q),
                onTap: () {
                  Navigator.pop(ctx);
                  onQualityDownload?.call(q);
                },
              )),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  static String _formatDuration(int seconds) {
    final min = seconds ~/ 60;
    final sec = seconds % 60;
    return '$min:${sec.toString().padLeft(2, '0')}';
  }
}

class _TrackBadge extends StatelessWidget {
  final int number;
  final bool selected;

  const _TrackBadge({required this.number, required this.selected});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      width: 32,
      height: 32,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected ? cs.primary : Colors.transparent,
          border: selected
              ? null
              : Border.all(
                  color: cs.onSurface.withValues(alpha: 0.15),
                  width: 1.5,
                ),
        ),
        child: Center(
          child: Text(
            '$number',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: selected ? cs.onPrimary : cs.onSurface.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ),
    );
  }
}
