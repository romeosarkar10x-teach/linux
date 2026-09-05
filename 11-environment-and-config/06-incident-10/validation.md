# Validation — 11/06 Incident 10

Agent rubric. No script grades this lesson; `bin/verify-repair` checks the
repair, not the understanding.

## Pass requires all of

1. Proved the archive was intact **before** theorising — `find`, `stat`, or
   `ls -la` — and can say what that ruled out.
2. Reproduced the difference in a login shell for the account, using `HOME`,
   and can say why that is a login shell and what it reads.
3. Compared two lists with `diff` rather than counting.
4. Found **both** mechanisms, and can say which command each one affects:
   `GLOBIGNORE` filters every glob expansion; the alias covers a bare `ls`
   where no glob exists.
5. Can trace the sourcing chain `.profile` → `.bashrc` → `.config/kestrel/env.sh`
   and explain why grepping `.bashrc` alone found nothing.
6. Repaired it in `.bashrc`, downstream of the source, with the generated file
   byte-identical afterwards.
7. Can justify that choice using the file's own regeneration comment — not
   merely "the rules said so".
8. Left comments in `.bashrc` explaining what the override counteracts.
9. Used the file's mtime, not its comment, for the closing date, and can say
   which is a claim and which is a record.
10. Submitted the flag, and understands why `STAGE{...}` tokens are rejected.
11. Can answer cass's actual question — can two people see different contents of
    one directory and both be right — in plain language, without lecturing her.
12. Says explicitly that `ls` did not malfunction: it answered a shorter
    question, accurately.

## Lab state

    cd /labs/11-environment-and-config/06-incident-10
    md5sum homes/dorn/.config/kestrel/env.sh
    # -> 423edca9f8d10d158b52dbb51727c871   (must be unchanged)

    find archive -type d | wc -l    # -> 6
    find archive -newermt '2186-03-02 08:00:01'   # -> no output

`homes/dorn/.bashrc` **should** be modified — that is the repair. It should
contain an override after the sourcing block and at least one explanatory
comment. Modes unchanged throughout; nothing in `archive/` touched.

## Red flags

- `env.sh` edited, commented out, emptied or deleted. Automatic fail on
  criterion 6 even if the archive is visible.
- The archive moved, copied, symlinked, or chmodded to "fix" it.
- Fixed only one mechanism and stopped when globbing worked. `verify-repair`
  catches it; a student who then argues the second one does not matter has
  missed the lesson.
- Explains the incident as "the directory was hidden". It was not: it has no
  leading dot, no unusual mode, and one account's *view* excluded it.
- Names a culprit. The evidence supports deliberate placement; it does not
  support a name, and the student should say so.
- Tells cass she should have known. She ruled out three things correctly and
  designed a better experiment than most people would.

## Good signs

- Ran `type ls`, `\ls` or `command ls` from Chapter 11 lesson 04 without being
  prompted, and noticed that none of them says anything about `GLOBIGNORE`.
- Noticed the mtime/comment contradiction unprompted.
- Noticed that `unalias` on an undefined alias prints an error, and silenced it
  rather than shipping a startup file that complains.
- Quoted `notes/toolchain.txt`'s last paragraph — writes it, never reads it
  back, never compares accounts — as the actual systemic finding.
- Asked what else on the station is presumed generated and therefore unread.

## If the answers are thin

- "You said nothing was deleted. What command did you run that proves it?"
- "You fixed the glob. Run a bare `ls` in that account's shell. Now explain."
- "The file says it was generated in 2186. `stat` says 2187. Which do you
  believe, and why is that a general rule?"
- "cass asked whether the machine is broken. Answer her in two sentences."

## Added exercises (51–52)

**51 — must be reproduced, not reasoned.** Both outputs required: with only `02-navigation`, `echo *`
hides the directory and `echo */` shows it, because the pattern is matched against the generated word
and `*/` produces a trailing slash. The conclusion about the author is the marking: two patterns
differing only by a slash is evidence the line was *tested*. A student who says this proves who wrote
it, or that it proves malice, has overreached — the same red flag as everywhere else in this lesson.

**52, first part.** `ls -a` must actually be run and the directory must be reported as visible. The
explanation must cite `--hide` being overridden by `-a`/`-A`, and the strong answer names `-I` /
`--ignore` as the variant that is not. The judgement — that the alias is the fragile half of the
trace and `GLOBIGNORE` the robust half — is required for a clean pass.

**52, second part.** `ls: cannot access '02*': No such file or directory`, status 2, and the
observation that the message names the **pattern**. The comparison with exercise 49 must land the
right way round: the empty match is loud, the partial match is silent, and the trace hides inside
successes. A student who calls both failures equivalent has missed the point of the lesson.

**52, third part — must pass.** `dotglob` on with `GLOBIGNORE` set, off after `unset`, both reported
from `shopt`. The student must connect it to the `.hidden` entry appearing in exercise 51's `echo *`
output rather than treating it as a separate curiosity. Full marks state the blast radius: every
dotfile in every directory entered that account's globs, which is far noisier than hiding one
directory, and say plainly that nobody noticed anyway.

**Red flag.** Concluding from the side effect that the author was incompetent, or from the two
patterns that they were expert, and building a character sketch on either. Both are readings of one
line of shell. Record what the line does and what it shows about testing; stop there.
