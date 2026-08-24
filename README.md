# omarchy-agentwire

An [Omarchy](https://omarchy.org) bar widget for
[AgentWire](https://github.com/tcballard/AgentWire), the record/diff/replay
tap for coding-agent protocols (Codex App Server, ACP).

The widget polls the local AgentWire inspector and shows a live indicator
with the protocol event count while a recording session is running. Clicking
it opens a panel with the session summary — client/server message counts,
errors, the last method seen — and a link that opens the full browser
inspector.

Everything stays on your machine: the widget only reads the inspector's
loopback endpoint (`http://127.0.0.1:4777/api/events`) and makes no other
network requests.

## Requirements

- The `agentwire` CLI: `cargo install --locked agentwire`, or a binary from
  the [AgentWire releases](https://github.com/tcballard/AgentWire/releases).
- A running inspector: either a live recording session
  (`agentwire record --ui -- codex app-server`) or a served trace
  (`agentwire serve some-trace.jsonl`).

## Install

```bash
omarchy plugin add https://github.com/tcballard/omarchy-agentwire.git --enable
```

Then add the **AgentWire** widget (category *Development*) to your bar.

## Usage

- **Idle** (dim dot, `AW`): no inspector is listening on the configured
  address. Start a recording with `--ui` and the widget lights up on its own.
- **Recording** (green dot, `AW <n>`): a session is live; `n` is the protocol
  event count.
- **Finished** (grey dot with a count): the trace is still being served but
  the recorded session has ended.
- **Panel**: event totals per direction, error count, last method, and
  *Open inspector ↗* to jump to the full web inspector. Escape closes it.

## Configuration

Two properties at the top of `BarWidget.qml`:

- `inspectorUrl` (default `http://127.0.0.1:4777`) — match the `--ui` or
  `serve` address if you changed it.
- `pollIntervalMs` (default `2000`).

## Development

The polling and summary logic lives in `Model.js` and is exercised against
the real inspector API in AgentWire's repository. Validate the plugin
lifecycle on an Omarchy machine:

```bash
omarchy plugin validate "$HOME/.config/omarchy/plugins/io.github.tcballard.agentwire"
qmllint -I "$OMARCHY_PATH/shell" BarWidget.qml Panel.qml
```

The QML follows the documented plugin conventions (shared `moduleName`, the
panel loaded from the bar entry point, `opened`/`open()`/`close()`
forwarding, `PanelKeyCatcher` for Escape). If the shell's base-class API
differs from a freshly cloned built-in (`omarchy plugin clone omarchy.clock
--edit`), align with the clone.

## Removal

Disable the widget in the bar settings, then remove the plugin directory:

```bash
rm -rf "$HOME/.config/omarchy/plugins/io.github.tcballard.agentwire"
```

## License

MIT
