# Chapter 7 — Text Processing Pipelines

> An account nobody has heard of logged in once, three months ago, and every ranked report anyone
> built that quarter had it on the last line.

## Incident briefing

Chapter 6 could tell you **which files** and **which lines**. It could not tell you *how many*, *how
often*, or *what the third column says*. That is this chapter: turning a stream of lines into a
number, a table, or a report — and knowing whether the number is true.

The tools are small and they compose. `wc`, `sort` and `uniq` answer counting questions between them,
and `sort | uniq -c | sort -rn` is the single most-used idiom on any station. `cut` and `paste` do
column surgery on delimited text. `tr` is the bluntest tool here and the right one about once a week.
`sed` substitutes, and its greed and its flags are the difference between a fixed file and a
plausible-looking wrong one. `awk` splits every line into fields and gives you arithmetic and arrays,
which is where reports actually get made. `tee` removes the choice between seeing output and keeping
it; `xargs` turns a stream into arguments, which is exactly where filenames get people hurt.

Then the lesson none of the tools teach: **how to build a pipeline you can defend.** One stage at a
time, looking after each one, checking the count at every step, redirecting only when it is right.
Nobody writes a nine-stage pipeline. They write one stage nine times, and the people who look fast at
it are the people who never guessed.

The incident is the captain's routine quarterly access report. There is no error, no anomaly detector
and no alert. `ops-bot` is 74% of the file and the top three accounts are 94% of it, so every
ranked report is dominated by things everyone already knows. The finding is a row with a count of
one, at the bottom of a table the student built themselves — an account called `eng-svc` that logged
in at 04:14 on 2187-01-18, never appeared again, and is in no account snapshot before or after. The
chapter's real subject is the habit that finds it: reading the last row of your own report.

## Learning objectives

- [ ] Count lines, words and characters with `wc`, and say what its `total` line is and is not
- [ ] Sort by field, numerically, in reverse, and explain why `sort` must precede `uniq`
- [ ] Use `uniq -c`, `-d` and `-u`, and read a counted table as a distribution
- [ ] Cut fields by delimiter and by character position, and say when each is wrong
- [ ] Paste files column-wise and choose a delimiter deliberately
- [ ] Translate, squeeze and delete character sets with `tr`, and know it has no concept of a word
- [ ] Substitute with `sed`: BRE and ERE, greed, the `g`, `N`, `I`, `p` and `w` flags, address ranges
- [ ] Explain why `sed` is the wrong tool for structured fields, and reach for `awk` instead
- [ ] Split lines into fields with `awk`, set `FS` and `OFS`, and use `NF`, `NR` and `FNR` correctly
- [ ] Build totals, averages and per-key tables with `awk` arrays, and format them with `printf`
- [ ] Save and display in one pass with `tee`, and state exactly when `tee` truncates
- [ ] Turn a stream into arguments with `xargs`, using `-n`, `-I{}`, `-r`, `-t` and `-a`
- [ ] State why NUL is the only safe filename separator, and pair `find -print0` with `xargs -0`
- [ ] Read a pipeline's exit status correctly with `PIPESTATUS` and `set -o pipefail`
- [ ] Build a pipeline one stage at a time, checking a count after every stage
- [ ] Say what a count check proves and what it does not
- [ ] Produce a report with a header, aligned columns and the period it covers

## Prerequisites

- Chapter 1 — exit status, pipes and redirection as shell mechanics
- Chapter 2 — paths, so `logs/*.log` means what you think it means
- Chapter 5 — quoting. Every `sed` and `awk` program in this chapter must survive the shell first
- Chapter 6 — `grep` and regular expressions; `sed` and `awk` both read patterns you already know

## Lessons

- [`01-wc-sort-uniq`](01-wc-sort-uniq/readme.md) — counting, ranking, and the idiom you will use forever
- [`02-cut-and-paste`](02-cut-and-paste/readme.md) — taking a column, and putting columns back together
- [`03-tr`](03-tr/readme.md) — character sets, squeeze and delete, and what `tr` cannot see
- [`04-sed-substitution`](04-sed-substitution/readme.md) — substitution, greed, flags and addresses
- [`05-awk-fields`](05-awk-fields/readme.md) — fields, arrays, arithmetic and `printf`
- [`06-tee-and-xargs`](06-tee-and-xargs/readme.md) — where output goes, and how arguments are built
- [`07-building-a-pipeline`](07-building-a-pipeline/readme.md) — the method: one stage at a time, checking counts
- [`08-incident-07`](08-incident-07/readme.md) — **the incident.** The finding is the last row of your own report.

## Flags in this chapter

**1** — in `08-incident-07`, plus a four-stage chain of `STAGE{...}` receipts that do not register
with `kestrel flags`.

The flag is not written in the lab. It is a station form filled in from three things the student must
produce: an account name taken from a ranked table, an event word looked up from the log's `action`
field, and a frequency word that depends on getting the count exactly right. `grep -r KESTREL` over
the whole chapter returns nothing, in this lab as in every other.
