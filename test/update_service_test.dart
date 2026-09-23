import 'package:flutter_test/flutter_test.dart';

import 'package:flacidal_mobile/core/update_service.dart';

// Deliberately left uncovered here (same convention as
// test/config_provider_test.dart's FlacCore/native-init exclusion):
//   - fetchUpdateStatus / downloadAndInstallUpdate: issue live network I/O
//     (GitHub releases API, APK download) and touch the filesystem/platform
//     install intent, none of which is available in a plain `flutter test`
//     unit-test process.

void main() {
  test('current version at the head of the list is 0 behind', () {
    final tags = ['v0.8.0-beta.11', 'v0.8.0-beta.10', 'v0.8.0-beta.9'];
    expect(countVersionsBehind('0.8.0-beta.11', tags), 0);
  });

  test('orders prereleases correctly, not lexicographically', () {
    // beta.10 sorts after beta.9 as a string in a way that would break a
    // naive comparison; pub_semver handles prerelease ordering correctly.
    final tags = ['v0.8.0-beta.11', 'v0.8.0-beta.10', 'v0.8.0-beta.9'];
    expect(countVersionsBehind('0.8.0-beta.10', tags), 1);
  });

  test('current version absent from the list returns the list length', () {
    final tags = ['v0.8.0-beta.11', 'v0.8.0-beta.10'];
    expect(countVersionsBehind('0.1.0', tags), tags.length);
  });

  test('ignores a malformed tag in the list without throwing', () {
    final tags = [
      'v0.8.0-beta.12',
      'not-a-version',
      'v0.8.0-beta.11',
      'v0.8.0-beta.10',
    ];
    expect(countVersionsBehind('0.8.0-beta.10', tags), 2);
  });

  test('a non-semver current version returns the list length', () {
    final tags = ['v0.8.0-beta.11', 'v0.8.0-beta.10'];
    expect(countVersionsBehind('dev', tags), tags.length);
  });

  test('current version newer than every tag is 0 behind', () {
    // A local build or CI workflow_dispatch run ahead of the last tagged
    // release must never be hard-blocked.
    final tags = ['v0.8.0-beta.11', 'v0.8.0-beta.10'];
    expect(countVersionsBehind('0.8.0-beta.12', tags), 0);
  });

  test(
    'counts by version value, not list position (release list is by creation date)',
    () {
      // GitHub's releases list is ordered by creation date, not semver: a
      // backport published after a newer feature release lands first in
      // the list despite being the lower version.
      final tags = ['v0.9.1', 'v0.9.2', 'v0.9.0'];
      expect(countVersionsBehind('0.9.0', tags), 2);
    },
  );
}
