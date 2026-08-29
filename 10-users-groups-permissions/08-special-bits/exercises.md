# 10/08 — Exercises: special bits, and the audit

```
cd /labs/10-users-groups-permissions/08-special-bits
ls -F
```

Chapters 1–10 tools. Wrecked the lab? `kestrel reset 10/08`. Read the rule in `readme.md` before you
`chmod` anything: you may fix the hole, you may not use it.

---

## The fourth digit

**1.** `cat notes/setuid.txt`, all of it, before you run anything else. Write down the three octal
values and what each does. You will be wrong about one of them in twenty minutes and this is the page
you will come back to.

**2.** `ls -l bin/`. Two files have a letter in the mode where you expect `x`. Which two, and which
letter?

**3.** `stat -c '%a %n' bin/*`. Now the modes are numbers. Which two have four digits, and what is
the leading digit in each?

**4.** `stat -c '%a' bin/whoami-really` prints `755`, not `0755`. Explain in one sentence why `stat`
prints three digits for one file and four for another.

**5.** Write `4755`, `2775`, `1777` and `4750` out as `ls -l` mode strings, on paper, before you check
any of them. Then check the ones that exist in this lab.

**6.** What is `0644` in this notation? What is the leading digit for a file with no special bits?

**7.** `chmod 4644 scratch/plain; ls -l scratch/plain` (create the file first). You get a capital `S`.
What does the capital mean, and what is missing?

**8.** Same question for `chmod 1666 scratch/dir` on a *directory* — make one, set it, look at the
last character. Capital `T`. What is missing there?

**9.** A capital `S` or `T` is almost always a mistake. Say what mistake, in terms of the two bits
involved.

## Real and effective

**10.** `./bin/whoami-really`. That is `id` under another name. What does it print for you?

**11.** `./bin/readas notes/setuid.txt | head -3`. That is `cat` under another name, and it worked.
Nothing surprising yet — you can read that file anyway.

**12.** `ls -l bin/readas`. Who owns it and what is its mode? What will its **effective** uid be while
it runs, and what will its **real** uid be?

**13.** `cat audit/stage1.txt`. It fails. `ls -l audit/stage1.txt` — say exactly which triad the
kernel used and why the answer was no.

**14.** Now read it with `bin/readas`. **Stage 1** is in there. Record it.

**15.** You just read a `0400 root:root` file without being root and without `sudo`. Which process was
root, and which uid did the kernel check when it opened the file?

**16.** `cp /bin/id scratch/mine; chmod 4755 scratch/mine; ls -l scratch/mine; ./scratch/mine`. The
mode says setuid and the output shows no difference. Why not?

**17.** From 16: setuid is only interesting when the owner is somebody other than you. Say what
`chmod 4755` on a file you own actually buys an attacker who can write to that file.

**18.** `sudo chown root scratch/mine; ls -l scratch/mine`. The `s` is gone. State the rule.

**19.** Explain why the kernel *has* to clear it. Describe the attack that would work if `chown` kept
setuid.

**20.** So: what is the correct order of operations for installing a setuid program — `chown` then
`chmod`, or `chmod` then `chown`? Say why the other order silently produces nothing.

**21.** `printf '#!/bin/bash\nid -u\n' > scratch/s.sh; chmod +x scratch/s.sh; sudo chown root
scratch/s.sh; sudo chmod 4755 scratch/s.sh; ls -l scratch/s.sh; ./scratch/s.sh`. The mode says
setuid root. The output says `1005`. What happened?

**22.** The kernel ignores setuid on `#!` scripts. Two ways to get the effect you wanted anyway; say
which one you would use on a real station and why.

## Finding them

**23.** `find . -perm -4000`. Read the `-` as "at least these bits". How many results, and does it
include the directories?

**24.** `find . -perm -4000 -type f -printf '%M %u:%g %p\n'`. Better. Write the two lines down.

**25.** `find . -perm /6000`. What does `/` mean here, and what did you get that `-4000` did not?

**26.** `find . -perm 4750` — no prefix at all. One result. Explain the difference between this and
`-perm -4750` in a sentence that mentions the other nine bits.

**27.** `find . -perm -2000` and `find . -perm -1000 -type d`. Which objects, and which bit is on each?

**28.** Every one of those commands printed `find: './dropbox': Permission denied`. Why can `find` not
descend into a directory you are allowed to write to? Name the missing bit.

**29.** You now have five special-bit objects. List them with mode, owner, group, and one line each on
what the bit is doing. That list is the audit rhea asked for.

**30.** `find / -perm -4000 -type f 2>/dev/null | head -20`. These are the station's real ones. Pick
three and say what each is for — `sudo`, `passwd` and `mount` are the classic three and they are all
here.

**31.** Why does `passwd` need to be setuid root when all it does is change your own password? Answer
with the mode of `/etc/shadow` (lesson 03).

**32.** Given 30 and 31: is "setuid root" the finding, or is it the normal state of a working system?
What actually makes one setuid binary a problem and another one fine?

## The one that is supposed to be there

**33.** `ls -ld shared; cat shared/README; cat notes/page-2.txt`. What is `shared` for and what would
break if you removed its setgid bit?

**34.** Being pedantic: `shared` is `2775 root:engineering`. Which of those numbers lets two different
people collaborate, and which one makes their files land in the same group?

**35.** You are not in `engineering` yet, so hold that thought. Meanwhile: is there anything about
`shared` you would report as a **finding**? Argue both ways in two sentences and then commit.

**36.** `ls -ld dropbox; cat dropbox/README`. `1733`. Break it down digit by digit: who may do what.

**37.** `ls dropbox` fails and `echo x > dropbox/mine.txt` works. Which two bits produce that pair of
outcomes, and what is that combination *for*?

**38.** `rm dropbox/from-cass.txt`. It fails: `Operation not permitted`. You have write on the
directory. Explain in one sentence why the write was not enough.

**39.** `rm dropbox/mine.txt` — your own file — works. State the sticky-bit rule from those two
results rather than from the notes.

**40.** `stat -c '%a' /tmp` and `ls -ld /tmp`. Same bit. Describe the attack the sticky bit on `/tmp`
prevents, given that everybody on a station can write there.

**41.** Would removing the sticky bit from `dropbox` be a finding, a fix, or a mistake? One sentence.

## The one that is not

**42.** `ls -l bin/summarise-hash`. Mode, owner, group, mtime. Write all four down; you will need the
mtime in the debrief.

**43.** `./bin/summarise-hash notes/setuid.txt`. `Permission denied`, and you have not even reached
the question of what it does. Which triad denied you, and what would you have to be to get past it?

**44.** Decode `4750` into a sentence with no numbers in it: who can execute this, and who does it run
as?

**45.** From the mode alone — before running it, before reading a single byte of it — say what this
program can read. Not what it does: what it *can reach*.

**46.** Read `audit/stage2.txt`. It fails, and it is **yours**. `ls -l` it, then explain the failure
using the rule from lesson 04. This one catches nearly everybody.

**47.** Get its contents without changing its mode and without using `bin/readas`. **Stage 2** is
inside. (`sudo -u rhea` is the obvious try. It fails too. Work out why, then pick a better account.)

**48.** Say why `sudo -u rhea` failed where your second choice succeeded. This is the same rule as 46
seen from the other end.

## Joining a group

**49.** `cat notes/page.txt`. rhea's grant has six parts. List them. Which part are you responsible
for at the end of the lesson?

**50.** `getent group engineering` and `id`. Are you in it? `ls engineering/archive` — consistent?

**51.** `sudo usermod -aG engineering cadet`, then `getent group engineering`, then `id`. Two of those
three now disagree. Which, and which one is telling the truth about your running shell?

**52.** `cat notes/groups.txt`. Explain the disagreement in one sentence containing the word "login".

**53.** What would `usermod -G engineering cadet` — no `-a` — have done to you? Be specific about
which group you would have lost and what you would have lost with it.

**54.** Get a shell that has the group: `newgrp engineering`, or a fresh session. `id` again. Now
`ls engineering/archive`. Read `stage3.txt`. **Stage 3.**

**55.** `id -gn` inside that `newgrp` shell. Your *primary* group changed too. What does that mean for
the group of files you create from here — check with `touch scratch/g; ls -l scratch/g`.

**56.** Exit that shell and `touch shared/mine2; ls -l shared/mine2`. Your primary group is `cadet`
again and the file's group is `engineering`. That is the setgid directory from exercise 33 doing its
job. Say the rule.

**57.** `sudo chmod g-s shared; touch shared/mine3; ls -l shared/mine3`. Different group. Put it back
with `sudo chmod g+s shared` and remove both test files. This is what cass was warning about.

**58.** `mkdir shared/sub; ls -ld shared/sub`. The new directory is setgid too. Why does it have to
be, for the scheme to work more than one level deep?

## The hole, and closing it

**59.** `ls -l engineering/archive/cycle-41.hash`. You are in `engineering` now and you still cannot
read it. Which triad, and why does membership not help?

**60.** There is exactly one identity on this station that can read that file, and exactly one program
that has it. Run the helper on that path. **The flag is in the output** — submit it with
`kestrel flags submit`.

**61.** Read the rest of what the helper printed. In two sentences: what was dorn doing, and what does
the file say about the two hashes? Do not go further than the file does.

**62.** Now the finding. `./bin/summarise-hash /home/dorn/.bashrc` — or any other path owned by dorn.
It reads that too. State the flaw in one sentence, in terms of scope rather than intent.

**63.** Would the flaw be fixed by making the helper `4750 dorn:engineering` — which it already is —
and trusting engineering? Answer in terms of who is in `engineering` and who will be next year.

**64.** Close it with the narrowest change that closes it. `sudo chmod u-s bin/summarise-hash`, then
`ls -l` and try the helper again. What error do you get, and is the file still there?

**65.** Argue for `chmod u-s` over `rm`. Then argue for `rm`. Which would you actually do, and what
would you tell rhea either way?

**66.** Take the grant back off yourself: `sudo gpasswd -d cadet engineering`, then `id` in a fresh
shell. Why does rhea's page ask for this, given that she trusts you?

**67.** What would the correct way to get dorn's access have been? Write the request he should have
sent, in the six headings from lesson 07. You know what he wanted; that is the only part you know.

## Debrief

**68.** Three sentences for rhea: what the binary does, what you changed, and what you read while you
had the access. She asked for the third one specifically.

**69.** State what the evidence supports about `bin/summarise-hash` and what it does not. You have a
mode, an owner, an mtime of 2187-05-18, and the contents of one file. You do not have a reason. Write
the line you would put in the audit report and then write the line you would not.

**70.** The chapter in one sentence: something about the difference between having a permission and
being exempt from the check — and where a setuid binary sits between the two.
