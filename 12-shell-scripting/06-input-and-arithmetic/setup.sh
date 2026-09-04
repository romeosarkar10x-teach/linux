#!/bin/bash
# Lab setup for 12/06 — read, arithmetic, command substitution, arrays
set -euo pipefail

LAB="/labs/12-shell-scripting/06-input-and-arithmetic"

rm -rf "$LAB"
mkdir -p "$LAB"/{bin,data,notes,scratch}

# ---------------------------------------------------------------- data
cat > "$LAB/data/readings.txt" <<'EOF'
alpha 12
beta 7
gamma 19
delta 4
epsilon 21
EOF

# leading zeros, on purpose: these are how the sensor writes them
cat > "$LAB/data/margins.txt" <<'EOF'
alpha 09
beta 08
gamma 11
delta 07
EOF

cat > "$LAB/data/crew.csv" <<'EOF'
id:name:deck:hours
1:vasquez:alpha:38
2:okonkwo:beta:41
3:lindqvist:gamma:36
4:rhea:ops:44
EOF

# ---------------------------------------------------------------- bin
cat > "$LAB/bin/ask" <<'EOF'
#!/usr/bin/env bash
# read, with a prompt, and the two flags you should always have.
read -r -p "deck name: " name
read -r -p "how many? " count
echo "you said: name=[$name] count=[$count]"
EOF

cat > "$LAB/bin/ask-safe" <<'EOF'
#!/usr/bin/env bash
# A prompt is not input validation.
read -r -p "how many? " count
case "$count" in
    ''|*[!0-9]*) echo "not a whole number: $count" >&2; exit 65 ;;
esac
echo "count times two: $(( count * 2 ))"
EOF

cat > "$LAB/bin/fields" <<'EOF'
#!/usr/bin/env bash
# read splits on IFS into as many names as you give it.
# The LAST name gets everything that is left.
while IFS=: read -r id name deck hours; do
    [ "$id" = id ] && continue
    printf '%-10s deck=%-6s hours=%s\n' "$name" "$deck" "$hours"
done < /labs/12-shell-scripting/06-input-and-arithmetic/data/crew.csv
EOF

cat > "$LAB/bin/average" <<'EOF'
#!/usr/bin/env bash
# rhea, 2186-06-08. Mean deck reading.
total=0
n=0
while read -r deck value; do
    total=$(( total + value ))
    n=$(( n + 1 ))
done < /labs/12-shell-scripting/06-input-and-arithmetic/data/readings.txt
echo "readings: $n"
echo "total:    $total"
echo "average:  $(( total / n ))"
EOF

cat > "$LAB/bin/average-2" <<'EOF'
#!/usr/bin/env bash
# Same numbers, two decimal places, without leaving the shell for a language.
total=0
n=0
while read -r deck value; do
    total=$(( total + value ))
    n=$(( n + 1 ))
done < /labs/12-shell-scripting/06-input-and-arithmetic/data/readings.txt

whole=$(( total / n ))
# multiply before dividing: the only trick integer arithmetic has
frac=$(( (total * 100 / n) % 100 ))
printf 'average:  %d.%02d\n' "$whole" "$frac"
EOF

cat > "$LAB/bin/margin-check" <<'EOF'
#!/usr/bin/env bash
# rhea, 2186-06-09. Flags margins below 10.
while read -r deck margin; do
    if (( margin < 10 )); then
        echo "$deck: margin low ($margin)"
    fi
done < /labs/12-shell-scripting/06-input-and-arithmetic/data/margins.txt
echo "margin check complete"
EOF

cat > "$LAB/bin/arith-tour" <<'EOF'
#!/usr/bin/env bash
echo "7/2      = $(( 7 / 2 ))"
echo "-7/2     = $(( -7 / 2 ))"
echo "7%3      = $(( 7 % 3 ))"
echo "-7%3     = $(( -7 % 3 ))"
echo "2**10    = $(( 2 ** 10 ))"
echo "1<<3     = $(( 1 << 3 ))"
echo "3>2      = $(( 3 > 2 ))"
echo "0?1:2    = $(( 0 ? 1 : 2 ))"
echo "max int  = $(( 9223372036854775807 ))"
echo "and one  = $(( 9223372036854775807 + 1 ))"
x=5
echo 'x+1 as $((x+1))  = '"$(( x + 1 ))"
echo 'x+1 as $(($x+1)) = '"$(( $x + 1 ))"
y=x
echo 'y=x, $((y+1))    = '"$(( y + 1 ))"
EOF

cat > "$LAB/bin/decks-array" <<'EOF'
#!/usr/bin/env bash
decks=(alpha beta "cargo hold" gamma)

echo "count:    ${#decks[@]}"
echo "second:   ${decks[1]}"
echo "last:     ${decks[-1]}"
echo "indices:  ${!decks[@]}"
echo "slice 1,2: ${decks[@]:1:2}"

echo "-- one per line with \"\${decks[@]}\""
for d in "${decks[@]}"; do echo "  [$d]"; done

echo "-- and with \${decks[*]} unquoted"
for d in ${decks[*]}; do echo "  [$d]"; done
EOF

chmod 755 "$LAB"/bin/*

# ---------------------------------------------------------------- notes
cat > "$LAB/notes/read.txt" <<'EOF'
read
----
    read -r line               one line, backslashes intact
    IFS= read -r line          ... and whitespace intact (12/04)
    read -r a b c              split on IFS into three names
    IFS=: read -r a b c        split on colons instead
    read -r -p "prompt: " v    prompt goes to the terminal, not stdout
    read -t 5 v                give up after 5 seconds, status 1
    read -n 3 v                stop after 3 characters, no Enter needed
    read -s v                  do not echo (passwords)

The LAST variable gets all the remaining fields, separators and all:
    read -r p q <<< "a b c"    ->  p=a  q="b c"

Fewer fields than names: the extra names are set to empty. No error.

read returns non-zero at end of input -- including for a final line with
no trailing newline, which it still stores. See 12/04.
EOF

cat > "$LAB/notes/arithmetic.txt" <<'EOF'
arithmetic
----------
    $(( expr ))    expands to the value
    (( expr ))     evaluates; status 0 if non-zero, 1 if zero
    let "x = 1+2"  older, quoting-sensitive, avoid

INTEGERS ONLY. $(( 1.5 )) is a syntax error, not a rounding.
Division truncates TOWARD ZERO: 7/2 = 3, -7/2 = -3.
% takes the sign of the left operand: -7%3 = -1.

Inside $(( )) a bare name is a variable: $((x+1)) and $(($x+1)) are the
same. A variable holding a name is evaluated AGAIN: y=x, x=5, $((y+1))
is 6.

An unset or empty name is 0. A name holding "abc" is also 0, silently.

LEADING ZEROS ARE OCTAL:
    v=010; $((v))       -> 8
    $((08))             -> error: value too great for base
    $((10#$v))          -> 10       <- the fix
Sensor logs, timestamps and zero-padded IDs all bite here.

Bases: 16#ff = 255, 2#101 = 5, 10#08 = 8.

64-bit and it WRAPS: max + 1 is negative. No warning.

Need decimals? Multiply first: (total * 100 / n) and print with
printf '%d.%02d'. Or hand it to awk. There is no bc here.
EOF

cat > "$LAB/notes/arrays.txt" <<'EOF'
arrays
------
    a=(one "two three" four)
    "${a[@]}"      one word per element        <- almost always this
    "${a[*]}"      all elements as ONE word, joined by IFS[0]
    ${#a[@]}       number of elements
    ${#a[1]}       length of element 1
    ${!a[@]}       the INDICES, which is not the same as 0..n-1
    ${a[@]:1:2}    slice
    ${a[-1]}       last
    a+=(five)      append

Same rule as "$@" vs "$*" in 12/02, and for the same reason.

Arrays are SPARSE. a[9]=nine on a 3-element array gives 4 elements with
indices 0 1 2 9. After unset 'a[1]' the indices are 0 2 9. Never assume
the indices are contiguous -- loop over "${a[@]}", or over "${!a[@]}"
when you need the index.

Associative arrays must be declared:
    declare -A m
    m[deck]=alpha
    m["cargo hold"]=3
    "${!m[@]}" are the keys, in no order you should rely on.

An unquoted ${a[@]} splits and globs every element. There is no reason
to write it.
EOF

cat > "$LAB/notes/page.txt" <<'EOF'
station log — ops-bot
2187-07-04 06:15

  bin/margin-check, scheduled run.

  Output:
    delta: margin low (07)
    margin check complete

  Exit status: 0
  Prior run 2187-07-03: identical output.
  Recorded. No action required.
EOF

# ---------------------------------------------------------------- times
find "$LAB" -exec touch -h -d '2187-07-04 09:00:00' {} +
find "$LAB/notes" -type f -exec touch -h -d '2186-08-02 12:00:00' {} +
touch -h -d '2187-07-04 06:15:00' "$LAB/notes/page.txt"
touch -h -d '2186-06-08 10:40:00' "$LAB/bin/average"
touch -h -d '2186-06-09 09:05:00' "$LAB/bin/margin-check"
