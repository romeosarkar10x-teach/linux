# Tutor notes — Remediation

**Never give an answer.** One fact, or one question, then stop.

This is the lesson where students finally get to *do* something, and the
failure mode is speed. They will find all five faults in ten minutes, fix them
in five, and produce no record at all. If a student reaches exercise 48 with
fewer than six change records, send them back to exercise 7 — they cannot fill
in a `before` field they never captured, and discovering that is the lesson.

Insist on the order. A student who restores the summariser before clearing the
setuid bit has not lost anything today, but they should be asked which of their
changes would have needed doing twice if the hole had been used in between.

**Exercise 21 is the one to protect.** They will run `eng-scan`, read
`euid 1005`, and assume the file is not really setuid or that they have
misunderstood `stat`. Let them check the mode again. Let them be confused for a
minute. The reveal — that Linux ignores setuid on `#!` scripts — is worth far
more discovered than told, and the follow-up question is the important one: does
that make the file harmless? The answer is no, and the reason is that a mode
like that is evidence of intent regardless of whether it worked.

**Exercise 30 is the fulcrum of the chapter.** The report's numbers match the
clamped output and not the raw data. That is an arithmetic fact and it is the
first hard conclusion the student can defend. Watch what they write in exercise
31. "The report was generated after the clamp was in place" is right. "The
report was falsified" is a claim about intent that the arithmetic does not
support. "rhea falsified the report" fails rule 6 and everything else. Do not
let a strong sentence through because it feels earned.

Exercise 36 tends to produce a shrug. Push: they have just made the export
harmless, so why remove it? The answer — residue, and the next person who
restores the wrong file gets the clamp for free — is a genuinely useful idea
about cleanup that most people never articulate.

Exercise 47's `reversible` field invites an honest admission. If a student
overwrote the live summariser without keeping a copy, the correct response is
to praise the honesty and note the cost, not to mark them down. An investigator
who hides their own mistakes is worse than one who makes them.

On `sudo`: they need it for the setuid bit, the directory mode, and the
`.bashrc` edit, because those three are owned by root and ops-bot. Do not tell
them which ones. `Operation not permitted` is a clear enough teacher.

Exercise 56 closes the lesson and should not be rushed. A green `postcheck` is
the beginning of the report, and lesson 05 is that report.
