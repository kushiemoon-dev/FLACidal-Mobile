import 'dart:convert';
import 'package:http/http.dart' as http;

/// Resolves music URLs from any platform to Tidal/Qobuz via Odesli (song.link) API.
class URLResolver {
  static const _odesliBase = 'https://api.song.link/v1-alpha.1/links';

  /// Returns a Tidal URL if the input URL can be resolved, null otherwise.
  /// Supports Spotify, Apple Music, YouTube Music, Deezer, etc.
  static Future<ResolvedURL?> resolve(String url) async {
    // Already a Tidal or Qobuz URL — no resolution needed
    final lower = url.toLowerCase();
    if (lower.contains('tidal.com') || lower.contains('qobuz.com')) {
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse('$_odesliBase?url=${Uri.encodeComponent(url)}'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final linksByPlatform = data['linksByPlatform'] as Map<String, dynamic>? ?? {};

      // Try Tidal first, then Qobuz
      final tidal = linksByPlatform['tidal'] as Map<String, dynamic>?;
      final qobuz = linksByPlatform['qobuz'] as Map<String, dynamic>?;

      final tidalUrl = tidal?['url'] as String?;
      final qobuzUrl = qobuz?['url'] as String?;

      if (tidalUrl == null && qobuzUrl == null) return null;

      // Get entity info
      final entityId = data['entityUniqueId'] as String? ?? '';
      final title = data['entitiesByUniqueId']?[entityId]?['title'] as String? ?? '';
      final artist = data['entitiesByUniqueId']?[entityId]?['artistName'] as String? ?? '';

      return ResolvedURL(
        tidalUrl: tidalUrl,
        qobuzUrl: qobuzUrl,
        title: title,
        artist: artist,
        originalUrl: url,
      );
    } catch (_) {
      return null;
    }
  }
}

class ResolvedURL {
  final String? tidalUrl;
  final String? qobuzUrl;
  final String title;
  final String artist;
  final String originalUrl;

  const ResolvedURL({
    this.tidalUrl,
    this.qobuzUrl,
    required this.title,
    required this.artist,
    required this.originalUrl,
  });

  String get bestUrl => tidalUrl ?? qobuzUrl ?? originalUrl;
}
