# 10/06 — chown, chgrp, and umask

> "One of them is owned by nobody. Not by me, not by you — by a number with no account behind it."
> — rhea

Lesson 04 read the nine permission bits. Lesson 05 changed them. Both assumed the two columns to
their left — the owner and the group — were already right. This lesson is about those two columns:
who sets them, who is allowed to, and where they come from when nobody sets them at all.

The rules are short and the second one is the one people get wrong.

**`chown` is root's.** Not the owner's. There is no combination of the nine bits that lets you give a
file away, and no `chmod` you can run first. That looks arbitrary until you ask what giving a file
away would mean on a machine with disk quotas, or on a machine where somebody has left a setuid
program lying around — both of which are reasons, and the second one is chapter 10 lesson 08.

**`chgrp` is usually yours.** You may change the group of a file you own, but only *to a group you
belong to*. So `chgrp` is not a way to acquire access; it is a way to share access you already have.
Try it against a group you are not in and the kernel says `Operation not permitted` in exactly the
same words it uses for `chown`, which is a small cruelty of the interface.

Both commands take `-R`, `--reference`, and `-c`, the same as `chmod`. Both accept numeric ids as
well as names, and a numeric id works even when no account has that number — which is how a file
comes to be owned by `4102` with nothing behind it. `ls -l` prints the number when it cannot find a
name. That is a fact about the account database, not about the file, and it is worth saying carefully
because it is the sort of thing people build a story on.

Then there is a difference from `chmod` worth committing to memory. `chmod` always follows symlinks
and has no option not to. `chown` and `chgrp` follow them too — but only when you name the link
directly and do not pass `-R`. With `-R`, they change the links themselves and leave the targets
alone, and `-h` makes that explicit for a single link. Three tools, three behaviours; the only way to
be sure is to check, which you will do in the exercises.

The second half of the lesson answers a question you have had since chapter 3 without asking it:
where does a new file's mode come from? Nothing chooses `644`. The program asks for a mode — `0666`
for a file, `0777` for a directory, by long convention — and the kernel removes whatever bits are set
in the process's **umask** before creating it. With the usual mask of `022` that leaves `644` and
`755`, and it explains something you have seen a hundred times: `touch` never produces an executable
file, not because the umask strips `x`, but because `0666` never had one.

The umask is a property of a *process*. Setting it in your shell affects that shell and everything it
starts afterwards, changes nothing that already exists, and is not recorded on any file. It is a mask
of bits to **remove**, so `umask 077` is the strict one and `umask 000` is the reckless one. Every
other permission number you have met this chapter reads the other way round, which is why this is the
one people reverse.

Finally, `intake/unclaimed.raw`. rhea asks what you can establish from the file itself. The honest
answer is short: a uid, a gid, a size, and a timestamp. Not a person. Getting to the end of this
lesson with a small, defensible answer is worth more than getting there with a large one.

## What you will be able to do

- [ ] Read the owner and group of any file by name and by number, with `ls -l` and `stat`
- [ ] Say why `chown` requires root, and give one concrete reason it must
- [ ] Use `chgrp` on a file you own, and state the limit on which groups you may set
- [ ] Use `chown user:group`, `chown :group` and `chown user:` and say what each does to the group
- [ ] Use `-R`, `--reference` and `-c` on both commands
- [ ] Predict what `chgrp` does to a symlink with and without `-R` and `-h`
- [ ] Explain where a new file's mode comes from, in terms of a requested mode and a mask
- [ ] Predict the mode of a file and a directory created under any given umask
- [ ] Say what changing the umask does and does not affect, including in a subshell
- [ ] Find every file on a path owned by a given account, or by no account at all

## Files

```
intake/cycle-41.raw     owned by root
intake/cycle-42.raw     owned by rhea, group crew
intake/unclaimed.raw    owned by 4102, and there is no 4102
handoff/               yours, group crew — but the files in it are not
handoff/week-24.txt     640, group cadet
handoff/week-25.txt     640, group cadet
handoff/rota.txt        640, group cadet
mixed/                 three different groups and one symlink pointing out of the tree
notes/ownership.txt     chown, chgrp, and who may run them
notes/umask.txt         where a new file's mode comes from
notes/page.txt          rhea, 07:40
scratch/               yours
```

You will need `sudo` for exactly one part of this lesson, and the exercises say where. Everywhere
else, being refused is the answer.
