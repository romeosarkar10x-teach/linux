# 01/02 — Tutor hint ladder

Governed by [`docs/TUTOR_PROTOCOL.md`](../../docs/TUTOR_PROTOCOL.md). One rung per exchange.

**Diagnose first:** if a student is stuck across several exercises here, it is nearly always that
they believe `sh` and `bash` are two names for one program. Establish that before hinting further.

### Exercise 1 — /bin/sh
- **L1 question:** What kind of file is `/bin/sh`? What does a long listing show you at the start
  and the end of that line?
- **L2 locate:** Notes, "`/bin/sh` is a lie of convenience".
- **L3 concept:** Some filesystem entries are pointers to other entries; a long listing shows both
  the type and the destination on one line. On different data: `/usr/bin/vi` is often the same kind
  of pointer.
- **L4 decompose:** Long-list the path. Read character one. Read after the arrow.
- **L5 near-miss:** If they ran `sh --version` and got confused, ask them to look at the file
  instead of running it.
- **Never say:** "symlink to dash".

### Exercise 2 — /etc/shells
- **L1 question:** The notes name a file. Have you read it?
- **L2 locate:** Notes, "What shells are installed".
- **L3 concept:** It is an ordinary text file; nothing special is needed to read it.
- **L4 decompose:** `cat` the path.
- **L5 near-miss:** —
- **Never say:** —

### Exercise 3 — three readings
- **L1 question:** Which of the three is a measurement rather than a stored value?
- **L2 locate:** Notes, "Which shell is running this"; also 01/01's Gotcha.
- **L3 concept:** Preference, invocation name, kernel fact — three different sources with three
  different failure modes.
- **L4 decompose:** One command each, in the notes' order.
- **L5 near-miss:** If they only have two, ask which one is argument zero.
- **Never say:** the three commands as a set.

### Exercise 4 — inside dash
- **L1 question:** Which of the three readings could dash possibly change?
- **L2 locate:** Notes, "Trying another shell".
- **L3 concept:** A variable inherited from the parent keeps its value in the child. Argument zero
  and the process table describe the child itself.
- **L4 decompose:** Enter dash. Take all three readings. Compare with the bash ones.
- **L5 near-miss:** If they report all three changed, have them re-read the first one carefully.
- **Never say:** which one stays the same.

### Exercise 5 — stale shells list
- **L1 question:** How would you check whether a path in that list actually exists?
- **L2 locate:** Notes, "Gotcha" after `/etc/shells`; also `ls -l` from boot.dev.
- **L3 concept:** A list of names is not evidence the things exist. Different example: a crew roster
  can list someone who transferred off six months ago.
- **L4 decompose:** Read both files. Note lines present in one only. Then test each path's existence
  one at a time.
- **L5 near-miss:** If they try `diff`, tell them that is Chapter 7 and to compare by eye — both
  files are short.
- **Never say:** which entries differ. In particular do not tell them that the copy's extras are
  absent from this machine; that finding is the exercise.

### Exercise 6 — nologin
- **L1 question:** Look at the two odd entries. Does that path look like a shell to you?
- **L2 locate:** `crew-shells.txt`; also `man nologin` if they want the full answer.
- **L3 concept:** The login shell field must contain *something*; putting a program there that
  refuses and exits is how you make an account exist without being usable interactively.
- **L4 decompose:** Identify the two accounts. Then find out what that program does.
- **L5 near-miss:** If they say "it is a broken shell", ask whether it might be doing its job.
- **Never say:** "it refuses logins".

### Exercise 7 — a shell that is not there
- **L1 question:** Of the shells named in that file, which have you not yet confirmed exists?
- **L2 locate:** Notes, "What shells are installed".
- **L3 concept:** Same skill as exercise 5, applied to an account rather than a list.
- **L4 decompose:** List the distinct shells in the file. Test each path. One fails.
- **L5 near-miss:** If they conclude the account is broken, push for what the login program would
  actually do.
- **Never say:** `ksh`.

### Exercise 8 — greet.sh two ways
- **L1 question:** How do you run a script file with a specific interpreter, without relying on a
  shebang?
- **L2 locate:** Notes, "`/bin/sh` is a lie of convenience", the example block.
- **L3 concept:** Naming the interpreter first makes the file an argument, and the shebang is then
  irrelevant. Different example: `python3 thing.py` regardless of what `thing.py` claims.
- **L4 decompose:** Interpreter, then filename. Twice, with two interpreters.
- **L5 near-miss:** If they get "permission denied", they tried to execute it — ask what they are
  actually trying to control here.
- **Never say:** `bash greet.sh` / `sh greet.sh` verbatim.

### Exercise 9 — explaining the error
- **L1 question:** dash said something was "not found". What does a shell normally mean by that?
- **L2 locate:** Notes, "Trying another shell".
- **L3 concept:** A shell reads a word in command position and looks for something to run. If the
  word is not a keyword *it knows*, the only remaining option is to look for a program by that name
  and fail. bash knows the keyword; dash does not, so the word falls through to the search.
- **L4 decompose:** Which word failed? Is that a program name in bash? What is it instead?
- **L5 near-miss:** If they say "dash has a syntax error", ask why the message names a lookup
  failure rather than a parse failure.
- **Never say:** "it is a bash keyword" as the whole answer.

### Exercise 10 — --version
- **L1 question:** What did the second one actually say?
- **L2 locate:** Notes, "The one-line summary of a shell".
- **L3 concept:** Command-line options are per-program conventions, not a standard. A very common
  option can still be absent.
- **L4 decompose:** Try both. Quote the failure.
- **L5 near-miss:** —
- **Never say:** —

### Exercise 11 — nesting mixed shells (Experiment)
- **L1 question:** Does starting a different shell make the previous one go away?
- **L2 locate:** 01/01, "Nesting".
- **L3 concept:** Nesting is about processes, not about which program. A dash inside a bash inside a
  bash is three processes, and the listing names each by what it is.
- **L4 decompose:** Prediction first, in writing. Then nest and list.
- **L5 near-miss:** If no prediction is written, that is the exercise — send them back.
- **Never say:** the count.

### Exercise 12 — `$0` three ways (Experiment)
- **L1 question:** What is `$0` actually reporting — the program, or the name it was called by?
- **L2 locate:** Notes, "Which shell is running this", the `-bash` paragraph.
- **L3 concept:** Argument zero is set by whoever starts the process, and login programs use a
  leading dash as a signal. Different example: `busybox` decides what to do entirely from argument
  zero.
- **L4 decompose:** Three predictions, written. Then measure each.
- **L5 near-miss:** If they expected `-bash` from (c) and did not get it, that is the intended
  result — ask them who actually sets argument zero, and whether the shell can set its own.
- **Never say:** that `-l` does not change `$0`, before their prediction exists.

### Exercise 13 — dash's parent (Stretch)
- **L1 question:** Which exercise in 01/01 taught you to see a parent's PID?
- **L2 locate:** 01/01 exercise 14; `man ps`.
- **L3 concept:** Parentage is recorded per process, so a child can always name its parent.
- **L4 decompose:** Note bash's PID before entering dash. In dash, get PID and PPID. Compare.
- **L5 near-miss:** If the numbers do not match, ask how many shells deep they actually are.
- **Never say:** `-o pid,ppid`.

### Exercise 14 — the shebang (Stretch)
- **L1 question:** When you run a file *as a program*, who decides which interpreter reads it?
- **L2 locate:** Notes, the shebang mention under `/bin/sh`.
- **L3 concept:** The kernel reads the first line and, if it starts with the right two characters,
  uses the named program as the interpreter. The launching shell has no say. Different example: a
  file starting `#!/usr/bin/env python3` runs as Python even from bash.
- **L4 decompose:** Which interpreter does this file *need*? Write that as line one. Make the file
  executable. Run it as a program.
- **L5 near-miss:** If they wrote `#!/bin/sh`, ask them to run it and read the result.
- **Never say:** `#!/bin/bash`.

### Exercise 15 — fixing the roster (Stretch)
- **L1 question:** What are the two separate things you must check about a candidate shell?
- **L2 locate:** Notes, "What shells are installed" — the two-questions paragraph.
- **L3 concept:** Existence and registration are independent. A shell can be installed but
  unregistered, or registered but gone.
- **L4 decompose:** Pick a candidate. Test it exists. Test it is listed. Then copy and edit.
- **L5 near-miss:** If they pick something installed but not in `/etc/shells`, ask what `chsh`
  would say.
- **Never say:** `/bin/bash`.

### Exercise 16 — syntax check without running (Dig)
- **L1 question:** Is there a way to ask a shell "would this parse?" without letting it do anything?
- **L2 locate:** `man bash`, the OPTIONS / `set` builtin list — look for the one described as
  reading commands without executing them. `man dash` has the same option.
- **L3 concept:** Parsing and executing are separate phases. A checker can prove a file is
  well-formed and still know nothing about whether the commands in it exist. Different example: a
  script full of `frobnicate --hard` parses perfectly and fails instantly.
- **L4 decompose:** Find the option. Run it under both shells. Compare with what exercise 8 did.
- **L5 near-miss:** If they insist `sh` should have complained, send them back to their own answer
  for exercise 9 and ask which phase the failure happened in.
- **Never say:** `-n`; and do not pre-empt the surprise by saying the check will pass.

### Exercise 17 — the type builtin (Dig)
- **L1 question:** What single word describes what `[[`, `echo` and `dash` each *are* to the shell?
- **L2 locate:** `man bash`, SHELL BUILTIN COMMANDS; or `help` with no arguments.
- **L3 concept:** The shell can classify a name before running it: keyword, builtin, function,
  alias, or file on disk. Different example: `cd` cannot be a file, because a program cannot change
  its parent's directory.
- **L4 decompose:** Find the classifier. Run it on all three in bash. Then try it in dash.
- **L5 near-miss:** If they use `which` and get nothing for `[[`, ask why an external lookup tool
  would not find a shell keyword.
- **Never say:** `type`.
