# 11/03 — Solutions

Answer key. Every value measured in the container.

**No flag in this lesson.** The chapter's flag is in `06-incident-10`. This lesson is the one the
incident is unsolvable without.

---

## Reading the notes

**1.** Is it a login shell? Is it interactive?

**2.** `-l` (or `--login`) makes it a login shell. `-i` makes it interactive. They are independent:
you can have either, both, or neither.

**3.** One. The first of the three that exists.

**4.** No.

**5.** Put a marker line (`echo "read: ~/.bashrc"`) in each candidate file and start each kind of
shell. What appears is what ran. No documentation required, and the answer is about *this* machine.

**6.** Because a startup file runs on every login, so a broken one breaks your logins — and `HOME` is
just a variable, so you can point bash at a directory you are willing to ruin.

## The four cases, measured

**7.** Five: `.bash_profile`, `.bash_login`, `.profile`, `.bashrc`, `.bash_logout`.

**8.** Each echoes one line naming itself. None of them sources any other. That is deliberate: this
home directory answers "which files does bash read", with nothing else in the way.

**9.** One: `read: ~/.bash_profile`.

**10.** It should be. If it was not, the belief that was wrong is almost always "login shells read
`.bashrc` too".

**11.** One: `read: ~/.bashrc`. Note that `.bash_profile` does *not* appear — this shell is not a
login shell.

**12.** Nothing. A shell that is neither login nor interactive reads no startup files at all. This is
why a script does not have your aliases, and why it is the correct default: a script should behave
the same for everyone who runs it.

**13.** `read: ~/.bash_profile` on the way in, `read: ~/.bash_logout` on the way out. `.bash_logout`
runs when a *login* shell exits.

**14.** Only `.bash_profile`. `bash -li -c true` runs the command and exits without going through the
interactive-login exit path, so `.bash_logout` does not run. Measured, not deduced — and worth
remembering, because it means "it works when I log out by hand" and "it works from a script" are
different claims about `.bash_logout`.

**15.**

| shell | reads |
|---|---|
| `bash -l` | `/etc/profile` (+ `/etc/profile.d/*.sh`, + `/etc/bash.bashrc` if interactive), then the first of `~/.bash_profile`, `~/.bash_login`, `~/.profile` |
| `bash -i` | `/etc/bash.bashrc`, then `~/.bashrc` |
| `bash -c` | nothing, except `$BASH_ENV` |
| login shell exiting | `~/.bash_logout` |

## First match wins, again

**16.** Because the seeded files are the reference. Once you have moved or edited one you no longer
have a known-good copy to compare against, and `kestrel reset` is a bigger hammer than `cp -a`.

**17.** `read: ~/.bash_login`.

**18.** `read: ~/.profile`.

**19.** The shell starts normally and exits 0. Having none of the three login files is not an error —
bash reads the first that exists, and "none exists" is a perfectly good answer. You simply get no
configuration.

**20.** Bash checks the three in a fixed order and reads the first one that exists, ignoring the
others entirely. You saw the same three words in lesson 02, about `PATH`: an ordered list, searched
left to right, first match wins. It is the same idea applied to files instead of directories.

**21.** Nothing happens to it — that is the problem. It stays on disk, unedited, and is never read
again. Their `PATH` edits, their `source ~/.bashrc` line, their exports: all still there, all inert.

**22.** Because the file they lost is unchanged, so every check they make on it passes; because the
new file works, so nothing errors; and because the symptom is *absence* — a variable that is empty, an
alias that is missing — which looks like a hundred other things. Nothing points at the file that took
priority.

## The station's arrangement

**23.** `~/.profile`. It is read because neither `~/.bash_profile` nor `~/.bash_login` exists in that
home directory, so it is the first match.

**24.**

```
if [ -n "$BASH_VERSION" ] && [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
fi
```

A decision. Bash provides no such link; somebody wrote that line because they wanted their aliases in
login shells. The `if` exists because `~/.profile` is also read by shells that are not bash, which
would choke on bash syntax in `.bashrc`.

**25.** `function`, defined in `~/.bashrc` — which the login shell reached only via the line in
exercise 24. Remove that line and the function is gone from login shells.

**26.** `~/.profile`, which exports `STATION_ROLE=cadet`.

**27.** `[]` — empty. `--noprofile` skipped `/etc/profile` and all three login files, so nothing set
`STATION_ROLE`, and nothing sourced `.bashrc` either.

**28.** `bash: --: invalid option`. It is complaining about the *position*, not the option: once bash
has seen a short option it stops accepting long ones. `bash --noprofile -l` is fine. The error names
`--`, which is the least helpful place it could have pointed.

**29.** `2186-08-14 16:02:00`. rhea's claim in `notes/page.txt` is true: the file really has not been
written to since last August.

**30.** `expand_aliases off`. In a non-interactive shell bash does not expand aliases, so `type`
reports the name as not found — there is nothing that word will turn into. The `alias` builtin still
*recorded* it, which is why `alias` lists it. Both outputs are accurate; they answer different
questions, exactly like `type` and `which` in lesson 02.

**31.** `decks is aliased to `deck-report --all'`. Turning the option on makes the alias live.

**32.** Whether the shell is interactive. Functions are unaffected by `expand_aliases`; aliases are
switched off wholesale in non-interactive shells.

**33.** Put anything a script needs in a **function**, not an alias. An alias in a sourced file is
silently inert in exactly the case a script cares about, and the failure is `command not found` —
which sends you looking for a missing program rather than a disabled feature.

## The complaint

**34.** `.bash_profile`, because it comes first in the order.

**35.** `read: ~/.bash_profile`, alone. The `.profile` next to it — which contains a line saying so —
never runs.

**36.** No. `alias` prints nothing. `.bash_profile` does not source `.bashrc`, and a login shell does
not read `.bashrc` on its own.

**37.** `read: ~/.bashrc`, and the alias is defined. The alias exists in every interactive non-login
shell and in no login shell.

**38.** Terminals that start a login shell read `.bash_profile`, which does not pull in `.bashrc`, so
they have no aliases. Terminals that start a plain interactive shell read `.bashrc` directly and have
all of them. Same account, same files, different kind of shell.

**39.** `~/.bash_profile`. Its *existence* — not its contents — is what stops `~/.profile` from being
read, and `~/.profile` is where the sourcing line would have been.

**40.** cass's terminal starts a non-login interactive shell and reads `.bashrc`, which defines a
`station-status` function printing four lines. rhea's terminal starts a login shell, reads
`.bash_profile`, never reaches `.bashrc`, and so falls through to the program on `PATH`, which prints
three. Two people, one word, no fault, thirty seconds apart.

**41.** How the terminal was started. A different terminal program, a new profile in the same one, a
window opened from a file manager rather than the launcher, a `screen`/`tmux` setting, a shell started
by a program rather than by login. None of those touches a file, and all of them change whether the
shell is a login shell.

**42.** Any two of: the terminal emulator has a "run command as a login shell" checkbox and it was
turned off; the new window was spawned by a program that runs `bash` rather than `bash -l`; she
opened a shell inside an editor or file manager; a multiplexer was configured to start a non-login
shell for new panes.

**43.** Because the fix is one file and the difference is a rule. Knowing the difference, she can
predict the next twenty terminals; knowing the fix, she can repair this one and be surprised again.
She says so herself: wrong on purpose beats right by accident.

## Breaking it on purpose

**44.** The shell exits before running your command — `REACHED` never prints — and the exit status is
1. A login that exits during its startup file is a login you do not get.

**45.** It blocks, waiting on standard input that no one is going to type. An automated login hangs
forever rather than failing, which is worse: nothing errors, nothing times out, and the job simply
never finishes. Never prompt in a startup file without checking that the shell is interactive.

**46.** It continues. `.profile: line 1: ecoh: command not found`, and then `REACHED` prints, rc 0.
A startup file is an ordinary script: an error on one line does not stop the rest.

**47.** The quiet one. Exercise 44 announces itself the moment you try to log in and you fix it
immediately. Exercise 46 leaves you logged in with one line of your configuration missing — an
unexported variable, a `PATH` entry that never got added — and the consequence turns up hours later
somewhere unrelated. Loud failures cost minutes; quiet ones cost days.

**48.** `HOME=$L/scratch/t bash --noprofile -l` — then edit the file from inside that shell. Verified:
`REACHED` prints.

**49.** Because `--noprofile` is reversible and deleting is not. The home directory may contain
everything else the account has; the problem is one line in one file, and you want a shell that skips
it rather than a machine that has lost it. Same instinct as lesson 02, exercise 46: get a working
shell first, repair second.

## BASH_ENV, source, and reload

**50.** `read: BASH_ENV file`. Exercise 12 said a non-interactive shell reads *nothing* — this is the
exception, and the only one. If `BASH_ENV` is set, bash reads the file it names before running the
script.

**51.** No. Only `read: ~/.bashrc` appears. `BASH_ENV` applies to non-interactive shells only;
interactive ones use `~/.bashrc` instead.

**52.** `echo "$BASH_ENV"` in the environment the job runs under — remembering from lesson 01 that
your own shell's value is not the job's. Print the job's environment from inside the job
(`env | grep BASH_ENV`), because that is the only environment that matters.

**53.** `zz` is still there. `source` runs the file again *in the shell you already have*: it adds
whatever the file defines and removes nothing. Anything you defined by hand, and anything a previous
run defined that the file no longer mentions, survives untouched.

**54.** Any *removal*. A deleted alias, a deleted function, a `PATH` entry you appended twice, an
exported variable you took out of the file — none of those go away, because nothing tells the running
shell to forget them. Only a new shell starts from nothing. "Reload" is a word from other software;
bash does not have the concept.

## Debrief

**55.** Compare against the table in solution 15. The row people get wrong is almost always the login
row — either they add `~/.bashrc` to it, or they forget that `/etc/bash.bashrc` is reached from
`/etc/profile` when the shell is interactive.

**56.** `~/.bashrc` is for things that must exist in every interactive shell and cannot be inherited:
aliases, functions, shell options, the prompt. `~/.profile` is for things that are set once per
session and inherited by everything you start from it: exported variables, `PATH`.

**57.** "Everywhere" is not true — `~/.bashrc` is not read by login shells or by scripts, so it is
the *narrowest* of the three places, not the widest. An exported variable belongs in `~/.profile`,
where it is set once and inherited downward exactly as lesson 01 described.

**58.** Something like: *Nothing changed on disk — your `.bashrc` is untouched since August and I
checked. What changed is the kind of shell the terminal started. Your function lives in `.bashrc`,
which login shells never read; the terminals where it works start a non-login shell, and this
morning's started a login one, so it fell through to the program on `PATH`. You can tell which kind
you are in with `shopt login_shell` — `on` means the function will be missing. (`$0` beginning with a
dash is the traditional tell, but it depends on how the shell was launched: `kestrel enter` gives you
a login shell whose `$0` is plain `bash`. `shopt login_shell` is the one that always answers.)*
