#!/usr/bin/env bash
# Convenience wrapper. Same as: kestrel build
set -euo pipefail
exec "$(dirname -- "${BASH_SOURCE[0]}")/bin/kestrel" build "$@"
