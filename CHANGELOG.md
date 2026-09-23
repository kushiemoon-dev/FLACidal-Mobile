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

## v0.8.0-beta.10 — 2026-08-27

### New features
- **Self-hosted priority endpoints (Tidal/Qobuz/Amazon)** — same fix as [FLACidal v4.17.0](https://github.com/kushiemoon-dev/FLACidal/releases/tag/v4.17.0). Until now the setting existed on desktop but wasn't wired to anything on any platform, so self-host just sat there unused while the public pool took all the traffic and got rate-limited. Mobile gets the config field for the first time here — Settings now has a self-host endpoints section per source. Root cause and pool rework live in [flacidal-core v0.20.0](https://github.com/kushiemoon-dev/flacidal-core/releases/tag/v0.20.0).

### Fixes
- Silent-failure bug where saving Settings could fail with no error shown at all if `FlacCore` hadn't finished initializing.

### Known limitation
The config round-trip (setting an endpoint → it actually reaching the download engine) hasn't been confirmed on a real device yet — this build is a test release specifically for that. No status/health display for self-host on mobile yet either (desktop-only for now).
