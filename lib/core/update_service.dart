import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pub_semver/pub_semver.dart';

import 'download_service.dart';

const forcedUpdateThreshold = 3;

class UpdateAsset {
  final String name;
  final String browserDownloadUrl;

  const UpdateAsset({required this.name, required this.browserDownloadUrl});
}

class UpdateStatus {
  final bool hasUpdate;
  final String currentVersion;
  final String latestVersion;
  final int versionsBehind;
  final bool blocked;
  final String releaseUrl;
  final List<UpdateAsset> latestAssets;

  const UpdateStatus({
    required this.hasUpdate,
    required this.currentVersion,
    required this.latestVersion,
    required this.versionsBehind,
    required this.blocked,
    required this.releaseUrl,
    this.latestAssets = const [],
  });
}

Version? _tryParse(String tag) {
  try {
    return Version.parse(tag.replaceFirst(RegExp(r'^v'), ''));
  } catch (_) {
    return null;
  }
}

// countVersionsBehind returns how many tags in tagsNewestFirst are strictly
// newer than current by semver value, not by list position: GitHub orders
// releases by creation date, so a backported patch can appear before a
// later feature release. If current itself does not parse as a version
// (e.g. a non-semver placeholder), it returns tagsNewestFirst.length,
// trivially past forcedUpdateThreshold, since it can't be compared.
int countVersionsBehind(String current, List<String> tagsNewestFirst) {
  final cur = _tryParse(current);
  if (cur == null) return tagsNewestFirst.length;
  var behind = 0;
  for (final tag in tagsNewestFirst) {
    final t = _tryParse(tag);
    if (t != null && t > cur) behind++;
  }
  return behind;
}

// _latestValidTag returns the highest valid semver tag in tags, or "" if
// none is valid. Not necessarily tags.first: see countVersionsBehind.
String _latestValidTag(List<String> tags) {
  Version? best;
  String bestTag = '';
  for (final tag in tags) {
    final v = _tryParse(tag);
    if (v == null) continue;
    if (best == null || v > best) {
      best = v;
      bestTag = tag;
    }
  }
  return bestTag;
}

UpdateStatus _noUpdate(String currentVersion) => UpdateStatus(
  hasUpdate: false,
  currentVersion: currentVersion,
  latestVersion: '',
  versionsBehind: 0,
  blocked: false,
  releaseUrl: '',
);

// fetchUpdateStatus lists every release tag for the mobile repo (not tested
// directly: live network call, same convention as the desktop side). Any
// error or non-200 response fails open: no update, not blocked.
Future<UpdateStatus> fetchUpdateStatus(String currentVersion) async {
  try {
    final response = await http
        .get(
          Uri.parse(
            'https://api.github.com/repos/kushiemoon-dev/FLACidal-Mobile/releases?per_page=100',
          ),
          headers: {'Accept': 'application/vnd.github.v3+json'},
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      return _noUpdate(currentVersion);
    }

    final releases = jsonDecode(response.body) as List<dynamic>;
    if (releases.isEmpty) {
      return _noUpdate(currentVersion);
    }

    final tags = releases
        .map((r) => (r as Map<String, dynamic>)['tag_name'] as String)
        .toList();
    final behind = countVersionsBehind(currentVersion, tags);

    final latestRelease = releases.first as Map<String, dynamic>;
    final assets = (latestRelease['assets'] as List<dynamic>? ?? [])
        .map(
          (a) => UpdateAsset(
            name: (a as Map<String, dynamic>)['name'] as String,
            browserDownloadUrl: a['browser_download_url'] as String,
          ),
        )
        .toList();

    return UpdateStatus(
      hasUpdate: behind > 0,
      currentVersion: currentVersion,
      latestVersion: _latestValidTag(tags).replaceFirst(RegExp(r'^v'), ''),
      versionsBehind: behind,
      blocked: behind >= forcedUpdateThreshold,
      releaseUrl: latestRelease['html_url'] as String? ?? '',
      latestAssets: assets,
    );
  } catch (_) {
    return _noUpdate(currentVersion);
  }
}

String? _findChecksum(String checksumsText, String assetName) {
  for (final line in checksumsText.split('\n')) {
    final trimmed = line.trim();
    if (trimmed.isEmpty) continue;
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length < 2) continue;
    final hash = parts[0];
    final name = parts.sublist(1).join(' ').replaceFirst(RegExp(r'^\*'), '');
    if (name == assetName || name.endsWith('/$assetName')) {
      return hash;
    }
  }
  return null;
}

// downloadAndInstallUpdate downloads the universal APK from status, verifies
// its SHA256 against checksums.txt, and triggers the system install intent.
// A checksum mismatch deletes the partial/corrupt file and throws instead of
// ever calling OpenFile.open. Not tested directly: live network I/O,
// filesystem writes and a platform install intent, same convention as
// fetchUpdateStatus.
Future<void> downloadAndInstallUpdate(
  UpdateStatus status, {
  required void Function(int received, int total) onProgress,
}) async {
  if (!Platform.isAndroid) return;

  final apkAsset = status.latestAssets.firstWhere(
    (a) =>
        a.name.toLowerCase().contains('universal') &&
        a.name.toLowerCase().endsWith('.apk'),
    orElse: () =>
        throw Exception('No universal APK asset found in the latest release'),
  );
  final checksumsAsset = status.latestAssets.firstWhere(
    (a) => a.name == 'checksums.txt',
    orElse: () =>
        throw Exception('No checksums.txt asset found in the latest release'),
  );

  final checksumsResponse = await http
      .get(Uri.parse(checksumsAsset.browserDownloadUrl))
      .timeout(const Duration(seconds: 15));
  final expectedHash = _findChecksum(checksumsResponse.body, apkAsset.name);
  if (expectedHash == null) {
    throw Exception('No checksum entry for ${apkAsset.name}');
  }

  final dir = await getTemporaryDirectory();
  final apkFile = File('${dir.path}/update.apk');

  final client = http.Client();
  try {
    final request = http.Request(
      'GET',
      Uri.parse(apkAsset.browserDownloadUrl),
    );
    final streamedResponse = await client.send(request).timeout(
      const Duration(seconds: 30),
    );
    final total = streamedResponse.contentLength ?? 0;
    var received = 0;

    final startedService = await DownloadService.startUpdate();
    final sink = apkFile.openWrite();
    var lastReportedPercent = -1;
    try {
      await for (final chunk in streamedResponse.stream.timeout(
        const Duration(seconds: 30),
      )) {
        sink.add(chunk);
        received += chunk.length;
        onProgress(received, total);
        if (total > 0) {
          final percent = received * 100 ~/ total;
          if (percent != lastReportedPercent) {
            lastReportedPercent = percent;
            await DownloadService.updateUpdateProgress(percent);
          }
        }
      }
      await sink.flush();
    } finally {
      await sink.close();
      if (startedService) await DownloadService.stop();
    }
  } finally {
    client.close();
  }

  final digest = await sha256.bind(apkFile.openRead()).first;

  if (digest.toString().toLowerCase() != expectedHash.toLowerCase()) {
    await apkFile.delete();
    throw Exception(
      'Downloaded update failed integrity verification (checksum mismatch). '
      'The file has been removed.',
    );
  }

  await Permission.requestInstallPackages.request();
  final result = await OpenFile.open(
    apkFile.path,
    type: 'application/vnd.android.package-archive',
  );
  if (result.type != ResultType.done) {
    throw Exception('Failed to launch the installer: ${result.message}');
  }
}
