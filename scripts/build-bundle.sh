#!/usr/bin/env bash
# Build the OpenWorker install bundle: a .zip holding just the persona as
# manifest.md — the exact shape OpenWorker's "Install a coworker → .zip" accepts.
# Usage: bash scripts/build-bundle.sh [output.zip]
set -euo pipefail
REPO="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$REPO/${1:-career-ops-coworker.zip}"
VER="$(grep -m1 -E '^version:' "$REPO/career-ops.md" | sed 's/version:[[:space:]]*//; s/["'"'"']//g' || true)"
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
cp "$REPO/career-ops.md" "$TMP/manifest.md"
rm -f "$OUT"
( cd "$TMP" && zip -q -X "$OUT" manifest.md )
echo "built ${OUT##*/} (persona v${VER:-?}) — OpenWorker → Install a coworker → .zip"
