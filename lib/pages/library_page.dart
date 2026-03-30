import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/flac_core.dart';
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
  String _sortBy = 'name'; // name, date, size
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFiles() async {
    setState(() => _loading = true);
    try {
      final core = ref.read(flacCoreProvider);
      final result = core.callSync('listFiles', {'dir': core.downloadDir});
      final files = result['result'] as List<dynamic>? ?? [];
      _sortFiles(files);
      setState(() {
        _files = files;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  void _sortFiles(List<dynamic> files) {
    files.sort((a, b) {
      final ma = a as Map<String, dynamic>;
      final mb = b as Map<String, dynamic>;
      return switch (_sortBy) {
        'size' => ((mb['size'] ?? mb['Size'] ?? 0) as int)
            .compareTo((ma['size'] ?? ma['Size'] ?? 0) as int),
        'date' => (mb['modTime'] ?? mb['ModTime'] ?? '')
            .toString()
            .compareTo((ma['modTime'] ?? ma['ModTime'] ?? '').toString()),
        _ => (ma['name'] ?? ma['Name'] ?? '')
            .toString()
            .toLowerCase()
            .compareTo((mb['name'] ?? mb['Name'] ?? '').toString().toLowerCase()),
      };
    });
  }

  Future<void> _showMetadata(Map<String, dynamic> file) async {
    final path = file['path'] ?? file['Path'] ?? '';
    if (path.toString().isEmpty) return;

    try {
      final core = ref.read(flacCoreProvider);
      final result = core.callSync('getMetadata', {'path': path});
      final meta = result['result'] as Map<String, dynamic>? ?? {};

      if (!mounted) return;
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (ctx) => DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          expand: false,
          builder: (ctx, scrollCtrl) => ListView(
            controller: scrollCtrl,
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              Text('Metadata', style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 16),
              ...meta.entries.map((e) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 120,
                          child: Text(e.key,
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Expanded(child: Text(e.value.toString())),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _deleteFile(Map<String, dynamic> file) async {
    final name = file['name'] ?? file['Name'] ?? 'file';
    final path = file['path'] ?? file['Path'] ?? '';

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete File'),
        content: Text('Delete "$name"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(ctx).colorScheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && path.toString().isNotEmpty) {
      try {
        ref.read(flacCoreProvider).callSync('deleteFile', {'path': path});
        _loadFiles();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final flacCount = _files.where((f) {
      final name = (f as Map<String, dynamic>)['name'] ?? f['Name'] ?? '';
      return name.toString().endsWith('.flac');
    }).length;

    return Scaffold(
      appBar: AppBar(
        title: Text('Library${flacCount > 0 ? ' ($flacCount)' : ''}'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort',
            onSelected: (v) {
              setState(() {
                _sortBy = v;
                _sortFiles(_files);
              });
            },
            itemBuilder: (_) => [
              CheckedPopupMenuItem(value: 'name', checked: _sortBy == 'name', child: const Text('Name')),
              CheckedPopupMenuItem(value: 'date', checked: _sortBy == 'date', child: const Text('Date')),
              CheckedPopupMenuItem(value: 'size', checked: _sortBy == 'size', child: const Text('Size')),
            ],
          ),
          IconButton(
            icon: Icon(_gridView ? Icons.list : Icons.grid_view),
            onPressed: () => setState(() => _gridView = !_gridView),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadFiles,
        child: _buildBody(),
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredFiles() {
    final flacFiles = _files
        .where((f) {
          final name = (f as Map<String, dynamic>)['name'] ?? f['Name'] ?? '';
          return name.toString().endsWith('.flac');
        })
        .cast<Map<String, dynamic>>()
        .toList();

    if (_searchQuery.isEmpty) return flacFiles;

    final query = _searchQuery.toLowerCase();
    return flacFiles.where((f) {
      final name = (f['name'] ?? f['Name'] ?? '').toString().toLowerCase();
      return name.contains(query);
    }).toList();
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());

    final flacFiles = _getFilteredFiles();

    if (_files.isEmpty) {
      return ListView(children: const [
        SizedBox(height: 120),
        Center(
          child: Column(children: [
            Icon(Icons.library_music, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No downloaded files yet'),
            SizedBox(height: 8),
            Text('Download some tracks from the Home page',
                style: TextStyle(color: Colors.grey)),
          ]),
        ),
      ]);
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search library...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              isDense: true,
            ),
            onChanged: (v) => setState(() => _searchQuery = v),
          ),
        ),
        if (flacFiles.isEmpty)
          const Expanded(
            child: Center(child: Text('No matching files')),
          )
        else if (_gridView)
          Expanded(child: _buildGridView(flacFiles))
        else
          Expanded(child: _buildListView(flacFiles)),
      ],
    );
  }

  Widget _buildListView(List<Map<String, dynamic>> flacFiles) {
    return ListView.builder(
      itemCount: flacFiles.length,
      itemBuilder: (context, index) {
        final file = flacFiles[index];
        final name = file['name'] ?? file['Name'] ?? 'Unknown';
        final size = (file['size'] ?? file['Size'] ?? 0) as int;
        final displayName = name.toString().replaceAll('.flac', '');

        return ListTile(
          leading: _buildCoverArt(file, size: 40),
          title: Text(displayName, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(_formatSize(size)),
          trailing: PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'metadata':
                  _showMetadata(file);
                case 'delete':
                  _deleteFile(file);
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'metadata', child: Text('Metadata')),
              PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGridView(List<Map<String, dynamic>> flacFiles) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: flacFiles.length,
      itemBuilder: (context, index) {
        final file = flacFiles[index];
        final name = file['name'] ?? file['Name'] ?? 'Unknown';
        final displayName = name.toString().replaceAll('.flac', '');

        return GestureDetector(
          onTap: () => _showMetadata(file),
          onLongPress: () => _deleteFile(file),
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _buildCoverArt(file, fit: BoxFit.cover),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    displayName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Build a cover art widget. Checks for a companion .jpg alongside the .flac.
  Widget _buildCoverArt(Map<String, dynamic> file,
      {double? size, BoxFit fit = BoxFit.cover}) {
    final path = (file['path'] ?? file['Path'] ?? '').toString();
    if (path.isNotEmpty) {
      final jpgPath = '${path.replaceAll(RegExp(r'\.flac$'), '')}.jpg';
      final jpgFile = File(jpgPath);
      if (jpgFile.existsSync()) {
        if (size != null) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.file(jpgFile, width: size, height: size, fit: fit),
          );
        }
        return Image.file(jpgFile, fit: fit);
      }
      // Also check cover.jpg in same directory
      final dirCover = File('${File(path).parent.path}/cover.jpg');
      if (dirCover.existsSync()) {
        if (size != null) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.file(dirCover, width: size, height: size, fit: fit),
          );
        }
        return Image.file(dirCover, fit: fit);
      }
    }

    // Fallback icon
    if (size != null) {
      return Icon(Icons.audio_file, size: size);
    }
    return const Center(
      child: Icon(Icons.album, size: 48, color: Colors.grey),
    );
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
