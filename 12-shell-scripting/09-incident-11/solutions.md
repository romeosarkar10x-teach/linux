# 12/09 — solutions

Instructor copy. Contains the flag in plaintext. Do not hand to students.

Lab: `/labs/12-shell-scripting/09-incident-11`.

## The shape of this lesson

The student is asked for an **audit**, not a repair. `notes/incident.txt` says
so explicitly: nothing under `ops/` may be edited before the audit is attested.
This matters because the natural instinct — spot the bad line, fix it, move on —
destroys the evidence and produces no report. Every checkpoint in `bin/` is a
read-only claim about the system as it stands.

Three offenders, chosen so that they fail three different reading strategies:

| offender | data file | why it is missed |
| --- | --- | --- |
| `housekeeping.sh` | `data/margins.txt` | hidden behind an undocumented mode |
| `fix-units.sh` | `data/readings.txt` | writes via `mktemp` + `mv`, no redirect |
| `nightly.sh` | `data/margins.txt` | writes nothing itself; calls the one that does |

And one red herring: `import.sh` writes under `data/` but its destination comes
from its argument, which `notes/rules.txt` excludes.

## A. Warmup

1. Six: `summarize.sh`, `rotate-logs.sh`, `import.sh`, `fix-units.sh`,
   `housekeeping.sh`, `nightly.sh`.
2. `bin/check-inventory 6` → `STAGE{six-scripts-one-liar}`.
   Any other number is rejected with the count it wanted.
3. The claim is exactly: cleanup completed, and zero files were removed.
4. Five consecutive nights, identical text.
5. It does not claim that nothing was **written**. "Removed" is a claim about
   deletion only. This one observation is the whole incident.
6. Expected:
   - `summarize.sh` → `reports/summary.txt`
   - `rotate-logs.sh` → `logs/`
   - `import.sh` → `data/incoming/<basename of $1>`
   - `fix-units.sh` → a temp file, then `mv` (this is the trap; most students
     write "nothing" here and correct it at exercise 27)
   - `housekeeping.sh` → `logs/housekeeping.log` (they will not yet see
     `data/margins.txt`)
   - `nightly.sh` → nothing
7. Seven records. `deck-02 09`, `deck-04 07`, `deck-07 08` have leading zeros.

## B. `housekeeping.sh`

8. Three: `usage()` prints `[rotate|prune|verify]`.
9. Four. The `case` has a branch for `adjust`.
10. `bin/name-mode adjust` → `STAGE{the-fourth-mode}`.
11. With no argument it falls to the `*)` branch, which calls `prune` — so a
    bare run logs a cleanup line and removes nothing. Measured:

    ```
    $ ops/housekeeping.sh ; echo rc=$?
    rc=0
    $ tail -1 logs/housekeeping.log
    2187-07-05 02:00 housekeeping: cleanup complete, 0 files removed
    ```

12. Files under `scratch/` older than the retention window — of which there are
    none, hence the constant zero.
13. Literally true, and that is the point. The log line was never a lie; it was
    simply an incomplete description of what the script does.
14. It rewrites every record, clamping any margin above `THRESHOLD` down to
    `THRESHOLD`, and replaces `data/margins.txt` with the result.
15. The log says `cleanup complete, 0 files removed`, because `adjust` ends by
    calling `prune`. That run removed nothing and rewrote seven records, four of
    them changed.
16. `[ "$margin" -gt "$THRESHOLD" ]`.
17. It does **not** break. `test`/`[` parses its integer operands as decimal, so
    a leading zero is insignificant. Measured:

    ```
    $ [ 09 -gt 10 ]; echo $?
    1
    $ [ 09 -gt 5 ]; echo $?
    0
    $ (( 09 > 5 )); echo $?
    bash: ((: 09: value too great for base (error token is "09")
    1
    ```

    This is the deliberate contrast with 12/06: same-looking comparison,
    different parser. Accept any answer that cites `help test` / `man 1 test`
    or shows a run. Reject "it breaks, like last time" — that is the memory
    answer the exercise forbids.
18. Four. `14`, `22`, `31`, `12` exceed the threshold of 10 and become `10`;
    `09`, `07`, `08` are already below and are copied through unchanged.
    `bin/count-adjusted 4` → `STAGE{four-records-quietly-lowered}`.

    The checker rejects `7` with "seven records were rewritten; the question is
    how many were *lowered*", and rejects `3` with a hint that a leading zero is
    not the reason a record was skipped here.
19. Before/after on a `/tmp` copy:

    ```
    deck-01 14   ->  deck-01 10
    deck-02 09   ->  deck-02 09
    deck-03 22   ->  deck-03 10
    deck-04 07   ->  deck-04 07
    deck-05 31   ->  deck-05 10
    deck-06 12   ->  deck-06 10
    deck-07 08   ->  deck-07 08
    ```

    Note the script must be pointed at the copy — `LAB` is set at the top of the
    file. A student who runs the copy without changing `LAB` edits the real lab.
    That is worth catching in review; it is also why the lesson says to copy.
20. `housekeeping.sh rotate`, then `housekeeping.sh adjust`, then
    `summarize.sh` — in that order.
21. Every summary in `reports/` describes the data **after** clamping. The
    report can never disagree with the file, because the file was edited first.
22. One mechanism: the nightly run lowers out-of-tolerance margins to exactly
    the tolerance and then summarises the edited file. Physical inspection sees
    the real margin; the summary sees the clamped one. Two decks, one cause.

## C. The other scripts

23. No. `reports/summary.txt`.
24. No. Under `logs/`.
25. `data/incoming/$(basename -- "$1")`.
26. `notes/rules.txt` counts a script as an offender only when the destination
    is fixed by the script itself; `import.sh` writes wherever its caller's
    argument names, so the caller — not the script — chose the destination.
27. `mv -- "$tmp" "$src"`, where `src` is `"$LAB/data/readings.txt"`.
28. Afterwards the destination path holds bytes the script produced, and the
    bytes that were there are gone. That is a write, whatever the command is
    named. A tool that greps for `>` alone will not see it.
29. It proves the file's mtime, which is metadata that any of `touch`, `cp -p`,
    a restore, or an edit-then-reset can set. It does not prove when the script
    ran, how often, or whether the content matches what ran.
30. `notes/rules.txt` attributes a target to the script that causes the write.
    `nightly.sh` invokes `housekeeping.sh adjust`, so `data/margins.txt` is
    attributed to it. Without this rule an audit reports only leaf scripts and
    misses everything scheduled.
31. ```
    fix-units.sh data/readings.txt
    housekeeping.sh data/margins.txt
    nightly.sh data/margins.txt
    ```

## D. The audit tool

Reference implementation. Students' tools will differ; grade against the six
shipping requirements from 12/08 and against the attestation passing.

```bash
#!/usr/bin/env bash
# audit — report ops scripts that write to fixed paths under data/.
#
# usage: audit [OPSDIR]
#
# exit codes:
#   0  report written
#  64  usage error
#  66  ops directory unreadable
set -euo pipefail

OPSDIR=${1:-/labs/12-shell-scripting/09-incident-11/ops}

usage() {
    cat <<'EOF'
usage: audit [OPSDIR]

Report ops scripts that write to a fixed path under data/.
Output: one "script data/file" line per offender, sorted.

  -h, --help   this text
EOF
}

case ${1:-} in
    -h|--help) usage; exit 0 ;;
    -*)        usage >&2; exit 64 ;;
esac

[ -d "$OPSDIR" ] && [ -r "$OPSDIR" ] || {
    printf 'audit: cannot read ops directory: %s\n' "$OPSDIR" >&2
    exit 66
}

# What counts as a write, for this tool: a redirect (> or >>), or one of
# cp, mv, tee, sed -i, truncate, naming a path under data/. This is a
# heuristic. It cannot see through eval, and it cannot see a path that is
# assembled at runtime from data the script did not contain.
writes_in() {
    grep -hoE '(>>?|cp|mv|tee|sed -i|truncate)[^|;&]*(\$[A-Za-z_]+/)?data/[A-Za-z0-9_.-]+' "$1" \
        | grep -oE 'data/[A-Za-z0-9_.-]+' | sort -u
}

# A destination taken from a positional parameter belongs to the caller,
# not to this script, so drop those lines before extracting the path.
fixed_writes_in() {
    grep -vE '\$\{?[0-9@*]' "$1" > "$tmp"
    writes_in "$tmp"
}

tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT

declare -A direct
scripts=$(find "$OPSDIR" -type f -name '*.sh' | sort)

while read -r s; do
    name=$(basename -- "$s")
    for f in $(fixed_writes_in "$s"); do
        direct["$name"]+="$f "
    done
done <<< "$scripts"

report() {
    while read -r s; do
        name=$(basename -- "$s")
        for f in ${direct["$name"]:-}; do
            printf '%s %s\n' "$name" "$f"
        done
        # indirect: attribute the targets of every ops script this one calls
        for callee in $(grep -oE '[A-Za-z0-9_-]+\.sh' "$s" | sort -u); do
            [ "$callee" = "$name" ] && continue
            for f in ${direct["$callee"]:-}; do
                printf '%s %s\n' "$name" "$f"
            done
        done
    done <<< "$scripts"
}

report | sort -u
```

32–33. Straight from 12/08. The only new judgement is the default: hard-coding
the lab path is fine as a *default*, not as the only possibility, because an
auditor runs the tool against a copy.

34. `find "$OPSDIR" -type f -name '*.sh'`. `ls` output is not a list of
    filenames (12/04) and a glob silently yields the literal pattern when
    nothing matches — and, unlike `find`, does not descend.

35. The comment in the reference lists the heuristic. Full credit requires the
    student to write down that it is one. An audit tool that presents a
    heuristic as a proof is worse than no tool.

36. By excluding lines that mention a positional parameter before extracting a
    path. Anything the caller supplies is the caller's choice of destination.
    Students who instead special-case the name `import.sh` should be failed on
    this exercise even though the report comes out right — exercise 38 exists
    to make that failure visible.

37. Build a map of script → targets first, then a second pass attributing each
    callee's targets to its caller. One level is enough here; say so, rather
    than pretending to a transitive closure the tool does not compute.

38. `nightly.sh` contains no `data/` path at all, so it can only appear if the
    indirect pass works.

39. Exact format, from `notes/rules.txt`: `<script> <path relative to lab>`,
    one per line, sorted, no header.

40. ```
    $ bin/audit-attest < report.txt
    ```

    The checker canonicalises whitespace, strips `./`, and sorts, so formatting
    slips do not cause false rejections. Rejections, in the order they are
    tested:

    - empty input
    - `import.sh` named — the caller chooses that path
    - `summarize.sh` or `rotate-logs.sh` named — neither writes under `data/`
    - `housekeeping.sh data/margins.txt` missing — "the fourth mode"
    - `fix-units.sh data/readings.txt` missing — "a write does not have to be a
      redirect"
    - `nightly.sh data/margins.txt` missing — "a script that writes nothing can
      still be responsible for a write"
    - right lines, wrong count — extra rows

    On success it prints the attestation and the flag.

41. **Flag: `KESTREL{a_cleanup_that_wrote_more_than_it_removed}`**

    ```
    kestrel flags submit 'KESTREL{a_cleanup_that_wrote_more_than_it_removed}'
    ```

    The three `STAGE{...}` tokens are not flags and are not registered; a
    student who submits one gets a rejection from `kestrel`, which is the
    intended lesson about reading instructions.

42. The reference passes `shellcheck` clean. The likely student findings are
    SC2086 (unquoted expansion — deliberate in the `for f in ${direct[...]}`
    loops, and must be *justified in a comment*, not silenced), and SC2162
    (`read` without `-r`), which is a real bug and must be fixed.

43. The six from 12/08: shebang, executable bit, on `PATH` or invoked by path
    deliberately, `--help` on stdout exiting 0, distinct exit codes documented
    in the file, and no hard-coded path that cannot be overridden.

## E. Experiment

44. A `"$DATA/margins.txt"` write is caught by the reference regex, because the
    `(\$[A-Za-z_]+/)?` branch allows a variable prefix — but the tool has no
    idea what `DATA` is, so it reports the path as written. Say that out loud in
    the report: the tool matches text, not filesystem locations.
45. `eval` on a constructed command is invisible. The limit it reveals: static
    reading of a shell script cannot enumerate what the script will do, only
    what it says. An audit reports evidence, not behaviour.
46. Measured on the lab:

    ```
    $ grep -rn '>' ops/ | wc -l
    10
    $ grep -rn '>>' ops/ | wc -l
    3
    ```

    Most of the ten are `>` inside `2>&1`, `>&2`, and comparisons — the point
    being that grepping for a bare `>` gives noise and still misses `mv`.
47. Yes — a `>` redirect naming `data/margins.txt` is the easiest case for the
    tool. `mv` is the hard case, which is why the lab uses it.
48. With `THRESHOLD=100` no record is above it, so every record is copied
    through unchanged and the data is byte-identical — while the log line is
    exactly the same as on a night that changed four records. The log carries no
    information about whether anything happened.

## F. Stretch

49. Any well-formed JSON, one object per offender, is acceptable; check that it
    is emitted by the same code path as the text report rather than a second
    hand-maintained one.
50. An auditor wants `--since` to scope a review to a window of interest. It
    must not be the default because mtime is attacker-controllable metadata
    (exercise 29), so a default filter would silently drop evidence.
51. Model answer: "Three scripts under `ops/` write to files under `data/`;
    `housekeeping.sh` does so through a mode its own usage text does not list,
    and `nightly.sh` invokes it every night. The nightly log line reports only
    file removals, so five nights of identical output are consistent with both a
    no-op and a rewrite of every margin record. I did not determine when the
    `adjust` mode was added, by whom, or whether any run was reviewed."
52. Almost all of it survives, because the model answer was written without
    intent words. If the student's did not, the deletion is the lesson.
53. Repair sketch, not applied: list `adjust` in `usage()`; have `prune` log
    what it removed and `adjust` log what it changed, as separate lines; and a
    test that runs `nightly.sh` against a fixture and asserts `data/` is
    byte-identical afterwards — which would have failed on night one.

## G. Dig

54. `find ... -exec ... \;` (or `-exec ... +`). The loop is still preferable
    here because the tool builds an associative map across scripts and needs a
    second pass; `-exec` gives one process per file with no shared state.
55. `grep -o` prints only the matching part, `grep -h` suppresses the filename
    prefix when several files are searched. Both keep the report clean without
    a `sed` pass afterwards.
56. `sed -i` does not edit in place; it writes a new file and renames it over
    the original, so the inode number changes and the original permissions are
    reconstructed rather than preserved. Measured:

    ```
    $ printf a > s1; ls -i s1
    4108771 s1
    $ sed -i s/a/b/ s1; ls -i s1
    4108862 s1
    ```

    An audit that greps only for `>` misses `sed -i` for the same reason it
    misses `mv`: the write is performed by a rename.

## H. Bring it together

57. The rule cannot check the log text. It has to check state: hash every file
    under `data/` before and after the nightly run and alert when a hash changes
    on a night whose log reports only removals. Machine-checkable, and it does
    not depend on the script telling the truth about itself.
58. Expect `fix-units.sh` most often — `mv` reads as cleanup, not as a write.
    `nightly.sh` is the second most-missed, because it contains no path at all.
59. Something like: `# adjust: rewrites data/margins.txt, clamping margins to
    THRESHOLD. Not listed in usage().` One sentence, no behaviour change, and
    the incident is a five-minute read.

## Instructor notes

- The flag is stored base64-encoded inside `bin/audit-attest` and printed only
  after the report validates, so `grep -r 'KESTREL{' /labs/12-shell-scripting/`
  returns nothing (verified, exit status 1) and reading the checker does not
  shortcut the work.
- `bin/name-mode` accepts only the exact lowercase `adjust`; `ADJUST` is rejected
  (verified), which is fair — the mode name in the `case` is lowercase.
- If a student edits `ops/` before attesting, have them `git`-less restore by
  re-running `setup.sh`; it is idempotent.
- The captain does not appear in this lesson. Nothing in the lab names who added
  `adjust`, and nothing should be inferred from the fact that it is undocumented.
