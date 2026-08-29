# 08/05 — Exit codes and chaining

Lessons 01–04 were about where bytes go. This one is about the other thing every command produces: a
number nobody prints.

Every command that finishes leaves an **exit status** behind — one byte, 0 to 255. `0` means it did
what it was asked. Anything else means it did not, and *which* number is the command's own business.
The shell keeps the last one in `$?`.

```
grep p-01 data/readings.txt >/dev/null ; echo $?    # 0, matched
grep zzz  data/readings.txt >/dev/null ; echo $?    # 1, did not match
grep p-01 /nope           2>/dev/null ; echo $?     # 2, could not answer
```

Three different answers, and the difference between 1 and 2 is the difference between "no" and "I
don't know". Most well-behaved tools make that distinction; `diff` uses the same 0/1/2 pattern. Read
the EXIT STATUS section of the manual before you write a chain that depends on one.

## `$?` is the *last* command's status

Including the command you used to look at it, and including `[`:

```
bin/rc 3
if [ -n "x" ]; then :; fi
echo "$?"        # 0 -- that is the `if`, not rc 3
```

If you need a status later, put it in a variable on the very next line: `rc=$?`.

## The numbers the shell assigns

| status | meaning |
|---|---|
| 0 | success |
| 1–125 | the command's own choice of failure |
| 126 | found, but could not be executed — not executable, or a directory |
| 127 | command not found |
| 128+N | killed by signal N — 130 is Ctrl-C (SIGINT 2), 143 is SIGTERM, 141 is SIGPIPE |
| 255 | commonly "out of range" — `exit -1` becomes 255 |

The status is one byte, so it wraps: `exit 300` becomes **44**, and `exit 256` becomes **0** — a
failure that reports success. Never compute an exit code.

## Chaining

```
a && b     run b only if a succeeded
a || b     run b only if a failed
a ; b      run b either way (a newline is the same as ;)
! a        invert a's status
```

`&&` and `||` have **equal precedence** and group **left to right**. That single fact is the reason
this construct is a trap:

```
a && b || c
```

It is not if/else. It parses as `(a && b) || c`, so `c` runs when `a` fails **and** when `a` succeeds
but `b` fails. Measured:

```
true  && echo B || echo C     # B
false && echo B || echo C     # C
true  && false || echo C      # C   <- the surprise
```

If you mean if/else, write `if`. If you mean "several things, only on success", group them:

```
a && { b; c; }        both, only if a succeeded
{ a; b; } && c        c if b succeeded; a's status is discarded
```

The semicolon before the closing `}` is required, and `{ }` needs spaces inside — it is a keyword,
not punctuation.

`!` inverts, and in front of a pipeline it inverts only the pipeline's final status:
`! bin/rc 3 | cat` gives `$?` = 1 with `PIPESTATUS` still `3 0`.

## A script returns the status of its last command

Unless it says otherwise with `exit N`. This is how statuses get lost, and it is the bug in this lab.

`bin/checkbank B` reports the failure on standard error, prints "check incomplete", and then ends
with `echo "checkbank: done"`. `echo` succeeds. So the script exits **0**, and every wrapper that
believed it has believed it for over a year:

```
bin/checkbank B ; echo $?          # 0
bin/checkbank-fixed B ; echo $?    # 1
```

`bin/deckcheck` asks `if bin/checkbank "$b"` and writes `logs/deckcheck.log` accordingly. The log is
a perfect record of nothing. cass's page says it better than a rubric could: *I do not think the walk
is lying. I think it is not being asked the question.*

The same trap in a function:

```
f() { local v=$(bin/rc 7); }; f; echo $?      # 0  -- `local` succeeded
g() { local v; v=$(bin/rc 7); }; g; echo $?   # 7
```

`local x=$(cmd)` throws away `cmd`'s status, because the status you get is `local`'s. Declare first,
assign second, whenever the status matters. A bare assignment does keep it: `x=$(bin/rc 4); echo $?`
is 4.

## `set -e` is not a safety net

It aborts on a command that fails — except in all the places you most need it:

- not for a command on the left of `&&` or `||` (`bin/rc 3 && echo yes` does not abort; the script
  carries on)
- not for anything inside `if`, `while`, `until`, or after `!`
- not for a failing stage of a pipeline unless `pipefail` is on (lesson 04)
- and inside a function called in a condition, `set -e` is switched off for the whole call:
  `f() { bin/rc 3; echo unreachable; }; f && echo ok` prints `unreachable` **and** `f ok`

Use it, but do not trust it to notice what you did not check yourself. Explicit is better:

```
if ! bin/checkbank-fixed B; then
  echo "bank B check failed" >&2
  exit 1
fi
```

## What to take out of here

- Every command answers with a number; `$?` holds only the most recent one.
- 1 and 2 usually mean different things. 126, 127 and 128+N come from the shell.
- `a && b || c` is not if/else.
- A script or function returns its last command's status unless you make it say otherwise.
- `local x=$(cmd)` loses `cmd`'s status. So does ending a script with `echo`.
- `set -e` has more exceptions than rules.

Next: the incident.
