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

// countVersionsBehind returns how many entries of tagsNewestFirst (newest
// first, as returned by the GitHub releases API) separate current from the
// newest tag. Malformed tags are skipped. If current is not found in the
// list (older than everything returned, or a non-semver value), it returns
// tagsNewestFirst.length, trivially past forcedUpdateThreshold.
int countVersionsBehind(String current, List<String> tagsNewestFirst) {
  final cur = _tryParse(current);
  if (cur == null) return tagsNewestFirst.length;
  for (var i = 0; i < tagsNewestFirst.length; i++) {
    final t = _tryParse(tagsNewestFirst[i]);
    if (t != null && t == cur) return i;
  }
  return tagsNewestFirst.length;
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
      latestVersion: tags.first.replaceFirst(RegExp(r'^v'), ''),
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

  final checksumsResponse = await http.get(
    Uri.parse(checksumsAsset.browserDownloadUrl),
  );
  final expectedHash = _findChecksum(checksumsResponse.body, apkAsset.name);
  if (expectedHash == null) {
    throw Exception('No checksum entry for ${apkAsset.name}');
  }

  final dir = await getTemporaryDirectory();
  final apkFile = File('${dir.path}/update.apk');

  final request = http.Request('GET', Uri.parse(apkAsset.browserDownloadUrl));
  final streamedResponse = await http.Client().send(request);
  final total = streamedResponse.contentLength ?? 0;
  var received = 0;

  await DownloadService.start(total: total);
  final sink = apkFile.openWrite();
  try {
    await for (final chunk in streamedResponse.stream) {
      sink.add(chunk);
      received += chunk.length;
      onProgress(received, total);
      await DownloadService.update(completed: received, total: total);
    }
    await sink.flush();
  } finally {
    await sink.close();
    await DownloadService.stop();
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
