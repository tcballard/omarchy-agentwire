#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
source "$ROOT/scripts/contract-revisions.sh"
[[ $OMARCHY_REVISION =~ ^[0-9a-f]{40}$ ]] || { echo "invalid Omarchy revision" >&2; exit 1; }

TEMP_DIR=""
cleanup() { [[ -z $TEMP_DIR || ! -d $TEMP_DIR ]] || rm -rf -- "$TEMP_DIR"; }
trap cleanup EXIT

if [[ -n ${OMARCHY_PATH:-} ]]; then
  UPSTREAM=$(cd -- "$OMARCHY_PATH" && pwd)
else
  TEMP_DIR=$(mktemp -d)
  UPSTREAM="$TEMP_DIR/omarchy"
  git init -q "$UPSTREAM"
  git -C "$UPSTREAM" remote add origin https://github.com/basecamp/omarchy.git
  git -C "$UPSTREAM" fetch -q --depth=1 origin "$OMARCHY_REVISION"
  git -C "$UPSTREAM" checkout -q --detach FETCH_HEAD
fi

[[ $(git -C "$UPSTREAM" rev-parse HEAD) == "$OMARCHY_REVISION" ]] || { echo "Omarchy checkout is not pinned revision" >&2; exit 1; }
[[ -z $(git -C "$UPSTREAM" status --porcelain) ]] || { echo "Omarchy checkout is dirty" >&2; exit 1; }

PLUGIN_DEST="$UPSTREAM/shell/plugins/panels/agentwire"
mkdir -p "$PLUGIN_DEST"
git -C "$ROOT" archive HEAD | tar -x -C "$PLUGIN_DEST"
XDG_ROOT=$(mktemp -d)
trap 'rm -rf -- "$XDG_ROOT"; cleanup' EXIT
XDG_CONFIG_HOME="$XDG_ROOT/config" XDG_CACHE_HOME="$XDG_ROOT/cache" XDG_STATE_HOME="$XDG_ROOT/state" \
  "$UPSTREAM/test/shell.d/bar-widget-contract-test.sh"

