# 10/01 — Users and ids

> Sixty-one people aboard and rather more accounts than that. Some of the extras are automation.
> At least one of them is neither.

Nine chapters of this course have been about what is on the disk and what is running. This one is
about **who is allowed**, and every answer starts in the same place: to the kernel, you are a number.

That number is your **uid**. Every access check the kernel makes — can this process open this file,
can it signal that process, can it read that directory — compares numbers. Names are a convenience
for people. They are looked up in a file, the lookup can fail, and the number keeps working when it
does. This is not a detail you will forget about later; in lesson 06 you will see `ls -l` print a
bare number where a name should be, and the reason is exactly this.

The file is `/etc/passwd`, and it is world-readable — deliberately, because every program that wants
to print a name instead of a number has to read it. It has seven colon-separated fields. Field 2 is
`x` on every modern system, meaning "the password hash is not here, it is in `/etc/shadow`", which is
`root:shadow` and mode `640`. That split is the whole reason `/etc/passwd` can be public.

Field 4 is the **primary group**, by number, and it is not the same number as the uid. On this
container `cadet` is uid 1005 and gid 1008. Assuming they match is a mistake you make once.

`root` is not privileged because of its name. It is privileged because its uid is 0. An account named
`root` with uid 1000 is an ordinary user, and an account named anything at all with uid 0 is root.
Names are labels on numbers; the number is the account.

The tools are small. `whoami` prints one word. `id` prints everything and is the one to reach for.
`id NAME` answers the same question about somebody else, and needs no privilege — identity on this
system is public information, and only the secrets are not. `getent passwd NAME` does the lookup
properly and tells you with its exit status whether the account exists. Do not use `grep` on
`/etc/passwd` for this: `grep 1001` matches a uid of 1001, a gid of 1001, and a home directory with
1001 in the path, and it will not tell you which it found.

Two things look like `whoami` and are not. `$USER` is an environment variable set by the login
program and copied to every child — nothing keeps it true, and in this container it is **not set at
all**, which you will prove in exercise 12. `logname` reads the system's login record, and in this
container it fails with `logname: no login name`, because a `docker exec` session never created one.
Both are wrong in the same way: they answer "how did this session start", not "who is this process".

The lab gives you a station account export with 34 accounts in it, and a crew list with the people
actually aboard. rhea's question is the one this lesson exists for: **which of these accounts belongs
to a person?** Not which ones look official. The answer needs three separate filters, and every one
of them has an exception in the data.

## What you will be able to do

- [ ] State that identity is a number, and name where the number-to-name mapping lives
- [ ] Read all seven fields of a `/etc/passwd` line and say what each one is for
- [ ] Explain why field 2 is `x`, and what `/etc/shadow`'s mode buys you
- [ ] Distinguish uid from primary gid, and give an account where they differ
- [ ] Explain why uid 0 is root and the name is irrelevant
- [ ] Use `id`, `id -u`, `id -un`, `id -G`, `id -nG`, and `id NAME` deliberately
- [ ] Use `getent passwd` by name and by number, and read its exit status
- [ ] Say why `getent` beats `grep` on `/etc/passwd`, with a case where grep is wrong
- [ ] Separate system accounts from human ones using `UID_MIN`, and name the exceptions
- [ ] Say what `/usr/sbin/nologin` in field 7 does and does not prevent
- [ ] Explain why `$USER` and `logname` are not answers to "who am I"

## Files

```
roster/passwd.export  34 accounts, exported from the station database 2187-06-10
roster/crew-list.txt  the people actually aboard. Not an account list
roster/README         what these copies are
notes/accounts.txt    the seven fields, the tools, and the getent-versus-grep rule
notes/page.txt        rhea, and the question she gets asked twice a year
scratch/              yours
```

Nothing in this lesson changes an account. You are reading. Lesson 03 creates and removes them, and
by then you will know what you are removing.
