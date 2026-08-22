#!/usr/bin/env bash
# Convenience wrapper: start the container and drop into it.
set -euo pipefail
K="$(dirname -- "${BASH_SOURCE[0]}")/bin/kestrel"
"$K" start
exec "$K" enter
