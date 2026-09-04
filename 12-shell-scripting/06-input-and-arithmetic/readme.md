# 12/06 — input and arithmetic

> Shell arithmetic is limited, awkward, and enough. Knowing exactly where it
> stops is what keeps you from writing something worse than the problem.

## `read`, properly

You met `read` as a loop engine in 12/04. It is also how a script asks.

```bash
read -r -p "deck name: " name
```

`-p` writes the prompt to the terminal, not to stdout, so a script that prompts
can still be piped. `-r` is not optional; neither is quoting the result.

Given several names, `read` splits the line on `$IFS` and gives the **last name
everything that is left**:

```bash
read -r p q <<< "a b c"     # p=a  q="b c"
```

Fewer fields than names is not an error — the extras come back empty. Set `IFS`
per-command to parse structured lines: `IFS=: read -r id name deck hours` is
`bin/fields`, and it is a complete CSV reader for files that have no quoting.

Also: `-t N` (give up after N seconds, status 1), `-n N` (stop after N
characters), `-s` (do not echo).

A prompt is not validation. `bin/ask-safe` checks with a `case` pattern —
`''|*[!0-9]*)` — before it does arithmetic, because everything below assumes it.

## `$(( ))`

**Integers. Only.** `$(( 1.5 ))` is not rounding, it is
`syntax error: invalid arithmetic operator`. Division truncates toward zero:
`7/2` is 3 and `-7/2` is `-3`. `%` takes the sign of its left operand: `-7%3` is
`-1`.

Inside `$(( ))` a bare word is a variable, so `$((x+1))` and `$(($x+1))` are the
same thing — and a variable whose *value* is a name gets evaluated again:
`y=x; x=5; $((y+1))` is 6. An unset name is 0. A name holding `abc` is also 0,
silently.

`(( expr ))` is the statement form: status 0 when the value is non-zero, 1 when
it is zero (12/03). `let` is the older spelling and its quoting rules will bite
you; use `(( ))`.

### The leading zero

```bash
v=010; echo $((v))      # 8
echo $((08))            # error: value too great for base
echo $((10#$v))         # 10
```

A leading zero means octal. Sensor readings, zero-padded IDs and anything
formatted `%02d` all arrive that way. `bin/margin-check` has flagged low margins
since 2186 and it has never once looked at alpha or beta, because their margins
are written `09` and `08`. The errors go to stderr; the log ops-bot keeps records
stdout. Run it.

The fix is `10#` on every number that came from a file.

### The other two edges

64-bit, and it **wraps**: `$(( 9223372036854775807 + 1 ))` is negative, with no
warning. And when you need a decimal, multiply before you divide:

```bash
frac=$(( (total * 100 / n) % 100 ))
printf '%d.%02d\n' "$(( total / n ))" "$frac"
```

That is `bin/average-2`, which reports `12.60` where `bin/average` reports `12`.
Beyond that, hand it to `awk`. There is no `bc` on this station.

## `$( )` is not `$(( ))`

One runs a command and expands to its output; the other evaluates arithmetic.
They look alike at 2 a.m. Command substitution strips **all** trailing newlines,
runs in a subshell (12/04), and forwards the command's status. Prefer `$( )` to
backticks: it nests, and it does not change the quoting rules inside it.

## Arrays

```bash
decks=(alpha beta "cargo hold" gamma)
"${decks[@]}"     # one word per element   <- almost always this
"${decks[*]}"     # one word, joined by IFS[0]
${#decks[@]}      # count
${!decks[@]}      # the indices
```

Exactly the `"$@"` versus `"$*"` rule from 12/02, for the same reason.
`bin/decks-array` loops both ways and the cargo hold splits in one of them.

Arrays are **sparse**: `a[9]=x` on a three-element array gives four elements with
indices `0 1 2 9`, and `unset 'a[1]'` leaves `0 2 9`. Loop over `"${a[@]}"`, or
over `"${!a[@]}"` when you need the index — never over `0..n-1`.

`declare -A m` gives an associative array with string keys, in no order you may
rely on.

## What you will do

Fix `bin/margin-check` so that it checks four decks instead of two, without
editing the data file. Then work out what else on this station reads numbers out
of a log.
