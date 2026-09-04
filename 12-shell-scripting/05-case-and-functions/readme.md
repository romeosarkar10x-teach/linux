# 12/05 — `case` and functions

> `case` is how a script with four modes stays readable. It is also how a script
> hides a fourth mode nobody reads down to.

Two structures, both about the same thing: giving a script more than one job
without turning it into a wall of `elif`.

## `case`

```bash
case "$1" in
    status)        echo "all decks nominal" ;;
    help|-h|--help) usage ;;
    *)             echo "unknown mode: $1" >&2; exit 64 ;;
esac
```

The word is expanded, but **not word-split and not globbed** — `case $v in` with
`v="a b"` still matches the pattern `a b`. It is the one place where unquoted is
genuinely safe. Quote it anyway, so you never have to remember which place.

The patterns are **globs, not regexes**: `*`, `?`, `[a-z]`, and `|` for
alternatives. There is no anchoring; the pattern must match the whole word.
`[a-z]*` does not match `ABC`.

**First match wins, and nothing after it is tested.** A `*)` branch that is not
last makes every branch below it dead code, and bash will not say a word.
`bin/dispatch` has had this since 2186 — rhea moved the catch-all up while
adding it, and the special case for the bridge deck has never once run. That is
what `shellcheck` is for; run it on that file and read SC2222.

Three terminators:

- `;;` — stop.
- `;&` — run the **next** body without testing its pattern. Fallthrough.
- `;;&` — keep testing the remaining patterns.

`bin/fallthrough ax` runs all three on the same input. `;&` and `;;&` are rare
enough that if you use one, comment it.

## Functions

```bash
deck_report() {
    local name="$1" path
    ...
}
```

Defined when the definition **runs**, not when the file is parsed, so the
definition has to come before the call. A function is looked up before builtins'
external twins and before PATH, which is why `ls() { ... }` shadows `/bin/ls`
and why `command ls` gets past it (11/04, again — same lookup order).

Arguments are positional exactly as in a script: `$1`, `$#`, `"$@"`. `$0` is
**not** the function name; it is still the script. `${FUNCNAME[0]}` is the name.

`type -t f`, `declare -f f`, `unset -f f`.

## `local`, and the status it eats

Without `local`, an assignment inside a function writes the *caller's* variable.
`bin/leaky` shows both. The resulting bug never looks like a scope bug; it looks
like a loop counter that was somehow already 4.

One trap worth memorising:

```bash
f() { local n=$(grep -c FAULT "$1"); }    # status is local's: always 0
g() { local n; n=$(grep -c FAULT "$1"); } # status is grep's
```

`bin/status-trap` prints `masked: 0` and `unmasked: 1` on the same file. Declare
on one line, assign on the next, whenever the status matters.

## Return a code or print an answer — not both

A function has exactly one status and one output stream. Decide which one
carries the answer:

- **Status** for yes/no. `deck_has_fault() { grep -q FAULT "$1"; }` — the caller
  writes `if deck_has_fault x; then`.
- **Output** for values. `deck_lines() { wc -l < "$1"; }` — the caller writes
  `n=$(deck_lines x)`.

`bin/echo-vs-return` uses both, correctly, in four lines. What you must not do
is `return "$n"` for a value: `return` takes a status, 0–255, taken **mod 256**.
`return 300` gives 44 (`bin/big-return` proves it), and `return abc` is an error
with status 2. A file count of 300 becomes 44 and nobody finds out for a year.

Note also that `$(f)` captures the output *and* forwards the status:
`r=$(m); echo $?` gives `m`'s status.

`exit` inside a function exits the whole script. `return` outside a function is
an error — "can only `return' from a function or sourced script".

## Libraries

`lib/deck.sh` has no shebang, because it is meant to be **sourced**, not run
(12/01). Source it and call `deck_report alpha` in your own shell — the
functions are yours until you `unset -f` them.

## What you will do

Find the branch in `bin/dispatch` that has never executed. Read
`ops/housekeeping.sh`'s `case` all the way to the bottom, and count its modes
against the ones its `usage` mentions.
