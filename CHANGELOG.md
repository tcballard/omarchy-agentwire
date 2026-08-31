# Changelog

## 0.2.0 — unreleased

- Move to one Quattro-native `Panel.qml` bar-widget entry point.
- Consume AgentWire's bounded inspector summary API v1 instead of downloading
  and reducing the full event stream.
- Distinguish recording, served, completed, limited, unavailable,
  incompatible, misconfigured, offline, and connecting states.
- Add strict loopback URL handling, final-response and media-type checks,
  single-flight polling, timeout, response limit, and bounded backoff.
- Add pinned cross-repository contract tests, official Omarchy validation,
  Quickshell runtime CI, deterministic release assets, and release runbooks.
