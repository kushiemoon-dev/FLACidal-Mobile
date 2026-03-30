# FLACidal Mobile

Cross-platform mobile app for downloading lossless FLAC music from Tidal.
Built with Flutter + Go FFI.

## Features

- Paste Tidal URLs (album, playlist, track) to download FLAC
- URL resolution: paste Spotify/Apple Music URLs -> auto-resolve to Tidal
- Real-time download queue with pause/resume
- Search Tidal (tracks, albums, artists)
- Library browser with metadata viewer
- Lyrics (fetch + embed in FLAC)
- Format conversion (MP3, AAC, Opus)
- Extension system for additional music sources
- Qobuz support
- Material 3 dark/light theme with 16 accent colors
- Share intent handler (share URLs from browser -> auto-download)
- Downloads to public Music folder

## Requirements

- Android 5.0+ (arm64, arm, x86_64)
- iOS 16+ (arm64) -- requires sideloading via AltStore

## Build

### Prerequisites
- Flutter 3.41+
- Go 1.23+
- Android NDK r29 (for Go cross-compilation)

### Android
```bash
# Build Go shared libraries
cd ../flacidal-core
make android-arm64 android-arm android-x86_64
make install-android

# Build Flutter APK
cd ../flacidal-mobile
flutter build apk --release
```

### iOS (requires macOS + Xcode)
```bash
cd ../flacidal-core
make ios
make install-ios

cd ../flacidal-mobile
flutter build ipa --no-codesign
```

## Distribution

- **Android**: APK from [GitHub Releases](../../releases)
- **iOS**: IPA via AltStore -- add this source URL: `https://kushiemoon-dev.github.io/flacidal-mobile/altstore/apps.json`

## Architecture

- `flacidal-core/` -- Shared Go module (Tidal API, downloader, metadata, extensions)
- `flacidal-mobile/` -- Flutter app with Go FFI bindings
- `flacidal-desktop/` -- Desktop app (Wails + Svelte)

## License

Private
