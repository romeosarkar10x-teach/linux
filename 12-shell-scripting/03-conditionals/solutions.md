# 12/03 — solutions

Measured in the course container.

## A

1. `y`. Status 0 is true.
2. `n` for both. Any nonzero is false; 3 is not special.
3. `grep` supplied it. `-q` makes it report by status only.
4. `[` — a builtin command whose last argument is `]`.
5. `test` and `[` are builtins; `[[` is a **keyword**, so the shell parses its
   contents itself instead of expanding them into an argument list first.
6. Because `[` must exist as a program for anything that execs commands
   directly (`find -exec`, other shells, scripts run under `sh`) rather than
   going through bash's builtin lookup.
7. Prints `y`. It tested whether the string `1` is non-empty — which any number
   is. `[ STRING ]` with one argument is `-n STRING`.
8. `if [ "$(wc -l < tree/regular.txt)" -gt 0 ]; then ...`

## B

9. `bash: [: =: unary operator expected`, status 2.
10. `[`, `=`, `x`, `]` — the empty expansion produced **no word at all**, so `=`
    landed in the operand position.
11. `bash: [: too many arguments`, status 2. Five: `[ a b = x ]`.
12. Yes, both vanish. `[ "$v" = x ]` returns 1 (false) in both cases.
13. Word splitting. `[[ ]]` is parsed as a unit, so `$v` stays one word.
14. Status 0 — true. `[ "$a"="$b" ]` is a single argument, `=`, and a one
    argument test is a non-empty-string test.
15. `bin/gate: line 5: [: =: unary operator expected` then `no match`, script
    status **0**; and `[: too many arguments`, `no match`, status **0**.
16. `[` returned 2, the `if` read that as false and took the `else`, and the
    `else`'s `echo` succeeded — so the script's status is the echo's.
17. Nothing but the data: every deck name it has been given has been a single
    word with no glob characters.
18. Two characters: quote `$1`. The second fix is `[[ $1 = $expected ]]`.
    Ship the quotes — the script is otherwise portable, and the habit is the
    point.

## C

19. `[ 10 -gt 9 ]` → 0 (true, arithmetic). `[[ 10 > 9 ]]` → 1 (false, string:
    `1` sorts before `9`).
20. Unescaped `>` would redirect into a file called `9`. The answer is 1: as
    text, `"10"` is less than `"9"`.
21. `8` → refused (right), `9` → new enough (right), `10` and `11` → refused
    (**wrong**). 10 is the first release it gets wrong, and it is the first
    two-digit release.
22. A deployment. On its own — its evidence is the gate's exit status, which is
    a claim about a string comparison and nothing else.
23. `[ "$have" -gt 8 ]` instead of `[[ $have > 8 ]]`: arithmetic, not text.
24. `version-gate 9.2` says "new enough" (as text, `9.2` > `8`). `count-gate 9.2`
    gives `[: 9.2: integer expression expected`, status 2 → refuses. `-gt` is
    **integer** arithmetic and has no opinion about decimals; it says so loudly,
    which is the behaviour you want.
25. `-eq` asks "are these the same number" (yes). `=` asks "are these the same
    text" (no). Both are correct answers to different questions.
26. `bash: [: abc: integer expression expected`, status 2.
27. Returns 1, silently. `[[ ]]` evaluates the operands of `-eq` as arithmetic,
    where an unset-looking name is 0, and `0 -eq 1` is false. For a deployment
    gate you want the loud version.
28. ```bash
    #!/usr/bin/env bash
    case $1$2 in *[!0-9]*|'') echo "cmp: integers only" >&2; exit 65;; esac
    [ "$1" -gt "$2" ]
    ```
    (or an explicit `[[ $1 =~ ^[0-9]+$ ]]` test per argument — `case` is 12/05,
    either is fine here.)
29. Refused. `"100"` starts with `1`, which sorts before `8`. Every two- and
    three-digit release fails.

## D

30. `-e link-ok` → true, `-e link-broken` → false. `-e` follows the link and
    asks about the **target**.
31. `-L` is true for both. It is the only one that asks about the link itself.
32. `-f link-ok` → true. It follows too.
33. True for `subdir`, false for `regular.txt`.
34. True for `regular.txt`, false for `empty.txt`.
35. `-r` reads the `r` bit, `-w` the `w`, `-x` the `x`, in whichever triad
    applies **to you** — first match, no fallthrough (10/04). `readonly.txt` is
    `444`: `-r` true, `-w` false, `-x` false. `runnable.sh` is `755`: all three.
36. `-w /etc/passwd` is false for cadet and would be true for root — root is
    exempt from the check rather than permitted by it (10/07). These tests
    answer "can *this process* do it", not "what does the mode say".
37. `regular.txt` is 2187-06-30, `empty.txt` is 2186-01-01, so `-nt` is true.
    Confirm with `stat -c '%y %n' tree/regular.txt tree/empty.txt`.
38. `symlink, directory, regular file, symlink, does not exist` — the surprise
    is that both symlinks classify the same, and that the broken one never
    reaches the "does not exist" branch.
39. For: `-L` first is the only branch that reports the link *as a link*, which
    is what you want in an audit. Against: users usually care what they will get
    when they open it, and "symlink" tells them nothing about that.
40. With `-f` first, `link-ok` becomes "regular file" (it follows) and
    `link-broken` falls through to `-e`, which is also false, so it reports
    "does not exist" — an actively misleading answer for a link that is right
    there.
41. `[ -L "$p" ] && [ ! -e "$p" ]` — is a link, and its target is not there.

## E

42. `regular.txt` ready; `empty.txt` not (fails `-s`); `readonly.txt` ready;
    `nosuch` not.
43. Not wrong. It claims the file exists, is readable **by this process**, and
    is not empty. It never claimed anything was writable — and if the caller
    needs to write, the check is missing a condition, which is a specification
    bug, not a logic one.
44. `if [[ -e $TREE/$DECK && -r $TREE/$DECK && -s $TREE/$DECK ]]` — same
    behaviour, including for names with spaces, because `[[ ]]` does not split.
45. `[ -e "$f" -a -r "$f" -a -s "$f" ]` works. Reason not to: `-a`/`-o` make the
    argument count depend on the data, so a filename like `-a` or `!` can change
    how the whole expression parses. POSIX deprecates them for exactly this.
46. `dir`; against a nonexistent path, `notdir`.
47. `else branch`. `true &&` runs `false`, which fails, so `||` fires.
48. `echo ok >&-` fails with `write error: Bad file descriptor` **and** the
    `||` branch runs, so you get the error text and `failed2`. The `&&` side
    succeeded and the `||` side ran anyway.
49. Only when the middle command cannot fail and you do not care if it does.
    Otherwise write `if`/`else`.
50. `[[ -e $p && ( -d $p || ( -f $p && -s $p ) ) ]]`
51. Unquoted: true, glob match. Quoted (`"deck-*"`): false, literal comparison.
    Quoting the right-hand side turns off pattern matching — the reverse of the
    rule everywhere else.
52. Status 0. `BASH_REMATCH[0]` is `deck-01`. With `^(deck)-([0-9]+)$`,
    `BASH_REMATCH[1]` is `deck` and `[2]` is `01`.

## F

53. ```bash
    #!/usr/bin/env bash
    if [ "$#" -ne 1 ]; then echo "usage: $(basename "$0") <path>" >&2; exit 64; fi
    p=$1
    if   [ ! -e "$p" ]; then echo "$p: missing" >&2; exit 66
    elif [ ! -f "$p" ]; then echo "$p: not a regular file" >&2; exit 66
    elif [ ! -r "$p" ]; then echo "$p: unreadable" >&2; exit 66
    elif [ ! -s "$p" ]; then echo "$p: empty" >&2; exit 66
    fi
    echo ok
    ```
54. `regular.txt` ok; `empty.txt` empty; `subdir` not a regular file;
    `link-ok` ok (it follows); `link-broken` missing; `runnable.sh` ok;
    `not-runnable.txt` ok; nonexistent path missing.
55. Every expansion is quoted, so `./check-deck.sh "tree/a b.txt"` works. Create
    such a file and prove it.
56. The `$#` check comes before any use of `$1`, so `set -u` never sees an unset
    parameter. Order matters: `p=$1` above the check would fail.
57. Inside `[[ ]]` the quotes on `$p` become unnecessary. Keep them anyway —
    the habit has to survive being moved into a `[ ]` or an argument list, and
    a reader should not have to check which construct they are in.
58. Expect `SC2086` warnings if any expansion is unquoted, and possibly
    `SC2181`-style advice. The ones about quoting are this lesson.

## G

59. "The release gate compares its argument as text, not as a number, so
    release 10 sorts below the 8 it is checked against. It has been correct for
    every single-digit release, which is every release until today."
60. For: it restores deployment in one step and touches nothing else. Against:
    it makes the version string lie to every other tool that reads it, and the
    gate stays wrong for release 11, 12 and 100 — you would be renaming
    releases forever to protect one comparison.
61. (a) an unquoted `$1`, which makes `[` fail on empty or multi-word input;
    (b) the script reports "no match" for a *failed test*, and exits 0 either
    way. Monitoring notices neither — nothing checks stderr, and the status is
    0. That is why (b) is the worse of the two.
62. When the script has to run under `sh`/dash (or any POSIX shell), such as an
    installer, a container entrypoint, or anything with `#!/bin/sh`.
