# 01/02 — Exercises

```bash
kestrel seed 01/02
kestrel enter
lab 01/02
```

Answers in `~/01-02-answers.md`.

---

## Warmup

**1.** Show that `/bin/sh` is not a program in its own right on this system, and say what it points
at.

*Done looks like:* a listing that makes the relationship visible, and the target named.

**2.** Print the list of registered login shells.

*Done looks like:* the file's contents.

**3.** Report which shell you are in, three ways: the preference, the invocation name, and the
kernel's answer.

*Done looks like:* three outputs, and a note on which you would quote in a bug report.

---

## Core

**4.** Start a `dash` shell. While in it, print all three of the readings from exercise 3 again.
Two of them change and one does not. Say which, and why.

*Done looks like:* three readings from inside dash, and the explanation.

**5.** `station-shells` in the lab is a copy of `/etc/shells` taken from another station system.
Compare it against this machine's real `/etc/shells`, and then against what is actually installed
here. Report four things: what the copy lists that this machine's file does not; whether those
extra entries are installed here; what this machine's file lists that the copy omits; and what you
conclude about using a copied config file as evidence about a machine.

*Done looks like:* the four findings. You do not have `diff` or `grep` yet — compare by reading,
and check existence one path at a time.

**6.** `crew-shells.txt` lists each station account's login shell. Two accounts have a shell that is
not a shell. Identify them and say what that entry does instead.

*Done looks like:* the two accounts named, and one sentence on what that path is for.

**7.** One account in `crew-shells.txt` has a login shell this machine does not have installed.
Find it, prove the shell is absent, and say what would happen if that account tried to log in.

*Done looks like:* the account, the evidence of absence, and the predicted outcome.

**8.** Run `greet.sh` under `bash`. Then run the same file under `sh`. Record both results exactly,
including the exit status of each run.

*Done looks like:* two invocations — one printing the expected line, one printing an error and no
expected line — with the error quoted verbatim, plus both exit statuses. One of the exit statuses
will surprise you; note it and move on, you will explain it in exercise 9.

**9.** Explain the exercise-8 error. Name the specific construct that dash does not have, and say
why dash's error message says "not found" rather than "syntax error".

*Done looks like:* two sentences that get both halves right.

**10.** Ask `bash` for its version. Then ask `dash` for its version the same way. Report what
happens, and what you conclude about assuming a flag exists.

*Done looks like:* both attempts and the conclusion.

---

## Experiment

**11.** **Predict first, then run.** You are in bash. You type `dash`, and then inside dash you type
`bash`, and then you run the bare process listing.

Write down before running: how many processes will be listed, and what will they be called?

Then run it, and explain any difference.

*Done looks like:* prediction, observation, explanation.

**12.** **Predict first, then run.** The notes say a login shell's `$0` often has a leading dash.
Predict what `$0` will be in each of these three situations: (a) your normal interactive shell,
(b) a shell you started by typing `bash`, (c) a shell started as `bash -l`, which explicitly asks
for login behaviour.

Then check all three.

*Done looks like:* three predictions, three observations, and one sentence answering this: if
asking for login behaviour does not produce the leading dash, then who puts it there?

---

## Stretch

**13.** Using only 01/01 and this lesson: from inside a `dash` shell, work out its PID, its parent's
PID, and confirm the parent is the bash you started from.

*Done looks like:* the two PIDs and the confirmation, with the commands shown.

**14.** `greet.sh` has no shebang line. Add one that makes the file work correctly when someone runs
it as a program, then explain in one sentence why the shebang matters more than which shell *you*
happen to be using when you launch it.

*Done looks like:* the edited file, a successful run, and the sentence. Editing files: use whatever
you know — `cat >` from Chapter 0 is enough. `nano` is available if you prefer.

**15.** Copy `crew-shells.txt` to `crew-shells-fixed.txt` and correct the one account whose shell is
missing from this machine, choosing a replacement that is both installed **and** registered in
`/etc/shells`. Say why both conditions matter.

*Done looks like:* the new file, and two sentences — one per condition.

---

## Dig

**16.** Both `bash` and `sh` have an option that reads a script and checks it for syntax errors
**without running it**. Find it in the man page — it is not in the notes — and run it on `greet.sh`
with each shell.

You will expect `sh` to complain. It does not. Explain why, in one sentence, using what you worked
out in exercise 9.

*Done looks like:* both invocations, both exit statuses, and the explanation. This exercise is
worth more when your prediction is wrong.

**17.** There is a shell builtin that reports whether a name is a builtin, a file, an alias, or a
keyword. Run it on `[[`, on `echo`, and on `dash`, in bash — then run the same on `[[` in dash.
Report all four results.

*Done looks like:* four outputs, and one sentence on why `[[` answers differently in the two shells.
(You will meet this command properly in the next lesson. Find it now.)

---

## Core — what is actually installed

**18.** For each of `bash`, `dash`, `sh`, `zsh`, `fish` and `ksh`, say whether it exists on this
machine. Use one command per name and record the exact evidence.

*Done looks like:* six answers with evidence, not six guesses.

**19.** Three of the names in exercise 18 are absent. Are they absent from `/etc/shells` too?
Answer for each.

*Done looks like:* three answers, and one sentence on the difference between listed and installed.

**20.** `/etc/shells` lists seven paths on this machine. How many distinct *programs* is that? Work
it out from the paths.

*Done looks like:* the count, and the reason it is smaller than seven.

**21.** `rbash` appears in `/etc/shells`. Find out what it is by looking at what file it actually
is, not by searching the internet.

*Done looks like:* the evidence and a one-sentence description.

**22.** `/bin/sh` is a symlink. Say what would change on this system if that link were repointed at
`bash`, and name one thing that would get slower and one class of bug that would disappear.

*Done looks like:* two named consequences.

**23.** Run `sh` and check whether it behaves as dash or as bash. Then explain how you would check
this on a machine you have just been handed, in one command.

*Done looks like:* the check, the answer, and the portable one-liner.

---

## Core — running the same file under different shells

**24.** Run `greet.sh` three ways: `bash greet.sh`, `sh greet.sh`, and `dash greet.sh`. Two of the
three behave identically. Which two, and why?

*Done looks like:* three outputs and the reason, referring to exercise 1.

**25.** Take the exact exit status of each of the three runs. Write them down next to each other.

*Done looks like:* three numbers, and a note on which one you would treat as "the script is broken".

**26.** Write a two-line script that uses only constructs both shells have — `echo` and a variable —
and confirm it behaves identically under both. Say what you have and have not proved by that.

*Done looks like:* the script, both runs, and the honest limit of the evidence.

**27.** Now write a script that works in bash and fails in dash for a *different* reason than
`greet.sh` does. Any bashism will do. Quote dash's error.

*Done looks like:* the script, the two runs, and the error quoted exactly.

**28.** `bash -c 'echo ${BASH_VERSION}'` and `dash -c 'echo ${BASH_VERSION}'`. Two very different
outputs from one command line. Explain both.

*Done looks like:* both outputs and two sentences.

**29.** From a script's point of view, name the one fact about the interpreter that matters, and the
one fact about the interactive shell you launched it from that does not.

*Done looks like:* two short statements.

---

## Core — the crew roster

**30.** How many distinct login shells appear in `crew-shells.txt`? List them.

*Done looks like:* the list, with each shell counted once.

**31.** For each shell in that list, say whether it is installed here and whether it is in
`/etc/shells`. Two columns of yes/no.

*Done looks like:* the table, filled in from evidence.

**32.** One entry in `crew-shells.txt` would let the account exist but never log in interactively,
and a second would let it log in but immediately drop the session. Say which is which.

*Done looks like:* both entries named and the behaviours distinguished.

**33.** If you were auditing the station's accounts, which single line of `crew-shells.txt` would
you flag first, and what would you ask about it?

*Done looks like:* the line and the question. There is more than one defensible answer.

**34.** `station-shells` came from another machine. Name two questions you cannot answer from it,
however carefully you read it.

*Done looks like:* two questions, both about the *other* machine's real state.

---

## Experiment — predict before you run

**35.** **Predict first.** `sh -c 'echo $0'`. Will it print `sh`, `dash`, or a path? Predict, then
run.

*Done looks like:* prediction, output, and the reconciliation.

**36.** **Predict first.** You are in dash. You run `bash -c 'echo $SHELL'`. What will it print?

*Done looks like:* prediction, output, and one sentence on where that value came from.

**37.** **Predict first.** Does starting `dash` change what `/bin/sh` points at? Predict yes or no
before you check, then check.

*Done looks like:* the prediction and the check. If your prediction was yes, write down why.

**38.** **Predict first.** `dash --version`. Predict whether it prints a version, an error, or
nothing, and what its exit status will be. Then run it and check the status separately.

*Done looks like:* prediction, exact output, exact status.

**39.** **Predict first.** Type `exec dash` in a child shell — not `dash`. Predict how many `exit`s
it will take to get back to your first shell afterwards, compared with plain `dash`.

*Done looks like:* both counts and one sentence on what `exec` did. Do this in a throwaway child
shell.

---

## Stretch

**40.** Write the one-paragraph answer you would give to "which shell should I write this script
in?" for a script that must run on every machine on the station, and for a script that only ever
runs on your own account.

*Done looks like:* two recommendations with reasons, not one rule.

**41.** Take the four readings that identify a shell — `$SHELL`, `$0`, `ps -p $$ -o comm=`, and
`/proc/$$/exe` — and say what each one is really reporting. Rank them by how much you would trust
them.

*Done looks like:* four glosses and a ranking with reasons.

**42.** A colleague says "the script works for me". Using this lesson only, list three things about
their environment that could make that true while it fails for you.

*Done looks like:* three concrete differences.

**43.** Fix `greet.sh` so that it runs correctly under dash — without a shebang, and without losing
what it does. Say which construct you had to give up.

*Done looks like:* the rewritten script, a clean `dash greet.sh`, and the construct named.

**44.** Write two sentences on why a station would keep `dash` as `/bin/sh` at all, given that bash
is installed and more capable.

*Done looks like:* two sentences that mention start-up cost and discipline.

---

## Dig

**45.** Find where `bash` records the shell options that are on by default in POSIX mode, and name
two things `bash --posix` changes.

*Done looks like:* the source consulted and two named changes.

**46.** `command -v`, `type`, `which` and `whereis` will all "find a shell". Run all four on `dash`.
Two of them answer from the shell's own knowledge and two from the filesystem. Say which are which.

*Done looks like:* four outputs and the split.

**47.** `/proc/$$/exe` is a symlink. Follow it in both bash and dash and report where it lands.

*Done looks like:* two paths, and one sentence on why this is the least deniable of the four
readings.

**48.** Find out whether `rbash` is a separate binary or the same file as `bash`, and what makes it
behave differently.

*Done looks like:* the evidence and the mechanism in one sentence.

**49.** Find the option that makes `bash` refuse to read any startup files, and say when you would
want it.

*Done looks like:* the flag and a concrete situation.

**50.** Find out what `SHLVL` is, and watch it change as you nest three shells.

*Done looks like:* four readings and a definition.

**51.** `dash` is smaller than `bash`. Find both sizes and state the ratio. Then say why the size
difference is a design decision, not an accident.

*Done looks like:* two numbers, the ratio, and one sentence.

**52.** Find out what happens to a login attempt when the account's shell is not listed in
`/etc/shells` but *is* installed. It is not the same as the exercise-7 case.

*Done looks like:* the answer, and the source you used.
