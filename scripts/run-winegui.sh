#!/usr/bin/env bash
set -euo pipefail

if ! command -v winecfg >/dev/null 2>&1; then
  echo "winecfg was not found. Run .devcontainer/install-winehq.sh first." >&2
  exit 1
fi

if [ -n "${DISPLAY:-}" ]; then
  exec winecfg
fi

XVFB_DISPLAY=":99"
Xvfb "$XVFB_DISPLAY" -screen 0 1280x720x24 >/tmp/xvfb.log 2>&1 &
XVFB_PID=$!
trap 'kill "$XVFB_PID" >/dev/null 2>&1 || true' EXIT

export DISPLAY="$XVFB_DISPLAY"
exec winecfg
