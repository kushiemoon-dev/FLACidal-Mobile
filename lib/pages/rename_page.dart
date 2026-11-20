import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/core_errors.dart';
import '../l10n/app_localizations.dart';
import '../providers/core_provider.dart';
import 'library/rename_plan.dart';

/// Batch rename with a mandatory preview: nothing is renamed until a preview
/// for the CURRENT template exists, and only checked, error free rows go to Core.
class RenamePage extends ConsumerStatefulWidget {
  const RenamePage({super.key, required this.filePaths});

  final List<String> filePaths;

  @override
  ConsumerState<RenamePage> createState() => _RenamePageState();
}

class _RenamePageState extends ConsumerState<RenamePage> {
  final _templateController = TextEditingController();
  List<String> _presets = [];
  RenamePlan? _plan;
  bool _busy = false;

  String get _template => _templateController.text.trim();
  bool get _planValid => _plan != null && _plan!.isFor(_template);

  @override
  void initState() {
    super.initState();
    try {
      final list =
          ref.read(flacCoreProvider).callResult('getRenameTemplates')
              as List<dynamic>? ??
          const [];
      _presets = [
        for (final t in list.whereType<Map>())
          if (t['template'] is String) t['template'] as String,
      ];
    } catch (_) {
      // Free text template still works without presets.
    }
    if (_presets.isNotEmpty) _templateController.text = _presets.first;
  }

  @override
  void dispose() {
    _templateController.dispose();
    super.dispose();
  }

  Future<void> _preview() async {
    final l = AppLocalizations.of(context);
    final template = _template;
    if (template.isEmpty) return;
    setState(() => _busy = true);
    try {
      final result = await ref.read(flacCoreProvider).callResultAsync(
        'previewRename',
        {'files': widget.filePaths, 'template': template},
      );
      if (mounted) {
        setState(() => _plan = RenamePlan.fromCore(template, result));
      }
    } catch (e) {
      _snack(l.renamePreviewFailed(describeCoreError(l, e)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _apply() async {
    final plan = _plan;
    if (plan == null || !plan.isFor(_template) || !plan.canApply) return;
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      final result = await ref.read(flacCoreProvider).callResultAsync(
        'renameFiles',
        {'files': plan.applicablePaths, 'template': plan.template},
      );
      final outcome = RenameOutcome.fromCore(result);
      _snack(l.renameDone(outcome.ok, outcome.failed));
      if (mounted && outcome.ok > 0) context.pop(true);
    } catch (e) {
      _snack(l.renameFailed(describeCoreError(l, e)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final plan = _plan;
    return Scaffold(
      appBar: AppBar(title: Text(l.renameTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.renameTemplate,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (final p in _presets)
                      ChoiceChip(
                        label: Text(p),
                        selected: _template == p,
                        onSelected: (_) =>
                            setState(() => _templateController.text = p),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _templateController,
                  decoration: InputDecoration(
                    labelText: l.renameCustomTemplate,
                    helperText: '{artist} {title} {album} {tracknumber}',
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _busy || _template.isEmpty ? null : _preview,
                  icon: const Icon(Icons.visibility),
                  label: Text(l.renamePreview),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: !_planValid
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        l.renamePreviewFirst,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: plan!.rows.length,
                    itemBuilder: (context, i) {
                      final row = plan.rows[i];
                      return CheckboxListTile(
                        value: row.checked,
                        onChanged: row.hasError
                            ? null
                            : (_) => setState(() => _plan = plan.toggle(i)),
                        title: Text(
                          row.oldName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          row.hasError
                              ? l.renameRowError(row.error)
                              : row.newName,
                          style: row.hasError
                              ? TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                )
                              : null,
                        ),
                      );
                    },
                  ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _busy || !_planValid || !plan!.canApply
                      ? null
                      : _apply,
                  child: Text(
                    l.renameApply(
                      _planValid ? plan!.applicablePaths.length : 0,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
