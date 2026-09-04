# 12/08 — exercises

Lab: `/labs/12-shell-scripting/08-ship-a-tool`. Your tool ends up in
`~/.local/bin`.

## A. Warmup — the three requirements

1. `cd` into the lab and run `broken/noexec`. Record the message and the status.
2. Fix it with the smallest change, run it again, record the status.
3. Run `broken/bad-shebang`. Record the message and the status **exactly**.
4. The file exists — you just listed it. Read the message again and say which
   thing was not found.
5. Open `broken/bad-shebang` and find the typo. Fix it and re-run.
6. Run `broken/no-shebang`. It works. Now run `sh -c broken/no-shebang`. It also
   works. Write one sentence on why this is still a bug.
7. Run `head -c 20 broken/crlf | xxd`. What is the last byte of line 1, and what
   is the error message it produces?
8. Which of 126 and 127 means "found it, could not run it"? Say the other one
   out loud with both of its causes.

## B. Core — PATH

9. `command -v stationctl`. Record the output and the status.
10. `ls -d ~/.local/bin`. Does it exist? What does `~/.profile` do with it?
11. Create `~/.local/bin`, then run `echo "$PATH"` in your **current** shell. Is
    the new directory there?
12. Explain that result in terms of when `~/.profile` is read (11/03).
13. Get the directory onto PATH in your current shell without starting a new
    one. Say which of the two available methods you used and why.
14. Prove that a **new login shell** would have picked it up anyway.
15. Put a two-line script called `demo` in `~/.local/bin`, make it executable,
    and run it by name from a different directory.
16. `type -a bash`. Why are there two answers, and which one wins?
17. With `demo` in `~/.local/bin` on your PATH, create a second `demo` in a
    directory **earlier** in PATH. Without changing PATH, run `demo` again.
    Which one ran?
18. Now run `hash -r` and run `demo` again. Explain the difference in one
    sentence.
19. Assigning to `PATH` also clears that table. Design a two-command test that
    distinguishes "PATH assignment cleared the hash" from "the hash was never
    consulted", and run it.
20. Remove both `demo` files. Confirm with `command -v`.

## C. Core — read the tool you are replacing

21. Run `examples/logsize --help`. Where did the text go — stdout or stderr?
    Prove it, do not assume.
22. Run `examples/logsize` with no argument. Same text. What is different?
23. Record `logsize`'s status for: `--help`, no argument, a missing file, a real
    file.
24. Run `examples/deckinfo cargo`. Now run it with **no** argument. Explain the
    output.
25. That behaviour comes from one unquoted, unchecked expansion. Name it and say
    what `grep` does with an empty pattern.
26. Run `examples/deckinfo 01` and `examples/deckinfo engineering`. Both work.
    Is that a feature? Write one sentence you would put in its `--help`.
27. `deckinfo` has a hard-coded absolute path in it. Name two ways that hurts
    somebody who is not you.
28. Run `examples/deckinfo deck-99` and record the status. It is not 0 — but
    the tool never decided that. Say where that status came from, and why an
    accidentally-correct status is still a bug.
29. List every one of the six shipping requirements from `notes/shipping.txt`
    that `deckinfo` fails.
30. Read `notes/page.txt`. In one sentence, say what it cost the station that
    the note was never followed up — using only what you found in exercises
    24–29.

## D. Core — build `stationctl`

Write `~/.local/bin/stationctl`. Work in `scratch/` and copy it over, or edit it
in place; your choice, but say which.

31. Start with the header from 12/07, a comment block listing the exit codes,
    and a `usage()` function. Make `--help` work and nothing else. Test it.
32. Confirm `--help` goes to stdout and exits 0, and that no argument at all
    goes to stderr and exits 64. Use redirection to prove both.
33. Add `--version`, printing `stationctl 1.0`.
34. Add the `case` dispatch with an explicit unknown-command branch. Test
    `stationctl wobble` and check the status.
35. Add `: "${STATIONCTL_DATA:=$LAB/data}"` with the lab path as the default.
    Explain why `:=` and not `=`.
36. Add a check that the data directory exists, exiting 66 with a message that
    names the path.
37. Implement `decks`: print the deck ids and names, one per line, from
    `decks.txt`.
38. Implement `faults` with no argument: for each deck that appears in
    `faults.txt`, print the deck and its count, highest first.
39. Implement `faults DECK`: the count for one deck. Print `0` for a deck that
    exists with no faults; exit 66 with a message for a deck that does not
    exist at all. Say why those two cases must differ.
40. Implement `check`: exit 1 and report if any deck has more than two faults,
    exit 0 silently otherwise. Which deck trips it?
41. `check` exits 1. That is not an error. Show where in `--help` you said so,
    and why it matters to whoever puts this in a pipeline.
42. Run `stationctl` from three different directories, including `/`. It must
    behave identically. If it does not, you have a relative path in it.
43. `shellcheck ~/.local/bin/stationctl`. Fix everything, or justify each
    disable in one sentence.
44. Hand your `--help` to someone (or to the tutor) who has not seen the tool.
    Can they list the decks without asking you a question? If not, fix the help,
    not the person.

## E. Experiment — predict first

45. Predict the status of `stationctl --help > /dev/null 2>&1`, then of
    `stationctl 2>/dev/null` with no argument. Run both.
46. Predict what `STATIONCTL_DATA=/nonexistent stationctl decks` does. Run it.
    Was the message good enough to act on?
47. Predict what happens if you `chmod -x ~/.local/bin/stationctl` and run it by
    name. Write the status down first.
48. Predict what `stationctl faults ''` does. Run it. Fix whatever you find.
49. Predict what happens with a deck name containing a space, then create one in
    a copy of the data and try it.
50. Predict the output of `PATH=/usr/bin stationctl decks`. Run it, and explain
    the status you got in terms of exercise 8.

## F. Stretch

51. Add `stationctl faults --json`, emitting one object per deck. No `jq`
    required to produce it; quoting is the whole exercise.
52. Make `check` accept `--threshold N`, defaulting to 2. Validate that N is a
    number (12/06) and exit 64 if it is not.
53. Write a `--help` for `examples/deckinfo` without changing what it does, then
    write the one sentence you would leave in `notes/` for the next person.
54. Put `stationctl` under `git` in `scratch/` and commit it with a message that
    names the interface, not the implementation.

## G. Dig

55. `type`, `command -v` and `which` are three different things. Find out which
    of them is a shell builtin and which is a separate program, and say why a
    script should use `command -v`.
56. `env -S` exists specifically to work around the shebang-options limit. Find
    it in `man env` and write the shebang line that would give you
    `bash -euo pipefail` directly.
57. Find the flag to `command` that makes it ignore functions, and construct a
    case where a script breaks without it.

## H. Bring it together

58. Read `notes/shipping.txt` once more and score your own `stationctl` against
    all six, honestly, in writing.
59. `deckinfo` was left undocumented in 2186 with a note saying it would be
    written up later. Your tool is now the newest thing in the ops tree. In two
    sentences, say what you have written down that makes it different, and where
    you wrote it.
