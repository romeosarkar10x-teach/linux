# 12/01 — solutions

Tutor note: exit statuses and error strings below were measured in the course
container. If a student reports something different, believe the student's
terminal first and check the interpreter path.

## A

1. `bin`, `broken`, `notes`, `ops`. `notes/` first — the page and the notes are
   the only files that say why any of the rest exists.
2. `#!/usr/bin/env bash`. The kernel runs `/usr/bin/env` with arguments `bash`
   and the script's path; `env` finds bash via `PATH` and execs it.
3. Claims housekeeping; actually prints one fixed line, `cleanup complete, 0
   files removed`. It removes nothing and checks nothing.
4. That the run was fine. Its evidence is the script's own log line and its exit
   status — both of which the script chose.
5. `-rwxr-xr-x cadet crew` — all four executable by everyone.
6. `no-bit.sh` is `644`. `./broken/no-bit.sh` gives `Permission denied`, 126.
7. `#` and `!` (`0000000   #   !`). The kernel checks that two-byte magic number
   before deciding whether to treat the file as a script.

## B

8. `14`.
9. Yes, `14` — the shebang is bypassed but the body is the same.
10. Yes. Not luck: the body is one `wc -l < file` redirection, which is POSIX
    and behaves identically in dash.
11. Prints `[]`. `bash` forked a new process; its variables died with it.
12. Prints `[alpha]`. Sourcing runs the lines in the current shell — no second
    process to lose the assignment in.
13. Yes it works without `+x`: `chmod 644 scratch/setter.sh; . scratch/setter.sh`
    still sets `DECK`. Sourcing reads the file, it does not execute it.
14. `bash` version: `pwd` unchanged. Sourced: `pwd` is `/tmp`. Same reason.
15. It confirms the assignment landed in *this* shell — `unset` here removes it,
    and re-sourcing brings it back.
16. Source when you want the file to change your shell; execute when you want it
    to do a job. Sourced: `~/.bashrc`. Executed: any tool on `PATH`.
17. `[]`. The inner `bash` is a grandchild; the middle shell never saw `DECK`.

## C

18. `bash: ./broken/no-bit.sh: Permission denied`, status `126`.
19. `bash` is being executed, not the script; the script is only *read*, and it
    is readable.
20. All three `x` bits (mode `644`).
21. `cp broken/no-bit.sh scratch/ && chmod +x scratch/no-bit.sh && ./scratch/no-bit.sh`.
22. `700` works (you are the owner). `600` fails. The kernel checked the **owner**
    triad and stopped there — first match, no fallthrough (10/04).
23. `126` — found, not permitted.
24. `bash: ./bin: Is a directory`, also `126`. Same class: the thing exists and
    cannot be executed.

## D

25. `cannot execute: required file not found`, status `127`. `/usr/local/bin/bash`
    does not exist. Note the message says nothing about the interpreter.
26. Works. Only the *kernel* reads shebangs, and only when executing the file.
27. `ls -l /usr/local/bin/bash` → no such file; bash is `/usr/bin/bash`. Change
    line 1 to `#!/usr/bin/env bash` (or `#!/usr/bin/bash`).
28. `/usr/bin/env: ‘bash\r’: No such file or directory` plus
    `use -[v]S to pass options in shebang lines`, status `127`. The interpreter's
    name is literally `bash\r`.
29. `cat -A` shows `#!/usr/bin/env bash^M$` — the `^M` is a carriage return, at
    the end of every line, and on line 1 it is part of the argument.
30. `tr -d '\r' < broken/crlf.sh > scratch/crlf.sh && chmod +x scratch/crlf.sh && ./scratch/crlf.sh`.
31. `./broken/wrong-shell.sh: 2: Syntax error: "(" unexpected` — line 2, the `(`
    of the array assignment. Status `2`.
32. `#!/bin/sh`, and `/bin/sh -> dash`. `sh` here is dash, not bash. Arrays are a
    bash extension.
33. The shebang chose the interpreter and the interpreter chose the grammar; run
    it under bash and the same bytes are valid.
34. bash, finding no shebang and no valid magic number, runs the file itself as
    a shell script. That is bash's fallback, not a kernel rule.
35. `./scratch/ns.sh` prints `[b][5.2.21(1)-release]` — bash found no shebang
    and ran the file *itself*, so bash grammar applies. Under `find -exec` the
    same file gives `./ns.sh: 1: Syntax error: "(" unexpected` — `execvp` hit
    `ENOEXEC` and fell back to **`/bin/sh`**, which here is dash. So the
    fallback exists, but the interpreter it picks is not yours: it is bash only
    when bash happens to be the caller. That is the argument for the shebang.
    (Note the `find` invocation still reports 0 — the failure is inside the
    child and `find` does not pass it on.)
36. Loudest → quietest: `crlf` (names a bogus interpreter), `bad-interpreter`
    (127 immediately), `wrong-shell` (syntax error, line number), `no-bit` (126,
    obvious once you `ls -l`), `no-shebang` — last, because it *works today* and
    fails only when something about the caller changes.

## E

37. `doing the thing`, status `3`. `exit` ends the script immediately.
38. `checkpoint`, status `1`, from `false`.
39. Status becomes `0`. Adding a successful last line silently changed what the
    script reports about the failure above it.
40. "A script reports the status of whatever ran last, so one trailing `echo`
    turns every failure above it into a success as far as the caller is
    concerned."
41. `0`. It is a claim about the last `echo` succeeding and about nothing else.
42. `ls: cannot access '/nope': No such file or directory` on **stderr**, status
    `2`. The message went to fd 2 and was never part of the script's output.
43. `ls /nope; exit 0` or `ls /nope || true`.
44. `cmd; rc=$?; ...more...; exit "$rc"` — capture immediately, because `$?` is
    overwritten by the next command.
45. `no`. Status `0` is true; anything else is false.

## F

46–48. Working form:
```bash
#!/usr/bin/env bash
# Deck count is asked for at every shift handover; this saves the lookup.
LAB=/labs/12-shell-scripting/01-first-script
wc -l < "$LAB/ops/decks"
```
The relative version breaks from `/tmp` because the path is resolved against the
*caller's* working directory, not the script's location.

49. ```bash
    [ -f "$LAB/ops/decks" ] || exit 4
    ```
    Test with `mv ops/decks ops/decks.bak` and `echo $?`; move it back.
50. It runs. Extensions are a convention for humans; the kernel reads the magic
    number and the mode.
51. `file` reads the first bytes: `bin/greet: Bourne-Again shell script, ASCII
    text executable`, `ops/decks: ASCII text`. It is reading content, not the
    name and not the mode.
52. `PATH="$PWD/scratch:$PATH"` then `hello` from `/tmp`; `PATH=${PATH#*:}` or
    open a new shell to undo. This is 11/02.
53. `echo $PATH` — no `.` and no empty field. Leaving it off means a file named
    `ls` in a directory somebody else can write to never becomes your `ls`.
54. `#!/bin/sh` wins — only line 1 is a shebang; line 2 is a comment.
    `$BASH_VERSION` prints empty, proving dash ran it.
55. `#!/bin/cat` makes the kernel run `cat` with the script as its argument, so
    the script prints *itself*, shebang line included. Status `0`.
56. `exit 1` in a file (or `false`); `exit 0` (or `true`). No shebang needed if
    run with `bash`, but include one.

## G

57. It is evidence that the last command in the script succeeded. It is not
    evidence that any file was examined, that any file was removed, or that the
    thing the script is named for happened at all.
58. Something that makes the report derive from the work — e.g. count what it
    actually removed and print that count, and `exit` nonzero if the tree it was
    supposed to read is missing. The point is that the number must be computed,
    not typed.
59. (1) `head -1` — is the shebang path real? (2) `ls -l` — is the exec bit set,
    and are the directories on the path traversable? (3) `cat -A` — are the line
    endings ours?
60. Useless: `# count the lines`. Useful: `# Asked for at every handover; the
    record file moves, this doesn't.` The code already says what; a comment
    earns its place by saying why.
