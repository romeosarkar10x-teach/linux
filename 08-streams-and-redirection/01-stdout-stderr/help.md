# 08/01 — Tutor guide: stdout and stderr

Read `docs/TUTOR_PROTOCOL.md` first. Guide with questions. **Never hand over an answer**, including
the ones that look too small to matter — "it's 6" is the whole of exercise 12.

## What the lesson is actually for

Not the syntax. The syntax is next lesson. This lesson has exactly one job: make the student
*believe*, from their own hands, that fd 1 and fd 2 are two separate destinations that happen to be
aimed at the same screen.

A student who has not internalised that will write `2>&1 >file` next lesson, get the wrong answer,
and have no model to debug it with. A student who has will find that ordering rule obvious.

The secondary job is the chapter's seed: **exit 0 is honest**. `panelcheck` clamps, complains
correctly, and succeeds. If the student leaves believing exit 0 means "nothing to see here", the
chapter finale lands as a trick instead of as a consequence.

## Where students stall, and what to ask

**"Which stream is this line on?" (ex 5–7).** They want to be told. Ask: *what is the cheapest
experiment that would tell you?* If they are stuck, ask what `2>/dev/null` did in the readme.

**Exercise 10, `>/dev/null | wc -l` prints 0.** Very common confusion — they expected stderr to
"fall into" the pipe. Ask: *a pipe connects which descriptor of the left command to which descriptor
of the right one?* Do not give them `2>&1 >/dev/null`; exercise 11 exists to leave them wanting it.

**Exercise 15, `grep -c panel` = 8.** The best moment in the lesson. If they say "grep missed some",
ask: *missed, or never received?* Push until they say the words "grep can only filter what it was
given".

**Exercise 20, closed fd 1.** Some students conclude the program is broken. Ask: *if you had to
report that your only way of reporting things is gone, how would you do it?*

**Exercise 24, `2>&1`.** They have not been taught it. If they demand the rule, decline and ask them
to write down their guess — the next lesson opens by checking that sentence. A wrong guess written
down is worth more here than a right rule handed over.

**Exercise 33.** Students want a clean four-way answer. Two of the four are debatable and the
correct response is to say which two and why. If a student gives four confident answers, ask them to
argue the opposite case for `6 panels checked`.

**Exercise 44.** Do not adjudicate. Ask what the *caller* does with the status. That question turns
an opinion into an engineering answer, and it is the one they will need in Chapter 12.

## Common wrong models to catch early

- "stderr is for errors." Correct it with a question: *is `which deck?` an error?*
- "The program decides where its output goes." Ask them to make `fdreport` print `/tmp/o.txt` for
  fd 1 without editing the script.
- "Redirection loses the other stream." Exercise 23 disproves it; make them run it.
- "Exit 0 means fine." Ask what `panelcheck` clamped.

## Never say

- The value of exercise 12 (6), 9 (10), or 15 (8).
- `2>&1 >/dev/null` before the student has finished exercise 11.
- Which two lines in exercise 33 are the debatable ones.
- Anything about the chapter's incident, `/var/tmp/panelcheck.d`, or why the complaints are unread.
  The `see /var/tmp/…` line is deliberately visible from lesson 01 and must stay unexplained.
