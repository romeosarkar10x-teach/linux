# 10/07 — sudo and root

> "I have to be able to say, later, exactly what I granted and to whom, and 'access to engineering'
> is not a sentence I can defend." — rhea

Every refusal you have collected in this chapter had the same fix available: run it as somebody else.
This lesson is about the machinery for doing that, and about the much harder question of what to ask
for.

Start with what root is, because most people carry a wrong model of it. **root is uid 0.** That is
the definition; the name is a line in `/etc/passwd` and the kernel checks the number. And uid 0 is
not "granted every permission" — it is **exempt from the permission check**. The kernel does not
consult the owner/group/other triads for uid 0 at all. That is why a file with mode `000` is readable
by root, why root is in no group and needs to be in none, and why no `chmod` you can write locks root
out. You will prove this in three commands.

`sudo` is an ordinary program. It has the setuid bit and it is owned by root, so it begins running as
root regardless of who launched it — you will look at `ls -l /usr/bin/sudo` and see the `s` that does
it, and lesson 08 explains the bit. Having started as root, the first thing `sudo` does is consult a
**policy**, `/etc/sudoers` and the files in `/etc/sudoers.d`, to decide whether you should have been
allowed to ask. `sudo -l` prints the part of that policy that applies to you.

Two behaviours surprise everybody once. **`env_reset`** throws away most of your environment before
running the command, so a variable you exported is not there. **`secure_path`** replaces `PATH`
entirely with a fixed list from the policy, so a program you placed earlier in your own `PATH` is not
the one that runs. Both exist because the command is about to run as root and your environment is the
easiest thing in the world for someone to have tampered with. In this lesson you will hijack a command
in your own `PATH`, watch it work, and watch `sudo` ignore it.

Two things `sudo` cannot do, for the same reason. `sudo echo hi > /root/f` fails, because the
redirection is performed by *your* shell before `sudo` ever runs, and your shell is not root. `sudo cd
/root` fails, because `cd` is a shell builtin and there is no program for `sudo` to execute. The fixes
— `sudo tee`, `sudo sh -c '...'` — both mean handing a whole shell to root, which is worth a moment's
thought each time.

Then the part that outlasts the commands. `sudo` is preferred over `su` not because it is safer at the
moment of use, but because it is **attributable and revocable**: the policy names an account, the log
names an account, nobody shares a password, and removing one person's access does not disturb anyone
else's. The same logic runs one level up, into what you ask for. `policy/grants.txt` has four real
grants, two of which are much wider than they look — one of them grants an editor, and an editor is a
shell.

rhea has refused your first request, and she was right to. Her reply is in `requests/reply-1.txt` and
the shape of a request she can grant is in `requests/template.txt`. The exercise at the end of this
lesson is to write the second draft: what operation, on what path, as whom, for how long, and why the
ordinary route does not work. The last line is the one people leave out and the only one that shows
the request is necessary.

There is a scene with rhea for this lesson. It is worth doing after the exercises, not before.

## What you will be able to do

- [ ] State what root is in one sentence, and say why "exempt from the check" is not the same as
      "has every permission"
- [ ] Prove that root reads a file with mode `000`
- [ ] Explain what `sudo` is as a program, and point at the bit that makes it work
- [ ] Read `sudo -l` and say what it does and does not tell you
- [ ] Explain `env_reset` and `secure_path`, and demonstrate each
- [ ] Say why `sudo cmd > file` writes as you, and fix it two different ways
- [ ] Use `sudo -u` to run as a non-root account, and say when that is the right answer
- [ ] Distinguish `sudo -i` from `sudo -s` by what each does to the environment
- [ ] Read a `sudoers` line and say who may run what, as whom, on which host
- [ ] Identify a grant that is wider than it looks, and explain why
- [ ] Write an access request that names an operation, a path, a duration and a reason

## Files

```
policy/sudoers.example  an example policy to read. Not live.
policy/grants.txt       four grants as requested; two are not what they seem
policy/README           why nothing here is live, and why /etc/sudoers is out of bounds
requests/draft-1.txt    what you sent
requests/reply-1.txt    what rhea sent back
requests/template.txt   the shape of a request that can be granted
jobs/collect-counts.sh  a script where exactly one line needs root
jobs/tidy.sh            somebody's tidy script. Read it before running it.
notes/sudo.txt          what sudo is, and the two things it cannot do
notes/root.txt          what uid 0 is, and su versus sudo
notes/page.txt          rhea, 08:15
scratch/                yours
```

**Out of bounds for this lesson:** editing `/etc/sudoers` or anything in `/etc/sudoers.d`. A broken
policy file locks out everyone including the person who broke it, and a station has no second way in.
Read them; do not write them.
