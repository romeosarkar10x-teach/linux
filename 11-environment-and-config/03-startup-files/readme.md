# 11/03 — Startup files: what runs, and when

> "I want to know what is DIFFERENT about the terminal I opened this morning,
> because until I know that I am going to keep being surprised, and I would
> rather be wrong on purpose than right by accident."
> — rhea, 2187-06-22

Lesson 01 said a variable is a copy handed downward. Lesson 02 said `PATH` is an ordered list
that decides what a word means. Both left the same question open: **who set them, and when?**

The answer is a short list of shell scripts that run automatically when a shell starts. They are
ordinary files. There is no magic in them. The only thing that surprises people is *which* ones run,
because bash asks two questions and most of us only remember one.

## The two questions

Bash decides what to read by crossing two independent properties of the shell it is starting:

- **Is it a login shell?** Something passed `-l` or `--login`, or it is the first shell of a session.
- **Is it interactive?** It is reading commands from a terminal, rather than running a script.

Those cross into four cases, and three of them read different files:

| shell | reads |
|---|---|
| login | `/etc/profile`, then the **first** of `~/.bash_profile`, `~/.bash_login`, `~/.profile` |
| interactive, not login | `/etc/bash.bashrc`, then `~/.bashrc` |
| neither (a script, a pipeline, `bash -c`) | nothing — unless `BASH_ENV` is set |
| login shell, on exit | `~/.bash_logout` |

Read the login row again. It says **first**, and it means it. If `~/.bash_profile` exists,
`~/.profile` is never read — not merged, not consulted, not read. A file you have edited for years
can be silently retired by creating a file next to it.

And read what the login row does *not* say: it does not say `~/.bashrc`. **A login shell does not read
your `~/.bashrc`.** If your login shells have your aliases anyway — and on this station they do — it
is because one of the three login files contains a line that asks for it, by hand. That line is in
`homes/station/.profile` in this lab. Go and look at it. It is not machinery; it is somebody's
decision, written down.

## Why this is the lesson the incident needs

Chapter 11's incident cannot be solved without this. Neither can rhea's page in lesson 02 — the one
where cass got three lines and rhea got four, thirty seconds apart, on the same machine. There is a
home directory in this lab called `split/` that reproduces it exactly: a `.bash_profile` that does
not source `.bashrc`, so the account's aliases and functions exist in **every shell except the login
shell**. Nothing is broken. Nobody typed anything wrong. One file took priority over another.

## Experimenting without locking yourself out

`HOME` is just a variable, and bash looks up `~/.bashrc` by expanding it. So you can point bash at a
home directory you are willing to ruin:

```
HOME=/labs/.../homes/full bash -l -c true
```

That is the whole technique, and the reason this lesson has three fake home directories instead of
asking you to edit your own. A startup file is a script that runs on every login: if it can hang,
your logins hang; if it exits nonzero under `set -e`, your logins fail. **Test configuration
somewhere other than the account you need to stay logged in to.** This is the habit, not the trick.

Also worth knowing before you start: `--noprofile` skips the login files, `--norc` skips the bashrc
files, and `--rcfile FILE` substitutes one. Long options must come **before** short ones —
`bash --noprofile -l` works, `bash -l --noprofile` is an error whose message blames `--`.

## Objectives

- [ ] Name the two properties that decide which startup files run, and say why they are independent
- [ ] List the files a login shell reads, in order
- [ ] List the files an interactive non-login shell reads, in order
- [ ] State what a non-interactive shell reads, and the one exception (`BASH_ENV`)
- [ ] Demonstrate that only the **first** existing login file is read
- [ ] Explain why a login shell has your aliases even though it never reads `~/.bashrc`
- [ ] Prove which files ran, by marker line, rather than by reading documentation
- [ ] Use `HOME=... bash -l` to test a configuration without risking your own account
- [ ] Use `--noprofile`, `--norc` and `--rcfile`, and get the option order right
- [ ] Explain why an alias defined in a sourced file is not usable in a non-interactive shell, and why
      a function is
- [ ] Explain why `source ~/.bashrc` is not the same as logging in again
- [ ] Reproduce the two-terminals-one-command complaint from a configuration, not from a fault
- [ ] Say what `~/.bash_logout` is for and when it does not run

## Files

```
homes/full/      all four candidate files, each announcing itself
homes/station/   the station's arrangement: .profile, which sources .bashrc
homes/split/     a .bash_profile that does not source .bashrc -- the complaint
notes/startup.txt   which files, when
notes/order.txt     how to measure it instead of guessing
notes/page.txt      rhea, again, and this time it is hers
scratch/         yours
```

## Reset

```
kestrel reset 11/03
```

Wipes and re-seeds the lab. Exercise 44 asks you to break a home directory badly enough that logging
into it fails; the reset is how you get it back.
