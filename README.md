# omarchy-agentwire

An [Omarchy](https://omarchy.org) Quattro service and bar widget for
[AgentWire](https://github.com/tcballard/AgentWire), the record/diff/replay tap
for coding-agent protocols. It shows the bounded inspector summary, opens a
keyboard-friendly detail panel, and jumps to the full browser inspector.

Version 0.2.0 targets Omarchy 4.0.0, 4.0.1, and compatible current Quattro
shell builds. It consumes AgentWire inspector summary API v1.

## Install

```bash
omarchy plugin add https://github.com/tcballard/omarchy-agentwire.git --enable
```

Then add **AgentWire** from the bar's *Development* category.

That is the entire setup on x86-64 Omarchy. The plugin includes its pinned
AgentWire runtime, starts the inspector hub as an enabled Omarchy service, and
uses private XDG runtime and state directories. There is no Cargo install,
systemd unit, background command, URL setting, or PATH change.

To record a client session, use the plugin's launcher in place of the agent
command:

```bash
~/.config/omarchy/plugins/io.github.tcballard.agentwire/bin/agentwire \
  record -- codex app-server
```

The native runtime exclusively creates a randomly named private trace under
`$XDG_STATE_HOME/agentwire/traces` (or `~/.local/state/agentwire/traces`) and
publishes it to the already-running inspector. Supplying `--trace` still lets
you choose a trace path. Starting a recording is an explicit user action;
installing and operating the Omarchy integration is automatic.

The loopback inspector API is protected by a per-hub 256-bit capability kept
in an owner-only XDG runtime file. The panel reads it through the native
launcher and the browser receives it in the URL fragment. Traces and inspector
responses are bounded; the hub restart budget and explicit action deadlines
prevent persistent crash loops or abandoned helper processes.

## Remove

```bash
omarchy plugin remove io.github.tcballard.agentwire
```

Omarchy disables and unloads the plugin before removing its checkout. Saved
traces remain in `$XDG_STATE_HOME/agentwire/traces` or
`~/.local/state/agentwire/traces` so removal does not destroy recordings; delete
that directory separately only when those traces are no longer needed.

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
`C` copies the ready-to-use `codex app-server` wrapper, `A` copies an ACP agent
template, `M` copies an MCP server template, `T` opens the private trace folder,
`R` refreshes, Tab switches panels, and Escape closes it. Replace
`YOUR_ACP_AGENT` or `YOUR_MCP_SERVER` in a template with the command selected by
your client. Copying a command does not start a recording or modify client
configuration.

Saved traces open from `$XDG_STATE_HOME/agentwire/traces` or the fallback
`~/.local/state/agentwire/traces`.

## Runtime requirements and permissions

- Requires x86-64 Omarchy with a compatible Quattro shell. The bundled
  AgentWire executable does not currently support ARM systems.
- Uses Omarchy's existing `/usr/bin/bash`, `/usr/bin/wl-copy`, and
  `/usr/bin/xdg-open` for the explicit copy-command and open-trace-folder
  actions. The attested runtime opens each action helper without following
  symlinks, verifies its root ownership and non-writable executable mode, and
  executes that exact opened object with a sanitized `PATH`. It does not add
  system packages or change system configuration.
- Runs as unsandboxed user code. When enabled, it starts the bundled AgentWire
  child process, binds `127.0.0.1:4777`, and writes owner-only runtime state and
  traces below the user's XDG directories.
- Network activity is limited to the loopback inspector. Opening the inspector,
  writing a command to the clipboard, and opening the trace folder happen only
  after the corresponding user action.
- Requires no `sudo`, `pkexec`, systemd unit, credentials, or external service.

## Configuration

The native service owns `http://127.0.0.1:4777`; it is intentionally not a
user setting. `pollIntervalMs` defaults to 2000 and is bounded to 250–60000 ms.
Failed polls back off to 30 seconds.

The widget requests only `/api/summary`, verifies the final response URL and
JSON media type for every HTTP response, rejects responses over 64 KiB of
characters, and uses a five-second timeout. XMLHttpRequest implementations may
buffer some or all of a response before the size check can abort it; AgentWire's
summary itself is deliberately bounded.

The loopback restriction limits exposure but does not make every local process
trusted. A malicious loopback service can answer or redirect a request before
the widget rejects the final URL. The bundled executable is rebuilt from the
pinned AgentWire revision and compared byte-for-byte in CI. See
[SECURITY.md](SECURITY.md).

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
