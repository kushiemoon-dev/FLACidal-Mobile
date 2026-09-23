# Changelog

## v0.8.0-beta.12: 2026-09-23

### New features
- **Automatic update checks and installs**: the app now checks for updates at cold start and on resume (throttled to once per 24h), comparing against every published release tag rather than just the newest, since this repo has no stable release yet. A user 3 or more releases behind is blocked with a full-screen prompt until they update; updating downloads the universal APK, verifies its SHA256 checksum, and triggers the system install intent. `AndroidManifest.xml` gained `REQUEST_INSTALL_PACKAGES`, required to trigger that install prompt.
- **Config export/import** (Settings > About): wired to the existing `exportConfig`/`importConfig` Core RPCs. Export picks a destination folder and writes a fixed filename; import picks a JSON file and refreshes the settings screen with the freshly written config.
- **Foreground service now starts on any active download queue**, not just while a screen is actively watching it: a container-level listener starts the service the moment the queue becomes non-empty and stops it once it fully drains, including the cold-start case where a persisted queue is restored before the app UI is even up.
- **About screen shows the real build version** instead of a hardcoded string, read via `package_info_plus`.
- **Core dependency bump to v0.21.1**: same fixes as [FLACidal v4.17.2](https://github.com/kushiemoon-dev/FLACidal/releases/tag/v4.17.2), a Tidal manifest gap that could blacklist a healthy endpoint, and a metadata endpoint failure that never surfaced on the Status page.

### Fixes
- **Config import silently overwrote stored Tidal, Soulseek and Qobuz credentials with blanks, with no warning**: a fresh export has them redacted, and import wrote that straight back without confirmation. Import also left the download-options provider stale, so a later option change would overwrite the just-imported values.
- **Download format picker offered conversion formats Android can't produce**: Android has no ffmpeg conversion path, so the picker is now restricted to FLAC only.
- **The convert dialog could still be opened without ffmpeg available** from the library page, the one entry point that hadn't been guarded yet; it now shows an unavailable message like the dedicated Conversion page already did.
- **Consecutive beta releases stopped installing as updates over the previous beta** (`INSTALL_FAILED_UPDATE_INCOMPATIBLE`): CI was generating a fresh, throwaway debug keystore on every run instead of reusing a persisted one, so each beta ended up signed with a different key.

## v0.8.0-beta.11 — 2026-08-27

### New features
- **Extensions permissions disclosure** — The extensions page now shows an extension's declared `permissions` (storage access, file deletion, library re-enrichment, etc.) before install/activation, on both the Installed and Browse tabs, so users can make informed decisions about which extensions to trust.
- **Update detection in Browse tab** — The Browse tab now distinguishes "Update available" from "Installed, up to date" for already-installed extensions by comparing the registry's version string against the locally installed version, matching desktop's behavior.
- **Core dependency bump to v0.21.0** — this build also pulls in [flacidal-core v0.21.0](https://github.com/kushiemoon-dev/flacidal-core/releases/tag/v0.21.0): the new metadata-extension capability (structured track metadata supplied by extension plugins) is what makes the permissions and update-badge UI above meaningful, and separately, embedded covers now always get fetched over the network and written to the tag whenever a download job has a `CoverURL`, even with zero metadata extensions installed — previously this never fetched. That cover-art change is a deliberate upstream behavior change and affects every mobile user, not just extension users.

### Fixes
- **Tapping Update on an extension left the same enabled button on screen with no feedback**: the Browse tab's trailing-widget logic checked for an available update before checking whether an install was already in flight, so the loading spinner was unreachable during an update (it only became true after the RPC finished), which also left no guard against a second concurrent install request for the same extension.

## v0.8.0-beta.10 — 2026-08-27

### New features
- **Self-hosted priority endpoints (Tidal/Qobuz/Amazon)** — same fix as [FLACidal v4.17.0](https://github.com/kushiemoon-dev/FLACidal/releases/tag/v4.17.0). Until now the setting existed on desktop but wasn't wired to anything on any platform, so self-host just sat there unused while the public pool took all the traffic and got rate-limited. Mobile gets the config field for the first time here — Settings now has a self-host endpoints section per source. Root cause and pool rework live in [flacidal-core v0.20.0](https://github.com/kushiemoon-dev/flacidal-core/releases/tag/v0.20.0).

### Fixes
- Silent-failure bug where saving Settings could fail with no error shown at all if `FlacCore` hadn't finished initializing.

### Known limitation
The config round-trip (setting an endpoint → it actually reaching the download engine) hasn't been confirmed on a real device yet — this build is a test release specifically for that. No status/health display for self-host on mobile yet either (desktop-only for now).

## v0.8.0-beta.9: 2026-08-21

### Fixes
- **Fetching or installing an extension froze the UI**: both calls went through a blocking native call on the Flutter UI isolate instead of the async goroutine+callback path. Now async, with a per-extension spinner shown during install and a guard against double-tapping install on the same extension.
- Native library synced with flacidal-core v0.19.0.

## v0.8.0-beta.8: 2026-08-12

### New features
- **Soulseek credentials UI**: username/password fields added to the Sources page, mirroring the existing Qobuz credentials pattern.

### Fixes
- Search filter row could overflow the screen; now wrapped in a horizontal scroll.
- Native library rebuilt against flacidal-core v0.18.0 (staged Tidal segmented downloads, an endpoint-pool 403 fix, ReplayGain, Dolby Atmos, and non-FLAC analysis, all landing here as a dependency bump).

## v0.8.0-beta.7: 2026-07-06

- Native library synced with a flacidal-core fix: a single unresponsive or offline Soulseek peer no longer sent a track straight to Tidal when other real candidates were sitting in the same search; the app now retries across the top 3 ranked results instead of giving up on the whole source after one dead peer.

## v0.8.0-beta.6: 2026-07-06

- Native library synced with two flacidal-core fixes: Soulseek's real failure reason is now surfaced instead of being hidden behind whichever proxy source's error happened to be shown last, and a genuinely unresponsive peer now fails fast (45s of no progress) instead of leaving the UI stuck for up to 5 minutes, while a slow but still-progressing transfer is no longer punished for taking its time.

## v0.8.0-beta.5: 2026-07-06

- Native library synced with three flacidal-core fixes found chasing a real end-to-end test: a login-scoped context was starving all searches after about 8 seconds, peers reporting a file size of 0 caused a divide-by-zero panic, and Windows-style path filenames weren't being stripped to a clean basename on Linux/Android.

## v0.8.0-beta.4: 2026-07-06

- Native library synced with a flacidal-core fix for a nil-context panic hit on every successful Soulseek download once it reached the file-transfer stage.

## v0.8.0-beta.3: 2026-07-06

- Native library synced with a flacidal-core fix: the Soulseek-first pre-pass was registered and prioritized but never actually invoked on mobile, so orchestrator wiring needed a fresh build to take effect.

## v0.8.0-beta.2: 2026-07-06

- Native library synced with a flacidal-core fix for existing installs missing Soulseek in their saved source-order config; it now gets prepended on migration.

## v0.8.0-beta.1: 2026-07-06

### New features
- **Native Soulseek wired in as a primary source**, reaching mobile parity with desktop's Soulseek support.

## v0.7.0: 2026-06-03

### Fixes
- **Tidal downloads were failing due to dead proxy endpoints**: fixed by rebuilding against flacidal-core v0.4.9, which carried live Tidal endpoints. The interim README warning about the outage was removed once this landed.

## v0.6.0: 2026-05-23

### New features
- **Deezer and Bandcamp support**: a new Deezer tab, URL support for both sources on the home screen, and a source-priority reorder option. The URL input's hint text was updated to mention both.

## v0.5.0: 2026-05-22

No functional changes in this release: version bump only.

## v0.4.7: 2026-05-18

Internal cleanup only: removed unused imports and dead fields across 4 pages, and replaced the boilerplate counter widget test with a platform-agnostic placeholder.

## v0.4.6: 2026-04-16

### Fixes
- **Qobuz connection test always showed "Unknown error" even when the connection worked**: `testQobuzConnection` wasn't unwrapping the `result["result"]` field Go responses are wrapped in.
- **Qobuz search results were queued through the Tidal download path**: now routed to `queueQobuzDownloads`.

## v0.4.5: 2026-04-15

No functional changes in this release: version bump only.

## v0.4.4: 2026-04-13

No functional changes in this release: version bump only.

## v0.4.3: 2026-04-13

No functional changes in this release: version bump only.

## v0.4.2: 2026-04-13

Build only: Go version bumped to 1.26 in CI.

## v0.4.1: 2026-04-13

No app functionality changed in this release: README showcase media was reworked (a broken demo GIF replaced with a clean screenshot slideshow, then an animated showcase video).

## v0.4.0: 2026-04-09

### New features
- **Metadata editing**, with cover art and lyrics saving and a re-enrich action.
- **Library enhancements**: filters, album grouping, and search sorting.
- **Extension store**: search, categories, and source management UI.
- **Audio playback**, a CSV import UI, and format conversion from the metadata bottom sheet.

## v0.3.0: 2026-04-04

### Fixes
- Qobuz credentials are now pre-populated in Settings instead of starting blank.

## v0.2.2: 2026-04-04

### New features
- **Qobuz downloads routed to their own RPC endpoint** instead of the Tidal-shaped one, which expected a different track format.

### Fixes
- A native FFI event pointer wasn't freed after Dart copied its string, risking a use-after-free with `NativeCallable.listener`.
- Quality picker offered invalid values; corrected to the real Tidal API options (`HI_RES`, `LOSSLESS`, `HIGH`), with `HI_RES` as the default instead of `LOSSLESS`.

## v0.2.1: 2026-04-03

Build only: iOS CI disabled (README updated with a call for iOS contributors); no Android-facing change.

## v0.2.0: 2026-04-03

### Fixes
- Search used a blocking FFI call, freezing the UI; switched to async.

## v0.1.0: 2026-03-30

Initial release. Android/iOS scaffold with FFI bindings to the Go backend, core screens (Home, Search, Queue, Library, Settings), and a custom dark theme matching desktop's visual identity. Content detail, history, lyrics, sources, conversion, and extensions pages; URL resolution and background downloads; app icon and CI/CD distribution workflows.
