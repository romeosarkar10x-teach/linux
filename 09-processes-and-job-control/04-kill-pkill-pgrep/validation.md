# 09/04 — Validation: kill, pkill and pgrep

For the validator agent. Judge understanding, not phrasing.

## Must be right

1. **`pgrep` selects, `pkill` selects and signals, same matching.** And that the working habit is to
   run `pgrep -a` with the pattern first and read it. A student who cannot state the habit has missed
   the lesson even if they can recite every flag.
2. **Default matching is `comm`**, which is the basename of the executing file, fifteen characters
   wide, and *not* the name of a script. `-f` matches the whole command line.
3. **The pattern is an ERE and it is unanchored.** They must be able to say why `panel-mon` matches
   `panel-monitor` and why `panel*` matches `pane`.
4. **The failure is silent.** No warning, no error, one extra pid. If they think a mistake here would
   announce itself, they have not understood the risk.
5. **A concrete fix.** Any of `-x`, an anchored pattern, or a trailing space — with a reason. "Be
   careful" is not a fix.

## Should be right

- `-a` over `-l` over bare output, and `-e` on every `pkill`.
- `-P` takes a pid and must be used before the parent is killed (exercises 27–29).
- rc 1 means "nothing matched" and is not an error (exercise 24, 34).
- `killall` matches names exactly, `pkill` matches substrings — and which of the two is the more
  conservative default.
- `pgrep` excludes its own pid; `ps | grep` cannot.

## Worth pushing on

**Exercise 22.** `pkill -e` prints `comm`, not what you searched for. A student who noticed the
receipt said `bash` has read their own output, which is more than most people do.

**Exercises 37–37b.** Process groups. Full credit needs: a negative pid signals a group; the group is
set by the shell that created the job; an interactive shell gives each job its own group and a script
does not, so the group-kill in a script includes the script. Partial credit for the first two — the
third is genuinely surprising and it is fine if they had to run it to believe it.

**Exercise 43.** `pgrep` matches zombies, so `pgrep` rc is not a liveness check. A student who
connects this back to lesson 03 without being prompted has a working model.

## Red flags

- Reaching for `pkill -f` with a short pattern after having done exercise 13. Ask them to say what it
  matches, out loud, before they run it.
- Believing `-c` is a safety feature.
- Answering exercise 41 or 42 with "be careful" or "double-check". Both questions ask for commands.
- Any answer to exercise 36 that does not include the student's own shell.

## Not required

- `--ns`, `--nslist`, `--cgroup`, `-L`, `-F` (exercise 51 asks only for one sentence about `--ns` and
  "it does nothing useful in here" is the whole answer).
- `-w`/`--lightweight` and thread selection.
- The exact number in any count. The numbers move; the reasoning does not.
- `bg`/`fg`/`jobs` — lesson 05.
- Anything about `/proc/<pid>/environ` beyond exercise 55's "record it before you kill it".

## Reporting exercises

39 says what was *matched*. Reject an answer that only says what was intended — that is the failure
mode the shift log was written to prevent. 40 must use the identical pattern in both commands; if the
`pgrep` and the `pkill` differ, the preview proved nothing and the student should be told so plainly.
