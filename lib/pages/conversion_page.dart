import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/core_provider.dart';

class ConversionPage extends ConsumerStatefulWidget {
  final List<String> filePaths;
  const ConversionPage({super.key, required this.filePaths});

  @override
  ConsumerState<ConversionPage> createState() => _ConversionPageState();
}

class _ConversionPageState extends ConsumerState<ConversionPage> {
  bool _loading = true;
  bool _converting = false;
  bool _converterAvailable = false;
  String _selectedFormat = 'mp3';
  int _bitrate = 320;
  bool _deleteSource = false;
  Map<String, dynamic>? _result;

  @override
  void initState() {
    super.initState();
    _checkConverter();
  }

  Future<void> _checkConverter() async {
    try {
      final core = ref.read(flacCoreProvider);
      final available = core.callSync('isConverterAvailable');
      final avail = available['result'] as bool? ?? false;

      setState(() {
        _converterAvailable = avail;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _converterAvailable = false;
      });
    }
  }

  Future<void> _convert() async {
    setState(() => _converting = true);

    try {
      final core = ref.read(flacCoreProvider);
      final result = core.callSync('convertFiles', {
        'files': widget.filePaths,
        'options': {
          'format': _selectedFormat,
          'bitrate': _bitrate,
          'deleteSource': _deleteSource,
        },
      });

      setState(() {
        _result = result['result'] as Map<String, dynamic>?;
        _converting = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Conversion finished')));
      }
    } catch (e) {
      setState(() => _converting = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Something went wrong: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Convert')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : !_converterAvailable
          ? _buildUnavailable()
          : _buildForm(),
    );
  }

  Widget _buildUnavailable() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning, size: 64, color: Colors.orange),
          SizedBox(height: 16),
          Text('FFmpeg is unavailable'),
          SizedBox(height: 8),
          Text(
            'FFmpeg needs to be installed on this device for format conversion to work.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.filePaths.length} file(s) selected',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ...widget.filePaths
                    .take(5)
                    .map(
                      (p) => Text(
                        p.split('/').last,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                if (widget.filePaths.length > 5)
                  Text(
                    '... and ${widget.filePaths.length - 5} more',
                    style: const TextStyle(color: Colors.grey),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        Text('Output Format', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'mp3', label: Text('MP3')),
            ButtonSegment(value: 'aac', label: Text('AAC')),
            ButtonSegment(value: 'opus', label: Text('Opus')),
          ],
          selected: {_selectedFormat},
          onSelectionChanged: (v) => setState(() => _selectedFormat = v.first),
        ),
        const SizedBox(height: 16),

        Text(
          'Bitrate: $_bitrate kbps',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        Slider(
          value: _bitrate.toDouble(),
          min: 128,
          max: 320,
          divisions: 6,
          label: '$_bitrate kbps',
          onChanged: (v) => setState(() => _bitrate = v.round()),
        ),
        const SizedBox(height: 8),

        SwitchListTile(
          title: const Text('Delete original files'),
          subtitle: const Text(
            'Deletes the original FLAC once conversion finishes',
          ),
          value: _deleteSource,
          onChanged: (v) => setState(() => _deleteSource = v),
        ),
        const SizedBox(height: 24),

        FilledButton.icon(
          onPressed: _converting ? null : _convert,
          icon: _converting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.transform),
          label: Text(_converting ? 'Converting...' : 'Convert'),
        ),

        if (_result != null) ...[
          const SizedBox(height: 16),
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Conversion finished',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
