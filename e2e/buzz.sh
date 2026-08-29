#!/usr/bin/env bash
# Acceptance lane: validate, lint, load, open, and capture Flow Boundary in the
# shared production-parity Omarchy shell.
# RTM: REQ-FB-007, REQ-FB-008
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
"$ROOT/scripts/rig-verify.sh" "$ROOT"
"$ROOT/scripts/rig-render.sh" "$ROOT" "$ROOT/preview.png"
test -s "$ROOT/preview.png"
