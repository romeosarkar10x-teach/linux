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
