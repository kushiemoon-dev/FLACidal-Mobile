import 'package:flutter/material.dart';

/// Reusable section header with primary-colored title and optional trailing widget.
/// Extracted from `SettingsPage._SectionHeader`.
class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const SectionHeader({
    super.key,
    required this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: trailing != null
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(child: Text(title, style: style)),
                trailing!,
              ],
            )
          : Text(title, style: style),
    );
  }
}
