# Tutor notes — Triage

**Never give an answer.** Give one fact, or one question, and stop.

This lesson has no new hard command. `ps`, `pgrep` and `lsof` are chapter 7
tools; `/proc` is chapter 8; `getent` and the group files are chapter 10. What
is new is the habit: read the account, not the person, and read the process
before you touch it.

Two failures dominate.

**"The account is a bot, so nobody is watching it."** Students slide from
`nologin` to intent within one sentence. `nologin` is a fact about a shell
field. What runs as `ops-bot` was started by something, and the whole chapter
turns on that something. If a claim's `says` line contains a motive, send them
back to lesson 01 rule 4 and no further.

**`sudo cmd < /proc/PID/environ`.** They will be certain sudo failed. It never
ran. The shell opens the redirection as cadet before exec'ing sudo. Ask them
which process opens the `<`. Do not say "use `sudo cat`" — they get there in
one step once they see who opens the file.

For exercise 34 (`rm var/summary.log`) let them do it. They will assume the
data is gone. It is on fd 3 for as long as the process lives, and recovering it
through `/proc/PID/fd/3` is the moment the lesson exists for. If they baulk at
deleting evidence, that instinct is right and worth naming — then point out
that this is a copy in a lab, which is exactly why rule 5 says work on copies.

For exercise 41, insist on a written prediction before the command. A student
who runs `kill` first and reasons afterwards has learned nothing; `Operation
not permitted` is only interesting if you expected otherwise.

The `eng-svc` account (exercise 45) is the chapter's first genuine hook. It
appears in a log and does not exist in `/etc/passwd`. Both facts are true and
neither explains the other. Refuse every theory. "Write down both. Move on."

Exercise 52 — the 2186-10-06 mtime on `bin/strain-summary` — is deliberately
unexplained. If a student notices it unprompted, say so plainly: yes, that is
seven months out of place, write it in the case file, lesson 03 is about
timestamps. Do not hint at what it means.

Nobody should name a person in this lesson. `dorn` in exercise 50 is an account
in a log line, and the correct sentence is "the account `dorn` logged out at
04:12:38", not anything about dorn.
