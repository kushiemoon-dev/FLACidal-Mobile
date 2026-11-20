import 'package:flacidal_mobile/pages/library/analysis_result.dart';
import 'package:flutter_test/flutter_test.dart';

// Shape taken from AnalysisResult in FLACidal-Core analyzer.go (json tags).
const _fixture = {
  'filePath': '/m/a.flac',
  'fileName': 'a.flac',
  'isTrueLossless': false,
  'confidence': 87.5,
  'spectrumCutoff': 16000,
  'expectedCutoff': 22050,
  'verdict': 'likely_upscaled',
  'verdictLabel': 'Likely upscaled',
  'details': 'cutoff at 16 kHz',
  'sampleRate': 44100,
  'bitDepth': 16,
  'bpm': 120.0,
  'musicalKey': 'Dm',
};

void main() {
  test('parses every field of the Core payload', () {
    final r = AnalysisResult.fromCore(_fixture);
    expect(r.fileName, 'a.flac');
    expect(r.verdict, 'likely_upscaled');
    expect(r.isTrueLossless, isFalse);
    expect(r.confidence, 87.5);
    expect((r.sampleRate, r.bitDepth), (44100, 16));
    expect((r.spectrumCutoff, r.expectedCutoff), (16000, 22050));
    expect((r.bpm, r.musicalKey), (120.0, 'Dm'));
  });

  test('integers sent as doubles and missing keys do not crash', () {
    final r = AnalysisResult.fromCore({'sampleRate': 48000.0});
    expect(r.sampleRate, 48000);
    expect(r.bitDepth, isNull);
    expect(r.verdict, isEmpty);
  });

  test('wrong top level shape is rejected', () {
    expect(() => AnalysisResult.fromCore([]), throwsFormatException);
  });
}
