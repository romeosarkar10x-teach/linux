# 12/04 — solutions

All outputs measured in the container.

## A. `for` walks a list of words

1. Three. The list is three words.
2. Two: `[a b]`, `[c]`. The quotes were removed *before* the loop got the list,
   but they had already decided where the word boundaries were.
3. Three: `[a]`, `[b]`, `[c]`. Command substitution produces **text**, and the
   shell then splits that text on `$IFS`. Quoting inside `echo`'s arguments does
   not survive into its output — output has no quotes, only bytes.
4. Brace expansion. It runs first, before variable expansion, which is why
   `{1..$n}` does not work.
5. Works in bash. Under `sh` (dash):

   ```
   sh: 1: Syntax error: Bad for loop variable
   ```

   Status 2. `for ((...))` is bash grammar (12/01).
6. Six lines. `decks/cargo hold.log` is one word — the glob produced it as one
   word and nothing re-split it.
7. One iteration, `[decks/nomatch*]`. A glob that matches nothing expands to
   itself.
8. With `nullglob`: zero iterations. This is why scripts that loop over a
   possibly-empty glob either set `nullglob` or test `[ -e "$f" ]` inside.
9. Two. `"$@"` produces one word per argument, exactly as in 12/02.

## B. Why not `$(ls)`

10. Six names, one per line.
11. Seven iterations. `cargo` and `hold.log`.
12. From `decks/`:

    ```
    bin/count-decks-ls: line 5: cargo: No such file or directory
    cargo: 
    bin/count-decks-ls: line 5: hold.log: No such file or directory
    hold.log: 
    ```

    (Plus the five correct lines.) It has been right about four decks out of
    five since 2186 — which is exactly the kind of wrong that survives.
13. `cargo hold.log: 3`.
14. `for f in $(ls *.log)` versus `for f in *.log`.
15. No. `ls -1` already prints one per line — newline *is* whitespace, so the
    split happens anyway. `ls -Q` is worse:

    ```
    ["cargo]
    [hold.log"]
    ```

    Now you have a broken name *and* literal quote characters, because quote
    removal happens before command substitution, not after. The damage happens
    in the shell's word-splitting of the substitution's output, after `ls` has
    exited. No `ls` flag can reach that stage.
16. `IFS=$'\n'` does fix this file — all six names come back whole. It breaks on
    a filename containing a newline, and it silently changes splitting for every
    later command in that shell, which is a much larger blast radius than the
    problem. Use the glob.
17. Loop over the glob; never loop over the output of a command that prints
    filenames.

## C. `while read` and its three parts

18. Line 1 has leading and trailing spaces. Line 2 contains a backslash. Line 3
    contains a literal tab. Line 4 has no trailing newline. `cat -A` shows `$`
    at each line end — there is none after line 4.
19. `read`:

    ```
    [leading and trailing]
    [backslash stays]
    [tab	separated]
    ```

    Whitespace stripped, backslash eaten. Three iterations.
20. `read -r`: line 2 comes back as `back\slash stays`. Whitespace still
    stripped.
21. `IFS= read -r`: line 1 comes back as `  leading and trailing   `.
22. `IFS=` protects leading and trailing whitespace. `-r` protects backslashes.
    `< file` protects the loop from running in a subshell.
23. Confirms all three.
24. `wc -l` says 3. The loop runs 3 times. Both are "wrong" about the same
    thing: there are four lines of text, and neither `wc -l` nor `read` counts
    the fourth, because both count *terminators*.
25. `0x65` — `e`, the last letter of `no-trailing-newline`. Not `0x0a`.
26. Four.
27. It never ends. `read` returns false, `|| true` makes the condition true
    forever, and `$line` keeps whatever it last held — an infinite loop printing
    the same line. `[ -n "$line" ]` is true exactly once, because the body is
    followed by another `read` that clears the variable to empty. Ctrl-C.
28. Before. `read` fills the variable with whatever it got and *then* reports
    end-of-input. `printf 'x' | { read -r v; echo "rc=$? v=[$v]"; }` gives
    `rc=1 v=[x]`.
29. `1`. `wc -l` counts newline bytes, and there is one.

## D. The subshell

30. `n=0`.
31. `inside: 3`.
32. Into a child process that exited. The right-hand side of a pipeline runs in a
    subshell; its variables die with it.
33. From `decks/`: `decks with faults: 0`, status 0. It is confident and it is
    wrong and it exits successfully, which is how it has stayed in the tree.
34. One name: `epsilon.log`.
35. Neither is wrong in isolation. `grep -l` finds the fault; the loop counts it
    correctly; the count is discarded at the pipe. The bug is structural.
36. ```bash
    faults=0
    while read -r f; do faults=$((faults + 1)); done < <(grep -l FAULT *.log)
    echo "decks with faults: $faults"
    ```

    `decks with faults: 1`.
37. `faults=$(grep -l FAULT *.log | wc -l)`. Ship this one: no loop, no subshell
    question, and the thing that counts is the thing that produces the number.
    Keep the loop only if the body does more than increment.
38. `shopt -s lastpipe` in a script does fix it — `bash -c 'shopt -s lastpipe;
    ...'` prints `n=3`. It does **not** help in an interactive shell, where job
    control is on and `lastpipe` is ignored. A fix that behaves differently
    when you test it by hand than when it runs is a bad fix.
39. A child can be told things and can be watched, but it cannot reach back into
    its parent — the same reason `export` only goes downward and the same reason
    a script that `cd`s does not move your shell.

## E. `until`, `break`, `continue`

40. `while [ $i -lt 3 ]`.
41. `until` for retry ("until it answers"), `while` for consumption ("while
    there is input"). Pick the one that makes the condition read as a positive
    statement; a `while [ ! ... ]` is usually an `until`.
42. `first fault: epsilon.log`.
43. Same first line, plus any later matches, and it reads every remaining file.
    On five small decks that is invisible; the habit matters when the loop body
    is expensive.
44. `1`, `3`, `5`.
45. ```bash
    for i in 1 2 3; do
        for c in a b; do
            [ "$i$c" = "2a" ] && break 2
            echo "$i$c"
        done
    done
    echo done
    ```

    Prints `1a 1b` then `done`. If `break 2` had been `break`, `3a`/`3b` would
    follow.
46. Status 0 normally; with `false` last in the body, status 1. A loop's status
    is the status of the last command it ran.
47. `for i in 1 2 3; do true; break; false; done` gives 0 — `break` ends it after
    `true`. To control it, end the loop with an explicit `return`/`exit`, or set
    a variable in the loop and test it after.

## F. Build

48. ```bash
    for f in *.log; do
        printf '%s: %s\n' "$f" "$(wc -l < "$f")"
    done | sort
    ```
49. Accumulate outside any pipeline:

    ```bash
    total=0
    for f in *.log; do
        n=$(wc -l < "$f")
        printf '%s: %s\n' "$f" "$n"
        total=$((total + n))
    done
    echo "total: $total"
    ```

    The `sort` from 48 has to go, or move to a temp file — you cannot sort in a
    pipeline and keep the total in the same shell. That trade-off is the lesson.
50. ```bash
    found=1
    for f in *.log; do
        if grep -q FAULT "$f"; then echo "$f"; found=0; fi
    done
    exit $found
    ```
51. ```bash
    n=0
    while IFS= read -r line || [ -n "$line" ]; do
        n=$((n + 1))
        printf '%d\t%s\n' "$n" "$line"
    done < "$1"
    ```

    Four lines out; `cat -n` also shows four but does not end the last one with a
    newline. Compare with `| xxd | tail -1`.
52. ```bash
    if [ $# -ne 1 ] || [ ! -r "$1" ]; then
        echo "usage: read-lines FILE" >&2
        exit 64
    fi
    ```
53. ```bash
    while IFS= read -r name; do
        if [ -e "decks/$name" ]; then echo "ok   $name"; else echo "MISSING $name"; fi
    done < manifests/decks.txt
    ```

    `IFS=` is what keeps `cargo hold.log` intact here too.
54. `printf 'mv %q %q\n' "$f" "${f%.log}.txt"` — `%q` quotes for reuse by the
    shell, which is exactly the "could be pasted" requirement.
55. The trace shows the glob already expanded, the `[ -e ... ]` with its real
    arguments, and — the useful one — the quoting on the cargo hold, which until
    now you had only inferred from whether it worked.
56. Yours. The three sentences are the `for`/glob rule, `while IFS= read -r line
    || [ -n "$line" ]; do ... done < file` with all four parts named, and "the
    right-hand side of a pipeline is a child; its variables do not come back".
