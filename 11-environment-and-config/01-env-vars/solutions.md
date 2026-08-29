# 11/01 — Solutions

Answer key. Values measured in the container, not drafted. Counts that depend on the student's own
shell are marked; everything else is exact.

**No flag in this lesson.** The chapter's flag is in `06-incident-10`.

---

## Warmup — the one-word difference

**1.** `[]` — empty. Single quotes stop *your* shell expanding `$DECK`, so the string `echo "[$DECK]"`
reaches the child intact and the child expands it against its own environment, which has no `DECK`.
With double quotes your shell would substitute `05` before `bash` ever started, and the child would
print `[05]` while proving nothing about inheritance.

**2.** `[05]`. Seven characters: `export ` .

**3.** At the process boundary. It lives in this shell's variable table and is never copied into a
child.

**4.** `bash: DECK: command not found`. Bash split the line into words and
found no `=` attached to the first one, so it read `DECK` as a command name and `=` and `05` as its
two arguments.

**5.** No. Variable names are case-sensitive; `echo "$deck $DECK"` prints `05 07`.

**6.** No — `export CYCLE` promotes the existing variable and keeps its value. Useful when the value
is long, was computed, or was set somewhere else in a file you would rather not edit twice.

**7.** `12`, then `13`, then `13` again. (The base number is 11 in a fresh `kestrel enter` and 12
once you have `cd`'d anywhere, because `cd` sets `OLDPWD`. What matters is the *change*, not the
number.) Exporting added one variable to the environment handed to children. The unexported `TEMP2`
added a variable to the shell and changed nothing about what crossed the boundary.

**8.** Back to `12`.

**9.** "the shell hands that program a copy of exactly the exported ones, and nothing else" — the
line in `notes/variables.txt` under *Inheritance runs one way*.

**10.** `printenv NAME` with its output discarded, tested by exit status. `echo "$NAME"` cannot
distinguish an unset variable from an empty one; both print an empty line and both succeed, so a
script built on `echo` would report an empty `DECK` as present.

## Asking the right process

**11.** About `12` against about `1500`. Two reasons: `set` lists *unexported* shell variables too,
and `set` prints every shell *function* including its whole body — `lab` alone is a dozen lines, and
the bash-completion machinery loaded at login is most of the rest.

**12.** Set by you: nothing, on a fresh shell. Arrived before you: `HOME`, `HOSTNAME`, `LANG`,
`PATH`, `PWD`, `SHLVL`, `DEBIAN_FRONTEND`, `LS_COLORS`, `_` — from the container's image and the
`docker exec`. `COURSE` and `LABS` arrived too but from a different place: your `.bashrc`, which is
lesson 03.

**13.** `declare -x NAME="value"` lines — valid bash. You can save it to a file and `source` it to
recreate the same environment in another shell. `env`'s `NAME=value` output is not safely re-usable:
a value containing a newline or a quote produces lines that cannot be parsed back.

**14.** `BASH_VERSION`, `PS1`, `HISTSIZE`, `PPID`, `UID` — any of these. They are shell variables
that were never exported: bash sets them for its own use and no child needs them.

**15.** `printenv HOME` prints `/home/cadet`, rc 0. `printenv NOPE` prints nothing, `rc=1`.
`echo "$NOPE"` prints an empty line, `rc=0` — `echo` succeeded at printing nothing. Only `printenv`
gives a script something to branch on.

**16.** `DECK=05` without exporting: `echo "$DECK"` prints `05`, `printenv DECK` prints nothing and
exits 1. They disagree because they are answering questions about two different tables.

**17.** `function`. It appears in `set` (as `lab () { ... }`) and not in `env`. Functions are part of
the shell's own state; the environment is a list of name/value strings handed to a program, and a
program cannot be handed a shell function. (Bash *can* export functions, awkwardly, via
`export -f` — nothing on this station does, and it is a known source of trouble.)

**18.** `1` then `2`. It counts how many shells deep you are. The child incremented it on purpose —
it is the one variable that is deliberately different on the other side of the boundary.

**19.** After `env` it prints `env`; after `ls` it prints `ls`. Bash sets `_` to the last argument of
the previous command, and exports the full path of the command it is about to run. It changes with
every command, including the ones a script runs internally, so nothing can rely on it.

**20.** `set` when the question is about *this shell*: is the variable defined, what is the function
body, what did I type. `env` when the question is about *what a program will receive*. Inheritance
questions can only be answered by `env`, because only `env` is on the other side.

## Crossing the boundary

**21.** `./bin/deck-report: line 4: DECK: DECK is not set in my environment`, rc 1. Line 4 is
`: "${DECK:?DECK is not set in my environment}"`.

**22.** Works: `deck : 05`, `cycle : 41`, `reader : cadet`, `source : /var/lib/kestrel/decks`.

**23.** Fails, identically to exercise 21. On one line the assignment is a *prefix* to that command
and is placed in that command's environment. On two lines it is an ordinary assignment: a shell
variable, unexported, which stops at the boundary. The characters are the same; the newline changes
what they mean.

**24.** `[]` after 22 — the prefix leaves nothing at all, not even an empty variable. `[05]` after 23.
The prefix form is safer: the value exists for one command and cannot leak into the next thing you
run, which matters when the value is a credential or a path that would silently change another
program's behaviour.

**25.** Prefix — one command. Plain assignment — this shell, until `unset` or exit, and no child sees
it. `export` — this shell and every child it starts from now on, until `unset`, `export -n`, or exit.

**26.** With `DECK` exported: `DECK  05`. After `unset DECK`: `DECK  (not in my environment)`. The
other four lines never change; nothing in the lab sets them.

**27.** `cycle  : 99`. Both prefixes apply to the one command that follows.

**28.** Your login shell → the `bash -c` child → `deck-report`'s own `#!/usr/bin/env bash` process.
`DECK` was copied twice, once at each boundary, which is why it survived.

**29.** `[UNSET]`. The script exported `STATION` into *its own* environment and printed it from
there. The export died with the process. There is no contradiction: the message was true of the
process that printed it.

**30.** `[kestrel-7]`. `source` does not start a process — it reads the file and runs the lines in
your current shell, so its `export` is your `export`. One process ran: yours.

**31.** `inside=[kestrel-7]`, `outside=[UNSET]`. The parentheses made a subshell — a child that is a
copy of your shell. The `source` ran there, in the copy, and the copy's table died at the closing
parenthesis. Sourcing puts the variable in *the shell that sourced it*, and that shell was not yours.

**32.** A script's variables reach you only if (a) it was sourced, not executed, and (b) the shell
that sourced it is the shell you are typing in. Anything else is a child, and children do not write
back.

## Removing, demoting, and the difference

**33.** `env | grep KEEP` prints `KEEP=1`, then nothing after `unset`. `set | grep '^KEEP='` is
likewise empty. `unset` removes it from both, because there is only one table and the export flag was
a mark on the entry.

**34.** Not in `env`. Still in `set`. `echo "$KEEP"` still prints `1`. It is an ordinary shell
variable again.

**35.** `[UNSET]` — the child no longer receives it, while your shell still has the value. Use it to
stop handing something to the programs you are about to run without losing it yourself: a token you
still need, a `DEBUG` setting that is confusing one tool, a variable you want to hand back later with
a bare `export KEEP`.

**36.** `bash: FIXED: readonly variable`. You cannot unset it either:
`bash: unset: FIXED: cannot unset: readonly variable`, rc 1. Readonly is a one-way door for the life
of the shell.

**37.** Not readonly — not even set. Readonly is a property of an entry in *this shell's* table, and
the table went away with the shell. Nothing about readonly is written to disk or inherited.

**38.** Yes: `env | grep EMPTY` prints `EMPTY=` — the name is present with an empty value. Being
empty and being absent are different states of the environment.

**39.** `printenv EMPTY` — exit 0 with an empty line when it is set-and-empty, exit 1 when it is
unset. Equivalently `${EMPTY-x}` versus `${EMPTY:-x}`, which is exercises 41–42.

**40.** `unset` takes the *name* of the variable to remove; `$name` would hand it the value, which is
the wrong string. `unset $EMPTY` with `EMPTY` empty expands to bare `unset`, which removes nothing
and exits 0 — a silent no-op, and `EMPTY` is still there. This is the same class of mistake as
quoting: think about what the command receives, not what you typed.

## Unset, empty, and insisting

**41.** `none` when unset; an empty line when `DECK=`. `${x-d}` substitutes only when `x` is *unset*.
An empty value is a value, so it is used.

**42.** `none` in both cases. The colon adds "or empty" to the condition. Reach for the colon forms
when an empty value would be as useless to you as a missing one — which is nearly always, for a
filename or an identifier.

**43.** `: "${CYCLE:=41}"` on line 5. The `:=` form: substitute *and assign* when unset or empty.

**44.** `${REPORT_SOURCE:-/var/lib/kestrel/decks}`, used inline on the last line. `:=` sets the
variable, so every later reference in the same script sees the default too and you write the default
exactly once. `:-` substitutes at one point of use; a second reference would need the default
repeated, which is how two copies of a default drift apart.

**45.** `${DECK:?...}` — the colon form, so empty triggers it as well as unset. Same message, rc 1.

**46.** "If `DECK` is unset or empty, print my message to standard error and abort; otherwise expand
to its value." The leading `:` is the do-nothing builtin: the line exists only for the side effect of
the expansion, and `:` gives the expansion somewhere to be without running anything with it. Without
it the expanded value would be executed as a command.

**47.** A report is produced with a blank deck field and looks like a successful run. It lands in the
log, gets filed, and is indistinguishable from a real one until somebody needs it — which is
fourteen months later, if chapter 8 taught you anything. Failing at line 4 costs one night; failing
quietly costs the archive.

**48.** rc 0, then rc 1. You would test that a missing configuration variable makes the job *fail* —
one `if ! ...; then` in the nightly wrapper turns three silent nights into an alert on the first one.

## env, in full

**49.** Same output as exercise 22. `env NAME=value` runs a real program with a modified environment,
so it works where the shell's prefix form does not: on a builtin, and in places where the shell would
otherwise apply the assignment to itself. It also documents itself — `env` in the line is a visible
statement that this is an environment change and not an argument.

**50.** `11` — one fewer than `./bin/count-env` gives on its own. `env -u PATH ls` still lists the
directory: `env` looks the command up using the system's built-in default search path when `PATH` is
absent, and `ls` lives in `/usr/bin`, which is on it. Removing `PATH` is not the same as making
lookup fail.

**51.** `env -i bash -c env` prints `PWD`, `SHLVL` and `_`. None were inherited — `bash` set all
three itself as it started. `env -i env` prints nothing at all, because there is no shell in that
command: `env` empties the environment and executes `env` directly, and the second `env` sets no
variables of its own. The three in the first command are bash's fingerprints, not leftovers.

**52.** `/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin` — bash's compiled-in default.
Missing: `/opt/kestrel/bin`, the first entry of your own `PATH`. So that entry is not a property of
the machine; something put it in your environment before your shell started. Lesson 02 is about who.

**53.** Works. The script depends on `DECK` and on finding `bash` and `id`; it depends on nothing
else in the environment, which is a stronger statement than reading the source can give you.

**54.** Same message, same rc 1. Not a different failure — which is the point: the script cannot tell
"you gave me nothing" from "you gave me everything except `DECK`", and it does not need to.

**55.** Because "works for me" almost always means "works with my thirty extra variables", and
`env -i` is the cheapest way to find out which one matters. Start empty, add back one at a time, and
the difference between the two environments stops being a guess. A scheduled job runs with a small
environment and no login files; `env -i` reproduces that on demand.

**56.** `2` and `2` — no difference here. Both `_` lines come from the same shell behaviour, and
redirecting to a file does not change what `env` was handed. (`env` does not add or remove anything
of its own; the only variable that moves around in casual testing is `_`, and it is set before the
redirection is set up.)

## The nightly job

**57.** She asks for the *class* of thing that broke, not a fix and not a culprit. She also tells you
to check the mtime yourself rather than believe her, which is the correct instruction and you should
follow it.

**58.** First failure `2187-06-16`; three consecutive nights, through `2187-06-18`.

**59.** `2186-07-19 04:31:00`. Confirmed: eleven months older than the first failure. The script did
not change.

**60.** No. The script's `${DECK:?}` uses the colon form, so unset and empty produce the identical
message — exercise 45 is the one that establishes this. To tell them apart you would need the
environment the job actually ran with, which the log does not record.

**61.** Any three of: whatever *exported* `DECK` stopped doing so; the job's invocation lost its
`DECK=05` prefix; the wrapper began running the script through something that does not inherit the
environment (a different account, a scheduler, a `env -i`-style clean context); a startup file that
used to be sourced no longer is, because the shell running the job is not interactive. Check first:
what the job's environment actually contains — reproduce it with `env -i`, rather than reading the
script again.

**62.** Something changed in the *environment the job is handed*, not in the job. The script has been
the same file since 2186-07-19, and running it by hand works because a hand-typed command inherits a
login shell's variables that a scheduled one does not.

## Debrief

**63.** Either (a) it must be sourced — `. ./setup.sh`, in which case it can, or (b) it prints an
`export` line for you to run or eval, in which case it cannot and is telling you to do it yourself.
From the outside: run it as `./setup.sh` and check with `printenv JAVA_HOME`. If it is unset, it was
never able to; read the file for a `source`/`eval` instruction.

**64.** Nowhere — the shell that held it exited and its variable table went with it. Nothing about a
variable is written to disk unless a file writes it. Lesson 03, startup files, is about the file that
sets it again every time you log in.

**65.** An environment variable is a name/value string that a process was handed when it started. The
process that started you gave it to you — your login shell, which got its own from `docker exec`, and
added to it from your startup files. You can take it away for your children with `unset` or
`export -n`; nobody can take it away from a process that is already running, and no child of yours
can give one back.
