### Repository URL

https://github.com/tcballard/omarchy-agentwire

### Category

Developer Tools

### Tags

AI, Bar, Quickshell

### Suggest a missing tag

_No response_

### Maintainer notes

AgentWire is an x86-64 Omarchy Quattro service and bar widget. Enabling it starts the bundled AgentWire inspector as the current user on the fixed numeric loopback address `127.0.0.1:4777`. It writes owner-only runtime state and recording traces below the user's XDG directories. Copying a recording command to the clipboard, opening the browser inspector, and opening the trace folder are explicit user actions.

Runtime requirements are x86-64 Omarchy with a compatible Quattro shell and Omarchy's existing `bash`, `wl-copy`, and `xdg-open` commands. The plugin adds no packages or system services, changes no system configuration or client configuration, requires no credentials or privilege escalation, and performs no non-loopback runtime network access.

The repository includes a 2,790,456-byte x86-64 ELF because the zero-setup plugin bundles AgentWire. Its SHA-256 is `26701637c0169e76e1cce978592a85861ec9b6dd8ac62062f42c3250bb6f8ec9`. CI rebuilds it from AgentWire commit `f4a19d85cbab302fd0c6bf271465ac1d2f69656d` with Rust 1.98.0, compares it byte-for-byte, and verifies the committed digest.

A pre-submission marketplace dry run against plugin commit `86f8e47365fdaca96f79cf08ca515675f31a6fe7` passed Quattro compatibility and requested manual security review. The bundled executable is expected. The scan also reported CI/development scripts that fetch AgentWire or Omarchy before executing their validators. Those scripts reject anything except a lowercase 40-character SHA, perform a detached checkout, confirm exact HEAD equality and a clean tree, and only then execute the checked-out validator or build. These commit references and dry-run results will be updated to the final repository HEAD before issue creation.

The plugin CI run for the preflight commit passed: https://github.com/tcballard/omarchy-agentwire/actions/runs/33388977416

### Submission checklist

- [x] The repository is public and contains installation and removal instructions.
- [x] I have documented the plugin license and any external dependencies.
- [x] I confirm that I own or have permission to submit this plugin and its preview assets.
- [x] The plugin does not overwrite user configuration without explicit consent.
- [x] I understand that approval is for listing and is not a security review.
