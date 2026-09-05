# Validation — Remediation

Judged by an agent reading the student's change records and terminal history.
No flag in this lesson.

`./bin/postcheck` must exit 0 in front of you. Run it yourself; do not accept a
pasted transcript.

There must be at least six change records, one per change, each with all six
fields filled and a `verified by` field containing a command that was actually
run. Pick two at random and re-run their verification commands. A record whose
`before` field is empty because the student never captured a before state is a
fail on this item — ask them how they would restore what they changed.

They can name all five faults and say which they closed first and why. The
order — close, fix, stop, restore, prove — should be visible in their record
timestamps, not merely recited.

On the setuid script: they cleared the bit, and they can explain that Linux
ignores setuid on `#!` scripts *and* that this does not make the file
uninteresting. A student who says "it was harmless so I left it" has failed
both halves.

On the directory mode: it is `1775`, not `775`. If it is `775` they used an
octal `chmod` and silently dropped the sticky bit; ask them what the leading
digit was for and have them restore it. They can say what the sticky bit
protects against.

On the apt source: removed, verified with a `grep` that exits non-zero, and —
this is the item students skip — recorded as an **open** problem that packages
already installed from that mirror remain unverified. If that is missing, the
remediation is incomplete however green `postcheck` is.

The report analysis is the item that matters most. They must state that the
three figures in `deck3-report.txt` match the clamped output (peak 6.0, mean
5.55 rounding to 5.6, exceedances 0) and not the raw sample (7.3, 5.88, 5), and
therefore that the report was produced after the clamp was in place. Read their
sentence carefully. It must contain no person and no motive. "The report was
falsified" overstates what arithmetic can show and fails this item; so does any
sentence naming an account as the author.

The regenerated report shows 7.3, 5.9 (or 5.88) and 5.

They stopped the loop with `SIGTERM` and can say why `-9` would have been the
wrong instinct on a system under investigation, referring to what they saw in
lesson 02.

They tested their own test (exercise 49) — broke one thing back, watched
`postcheck` catch it, restored it.

They named one thing they chose **not** to change, with a reason. The
group-writable `station/summariser`, or the plain-http `station.list`, are both
good answers. If everything they saw was changed, they were not exercising
judgement.

Close with: *"Your postcheck is green. Name three things that is still
consistent with."* Strong answers reach the installed packages, a second copy
of the fault somewhere outside this lab, and continued access by whoever made
the changes. A student who treats green as finished is not ready for lesson 05.
