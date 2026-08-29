# 10/08 — Tutor notes

For the tutor agent. Not for the student. **Never give an answer.** Ask the question. This lesson is
also the chapter's incident and carries the flag; the CTF rules in `docs/GAMEMASTER_PROTOCOL.md`
apply to the four stages.

## What this lesson is actually about

1. **Effective uid versus real uid.** Everything else is decoration on that distinction.
2. **Scope, not power.** A setuid binary is judged by what it can reach when handed an arbitrary
   path, not by how small or well-meaning it is.
3. **A legitimate special bit and an illegitimate one look identical in `ls -l`.** The audit is the
   skill; the fix is two characters.

## The stages

- **1** (`bin/readas` on `audit/stage1.txt`) — anybody who read `notes/setuid.txt` gets it. If a
  student is stuck here the problem is that they have not read the notes; send them back rather than
  hinting.
- **2** (`audit/stage2.txt`, mode `0004`) — the cliff, and it should be. They will try `sudo cat`,
  which works and is *wrong* — it tells them nothing and it uses root for a lesson about triads. If
  they do it, do not call it wrong; ask what they learned, then ask them to get it again without
  root. Nearly everybody tries `sudo -u rhea` and fails, because rhea is in `crew`. That failure is
  the teaching moment: ask which triad applied to her.
- **3** (`usermod -aG` + re-login) — the common wall is `id` not changing. Ask where a process's
  group list comes from, and when.
- **4** (the helper on the `dorn:dorn` file) — usually immediate once stage 3 lands.

Every stage fails loudly: `Permission denied` at 1, 2 and 3; `bash: ./bin/summarise-hash: Permission
denied` at 4. Nothing here fails silently or gives a wrong-looking success.

## Questions worth having ready

When they read `audit/stage1.txt` with the setuid `cat`:

- "Which process was root just then?"
- "How many files can that program read?"
- "What is the difference between that and `sudo cat`, from root's point of view?" (None. That is the
  point.)

When they find `bin/summarise-hash` and call it a backdoor:

- "What can it do that a shell could not?" (Read as dorn. That is all — it is *narrower* than a
  backdoor.)
- "So is it fine?" (No. Ask them to say why in terms of paths rather than intent.)

When they reach exercise 62 and read `/home/dorn/.profile` through it — some will feel they have done
something wrong. They have demonstrated the flaw, on a file the account owner left behind, which is
the demonstration the audit needs. Reading anything of *rhea's* through it would breach the lab rule.
Draw that line explicitly if it comes up.

## The setgid directory — 33 to 35, 57

The red herring, and it is a good one: `shared` is genuinely setgid, genuinely group-writable, and
genuinely correct. A student who "fixes" it has broken engineering's collaboration for every file
made after the change, silently. cass's page warns them; some will not read it.

If a student proposes removing the bit, do not stop them — exercise 57 makes them do it and put it
back. Ask afterwards: "Who would have noticed, and when?"

## Frequent wrong turns

**"Setuid root is the finding."** Exercise 30 lists nine setuid-root binaries the station needs. Ask
what `passwd` would do without it.

**Reading `4750` as "read-write-execute for the group".** They are reading the fourth digit as if it
were the first. Have them write out all four digits with names before they interpret any of them.

**`chmod 4755` then `chown`.** Silent failure, and it is the single most common real-world version of
this mistake. Exercise 18–20 exist to make them meet it in a place where it does not matter.

**Trying to make a setuid shell script work.** They will try `chmod 4755` on a wrapper, then a
wrapper around the wrapper. Ask what program is actually executed when the kernel reads `#!`.

**Reaching for `sudo` at every obstacle.** cadet has passwordless sudo, so nothing here can stop
them, and several stages are trivially bypassable with it. `sudo` is not forbidden, and using it
answers a different question than the one being asked. Ask which one.

**Naming dorn as an attacker.** He owns a file. Exercise 69 is the check, and it is the chapter's
integrity check: ask which line of evidence supports the word they used. This lesson is the arc's
first unambiguously *deliberate* artefact, which makes the discipline harder and more necessary, not
less. Do not confirm or deny anything about his motives; the lab does not know them and neither do
you.

## The lab rule

**Fix the hole, do not use it.** The helper will read anything of dorn's, and rhea's grant covers the
archive only. A student who reads through the helper into rhea's or the captain's files has broken
the rule; ask them what they would say to rhea in exercise 68, which asks what they read. That
question is the enforcement.

## After the flag

Do not let the lesson end at the submission. Exercises 64–69 are the actual finale: the narrowest
fix, giving back the access, and the two sentences about what the evidence does and does not support.
A student who submits the flag and stops has done a CTF, not an audit.
