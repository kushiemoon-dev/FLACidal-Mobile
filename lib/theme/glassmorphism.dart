import 'dart:ui';

import 'package:flutter/material.dart';

import 'flacidal_theme.dart';

/// A frosted-glass container with backdrop blur and translucent fill.
class GlassmorphicContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blur;

  const GlassmorphicContainer({
    super.key,
    required this.child,
    this.borderRadius = 12,
    this.blur = 8,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: FlacColors.bgSecondary.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: FlacColors.bgElevated.withValues(alpha: 0.5),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Shows a modal bottom sheet with glassmorphic styling.
Future<T?> showGlassBottomSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) => GlassmorphicContainer(
      borderRadius: 16,
      child: builder(ctx),
    ),
  );
}
