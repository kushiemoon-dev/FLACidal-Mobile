import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/core_provider.dart';

/// Full-screen page for editing FLAC file metadata.
class EditMetadataPage extends ConsumerStatefulWidget {
  final String filePath;
  final Map<String, dynamic> initialMetadata;

  const EditMetadataPage({
    super.key,
    required this.filePath,
    required this.initialMetadata,
  });

  @override
  ConsumerState<EditMetadataPage> createState() => _EditMetadataPageState();
}

class _EditMetadataPageState extends ConsumerState<EditMetadataPage> {
  late final TextEditingController _title;
  late final TextEditingController _artist;
  late final TextEditingController _album;
  late final TextEditingController _albumArtist;
  late final TextEditingController _trackNumber;
  late final TextEditingController _discNumber;
  late final TextEditingController _year;
  late final TextEditingController _genre;
  late final TextEditingController _isrc;
  late final TextEditingController _label;
  late final TextEditingController _copyright;
  late final TextEditingController _composer;
  late final TextEditingController _comment;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final m = widget.initialMetadata;
    _title = TextEditingController(text: _str(m, 'title'));
    _artist = TextEditingController(text: _str(m, 'artist'));
    _album = TextEditingController(text: _str(m, 'album'));
    _albumArtist = TextEditingController(text: _str(m, 'albumArtist'));
    _trackNumber = TextEditingController(text: _str(m, 'trackNumber'));
    _discNumber = TextEditingController(text: _str(m, 'discNumber'));
    _year = TextEditingController(text: _str(m, 'date'));
    _genre = TextEditingController(text: _str(m, 'genre'));
    _isrc = TextEditingController(text: _str(m, 'isrc'));
    _label = TextEditingController(text: _str(m, 'label'));
    _copyright = TextEditingController(text: _str(m, 'copyright'));
    _composer = TextEditingController(text: _str(m, 'composer'));
    _comment = TextEditingController(text: _str(m, 'comment'));
  }

  String _str(Map<String, dynamic> m, String key) =>
      (m[key] ?? '').toString();

  @override
  void dispose() {
    _title.dispose();
    _artist.dispose();
    _album.dispose();
    _albumArtist.dispose();
    _trackNumber.dispose();
    _discNumber.dispose();
    _year.dispose();
    _genre.dispose();
    _isrc.dispose();
    _label.dispose();
    _copyright.dispose();
    _composer.dispose();
    _comment.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final core = ref.read(flacCoreProvider);
      final trackNum = int.tryParse(_trackNumber.text) ?? 0;
      final discNum = int.tryParse(_discNumber.text) ?? 0;
      core.callSync('editMetadata', {
        'path': widget.filePath,
        'metadata': {
          'title': _title.text,
          'artist': _artist.text,
          'album': _album.text,
          'albumArtist': _albumArtist.text,
          'trackNumber': trackNum,
          'discNumber': discNum,
          'year': _year.text,
          'genre': _genre.text,
          'isrc': _isrc.text,
          'label': _label.text,
          'copyright': _copyright.text,
          'composer': _composer.text,
          'comment': _comment.text,
        },
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Metadata saved')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _extractCoverArt() async {
    try {
      final core = ref.read(flacCoreProvider);
      final result = core.callSync('extractCoverArt', {
        'path': widget.filePath,
      });
      final savedPath = result['result']?['path'] ?? 'unknown';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cover art saved: $savedPath')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _saveLyrics() async {
    try {
      final core = ref.read(flacCoreProvider);
      final result = core.callSync('saveLyricsToFile', {
        'path': widget.filePath,
      });
      final savedPath = result['result']?['path'] ?? 'unknown';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lyrics saved: $savedPath')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _reEnrich() async {
    try {
      final core = ref.read(flacCoreProvider);
      final result = core.callSync('reEnrichMetadata', {
        'path': widget.filePath,
      });
      final fields = result['result']?['updated_fields'] as List? ?? [];
      if (mounted) {
        final msg = fields.isEmpty
            ? 'No additional metadata found'
            : 'Updated: ${fields.join(", ")}';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Metadata'),
        actions: [
          if (_saving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              tooltip: 'Save',
              onPressed: _save,
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Action buttons
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ActionChip(
                avatar: const Icon(Icons.image, size: 18),
                label: const Text('Extract Cover Art'),
                onPressed: _extractCoverArt,
              ),
              ActionChip(
                avatar: const Icon(Icons.lyrics, size: 18),
                label: const Text('Save Lyrics'),
                onPressed: _saveLyrics,
              ),
              ActionChip(
                avatar: const Icon(Icons.auto_fix_high, size: 18),
                label: const Text('Re-enrich'),
                onPressed: _reEnrich,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _field('Title', _title),
          _field('Artist', _artist),
          _field('Album', _album),
          _field('Album Artist', _albumArtist),
          Row(
            children: [
              Expanded(child: _field('Track #', _trackNumber,
                  keyboardType: TextInputType.number)),
              const SizedBox(width: 12),
              Expanded(child: _field('Disc #', _discNumber,
                  keyboardType: TextInputType.number)),
            ],
          ),
          _field('Year', _year, keyboardType: TextInputType.number),
          _field('Genre', _genre),
          _field('ISRC', _isrc),
          _field('Label', _label),
          _field('Copyright', _copyright),
          _field('Composer', _composer),
          _field('Comment', _comment, maxLines: 3),
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController controller,
      {TextInputType? keyboardType, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
