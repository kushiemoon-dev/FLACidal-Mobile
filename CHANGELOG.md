# Changelog

## v0.8.0-beta.10 — 2026-08-27

### New features
- **Self-hosted priority endpoints (Tidal/Qobuz/Amazon)** — same fix as [FLACidal v4.17.0](https://github.com/kushiemoon-dev/FLACidal/releases/tag/v4.17.0). Until now the setting existed on desktop but wasn't wired to anything on any platform, so self-host just sat there unused while the public pool took all the traffic and got rate-limited. Mobile gets the config field for the first time here — Settings now has a self-host endpoints section per source. Root cause and pool rework live in [flacidal-core v0.20.0](https://github.com/kushiemoon-dev/flacidal-core/releases/tag/v0.20.0).

### Fixes
- Silent-failure bug where saving Settings could fail with no error shown at all if `FlacCore` hadn't finished initializing.

### Known limitation
The config round-trip (setting an endpoint → it actually reaching the download engine) hasn't been confirmed on a real device yet — this build is a test release specifically for that. No status/health display for self-host on mobile yet either (desktop-only for now).
