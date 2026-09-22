<h1 align="center">AgentWire for Omarchy</h1>

<p align="center">
  <a href="https://github.com/tcballard/omarchy-badges"><img src="https://raw.githubusercontent.com/tcballard/omarchy-badges/75975e5b5bf75e7ede3764bcd2950046f7abfe2c/badges/v1/omarchy-plugin.svg" alt="Built for Omarchy: Plugin" height="24"></a>
</p>

**See what your coding agent is doing.**

Keep AgentWire recording status and event counts in your Omarchy bar. Open a session summary, jump into the browser inspector and find saved traces when you need to understand an agent interaction.

## Everyday use

Add **AgentWire** from the bar’s Development category. Click for session details, right-click for the browser inspector, or use the panel to copy a recording command. Recording starts only when you run that command. [Recording your first session →](GUIDE.md#install)

## Install

x86-64 Omarchy with a compatible Quattro shell, Bash, wl-copy and xdg-open. The plugin bundles its pinned AgentWire runtime; no Rust build is required.

```bash
omarchy plugin add https://github.com/tcballard/omarchy-agentwire.git --enable
```

## Update and remove

Update:

```bash
omarchy plugin update io.github.tcballard.agentwire
```

Remove:

```bash
omarchy plugin remove io.github.tcballard.agentwire
```

## A few useful details

**v0.2.0.** ARM is not supported by the bundled executable. The local inspector starts when the plugin is enabled; saved traces remain after removal. [Requirements and permissions](GUIDE.md#runtime-requirements-and-permissions) · [Security](SECURITY.md)

Built around [AgentWire](https://github.com/tcballard/AgentWire), the record, diff and replay tool for coding-agent protocols.

[Usage and development guide](GUIDE.md) · [Report a bug](https://github.com/tcballard/omarchy-agentwire/issues)

[MIT licensed](LICENSE).

<!-- Preserve links to sections now in the guide. -->
<a id="configuration"></a>
<a id="development-and-release-checks"></a>
<a id="license"></a>
<a id="remove"></a>
<a id="runtime-requirements-and-permissions"></a>
<a id="states-and-controls"></a>

[Looking for the previous detailed sections? Open the full guide →](GUIDE.md)
