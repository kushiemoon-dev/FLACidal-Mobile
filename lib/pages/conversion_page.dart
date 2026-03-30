import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/core_provider.dart';

/// Format conversion page — convert FLAC files to other formats.
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
  List<dynamic> _formats = [];
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

      List<dynamic> formats = [];
      if (avail) {
        final fmtResult = core.callSync('getConversionFormats');
        formats = fmtResult['result'] as List<dynamic>? ?? [];
      }

      setState(() {
        _converterAvailable = avail;
        _formats = formats;
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Conversion complete')),
        );
      }
    } catch (e) {
      setState(() => _converting = false);
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
          Text('FFmpeg not available'),
          SizedBox(height: 8),
          Text('Format conversion requires FFmpeg installed on the device.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Files to convert
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${widget.filePaths.length} file(s) selected',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                ...widget.filePaths.take(5).map((p) => Text(
                      p.split('/').last,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )),
                if (widget.filePaths.length > 5)
                  Text('... and ${widget.filePaths.length - 5} more',
                      style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Format selector
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

        // Bitrate
        Text('Bitrate: $_bitrate kbps',
            style: Theme.of(context).textTheme.titleSmall),
        Slider(
          value: _bitrate.toDouble(),
          min: 128,
          max: 320,
          divisions: 6,
          label: '$_bitrate kbps',
          onChanged: (v) => setState(() => _bitrate = v.round()),
        ),
        const SizedBox(height: 8),

        // Delete source
        SwitchListTile(
          title: const Text('Delete source files'),
          subtitle: const Text('Remove original FLAC after conversion'),
          value: _deleteSource,
          onChanged: (v) => setState(() => _deleteSource = v),
        ),
        const SizedBox(height: 24),

        // Convert button
        FilledButton.icon(
          onPressed: _converting ? null : _convert,
          icon: _converting
              ? const SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.transform),
          label: Text(_converting ? 'Converting...' : 'Convert'),
        ),

        // Result
        if (_result != null) ...[
          const SizedBox(height: 16),
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Conversion complete',
                  style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer)),
            ),
          ),
        ],
      ],
    );
  }
}
