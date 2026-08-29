# 10/02 — Groups

> Access on this station is not granted to people, it is granted to groups, and the membership list
> is eleven years old.

A group is a number with a list of names attached. It exists so that permission can be given to a
*set* of people without writing each of them down on every file — and so that when somebody joins the
set, everything they should be able to reach becomes reachable at once, with no file touched.

`/etc/group` has four fields: name, an `x` where a group password would be, the gid, and a
comma-separated member list. It is world-readable for the same reason `/etc/passwd` is: `ls -l` has
to turn a gid into a name.

There are two kinds of membership and confusing them is the single most common mistake in this
chapter.

Your **primary group** comes from field 4 of your `/etc/passwd` line. You have exactly one. It is the
group that gets stamped on every file you create. Notice where it is written: in `/etc/passwd`, not
in `/etc/group`. Your name does **not** appear in the member list of your own primary group — run
`getent group cadet` and look at the empty fourth field. Nothing is broken. There are two places
membership is recorded and you have to read both.

Your **supplementary groups** come from the member lists in `/etc/group`. You can have as many as you
like. They grant access and do nothing else — being in `crew` does not make your new files belong to
`crew`.

Joining is one command: `sudo usermod -aG engineering cadet`. And then comes the thing that catches
everybody exactly once.

**It will not work in the shell you are already in.** Your credentials — uid, primary gid, and the
full supplementary list — were handed to your shell by the kernel when the session started, and every
child of that shell gets a copy. Editing `/etc/group` does not reach into a running process. `id
cadet` will show the new group, because that is a fresh lookup of the *account*; `id` with no
argument will not, because that is your *process*. The two commands look almost identical and are
asking completely different questions. Exercise 25 is where you will see them disagree, and it is
worth stopping there until it is not surprising any more.

The fixes are: log out and back in, or start a session that gets fresh credentials — `newgrp GROUP`
for a new shell, `sg GROUP -c 'command'` for one command. Both have a sharp edge: they only work for
a group you are *already a member of*. Try either on a group you have not joined and you are asked
for the group's password, which nobody has set, and you are refused. `sg` is not a way in.

The `-a` in `usermod -aG` is not decoration. `usermod -G` without it **sets** the list, which means it
removes you from every group you did not name. Your account is in `sudo`. Do not test this on
yourself; the lab gives you an account called `probe` to break instead.

## What you will be able to do

- [ ] Read all four fields of an `/etc/group` line
- [ ] State where primary membership is recorded and where supplementary membership is recorded
- [ ] Explain why your own name is missing from your primary group's member list
- [ ] Say which kind of membership decides the group of a file you create
- [ ] Use `groups`, `id -gn`, `id -nG` and `id -nG NAME`, and say what each asks
- [ ] Add and remove a supplementary group with `usermod -aG` and `gpasswd -d`
- [ ] Explain why a new group does not apply to the shell you ran the command in
- [ ] Distinguish `id` from `id NAME` as "this process" versus "this account"
- [ ] Use `newgrp` and `sg`, and state the one thing neither of them can do
- [ ] Say exactly what `usermod -G` without `-a` does, and why it is dangerous here
- [ ] Explain what a group password is and why the answer is "do not"

## Files

```
shared/            crew-owned, group-writable. You are in this group
engineering/       rhea:engineering, 0750. You are not — yet
roster/group.export  the station's group database, 2187-06-10
notes/groups.txt     both kinds of membership, and the re-login rule
notes/page.txt       rhea, on asking before joining
scratch/             yours
```

There is also an account called `probe` on this container. It has no password, no login shell and
nothing of its own. It exists so that exercise 40 has something safe to destroy.
