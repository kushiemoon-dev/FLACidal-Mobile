import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// AppBar shown while the Library is in selection mode.
class SelectionBar extends StatelessWidget implements PreferredSizeWidget {
  const SelectionBar({
    super.key,
    required this.count,
    required this.onCancel,
    required this.onRename,
    required this.onAnalyze,
  });

  final int count;
  final VoidCallback onCancel;
  final VoidCallback onRename;
  final VoidCallback onAnalyze;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.close),
        tooltip: l.libraryCancelSelection,
        onPressed: onCancel,
      ),
      title: Text(l.librarySelected(count)),
      actions: [
        IconButton(
          icon: const Icon(Icons.drive_file_rename_outline),
          tooltip: l.libraryRename,
          onPressed: onRename,
        ),
        IconButton(
          icon: const Icon(Icons.graphic_eq),
          tooltip: l.libraryAnalyze,
          onPressed: onAnalyze,
        ),
      ],
    );
  }
}
