# 02/01 — Tutor hint ladder

Rules: `docs/TUTOR_PROTOCOL.md`. One rung per exchange. Never state a command the exercise asks
the student to produce. L3 examples must use different data than the lab.

---

### Exercise 1
- **L1 question:** When you open a fresh terminal, before you type anything, where are you?
- **L2 locate:** Notes, "The working directory"; and the "Gotchas" callout about `cd` with no argument.
- **L3 concept:** A command with no arguments usually has a default. `head` with no count defaults to 10 lines. Ask what the useful default destination for a move command would be.
- **L4 decompose:** (1) print where you are; (2) move somewhere obviously different, like `/etc`; (3) run the bare command; (4) print where you are again.
- **L5 near-miss:** If they say "it goes to root", ask them to compare the output with `echo ~`.
- **Never say:** that `cd` with no argument is equivalent to `cd ~`.

### Exercise 2
- **L1 question:** What single character at the front of a path means "start from the top of the tree"?
- **L2 locate:** Notes, "Absolute and relative", the two-row table.
- **L3 concept:** `/etc/hostname` names the same file whether you run it from `/tmp` or from `/var/log`. Ask them what makes that true.
- **L4 decompose:** (1) `cd` to the lab and run `pwd`; (2) copy that output; (3) go home; (4) paste it in front of the filename.
- **L5 near-miss:** If they wrote a path with no leading slash and got "No such file", ask which directory the shell started counting from.
- **Never say:** the absolute path itself.

### Exercise 3
- **L1 question:** If the file is in the directory you are standing in, how much of the path do you actually need?
- **L2 locate:** Notes, "Absolute and relative".
- **L3 concept:** In `/var/log`, `syslog` and `/var/log/syslog` name the same file. Ask why.
- **L4 decompose:** (1) `cd` to the lab; (2) `ls` to confirm the name; (3) use the name alone.
- **L5 near-miss:** If they still typed the absolute path, ask what "relative" is relative *to*.
- **Never say:** the command.

### Exercise 4
- **L1 question:** How many different names can one directory have?
- **L2 locate:** Notes, "The two directories in every directory".
- **L3 concept:** From `/var/log`, `/var/spool`, `../spool` and `/var/./spool` are three names for one place. Ask them to build the analogous set here.
- **L4 decompose:** (1) the plain relative name; (2) `pwd` output plus the name; (3) go up one with `..`, then come back down into the lab, then into the target.
- **L5 near-miss:** If the third one is just `./deck-3`, point out that it never went *up*.
- **Never say:** `../01-filesystem-tree/deck-3`.

### Exercise 5
- **L1 question:** From bay 3, what is the shortest way to describe where bay 1 is?
- **L2 locate:** Notes, "The two directories in every directory".
- **L3 concept:** Standing in `/home/cass`, `../dorn/notes.txt` reaches a sibling's file. The pattern is: up to the shared parent, then down.
- **L4 decompose:** (1) name the directory both bays share; (2) how do you name it from where you stand; (3) append the rest of the path.
- **L5 near-miss:** If they have `../bay-1` and it worked, they are done — ask them to say out loud what `..` resolved to.
- **Never say:** `../bay-1/survey.txt`.

### Exercise 6
- **L1 question:** How many levels up is the lab root from bay 3?
- **L2 locate:** Notes, "The two directories in every directory".
- **L3 concept:** `../../` from `/usr/share/doc` reaches `/usr`. Each `../` strips one component.
- **L4 decompose:** (1) write out your `pwd`; (2) cross off components from the right until you are at the lab; (3) count how many you crossed off.
- **L5 near-miss:** If they used one `..`, ask them to `ls` that directory and see whether `roster.txt` is in it.
- **Never say:** `../../roster.txt`.

### Exercise 7
- **L1 question:** Can a single path go up and down again?
- **L2 locate:** Notes, "The two directories in every directory", the worked block.
- **L3 concept:** From `/etc/apt`, `../ssl` reaches `/etc/ssl` without ever naming `/etc`.
- **L4 decompose:** (1) go up to the parent; (2) from there, what is the target called; (3) join them with a slash in one argument.
- **L5 near-miss:** If they ran two `cd` commands, remind them the exercise says one.
- **Never say:** `cd ../bay-2`.

### Exercise 8
- **L1 question:** How deep is `panel-07` below the lab root? Count the components.
- **L2 locate:** Notes, "Resolution, and where the surprises come from".
- **L3 concept:** Going from `/usr/share/doc/bash` back to `/usr` takes three ups, because three names sit between them.
- **L4 decompose:** (1) `pwd` from inside panel-07; (2) count the components after the lab path; (3) that count is how many `..` you need.
- **L5 near-miss:** If they used four and it worked but landed one too high, ask them to `ls` and check for `roster.txt`.
- **Never say:** the number of `..` components.

### Exercise 9
- **L1 question:** Which of the two path kinds keeps working if the script is run from somewhere else?
- **L2 locate:** Notes, "Absolute and relative", second column of the table.
- **L3 concept:** A cron-style job that runs `cat readings.log` breaks the moment it is launched from a different directory; `cat /var/log/readings.log` does not.
- **L4 decompose:** (1) build the relative path by counting up then down; (2) build the absolute one from `pwd` at the lab root; (3) compare their fragility.
- **L5 near-miss:** If they claim absolute is always better, ask what happens when the whole tree is moved.
- **Never say:** either finished path.

### Exercise 10
- **L1 question:** `shortcut` is not a directory. What is it, and what does that mean for "where am I"?
- **L2 locate:** Notes, "Resolution, and where the surprises come from", the `/bin` block.
- **L3 concept:** `cd /lib` on this station reports `/lib` even though the real directory is `/usr/lib`. Ask which of those two is on disk.
- **L4 decompose:** (1) `cd shortcut`; (2) run the plain builtin; (3) find the flag in `help pwd` that asks for the resolved form.
- **L5 near-miss:** If they used `realpath .` and got the right string, accept it and ask them to find `pwd`'s own flag as well.
- **Never say:** `pwd -P`.

### Exercise 11
- **L1 question:** Which tool answers "what does this path really point at" without moving you?
- **L2 locate:** Notes, "Resolution, and where the surprises come from", last block.
- **L3 concept:** `realpath /bin/sh` prints the real file the name lands on, from wherever you are standing.
- **L4 decompose:** (1) name the file through the symlink; (2) hand that whole path to the resolving tool.
- **L5 near-miss:** If they `cd`-ed first, point out the exercise says "without changing directory".
- **Never say:** the command.

### Exercise 12
- **L1 question:** The shell remembers how you got here. Does the kernel?
- **L2 locate:** Notes, "Resolution, and where the surprises come from"; and `01/04` on `$PWD`.
- **L3 concept:** After `cd /bin`, `cd ..` lands at `/`, not `/usr` — the shell walked back along the path you typed, not the one on disk.
- **L4 decompose:** (1) note the logical path from ex 10; (2) strip its last component; (3) compare with where you actually ended up.
- **L5 near-miss:** If they say "the shell is wrong", ask which behaviour would be less surprising to a person who typed `cd shortcut`.
- **Never say:** the words "logical" and "physical" paired with the answer — make them name it.

### Exercise 13
- **L1 question:** How many levels is `bay-2` above `panel-07`?
- **L2 locate:** Notes, "The two directories in every directory".
- **L3 concept:** Same shape as exercise 6, one level shallower.
- **L4 decompose:** (1) `pwd`; (2) count components back to `bay-2`; (3) that many `..`, then the filename.
- **L5 near-miss:** If they got `No such file or directory`, ask them to `ls` the directory their `..` chain lands in.
- **Never say:** `../../readings.log`.

### Exercise 14
- **L1 question:** Which two tools split a path into its two halves?
- **L2 locate:** Notes, "Naming pieces of a path".
- **L3 concept:** On `/etc/apt/sources.list`, one tool gives `/etc/apt` and the other gives `sources.list`. The suffix-stripping form takes the suffix as a second argument.
- **L4 decompose:** (1) directory half; (2) filename half; (3) filename half with a second argument.
- **L5 near-miss:** If they stripped the suffix with a text editor or by hand, point at the second argument.
- **Never say:** `basename ... .log`.

### Exercise 15
- **L1 question:** Is a run of slashes in the *middle* of a path the same as one slash? Is a run at the *front* the same question?
- **L2 locate:** Notes, "Absolute and relative" (what a leading slash means) and "Resolution, and where the surprises come from".
- **L3 concept:** `/etc//passwd` and `/etc/passwd` are one file. But compare `ls etc` from `/` with `ls /etc` — the leading slash changed which tree you started from, not how many separators there were.
- **L4 decompose:** (1) write four predictions; (2) run all four; (3) for each failure, ask what the path would have to name for it to succeed; (4) explain only the mismatches.
- **L5 near-miss:** If they blame the double slash for the third failure, ask them to run `ls /deck-3` and compare the error.
- **Never say:** that a leading `//` is absolute, or that a trailing slash requires a directory — both are the deliverable.
- **Grading note:** a missing written prediction fails this exercise. A wrong prediction with a correct explanation passes.

### Exercise 16
- **L1 question:** Who expands `~` — the shell, or the program you ran?
- **L2 locate:** Notes, "`~` — home"; and `01/04` on quoting.
- **L3 concept:** `echo $HOME` and `echo "$HOME"` agree; `echo '$HOME'` does not. Same question, different character.
- **L4 decompose:** (1) predict all five; (2) run them; (3) for the two that differ, ask what the quotes turned off; (4) for the last line, recall what `..` means in the root directory.
- **L5 near-miss:** If they say "quotes are for spaces", ask why the output changed when there were no spaces.
- **Never say:** that `~` expansion is suppressed inside quotes.
- **Grading note:** prediction must be written before the run.

### Exercise 17
- **L1 question:** Chapter 1 said the shell keeps some state in variables. Is "where am I" one of them?
- **L2 locate:** `01/04` notes; `env | sort` in the container.
- **L3 concept:** `echo $HOME` prints a directory without running any program that looks it up. Ask what other directory the shell would need to keep on hand.
- **L4 decompose:** (1) list the environment; (2) find the entry whose value matches `pwd`'s output; (3) print it; (4) `cd` and print it again.
- **L5 near-miss:** If they found `OLDPWD` first, tell them they are one variable away and that the other one is the current one.
- **Never say:** `$PWD`.

### Exercise 18
- **L1 question:** Does a process stop existing in a directory when the directory stops existing?
- **L2 locate:** Notes, "Gotchas", third callout.
- **L3 concept:** A file that is deleted while a program still has it open keeps working for that program. Directories have a version of that story.
- **L4 decompose:** (1) make a directory; (2) `cd` into it; (3) remove it by absolute path; (4) run the three commands and record each result verbatim.
- **L5 near-miss:** If they conclude "the shell crashed", point at the exit status and the fact that they can still `cd` out.
- **Never say:** that `$PWD` is stale while `getcwd` fails — that is the deliverable.

### Exercise 19
- **L1 question:** Do both tools have the same appetite for arguments? Try each with three and see.
- **L2 locate:** `man basename`, the OPTIONS section — it is a short page, read all of it.
- **L3 concept:** `head file1 file2` handles several by default; some tools instead reserve the second argument for something else and need a flag to switch modes.
- **L4 decompose:** (1) give one tool three paths — it works; (2) give the other three paths — read the error or the surprising output; (3) find the flag that changes its argument handling; (4) find the flag that takes the suffix.
- **L5 near-miss:** If they have the multiple-operand flag but are still stripping suffixes one at a time, point at the *other* option in the same section.
- **Never say:** `-a` or `-s`.

### Exercise 20
- **L1 question:** `realpath` prints absolute paths. Can you tell it what to measure *from*?
- **L2 locate:** `man realpath`, OPTIONS.
- **L3 concept:** Some tools take a "compute this with respect to X" option — `du --exclude`, `tar -C`. Look for the one whose name says "relative".
- **L4 decompose:** (1) read the options list; (2) two of them contain the word relative — read both; (3) pick the one that takes a directory; (4) verify by `cd`-ing there and using the result.
- **L5 near-miss:** If they picked the "relative-base" one and got an absolute path, tell them there are two and the other is the one they want.
- **Never say:** `--relative-to`.

### Exercise 21
- **L1 question:** `pwd` has a flag for the physical path. Does `cd` have the same one?
- **L2 locate:** `help cd` inside bash — `cd` is a builtin, so `man cd` will not help.
- **L3 concept:** The `-P` / `-L` pair shows up in more than one builtin, and means the same thing in each.
- **L4 decompose:** (1) run `help cd`; (2) find the two flags; (3) use the one that resolves; (4) run `set -o` and look for an option whose name is the same idea as a word.
- **L5 near-miss:** If they found `set -o physical` first, ask them to also demonstrate the per-command flag.
- **Never say:** `cd -P` or `set -o physical`.

---

## Escalation notes

If the student is guessing paths rather than reasoning about them, stop and make them run `pwd`
before every attempt for the next three exercises. Nearly every failure in this lesson is a wrong
belief about where they are standing, not a wrong belief about the command.
