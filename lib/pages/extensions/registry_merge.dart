/// Merges registry listings: duplicate ids are dropped, first listing wins.
/// Pass the default registry first, then the user's sources in order.
List<Map<String, dynamic>> mergeRegistries(
  List<List<Map<String, dynamic>>> all,
) {
  final seen = <String>{};
  final merged = <Map<String, dynamic>>[];
  for (final list in all) {
    for (final entry in list) {
      final id = entry['id'] as String? ?? '';
      if (id.isEmpty || !seen.add(id)) continue;
      merged.add(entry);
    }
  }
  return merged;
}

/// Entries of a raw `getExtensionRegistry` result, ignoring junk.
List<Map<String, dynamic>> registryEntries(Object? result) => [
  if (result is List)
    for (final e in result.whereType<Map>()) Map<String, dynamic>.from(e),
];
