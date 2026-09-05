# Chapter 14 — Archives, Disks & Integrity

> "It passed. That is not the same as being right."

## Incident briefing

Everything so far has been about reading what is on the station. This chapter is
about moving it, storing it, measuring it, and proving it did not change on the
way — and about the gap between "unchanged" and "correct", which is where the
chapter's incident lives.

It goes in order. First `tar`: create, list, extract, and the three habits that
prevent the three classic accidents — listing before extracting, `-C` instead of
`cd`, and knowing that `-f` takes the next word. Then compression: reading
`.gz` files without decompressing them, gzip eating its input, the difference
between `file` believing a header and `gzip -t` checking a CRC, and a file that
gets *larger* when you compress it. Then disks: `df` asks the filesystem, `du`
walks names, and the space that neither `rm` nor `du` can account for because a
process still holds a deleted file open. Then checksums, and — much more
importantly — the four things a passing checksum does not prove.

Then the incident. The June strain export passes its own `SHA256SUMS`. ops-bot
confirms it. The captain wants it signed off today. It is also missing 235
samples, on five days out of twenty, and those five days are exactly the days
the deck's own readings crossed the clamp threshold. The archive is intact, and
that is the point: every checksum in that directory certifies the damage
perfectly, because they were all computed after it.

The chapter's method accumulates: lesson 01 teaches you to look inside an
archive without extracting it, lesson 02 teaches you to read a file without
changing it, lesson 03 teaches you that a number can be true and answer a
question you did not ask, lesson 04 teaches you exactly what verification
covers — and the incident asks you to audit a piece of evidence while proving,
with a hash you recorded before you started, that you did not touch it.

## Learning objectives

- [ ] Create, list and extract tar archives, and list before extracting every time
- [ ] Say why `-f` must be last among the bundled flags, and recognise what `tar -cfz` actually does
- [ ] Extract with `-C` rather than `cd`, and recognise a tarbomb before it lands
- [ ] Use `--strip-components`, and notice when it silently extracts nothing
- [ ] Explain why tar removes a leading `/` from member names, and what that protects
- [ ] Read compressed files in place with `zcat`, `zgrep`, `zless` and `zdiff`
- [ ] Know that `gzip` replaces its input, and that `-k` is the flag that does not
- [ ] Distinguish `file` reading a header from `gzip -t` verifying a whole stream
- [ ] Read `gzip -l`, and say when its uncompressed size is wrong and why
- [ ] Compare gzip, bzip2 and xz, and name a case where compression makes a file larger
- [ ] Install and remove a package to get a tool you need for one job (`zip`, `ncdu`)
- [ ] Use `df -h`, `df -i` and `du -h --max-depth=1` and say which question each answers
- [ ] Explain disk usage against apparent size: block rounding, sparse files, hard links
- [ ] Find space held by a deleted-but-open file with `lsof +L1` and `/proc/<pid>/fd/`
- [ ] Compute and verify checksums with `sha256sum -c`, and use `--strict`
- [ ] State what a checksum proves, and the four things it does not
- [ ] Recognise that a manifest shipped beside its files proves only self-consistency
- [ ] Audit evidence without altering it, and demonstrate that you did not

## Prerequisites

- Chapter 2 — paths; every `tar -C` and every `du` argument is a path question
- Chapter 4 — `head`, `tail`, `wc -l`; the incident's shortfall is a `wc -l` away
- Chapter 5 — redirection and pipes; `zcat | grep` and `exec 9>` both live here
- Chapter 6 — `grep`, `sort`, `cut`; reading a manifest is a text-processing job
- Chapter 8 — exit status; `gzip -t`, `sha256sum -c` and `manifest-audit` all answer through it
- Chapter 10 — ownership and permissions, which is what tar preserves and zip does not
- Chapter 11 — `PATH`; lesson 02 and 03 install into `/usr/bin`, not `/opt/kestrel/bin`
- Chapter 12 — loops and `read`; the incident's audit is a `while read` over a manifest
- Chapter 13 — `apt` and `dpkg`; lessons 02 and 03 have you install a tool and purge it again

## Lessons

- [`01-tar`](01-tar/readme.md) — create, list, extract; `-f` last, `-C` always, list first
- [`02-compression`](02-compression/readme.md) — reading `.gz` in place, and what `gzip -l` cannot tell you
- [`03-disk-usage`](03-disk-usage/readme.md) — `df` vs `du`, blocks, holes, links, and a file with no name
- [`04-checksums`](04-checksums/readme.md) — `sha256sum -c`, `--strict`, and the four things it does not prove
- [`05-incident-13`](05-incident-13/readme.md) — **the incident.** The export that passed its own checksum

## Roleplay

`05-incident-13/scene.md` — **the captain.** They want the export signed off
today, they have ops-bot's word that it passed, and deck-04 is waiting on the
signature. They never lie and they are not hiding anything. Their one dangerous
move is entirely reasonable: told that files are short, they say "bad export,
we'll re-run it" and move on — which is true, and which would bury the finding.
A cadet who accepts that has ended the investigation with an accurate statement
and nothing else. State the correlation with the clamp threshold and the captain
stops dead, holds the sign-off, and asks for the raw sample store. They will not
accept a name and will say so.

## Flags in this chapter

**1** — in `05-incident-13`, behind a three-stage chain of `STAGE{...}` receipts
that do not register with `kestrel flags`.

The flag is not written in any file. It is base64-encoded inside
`bin/manifest-audit` and printed only when the attestation names the right five
dates *and* the threshold that makes them a finding — dates alone are an
observation, not a conclusion.

The stages are: verify the export against its own checksum; extract a copy and
audit twenty day files against the manifest's line counts; then attest what the
short days have in common. **Stage 3 is the cliff** — stage 2 hands the student
five dates and no reason to care about them, and the captain is standing there
with a plausible explanation. Every stage refuses if the archive's bytes have
moved (exit 3), if the audit is incomplete (exit 4), or if the findings are
wrong (exit 5), and it always says which.
