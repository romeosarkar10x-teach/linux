# 12/09 — incident 11

> There is a housekeeping script in the ops tree. It is named for cleaning up.
> Read it before you run it.

`notes/page.txt`, from ops-bot, timestamped 02:00 this morning:

> Nightly automation completed.
> `housekeeping: cleanup complete, 0 files removed`
> No files were removed. No errors were reported. No action required.

That line is true. Every word of it. It is also the reason nobody has looked at
the ops tree in five weeks.

## What you are being asked for

Not a repair. `notes/incident.txt` is explicit: an **audit**, in a form somebody
else can check, and it says why — repairing the script destroys the evidence the
audit is about. You are going to write a tool, in the sense of 12/08, and its
output is the deliverable.

The question the audit answers is in `notes/rules.txt`, and the wording is the
whole exercise:

> An **offender** is a script under `ops/` that causes a file under `data/` to
> be written, when the path of that file did not come from the script's own
> arguments.

Read that sentence twice more, because three of the six scripts in `ops/` write
files and only some of them are offenders. In particular:

- Writing to `reports/` or `logs/` is not it.
- Writing to a path built from `"$1"` is not it — the caller chose the path, and
  the caller can see what they chose.
- Writing via a temporary file and then `mv` **is** it. `mv` is a write to the
  destination, and the fact that it happens in one atomic step makes it more
  invisible, not less.
- A script that writes nothing itself and runs a script that does **is** it. You
  report the file that ended up written.

## The four checkpoints

`notes/checkpoints.txt` lists them; each prints a `STAGE{...}` receipt when you
have actually done the thing.

```
bin/check-inventory N          how many scripts are under ops/
bin/name-mode MODE             the mode housekeeping.sh does not document
bin/count-adjusted N           records that mode rewrites, on today's data
bin/audit-attest < report.txt   the audit, and the flag
```

`STAGE{...}` tokens are receipts, not flags. Do not submit them to `kestrel`.

The last one reads your report on **standard input** — one line per offender,
`script-name.sh data/whatever.txt`. Order, whitespace and duplicates do not
matter. It will tell you loudly and specifically when you are wrong, and it will
not tell you the answer.

## The skills this needs

Nothing new. This is the chapter, applied:

- 12/05 — reading a `case` statement, and noticing that its list of branches and
  its `usage()` are two different lists maintained by hand.
- 12/06 — a comparison against a threshold, and values with a leading zero.
  Whether that bites here depends on **which** comparison the script uses, and
  you have now met two that behave differently. Check, do not assume.
- Chapter 6 — `find` and `grep` over a tree of scripts, which is how you
  build the audit rather than reading six files by eye and hoping.
- 12/08 — the audit is a tool: shebang, `x` bit, `--help`, documented exit
  codes. You will be asked to score it against 12/08's six.

## One rule about what you write down

The audit says what the scripts **do**. It does not say who wrote them, or why,
and you do not have the evidence for either. A `git`-less ops tree with
timestamps on it is not an attribution. Write the finding; leave the motive
alone. The attestation you get back is worded that way for the same reason.

## Before you move on

- A log line that reports what a run *removed* says nothing about what it
  *changed*.
- `mv` into a data file is a write to that data file.
- A script that calls another script owns what that call does.
- The audit is the deliverable, and it has to be checkable by someone who does
  not trust you.
