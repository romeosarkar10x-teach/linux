#!/usr/bin/env bash
# setup.sh -- seeds /labs/01-shell-and-terminal/05-readline
#
# Artifacts -> exercises:
#   deck-3-structural-strain-sampler-output-2187-06.log  -> ex 5, 8, 11 (a path long
#        enough that retyping it is a real cost; the point of Alt-. and Tab)
#   deck-3-structural-strain-sampler-output-2187-05.log  -> ex 9 (a sibling whose name
#        shares a long prefix, so Tab must ambiguate)
#   readings/                                            -> ex 9 (several files sharing prefixes)
#
# Idempotent: rewrites its own artifacts, creates nothing outside LAB.
set -euo pipefail

LAB="/labs/01-shell-and-terminal/05-readline"
mkdir -p "$LAB/readings"
cd "$LAB"

cat > deck-3-structural-strain-sampler-output-2187-06.log <<'EOF'
2187-06-01 00:00  deck3.bay2.strain  0.41
2187-06-01 00:06  deck3.bay2.strain  0.41
2187-06-01 00:12  deck3.bay2.strain  0.42
EOF

cat > deck-3-structural-strain-sampler-output-2187-05.log <<'EOF'
2187-05-01 00:00  deck3.bay2.strain  0.39
2187-05-01 00:06  deck3.bay2.strain  0.40
EOF

for f in strain-bay1 strain-bay2 strain-bay3 stress-bay1 stress-bay2; do
    printf '%s sample set\n' "$f" > "readings/$f.txt"
done

echo "seeded $LAB"
