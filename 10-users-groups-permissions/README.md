# Chapter 10 — Users, Groups & Permissions

> "I have to be able to say, later, exactly what I granted and to whom, and 'access to engineering'
> is not a sentence I can defend." — rhea

## Incident briefing

Nine chapters have treated the station as though everything on it were yours. It is not, and it never
was: every file you have opened since Chapter 2 was opened by a process with an identity, checked
against three bits that were chosen by somebody. This chapter is that check, from both ends — how the
kernel decides, and how a person decides what the kernel should decide.

It goes in order. Who you are: uid, gid, and the fact that a name is a lookup and a number is the
truth. Then groups, primary and supplementary, and where a new file's group actually comes from. Then
the account files themselves — `/etc/passwd`, `/etc/group`, `/etc/shadow` — and the tools that edit
them, which exist because editing those files by hand is how a station loses its ability to log
anybody in. Then the nine bits: `rwx` for owner, group and other, **first matching triad and no
fallthrough**, which is the single rule that explains almost every confusing permission failure for
the next five years — and `r` versus `x` on a *directory*, which are different permissions over
different operations. Then `chmod`, symbolic and octal, and `chown`, `chgrp` and `umask`: where a
mode comes from before you ever set one.

Then `sudo`, which is not a magic word. It is a setuid-root program: root from its first instruction,
and safe only because it reads a policy before it acts. The lesson is spent on what that policy can
and cannot say, on the two settings that make it safe (`env_reset`, `secure_path`), on the three
things `sudo` cannot do that everybody expects it to, and on the fact that granting a program which
can run other programs is granting a shell. It ends by having you write an access request, because a
grant nobody can describe is a grant nobody can revoke.

The chapter's incident is folded into the last lesson, where the three bits above the nine live.
rhea has asked for a permissions audit of the engineering tree. She has also found, and does not
understand, a setuid binary owned by an account whose holder left three weeks ago. It is small. It
reads and hashes, nothing else. It is still a hole, and the reason why is the whole chapter in one
sentence: a setuid program does not do a restricted thing with somebody's privileges — it does its
ordinary thing with them, for anything you ask.

One of the five special-bit objects in that lab is correct as it stands. Breaking it breaks other
people's work, silently, for months. Deciding which is the audit.

## Learning objectives

- [ ] Read your own identity: `id`, `whoami`, `groups`, and say which of those is a number and which is a lookup
- [ ] Explain uid/gid versus names, and why a script tests `id -u` and not `whoami`
- [ ] Read `/etc/passwd`, `/etc/group` and `/etc/shadow` field by field, and say why the third is 640
- [ ] Distinguish primary from supplementary groups, and say where a new file's group comes from
- [ ] Create, modify and remove accounts and groups with the tools that lock the files
- [ ] Read any `ls -l` mode into `rwx` triads and octal, in both directions, without arithmetic slips
- [ ] State the first-match rule, and construct a mode that locks the owner out of their own file
- [ ] Explain `r` and `x` on a directory as separate permissions over separate operations
- [ ] Apply the path rule: every component needs `x`, checked one at a time, before the file's own mode
- [ ] Use `chmod` symbolically and numerically, including `X`, `--reference`, `-R` and `-c`
- [ ] Predict what `chmod` does through a symlink, and what `chgrp -R` does to one
- [ ] Use `chown` and `chgrp`, and say why `chown` needs root and `chgrp` usually does not
- [ ] Compute a new file's mode from the umask, and say what the umask cannot do
- [ ] Describe root as *exempt from the check*, not as *permitted by it*, and say why the difference is visible
- [ ] Explain `sudo` as a setuid-root binary that consults a policy, with the mode to prove it
- [ ] Demonstrate `env_reset` and `secure_path`, including a PATH hijack that `sudo` defeats
- [ ] Say why `sudo cmd > /etc/file` fails, and fix it two ways with an argument for one of them
- [ ] Read a `sudoers` line — user, host, runas, command — and rank four grants by what they actually permit
- [ ] Explain why granting `find`, `vi` or `less` is granting a root shell
- [ ] Write an access request that names what, where, as whom, for how long, and why not the ordinary route
- [ ] Name setuid, setgid and sticky in octal and in `ls -l`, and say what each does to a file and a directory
- [ ] Distinguish real from effective uid, and say which one the kernel checks
- [ ] Find files by permission bits, distinguishing `-perm -N`, `-perm /N` and `-perm N`
- [ ] Explain why setuid on a shell script does nothing and why `chown` clears the bit
- [ ] Judge a setuid binary by what it can reach, and close a hole with the narrowest change that closes it

## Prerequisites

- Chapter 2 — paths and `ls -l`, every field of which this chapter finally explains
- Chapter 3 — file types, links, and the fact that a symlink has a mode nobody consults
- Chapter 5 — quoting, for `find -perm` expressions and `sudo sh -c` arguments
- Chapter 6 — `find` and `grep`; the audit in lesson 08 is a `find` problem before it is anything else
- Chapter 7 — `cut`, `awk` and `sort`, for reading `/etc/passwd` as the colon-separated data it is
- Chapter 8 — redirection, without which lesson 07's central failure makes no sense
- Chapter 9 — processes have owners; a setuid binary is a statement about a process, not a file

## Lessons

- [`01-users-and-ids`](01-users-and-ids/readme.md) — uid, gid, `id`, and the difference between a name and a number
- [`02-groups`](02-groups/readme.md) — primary, supplementary, and where a file's group comes from
- [`03-managing-accounts`](03-managing-accounts/readme.md) — `/etc/passwd`, `/etc/group`, `/etc/shadow`, and the tools that lock them
- [`04-rwx-and-octal`](04-rwx-and-octal/readme.md) — the nine bits, first match wins, and directories
- [`05-chmod`](05-chmod/readme.md) — symbolic and octal, `X`, `--reference`, and what `-R` really does
- [`06-chown-chgrp-umask`](06-chown-chgrp-umask/readme.md) — ownership, and where a mode comes from before you set one
- [`07-sudo-and-root`](07-sudo-and-root/readme.md) — root as exemption, `sudo` as a program, and how to ask for access
- [`08-special-bits`](08-special-bits/readme.md) — **the incident.** setuid, setgid, sticky, and the helper he shouldn't have built

## Roleplay

`07-sudo-and-root/scene.md` — **rhea, the least-privilege scene.** She will not grant "access to
engineering", because that is not a request and she cannot write it down. The student leaves having
asked properly, or having worked out that they did not need the access at all. It is the chapter's
centrepiece, not a garnish, and it is what earns the written grant that lesson 08 opens with.

## Flags in this chapter

**1** — in `08-special-bits`, plus a four-stage chain of `STAGE{...}` receipts that do not register
with `kestrel flags`.

The flag is not greppable. It sits in a file that is `0600` and owned by an account that is not
yours, so `grep -r KESTREL` finds nothing and no amount of `find` will open it. Exactly one identity
on the station can read that file, and exactly one program has it — which is the finding, the flag,
and the lesson in the same step.

The chain's four stages are a permission search, an octal mode read correctly, a group joined and
actually logged into, and setuid semantics. Stage 2 is the cliff: a file you own and cannot read.
