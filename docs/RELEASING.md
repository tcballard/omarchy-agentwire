# Release runbook

## Coordinated order

1. Land the AgentWire inspector-summary PR on `main` and record its exact
   public commit SHA. If squash or rebase changes it, update
   `scripts/contract-revisions.sh`, rerun every gate, and update the plugin PR.
2. Confirm the plugin's `AGENTWIRE_REVISION` fetches publicly and the canonical
   contract check passes.
3. Require green `Release contract` and `Quickshell runtime contract` checks on
   the plugin PR, then complete the hands-on matrix below.
4. Merge the plugin PR to protected `main`.
5. Create a signed or annotated `v0.2.0` tag at the reviewed `main` commit and
   push it. The tag workflow builds and compares deterministic assets, verifies
   the peeled remote tag target, creates a draft release, uploads the archive
   and checksum, then publishes it.

Do not tag AgentWire as part of this plugin release. AgentWire's `v*` workflow
has its own binary and crate publication consequences.

## Required repository policy

- Protect `main`; require `Release contract` and `Quickshell runtime contract`.
- Disallow force pushes and deletion of `main`.
- Protect `v*` tags from update or deletion.
- Enable immutable releases when the repository supports it.
- Keep workflow actions pinned to reviewed full commit SHAs. Only the publish
  job receives `contents: write`; it never reruns repository tests or a fetched
  validator.

## Hands-on runtime matrix

The automated Quickshell fixture catches entry-point and shell-contract errors,
but it does not replace visual and interaction checks on real Omarchy systems.
Record evidence for:

| Target | Horizontal bar | Vertical bar | Keyboard | Live → complete | Served trace | Offline/recovery |
|---|---:|---:|---:|---:|---:|---:|
| Omarchy 4.0.0 | ☐ | ☐ | ☐ | ☐ | ☐ | ☐ |
| Omarchy 4.0.1 | ☐ | ☐ | ☐ | ☐ | ☐ | ☐ |
| Current compatible Quattro | ☐ | ☐ | ☐ | ☐ | ☐ | ☐ |

Also verify right-click opens the inspector, middle-click refreshes, a malformed
URL shows `misconfigured`, API-version drift shows `incompatible`, and dynamic
methods containing markup characters render literally.

## Commands

```bash
scripts/check-release.sh
scripts/check-qml-runtime.sh
scripts/build-release.sh dist HEAD
sha256sum -c dist/omarchy-agentwire-v0.2.0.tar.gz.sha256
```

The release is blocked until the AgentWire dependency is on `main`, repository
protections are active, both automated checks pass, the hands-on matrix is
complete, and a maintainer with publication authority approves the tag.
