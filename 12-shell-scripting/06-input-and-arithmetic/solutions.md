# 12/06 — solutions

All outputs measured in the container.

## A. `read` as input

1. With stdout redirected you still see `deck name:` — `-p` writes the prompt to
   **stderr**/the terminal, so prompting does not pollute the output a caller is
   capturing.
2. Yes: `you said: name=[alpha] count=[7]`. The prompt is written regardless; the
   answers come from stdin, whatever stdin is. A script that prompts can still be
   automated.
3. `$v` is empty, `$?` is 0. An empty line is input; end-of-input is not.
4. `1`. `read -t` returns greater than 128 on timeout in some shells, 1 here on
   immediate EOF from `/dev/null`. Either way: non-zero means "no line".
5. `[abc]`, and no Enter needed — `-n` returns as soon as it has the characters.
6. Passwords, one-time codes. It is not encryption: the value is a plain shell
   variable, visible to anything that can read that shell's memory, and it will
   be passed to whatever you hand it to. It just keeps it off the screen.
7. `p=[a] q=[b c]`. The last name gets the remainder.
8. Both empty, status 0. Missing fields are not an error — which is why a script
   that reads four fields from a three-field line silently gets an empty one.
9. Because the `while`/`read` must run in *this* shell to keep `$x`. Without the
   braces the assignment happens in the pipeline's subshell (12/04) and vanishes.
10. `IFS=: read ...` sets `IFS` for that command only. Setting it above changes
    splitting for everything after it, which is the bug you fix by moving it.

## B. `bin/fields`

11. `while IFS=: read -r id name deck hours`.
12. Skips the header row. `tail -n +2 file` would do it upstream instead — but
    then the loop reads from a pipe, and the subshell question is back.
13. Yes. The name field is bounded by colons, and `read` does not care about
    spaces once `IFS` is `:`.
14. It does not. `hours` — the last name — absorbs `deck:hours` as one string,
    because the last variable gets everything left including separators.
15. Quoted fields containing the delimiter, and embedded newlines inside a quoted
    field. Also escaping, and a BOM. Use a real parser when the data is real CSV.

## C. Validation

16. `12` → `count times two: 24`, 0. `1x`, `-3` and empty → rejected, 65.
    ` 4` (leading space) → **accepted**, `count times two: 8`, status 0 — because
    `read` without `IFS=` stripped the space before the `case` ever saw it
    (12/04). Two protections in a row, and the outer one hid the inner one.
17. `''` matches the empty string. `*[!0-9]*` matches anything containing at
    least one character that is not a digit. Together: reject empty, reject
    anything with a non-digit.
18. `''|-|*[!0-9-]*` is the lazy version and accepts `1-2`. Better:
    `case "$count" in ''|-) bad ;; -[0-9]*|[0-9]*) case "${count#-}" in
    *[!0-9]*) bad ;; esac ;; *) bad ;; esac`. If it is getting long, that is the
    signal to validate with a regex in `[[ =~ ]]` (12/03).
19. ```
    bash: 1x: value too great for base (error token is "1x")
    ```

    Bash tried to read `1x` as a based number. It is not "not a number" to the
    parser; it is a number in a base it cannot make sense of.
20. Because `$(( ))` evaluates array subscripts, and a subscript is an arithmetic
    context that performs command substitution:

    ```
    c='x[$(echo RAN-INSIDE-ARITH >&2)0]'; echo $((c))
    RAN-INSIDE-ARITH
    0
    ```

    The command ran. Arithmetic on unvalidated input is code execution, not just
    a wrong number.

## D. Arithmetic

21. See `bin/arith-tour`'s measured output in the readme.
22. Toward zero: `7/2` is 3, `-7/2` is `-3`. Python floors, so Python's `-7//2`
    is `-4`. Two languages, two answers, same expression.
23. The result takes the sign of the **left** operand: `-7 % 3` is `-1`.
24. ```
    bash: 1.5: syntax error: invalid arithmetic operator (error token is ".5")
    ```
25. `y` holds the string `x`; arithmetic evaluates a bare name, gets `x`,
    evaluates *that*, gets 5. Recursive variable evaluation.
26. `1`. `abc` is a name, the name is unset, an unset name is 0. No error, no
    warning, and the wrong answer is a plausible one.
27. Also `1` normally. Under `set -u`:

    ```
    bash: z: unbound variable
    ```

    status 127 from `bash -c`. `set -u` is what turns this class of silent zero
    into a loud stop (12/07).
28. ```
    bash: 5/0: division by 0 (error token is "0")
    ```

    Status 1; the script continues to the next command.
29. `1` and `0` respectively — `(( ))` is a status, inverted from C's truthiness
    in exactly the way you would expect from a shell. `if (( n > 3 )); then`.
30. Quoted: `x` is 3. Unquoted:

    ```
    bash: let: =: syntax error: operand expected (error token is "=")
    ```

    status 1, `x` unset — because the shell split `x = 1 + 2` into five words and
    `let` evaluated each separately. `(( x = 1 + 2 ))` has no such problem.
31. `0 1 2`. Post-increment returns the old value twice, and `i` ends at 2.
32. It wrapped to `-9223372036854775808`. What did not happen: any error, any
    status, any warning. Silent wraparound is the worst failure mode there is.
33. Check before you add: `if (( a > MAX - b ))`, where `MAX=9223372036854775807`.
    You cannot check afterwards, because the evidence is gone.

## E. Bases and the leading zero

34. `8`.
35. ```
    bash: 08: value too great for base (error token is "08")
    ```
36. `8`, `255`, `5`.
37. `09` and `08` are invalid octal and error out. `07` is **valid** octal and
    silently means 7 — here that is also its decimal value, but `010` would mean
    8, and nothing would tell you.
38. stdout:

    ```
    delta: margin low (07)
    margin check complete
    ```

    stderr:

    ```
    bin/margin-check: line 4: ((: 09: value too great for base (error token is "09")
    bin/margin-check: line 4: ((: 08: value too great for base (error token is "08")
    ```

    Status 0.
39. It tested gamma (11) and delta (07). alpha (9) and beta (8) are both below 10
    and neither was tested — the two it skipped are exactly the two it existed to
    find.
40. The log records stdout. The errors are on stderr, the exit status is 0
    because a failed `(( ))` inside an `if` is just a false condition, and the
    output is plausible — one deck flagged, "check complete". Everything a
    monitoring system looks at says the script is fine.
41. `if (( 10#$margin < 10 ))`. Then:

    ```
    alpha: margin low (09)
    beta: margin low (08)
    delta: margin low (07)
    margin check complete
    ```

    Three decks, and gamma correctly not flagged. Note `10#$margin` needs the
    `$` — `10#margin` is not a thing.

## F. Decimals

42. `average: 12` and `average: 12.60`.
43. Because integer division throws away the remainder immediately. `total/n*100`
    is `12*100` = 1200; `total*100/n` is `6300/5` = 1260. Multiply first, always.
44. 63/5 is exactly 12.6, so `12.60` is right here. Truncation shows up as soon as
    the division is inexact — try total 64: `12.80` exactly, total 62: `12.40`.
    Use readings summing to 64 with n=6 to see it bite.
45. `whole=$(( (total*100 + n/2) / n / 100 ))` style, or more simply compute
    `hundredths=$(( (total*100 + n/2) / n ))` and print
    `$((hundredths/100)).$((hundredths%100))` with `%02d`. Adding half the
    divisor before dividing is the standard integer-rounding trick.
46. `awk` is at `/opt/kestrel/bin/awk`. `bc` is **not installed**. With neither,
    you scale to integers and print with `printf`, which is what `average-2`
    does — and which is why knowing the trick matters.
47. Stop when you need real division, floating point, or more than about two
    lines of scaling arithmetic. `awk` does all three and is on every Unix; the
    moment you are writing a comment explaining your multiplication order, the
    shell has stopped being the cheap option.

## G. Arrays

48. See the readme.
49. The `${decks[*]}` loop, unquoted — `cargo` and `hold` come out as separate
    words. `"${decks[@]}"` keeps four elements.
50. `3` (number of elements) and `1` (length of the string `b`). `#` means length
    of, and `[@]` is what makes it a count.
51. `4` and `0 1 2 9`. Setting index 9 does not create 4 through 8.
52. `3` and `0 2 9`. The quotes stop the shell globbing `decks[1]` against files
    in the directory — a file named `decksX` would change what `unset` receives.
53. The index loop prints empty strings for the missing indices and misses index
    9 entirely, because `${#decks[@]}` is a count, not a highest index. Never
    loop `0..n-1` over a bash array.
54. `10` — one past the highest index, not one past the count.
55. Keys `vasquez` and `cargo hold`. Without `declare -A`, bash makes an
    **indexed** array and every string key evaluates as arithmetic to 0:

    ```
    declare -a crew=([0]="alpha")
    ```

    Every assignment overwrites element 0, silently.
56. `5`, and `[gamma 19]` — one element per line.
57. `10`. Word-splitting on whitespace gives one element per *field*, not per
    line. `mapfile -t` is the right tool; the `$( )` form is the one that looks
    fine on data without spaces.
58. ```bash
    best_deck=; best=-1
    while read -r deck value; do
        if (( 10#$value > best )); then best=$((10#$value)); best_deck=$deck; fi
    done < data/readings.txt
    echo "$best_deck $best"
    ```

    `epsilon 21`. `sort -k2 -n data/readings.txt | tail -1` agrees.

## H. Build

59–61. Expected shape:

```bash
#!/usr/bin/env bash
threshold=${1:-40}
case "$threshold" in ''|*[!0-9]*) echo "usage: hours [THRESHOLD]" >&2; exit 64 ;; esac

total=0 n=0
while IFS=: read -r id name deck hours; do
    [ "$id" = id ] && continue
    hours=$((10#$hours))
    total=$(( total + hours ))
    n=$(( n + 1 ))
    (( hours > threshold )) && echo "over: $name ($hours)"
done < data/crew.csv

tenths=$(( (total * 10 + n / 2) / n ))
printf 'total: %d\nmean:  %d.%d\n' "$total" "$((tenths / 10))" "$((tenths % 10))"
```

Total 159, mean 39.8, and two over the threshold: `over: okonkwo (41)` and
`over: rhea (44)`. Zero-pad `okonkwo`'s
41 to `041` in a copy and confirm the `10#` version still reports 41 while a
version without it reports 33.

62. Expect `SC2086` on unquoted expansions and a note about `read` without `-r`
    if you dropped it. The one people learn something from is usually
    `SC2155` — `local x=$(cmd)` masking the status, which is 12/05's trap, found
    by a tool.
