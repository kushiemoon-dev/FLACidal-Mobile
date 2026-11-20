/// Subset of Core's `AnalysisResult` (analyzer.go) shown on screen. Every
/// field is optional: Core omits nothing today, but the UI must not crash if
/// a future Core drops or retypes one.
class AnalysisResult {
  const AnalysisResult({
    required this.fileName,
    this.verdict = '',
    this.verdictLabel = '',
    this.isTrueLossless,
    this.confidence,
    this.sampleRate,
    this.bitDepth,
    this.spectrumCutoff,
    this.expectedCutoff,
    this.bpm,
    this.musicalKey = '',
    this.details = '',
  });

  factory AnalysisResult.fromCore(Object? json) {
    if (json is! Map) {
      throw const FormatException('analysis: expected a map');
    }
    int? asInt(Object? v) => v is num ? v.toInt() : null;
    double? asDouble(Object? v) => v is num ? v.toDouble() : null;
    return AnalysisResult(
      fileName: json['fileName'] as String? ?? '',
      verdict: json['verdict'] as String? ?? '',
      verdictLabel: json['verdictLabel'] as String? ?? '',
      isTrueLossless: json['isTrueLossless'] as bool?,
      confidence: asDouble(json['confidence']),
      sampleRate: asInt(json['sampleRate']),
      bitDepth: asInt(json['bitDepth']),
      spectrumCutoff: asInt(json['spectrumCutoff']),
      expectedCutoff: asInt(json['expectedCutoff']),
      bpm: asDouble(json['bpm']),
      musicalKey: json['musicalKey'] as String? ?? '',
      details: json['details'] as String? ?? '',
    );
  }

  final String fileName;
  final String verdict;
  final String verdictLabel;
  final bool? isTrueLossless;
  final double? confidence;
  final int? sampleRate;
  final int? bitDepth;
  final int? spectrumCutoff;
  final int? expectedCutoff;
  final double? bpm;
  final String musicalKey;
  final String details;
}
