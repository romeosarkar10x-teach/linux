# 12/05 — solutions

All outputs measured in the container.

## A. `case` basics

1. `all decks nominal`, `decks: 4`, `faults: 1`, and the usage line for each of
   the three help spellings.
2. `mode: unknown mode: nope` on **stderr**, status 64.
3. ```
   mode: unknown mode: 
   ```

   status 64. `"$1"` expands to the empty string, which matches `*`. Under
   `set -u` an unquoted `$1` would abort; quoted, it is still an unset-variable
   reference and `set -u` would still complain — the quotes protect the *word
   count*, not the existence. `${1:-}` is the guard for existence (11/01).
4. Around eleven lines, with `$1` written five or six times and `=` five times.
5. The `case`. Adding a mode is one line in one place; the `elif` chain needs a
   new comparison with a new chance to mistype the variable.
6. Pattern alternation. Not a pipe — there is no second process. `case` is
   syntax, not a command.
7. `yes`. `case` expands the word but does not word-split it. `[ $v = "a b" ]`
   gives `[: too many arguments`, status 2, because `[` is an ordinary command
   and its arguments *were* split (12/03).
8. `other`. Glob character classes are not case-insensitive, and the pattern must
   match the whole word.
9. `lower`. Same family as `nocaseglob` and the other `shopt`s in 11/05: bash
   options that change matching, set per shell and easy to forget you set.

## B. Patterns and order

10. `deck command: deck-01`. The reader expects the special bridge-deck branch.
11. `unrecognised: status` and `unrecognised: zzz`.
12. Two: `deck-*` and `*`. Dead: `deck-01` and `status`.
13. First match wins; nothing after the matching branch is tested, so a `*)`
    that is not last kills everything below it.
14. ```
    SC2221 (warning): This pattern always overrides a later one on line 6.
    SC2222 (warning): This pattern never matches because of a previous pattern
    ```

    (It reports the `deck-01` collision; the dead `status` branch below it is not
    separately called out, which is a fair reminder that a clean `shellcheck` run
    is a floor and not a ceiling.)
15. Order: `deck-01`, then `status`, then `deck-*`, then `*`. All four inputs now
    reach a distinct branch.
16. `a.log: log`, `b.log.gz: compressed log`, `c.txt: notes`, `d: unknown`.
17. Because `*.log` must match the **whole** word, and `b.log.gz` does not end in
    `.log`. Globs in `case` are anchored at both ends — this is the opposite of
    `grep`, where a pattern matches anywhere.
18. With `*log*`, the `*.log.gz` branch dies: `b.log.gz` comes back as `log`.
    Order patterns most-specific first, and when two patterns can match the same
    word, the order is the decision — write it deliberately.
19. `case $n in deck-[0-9][0-9]) ...` gives `deck-01 yes`, and `deck-1`,
    `deck-011`, `deck-ab` all `no`. Note `deck-011` is rejected only because the
    match is anchored at the end.

## C. `;;`, `;&`, `;;&`

20. With `ax` (matches both patterns): `;;` prints `A`; `;&` prints `A X`; `;;&`
    prints `A X`.
21. With `abc` (matches `a*` only): `;;` prints `A`; `;&` prints **`A X`**; `;;&`
    prints **`A`** alone. This is the pair that separates them.
22. Nothing. `;&` runs the next body unconditionally.
23. `;;&` resumes testing the remaining patterns, running the bodies of any that
    also match.
24. Two `case` statements are usually clearer, and they are what most reviewers
    expect. `;;&` earns its place when the patterns are a genuine set of
    independent attributes of one word.
25. Right: a set of increasingly-general cleanup steps where each also implies
    the next. Trap: anything where a reader would assume the branches are
    exclusive — which is what every other `case` has taught them.

## D. Functions

26. `$0` is the script name (or `bash` in an interactive shell), **not** `f`.
27. `f`.
28. `bash: f: command not found` — after `unset -f`, the name is nothing.
29. `function`, `builtin`, `keyword`, and `file` for a path. Keyword means the
    shell parses it specially; builtin means the shell runs it in-process; file
    means an external program.
30. From bash. It reprints the function from its own parsed form, so your
    formatting and comments are gone. Useful when you suspect something has
    redefined a name.
31. `not ls`. Real one: `command ls`, or `/bin/ls`. `unset -f ls` restores
    normality. Functions are looked up before PATH — the same lookup order as
    11/04's alias/function/builtin/file question.
32. `1`. A function's status is the status of its last command.
33. `0`. `:` is there because bash has **no empty function body**:

    ```
    bash: -c: line 1: syntax error near unexpected token `}'
    ```

    status 2.
34. `never` does not print. Status 7. `exit` in a function exits the script.
35. ```
    bash: return: can only `return' from a function or sourced script
    ```
36. Sourced: the function is defined in your shell and callable. Executed: the
    definition happened in a child that has exited, and the name is not found.
    Same boundary as 12/01 and 12/04.

## E. `local`

37. ```
    after with_local:    count=start
    after without_local: count=inner
    ```

    `without_local` is the dangerous one.
38. ```bash
    helper() { for i in 1 2 3; do :; done; }
    for i in a b c; do helper; echo "$i"; done
    ```

    Prints `a` once and then stops — the outer `i` was clobbered to `3`.
39. `masked:   0`, `unmasked: 1`.
40. In `local n=$(...)` the status reported is `local`'s, which is 0 regardless;
    splitting the declaration from the assignment lets the command's own status
    through.
41. Yes — because the day you add `set -e` (12/07) or an `if`, the masking
    becomes a silent behaviour change in code you did not touch. Habits are
    cheaper than audits.
42. Dynamic. `a() { local v=inner; b; }` with `b` reading `$v` prints
    `b sees v=inner`, and the caller's `v` is `outer` afterwards. The callee sees
    the caller's locals, which is not how most languages work and is worth
    knowing before you rely on it.
43. ```
    v=1
    v=2
    ```

    Each call has its own `v`; the `echo`s run on the way back out, innermost
    first.
44. No:

    ```
    bash: local: can only be used in a function
    ```

    status 1.

## F. Status or output

45. `deck_has_fault` answers by status (`grep -q`), consumed by `if`.
    `deck_lines` answers by output (`wc -l <`), consumed by `n=$(...)`.
46. ```
    decks/alpha.log: 3 lines, clean
    decks/epsilon.log: 2 lines, FAULT
    ```
47. The echo version needs `[ "$(deck_has_fault "$f")" = yes ]` at every call
    site — longer, and it fails **open** if the function ever prints something
    unexpected. The status version cannot be misread by `if`.
48. ```
    return 300 -> 44
    return abc -> 2
    bin/big-return: line 3: return: abc: numeric argument required
    ```
49. 300 − 256 = 44. The report reads: "the archive tool says it processed 44
    files but there are 300 in the directory" — filed as a counting bug, in the
    wrong file, months later.
50. Yes: `[out] 3`. Command substitution captures stdout and passes the status
    through.
51. Shape:

    ```bash
    #!/usr/bin/env bash
    . /labs/12-shell-scripting/05-case-and-functions/lib/deck.sh

    usage() { echo "usage: deck-tool {list|count|faults|help}" >&2; }

    cmd_list()   { local f; for f in "$DECKS"/*.log; do basename "$f" .log; done; }
    cmd_count()  { local n=0 f; for f in "$DECKS"/*.log; do n=$((n+1)); done; echo "$n"; }
    cmd_faults() { grep -l FAULT "$DECKS"/*.log | wc -l; }

    case "${1:-help}" in
        list)   cmd_list ;;
        count)  cmd_count ;;
        faults) cmd_faults ;;
        help)   usage; exit 0 ;;
        *)      usage; exit 64 ;;
    esac
    ```

    Note the counter is not on the right of a pipe (12/04).
52. Expect to be told about `basename` in a loop and about unquoted expansions.
    Fix rather than suppress; a `# shellcheck disable=` you cannot justify in one
    sentence is a bug you have annotated.

## G. The ops tree

53. Five: `usage`, `rotate`, `prune`, `verify`, `adjust`.
54. Four: `rotate`, `prune`, `verify`, `adjust`.
55. Three. `adjust` is not in the usage line.
56. `prune`, via `"${1:-prune}"` — use `$1`, or `prune` if `$1` is unset or empty
    (11/01). A default mode that is not stated in the usage is a second thing
    this script does not tell you.
57. ```
    cleanup complete, 0 files removed
    verify: checksums ok
    usage: housekeeping.sh {rotate|prune|verify}
    ```

    Statuses 0, 0, 64.
58. ops-bot recorded `cleanup complete, 0 files removed`, which is `prune` — the
    default, reached without anyone naming it. It has never logged output from
    `rotate`, `verify` or `adjust`. Write down what you would need in order to
    find out whether `adjust` has ever run at all. You cannot answer that today.
