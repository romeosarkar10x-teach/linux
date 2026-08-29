#!/usr/bin/env bash
# setup.sh -- seeds /labs/08-streams-and-redirection/06-incident-08
#
# THE ANSWER KEY. Students are told not to open this.
#
# Incident: bin/summarise has been run nightly for fourteen months. It prints a
# clean report on fd 1 and, every time it clamps an out-of-range reading, one
# warning on fd 2. Nobody has ever kept fd 2: the wrapper bin/nightly runs
#   bin/summarise > "$OUT" 2>/tmp/summarise.err
# and /tmp is recycled, so fourteen months of warnings went to a path that no
# longer exists. logs/summarise-2187-06-13.log is fd 1 only and is clean --
# that is the red herring. Reading files cannot solve this. The student must
# RUN THE TOOL and keep the other stream.
#
# THE FLAG. Each warning carries note=<word>. Four distinct words, in order of
# first appearance: it, complained, for, months.
#   bin/summarise 2>&1 >/dev/null | grep -o 'note=[a-z]*' | awk '!s[$0]++'
# -> KESTREL{it_complained_for_months}
# The literal flag string appears in no file in the tree, and neither does any
# of the four words outside the tool's own runtime output.
#
# THE TRACE (arc, chapter 8). Clamps are routine on panels p-03 and p-11. On
# 2187-05-13 and 2187-05-14 there are clamps on p-07, which is not a clamping
# panel and is the panel that feeds the door-log summariser. Two nights, then
# never again. The lab NEVER names a person and the notes never accuse one.
#
# Chained CTF (the Dig), four stages, STAGE{} tokens, none registered:
#   1  2> split      last line of the tool's stderr carries the token
#   2  &> / tee      total combined line count is a line number in records/index-c.txt
#   3  heredoc/<<<   feed the named string to bin/decode on stdin
#   4  $? and &&/||  bin/verify exits non-zero until given the right argument
#
# Idempotent: removes its own tree first, creates nothing outside LAB.
set -euo pipefail

LAB="/labs/08-streams-and-redirection/06-incident-08"
rm -rf "$LAB"
mkdir -p "$LAB"/{bin,data,logs,notes,records,scratch}
cd "$LAB"

########## data: fourteen months of panel readings ##########

gen_month() {   # $1 = YYYY-MM, $2 = seed
  local m=$1 s=$2 d p v
  for d in $(seq -w 1 28); do
    for p in 01 03 05 07 09 11; do
      v=$(( (s + 10#$d * 7 + 10#$p * 13) % 900 ))
      # p-03 and p-11 sit by the coolant return and run hot in the warm months
      case "$p:$m" in
        03:*-0[5-9]|03:*-10|11:*-0[5-9]|11:*-10) v=$(( v % 400 + 850 ));;
      esac
      printf '%s-%s p-%s %d.%03d\n' "$m" "$d" "$p" $(( v / 1000 )) $(( v % 1000 ))
    done
  done
}

{
  echo "# panel readings, deck 05. one line per panel per day."
  echo "# fields: date panel value"
  s=100
  for m in 2186-05 2186-06 2186-07 2186-08 2186-09 2186-10 2186-11 2186-12 \
           2187-01 2187-02 2187-03 2187-04 2187-05 2187-06; do
    gen_month "$m" "$s"
    s=$(( s + 37 ))
  done
} > data/readings.txt

########## bin/summarise: clean on fd 1, fourteen months of complaint on fd 2 ##########

cat > bin/summarise <<'EOF'
#!/usr/bin/env bash
# summarise -- deck 05 panel summary. Values above 1.000 are clamped to 1.000.
# The clamp is reported on standard error so it does not pollute the report.
set -u
cd "$(dirname "$0")/.."

# Note codes are stored encoded so the report generator can be shipped without
# the station message catalog. Decoded once, at start of run.
notes=()
for code in aXQ= Y29tcGxhaW5lZA== Zm9y bW9udGhz; do
  notes+=( "$(printf '%s' "$code" | base64 -d)" )
done
n=0
clamped=0
total=0

declare -A sum cnt

while read -r date panel value; do
  case "$date" in \#*|'') continue;; esac
  total=$(( total + 1 ))
  v=${value%.*}
  if [ "$v" -ge 1 ]; then
    printf 'summarise: clamp %s %s value=%s -> 1.000 note=%s\n' \
      "$panel" "$date" "$value" "${notes[$(( n % 4 ))]}" >&2
    n=$(( n + 1 ))
    clamped=$(( clamped + 1 ))
    value=1.000
  fi
  month=${date%-*}
  sum[$month]=$(( ${sum[$month]:-0} + ${value%.*} * 1000 + 10#${value#*.} ))
  cnt[$month]=$(( ${cnt[$month]:-0} + 1 ))
done < data/readings.txt

echo "deck 05 panel summary"
echo "  readings ......... $total"
echo "  months ........... ${#cnt[@]}"
for m in $(printf '%s\n' "${!cnt[@]}" | sort); do
  printf '  %s  mean %d.%03d over %d readings\n' \
    "$m" $(( sum[$m] / cnt[$m] / 1000 )) $(( (sum[$m] / cnt[$m]) % 1000 )) "${cnt[$m]}"
done
echo "  status ........... nominal"
printf 'summarise: %d readings clamped. STAGE{it_told_you_every_night}\n' "$clamped" >&2
exit 0
EOF

cat > bin/nightly <<'EOF'
#!/usr/bin/env bash
# nightly -- the wrapper that has run every night for fourteen months.
set -u
cd "$(dirname "$0")/.."
OUT="logs/summarise-$1.log"
bin/summarise > "$OUT" 2>/tmp/summarise.err
echo "nightly: wrote $OUT"
EOF

cat > bin/decode <<'EOF'
#!/usr/bin/env bash
# decode -- reads one line on standard input. Nothing else.
set -u
read -r line || { echo "decode: nothing on standard input" >&2; exit 2; }
case "$line" in
  "the stream nobody kept")
    echo "STAGE{third_stage_you_fed_it_on_stdin}"
    echo "next: bin/verify takes one argument -- the panel that clamped on two nights"
    echo "      in 2187-05 and never again. Chain it so you only see the token on success."
    ;;
  *) echo "decode: that is not the phrase" >&2; exit 1;;
esac
EOF

cat > bin/verify <<'EOF'
#!/usr/bin/env bash
set -u
[ $# -eq 1 ] || { echo "usage: verify PANEL" >&2; exit 2; }
if [ "$1" = "p-07" ]; then
  echo "STAGE{fourth_stage_two_nights_in_may}"
  exit 0
fi
echo "verify: $1 is not it" >&2
exit 1
EOF

chmod 755 bin/summarise bin/nightly bin/decode bin/verify

########## the trace: p-07 clamps on two nights in 2187-05, and never again ##########

python_free_inject() {
  # p-07 does not clamp anywhere in the generated data. Give it two clamping
  # values on 2187-05-13 and 2187-05-14 only.
  sed -i \
    -e 's|^2187-05-13 p-07 .*|2187-05-13 p-07 1.184|' \
    -e 's|^2187-05-14 p-07 .*|2187-05-14 p-07 1.203|' \
    data/readings.txt
}
python_free_inject

########## logs: fd 1 only. the red herring. ##########

for d in 2187-06-09 2187-06-10 2187-06-11 2187-06-12 2187-06-13; do
  bin/summarise > "logs/summarise-$d.log" 2>/dev/null
done

cat > logs/README <<'EOF'
Nightly summary output. One file per night, written by bin/nightly.
Only the report is kept. See notes/wrapper.txt.
EOF

########## notes ##########

cat > notes/page.txt <<'EOF'
From: cass
To: whoever is on shift

I have the nightly summaries going back to last spring and they all say the
same thing: nominal. Fourteen months of nominal.

That is what is bothering me. Not one bad night in fourteen months, on a deck
where I have personally replaced two panels. Either deck 05 is the healthiest
deck on the station or the summary is not telling me everything it knows.

I do not want you to read the logs. I have read the logs. I want to know
whether the summary is the whole of what the tool says.
EOF

cat > notes/wrapper.txt <<'EOF'
The nightly job
---------------

bin/nightly runs the summariser once a night and keeps the report:

    bin/summarise > "logs/summarise-$DATE.log" 2>/tmp/summarise.err

The report goes into logs/. The error file goes to /tmp, which is recycled --
anything written there is gone by the next boot. That was fine when the tool
was written, because the tool was not expected to have anything to say on
standard error.

Nobody has changed this line since it was written.
EOF

cat > notes/clamping.txt <<'EOF'
Clamping, deck 05
-----------------

A panel reading above 1.000 is out of range. The summariser clamps it to 1.000
so one bad sample cannot drag a monthly mean, and reports the clamp.

Panels p-03 and p-11 sit next to the coolant return and clamp routinely in
warm months. Nobody investigates those any more.

The other panels on the deck are not expected to clamp at all. p-07 in
particular feeds the door-log summariser, so a clamp there changes what the
door log records for that day. If p-07 ever clamps, it is worth a look.
EOF

cat > notes/dig.txt <<'EOF'
Dig, chapter 8.

Four receipts, STAGE{...}. They do not register with `kestrel flags`; they are
there so you know you are on the path.

Stage 1 is in the tool's own complaint, on the last line of it. You have
everything you need for that already: run the tool and keep the stream the
wrapper throws away.
EOF

########## records: the Dig ##########

# The line number is the total of both streams, computed here so the lab and
# the index can never drift apart.
TOTAL=$( { bin/summarise; } 2>&1 | wc -l )
{
  for i in $(seq 1 $(( TOTAL + 60 )) ); do
    if [ "$i" -eq "$TOTAL" ]; then
      echo "$i  STAGE{second_stage_you_counted_both} -- next: bin/decode reads one line on standard input. Give it, without a pipe and without a file, the four-word phrase for what the wrapper did with fd 2. Four words, lower case, spaces between them. It is the phrase cass would use."
    else
      echo "$i  STAGE{that_is_not_the_total}"
    fi
  done
} > records/index-c.txt

cat > records/README <<'EOF'
Deck 05 index files. Line numbers are stable; nothing here is a log.
EOF

########## scratch ##########
printf 'Yours. Copy things here before you experiment on them.\n' > scratch/README

########## timestamps ##########
find . -exec touch -h -d '2187-06-14 08:00:00' {} +
touch -d '2186-04-02 11:20:00' bin/summarise bin/nightly notes/wrapper.txt
touch -d '2186-04-02 11:20:00' notes/clamping.txt
touch -d '2187-06-14 09:40:00' notes/page.txt
i=9
for d in 2187-06-09 2187-06-10 2187-06-11 2187-06-12 2187-06-13; do
  touch -d "$d 23:05:00" "logs/summarise-$d.log"
done
touch -d '2187-06-01 12:00:00' records/index-c.txt records/README

echo "seeded $LAB"
