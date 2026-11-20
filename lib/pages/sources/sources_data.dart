import '../../core/flac_core.dart';

class SourceEntry {
  const SourceEntry({
    required this.name,
    required this.displayName,
    required this.available,
  });

  final String name;
  final String displayName;
  final bool available;

  String get label => displayName.isEmpty ? name : displayName;
}

/// Everything the Sources screen shows, read only from keys Core really sends.
class SourcesData {
  const SourcesData({
    required this.sources,
    required this.order,
    required this.preferred,
    required this.qualityFallback,
    required this.extensionNames,
    required this.config,
  });

  final List<SourceEntry> sources;
  final List<String> order;
  final String? preferred;
  final bool qualityFallback;
  final Map<String, String> extensionNames;
  final Map<String, dynamic> config;

  /// `displayName` from `getAvailableSources`, else the installed extension's
  /// manifest name, else the raw id.
  String labelFor(String id) =>
      sourceLabel(id, sources: sources, extensionNames: extensionNames);
}

String sourceLabel(
  String id, {
  required List<SourceEntry> sources,
  required Map<String, String> extensionNames,
}) {
  for (final s in sources) {
    if (s.name == id && s.label.isNotEmpty) return s.label;
  }
  final ext = extensionNames[id];
  if (ext != null && ext.isNotEmpty) return ext;
  return id;
}

/// Parses raw `result` payloads. Throws [FormatException] when a payload has
/// an unexpected shape instead of inventing a value.
SourcesData parseSources({
  required Object? available,
  required Object? preferred,
  required Object? order,
  required Object? config,
  Object? extensions,
}) {
  if (available is! List) {
    throw const FormatException('getAvailableSources: expected a list');
  }
  if (order is! List) {
    throw const FormatException('getSourceOrder: expected a list');
  }
  if (config is! Map) {
    throw const FormatException('getConfig: expected a map');
  }
  final names = <String, String>{};
  if (extensions is List) {
    for (final e in extensions) {
      final manifest = e is Map ? e['manifest'] : null;
      if (manifest is Map && manifest['id'] is String) {
        names[manifest['id'] as String] = manifest['name'] as String? ?? '';
      }
    }
  }
  return SourcesData(
    sources: [
      for (final s in available.whereType<Map>())
        SourceEntry(
          name: s['name'] as String? ?? '',
          displayName: s['displayName'] as String? ?? '',
          available: s['available'] as bool? ?? false,
        ),
    ],
    order: [for (final id in order) id.toString()],
    preferred: preferred is String && preferred.isNotEmpty ? preferred : null,
    qualityFallback: config['autoQualityFallback'] as bool? ?? false,
    extensionNames: names,
    config: Map<String, dynamic>.from(config),
  );
}

SourcesData loadSources(FlacCore core) {
  Object? extensions;
  try {
    extensions = core.callResult('getExtensions');
  } catch (_) {
    // Labels fall back to the raw id; the screen stays usable.
  }
  return parseSources(
    available: core.callResult('getAvailableSources'),
    preferred: core.callResult('getPreferredSource'),
    order: core.callResult('getSourceOrder'),
    config: core.callResult('getConfig'),
    extensions: extensions,
  );
}
