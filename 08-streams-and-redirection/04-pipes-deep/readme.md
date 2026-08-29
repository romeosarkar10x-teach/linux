# 08/04 — Pipes, properly

Chapter 5 told you what a pipe does: `a | b` sends `a`'s output to `b`'s input. That is true and it
is not enough. This lesson is about what a pipe *is*, because four separate surprises come out of the
mechanism and every one of them looks like a broken program.

## Both stages start at once

`a | b` is not "run `a`, collect its output, then run `b`". The shell creates a pipe — a kernel buffer
with a read end and a write end — forks **both** commands immediately, connects `a`'s fd 1 to the
write end and `b`'s fd 0 to the read end, and lets them run. Whichever gets ahead blocks: if the
buffer fills, `a`'s next `write` waits; if it empties, `b`'s next `read` waits.

Consequences you can see:

- A pipeline of ten stages is ten processes, running concurrently.
- `b` can finish before `a` does, and often should.
- Nothing is stored on disk and nothing has a name. Inside a stage,
  `readlink /proc/self/fd/1` says `pipe:[22072171]`.

## Only fd 1 goes down the pipe

`|` redirects standard output. Standard error is untouched and goes wherever it was already going —
usually straight past the entire pipeline to your terminal.

```
bin/noisy | wc -l        # 6, and six "err" lines appear on your screen
bin/noisy 2>&1 | wc -l   # 12
bin/noisy |& wc -l       # 12, bash shorthand for the same thing
```

Order matters and it is the same rule as lesson 02: `2>&1` must come **before** the `|` to reach the
pipe, because the pipe redirection is set up first and `2>&1` copies whatever fd 1 is at that moment.
`cmd | wc -l 2>&1` redirects *`wc`'s* stderr and does nothing useful at all.

This is the whole of rhea's first complaint: the filter never sees the warnings because the warnings
were never sent to it.

## Exit status: the last stage wins

```
false | true ; echo $?      # 0
bin/failmid | wc -l ; echo $?   # 0, and failmid exited 4
```

The pipeline's status is the **rightmost** stage's. Everything upstream can fail and the pipeline
reports success. Two ways out:

```
bin/failmid | wc -l
echo "${PIPESTATUS[@]}"     # 4 0     -- every stage, in order
```

`PIPESTATUS` is an array set after each pipeline and **overwritten by the very next command**,
including an `echo` or a `[`. Capture it in one go or you lose it.

```
set -o pipefail
bin/failmid | wc -l ; echo $?   # 4
```

`pipefail` makes the pipeline's status the rightmost non-zero one. It is the right default in
scripts, with one trap: a stage killed by SIGPIPE (below) exits 141, and `pipefail` will happily
report that as a failure. `seq 1 100000 | head -1` under `pipefail` exits **141**.

## Every stage is a subshell

Each stage is its own process, so anything it assigns dies with it.

```
n=0; seq 1 3 | while read -r l; do n=$((n+1)); done; echo $n     # 0
```

The loop counted to three in a child and the child exited. Your options:

```
while read -r l; do n=$((n+1)); done < <(seq 1 3)   # process substitution, loop is in this shell
shopt -s lastpipe                                    # non-interactive shells only; last stage stays
```

or have the loop print its answer and capture that with `$(…)`.

## SIGPIPE: the reader can kill the writer

If the reader exits while the writer still has output, the writer's next `write` gets `SIGPIPE` and
the writer dies. This is normal, correct, and how `yes | head -2` terminates.

```
seq 1 100000 | head -1
echo "${PIPESTATUS[@]}"    # 141 0
```

141 is 128 + 13, the shell's spelling of "killed by signal 13". Two things follow. First, the writer
does **not** finish: `seq 1 100000 | tee big.txt | head -1` leaves `big.txt` with whatever had already
been written — about ten thousand lines, not a hundred thousand, and `tee` dies too (`141 141 0`).
Second, a writer's trailing cleanup — a summary line, a final flush — may never happen. `bin/countdown`
prints its "finished all 30" note on fd 2 and, piped into `head -1`, never gets there.

## Buffering, and why `| grep` looks broken

The C library chooses a buffering mode by asking whether fd 1 is a terminal:

| fd 1 is | mode | you see |
|---|---|---|
| a terminal | line buffered | each line as it is produced |
| a pipe or file | **block** buffered | nothing until ~4–8 KB has piled up |

Nothing is lost and nothing is broken — the output is sitting in the writer's buffer. But the effect
is dramatic:

```
bin/slowtick 40 | grep tick | head -3      # produces nothing for a long time
bin/slowtick 40 | grep --line-buffered tick | head -3   # three lines, immediately
```

That is rhea's second complaint, and it is a different bug from the first one.

Fixes, in order of preference:

- the tool's own flag: `grep --line-buffered`, `sed -u`, `awk '{print; fflush()}'`
- `stdbuf -oL cmd`, which sets the mode for a program that has no flag
- accept it, if the pipeline is not interactive

Two things that are *not* affected: bash builtins like `echo`, which issue a write per line and so
appear to work fine — which is exactly why shell scripts hide the problem — and `cat`, which passes
blocks through as they arrive. And some commands cannot stream at all: `wc -l`, `sort`, `tac` must
read to end of input before they can produce anything. That is not buffering, that is the algorithm.

## `tee`

`tee` writes its stdin to files *and* to stdout, so you can inspect a pipeline without breaking it.

```
a | tee f | b            keep a copy of what b receives
a | tee -a f | b         append
a | tee f1 f2 | b        several files
a | tee /dev/tty | b     copy to your terminal
a | tee >(wc -l > n) | b copy into another process
```

Remember what `tee` does *not* do: it copies fd 1 only, and it does not change any exit status —
`bin/failmid | tee f` still reports 0.

## What to take out of here

- Both stages start together; each is a separate process; each is a subshell.
- `|` carries fd 1 only, and `2>&1` must be on the left of the `|`.
- The status is the last stage's. `PIPESTATUS` has them all and is destroyed by the next command.
- `pipefail` is right in scripts, and will report SIGPIPE as failure.
- A reader that exits early kills the writer: 141, and the writer's last work never happens.
- Block buffering into a pipe is the default. It is not a bug and it has a flag.

Now: `exercises.md`.
