#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
VERSION=$(jq -r .version "$ROOT/manifest.json")
OUTPUT=${1:-"$ROOT/dist"}
REF=${2:-HEAD}
mkdir -p "$OUTPUT"
ARCHIVE="$OUTPUT/omarchy-agentwire-v$VERSION.tar.gz"
git -C "$ROOT" archive --format=tar --prefix=io.github.tcballard.agentwire/ "$REF" | gzip -n -9 >"$ARCHIVE"
(cd -- "$OUTPUT" && sha256sum "$(basename -- "$ARCHIVE")" >"$(basename -- "$ARCHIVE").sha256")
printf '%s\n' "$ARCHIVE"
