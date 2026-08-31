# omarchy-agentwire

An [Omarchy](https://omarchy.org) Quattro bar widget for
[AgentWire](https://github.com/tcballard/AgentWire), the record/diff/replay tap
for coding-agent protocols. It shows the bounded inspector summary, opens a
keyboard-friendly detail panel, and jumps to the full browser inspector.

Version 0.2.0 targets Omarchy 4.0.0, 4.0.1, and compatible current Quattro
shell builds. It consumes AgentWire inspector summary API v1.

## Requirements

Install AgentWire from GitHub; it is not yet available from crates.io and
does not yet ship prebuilt binaries:

```bash
cargo install --locked --git https://github.com/tcballard/AgentWire
```

Start either a live recording or a saved-trace inspector:

```bash
agentwire record --ui -- codex app-server
agentwire serve some-trace.jsonl
```

## Install

```bash
omarchy plugin add https://github.com/tcballard/omarchy-agentwire.git --enable
```

Then add **AgentWire** from the bar's *Development* category.

## States and controls

- `Recording` means the inspector owns a live trace that has not ended.
- `Served trace` means a saved, incomplete trace is being viewed; it is not a
  claim that a recording process is active.
- `Completed` includes the signed exit status when AgentWire captured one.
- `Connecting`, `offline`, `unavailable`, `incompatible`, `limited`, and
  `misconfigured` are distinct so transport, contract, and configuration
  failures are not mistaken for an idle session.

Left-click opens the panel, middle-click refreshes immediately, and right-click
opens the browser inspector. In the panel, Enter or `O` opens the inspector,
`R` refreshes, Tab switches panels, and Escape closes it.

## Configuration

`inspectorUrl` defaults to `http://127.0.0.1:4777`. Only numeric loopback
origins (`127.0.0.1` or `[::1]`) are accepted. `pollIntervalMs` defaults to
2000 and is bounded to 250–60000 ms. Failed polls back off to 30 seconds.

The widget requests only `/api/summary`, verifies the final response URL and
JSON media type for every HTTP response, rejects responses over 64 KiB of
characters, and uses a five-second timeout. XMLHttpRequest implementations may
buffer some or all of a response before the size check can abort it; AgentWire's
summary itself is deliberately bounded.

The loopback restriction limits exposure but does not make every local process
trusted. A malicious loopback service can answer or redirect a request before
the widget rejects the final URL. See [SECURITY.md](SECURITY.md).

## Development and release checks

```bash
node --test tests/*.test.cjs
scripts/check-agentwire-contract.sh
scripts/check-release.sh
scripts/check-qml-runtime.sh
```

The last command requires Quickshell and a Wayland compositor. CI runs the
official pinned Omarchy bar-widget fixture under headless Weston. See
[docs/RELEASING.md](docs/RELEASING.md) for the coordinated release order and
manual runtime matrix.

## License

MIT
