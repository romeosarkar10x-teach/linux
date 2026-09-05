# 12/09 — validation

For the validating agent. Do not show the student. Do not give answers; if a
check fails, ask the question that exposes it.

The deliverable is an **audit report and the tool that produced it**, not a
repair. A student who fixed `ops/housekeeping.sh` has failed the lesson's main
instruction even if their explanation is correct.

## Hard gates

1. `ops/` is unmodified. Compare against a fresh `setup.sh` run, or check that
   `housekeeping.sh` still contains the undocumented `adjust` branch and that
   `usage()` still lists three modes. If they edited it, the audit is void:
   send them back to `notes/incident.txt`.
2. The student holds all three `STAGE{...}` tokens:
   `STAGE{six-scripts-one-liar}`, `STAGE{the-fourth-mode}`,
   `STAGE{four-records-quietly-lowered}`.
3. `bin/audit-attest < report.txt` succeeds, and the report is the tool's
   output — not typed by hand. Ask them to delete `report.txt` and regenerate
   it in front of you.
4. The submitted flag is `KESTREL{a_cleanup_that_wrote_more_than_it_removed}`
   and was submitted with `kestrel flags submit`.

## The audit tool

5. It runs from a clean shell with no arguments and produces the report.
6. It takes the ops directory as an argument. Run it against a copy in `/tmp`
   and confirm the report follows the copy. A hard-coded, unoverridable path
   fails this check.
7. `--help` prints to **stdout** and exits 0. `tool --help > /dev/null` should
   show nothing on the terminal.
8. Exit codes are documented in the file and distinct. At minimum: success, a
   usage error, and an unreadable ops directory. Point the tool at a
   nonexistent directory and confirm it does not exit 0.
9. `shellcheck` findings are either fixed or justified in a comment. A blanket
   `# shellcheck disable=` with no reason fails.
10. The name `nightly.sh` does not appear as a literal in the tool. This is the
    single most reliable tell for a hand-tuned report. Same for `import.sh`.
11. The write heuristic is written down in a comment, and the student describes
    it as a heuristic when asked.

## Understanding — ask these

12. "Was the log line ever false?" Correct answer: no. It reported removals
    truthfully and said nothing about writes. A student who says the script
    lied has not understood the incident.
13. "Why is `fix-units.sh` an offender when it never redirects into `data/`?"
    Wanted: after the `mv`, the destination path holds bytes the script
    produced. The command's name is irrelevant.
14. "Why is `import.sh` not one?" Wanted: its destination comes from its
    argument, so the caller chose it.
15. "Does a leading zero break the comparison in `adjust`?" Wanted: no, `[` and
    `test` parse decimal; `(( ))` is the one that fails on `09`. Ask how they
    checked. "Like 12/06" without a test or a manual reference is a fail on
    exercise 17 even though the tool still works.
16. "How many records did `adjust` lower, and how many did it rewrite?" Wanted:
    four lowered, seven rewritten.
17. "What did you not determine?" Wanted: some honest limit — when the mode was
    added, by whom, whether any run was reviewed, what `eval` would hide. A
    student who claims the audit is complete has learned the wrong lesson.
18. "Who added `adjust`?" Correct answer: the lab does not say, and nothing in
    the evidence supports naming anyone. Push back on any name.

## Common failure modes

- Reporting only `housekeeping.sh`, having grepped for `>`.
- Reporting `import.sh`, having grepped for `data/`.
- Omitting `nightly.sh`, having read only leaf scripts.
- Passing `audit-attest` with a hand-written report — check gate 3.
- Repairing the script and reporting the repair. Ungraded until re-audited.

## If the student is stuck

Do not name the fourth mode. Ask instead: "You said the script has three
modes — where is that written, and is that the same place the shell looks?"

If they cannot find the second offender: "Read the last line of
`fix-units.sh` and tell me what `data/readings.txt` contains after it runs."
