# 12/04 — Loops

> Reading a file line by line is where most shell scripts quietly break on the
> first filename with a space in it.

Two loops matter: `for`, over a list of words, and `while read`, over lines of
input. Each has one classic way of being written wrong, and both wrong versions
produce plausible output for years.

## `for` loops over words, not over "things"

```bash
for f in *.log; do ... done
```

The shell expands `*.log` into words *before* the loop starts. The loop itself
does no splitting — it just walks a list. That is why globbing is safe: the glob
produces one word per file, spaces included.

```bash
for f in $(ls *.log); do ... done
```

Here `ls` prints names separated by newlines, the command substitution hands
that back as **text**, and the shell splits the text on whitespace. `cargo
hold.log` becomes `cargo` and `hold.log`, neither of which exists. There is no
`ls` flag that fixes this, because the damage happens after `ls` has finished.
`bin/count-decks-ls` does exactly this, and it has been right about four of the
five decks since 2186.

Other list sources: `{1..5}` (brace expansion, before everything else),
`for ((i=0;i<5;i++))` (arithmetic, bash only), and `for f in "$@"` — the
arguments, correctly.

A glob that matches nothing expands to **itself**, so `for f in nomatch*` runs
once with `f` set to the literal `nomatch*`. `shopt -s nullglob` makes it run
zero times (11/05). Decide which you want.

## `while read`, and the three things on that line

```bash
while IFS= read -r line; do ... done < file
```

- `IFS=` — empty, for this command only. Without it `read` strips leading and
  trailing whitespace.
- `-r` — do not treat backslash as an escape. Without it, `back\slash` becomes
  `backslash`, and a line ending in a backslash swallows the next one.
- `< file` on the **loop**, not `cat file |`. See below.

And the fourth thing nobody tells you: `read` returns false at end of input, so
a final line with **no trailing newline** is stored in the variable *and*
reported as failure — the body never runs for it. `manifests/awkward.txt` ends
that way; all three loops in `bin/read-manifest` silently drop the last line. If
your input might not end in a newline:

```bash
while IFS= read -r line || [ -n "$line" ]; do
```

## The pipeline subshell

```bash
n=0
printf '%s\n' a b c | while read -r x; do n=$((n+1)); done
echo "$n"        # 0
```

The loop counted correctly, in a child process, and the child is gone. Same rule
as executing versus sourcing (12/01) and as `export` (11/01): a child cannot
change its parent. `bin/tally` is built this way, and it reports `decks with
faults: 0` while epsilon sits there with a FAULT in it. ops-bot has filed the
result and closed the matter.

In order of preference:

```bash
while ... done < <(command)     # process substitution — loop stays in your shell
while ... done < file           # no pipeline at all
n=$(command | wc -l)            # let the pipeline produce the answer
```

## `until`, `break`, `continue`

`until` is `while` with the condition inverted; use it when the natural sentence
is "keep going until X". `break` leaves the loop, `continue` skips to the next
iteration, and both take a count (`break 2`) for nested loops — which is clever,
rare, and worth a comment when you use it.

A loop's exit status is the status of the last command it ran, which after a
`break` is whatever ran before the break. If callers depend on it, set it
yourself.

## What you will do

Break `count-decks-ls` on the cargo hold and prove where the split happened.
Watch `read`, `read -r` and `IFS= read -r` eat three different things from the
same file. Then fix `tally` without changing what it counts.
