#!/usr/bin/env bash
# Convenience wrapper. Same as: kestrel reset <chapter>/<lesson>
set -euo pipefail
exec "$(dirname -- "${BASH_SOURCE[0]}")/bin/kestrel" reset "$@"
