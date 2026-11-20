#!/usr/bin/env bash
# Builds libflacidal.so for the three Android ABIs from a FLACidal Core
# checkout and copies them into android/app/src/main/jniLibs.
#
# Usage: tool/build_core.sh <path-to-flacidal-core-checkout>
#
# The checkout must sit exactly on the tag pinned in CORE_VERSION, and that
# tag may never be older than MIN_CORE. Needs the Android NDK (ANDROID_NDK, or
# ANDROID_HOME / /opt/android-sdk with an ndk folder) and a Go toolchain.
set -euo pipefail

MIN_CORE="v0.31.0"

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CORE_DIR="${1:-}"

if [[ -z "$CORE_DIR" || ! -d "$CORE_DIR/.git" ]]; then
  echo "Usage: tool/build_core.sh <path-to-flacidal-core-checkout>" >&2
  exit 2
fi

WANT="$(tr -d '[:space:]' < "$ROOT/CORE_VERSION")"

# Refuse anything older than MIN_CORE (sort -V puts the older one first).
if [[ "$(printf '%s\n%s\n' "$MIN_CORE" "$WANT" | sort -V | head -1)" != "$MIN_CORE" ]]; then
  echo "CORE_VERSION is $WANT but Core $MIN_CORE or newer is required." >&2
  exit 1
fi

HAVE="$(git -C "$CORE_DIR" describe --tags --exact-match 2>/dev/null || true)"
if [[ "$HAVE" != "$WANT" ]]; then
  echo "Core checkout is at '${HAVE:-no tag}', expected $WANT (see CORE_VERSION)." >&2
  echo "Run: git -C $CORE_DIR checkout $WANT" >&2
  exit 1
fi

if [[ -z "${ANDROID_NDK:-}" ]]; then
  SDK="${ANDROID_HOME:-/opt/android-sdk}"
  ANDROID_NDK="$(find "$SDK/ndk" -maxdepth 1 -mindepth 1 -type d 2>/dev/null | sort -V | tail -1 || true)"
fi
if [[ -z "${ANDROID_NDK:-}" || ! -d "$ANDROID_NDK" ]]; then
  echo "Android NDK not found. Set ANDROID_NDK or install one under \$ANDROID_HOME/ndk." >&2
  exit 1
fi
export ANDROID_NDK

make -C "$CORE_DIR" android-arm64 android-arm android-x86_64

JNI="$ROOT/android/app/src/main/jniLibs"
for pair in arm64-v8a armeabi-v7a x86_64; do
  mkdir -p "$JNI/$pair"
  cp "$CORE_DIR/build/android/$pair/libflacidal.so" "$JNI/$pair/"
done
echo "Core $WANT built into $JNI"
