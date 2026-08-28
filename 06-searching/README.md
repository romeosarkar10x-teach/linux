# Chapter 6 — Searching: grep, regex & find

> Nineteen entries are gone from a run log, and the file reads perfectly. The only reason anyone
> can prove it is that the monitor numbered its own lines.

## Incident briefing

Chapter 5 taught you that the shell rewrites your command before the command runs. That gets you a
list of *names*. This chapter is about the two questions names cannot answer: **which files contain
this**, and **which files are like this**. The first is `grep` and the regular expressions it reads.
The second is `find`, which walks the tree asking a question of every entry it meets and acts on the
ones that say yes.

Both tools reward precision and punish approximation, and both fail in the same quiet way: they give
you a plausible answer to a question you did not mean to ask. A pattern that is slightly too loose
returns extra lines you will not notice; a pattern slightly too tight returns fewer, and looks like a
clean result. `grep -c '^#'` and `grep -c '^#[0-9]'` differ by two in this chapter's incident, and
the two is a pair of header lines that the first pattern silently counted as data. That is the whole
subject: knowing what your pattern actually matched, not what you hoped it would.

So the chapter goes slowly. Fixed strings first, then the flags that change what `grep` *reports*
rather than what it matches, then regular expressions in both dialects with the differences named
explicitly, because BRE and ERE disagree about which characters need a backslash and nothing about
the error message tells you which one you are in. Then `find`: its expression syntax, why the order
of its predicates changes the answer, and `-exec` in both its forms. Then the index tools — `locate`,
`which`, `type`, `whereis` — which are fast because they are answering from a snapshot, with all the
consequences that implies.

The incident is a log with entries removed from the middle of it. Every surviving line is correct,
nothing says `error`, and reading the file is useless. The finding comes from counting, and from the
fact that the writer numbered every entry: 701 entries across a declared range of 720. A second
monitor's log looks far worse and is entirely innocent. Telling those apart is the chapter.

## Learning objectives

- [ ] Search fixed strings with `grep`, and read its exit status as a question answered
- [ ] Use `-i`, `-v`, `-w`, `-x`, `-F` and say which change matching and which change reporting
- [ ] Use `-n`, `-c`, `-l`, `-L`, `-o`, `-q`, `-r`, `-h`, `-H` and `-A/-B/-C` deliberately
- [ ] Explain why `grep -c` counts matching *lines*, not matches, and what `-o` changes
- [ ] Write basic regular expressions: anchors, `.`, `*`, classes, ranges, POSIX classes
- [ ] Write extended regular expressions: `+`, `?`, `|`, `()`, `{n,m}`, and back-references' limits
- [ ] State exactly which metacharacters need escaping in BRE and not in ERE, and vice versa
- [ ] Say why a regex must be quoted, and which shell characters would otherwise eat it
- [ ] Search a tree with `find`, filtering by `-name`, `-iname`, `-path`, `-type` and `-size`
- [ ] Filter by time with `-mtime`, `-mmin` and `-newermt`, and pick the right one for the question
- [ ] Combine predicates with `-a`, `-o`, `!` and parentheses, and explain short-circuit evaluation
- [ ] Explain why `-print` after an `-exec … \;` is a test and after an `-exec … +` is not
- [ ] Choose between `-exec … \;`, `-exec … +` and `xargs`, and say what each costs
- [ ] Use `-prune`, `-maxdepth` and `-xdev` to stop a search going where it should not
- [ ] Describe how `locate` answers from an index, and every way that index can be wrong
- [ ] Distinguish `which`, `type`, `command -v` and `whereis`, and say which one to trust

## Prerequisites

- Chapter 1 — the shell as a program, exit status, and reading `man`
- Chapter 2 — paths, `ls -A` and hidden files, absolute versus relative
- Chapter 3 — file types and the three timestamps; the incident turns on mtime versus ctime
- Chapter 4 — creating and removing files, so the experiments in lesson 05 are safe to run
- Chapter 5 — quoting. Every pattern in this chapter must survive the shell before `grep` sees it

## Lessons

- [`01-grep-basics`](01-grep-basics/readme.md) — fixed strings, exit status, and what a "match" is
- [`02-grep-flags`](02-grep-flags/readme.md) — the flags that change matching, and the ones that only change output
- [`03-regex-bre-ere`](03-regex-bre-ere/readme.md) — two dialects, the escaping table, and the errors neither one reports
- [`04-find-basics`](04-find-basics/readme.md) — walking a tree by name, type, size and time
- [`05-find-advanced`](05-find-advanced/readme.md) — operators, precedence, `-prune`, and `-exec` in both forms
- [`06-locate-which-type-whereis`](06-locate-which-type-whereis/readme.md) — answers from an index, and the four ways to ask "where is this command"
- [`07-incident-06`](07-incident-06/readme.md) — **the incident.** Nineteen entries that were never written down as missing.

## Flags in this chapter

**1** — in `07-incident-06`, plus a four-stage chain of `STAGE{...}` receipts that do not register
with `kestrel flags`.

The flag is not written in the lab. It is five words spelled by five fields of one form, in a file
whose name begins with a dot and whose modification time is the only one that falls inside the
five-minute hole in the log. Finding it needs a timestamp window from lesson 05, a count from lesson
02, and an extended pattern from lesson 03. `grep -r KESTREL` over the whole chapter returns nothing,
in this lab as in every other.

The chain's four stages use `find -newermt`, `grep -c`, ERE with `grep -o`, and `find -exec` — one
skill each, none of them `locate`, and the last exercise asks you to say why `locate` could not have
helped at any stage.
