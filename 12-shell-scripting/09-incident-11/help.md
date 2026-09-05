# 12/09 — help

Read this only after you are stuck for real. It gives you questions, never
answers.

## "Where do I even start?"

Read `notes/incident.txt` and `notes/rules.txt` first. The incident says what
happened; the rules say what counts as an offender and what the report has to
look like. If you write a report without reading the rules you will spend your
time on the wrong format.

Then `ls ops/` and run `bin/check-inventory` with the count. It is the free
checkpoint — it exists to tell you the field you are working in.

## "I read all six scripts and only one writes to `data/`."

Then your definition of "writes" is `>` and `>>`. Ask yourself: after
`mv a b`, what does `b` contain? Was `b` written to or not? Now look again at
the script that only ever names a temp file.

## "`housekeeping.sh` only does rotate, prune, verify."

Where did you get that list? If the answer is "the usage text", read the `case`
statement instead. The usage text is written by a human. The `case` is what
runs.

## "I found the fourth mode but I cannot tell what it changes."

Do not run it in the lab. Copy the whole lab somewhere under `/tmp`, look at the
top of the copied script for the variable that decides where it reads and
writes, point it at the copy, and then run it. Diff the file before and after.

If you run it in the lab by accident: `setup.sh` is idempotent. Ask your
instructor to re-run it.

## "`bin/count-adjusted` keeps rejecting me."

Read the rejection text — it is different for different wrong answers, and each
one names what you got wrong. Two traps live here: the question asks how many
records were **lowered**, not how many were rewritten; and a record with a
leading zero is not automatically skipped. Check that second claim with a
one-line test rather than remembering 12/06.

Useful question: which comparison syntax is in the script, and does *that* one
care about leading zeros?

## "`nightly.sh` writes nothing. Why would it be on my list?"

Read the paragraph in `notes/rules.txt` about causing a write. Then ask: if a
scheduled job runs every night and something in `data/` changes every night,
does an auditor want a report that does not mention the scheduled job?

## "How do I make my tool find the indirect case without naming `nightly.sh`?"

Two passes. First pass: for every script, what fixed `data/` paths does it
write? Store that. Second pass: for every script, which other ops scripts does
it mention? Attribute their stored paths to it.

## "How do I exclude `import.sh` without special-casing it?"

Look at the destination expression in `import.sh` and the ones in the real
offenders and find the textual difference. It is visible in the line itself.
`notes/rules.txt` phrases the distinction for you.

## "`audit-attest` rejects my report and I do not understand the message."

Each rejection names one specific mistake, and they are checked in order, so fix
the one it tells you about and run it again. It normalises whitespace and
sorting for you, so a rejection is about content, not layout.

Fix the tool, not the report. A report you hand-edited to pass proves nothing,
and exercise 43 will ask you to score the tool.

## "Which token do I submit?"

`STAGE{...}` tokens are checkpoints. They are not registered with `kestrel` and
submitting one will fail. Only the `KESTREL{...}` string from a successful
attestation is a flag.

## Commands worth knowing here

- `diff` on a before/after copy
- `find DIR -type f -name '*.sh'`
- `grep -o`, `grep -h`, `grep -v`
- `shellcheck yourscript`
- `md5sum` on every file under `data/`, before and after a run
