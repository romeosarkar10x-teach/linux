# 09/02 — Help

Read this when you are stuck. It does not contain answers.

## "The numbers are different every time I look"

They are supposed to be. `top` is a live instrument. That has a consequence for how you write things
down: a value from `top` is only meaningful with the time you took it and what was running. "Load was
1.1" is not a finding. "Load was 1.1 at 06:10 with nothing of ours running" is.

## "Is load average a percentage?"

No. It is an average queue length: how many processes wanted a CPU or were blocked on disk. It has no
upper bound. Divide it by `nproc` before you have an opinion. And read the three numbers as a trend —
1-minute below 15-minute means falling.

## "Free memory is almost zero"

Almost always fine. Unused memory is wasted memory, so the kernel fills it with cache and evicts on
demand. Read `avail Mem` instead: that is what a new process could actually get. If `avail` is small
*and* swap is being written to, then you have something.

## "%CPU adds up to more than 100"

On a multi-core machine `%CPU` is a share of one CPU, so four busy cores is 400%. Press `1` to see
per-CPU lines and it stops being confusing. One thread pinned at 100% on a 24-core box is 4% of the
average and a serious problem.

## "The numbers in the header don't match this station"

Correct, and `notes/station.txt` is the reason. In a container the process list is yours and the
header — load, memory, CPU summary — comes from the host kernel you are sharing. This is why `%MEM`
reads 0.0 for something holding 35 megabytes. Use `RES` in absolute units for anything you plan to
say out loud.

## "I can't pipe top"

Use `-b` (batch) with `-n 1`, and add `-w 200`, or the `COMMAND` column is truncated to whatever
`top` guesses the width is — you will see a `+` where your evidence used to be. `htop` has no batch
mode at all; it needs a terminal and says so.

## "Nothing shows up when I look"

Two likely reasons. The refresh delay is long and the thing you are hunting is short-lived — press
`d` and lower it. Or you are sorting by `%CPU`, which is the default, and the thing you are hunting
is not currently busy. Press `T`.

That second one is worth pausing on. `%CPU` is a rate and `TIME+` is a total, and they answer
different questions. If nothing you can see explains what you are being told, try changing the
question before you change the tool.

## "top vs ps"

`ps` for scripts, snapshots and exit statuses. `top` for watching change. `top -b -n 1` has exit
status 0 even when it matched no process at all, so it is not a test — `ps -p PID` is.

## Keys you will want

`h` help, `q` quit, `P`/`M`/`T` sort by CPU/memory/time, `c` full command line, `V` tree, `u` filter
by user, `o` filter by field, `=` clear filters, `1` per-CPU lines, `d` delay, `k` kill, `W` save
your layout.

## Where to look

- `notes/top.txt` — the header, line by line
- `notes/keys.txt` — interactive keys and batch options
- `notes/station.txt` — which numbers here are not ours
- `man top`, sections "FIELDS / Columns" and "INTERACTIVE Commands"; `man htop`

## Still stuck

Paste the whole `top -b -n 1 -w 200 | head -12`, not one line of it, and say what you expected. Half
the header's value is in the lines people leave out.
