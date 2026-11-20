#!/usr/bin/env bash
# Validates altstore/apps.json after a release is published: valid JSON, same
# bundle id as the Xcode project, and every URL (icon, IPAs) answers 200.
# Run by hand, it hits the network.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FILE="$ROOT/altstore/apps.json"

jq -e . "$FILE" > /dev/null

want="$(grep -m1 'PRODUCT_BUNDLE_IDENTIFIER = dev.kushiemoon.flacidalMobile;' \
  "$ROOT/ios/Runner.xcodeproj/project.pbxproj" | sed -E 's/.*= (.*);/\1/')"
have="$(jq -r '.apps[0].bundleIdentifier' "$FILE")"
top="$(jq -r '.identifier' "$FILE")"
if [[ "$want" != "$have" || "$want" != "$top" ]]; then
  echo "Bundle id mismatch: project=$want apps.json=$have source=$top" >&2
  exit 1
fi

fail=0
for url in $(jq -r '.apps[0].iconURL, (.apps[0].versions[].downloadURL)' "$FILE"); do
  code="$(curl -sIL -o /dev/null -w '%{http_code}' "$url")"
  echo "$code $url"
  [[ "$code" == "200" ]] || fail=1
done
exit "$fail"
