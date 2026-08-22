#!/usr/bin/env bash
# setup.sh -- seeds /labs/01-shell-and-terminal/07-incident-01
#
# CONTINUITY: _handoff/SCENARIOS.md section 2 and section 7 (Ch 1).
#   dorn's last session ends 2187-05-24 04:12  (epoch 6860261520).
#   Trace 1: a history file whose final line stops mid-word.
#   NOTHING here may suggest concealment. At Chapter 1 this reads as a tired
#   person whose session ended. See SCENARIOS.md section 3.
#
# Artifacts -> exercises:
#   dorn-bash-history           -> ex 1-6 (THE evidence; mode 444, must stay unmodified)
#   check-sample-integrity.sh   -> ex 5, 6 (FLAG); derives the token from the data file,
#                                  so reading the script reveals the method, not the answer
#   strain-2187-05.dat          -> ex 5, 6 (the file the truncated line names; passes)
#   strain-2187-04.dat          -> red herring; record count mismatch, fails loudly, no flag
#   strain-2187-03.dat          -> red herring; same
#
# NO DECOY FLAGS. The wrong .dat files print an integrity failure and nothing else.
#
# Idempotent: rewrites its own artifacts, creates nothing outside LAB.
set -euo pipefail

LAB="/labs/01-shell-and-terminal/07-incident-01"
mkdir -p "$LAB"
cd "$LAB"

# --- the data files -------------------------------------------------------
# Field 6 of the ok-flagged records spells the token. Only the 05 file has a
# declared record count matching its actual records.

cat > strain-2187-05.dat <<'EOF'
# deck 3 bay 2 -- structural strain sample set
# period: 2187-05
# records: 8
2187-05-01 00:00 deck3.bay2.strain 0.39 ok he
2187-05-04 00:00 deck3.bay2.strain 0.40 ok never
2187-05-08 00:00 deck3.bay2.strain 0.41 ok finished
2187-05-12 00:00 deck3.bay2.strain 0.43 ok typing
2187-05-16 00:00 deck3.bay2.strain 0.44 -- -
2187-05-20 00:00 deck3.bay2.strain 0.46 -- -
2187-05-24 00:00 deck3.bay2.strain 0.47 -- -
2187-05-28 00:00 deck3.bay2.strain 0.49 -- -
EOF

cat > strain-2187-04.dat <<'EOF'
# deck 3 bay 2 -- structural strain sample set
# period: 2187-04
# records: 8
2187-04-01 00:00 deck3.bay2.strain 0.36 ok -
2187-04-08 00:00 deck3.bay2.strain 0.37 ok -
2187-04-15 00:00 deck3.bay2.strain 0.37 ok -
2187-04-22 00:00 deck3.bay2.strain 0.38 ok -
EOF

cat > strain-2187-03.dat <<'EOF'
# deck 3 bay 2 -- structural strain sample set
# period: 2187-03
# records: 6
2187-03-01 00:00 deck3.bay2.strain 0.34 ok -
2187-03-11 00:00 deck3.bay2.strain 0.35 ok -
2187-03-21 00:00 deck3.bay2.strain 0.35 ok -
EOF

# --- the verifier ---------------------------------------------------------
# Readable on purpose. It shows HOW the token is derived and never contains it.

cat > check-sample-integrity.sh <<'EOF'
#!/usr/bin/env bash
# check-sample-integrity.sh -- compare a sample set's declared record count
# against the records actually present.
#
#   usage: ./check-sample-integrity.sh <sample-set.dat>

set -u

f=${1:-}
if [ -z "$f" ]; then
    echo "usage: $0 <sample-set.dat>" >&2
    exit 2
fi
if [ ! -f "$f" ]; then
    echo "no such sample set: $f" >&2
    exit 2
fi

declared=$(sed -n 's/^# records: //p' "$f")
actual=$(grep -c -v '^#' "$f")

echo "sample set:        $f"
echo "declared records:  ${declared:-<none declared>}"
echo "records present:   $actual"

if [ "${declared:-x}" != "$actual" ]; then
    echo
    echo "INTEGRITY: FAIL -- declared and present disagree."
    echo "This set is incomplete. Nothing further to report."
    exit 1
fi

echo
echo "INTEGRITY: PASS"

tok=$(awk '$5 == "ok" { printf "%s%s", sep, $6; sep="_" }' "$f")
echo "verification token: KESTREL{${tok}}"
EOF
chmod 755 check-sample-integrity.sh

# --- dorn's history -------------------------------------------------------
# 2187-05-24, ending 04:12 (epoch 6860261520). The final line stops mid-word.
# The long find is genuine housekeeping. The statoin/station pair is a typo he
# corrected. Neither leads anywhere; both are meant to look like they might.

cat > dorn-bash-history <<'EOF'
#6860256000
cd /var/log/station
#6860256240
ls -l
#6860256900
cat /var/log/statoin/structural.log
#6860256930
cat /var/log/station/structural.log
#6860257800
find /var/log/station -type f -mtime +30 -name '*.log' -size +1M
#6860258400
cd ~/samples
#6860258760
ls -l
#6860259300
head -3 strain-2187-05.dat
#6860260200
wc -l strain-2187-05.dat
#6860261100
history -c
#6860261520
./check-sample-integrity.sh strain-2187-0
EOF
chmod 444 dorn-bash-history

# --- timestamps -----------------------------------------------------------
# Dates MUST match SCENARIOS.md section 2. The capstone sorts on these.
touch -d '2187-05-24 04:12:00' dorn-bash-history
touch -d '2187-05-18 22:40:00' check-sample-integrity.sh
touch -d '2187-05-28 00:06:00' strain-2187-05.dat
touch -d '2187-04-28 00:06:00' strain-2187-04.dat
touch -d '2187-03-21 00:06:00' strain-2187-03.dat

echo "seeded $LAB"
