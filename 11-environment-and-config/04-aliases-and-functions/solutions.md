# 11/04 — Solutions

Answer key. Measured in the container.

**No flag in this lesson.** The chapter's flag is in `06-incident-10`.

---

## The program, before anything shadows it

**1.** Three: `deck`, `status`, `source`.

**2.** `deck   : 5` instead of `deck   : all`. Still three lines.

**3.** Two. The `source :` line is dropped.

**4.** `2185-11-02 14:20:00`.

**5.** Yes. `type` says `.../bin/deck-report` and so does `which`. Nothing is shadowing it yet, and
this is the state in which the two tools agree — which is most of the time, which is why people trust
`which`.

## What an alias actually is

**6.** A text substitution applied to the first word of a command before bash decides what to run.

**7.** `bash: g: command not found`. The alias was defined, but not used.

**8.** `pre one two`.

**9.** Bash reads and parses a whole line before executing any of it. On line 7 the alias did not
exist at parse time, so the word `g` was never a candidate for substitution; by the time `alias` ran,
the parsing was over. On two lines, the second line is parsed after the first has run.

**10.** No — it prints `g`. Only the **first** word of a command is checked for an alias.

**11.** After the replacement text: `echo pre` + ` one two` = `echo pre one two`. The words you type
are not consumed, inspected or reordered; they are simply left where they were.

**12.** No. There is nowhere for `$1` to come from — the substitution happens before any command
exists to have arguments. Anything that needs `$1` must be a function.

**13.** Five: `ll`, `la`, `..`, `please`, `deck-report`.

**14.** `ls -l /etc/hostname`.

**15.** `bash: \ll: command not found`. The backslash suppressed alias expansion, so bash looked for a
*program* called `ll`, and there is none. The escape worked exactly as intended; there was simply
nothing behind the alias.

**16.** Same error. Quoting the word also suppresses expansion. Both tell you that alias expansion
happens on the literal first word before quote removal decides anything else — an alias is matched
only when the word is written plainly.

**17.** `bash: ll: command not found`. `command` skipped the alias stage and the function stage, and
went looking at builtins and `PATH`, where nothing called `ll` exists.

## ops-bot's discrepancy

**18.** 2.

**19.** 3.

**20.** Aliases are switched off in non-interactive shells. Your interactive shell expanded
`deck-report` to `deck-report --terse` and got two lines; the script sourced the identical file, got
the identical alias *recorded*, and never expanded it.

**21.** `type` told the truth: `deck-report is aliased to `deck-report --terse'`. `which` printed
`.../bin/deck-report` — a real file, correctly located, and not what ran. `which` searches `PATH`, and
`PATH` was never reached.

**22.** Yes. `2185-11-02 14:20:00`, exactly as claimed. Nothing about the program changed. ops-bot's
"no fault detected" is also correct: no component is misbehaving.

**23.** Something like: *Both numbers are correct. An alias in a sourced configuration file adds
`--terse` to `deck-report`, and aliases do not exist in non-interactive shells, so interactive
submissions are terse and scheduled ones are not. The program has not changed. What needs deciding is
which output is authoritative — that is a decision, not a fault.*

**24.** `please hi` prints `chained`: `please` expands to `sudo ` with a trailing space, which makes
bash check the next word, `hi`, for an alias too — and it is one. `nope hi` prints `X hi`: without the
trailing space, `hi` is left as a literal argument.

**25.** Because `sudo` runs a *program*, and your aliases are not programs. `sudo ll` normally fails.
`alias sudo='sudo '` makes the word after `sudo` alias-expandable, so your shortcuts survive it.

**26.** `type deck-report` goes back to naming the file in `bin/`. `unalias -a` removes all of them and
`alias` then prints nothing.

## Functions

**27.** Arguments (`$1`, `"$@"`, `$#`); a return status via `return`; `local` variables. Also: it
works in non-interactive shells, and it can change the current shell's state.

**28.** You cannot. Any `$1` you write in the alias text is either expanded when you define it (giving
you the *defining* shell's `$1`, usually empty) or left as a literal that never gets a value. There is
no point in the expansion at which arguments exist.

**29.** `declare -F mkcd`, `declare -F deck_summary`, `declare -F deck-report` — the function names
only.

**30.** `-F` lists names. `-f` prints bodies. Capital for the index, lowercase for the contents.

**31.** In `scratch/newdir`. It could not be a program because a program is a child process: it would
change *its own* directory and exit, leaving yours alone. Lesson 01's downward-only rule, applied to
the working directory instead of a variable.

**32.** `usage: mkcd <dir>` on standard error, exit status **2**. The function checked `$#` and used
`return`, which is what an alias could not have done.

**33.** Yes, still `IMPORTANT`. `deck_summary` declares `deck` as `local`.

**34.** `5`. Without `local`, the assignment inside the function writes to the caller's variable. The
function did its job correctly and damaged your shell on the way past.

**35.** It protects the *caller* from the function. A function without `local` is writing into
whatever shell happens to call it, and it cannot know what names that shell is using.

**36.** `return 3` gives `$?` of 3 and leaves you in your shell. `exit 3` ends the shell — the terminal
closes or you are dropped back out. `return` is for functions; `exit` in a function ends the whole
shell, which is almost never what you meant, and is exactly why a bad function in a startup file can
make logins impossible (lesson 03, exercise 44).

## Functions shadow harder than PATH

**37.** `[wrapped]`, on standard error (fd 2). The report itself is unchanged on fd 1. Chapter 8's
point again: the two streams are separable, so the banner is a courtesy, not a safeguard.

**38.** No. `which` prints the path in `bin/` and says nothing about the function. It searches `PATH`,
and a function means `PATH` is never consulted.

**39.** `type` says `deck-report is a function` and prints the body. `type -a` prints the function
*and then* the file in `bin/` — the full candidate list, in resolution order, showing you both the
thing that runs and the thing it is hiding.

**40.** Preventing infinite recursion. Inside the function, the word `deck-report` would resolve to
the function again; `command` skips the alias and function stages so the program is reached.

**41.** The builtin stage — and then `PATH`. It skips aliases and functions only.

**42.** `type` reveals it. `type -a` reveals it and what it hides. `declare -F deck-report` prints the
name, confirming a function exists. `command -v deck-report` prints just `deck-report` — the bare
name with no path, which is itself the tell, because for a program it prints a path. `which` reveals
nothing. Three of the four work; the one that fails is the one most people type.

**43.** Exit status **139** — a segmentation fault, with no error message from bash at all. The
recursion consumed the stack and the process died. Measure it, do not predict it: most people expect
"maximum function nesting level exceeded", and by default there is no such message.

**44.** With `FUNCNEST=20` you get
`bash: report: maximum function nesting level exceeded (20)` and exit status 1. A diagnosable error
instead of a crash. Ship the second: a bounded failure that names itself beats a signal 11 that
somebody has to debug from a core file.

**45.** `type` names the file in `bin/` again. It is `unset -f` because plain `unset` removes a
*variable*, and bash keeps functions and variables in separate namespaces — you can have both named
`count` at the same time.

## Three plausible mistakes

**46.** Expectations vary; what matters is writing them down before measuring, because at least one
of the three will surprise you.

**47.** Yes — `deck 5` prints the report for deck 5. That is the trap.

**48.** `$1` inside the double-quoted alias text expanded when the file was sourced, and at that
moment `$1` was empty. So the alias text is really `deck-report ` — and then your `5` was appended
after it, exactly as exercise 11 described. The right answer arrived for a reason that has nothing to
do with what the author intended, and it will keep arriving until somebody sources that file from a
shell that *does* have a `$1`.

**49.** `bash: deck: command not found`. Aliases do not exist in a non-interactive shell.

**50.** The script's. It fails loudly, at the point of use, with a message that names the thing that is
missing. The interactive version fails silently by *appearing to work*, which means the misconception
survives and gets copied into the next file.

**51.** Same as exercise 43: exit 139, segfault, no message. The one-word fix is `command`:
`report() { command report --all; }`.

**52.** `i` is now `3`. `count` assigned to `i` without `local` and overwrote your variable. Short
names like `i`, `n`, `count` and `tmp` are the ones that collide, because everybody uses them.

**53.** `local`: `count() { local i; i=$(deck-report | wc -l); echo "$i"; }`.

**54.** Running each one twice — once in an interactive shell and once in a script — before shipping
it. Mistake 1 diverges between the two, mistake 2 crashes in both, mistake 3 shows a changed variable
in both. Nothing subtler than that was needed, and nobody did it.

## Choosing

**55.** Alias: a fixed shortcut for a command you type by hand, with no arguments to place —
`alias la='ls -la'`. Function: anything that needs an argument in the middle, a decision, a loop, a
status, or that a script might call — `mkcd`, a wrapper, a two-command sequence with a check between.

**56.** Because aliases do not exist in non-interactive shells. A script that sources your file gets
the alias recorded and never expanded, so the command is "not found" — an error that sends you looking
for a missing program rather than a disabled feature. That is ops-bot's discrepancy, and it is why the
rule is worth memorising rather than re-deriving.

**57.** First: it changes what a word means for everyone, and `which rm` will keep saying `/usr/bin/rm`,
so the next person to debug it gets a tool that lies to them (lesson 02's shadowing, made invisible).
Second: it only applies in interactive shells, so every script keeps the old behaviour — you get two
different `rm`s on one machine and the safe one is the one nobody's automation uses. If the goal is
safety, the honest version is a differently-named command that people choose, not a redefinition of
one they already trust.

**58.** `type` can see aliases, functions and builtins — everything bash resolves before it ever looks
at `PATH` — while `which` sees only files on `PATH`. A backslash suppresses **alias** expansion only,
so a function of the same name still runs; `command` skips **both** aliases and functions and goes to
the builtin/`PATH` stage.
