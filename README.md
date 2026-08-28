<div align="center">

<img src="docs/banner.png" alt="FLACidal" width="600">

### FLACidal Mobile

**Grab lossless FLAC tracks from Tidal & Qobuz straight onto your phone**

[![GitHub Release](https://img.shields.io/github/v/release/kushiemoon-dev/flacidal-mobile?style=flat-square&color=e5a00d)](https://github.com/kushiemoon-dev/flacidal-mobile/releases/latest)
[![Stars](https://img.shields.io/github/stars/kushiemoon-dev/flacidal-mobile?style=flat-square&color=a855f7)](https://github.com/kushiemoon-dev/flacidal-mobile/stargazers)
[![License](https://img.shields.io/badge/License-MIT-gray?style=flat-square)](LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-3.41+-02569B?style=flat-square&logo=flutter&logoColor=white)](https://flutter.dev)
[![Go](https://img.shields.io/badge/Go-1.26+-00ADD8?style=flat-square&logo=go&logoColor=white)](https://go.dev)

![Android](https://img.shields.io/badge/Android-5.0+-3DDC84?style=flat-square&logo=android&logoColor=white)
![iOS](https://img.shields.io/badge/iOS-planned-555555?style=flat-square&logo=apple&logoColor=white)

</div>

---

<div align="center">
<img src="docs/screenshot.jpg" alt="FLACidal Mobile" width="300">
<img src="docs/screenshot-search.png" alt="FLACidal Mobile search results" width="300">
<img src="docs/screenshot-library.png" alt="FLACidal Mobile library" width="300">
<img src="docs/screenshot-settings.png" alt="FLACidal Mobile settings" width="300">
</div>

---

## Overview

**FLACidal Mobile** is the on-the-go counterpart to [FLACidal Desktop](https://github.com/kushiemoon-dev/FLACidal). Drop in a Tidal URL, pick your tracks, and Hi-Res or Lossless FLAC lands straight on your device, no account needed.

Flutter handles the UI, while a shared Go backend reached through FFI drives the entire download pipeline.

---

## Features

- **Hi-Res & Lossless** audio, up to 24-bit/192 kHz straight from Tidal and Qobuz
- **Paste & Download**: drop in any Tidal URL, whether it's an album, playlist, track, or artist page
- **URL Resolution** auto-resolves links from other platforms to Tidal through Odesli
- **Search** lets you switch providers and sort results while browsing Tidal and Qobuz
- A **Real-time Queue** showing download speed, ETA, and per-track percentage live
- **Background Downloads**: a foreground service keeps transfers going even after the app is closed
- A **Library** with albums grouped by disc number, filterable by source/quality/format, and "Already in Library" flagging
- **Metadata Editing** right in the app, covering title, artist, album, composer, genre, ISRC, and more
- **Cover Art** extraction, saving embedded artwork as a standalone .jpg
- **Lyrics** support: grab synced or plain lyrics, embed them in the FLAC, or export as .lrc
- **Re-enrich** to refresh and re-embed metadata without touching the audio again
- **Format Conversion** from FLAC into MP3, AAC, or Opus, with all metadata kept intact
- Complete **MP3 Tagging**: ID3v2 tags including cover art, lyrics, and composer
- **Artist Tag Modes** for multi-artist tracks, choosing joined or split Vorbis ARTIST tags
- **Singles/Albums Folders**: singles and albums sort into separate folders automatically
- An **Extension System** for adding community extensions that pull in more music sources
- **Audio Analysis** flags upscaled files via spectrum analysis, with a confidence score attached
- A **Custom Theme** matching the desktop app's dark theme, with the Outfit font and accent color options
- **Share Intent**: share a Tidal link from your browser and downloading starts right away

---

## Download

**[Download Latest APK](https://github.com/kushiemoon-dev/flacidal-mobile/releases/latest)**

| Platform | File | Install |
|----------|------|---------|
| Android | `FLACidal.apk` | Direct install |

> **iOS:** The codebase already supports iOS, but nobody with an Apple Developer account has stepped up yet to handle code signing and IPA distribution. Want to help? Check [Contributing](#contributing).

---

## Usage

1. Launch **FLACidal Mobile**
2. Drop in a Tidal URL (or share one straight from your browser)
3. Pick your tracks and hit **Download**
4. Files land in `Music/FLACidal/` on your device

### Supported Content

| Source | Types |
|--------|-------|
| **Tidal** | Album · Playlist · Track · Mix · Artist |
| **Qobuz** | Album · Playlist · Track |
| **Other** | Any music URL (resolved via Odesli) |

---

## Architecture

```
flacidal-mobile/         Flutter app
├── lib/
│   ├── core/            FFI bridge + URL resolver
│   ├── pages/           14 screens
│   ├── widgets/         8 reusable components
│   ├── providers/       Riverpod state management
│   ├── theme/           Custom dark theme
│   └── router/          GoRouter navigation
│
flacidal-core/           Shared Go backend (compiled as .so/.a)
```

The Go backend handles networking, downloads, metadata, and storage, while Flutter takes care of the UI. The two talk to each other via JSON-RPC over FFI.

---

## Build from Source

**Requirements:** Flutter 3.41+, Go 1.26+, Android NDK r29

```bash
# 1. Build Go shared libraries
cd flacidal-core
make android-arm64
make install-android

# 2. Build Flutter APK
cd ../flacidal-mobile
flutter build apk --release
```

### iOS (requires macOS + Xcode)

```bash
cd flacidal-core
make ios
make install-ios

cd ../flacidal-mobile
flutter build ipa --no-codesign
```

---

## Configuration

| Setting | Default | Options |
|---------|---------|---------|
| Quality | `LOSSLESS` | `HI_RES_MAX` · `HI_RES_LOSSLESS` · `LOSSLESS` · `HIGH` |
| Format | `FLAC` | `FLAC` · `M4A` · `ALAC` |
| Folder structure | Flat | By Artist/Album · By Playlist · Flat · Singles/Albums |
| Artist tag mode | Joined | `joined` (single field) · `split` (multi-value Vorbis) |
| Theme | Dark | Dark · Light · System |
| Accent color | Pink | 12 presets |
| Font | Outfit | 16 options |

---

## FAQ

**Do I need a Tidal account?**
Nope, FLACidal handles authentication on its own.

**Where are files saved?**
On Android: `/storage/emulated/0/Music/FLACidal/`, and it's configurable from Settings.

**Is iOS supported?**
It already compiles for iOS, though Apple signing still needs a contributor. In the meantime, build it yourself with `flutter build ipa --no-codesign` and sideload it through AltStore/SideStore. Contributions are very welcome.

**Does it work in the background?**
It does: a foreground service keeps downloads going while the app sits minimized.

---

## Contributing

Contributions are welcome. Here's where extra hands would help most:

- **iOS build & signing**: needs someone with an Apple Developer account to set up code signing, TestFlight distribution, and the AltStore source. The Flutter + Go FFI codebase is already iOS-ready.
- **Bug reports**: file an issue with steps to reproduce.

---

## Star History

[![Star History](docs/star-history.svg)](https://github.com/kushiemoon-dev/flacidal-mobile/stargazers)

---

## Disclaimer

FLACidal Mobile exists strictly for **personal and educational purposes**. It has no affiliation with, endorsement from, or connection to Tidal, Qobuz, or any other streaming service. Making sure your usage stays within local laws and each platform's Terms of Service is entirely on you. The software is provided "as is" without warranty of any kind.

---

<div align="center">

**MIT License** · [Desktop App](https://github.com/kushiemoon-dev/FLACidal) · [Releases](https://github.com/kushiemoon-dev/flacidal-mobile/releases)

Built with ♥ by [KushieMoon](https://github.com/kushiemoon-dev)

</div>
