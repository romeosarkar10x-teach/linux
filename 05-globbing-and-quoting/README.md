# Chapter 5 — Globbing & Quoting

> Housekeeping published its patterns four days in advance, ran at 0300, and removed forty-one
> files. Seven are still there. Five of them are not there by luck.

## Incident briefing

Every command you have typed so far was rewritten before the program you named ever ran. `ls *.log`
does not pass `*.log` to `ls`; the shell expands it first and `ls` receives a list of filenames it
cannot distinguish from ones you typed by hand. That is the single most useful fact about the shell
and the single most common source of destruction in it, because a pattern that expands to the wrong
list looks exactly like a command that did what you asked.

This chapter is the expansion machinery, in the order the shell applies it. Globs first: what `*`,
`?` and `[...]` actually match, why `*` never sees a dotfile, what an unmatched pattern does when
nothing matches it, and the `shopt` switches that change all of that under you. Then brace
expansion, which is not globbing at all — it never touches the disk, it happens earlier, and it
produces names whether or not they exist. Then quoting: three kinds, each switching off a different
subset of the machinery, and the crucial distinction that quoting protects text from the *shell* and
never from the *command*. Then word splitting, `IFS`, and the reason a filename with a space in it
becomes two arguments and a script deletes the wrong thing without reporting an error.

The incident is a four-line housekeeping script and the seven files that survived it. Two of the
four lines are defective, in different ways, and the survivors divide cleanly into the ones that
exploited a defect and the ones that got lucky. Separating those two groups is the work; reading the
result is the flag. The chapter also carries the first chained challenge of the course — four
stages, one per lesson, and deliberately the gentlest chain you will get.

## Learning objectives

- [ ] State the order of shell expansions and place brace, tilde, parameter, glob and splitting in it
- [ ] Match with `*`, `?`, `[abc]`, `[a-z]`, `[!abc]` and POSIX classes like `[[:digit:]]`
- [ ] Explain why `*` does not match a leading dot, and what `dotglob` changes
- [ ] Predict what an unmatched glob does, and change it with `nullglob` and `failglob`
- [ ] Use `globstar`, `extglob` and `nocaseglob`, and say what each costs
- [ ] Distinguish brace expansion from globbing: it precedes it and ignores the filesystem
- [ ] Build sequences and cross products with `{a,b}`, `{01..12}`, `{a..z}`, `{0..30..5}`
- [ ] Say when `{}` produces nothing at all, and why a single-item brace is left literal
- [ ] Quote with `'`, `"` and `\`, and state exactly what each one switches off
- [ ] Explain why quoting cannot protect a filename that begins with a dash, and what `--` is for
- [ ] Describe `IFS`, and the difference between whitespace and non-whitespace separators
- [ ] Distinguish `"$@"`, `$@`, `"$*"` and `$*` by argument count, with arrays too
- [ ] Read files line by line with `while IFS= read -r`, and say what each of the three parts fixes
- [ ] Name the contexts where word splitting does not happen — `[[ ]]`, `case`, `$(( ))`, assignments
- [ ] Debug an expansion with `set -x`, `printf '%q'` and `printf '[%s]\n'`

## Prerequisites

- Chapter 1 — the shell as a program, command lines, `echo`, exit status
- Chapter 2 — `ls` read column by column, and paths that fight back
- Chapter 3 — inodes, link counts, and the three timestamps (the incident needs mtime)
- Chapter 4 — `cp`, `mv`, `rm`, and `rm --` for names that begin with a dash

## Lessons

- [`01-globs`](01-globs/readme.md) — `*`, `?`, `[...]`, dotfiles, unmatched patterns, and the `shopt` switches
- [`02-brace-expansion`](02-brace-expansion/readme.md) — braces are not globs: sequences, cross products, and names that do not exist
- [`03-quoting`](03-quoting/readme.md) — three quotes, what each one switches off, and the layer quoting cannot reach
- [`04-word-splitting`](04-word-splitting/readme.md) — `IFS`, `"$@"` vs `$*`, `while IFS= read -r`, and the scripts that get it wrong
- [`05-incident-05`](05-incident-05/readme.md) — **the incident.** Seven files survived a sweep. Five of them meant to.

## Flags in this chapter

**1** — in `05-incident-05`, plus a four-stage chain of `STAGE{...}` receipts that do not register.

The flag is not written anywhere in the lab. It is five words, one from each of five files, read in
the order a single glob produces them — which is byte order, not the order you would sort them by
hand. Selecting exactly those five files takes one `shopt` from lesson 01, one argument from lesson
03, and the fact from lesson 04 that glob results are not word split. Get the glob wrong by one file
and the phrase is a word short and does not read, which is the naming convention in the lab doing
precisely the job it says it exists to do.
