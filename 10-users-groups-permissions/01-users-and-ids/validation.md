# 10/01 — Validation

For the validator agent. Rubric only; there is no script and there will not be one.

## Pass requires all of

1. **Identity is a number.** The student states, unprompted or when asked, that the kernel checks
   uids and that names are looked up. A student who explains root purely by its name has not passed.
2. **The seven fields**, correctly labelled, with field 2 explained as "the hash lives in
   `/etc/shadow`" and field 4 identified as the *primary group*.
3. **uid ≠ gid.** They can give their own two numbers (1005 and 1008) and say they are unrelated.
4. **`getent` over `grep`**, with a concrete demonstration — exercise 19's two lines, or the
   `grep deck` case, or an equivalent they found themselves.
5. **`UID_MIN` and its exception.** Both sentences from exercise 26. One without the other is a fail
   on this item.
6. **`nologin` understood as "no interactive login", not "disabled"**, with at least one thing such
   an account can still do.
7. **Exercise 32's arithmetic closes**: 19 login accounts, 17 aboard, and the two extras named.
8. **Reporting.** The exercise 43–45 answers contain no accusation and no person, and carry the
   date-of-export caveat.

## Red flags

- Attributing `eng-svc` to anybody, or asserting when or why it was created. The lab does not say,
  and the correct answer to "who made it" is "that is the question I would ask next". Treat a
  confident answer here as a fail on item 8 regardless of how good the rest is.
- Recommending that any account be deleted. Nothing in this lesson supports that, and lesson 03 will
  show why it is the expensive half of the job.
- Using `sudo` anywhere in this lesson. Everything here is readable. A student reaching for `sudo`
  to read `/etc/passwd` has not read the mode.
- Editing `/etc/passwd` or `/etc/group`, even in a way that "works". Exercise 46 and 47 are done on
  a **copy in `scratch/`**; a student who did them in place has done something a real station would
  treat as an incident.
- Claiming `$USER` is unset "because this is a container". It is unset because nothing ran a login
  program. The distinction matters and a student who has it can be asked about `su -` in lesson 07.
- Saying `logname` "is broken". It refused correctly.

## Good signs

- Notices before being asked that `nobody` breaks the `UID_MIN` heuristic.
- Notices that `eng-svc` has no gecos while all thirteen other service accounts do — the
  pattern-break, not just the missing crew-list entry.
- Reaches for `awk -F:` without being told, having had it in chapter 7.
- Asks what happens to `ls -l` when an account is deleted, before exercise 53 asks them.
- Answers exercise 55 with "the defence is that the secret is not in the file", rather than
  "hide the file".

## Questions to ask if the written answers are thin

- "Give me an account on this container where uid and gid differ." (All five human ones do.)
- "`grep 1004 /etc/passwd` gave two lines. Why?"
- "What can `ops-bot` do, given `/usr/sbin/nologin`?"
- "How many accounts in the export could you not classify, and what would you do about it?"
