# 12/09 — exercises

Lab: `/labs/12-shell-scripting/09-incident-11`.

Read `notes/incident.txt` and `notes/rules.txt` before exercise 1. Do **not**
edit anything under `ops/` until the audit is attested.

## A. Warmup — the tree

1. List `ops/`. How many scripts are there?
2. Run `bin/check-inventory` with your count. Record the token.
3. Read `notes/page.txt`. Write down, in one sentence, exactly what the logged
   line claims — using only words that appear in it.
4. `tail -5 logs/housekeeping.log`. How many consecutive nights say the same
   thing?
5. Name one thing that line does **not** claim.
6. Without running anything, list which scripts in `ops/` write a file, and to
   where. One line each.
7. `cat data/margins.txt`. How many records, and which have a leading zero?

## B. Core — read `housekeeping.sh`

8. Read its `usage()` function. How many modes does it document?
9. Read its `case` statement. How many modes does it accept?
10. Name the difference and run `bin/name-mode` with it.
11. What does the script do when run with **no** argument at all? Quote the line
    of the `case` that decides it.
12. Read `prune`. What does it remove?
13. Read the `log` line `prune` writes. Is it true?
14. Read `adjust`. In your own words, one sentence, what does it do to
    `data/margins.txt`?
15. `adjust` ends by calling `prune`. What does the log say after an `adjust`
    run, and what did that run actually do?
16. Which is the comparison in `adjust` — `[ ... -gt ... ]` or `(( ... > ... ))`?
17. In 12/06 a leading zero broke `(( ))`. Does it break the comparison this
    script actually uses? Answer from the manual or a one-line test, **not** from
    memory, and say how you checked.
18. Work out by hand how many records `adjust` would rewrite on
    `data/margins.txt` as it stands. Run `bin/count-adjusted` with your answer.
19. Copy the whole lab to `/tmp`, point the copy's scripts at the copy, and run
    `adjust` there. Compare the before and after. Did your hand count match?
20. In the copy, run `ops/nightly.sh`. Which three things run, and in which
    order?
21. `ops/summarize.sh` runs **after** `adjust` in `nightly.sh`. Say in one
    sentence what that ordering means for every summary in `reports/`.
22. The incident says two deck inspections found margins outside tolerance on
    days the summary said otherwise. Explain both observations with one
    mechanism.

## C. Core — the other scripts

23. Read `ops/summarize.sh`. Does it write under `data/`? Where does its output
    go?
24. Read `ops/rotate-logs.sh`. Same two questions.
25. Read `ops/import.sh`. It writes under `data/`. Quote the expression that
    decides the destination path.
26. Using the wording in `notes/rules.txt`, say why `import.sh` is not an
    offender, in one sentence.
27. Read `ops/fix-units.sh`. It never names a destination other than a temp
    file. Find the line that writes `data/`.
28. Why is `mv` a write to the destination? Answer in terms of what the file
    contains afterwards, not in terms of what `mv` is called.
29. `fix-units.sh` is dated 2186-09-11 and its comment says it was run once.
    Does the file's timestamp prove that? Say what it does and does not prove.
30. Read `ops/nightly.sh`. It writes nothing at all. Say why it is an offender
    anyway.
31. Write out the complete list of offenders, with the data file each one ends
    up writing.

## D. Core — build the audit tool

You are writing a tool, not a one-liner. Put it in `scratch/audit` or in
`~/.local/bin`; say which.

32. Start from 12/08's skeleton: shebang, `set -euo pipefail`, a comment block
    of exit codes, `usage()`, `--help` on stdout exiting 0.
33. Make it take the ops directory as an argument, defaulting to the lab's
    `ops/`. Do not hard-code a path you cannot override.
34. Stage one: list every `*.sh` under the ops directory. Use `find`, and say
    why not `ls` or a glob (12/04).
35. Stage two: for each script, find every line that writes to a path under
    `data/`. Decide what "writes" means to your tool — `>`, `>>`, `cp`, `mv`,
    `tee`, `sed -i`, `truncate` — and write the list down in a comment. It is a
    heuristic and you should say so.
36. Test stage two against `import.sh`, which must be found and then excluded.
    How does your tool tell "path from an argument" from "path from a
    constant"?
37. Stage three: catch the indirect case. For each script, find the ops scripts
    it invokes, and attribute their targets to it.
38. Test that your tool reports `nightly.sh` without you having special-cased
    the name `nightly.sh`.
39. Have it print the report in the exact format `notes/rules.txt` specifies,
    sorted, one line per offender.
40. Run `bin/audit-attest < report.txt`. If it rejects, read the rejection —
    each one names a specific mistake — and fix the **tool**, not the report.
41. Record the flag and submit it: `kestrel flags submit 'KESTREL{...}'`. Do not
    submit any `STAGE{...}` token.
42. `shellcheck` your audit tool. Fix or justify every finding.
43. Score your tool against 12/08's six shipping requirements, in writing.

## E. Experiment — predict first

44. Predict what your tool reports if a script writes to `"$DATA/margins.txt"`
    where `DATA` is set at the top of the file. Add that to the copy in `/tmp`
    and check.
45. Predict what it reports for a script that runs `eval` on a constructed
    command. Write down one sentence on the limit that reveals.
46. Predict the output of `grep -rn '>' ops/` and then run it. How much of the
    noise is redirection?
47. Predict whether your tool would find the offender if `adjust` used
    `printf ... > "$file"` instead of `mv`. Test it.
48. In the `/tmp` copy, change `THRESHOLD` to 100 and run `adjust`. What changes
    in the data, and what changes in the log?

## F. Stretch

49. Extend the tool with `--json`, one object per offender.
50. Add a `--since DATE` that reports only scripts modified after a date, and
    say why an auditor would want that and why it must not be the default.
51. Write the three-sentence finding you would attach to incident 11. It states
    what the scripts do, what the log line does not cover, and what you did not
    determine.
52. Read your finding back and delete every word that assigns intent. Say what
    is left.
53. Propose the repair — do not apply it — as a diff-sized description: what
    changes in `housekeeping.sh`, what changes in its log line, and what test
    would have caught this on the first night.

## G. Dig

54. Find the `find` flag that would let you run your check on each script
    without a shell loop, and say why you might still prefer the loop here.
55. `grep -o` and `grep -h` both matter for building a report cleanly. Find what
    each does and use one of them.
56. Find out what `sed -i` does about permissions and inode numbers, and say why
    an audit that greps for `>` alone would miss it.

## H. Bring it together

57. ops-bot reported the log line and closed the matter. In two sentences, say
    what a monitoring rule would have to check instead — phrased so that a
    machine could check it.
58. `notes/rules.txt` says "being wrong matters". Now that you are through, say
    which of the three offenders you would have missed reading by eye, and why.
59. Write the one sentence you would add to `ops/housekeeping.sh`'s header —
    without changing its behaviour — that would have made this incident a
    five-minute read.
