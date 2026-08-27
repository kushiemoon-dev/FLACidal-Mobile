# Changelog

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
