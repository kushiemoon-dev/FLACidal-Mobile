import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Asks before an extension is switched on, listing what it can reach.
/// Returns true only when the user taps Enable; never enables implicitly.
Future<bool> showEnablePrompt(
  BuildContext context, {
  required String name,
  required List<String> hosts,
  required List<String> permissions,
}) async {
  final l = AppLocalizations.of(context);
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l.extEnableTitle(name)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.extEnableHosts),
            const SizedBox(height: 4),
            if (hosts.isEmpty)
              Text(l.extEnableNoHosts)
            else
              for (final h in hosts) Text('• $h'),
            const SizedBox(height: 12),
            Text(l.extEnablePermissions),
            const SizedBox(height: 4),
            if (permissions.isEmpty)
              Text(l.extEnableNoPermissions)
            else
              for (final p in permissions) Text('• $p'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(l.later),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(l.enable),
        ),
      ],
    ),
  );
  return result == true;
}
