# 10/08 — Special bits, and the helper he shouldn't have built

> "There is a setuid binary in that tree owned by an account whose holder left three weeks ago. I did
> not put it there and I did not approve it." — rhea

Seven lessons of this chapter have been about nine bits. There are three more, they sit above the
nine, and they are the reason a mode you thought had three digits sometimes has four.

`4000` is **setuid**: run this program as the file's owner, whoever started it. `2000` is **setgid**:
on a program, run as the file's group; on a directory, give every new entry the directory's group
instead of the creator's. `1000` is **sticky**: on a directory, you may delete only entries you own,
which is the single line that makes `/tmp` possible.

Setuid is not "extra permission". A process has a **real** uid — who started it — and an **effective**
uid, which is the one the kernel checks when the process opens a file. Executing a setuid file sets
the effective uid to the owner's and leaves the real one alone. That is all it does, and it is
enough, because the program then goes on doing exactly what it always does — for anything you ask it
to do. `sudo` is setuid root and safe because it reads a policy before it acts. A setuid copy of
`cat` reads a policy never. There is one of each in this lab, and the difference between them is the
whole lesson.

Two facts that stop a lot of bad ideas early. The kernel **ignores setuid on a `#!` script**, always,
so every clever attempt to make a setuid shell script work is either a no-op or a hole somewhere
else; the answer is a small compiled program or a line in `sudoers`. And setuid does **not survive
`chown`** — changing a file's owner clears both special bits, because otherwise you could hand
somebody a program that runs as you by giving it away.

You find them by their bits, not their names. `find . -perm -4000` is "at least these bits",
`-perm /6000` is "any of these bits", and `-perm 4750` is "exactly this mode and nothing else".
Confusing those three is the usual reason an audit comes back empty, and an audit that comes back
empty is worse than no audit, because somebody files it.

## The incident

rhea has asked for a permissions audit of deck 05 and the engineering tree. She has also, separately,
told you what she found while writing the request: a setuid binary in a place setuid binaries do not
belong, owned by `dorn`, dated 2187-05-18. She did not put it there. She wants to know what it does
before anybody changes it, and she wants to be told what you changed afterwards.

Five objects under this lab carry a special bit. **One of them is correct as it stands**, and cass has
already written to you about what happens when somebody tidies it away. At least one is not correct,
and it is not correct in a specific way that you should be able to state in one sentence by the end.

## The rule for this lab

**You may fix the hole. You may not use it to read anything you were not already entitled to read.**

That is a real constraint, not a puzzle constraint. The helper runs as somebody else; everything it
can reach, it reaches as him. rhea's page grants you the engineering archive — in writing, for one
day, with an end date, because you asked properly in lesson 07. It grants you nothing else, and the
debrief asks what you read, not what you ran.

When you are done: take the access back off yourself, and tell her what you changed.

## What you will be able to do

- [ ] Name the three special bits, in octal and in `ls -l`, and say what each does to a file and to a directory
- [ ] Distinguish real uid from effective uid, and read both out of a running process
- [ ] Explain what `s` in the owner triad means, and what a capital `S` means instead
- [ ] Find files by permission bits with `-perm -N`, `-perm /N` and `-perm N`, and say how the three differ
- [ ] Explain why setuid on a shell script does nothing
- [ ] Predict what `chown` does to a setuid bit, and say why it must
- [ ] Say what a setgid directory is for, and defend leaving one alone
- [ ] Explain the sticky bit from `/tmp`'s behaviour rather than from a definition
- [ ] Add yourself to a group and say why `id` does not change until you log in again
- [ ] Judge a setuid binary by what it can reach, not by how small it is
- [ ] Close this hole with the narrowest change that closes it

## Files

```
audit/README            the audit task
audit/stage1.txt        root's, mode 0400
audit/stage2.txt        yours, mode 0004, and you cannot read it
bin/readas              setuid root. A demonstration, and a bad idea
bin/summarise-hash      dorn's. Look at its mode before you run it
bin/whoami-really       prints real and effective ids
dropbox/                mode 1733: write, don't list, delete only your own
shared/                 engineering's working directory. Setgid, on purpose
engineering/archive/    rhea's. Group engineering, which you are not in yet
notes/setuid.txt        the three bits, and what setuid actually does
notes/groups.txt        usermod -aG, newgrp, and why login matters
notes/page.txt          rhea, 07:40 — the grant, in writing
notes/page-2.txt        cass, 09:05
scratch/                yours
```

## The flag

`KESTREL{...}`, one flag, registered as `10/08`:

```
kestrel flags submit 'KESTREL{...}'
```

`grep -r KESTREL .` will not find it. The file it sits in is `0600 dorn:dorn`, and no group
membership and no `find` will open that for you — only being dorn will, which is what the helper is
for and why it should never have existed.

## The Dig

Four receipts, `STAGE{...}`, one per skill: a permission search, an octal mode read correctly, a
group joined and re-logged-in, and the setuid semantics themselves. They do not register with
`kestrel flags`. Stage one is solvable by anybody who has read this page and `notes/setuid.txt`.

## Reset

`kestrel reset 10/08` re-seeds the tree and puts every mode back. It also takes you out of
`engineering` again, which is the state rhea's page starts from.
