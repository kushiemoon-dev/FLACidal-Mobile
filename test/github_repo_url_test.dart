import 'package:flacidal_mobile/core/github_repo_url.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('accepts a plain repository URL', () {
    expect(
      normalizeGithubRepoUrl('https://github.com/owner/repo'),
      'https://github.com/owner/repo',
    );
  });

  test('strips trailing slash, .git and surrounding spaces', () {
    expect(
      normalizeGithubRepoUrl('  https://github.com/o/r.git/ '),
      'https://github.com/o/r',
    );
  });

  test('keeps dots and dashes inside names', () {
    expect(
      normalizeGithubRepoUrl('https://github.com/my-org/my.repo_x'),
      'https://github.com/my-org/my.repo_x',
    );
  });

  for (final bad in [
    'http://github.com/o/r',
    'https://gitlab.com/o/r',
    'https://github.com/o',
    'https://github.com/o/r/tree/main',
    'https://github.com/o/r extra',
    'https://github.com/o r/x',
    'https://evil.com/https://github.com/o/r',
    '',
  ]) {
    test('rejects "$bad"', () => expect(normalizeGithubRepoUrl(bad), isNull));
  }
}
