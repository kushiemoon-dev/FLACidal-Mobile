import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Sign-in fields of an extension. Fields start empty: Core never returns
/// secrets, and an empty value keeps the stored one (`authSet` only says
/// which fields already hold a value).
///
/// Returns the non-empty entries typed by the user, or null on cancel.
Future<Map<String, String>?> showAuthDialog(
  BuildContext context, {
  required String title,
  required List<Map<String, dynamic>> fields,
  required Map<String, dynamic> authSet,
}) {
  return showDialog<Map<String, String>>(
    context: context,
    builder: (ctx) =>
        _AuthDialog(title: title, fields: fields, authSet: authSet),
  );
}

class _AuthDialog extends StatefulWidget {
  const _AuthDialog({
    required this.title,
    required this.fields,
    required this.authSet,
  });

  final String title;
  final List<Map<String, dynamic>> fields;
  final Map<String, dynamic> authSet;

  @override
  State<_AuthDialog> createState() => _AuthDialogState();
}

class _AuthDialogState extends State<_AuthDialog> {
  late final Map<String, TextEditingController> _controllers = {
    for (final f in widget.fields)
      (f['key'] as String? ?? ''): TextEditingController(),
  };

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _submit() {
    final data = <String, String>{
      for (final e in _controllers.entries)
        if (e.value.text.isNotEmpty) e.key: e.value.text,
    };
    Navigator.pop(context, data);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final f in widget.fields)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: TextField(
                  controller: _controllers[f['key'] as String? ?? ''],
                  obscureText: f['type'] == 'password',
                  decoration: InputDecoration(
                    labelText: f['label'] as String? ?? f['key'] as String?,
                    hintText: widget.authSet[f['key']] == true
                        ? l.configured
                        : null,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l.cancel),
        ),
        FilledButton(onPressed: _submit, child: Text(l.save)),
      ],
    );
  }
}
