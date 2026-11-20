import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/core_provider.dart';
import '../core/core_errors.dart';
import '../l10n/app_localizations.dart';
import '../widgets/error_text.dart';

class CSVImportPage extends ConsumerStatefulWidget {
  const CSVImportPage({super.key});

  @override
  ConsumerState<CSVImportPage> createState() => _CSVImportPageState();
}

class _CSVImportPageState extends ConsumerState<CSVImportPage> {
  String? _csvPath;
  String _quality = 'LOSSLESS';
  bool _loading = false;
  String? _error;
  List<dynamic>? _results;

  static const _qualities = [
    'HI_RES_MAX',
    'HI_RES_LOSSLESS',
    'LOSSLESS',
    'HIGH',
  ];

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'txt'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _csvPath = result.files.single.path;
        _results = null;
        _error = null;
      });
    }
  }

  Future<void> _importCSV() async {
    if (_csvPath == null) return;

    setState(() {
      _loading = true;
      _error = null;
      _results = null;
    });

    try {
      final core = ref.read(flacCoreProvider);
      final result = core.callSync('importCSV', {
        'path': _csvPath!,
        'quality': _quality,
      });
      final tracks = result['result'] as List<dynamic>? ?? [];
      setState(() {
        _results = tracks;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = describeCoreError(AppLocalizations.of(context), e);
        _loading = false;
      });
    }
  }

  Future<void> _queueMatched() async {
    if (_results == null) return;

    final matched = _results!
        .where((r) {
          final m = r as Map<String, dynamic>;
          return m['matched'] == true && m['track'] != null;
        })
        .map(
          (r) => (r as Map<String, dynamic>)['track'] as Map<String, dynamic>,
        )
        .toList();

    if (matched.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).csvNoMatch)),
      );
      return;
    }

    try {
      final core = ref.read(flacCoreProvider);
      core.queueDownloads(matched, core.downloadDir);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).tracksQueued(matched.length)),
            action: SnackBarAction(
              label: AppLocalizations.of(context).viewQueue,
              onPressed: () => context.go('/queue'),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(genericErrorText(context, e))));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final matchedCount =
        _results?.where((r) {
          return (r as Map<String, dynamic>)['matched'] == true;
        }).length ??
        0;
    final totalCount = _results?.length ?? 0;

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).csvTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).csvPick,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(AppLocalizations.of(context).csvColumns),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      FilledButton.tonalIcon(
                        icon: const Icon(Icons.file_open),
                        label: Text(AppLocalizations.of(context).csvChoose),
                        onPressed: _pickFile,
                      ),
                      if (_csvPath != null) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _csvPath!.split('/').last,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    AppLocalizations.of(context).csvQuality,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  DropdownButton<String>(
                    value: _quality,
                    onChanged: (v) {
                      if (v != null) setState(() => _quality = v);
                    },
                    items: _qualities
                        .map((q) => DropdownMenuItem(value: q, child: Text(q)))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            icon: const Icon(Icons.search),
            label: Text(AppLocalizations.of(context).csvMatch),
            onPressed: _csvPath != null && !_loading ? _importCSV : null,
          ),
          const SizedBox(height: 16),
          if (_loading) const Center(child: CircularProgressIndicator()),
          if (_error != null)
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(_error!),
              ),
            ),
          if (_results != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                AppLocalizations.of(context).csvMatched(matchedCount, totalCount),
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            ..._results!.map((r) {
              final row = r as Map<String, dynamic>;
              final matched = row['matched'] == true;
              final trackName = row['trackName'] ?? '';
              final artistName = row['artistName'] ?? '';
              final track = row['track'] as Map<String, dynamic>?;
              final error = row['error'] ?? '';

              return ListTile(
                leading: Icon(
                  matched ? Icons.check_circle : Icons.error_outline,
                  color: matched ? Colors.green : Colors.orange,
                ),
                title: Text(
                  matched
                      ? (track?['title'] ?? trackName).toString()
                      : trackName.toString(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  matched
                      ? '${track?['artist'] ?? artistName} - ${track?['album'] ?? ''}'
                      : error.toString().isNotEmpty
                      ? error.toString()
                      : artistName.toString(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }),
          ],
        ],
      ),
      floatingActionButton: _results != null && matchedCount > 0
          ? FloatingActionButton.extended(
              onPressed: _queueMatched,
              icon: const Icon(Icons.download),
              label: Text(AppLocalizations.of(context).csvQueue(matchedCount)),
            )
          : null,
    );
  }
}
