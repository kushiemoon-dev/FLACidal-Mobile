import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/core_provider.dart';

/// History page — past downloads.
class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  bool _loading = false;
  List<dynamic> _history = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final core = ref.read(flacCoreProvider);
      final result = core.callSync('getHistory');
      setState(() {
        _history = result['result'] as List<dynamic>? ?? [];
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _clearHistory() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text('Delete all download history? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Clear')),
        ],
      ),
    );
    if (confirm == true) {
      ref.read(flacCoreProvider).callSync('clearHistory');
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          if (_history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Clear history',
              onPressed: _clearHistory,
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());

    if (_history.isEmpty) {
      return ListView(
        children: const [
          SizedBox(height: 120),
          Center(
            child: Column(
              children: [
                Icon(Icons.history, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No download history'),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      itemCount: _history.length,
      itemBuilder: (context, i) {
        final entry = _history[i] as Map<String, dynamic>;
        final title = entry['title'] ?? entry['Title'] ?? 'Unknown';
        final artist = entry['artist'] ?? entry['Artist'] ?? '';
        final date = entry['downloadedAt'] ?? entry['date'] ?? '';
        final success = entry['success'] as bool? ?? true;

        return ListTile(
          leading: Icon(
            success ? Icons.check_circle : Icons.error,
            color: success ? Colors.green : Theme.of(context).colorScheme.error,
          ),
          title: Text(title.toString(), maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text('$artist${date.toString().isNotEmpty ? '\n$date' : ''}'),
          isThreeLine: date.toString().isNotEmpty,
        );
      },
    );
  }
}
