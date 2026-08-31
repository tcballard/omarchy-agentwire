# Changelog

## 0.2.0 — unreleased

- Move to Quattro-native service and bar-widget entry points.
- Bundle the pinned x86-64 AgentWire runtime and start its stable inspector hub
  automatically when the plugin is enabled.
- Add an XDG-native launcher that creates private traces and publishes live
  state without Cargo, systemd, URL, or PATH setup.
- Add a native panel action and keyboard shortcut for copying the installed
  Codex App Server wrapper command without starting a recording or changing
  client configuration.
- Expand native recording actions with explicit ACP and MCP command templates,
  plus direct access to the private XDG trace folder.
- Consume AgentWire's bounded inspector summary API v1 instead of downloading
  and reducing the full event stream.
- Distinguish recording, served, completed, limited, unavailable,
  incompatible, misconfigured, offline, and connecting states.
- Add fixed loopback routing, final-response and media-type checks,
  single-flight polling, timeout, response limit, and bounded backoff.
- Add pinned cross-repository contract tests, byte-for-byte bundled-runtime
  provenance, official Omarchy validation, Quickshell runtime CI,
  deterministic release assets, and release runbooks.
