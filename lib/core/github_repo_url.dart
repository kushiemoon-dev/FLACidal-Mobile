final _repoUrl = RegExp(
  r'^https://github\.com/[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$',
);

/// Returns the canonical `https://github.com/<owner>/<repo>` form (no
/// trailing slash, no `.git`), or `null` when [input] is not such a URL.
/// Mirrors the check Core applies, so bad input never leaves the device.
String? normalizeGithubRepoUrl(String input) {
  var url = input.trim();
  if (url.endsWith('/')) url = url.substring(0, url.length - 1);
  if (url.endsWith('.git')) url = url.substring(0, url.length - 4);
  return _repoUrl.hasMatch(url) ? url : null;
}
