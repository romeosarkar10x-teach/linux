# 11/02 — Validation

For the AI validator. There is no auto-grader. Judge against this rubric by conversation and by
inspecting the lab.

## Pass requires all of

1. **The list.** States that `PATH` is an ordered, colon-separated list of directories searched left
   to right, first executable match wins. Knows there are seven entries here and that two of them
   (`/bin`, `/sbin`) are symlinks to two others — not a duplicate-search cost, the same directory.

2. **Resolution order.** Names bash's order: alias, function, builtin, hash, `PATH`. Can say why
   `which ls` and `type ls` disagree on this station without calling either broken.

3. **First match wins, and it matters.** Can reorder `PATH` so that `station-status` and
   `deck-report` change behaviour (exercises 17, 19), and can state the consequence: two people run
   the same command name and read different data, with plausible output either way.

4. **Shadowing.** Explains how a directory of overrides in front of `PATH` replaces a system command
   without modifying any system file, and that the shadowed file still passes a checksum. For
   exercise 25, gives the real mechanism — the alias expands and the *first word of the replacement
   text* is resolved through `PATH` — not "the alias didn't apply".

5. **126 vs 127.** 127 = the name resolved to nothing. 126 = it resolved to something that could not
   be executed. Has run both and knows which the non-executable file produces.

6. **The skip.** Knows that with an executable copy further down `PATH`, a non-executable candidate is
   silently skipped (rc 0), and that `Permission denied` / 126 appears only when nothing else on
   `PATH` matches. Has measured both, not reasoned about one.

7. **Five tools, three answers.** Can reproduce the disagreement in exercise 34 and explain the three
   groups. Accepts that no single tool detects the situation (exercise 36).

8. **The hash table.** Can produce a stale-hash error, identifies it by the path in the message that
   they did not type, clears it with `hash -r` or `hash -d`, and knows that assigning to `PATH` —
   even the same value — flushes the table, so the stale case is "the file moved, `PATH` did not".

9. **Editing without regret.** Explains what `PATH=$HOME/bin` (no `$PATH:`) destroys and why the
   shell becomes nearly unusable; states front-vs-back as a trust choice with a reason; identifies
   an empty element as the current directory in all three spellings and names the typo hazard.

10. **Rhea's question.** Gives at least two mechanisms for the same word producing different output on
    two terminals, and proposes a read-only diagnosis (`echo "$PATH"`, `type -a`) rather than editing
    anyone's configuration. Recognises that "the right answer" needs somebody to say which copy is
    authoritative — it is not a fact the machine holds.

## Lab state

Run in the lesson directory:

```
find . -newermt '2187-06-20 09:00:01' -not -path './scratch/*'
```

Should list nothing. Anything listed means they modified the station's files instead of working in
`scratch/`.

```
stat -c '%a' broken/station-status   # 644
stat -c '%a' bin/station-status override/ls   # 755 755
stat -c '%y' notes/path.txt          # 2186-08-02 11:20:00
```

If `broken/station-status` is now 755, they "fixed" it. Ask why they thought that was the task, then
reset — exercises 30–37 are unrecoverable otherwise.

## Red flags

- "`which` is broken" or "`type` is broken." Neither is. They have not understood the question each
  answers.
- Claims a wrapper can be detected from its output. Chapter 8 already told them fd 1 and fd 2 are
  separately redirectable, and a quiet wrapper prints nothing at all.
- Reports 126 and 127 as interchangeable, or reports rc without having run anything.
- "You must `hash -r` after changing `PATH`." Folklore; exercise 45 measures the opposite.
- Proposes fixing rhea's terminal, or editing cass's configuration. She asked whether it could be
  *detected*.
- Any answer to exercises 30–37 that was reasoned rather than run. The whole point is that the
  predicted behaviour is wrong.

## Good signs

- Noticed unprompted that `/bin/ls` and `/usr/bin/ls` share an inode and connected it to chapter 3.
- Said out loud that the wrapper is the same twenty lines whether it is honest or not.
- Asked who decides which directory goes first, and where that decision is written down. That is
  lesson 03.

## If the answers are thin

- "Put `override/` first and run `deck-report`. Which directory does it read from? Now swap. Was
  either program wrong?"
- "Make a file on `PATH` that is not executable, with a working copy further down. Predict the result
  before you run it. Now delete the working copy and predict again."
- "Ask five different tools where `broken/station-status` is. Write down all five answers. Which one
  lied?"
