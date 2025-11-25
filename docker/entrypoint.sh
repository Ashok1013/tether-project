#!/usr/bin/env bash
set -euo pipefail

# If DEV env var is set to 1 -> open interactive shell (dev mode)
if [ "${DEV}" = "1" ] || [ "$1" = "dev" ]; then
  echo "Starting development shell as $(id -un)"
  exec bash
fi

# Otherwise run build step non-interactively
# Expect /workspace to contain source (user should mount repository there)
if [ -d "/workspace" ]; then
  cd /workspace
fi

# If invoked with explicit command, run it
if [ "$#" -gt 0 ]; then
  exec "$@"
fi

# Default: run wheel builder
exec /usr/local/bin/build_wheel.sh
