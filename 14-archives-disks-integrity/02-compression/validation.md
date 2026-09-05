# Compression — Validation Rubric

Agent rubric only. No script grades this lesson.

## Pass requires all of

1. **Read every log without decompressing it.** The student can state June's
   line count (2161) and the `CLAMPED` counts (4/4/6) and did it with
   `zcat`/`zgrep`. Ask them to show the command. A transcript containing
   `gunzip logs/…` fails this item even if the numbers are right.
2. **Knows gzip replaces its input**, and knows `-k`. Ask: "after
   `gzip records.txt`, where is `records.txt`?" Answer must be "gone".
3. **Distinguishes the two broken files.** `truncated.gz` is not gzip and
   `file` says so; `half.log.gz` *is* gzip, `file` is satisfied, and only
   `gzip -t` reports `unexpected end of file`. A student who says "use `file`
   to check integrity" fails.
4. **Reports the incompressible case as a number.** `sensor-raw.bin` grows by
   53 bytes. "Compression can make files bigger" without the measurement is a
   weaker pass; accept it only if they can say *why* (no redundancy, plus
   framing overhead).
5. **Installed and then removed `zip`/`unzip`** using chapter 13's commands,
   and can say where the binaries landed (`/usr/bin`) and how that differs from
   `/opt/kestrel/bin`.
6. **Exercise 13 answered correctly:** the two 2016-byte logs are *not*
   identical; `cmp` reports byte 47. If they say "same size, same file", this is
   a fail — and the specific thing to send them back to.

## Fail on any of

- Any claim that `gzip -l`'s uncompressed size is always trustworthy.
- Any claim that `zcat` reads `.bz2` or `.xz`.
- Any claim that `zgrep` requires a compressed file.
- Ranking the compressors by the lab's timings and presenting that as evidence.
  The ranking is right; 46 KB does not demonstrate it. Say so.
- A report that the lab's logs "had to" be read compressed because of size. They
  are 144 KB. Exercise 14 exists to catch exactly this, and a student who
  repeats the pitch instead of measuring has not learned the lesson's habit.

## Partial credit

Exercises 49–56 are judgement questions with no single right wording. Accept any
answer that is technically correct and would not mislead a colleague. Reject
answers that are correct but say more than the student measured.

## What to say at the end

Name one thing they verified rather than assumed. That habit is the whole
course; the compression flags are not.
