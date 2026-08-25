# 06/05 — Validation

Rubric for the validating agent. The student passes when they can do the work, not when they can
recite the flags. Ask for commands **and** for the numbers those commands produced.

## Must demonstrate

1. **`-size` rounding.** Ask what `-size 1k` matches. A passing answer says "anything that rounds up
   to one KiB — 1 byte through 1024", not "1024 bytes". Follow up: "give me the predicate for files
   strictly over 32 kilobytes" (`-size +32k`) and "for exactly 512 bytes" (`-size 512c`).

2. **`-mtime` arithmetic.** "You want to delete logs older than a week. Write it." Must be `+7`. Ask
   what `-mtime 7` would have done instead — a passing answer says it matches only the 7-to-8-day
   band and would look like it worked.

3. **A time window.** Ask them to build "everything modified between two given times" from scratch.
   They must produce `-newermt A ! -newermt B` and be able to say which end is inclusive. If they
   cannot say, ask them to demonstrate it with `deck/` and the 04:30/04:35 pair — `marker-after` is
   in the result.

4. **The three `-perm` flavours.** Given `644`, `-644`, `/022`, they must say exact / at-least /
   any-of, and give a question each one is the right answer to. "Find anything writable by group or
   world" must map to `/022`.

5. **`-exec` forms.** Why does `-exec grep pattern {} +` print filename prefixes when `\;` does not?
   Passing: because `+` passes several files to one `grep`, and `grep` prefixes when given more than
   one file. A student who says "`+` is faster" and stops has not understood it.

6. **The `-delete` order trap.** Ask what `find dir -delete -name '*.log'` does. Passing answer: it
   deletes everything under `dir` and `dir` itself, because `-delete` is evaluated first and returns
   true. They should also state the habit — filters first, `-print` before `-delete`.

7. **Names that are not lines.** Ask why `find | xargs` is unsafe and give two fixes (`-print0 |
   xargs -0`, `-exec … +`). They should be able to name at least two of the four hostile characters
   (space, quote, newline, leading dash).

## Should be able to explain

- Why `-user cadet` cannot tell you anything in this lab, and the general principle that follows.
- Why `-newerct '2187-06-09'` returns nothing when every mtime is later than that date — and what
  that fact is good for.
- What `-empty` means for a directory (`notes/dot-only` is not empty).
- Why `find`'s exit status is 0 even when every `-exec`'d command failed.

## Sign-off scenario

Do not accept the lesson as complete until the student answers this cold, with commands:

> A run log covering last night has a stretch where nothing was recorded. You have a tree of a few
> thousand files and you have been told the stretch is roughly between 04:30 and 04:35. You do not
> know what you are looking for. What do you run, and what would make you confident the answer is the
> answer?

Passing shape: build the window with `-newermt A ! -newermt B` over the whole tree; use `-printf` to
show the stamps; observe how many files land inside; if it is one, read it. Confidence comes from the
*count* — one file in a five-minute window in a tree of thousands is a finding, twenty is not. Bonus
credit for checking ctime against mtime before trusting any of the stamps.

A student who reaches for `grep -r` first has not failed, but push back: ask what they would grep
*for*, given they do not know what the file contains.
