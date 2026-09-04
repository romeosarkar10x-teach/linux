# 12/02 — solutions

All output below was measured in the course container.

## A

1. `$0 = [bin/show-args]`, `$# = 3`.
2. `$0` changes to the absolute path; `$#` and the arguments do not. `$0` is the
   string the caller used.
3. `$0` is `bash` (the shell's own), `$# = 1`. Sourcing runs the lines in your
   shell, which already has a `$0`; the script never got one.
4. Two: `[a b]` and `[c]`.
5. Two, the same. The backslash escapes the space the way the quotes did — both
   are quoting, one character at a time versus a run.
6. `$# = 0` and the loop prints nothing. `"$@"` with no arguments is an empty
   list, not a list containing one empty string.
7. Your shell. `$#` is 5 and each deck arrives separately; the script contains
   no `*`. Prove it with `bin/show-args '*'`.
8. Nobody. `$# = 1` and `$1` is the literal `*` — a script that wanted to glob
   would have to do it itself.
9. `[10]` and `[ten]`. `$10` is `$1` followed by the character `0`; braces are
   how you say "parameter ten".

## B

10. `"$@"` 2, `$@` 3, `"$*"` 1.
11. `"$@"`.
12. `"$@"` produces zero words. `"$*"` always produces exactly one word, which
    here is the empty string — so `for` runs once on it.
13. No — it joins with a space. `IFS` is reset to its default when bash starts,
    so an `IFS` exported by the caller does not reach the script's expansion.
14. Now `"$*"` gives `a-b`. The joining uses the first character of the *script's
    own* `IFS`, at the moment of expansion.
15. `"$@"` — `<cargo hold>` as one word. The other two show `cargo` and `hold`.
16. `bin/count-at *` passes each name separately (your shell globbed it), so
    `"$@"` shows `<star file.txt>` intact. `"$(echo *)"` collapses the glob into
    one string first, so the script gets one argument that happens to contain
    spaces; `$@` then splits it anyway.
17. Three — `relay` used `$@` unquoted, so `cargo hold` split before it ever
    reached `show-args`.
18. Two. The diff is the pair of quote marks around `$@`.
19. Quoting is needed at **every** hop: one unquoted `$@` anywhere in the chain
    splits the argument permanently, and no amount of quoting downstream can put
    it back together.
20. When you want a single string for a message or a log line, e.g.
    `echo "invoked with: $*" >&2   # deliberately one line; not re-parsed`.

## C

21. `bin/deck-report "cargo hold"` — got `cargo hold:  entries` with no number,
    plus a complaint about an ambiguous redirect, and an exit status of 0.
22. stdout: `cargo hold:  entries`. stderr:
    `bin/deck-report: line 4: $DECKS/$1: ambiguous redirect`.
    Separate them with `bin/deck-report "cargo hold" 2>/dev/null` and
    `... 1>/dev/null`.
23. `0`. The last command was the `echo`, and it succeeded. The failure was two
    lines earlier, in a command substitution whose status nobody looked at.
24. (a) `< $DECKS/$1` is unquoted, so the word-split filename gives the shell two
    words after `<` and it refuses: *ambiguous redirect*. (b) the script reports
    a result it never checked — `lines` is empty and it prints anyway.
25. Only the quoting. `deck-report-2` prints `cargo hold: 4 entries`. It still
    reports without checking, so bug (b) survives.
26. She is complaining about (a). (b) is the reason ops-bot logged it as a
    successful run — and (b) is the one that will still be here after somebody
    fixes the quoting.
27. `alpha`, `beta` and `gamma` have no spaces, so word splitting produces one
    word and the unquoted expansion is accidentally correct. The bug is in the
    script the whole time; only the data made it visible.
28. It works: `-n: 1 entries`. The filename reaches `wc` as a **redirection
    target**, which the shell opens itself — it is never an argument, so `wc`
    never gets the chance to read it as an option.
29. `wc -l "$1"` on `-n` gives `wc: invalid option -- 'n'`, status 1. Fix:
    `wc -l -- "$1"`, which gives `1 -n`. The `--` says "no more options"; the
    redirect version needed none because the name never passed through `wc`'s
    argument parsing.
30. Something like: "You were right — the file is fine and so was your typing.
    `deck-report` doesn't quote the filename, so the shell split `cargo hold`
    into two words and refused the redirect. It also prints its line whether or
    not it got a number, which is why the run logged as successful. Fixing both."

## D

31. ```bash
    #!/usr/bin/env bash
    while [ "$#" -gt 0 ]; do
        echo "handling $1"
        shift
    done
    ```
32. Two.
33. `left: 0`.
34. Status `1`, and nothing changes.
35. `while shift; do ...; done` "works" but is wrong — it shifts *before* the
    body sees `$1`, dropping the first argument. Prefer the explicit `$#` test:
    it says what it means and does not depend on a side effect.
36. With one argument left, `shift 2` leaves `$#` at 1 and returns 1: bash
    refuses the whole shift rather than doing part of it.
37. ```bash
    [ "$#" -eq 0 ] && set -- alpha beta gamma
    printf '%s\n' "$@"
    ```
38. `set --` supplies *several* defaults and fixes `$#` for everything after it;
    `${1:-alpha}` gives one value at one use site and leaves `$#` at 0.
39. `line N: $1: unbound variable`, and the script exits (status 127 from
    `bash -c`, 1 from a script file — 11/05).
40. The explicit `$#` check with a usage message: `set -u` tells the *author*
    what went wrong, a usage message tells the *caller*.
41. ```bash
    while [ "$#" -ge 2 ]; do
        echo "pair: $1 / $2"
        shift 2
    done
    [ "$#" -eq 0 ] || { echo "odd argument left over: $1" >&2; exit 64; }
    ```
    Silently dropping the odd one is the bug to avoid.

## E

42. `usage: needs-two <deck> <shift>` on **stderr**, status `64`.
43. `bin/needs-two alpha 2>/dev/null` shows nothing;
    `bin/needs-two alpha 1>/dev/null` still shows the message.
44. `$0` prints the whole invocation path, so the usage line changes depending on
    how the user called it. `basename` gives the name they will type.
45. With two arguments, `ok`; with one, nothing. The caller learns from the
    status, which is the only part of a script an `if` can see.
46. ```bash
    #!/usr/bin/env bash
    DECKS=/labs/12-shell-scripting/02-arguments/decks
    if [ "$#" -ne 1 ]; then
        echo "usage: $(basename "$0") <deck>" >&2
        exit 64
    fi
    if [ ! -f "$DECKS/$1" ]; then
        echo "$(basename "$0"): no such deck: $1" >&2
        exit 66
    fi
    echo "$1: $(wc -l < "$DECKS/$1") entries"
    ```
47. no args → 64; `alpha` → `alpha: 6 entries`, 0; `cargo hold` → `4 entries`,
    0; `-n` → `1 entries`, 0; `nosuch` → 66.
48. Wrap the per-deck part in `for d in "$@"; do ... done`, change the `$#` test
    to `-lt 1`, and track a nonzero status to exit with at the end rather than
    exiting on the first missing deck.
49. Yes. Your shell quoted nothing — it globbed and passed separate words — and
    the script's `"$@"` and `"$1"` kept them separate. Both halves are needed.
50. ```bash
    [ "$1" = "--help" ] && { usage; exit 0; }
    ```
    `--help` is a request that succeeded, so it goes to stdout and exits 0; a
    wrong invocation is an error, so it goes to stderr and exits nonzero. That
    is what lets `tool --help | less` work while `if tool` still catches misuse.

## F

51. That its final `echo` ran. Not that any deck was read, not that the count is
    right, and not that the file it named exists.
52. For: it is one rename, it costs nothing, and it unblocks today's report.
    Against: it hides a bug that is in the script, not the data, and the next
    name with a space — a person's name, a date with a space, a pasted path —
    brings it straight back, in a script nobody is suspicious of any more.
53. It works perfectly as long as no argument ever contains whitespace or a glob
    character. That condition holds until the first time it doesn't, and nobody
    is warned when it stops.
54. "Style doesn't change behaviour; `$1` and `\"$1\"` are two different programs
    on any deck name with a space in it — ask rhea."
55. ```bash
    # "$@" is deliberate: unquoted $@ splits every argument here and no amount
    # of quoting in show-args can put "cargo hold" back together.
    ```
56. `"$@"` — with the quotes.
