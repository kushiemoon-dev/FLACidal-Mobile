import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/core_provider.dart';

/// Library page — browse downloaded FLAC files.
class LibraryPage extends ConsumerStatefulWidget {
  const LibraryPage({super.key});

  @override
  ConsumerState<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends ConsumerState<LibraryPage> {
  bool _loading = false;
  List<dynamic> _files = [];
  bool _gridView = false;

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    setState(() => _loading = true);
    try {
      final core = ref.read(flacCoreProvider);
      final result = core.callSync('listFiles');
      setState(() {
        _files = result['result'] as List<dynamic>? ?? [];
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Library'),
        actions: [
          IconButton(
            icon: Icon(_gridView ? Icons.list : Icons.grid_view),
            onPressed: () => setState(() => _gridView = !_gridView),
            tooltip: _gridView ? 'List view' : 'Grid view',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadFiles,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_files.isEmpty) {
      return ListView(
        children: const [
          SizedBox(height: 120),
          Center(
            child: Column(
              children: [
                Icon(Icons.library_music, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No downloaded files yet'),
                SizedBox(height: 8),
                Text('Download some tracks from the Home page',
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      itemCount: _files.length,
      itemBuilder: (context, index) {
        final file = _files[index] as Map<String, dynamic>;
        final name = file['Name'] ?? file['name'] ?? 'Unknown';
        final size = file['Size'] ?? file['size'] ?? 0;
        final sizeStr = _formatSize(size as int);

        return ListTile(
          leading: const Icon(Icons.audio_file),
          title: Text(name.toString(), maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(sizeStr),
          trailing: PopupMenuButton(
            itemBuilder: (ctx) => [
              const PopupMenuItem(value: 'metadata', child: Text('Metadata')),
              const PopupMenuItem(value: 'analyze', child: Text('Analyze')),
              const PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
            onSelected: (value) {
              // TODO: implement actions
            },
          ),
        );
      },
    );
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
