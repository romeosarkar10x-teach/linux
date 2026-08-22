# 01/03 — Tutor hint ladder

Governed by [`docs/TUTOR_PROTOCOL.md`](../../docs/TUTOR_PROTOCOL.md). One rung per exchange.

**Diagnose first:** when a student is stuck here, ask them to say out loud what they think the shell
does with the words on their line. The wrong model is "the shell understands the flags". Correct
that model before hinting at anything else.

### Exercise 1 — classify five words
- **L1 question:** Which command in the notes answers "what will actually run", rather than "is
  there a file with this name"?
- **L2 locate:** Notes, "`type` — the question to ask first".
- **L3 concept:** The shell can tell you a word's category before it runs it. Different example:
  ask it about `while` and about `cat` and notice the two answers are different *kinds* of answer.
- **L4 decompose:** One invocation per word. Read each answer's last two words.
- **L5 near-miss:** If they used `which` and got nothing for `cd` and `if`, that is exercise 5 — ask
  them why those two came back empty.
- **Never say:** `type`.

### Exercise 2 — deck-report with three arguments
- **L1 question:** How does the shell decide where one argument ends and the next begins?
- **L2 locate:** Notes, "The shape of a line".
- **L3 concept:** Whitespace splits words; the first is the command, the rest are a list. Different
  example: `cp a b c` hands `cp` three strings and `cp` decides that the last one is the
  destination — the shell has no opinion about that.
- **L4 decompose:** Run it with three words. Count the reported arguments.
- **L5 near-miss:** If they get `command not found`, that is exercise 9 arriving early — ask where
  the shell looks for a command word.
- **Never say:** `./bin/deck-report`.

### Exercise 3 — one argument with a space
- **L1 question:** What did the shell do the last time you gave it two words? How would you stop it
  doing that?
- **L2 locate:** Notes, "The shape of a line". Quoting is Chapter 5, but the basic form is
  Chapter 0's.
- **L3 concept:** Quoting groups characters into one word before the split happens. Different
  example: a directory called `Deck 3` needs the same treatment.
- **L4 decompose:** Try it unquoted, count arguments. Add quotes. Count again.
- **L5 near-miss:** If they use a backslash before the space and it works, that is correct — accept
  it and mention quotes as the other route.
- **Never say:** —

### Exercise 4 — every echo
- **L1 question:** Does the classifier have a way to show *all* matches rather than the first?
- **L2 locate:** Notes, "`type` — the question to ask first", the two flags.
- **L3 concept:** Resolution stops at the first match, but the tool can list what it passed over.
  Different example: ask it about `test`.
- **L4 decompose:** Find the flag. Run it on the word. Count lines. Which line is first, and why
  does first mean winner?
- **L5 near-miss:** If they list four and say the last one wins, send them back to the resolution
  order in the notes.
- **Never say:** `-a`.

### Exercise 5 — which vs type
- **L1 question:** What does `which` actually search, and what would it therefore be unable to find?
- **L2 locate:** Notes, "`which` and why `type` is better".
- **L3 concept:** One tool searches the filesystem; the other asks the shell. Anything that is not a
  file is invisible to the first. Different example: try both on `alias` itself.
- **L4 decompose:** Both tools, both words, four outputs. Which output is empty, and is the command
  it describes broken?
- **L5 near-miss:** If they conclude `cd` does not exist, ask them to run `cd /tmp`.
- **Never say:** "builtins".

### Exercise 6 — the file named -l
- **L1 question:** Read the error. Who produced it — the shell, or `cat`? What does that tell you
  about who interpreted `-l`?
- **L2 locate:** Notes, "Flag conventions", the `--` row.
- **L3 concept:** The program, not the shell, decides that a leading dash means a flag. So the fix
  is either to tell the program to stop parsing options, or to hand it a string that does not begin
  with a dash while still naming the same file. Different example: a file named `-n`.
- **L4 decompose:** Route one — the notes give you a two-character answer. Route two — what is
  another way to write the path to a file in the current directory?
- **L5 near-miss:** If they rename the file, that works and is a fifth-best answer; ask what they
  would do if it were someone else's file they must not touch.
- **Never say:** `--` or `./`.

### Exercise 7 — the file named --help
- **L1 question:** Which of your two methods relies on the *program* cooperating, and which does
  not?
- **L2 locate:** Notes, "Flag conventions".
- **L3 concept:** A path-based fix works on every program, because it never looks like a flag in the
  first place. An end-of-options marker works only where the program implements it.
- **L4 decompose:** Try both methods. Note which programs honour the marker.
- **L5 near-miss:** If both work for them, that is fine — ask which they would trust against an
  unknown program.
- **Never say:** —

### Exercise 8 — the ll alias
- **L1 question:** What are the four things you have been asked to prove, and which command proves
  each?
- **L2 locate:** Notes, "Aliases, briefly".
- **L3 concept:** An alias is a substitution the shell performs before resolving anything else; it
  can be inspected, bypassed and removed. Different example: `alias c='clear'`.
- **L4 decompose:** Define. Classify. Bypass. Remove and re-classify.
- **L5 near-miss:** If bypassing does not work, check they escaped the *alias name* and not the
  arguments.
- **Never say:** `unalias`, or the backslash trick, before they have tried.

### Exercise 9 — command not found
- **L1 question:** Where does the shell look for a command word, and is the current directory in
  that list?
- **L2 locate:** Notes, "Five kinds of command word", item 5.
- **L3 concept:** Only directories on `PATH` are searched, and the current directory is
  deliberately not one of them — for security reasons Chapter 11 explains. Naming a path sidesteps
  the search entirely. Different example: a program in `/tmp` has the same problem.
- **L4 decompose:** Give it a path relative to where you are. Then give it an absolute path. Same
  file, two spellings.
- **L5 near-miss:** If they add the directory to `PATH`, that works — accept it, and ask for the two
  path spellings as well, since that is the skill here.
- **Never say:** `./bin/deck-report`.

### Exercise 10 — four odd arguments
- **L1 question:** For each of the four, what do you *expect* the program to report before you run
  it?
- **L2 locate:** Notes, "The shape of a line".
- **L3 concept:** The program only ever sees the list the shell hands it. Everything surprising here
  happened before the program started.
- **L4 decompose:** One at a time. Transcribe exactly, including the brackets.
- **L5 near-miss:** If the fourth one alarms them, confirm they transcribed it right and tell them
  to stop there — the explanation is Chapter 5 and guessing now will teach them a wrong rule.
- **Never say:** the word "glob" or any explanation of the `*` result.

### Exercise 11 — the decoy ls
- **L1 question:** How did you run `deck-report` in exercise 9? Does the same trick work here?
- **L2 locate:** Notes, "Five kinds of command word".
- **L3 concept:** Two files can share a name; which one wins is decided by search order, and naming
  a path opts out of the search.
- **L4 decompose:** Run the one in `bin/` by path. Run the bare word. Compare.
- **L5 near-miss:** If they edited `PATH` to test it, ask them to put it back and mention that
  Chapter 11 covers doing that safely.
- **Never say:** —

### Exercise 12 — two echoes (Experiment)
- **L1 question:** Are the builtin and the file the same program? Would you expect two different
  programs to support the same flags?
- **L2 locate:** Notes, "`type` — the question to ask first", the last paragraph.
- **L3 concept:** The builtin exists for speed and predictability inside the shell; the external one
  is a full program from a separate package, with its own options. Neither is wrong.
- **L4 decompose:** Prediction in writing first. Then both invocations.
- **L5 near-miss:** If they are surprised that the builtin printed the flag as text, ask what a
  program that does not recognise a flag *should* do with it.
- **Never say:** what either one prints.

### Exercise 13 — the recursive alias (Experiment)
- **L1 question:** If the alias body contains the alias's own name, what stops that repeating?
- **L2 locate:** Notes, "Aliases, briefly", first bullet.
- **L3 concept:** The shell expands an alias once and then refuses to expand the same name again
  within that expansion. Without that rule the construct would be unusable, and it is a very common
  thing to want.
- **L4 decompose:** Prediction and reasoning in writing. Then define, run, observe. Then remove.
- **L5 near-miss:** If they predicted infinite recursion, that is a *good* prediction — the
  reasoning is sound and the rule is the surprise. Say so.
- **Never say:** the rule, before their prediction exists.

### Exercise 14 — classifying in dash (Stretch)
- **L1 question:** Which of the classifier commands did the notes say was the portable one?
- **L2 locate:** Notes, end of "`which` and why `type` is better"; and 01/02 exercise 17.
- **L3 concept:** Each shell classifies against its own grammar, so the same word can get different
  answers in different shells — which is exactly what 01/02 exercise 9 was about.
- **L4 decompose:** Enter dash. Three words. Compare with bash's answers.
- **L5 near-miss:** If `type -a` fails in dash, that is a finding — have them record it.
- **Never say:** `command -v`.

### Exercise 15 — how many processes (Stretch)
- **L1 question:** A shell script is run by a shell. Is that the shell you are typing into?
- **L2 locate:** 01/01, "Nesting"; and this lesson's shebang discussion in 01/02 exercise 14.
- **L3 concept:** Running a script starts a new shell process to interpret it; commands inside it
  may start further processes. The shebang names which shell.
- **L4 decompose:** Count: the interpreter named by the shebang, plus anything it runs. Which one
  started which?
- **L5 near-miss:** If they say one process, ask what is executing the `for` loop.
- **Never say:** the number.

### Exercise 16 — one line for a colleague (Stretch)
- **L1 question:** Of the classifiers you have met, which one covers all five kinds *and* gives a
  path when there is one?
- **L2 locate:** Notes, the "Putting it together" block.
- **L3 concept:** Choosing a diagnostic is about coverage: pick the one whose blind spots you can
  live with.
- **L4 decompose:** List the candidates. For each, name something it cannot see. Choose.
- **L5 near-miss:** If they pick `which`, ask what it would report for a shell function.
- **Never say:** —

### Exercise 17 — the bare-path flag (Dig)
- **L1 question:** Run `help type` and read the flag list. Which one describes printing a path only?
- **L2 locate:** `help type`; `man bash`, SHELL BUILTIN COMMANDS.
- **L3 concept:** The flag reports a path *when there is one to report*. A word that resolves to
  something which is not a file has no path, so the correct output is nothing at all.
- **L4 decompose:** Find it. Run on both words. For the empty one, ask what category that word is.
- **L5 near-miss:** If they call the empty output a bug, ask what path they expected a builtin to
  have.
- **Never say:** `-p`.

### Exercise 18 — the PATH cache (Dig)
- **L1 question:** If the shell searched every directory on `PATH` for every command you typed,
  what would that cost?
- **L2 locate:** `help hash`; `man bash`, SHELL BUILTIN COMMANDS.
- **L3 concept:** The shell remembers where it found each program. The cache is almost always
  invisible and occasionally very confusing — when a program moves, the shell keeps going to the
  old place. Different example: install a newer version of a tool into an earlier PATH directory
  and the running shell will not notice.
- **L4 decompose:** Show the cache. Run a few programs. Show it again. Clear it. Show it again.
- **L5 near-miss:** If their cache is empty at first, that is correct in a fresh shell — have them
  run some programs and look again.
- **Never say:** `hash`, or the clearing flag.

### Exercise 19 — switching a builtin off (Dig)
- **L1 question:** If the builtin wins because it is earlier in the order, what would change the
  outcome without touching `PATH` or the filesystem?
- **L2 locate:** `help enable`; `man bash`, SHELL BUILTIN COMMANDS.
- **L3 concept:** The set of active builtins is itself adjustable at run time. Turning one off does
  not remove it — it takes it out of the resolution order, so the next candidate wins. Different
  example: doing this to `test` makes a script measurably slower and otherwise identical.
- **L4 decompose:** Find the builtin. Turn the target off. Classify it again. Get version output.
  Turn it back on. Classify again.
- **L5 near-miss:** If they cannot turn it back on, point out that the same command with no flag is
  the inverse.
- **Never say:** `enable -n`.
