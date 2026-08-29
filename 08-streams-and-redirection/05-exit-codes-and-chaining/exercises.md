# 08/05 — Exercises: exit codes and chaining

```
cd /labs/08-streams-and-redirection/05-exit-codes-and-chaining
ls -F
```

Chapters 1–8 tools. Wrecked the lab? `kestrel reset 08/05`. Work in `scratch/`; do not edit `bin/`.

`bin/rc N` exits with status N and prints nothing. Use it whenever you need a command with a known
answer.

---

## Warmup — the number nobody prints

**1.** `cat notes/status.txt`. Then `cat notes/page.txt`. Write down cass's last sentence; you will
be explaining it at exercise 60.

**2.** `true; echo $?` and `false; echo $?`. Two numbers. Now `type -t true` — is `true` a program?

**3.** `bin/rc 3; echo $?`. `bin/rc 0; echo $?`. Confirm `rc` prints nothing at all — check both fds.

**4.** `bin/rc 3; echo $?; echo $?`. Two different numbers. Explain the second one.

**5.** `bin/rc 3; rc=$?; echo "saved $rc"`. Why is this the only reliable pattern?

**6.** `bin/rc 3; if [ -n "x" ]; then :; fi; echo $?`. Predict, then run. Which command's status did
you print?

**7.** Does a successful command clear `$?` immediately, or does the shell keep a history? Test.

## What the numbers mean

**8.** `grep p-01 data/readings.txt >/dev/null; echo $?`. Then `grep zzz …`. Then
`grep p-01 /nope 2>/dev/null; echo $?`. Three numbers. Which is "no" and which is "I could not
answer"?

**9.** Why does that distinction matter for `if grep -q PATTERN file; then …`? Construct the case
where the `if` gives you the wrong answer.

**10.** `diff data/readings.txt data/readings.txt; echo $?` and diff two different files. Same
pattern as `grep`?

**11.** `nosuchcommand; echo $?`. What number, and who produced it — the shell or the command?

**12.** `bin/notexec; echo $?`. Different number. `ls -l bin/notexec` and explain.

**13.** `./data; echo $?`. Same number as 12. Why is a directory in the same category?

**14.** `bash -c 'kill -INT $$'; echo $?` and `kill -TERM $$`. Two numbers. Show the arithmetic that
produces each from the signal number.

**15.** From lesson 04: which status did the writer of `seq 1 100000 | head -1` get, and which signal
is that?

**16.** `bin/rc 300; echo $?`. Not 300. `bin/rc 256; echo $?`. Explain both, and say what is dangerous
about the second.

**17.** `bin/rc -1; echo $?`. What happened? Write the rule about computing exit codes.

**18.** `man grep`, EXIT STATUS section. Then the same for `diff` and `sort`. Which of the three
documents a code you would not have guessed?

## Chaining

**19.** `true && echo yes`. `false && echo yes`. `true || echo no`. `false || echo no`. Four runs,
state the rule for each operator.

**20.** `bin/rc 0 && echo A; bin/rc 7 && echo A`. Which ran, and what was `$?` at the end of each
line?

**21.** `false; echo $?` versus `false || true; echo $?`. What did `||` do to the status?

**22.** `true && echo B || echo C` → B. `false && echo B || echo C` → C. Now `true && false || echo C`.
Predict first. Then explain the result using the words *left to right*.

**23.** Rewrite exercise 22's third command as a real if/else so that `C` runs only when the first
command fails.

**24.** `false && { echo b; echo c; } || echo fallback`. What ran? Now remove the braces and predict
the difference.

**25.** `{ bin/rc 3; true; } && echo ok`. Does `ok` print? Whose status did `&&` test?

**26.** Write a chain that runs `b` and `c` **only** if `a` succeeded, and `d` only if `a` failed,
without using `if`. Then say why you would use `if` anyway.

**27.** `! bin/rc 3; echo $?` and `! bin/rc 0; echo $?`. What does `!` do to a non-zero status other
than 1? Is the original number recoverable?

**28.** `! bin/rc 3 | cat; echo "$? ${PIPESTATUS[*]}"`. Two answers. What did `!` invert, and what
survived?

**29.** `a ; b` versus `a && b`. Give a real case where using `;` where you meant `&&` destroys data.

**30.** `cd /nonexistent; rm -rf ./*` — do not run this. Explain, with exercise 29 in hand, exactly
what would happen and what the two-character fix is.

## Statuses that get lost

**31.** `x=$(bin/rc 4); echo $?`. The status survived. Which status is it?

**32.** `f() { local v=$(bin/rc 7); }; f; echo $?`. Now
`g() { local v; v=$(bin/rc 7); }; g; echo $?`. Two answers. Explain the difference.

**33.** State the rule from 32 in one sentence, and say which other declaration keywords it applies to.

**34.** Write a script in `scratch/` whose last command is `echo done` and which is *supposed* to
fail. Run it, check `$?`. This is the lab's bug in miniature.

**35.** Fix your script two ways: with `exit "$rc"` at the end, and by making the failing command the
last one. Which do you prefer in a script somebody else maintains?

**36.** `bash -c ''; echo $?` — an empty script. And `bash -c 'exit'`. What is the status when nothing
ran?

**37.** `while false; do :; done; echo $?`. A loop whose body never ran. Why 0?

**38.** `time bin/rc 6; echo $?`. Does `time` change the status?

## The bank walk

**39.** `bin/checkbank A`. Read the output. `echo $?`.

**40.** `bin/checkbank B`. Read all three lines and note which fd each is on. Now `echo $?`.

**41.** State the contradiction in one sentence: what does the output say, and what does the status
say?

**42.** `bin/checkbank Z; echo $?`. So the script *can* report failure. What is different about the Z
path?

**43.** Read `bin/checkbank`. Find the last command that runs on the B path. Why does the script exit
0?

**44.** `bin/checkbank-fixed B; echo $?`. Now diff the two scripts. What are the three changes, and
which one actually matters?

**45.** `bin/checkbank B >/dev/null 2>&1 && echo "ok"`. This is what the wrapper does. What prints?

**46.** Read `bin/deckcheck`. Which construct is it using to decide ok versus FAILED?

**47.** `wc -l logs/deckcheck.log`, then run `bin/deckcheck`, then `tail -4`. What did it record for
bank B?

**48.** Copy `deckcheck` to `scratch/`, point it at `checkbank-fixed`, run it, and `tail -4` again.
What changed?

**49.** cass's log has said `ok` every night for months. Is the log wrong? Answer carefully — say what
the log is a true record *of*.

**50.** Two people have reported that bank B does not answer, and the walk disagreed with them every
night. Which of the two would you have believed before this lesson, and what would have changed your
mind?

## `set -e`

**51.** `bash -c 'set -e; bin/rc 3; echo "still here"'`. Did it abort?

**52.** `bash -c 'set -e; bin/rc 3 && echo yes; echo "still running"'`. Now? Explain using the
exception list in the readme.

**53.** `bash -c 'set -e; f(){ bin/rc 3; echo unreachable; }; f && echo "f ok"; echo end'`. Read the
output carefully. How many of the three echoes printed, and what does that say about `set -e` inside
a function used as a condition?

**54.** `bash -c 'set -e; if bin/rc 3; then echo t; else echo f; fi; echo end'`. Why no abort?

**55.** From lesson 04: does `set -e` catch a failing first stage of a pipeline? What must you add?

**56.** Write the four-line summary of when `set -e` does **not** fire. Keep it to four.

**57.** Rewrite `bin/deckcheck`'s decision explicitly, with no reliance on `set -e`, so that a failed
bank makes the whole walk exit non-zero at the end while still checking every bank.

## Reporting

**58.** Write cass three sentences: what the walk actually tests, why the log says ok, and the
one-line change. Do not use the word "bug".

**59.** cass will ask "is the log worthless?". Answer in one sentence that is fair to the log.

**60.** Explain cass's last sentence — "I do not think the walk is lying, I think it is not being
asked the question" — in terms of exit status. Two sentences.

**61.** Somebody proposes `set -e` at the top of every script as the fix. Give the strongest argument
against relying on it here, using exercise 53.

**62.** Write the check you would add to the nightly walk so that this class of bug is caught by the
walk itself rather than by a person.

## Experiment

**63.** Write `retry N CMD…` in `scratch/`: run the command up to N times until it succeeds, return
its status. Test with `bin/slowfail` and with `bin/rc 0`.

**64.** Write `try CMD…` that prints `ok` or `FAILED (status N)` and preserves the original status as
its own. Test it on `bin/rc 0`, `bin/rc 2`, `nosuchcommand`, and `bin/notexec`.

**65.** Add a `2>&1 | tee` to `try` from 64 and check whether its status still works. Explain what you
had to do (lesson 04 has the answer).

**66.** Make a command that exits 128+N without being killed by a signal: `bin/rc 130`. Can you tell
the difference afterwards from `$?` alone? What would you need instead?

**67.** `bin/slowfail` takes a second and exits 5. Wrap it in a chain that reports the failure and
also records how long it took, without losing the status.

**68.** Prove that `a && b || c` and `if a; then b; else c; fi` are different, with a single test case
whose result differs. Write both, run both.

## Stretch

**69.** `checkbank` exits 2 for an unknown bank and 0 for a broken one. Argue for a code scheme for
this tool: which failures deserve distinct numbers, and where you would stop.

**70.** A wrapper turns any non-zero status into a log line and then exits 0 itself, so its own caller
sees success. Sketch that wrapper in five lines and then say what it should have done instead.

**71.** `logs/deckcheck.log` is a true record of a question that was never asked. Name two other
places on a station where a log could be true and useless in exactly this way.

**72.** `exit 256` is 0. Write the two-line guard you would put in a script that computes its own
exit code from a count of errors.

**73.** Chapter 8's incident is a diagnostic tool that prints a clean report and exits zero. From this
lesson alone, list the ways "exits zero" can fail to mean "nothing was wrong". One line each. Do not
go looking for the tool.
