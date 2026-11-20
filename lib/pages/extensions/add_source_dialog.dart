import 'package:flutter/material.dart';

import '../../core/github_repo_url.dart';
import '../../l10n/app_localizations.dart';

/// Returns a normalized GitHub repository URL, or null on cancel. Invalid
/// input is rejected in the field and never reaches Core.
Future<String?> showAddSourceDialog(BuildContext context) => showDialog<String>(
  context: context,
  builder: (_) => const _AddSourceDialog(),
);

class _AddSourceDialog extends StatefulWidget {
  const _AddSourceDialog();

  @override
  State<_AddSourceDialog> createState() => _AddSourceDialogState();
}

class _AddSourceDialogState extends State<_AddSourceDialog> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final url = normalizeGithubRepoUrl(_controller.text);
    if (url == null) {
      setState(() => _error = AppLocalizations.of(context).extRepoUrlInvalid);
      return;
    }
    Navigator.pop(context, url);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l.extAddSourceTitle),
      content: TextField(
        controller: _controller,
        keyboardType: TextInputType.url,
        decoration: InputDecoration(
          labelText: l.extRepoUrlLabel,
          hintText: 'https://github.com/owner/repo',
          errorText: _error,
          border: const OutlineInputBorder(),
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l.cancel),
        ),
        FilledButton(onPressed: _submit, child: Text(l.extAdd)),
      ],
    );
  }
}
