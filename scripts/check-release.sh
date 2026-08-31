#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
source "$ROOT/scripts/contract-revisions.sh"
[[ -z $(git -C "$ROOT" status --porcelain) ]] || { echo "plugin checkout is dirty" >&2; exit 1; }
[[ $OMARCHY_REVISION =~ ^[0-9a-f]{40}$ && $AGENTWIRE_REVISION =~ ^[0-9a-f]{40}$ ]] || { echo "contract revisions must be lowercase 40-character SHAs" >&2; exit 1; }

TEMP_DIR=$(mktemp -d)
cleanup() { rm -rf -- "$TEMP_DIR"; }
trap cleanup EXIT

if [[ -n ${OMARCHY_PATH:-} ]]; then
  UPSTREAM=$(cd -- "$OMARCHY_PATH" && pwd)
else
  UPSTREAM="$TEMP_DIR/omarchy"
  git init -q "$UPSTREAM"
  git -C "$UPSTREAM" remote add origin https://github.com/basecamp/omarchy.git
  git -C "$UPSTREAM" fetch -q --depth=1 origin "$OMARCHY_REVISION"
  git -C "$UPSTREAM" checkout -q --detach FETCH_HEAD
fi
[[ $(git -C "$UPSTREAM" rev-parse HEAD) == "$OMARCHY_REVISION" ]] || { echo "Omarchy checkout is not pinned revision" >&2; exit 1; }
[[ -z $(git -C "$UPSTREAM" status --porcelain) ]] || { echo "Omarchy checkout is dirty" >&2; exit 1; }

node --test "$ROOT/tests"/*.test.cjs
"$ROOT/scripts/check-agentwire-contract.sh"
"$UPSTREAM/bin/omarchy-plugin-validate" "$ROOT"
node "$ROOT/scripts/check-plain-text.cjs"
jq -e '.schemaVersion == 1 and .version == "0.2.0" and .entryPoints.service == "Service.qml" and .entryPoints.barWidget == "Panel.qml"' "$ROOT/manifest.json" >/dev/null

FIRST="$TEMP_DIR/first"; SECOND="$TEMP_DIR/second"
mkdir -p "$FIRST" "$SECOND"
"$ROOT/scripts/build-release.sh" "$FIRST" HEAD >/dev/null
"$ROOT/scripts/build-release.sh" "$SECOND" HEAD >/dev/null
cmp "$FIRST/omarchy-agentwire-v0.2.0.tar.gz" "$SECOND/omarchy-agentwire-v0.2.0.tar.gz"
mkdir -p "$TEMP_DIR/extracted"
tar -xzf "$FIRST/omarchy-agentwire-v0.2.0.tar.gz" -C "$TEMP_DIR/extracted"
"$UPSTREAM/bin/omarchy-plugin-validate" "$TEMP_DIR/extracted/io.github.tcballard.agentwire"
echo "release contract: ok"
