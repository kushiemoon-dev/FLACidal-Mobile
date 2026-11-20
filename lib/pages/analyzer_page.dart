import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/core_errors.dart';
import '../l10n/app_localizations.dart';
import '../providers/core_provider.dart';
import 'library/analysis_result.dart';

/// Runs `quickAnalyze` on each selected file, with a deeper `analyzeFile`
/// pass available per file.
class AnalyzerPage extends ConsumerStatefulWidget {
  const AnalyzerPage({super.key, required this.filePaths});

  final List<String> filePaths;

  @override
  ConsumerState<AnalyzerPage> createState() => _AnalyzerPageState();
}

class _AnalyzerPageState extends ConsumerState<AnalyzerPage> {
  final Map<String, AnalysisResult> _results = {};
  final Map<String, Object> _errors = {};
  final Set<String> _running = {};

  @override
  void initState() {
    super.initState();
    for (final path in widget.filePaths) {
      _run(path, 'quickAnalyze');
    }
  }

  Future<void> _run(String path, String method) async {
    setState(() {
      _running.add(path);
      _errors.remove(path);
    });
    try {
      final raw = await ref.read(flacCoreProvider).callResultAsync(method, {
        'path': path,
      });
      if (mounted) {
        setState(() => _results[path] = AnalysisResult.fromCore(raw));
      }
    } catch (e) {
      if (mounted) setState(() => _errors[path] = e);
    } finally {
      if (mounted) setState(() => _running.remove(path));
    }
  }

  String _verdict(AppLocalizations l, AnalysisResult r) => switch (r.verdict) {
    'lossless' => l.analyzerVerdictLossless,
    'likely_upscaled' => l.analyzerVerdictLikelyUpscaled,
    'upscaled' => l.analyzerVerdictUpscaled,
    _ => r.verdictLabel,
  };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.analyzerTitle)),
      body: ListView.builder(
        itemCount: widget.filePaths.length,
        itemBuilder: (context, i) {
          final path = widget.filePaths[i];
          final result = _results[path];
          final error = _errors[path];
          final name = result?.fileName.isNotEmpty == true
              ? result!.fileName
              : path.split('/').last;
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  if (_running.contains(path))
                    const LinearProgressIndicator()
                  else if (error != null)
                    Text(
                      l.analyzerFailed(describeCoreError(l, error)),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    )
                  else if (result != null) ...[
                    _row(l.analyzerVerdict, _verdict(l, result)),
                    if (result.confidence != null)
                      _row(
                        l.analyzerConfidence,
                        '${result.confidence!.toStringAsFixed(0)} %',
                      ),
                    if (result.sampleRate != null)
                      _row(
                        l.analyzerSampleRate,
                        l.analyzerHz(result.sampleRate!),
                      ),
                    if (result.bitDepth != null)
                      _row(
                        l.analyzerBitDepth,
                        l.analyzerBits(result.bitDepth!),
                      ),
                    if (result.spectrumCutoff != null &&
                        result.spectrumCutoff! > 0)
                      _row(
                        l.analyzerCutoff,
                        l.analyzerHz(result.spectrumCutoff!),
                      ),
                    if (result.expectedCutoff != null &&
                        result.expectedCutoff! > 0)
                      _row(
                        l.analyzerExpectedCutoff,
                        l.analyzerHz(result.expectedCutoff!),
                      ),
                    if (result.bpm != null && result.bpm! > 0)
                      _row(l.analyzerBpm, result.bpm!.toStringAsFixed(0)),
                    if (result.musicalKey.isNotEmpty)
                      _row(l.analyzerKey, result.musicalKey),
                    if (result.details.isNotEmpty)
                      _row(l.analyzerDetails, result.details),
                  ],
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: _running.contains(path)
                          ? null
                          : () => _run(path, 'analyzeFile'),
                      icon: const Icon(Icons.graphic_eq),
                      label: Text(l.libraryAnalyze),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(label, style: const TextStyle(color: Colors.grey)),
        ),
        Expanded(child: Text(value)),
      ],
    ),
  );
}
