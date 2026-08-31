#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
source "$ROOT/scripts/contract-revisions.sh"
[[ $AGENTWIRE_REVISION =~ ^[0-9a-f]{40}$ ]] || { echo "invalid AgentWire revision" >&2; exit 1; }

TEMP_DIR=$(mktemp -d)
cleanup() { [[ ! -d $TEMP_DIR ]] || rm -rf -- "$TEMP_DIR"; }
trap cleanup EXIT

if [[ -n ${AGENTWIRE_PATH:-} ]]; then
  CORE=$(cd -- "$AGENTWIRE_PATH" && pwd)
else
  CORE="$TEMP_DIR/AgentWire"
  git init -q "$CORE"
  git -C "$CORE" remote add origin https://github.com/tcballard/AgentWire.git
  git -C "$CORE" fetch -q --depth=1 origin "$AGENTWIRE_REVISION"
  git -C "$CORE" checkout -q --detach FETCH_HEAD
fi

[[ $(git -C "$CORE" rev-parse HEAD) == "$AGENTWIRE_REVISION" ]] || { echo "AgentWire checkout is not pinned revision" >&2; exit 1; }
[[ -z $(git -C "$CORE" status --porcelain) ]] || { echo "AgentWire checkout is dirty" >&2; exit 1; }
node "$ROOT/scripts/check-agentwire-contract.cjs" "$CORE/contracts/inspector-summary-v1.example.json"
cargo "+$AGENTWIRE_RUST_TOOLCHAIN" build --release --locked \
  --manifest-path "$CORE/Cargo.toml" --target-dir "$TEMP_DIR/target"
cmp "$ROOT/bin/agentwire-x86_64" "$TEMP_DIR/target/release/agentwire"
(cd -- "$ROOT" && sha256sum -c bin/agentwire-x86_64.sha256)
echo "AgentWire bundled-runtime provenance: ok"
