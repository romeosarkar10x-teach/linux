# Chapter 8 — Streams, Redirection & Exit Codes

> A tool complained every night for fourteen months. The complaint went to a path that gets recycled,
> and the report said `nominal`.

## Incident briefing

Chapter 7 taught you to transform text. This chapter is about where the text *goes* — and, just as
importantly, where the text you never saw went instead.

Every process starts with three open files: standard input, standard output, and standard error. A
program writes its results to one and its complaints to the other, and the caller decides in the
command line which of the two survives. That decision is usually made once, when a wrapper is
written, by somebody who was right about the program at the time.

So the chapter goes in order. Which stream is which, and how to prove it for a tool you did not
write. Then redirection proper: `>`, `>>`, `2>`, `&>`, and the left-to-right ordering rule that makes
`2>&1 >/dev/null` and `>/dev/null 2>&1` opposites. Then here-documents and here-strings, where one
quote character decides whether the shell expands the body. Then pipes at depth — concurrency,
`PIPESTATUS`, `SIGPIPE`, and buffering, which is why a live pipeline can sit silent for a minute and
then emit everything at once. Then exit status: the third channel, the one that carries no words, and
every way it gets clobbered on the way to the caller.

The incident is a summariser that has been reporting `nominal` for fourteen months. The report is
true. It is also fd 1 only, and the tool has been writing a warning to fd 2 for every clamped reading
since 2186 — to a file under `/tmp`, which is recycled. Two of those warnings are about a panel that
is not supposed to clamp at all, on two consecutive nights in May. Nothing was hidden and nothing
lied; a stream was discarded, and a discarded stream cannot be grepped.

## Learning objectives

- [ ] Name the three standard streams and their file descriptors, and prove which one a tool uses
- [ ] Separate a tool's diagnostics from its results without modifying the tool
- [ ] Redirect with `>`, `>>`, `2>`, `2>>`, `&>`, `&>>` and `n>&m`, and say what each does to which fd
- [ ] Apply the left-to-right ordering rule, and explain why `2>&1 >f` and `>f 2>&1` differ
- [ ] Use `/dev/null`, and say what `>/dev/null 2>&1` throws away that you may want
- [ ] Redirect a whole block or loop, and know when that beats redirecting each command
- [ ] Write here-documents with `<<` and `<<-`, and say exactly what quoting the delimiter changes
- [ ] Use here-strings, and say when `<<<` is right and when a pipe or a file is
- [ ] Recognise the failure modes of an unterminated or mis-indented here-document
- [ ] Explain that pipeline stages run concurrently, and demonstrate it
- [ ] Read `PIPESTATUS`, and explain why `$?` alone lies about a pipeline
- [ ] Explain `SIGPIPE` and status 141, and why `seq | head` is not an error
- [ ] Diagnose block buffering and fix it with `--line-buffered`, `stdbuf` or `-u`
- [ ] Use `tee` to keep a stream and pass it on, including for standard error
- [ ] Read `$?`, name 0, 1, 2, 126, 127 and 128+N, and say who produces each
- [ ] Explain exit-status wrapping: 300 is 44, 256 is 0, -1 is 255
- [ ] Chain with `&&` and `||`, and predict `a && b || c` correctly using precedence
- [ ] List the ways an exit status is lost, including `local v=$(cmd)` and a script ending in `echo`
- [ ] State when `set -e` does not fire, and why adding it is often not a fix

## Prerequisites

- Chapter 1 — the shell as a program, and exit status as an idea
- Chapter 2 — paths, so a redirection target means something
- Chapter 4 — creating and truncating files; `>` is a destructive operator
- Chapter 5 — quoting. A here-document delimiter's quotes change the body's meaning
- Chapter 6 — `grep` and its exit status, used throughout as a command with an answer
- Chapter 7 — `sort`, `uniq -c`, `cut` and `awk`, which are the second stage of most pipelines here

## Lessons

- [`01-stdout-stderr`](01-stdout-stderr/readme.md) — two channels, and how to prove which one a tool used
- [`02-redirection`](02-redirection/readme.md) — every operator, and the ordering rule that trips everyone
- [`03-heredocs`](03-heredocs/readme.md) — `<<`, `<<-`, `<<<`, and the one quote that changes everything
- [`04-pipes-deep`](04-pipes-deep/readme.md) — concurrency, `PIPESTATUS`, `SIGPIPE` and buffering
- [`05-exit-codes-and-chaining`](05-exit-codes-and-chaining/readme.md) — the third channel, and every way it gets lost
- [`06-incident-08`](06-incident-08/readme.md) — **the incident.** Fourteen months of nominal.

## Flags in this chapter

**1** — in `06-incident-08`, plus a four-stage chain of `STAGE{...}` receipts that do not register
with `kestrel flags`.

The flag is not written in the lab, and this time that is not a hiding place — it is the subject.
Four words, spoken by a running tool on the channel the nightly wrapper discards, in the order it
first says them. `grep -r KESTREL` over the whole chapter returns nothing, and so does grepping for
the words: a stream that was never written to a file cannot be searched afterwards.

The chain's four stages use the `2>&1 >/dev/null` split, the combined-stream count, standard input via
a here-string, and an exit status read with `&&` — one skill each. The last exercise asks why `tee`
was the wrong tool at every stage.
