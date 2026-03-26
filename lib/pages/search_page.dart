import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/exceptions.dart';
import '../providers/core_provider.dart';

/// Search page — search tracks across Tidal/Qobuz.
class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _searchController = TextEditingController();
  bool _loading = false;
  String? _error;
  List<dynamic> _results = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final core = ref.read(flacCoreProvider);
      final result = core.searchTidal(query);
      setState(() {
        _results = result['result'] as List<dynamic>? ?? [];
        _loading = false;
      });
    } on FlacCoreException catch (e) {
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search tracks...',
            border: InputBorder.none,
          ),
          onSubmitted: (_) => _search(),
          autofocus: true,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _loading ? null : _search,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error, size: 48, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 8),
            Text(_error!),
          ],
        ),
      );
    }

    if (_results.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Search for tracks on Tidal'),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final track = _results[index] as Map<String, dynamic>;
        final title = track['Title'] ?? track['title'] ?? 'Unknown';
        final artist = track['Artist'] ?? track['artist'] ?? '';

        return ListTile(
          leading: const CircleAvatar(child: Icon(Icons.music_note)),
          title: Text(title.toString(), maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(artist.toString()),
          trailing: IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              final core = ref.read(flacCoreProvider);
              core.queueDownloads([track], '');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Queued: $title')),
              );
            },
          ),
        );
      },
    );
  }
}
