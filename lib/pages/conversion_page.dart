import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/core_provider.dart';
import '../l10n/app_localizations.dart';
import '../widgets/error_text.dart';

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
        ).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).convertDone)));
      }
    } catch (e) {
      setState(() => _converting = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(genericErrorText(context, e))));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).convertTitle)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : !_converterAvailable
          ? _buildUnavailable()
          : _buildForm(),
    );
  }

  Widget _buildUnavailable() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.warning, size: 64, color: Colors.orange),
          const SizedBox(height: 16),
          Text(AppLocalizations.of(context).convertFfmpegUnavailable),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context).convertFfmpegBody,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
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
                  AppLocalizations.of(context).convertFilesSelected(widget.filePaths.length),
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
                    AppLocalizations.of(context).convertMore(widget.filePaths.length - 5),
                    style: const TextStyle(color: Colors.grey),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        Text(
          AppLocalizations.of(context).convertOutputFormat,
          style: Theme.of(context).textTheme.titleSmall,
        ),
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
          AppLocalizations.of(context).convertBitrate(_bitrate),
          style: Theme.of(context).textTheme.titleSmall,
        ),
        Slider(
          value: _bitrate.toDouble(),
          min: 128,
          max: 320,
          divisions: 6,
          label: AppLocalizations.of(context).convertKbps(_bitrate),
          onChanged: (v) => setState(() => _bitrate = v.round()),
        ),
        const SizedBox(height: 8),

        SwitchListTile(
          title: Text(AppLocalizations.of(context).convertDeleteOriginals),
          subtitle: Text(AppLocalizations.of(context).convertDeleteOriginalsHint),
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
          label: Text(
            _converting ? AppLocalizations.of(context).convertConverting : AppLocalizations.of(context).convertTitle,
          ),
        ),

        if (_result != null) ...[
          const SizedBox(height: 16),
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                AppLocalizations.of(context).convertDone,
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
