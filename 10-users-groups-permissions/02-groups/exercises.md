# 10/02 — Exercises: groups

```
cd /labs/10-users-groups-permissions/02-groups
ls -l
```

Chapters 1–10 tools. Wrecked the lab? `kestrel reset 10/02`.

**One standing warning.** This lesson uses `sudo` on the account database, which is new. Every
command that changes a membership is aimed either at `probe` or at adding — never removing — one of
your own. `usermod -G` without `-a` on your own account removes you from `sudo` and ends the course.
Exercise 40 exists so you can watch that happen to somebody else.

---

## Warmup — the two lists

**1.** `groups`. Then `id -nG`. Same list? Which one puts your primary group first, and does the
other guarantee anything about order?

**2.** `id -gn` and `id -g`. Your primary group, twice. Is its name the same as your account name?

**3.** `getent group crew`. Four fields. Label each one. How many members are listed?

**4.** `getent group cadet`. Your primary group. Look at field 4. It is **empty**. You are in this
group. Explain the contradiction.

**5.** From exercise 4: name the file, and the field number in it, where your primary membership is
actually recorded. Prove it with one command.

**6.** So: to answer "is cadet in group X" completely, how many files must you consult? Write the
two questions you have to ask.

**7.** `getent group engineering`. Who is in it? Are you?

**8.** `id -nG rhea` and `id -nG cadet`. Write both lists. Which group does she have that you do not?

**9.** `cut -d: -f1,3 /etc/group | sort -t: -k2 -n | tail -8`. The high gids. Which of these are
per-account groups created by `useradd`, and how can you tell?

## Denied

**10.** `ls -l`. Two directories in this lab have a group that is not `crew`. Which, and what are
their modes?

**11.** `ls engineering`. Read the error and the exit status. Which of the three permission triads
did the kernel apply to you, and why that one?

**12.** `cat engineering/README`. Same result. You now know the directory is unreadable — does that
by itself tell you anything about the modes of the files inside it?

**13.** `ls -ld engineering` and read the mode aloud in words: what may the owner do, what may the
group do, what may everybody else do?

**14.** `stat -c '%U %G %a' engineering`. Owner, group, octal mode. Which of the two names is the one
that could let you in?

**15.** `cat shared/handover.txt`. That works. `stat -c '%U %G %a' shared/handover.txt` and say which
triad you got your access from this time.

**16.** Append your name to `shared/rota.txt` with `>>`. It works. Which permission bit did you
just use, and on which of the two — the file or the directory?

## Joining

**17.** Read `engineering/access.txt`. You cannot; it is in the directory you cannot read. Read
`notes/page.txt` instead and say what rhea has asked you to do before joining.

**18.** You are going to join anyway, because this is a training lab and the data is synthetic.
Write down, before you run anything, what you predict `ls engineering` will do afterwards.

**19.** `sudo usermod -aG engineering cadet`. No output. Did it work? Do not guess — find a command
that answers it.

**20.** `getent group engineering`. Your name is in field 4. The account database has been changed.

**21.** `id cadet`. `engineering` is there.

**22.** `id`. It is **not** there.

**23.** `ls engineering`. Still denied.

**24.** Write down what exercises 21, 22 and 23 taken together prove. Two sentences: one about what
`id cadet` asks, one about what `id` asks.

**25.** This is the centre of the lesson. In your own words: why does a change to `/etc/group` not
affect a shell that is already running? Your answer must use the word "copy".

**26.** `sg engineering -c 'id -nG'`. A different list. Where did this process get its credentials
from, and when?

**27.** `sg engineering -c 'cat engineering/access.txt'`. Now you can read it. Read it, and then say
whether you would have joined.

**28.** `newgrp engineering`, then `id -gn`, then `id -nG`. Two things changed, not one. What
happened to your *primary* group, and what does that mean for a file you create right now?

**29.** Still inside the `newgrp` shell: `touch scratch/from-newgrp` and `ls -l scratch/`. What group
did the new file get? Now `exit` and `touch scratch/from-normal`. Compare.

**30.** From exercise 29, state the rule: which kind of membership decides the group of a new file?

**31.** `exit` out of any `newgrp` shell. Confirm with `id -gn` that you are back.

## newgrp's edge

**32.** `sudo gpasswd -d cadet engineering`. You have left the group. Confirm with `getent group`.

**33.** Now `sg engineering -c 'id'`. Read what happens *exactly* — it is not a permission error.
What is it asking you for?

**34.** Nobody has set a password on `engineering`. So what does `sg` do, and state the rule: `sg`
and `newgrp` are for groups you *are* in, not a way to get into one.

**35.** `ls -l /etc/gshadow` and try to read it. Where would a group password live, and who can see
it? Say why group passwords are a bad idea in one sentence — think about how many people would need
to know it.

**36.** Rejoin: `sudo usermod -aG engineering cadet`. You will need it in exercise 43 and in lesson
06. Verify with `id cadet`, and note again that `id` alone still disagrees.

## The foot-gun

**37.** `id -nG probe`. Four groups. Write them down exactly.

**38.** Read the two forms in `notes/groups.txt`: `usermod -aG` and `usermod -G`. State the
difference in one sentence, using the word "set".

**39.** Predict: what will `sudo usermod -G hydroponics probe` leave `probe` in?

**40.** Run it. `id -nG probe`. Compare with exercise 37. How many memberships were destroyed, and
what output did the command produce to warn you?

**41.** Put them back: `sudo usermod -aG crew,ops probe`. Verify. Note that `probe`'s *primary* group
survived exercise 40 untouched — why?

**42.** Now the question that matters: you are in `sudo`. Write down what `sudo usermod -G
engineering cadet` would do to you, and what you would have to do to recover. Do **not** run it.

**43.** Write the safe habit as a rule you would put in a runbook. It should mention `-a`, and it
should mention `gpasswd -a` as the alternative that cannot make this mistake.

## The export

**44.** `wc -l roster/group.export`. How many groups did the station have on 2187-06-10?

**45.** `awk -F: '$4 != ""' roster/group.export | wc -l`. How many have members listed? What are the
others for?

**46.** `awk -F: '$3 >= 1000' roster/group.export | cut -d: -f1`. The groups somebody created. Which
of them are departments and which is not?

**47.** `getent group crew` on the live system versus `crew` in the export. Different member lists
and different gids. Which of those differences is expected and which one would you check?

**48.** The export has a group called `archive-ro` with two members. It is not a department. Say
what shape of thing it is — one sentence — and why a group like that is *good* practice compared
with granting the same access to `crew`.

**49.** `awk -F: '{n=split($4,a,","); print n, $1}' roster/group.export | sort -rn | head -3`. The
biggest groups. Is the largest one a useful permission boundary? Explain.

**50.** rhea's note says the membership list is eleven years old. From the export alone, name one
thing you *cannot* determine about any of these groups, and say which record would have it.

## Reporting

**51.** Write two sentences for rhea: that you joined `engineering`, and why. Do not justify it with
"I have sudo".

**52.** Somebody on shift says "I added you to the group but it still does not work". Write the reply
that fixes them permanently rather than just this once. Three sentences, no jargon they do not have.

## Experiment

**53.** In `scratch/`, create a file, then use `chgrp` (lesson 06 does it properly; try it now) to
change its group to `engineering`. Does it work? What about to `ops`? Explain the difference.

**54.** `sg crew -c 'touch scratch/sg-file'` then `ls -l scratch/sg-file`. Which group? Does this
give you a way to control the group of a file you create without `chgrp`?

**55.** Start a background `sleep 300 &` from a `newgrp engineering` shell, exit that shell, and then
check the sleeping process's groups with `id`… which you cannot, because `id` reports on itself.
Find where a running process's group list is recorded instead. (Chapter 9 told you where a process
keeps everything: look for `Groups:`.)

**56.** From exercise 55: if you remove yourself from a group, what happens to processes you already
started as a member of it? Test it, and state what that means for "revoking access".

## Stretch

**57.** Write `ingroup()`: takes a group name, returns 0 if the *current process* is in it and 1 if
not. Then write `account_ingroup()`, which asks the same question about the *account*. They must be
able to disagree, and your two implementations should make it obvious why.

**58.** Given only `/etc/passwd` and `/etc/group`, write the one-liner that lists every member of a
group including the people whose primary group it is. Test it on `crew` and on `cadet`.

**59.** Groups are supplementary *and* limited. Find the limit: `getconf NGROUPS_MAX`. What is it
here, and what design does that number reward — many small groups or a few large ones?

**60.** Argue against exercise 48: name the cost of having thirty small groups instead of three big
ones, and say who pays it.
