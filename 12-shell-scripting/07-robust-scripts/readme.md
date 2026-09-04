# 12/07 — robust scripts

> A script that fails silently in the middle is worse than one that never ran.
> Four lines at the top prevent most of it, and `shellcheck` catches most of the
> rest.

There is an open request in `notes/page.txt`, filed 246 days ago: *"Scripts in
ops/ have no consistent error handling. Several exit 0 on failure."* Nobody has
been assigned. You have now met three of those scripts.

## The header

```bash
#!/usr/bin/env bash
set -euo pipefail
```

- `-e` — exit when a command fails.
- `-u` — error on an **unset** variable.
- `-o pipefail` — a pipeline fails if *any* stage fails.

Add `set -x` temporarily when you are debugging; never ship it.

## What `-e` does not do

This is the part that gets skipped, and it is the part that matters. `-e` is
switched **off** for:

- anything used as a **condition** — `if`, `while`, `until` — including inside a
  function called from there;
- the left-hand side of `&&` and `||`;
- any command inverted with `!`;
- every stage of a pipeline but the last (that is what `pipefail` is for).

Run `bin/e-in-if`. It defines a strict-looking function whose first line is
`false`, calls it from an `if`, and prints:

```
check: still running after false
condition was true
script reached the end
```

`-e` was disabled for the whole body of `check`, because it was a condition. This
is not a bug — `if` could not work otherwise — but a function written to be
strict is not strict when tested. `bin/e-limits` walks the other three cases.

The conclusion is not "don't use `-e`". It is: `-e` is a floor, not a proof. You
still check the things you care about.

## `-u`, and the two escapes

`-u` fires on an **unset** name; an empty one is fine. Say what you meant:

```bash
${v:-default}    use a default
${v:?message}    fail here, with a message naming the variable
```

`bin/u-demo` shows both halves. Note that `$1` is a variable too — a script with
`set -u` and no arguments dies on `$1` and not on your usage check, unless the
usage check comes first (12/02).

## `pipefail` and the 141

```
without pipefail: 0
with pipefail:    1
yes | head -1:    141
```

The first is why you want it: `false | true` succeeded. The last is its price:
`head` exits, `yes` gets SIGPIPE, 128 + 13 = 141, and your strict script now dies
on a perfectly correct pipeline. Keep `pipefail`; guard the pipelines where you
expect an early exit.

## Quoting, as a policy

Quote every expansion. `"$var"`, `"$1"`, `"$@"`, `"$(cmd)"`, `"${arr[@]}"`. When
you deliberately leave one unquoted, comment it — or use an array, which is what
you actually wanted.

Two more habits worth as much as the quotes:

```bash
cd "$dir" || exit    # a failed cd leaves every later line running in the wrong place
rm -f -- "$f"        # -- ends option parsing; a file can be named -rf
```

`bin/unsafe` has neither. Run it with no arguments and work out where it ran
`ls`. It exits 0.

## `trap`

```bash
trap 'commands' EXIT      # any exit, including error exits
trap 'commands' ERR       # a command failed; does not stop it
trap 'commands' INT TERM  # Ctrl-C, kill
```

`EXIT` is the one to reach for. It runs after `exit 3` and the 3 survives —
`bin/trap-tour` proves both, and shows `ERR` firing without stopping anything.
**Single-quote** the body so `$var` is expanded when the trap runs, not when it is
set. A trap set inside a function belongs to the script.

## `mktemp`

```bash
tmp=$(mktemp) || exit 74
trap 'rm -f "$tmp"' EXIT
```

The `trap` goes on the very next line, before anything can fail. `mktemp -d` for
a directory; `mktemp -t kestrel.XXXXXX` for a recognisable name; it honours
`TMPDIR`.

`bin/tempfile-bad` uses `/tmp/report.$$`, which is rhea's from 2186. The PID is
predictable, the file may already exist and be owned by someone else, and the
`rm` at the end never runs if the script exits early — which it can, three lines
above. `bin/tempfile-good` is the same script with `mktemp` and a trap, and it is
two lines shorter.

## `shellcheck`

```
shellcheck bin/lint-me
```

Eight findings on nine lines, each with a number and a wiki page: SC2006
(backticks), SC2035 (a glob that could produce a leading dash), SC2086 (unquoted
expansions), SC2126 (`grep | wc -l`), SC2164 (`cd` without `|| exit`), SC2115
(`rm -rf $TMPDIR/*` when `$TMPDIR` may be empty). Read the page before you argue
with the tool.

To silence one check on one line — and only when you can say why in one sentence:

```bash
# shellcheck disable=SC2086  # word splitting is intended here
```

Never globally.

## What you will do

Rewrite `bin/unsafe` until `shellcheck` is silent and it fails loudly on every
input that should fail. Then find out which of the three broken scripts you have
met since 12/04 would have been caught by the header alone, and which would not.
