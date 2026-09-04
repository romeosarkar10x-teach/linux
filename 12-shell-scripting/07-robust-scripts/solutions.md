# 12/07 — solutions

All outputs measured in the container.

## A. `set -e`

1. Nothing after `false` printed; status 1.
2. `after` printed; status 0.
3. `bin/e-limits` prints claims 1–3 and dies on the bare `false`, status 1.
   Claim 4 never prints. The surprise for most people is 1: a failing command in
   a condition position is *expected* to fail, so `-e` ignores it.
4. `false &&` is a condition — `-e` is off for the left of `&&`.
5. Same, for `||`. This is why `cmd || handle` is the idiom for "handle this
   failure myself".
6. `survived`, status 0. `!` inverts, and `-e` never fires on an inverted
   command.
7. ```
   check: still running after false
   condition was true
   script reached the end
   ```

   Status 0.
8. Because the whole call was a condition, and `-e` is disabled for everything it
   reaches — including the inside of a function. The function then returned 0
   because its last command succeeded.
9. ```bash
   if ! check; then echo "check failed" >&2; exit 1; fi
   ```

   is still inside a condition. The version that actually helps is to make
   `check` report properly and call it outside a condition:

   ```bash
   check() { false || return 1; echo "not reached"; }
   check || { echo "check failed" >&2; exit 1; }
   ```

   The rule: if you want a failure detected, check the status yourself. `-e`
   will not do it for you in a condition.
10. `after` does **not** print; status 1. Called plainly, a function is an
    ordinary command and `-e` applies. Called as a condition, it is not. Same
    function, two behaviours, decided by the caller.
11. Yes: a script whose last command is `false` exits 1 — but that is true
    without `-e` too, since a script's status is its last command's.
12. `set -e` is for the failures you did not anticipate: it turns "kept going
    with wrong data" into "stopped". It is not a correctness proof — it is off in
    every place you wrote a condition, it cannot see a wrong answer that exits 0,
    and everything you actually care about still needs checking by hand.

## B. `-u` and `pipefail`

13. ```
    with a default: default
    without one:
    bin/u-demo: line 5: missing: unbound variable
    ```

    Status 1.
14. No. `-u` is about *unset*, not empty. `${v:-x}` and `[ -z "$v" ]` are what
    handle empty.
15. `default`, then:

    ```
    bash: missing: not set
    ```

    Status 127 from `bash -c`. `:?` is the way to fail with a message that names
    the variable — much better than a stack of `[ -z ]` checks.
16. Without a check: `line N: $1: unbound variable`, which tells the *user*
    nothing. With the check first: your usage line and exit 64. Guard before
    first use; the error you write is always better than the one bash writes.
17. `0` — the pipeline's status is the last stage's, and `true` succeeded.
    `1` — pipefail reports the leftmost failure. `141` — see 19.
18. The **last** stage's.
19. `kill -l 13` is `PIPE`. `head` exits after one line, `yes` writes to a closed
    pipe, gets SIGPIPE, and dies with 128 + 13 = 141.
20. Neither. Everyone behaved correctly; `pipefail` is reporting a truth you do
    not want to act on. That is the trade.
21. ```bash
    if ! out=$(yes | head -1); then :; fi     # or:
    out=$(yes | head -1) || true              # commented, deliberately
    ```

    Better still, avoid the early-exit pipeline: `head -1 < file`.
22. `set -x` prints each command **after** expansion, so you see the actual
    filename with its spaces, the actual value of the variable, and the order the
    shell chose. It is the fastest way to settle a quoting argument.

## C. Quoting and `cd`

23. `dir=$1` (harmless in an assignment), `cd $dir`, `> $out`, `echo wrote $out`.
    Plus `$(ls | wc -l)`, which is fine only because `wc` prints a bare number.
24. `wrote /tmp/summary.txt` — and it wrote `files: N` into `/tmp`, a path baked
    into the script.
25. `cd` with an empty argument is `cd` with **no** argument, which is `cd
    $HOME`:

    ```
    PWD=/home/cadet
    ```

    Status 0. The script then counted the files in your home directory and
    reported them as the answer, successfully.
26. It runs `cd` on the first word only, fails or lands somewhere wrong, and
    counts the wrong thing — again with status 0.
27. ```
    files: 4          rc=0
    usage: safe DIR   rc=64
    not a directory: nope   rc=66
    ```
28. `[ $# -eq 1 ] || usage` for the argument count; `"$dir"` quoted for the
    space; `[ -d "$dir" ]` for the missing directory; `set -e` for everything
    below.
29. Because after a failed `cd` the script keeps running **in the old
    directory**, and every relative path in it now points somewhere else. The
    classic version of this bug ends with an `rm -rf *` in the wrong place.
30. `rm *` expands to `rm -rf`, which `rm` reads as **options**. With `-f` there
    is no "missing operand" error either: status 0, nothing deleted, nothing
    said. `rm -- -rf` or `rm ./-rf` removes it.
31. A directory containing a file whose name has a newline (`ls` prints two
    lines, `find` prints two lines too — but `ls | wc -l` also miscounts when
    `ls` is columnising, and `ls` hides dotfiles). Empty directory: `ls | wc -l`
    is 0, `find -mindepth 1` is 0 — same. Directory with only dotfiles: `ls`
    says 0, `find` says the truth.

## D. `trap`

32. ```
    body
    ERR trap: line 7
    still here (ERR does not stop anything on its own)
    EXIT trap ran
    ```

    Status 3.
33. `EXIT`, last, after `exit 3` — and the 3 survived. That is what makes it the
    right place for cleanup: it runs on success, on failure, and on your own
    `exit`, without changing the status.
34. Notification, not control. Use it for logging "something failed at line N";
    use `-e` or an explicit check to stop.
35. Yes and yes: `E` printed, status 1.
36. Single quotes: the trap body is expanded when it **runs**, so it sees the
    later value. Double quotes: expanded when the trap is **set**, so it captures
    whatever `$msg` was then — usually empty.
37. ```bash
    tmp=$(mktemp); trap 'rm -f "$tmp"' EXIT
    echo data > "$tmp"; exit 1
    ```

    `ls "$tmp"` afterwards: gone.
38. Not with `EXIT` alone on some shells, and not at all if the script is killed
    with `-9`. Adding `INT TERM` covers Ctrl-C and `kill`. Nothing covers
    SIGKILL — which is why the trap is a courtesy and `mktemp`'s
    unpredictable name is the actual safety.
39. ```
    trap -- 'echo x' EXIT
    ```

    `trap -p` lists them; `trap - EXIT` removes one.
40. It fires when the **script** exits, not when the function returns. Traps are
    per-shell, not per-function; a function that sets a trap has changed the
    whole script's behaviour, which is worth a comment.

## E. Temporary files

41. The name is predictable from the PID; the file may already exist (and be
    owned by someone else, in which case you have just written into their file or
    failed); and there is no cleanup on an early exit.
42. Because nothing about "it worked once, alone, on an idle machine" tests any
    of the three failure modes. Correctness here is about the day it collides,
    and that day looks like a corrupted report, not a crash.
43. Yes — `/tmp/report.<pid>` is still there.
44. No. The `EXIT` trap removed it.
45. ```
    -rw------- 1 cadet cadet   0 /tmp/tmp.CvO0GKfcsB
    drwx------ 2 cadet cadet 4096 /tmp/tmp.1bzyu0aySV
    ```

    600 and 700, because `/tmp` is world-writable and shared; the point of
    `mktemp` is that nobody else can read or replace your file between creation
    and use.
46. `/labs/tmp.XXXXXXXX`. Honouring `TMPDIR` lets an operator move temporary
    files onto a filesystem with room, without editing your script — which is
    exactly the sort of thing you want to be possible during an incident.
47. `$$` is one PID, so two runs in the same shell would use the **same** name
    and clobber each other. Across users, PIDs are reused and the file may be
    owned by someone else. `$$` guarantees uniqueness against nothing at all;
    `mktemp` guarantees creation-or-failure, atomically.
48. Compare structure, not text: header, `mktemp || exit`, trap on the next line,
    quoted expansions, explicit `[ -s ]` check, and no `rm` at the end because
    the trap owns it.

## F. `shellcheck`

49. Eight, on nine lines.
50. ```
    ../bin/lint-me:3:7: note: Use $(...) notation instead of legacy backticks `...`. [SC2006]
    ../bin/lint-me:3:11: note: Use ./*glob* or -- *glob* so names with dashes won't become options. [SC2035]
    ../bin/lint-me:6:8: note: Double quote to prevent globbing and word splitting. [SC2086]
    ../bin/lint-me:7:9: note: Double quote to prevent globbing and word splitting. [SC2086]
    ../bin/lint-me:7:14: note: Consider using 'grep -c' instead of 'grep|wc -l'. [SC2126]
    ../bin/lint-me:10:1: warning: Use 'cd ... || exit' or 'cd ... || return' in case cd fails. [SC2164]
    ../bin/lint-me:11:8: warning: Use "${var:?}" to ensure this never expands to /* . [SC2115]
    ../bin/lint-me:11:8: note: Double quote to prevent globbing and word splitting. [SC2086]
    ```

    `-f gcc` for a hook: one line per finding, `file:line:col:`, which every
    editor and CI system already knows how to jump to.
51. Fixing the backticks first is the right order: it changes the parse, and some
    later findings move.
52. From running in the wrong directory. Everything relative after a failed `cd`
    is aimed somewhere else, and the script has no way to notice.
53. If `TMPDIR` is empty, `rm -rf $TMPDIR/*` is `rm -rf /*`. The `"${var:?}"`
    form makes the shell refuse instead. This is the single most expensive line
    in the file and it is a `note`-level habit that prevents it.
54. `grep -c row "$f"` — one process instead of two, and it says what it means.
    Both faster and clearer, though the clarity is the reason.
55. It is clean.
56. Expect SC2086 in your earlier work, and possibly SC2155 (`local x=$(cmd)`)
    from 12/05. Fix them there.

## G. Bring it together

57. Shape:

    ```bash
    #!/usr/bin/env bash
    # exit: 0 ok, 64 usage, 66 no such directory, 77 unreadable, 74 mktemp failed
    set -euo pipefail

    usage() { echo "usage: summary DIR" >&2; exit 64; }
    [ $# -eq 1 ] || usage
    dir=$1
    [ -d "$dir" ] || { echo "not a directory: $dir" >&2; exit 66; }
    [ -r "$dir" ] || { echo "cannot read: $dir" >&2; exit 77; }

    out=$(mktemp) || exit 74
    trap 'rm -f "$out"' EXIT

    count=$(find "$dir" -maxdepth 1 -mindepth 1 | wc -l)
    printf 'files: %s\n' "$count" > "$out"
    cat "$out"
    ```
58. The comment block is the contract; 64/66/77 follow `sysexits` as in 12/02.
59. Expect 64, 64, 66, 77, and a correct count for the spaced name.
60. **No.** Measured:

    ```
    /tmp/m2.sh: line 3: ((: 09: value too great for base (error token is "09")
    end
    ```

    status 0. The failing `(( ))` is a **condition**, so `-e` is off for it, the
    `if` is simply false, and the script exits successfully. The header does not
    catch the bug that lesson was about.
61. Also no. `bin/tally`'s pipeline succeeds at every stage; `pipefail` has
    nothing to report. The count is lost, not failed. `set -u` does not fire
    either, because the variable is set — in the child.
62. Yours, and the honest version is roughly: the header catches unanticipated
    *failures*; it does not catch wrong *answers*, and both scripts you have
    fixed this chapter produced wrong answers with status 0. What you do instead
    is check the things you care about, on purpose, and make the script say so
    when they are not true.
