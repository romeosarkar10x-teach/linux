# 02/02 — Tutor hint ladder

Rules: `docs/TUTOR_PROTOCOL.md`. One rung per exchange. L3 examples must use data outside this lab.

---

### Exercise 1
- **L1 question:** What do the entries that appear only in the second listing have in common?
- **L2 locate:** Notes, "What `ls` hides by default", first half.
- **L3 concept:** In a home directory, `ls` shows almost nothing while the directory is full of `.bashrc`, `.profile` and friends. Ask what those names share.
- **L4 decompose:** (1) plain listing, count; (2) the all-entries listing, count; (3) name the extras.
- **L5 near-miss:** If they used `-A` and got a count two lower than expected, ask which two entries `-A` deliberately drops.
- **Never say:** `-a`.

### Exercise 2
- **L1 question:** One of the two flags shows two entries that exist in *every* directory. Which entries?
- **L2 locate:** Notes, the three-line `ls`/`ls -a`/`ls -A` block; `man ls`, the `-A` entry.
- **L3 concept:** `.` and `..` are entries in the directory, not shell syntax — you saw that in `02/01`.
- **L4 decompose:** (1) run both; (2) diff the outputs by eye; (3) name the two extra lines.
- **L5 near-miss:** If they say "`-A` hides hidden files", have them re-run both on `logs`.
- **Never say:** "almost-all".

### Exercise 3
- **L1 question:** Which flag turns sizes into things a person can read at a glance?
- **L2 locate:** Notes, "The long format, field by field", last paragraph.
- **L3 concept:** `df` has the same flag and the same behaviour — `df` versus `df -h`.
- **L4 decompose:** (1) long listing; (2) add the readability flag; (3) check the `total` line changed too.
- **L5 near-miss:** If they got `879K` but dropped the long format, point at what the exercise asked for.
- **Never say:** `-lh`.

### Exercise 4
- **L1 question:** How many entries does `ls logs` print, and how many does the everything-listing print?
- **L2 locate:** Notes, "What `ls` hides by default".
- **L3 concept:** Same mechanism as exercise 1, one directory deeper. One of the three is a directory, which is easy to miss in a plain listing.
- **L4 decompose:** (1) list `logs` showing everything; (2) subtract the plain listing; (3) note which of the extras are directories.
- **L5 near-miss:** If they named two, ask them whether `-A` or `-a` was used and what the third one might be.
- **Never say:** the three names.

### Exercise 5
- **L1 question:** Does `ls` need you to be *in* a directory to list it?
- **L2 locate:** `02/01` notes on relative paths.
- **L3 concept:** From `/`, `ls etc/apt` lists a directory two levels down without any `cd`.
- **L4 decompose:** (1) get the hidden directory's exact name from exercise 4; (2) join it to `logs/` with a slash; (3) hand that to `ls`.
- **L5 near-miss:** If the shell says "No such file", check whether they dropped the leading dot.
- **Never say:** `ls logs/.rotated`.

### Exercise 6
- **L1 question:** Which flag changes the *sort key* to time, and which one flips any sort around?
- **L2 locate:** Notes, "Sorting", the table.
- **L3 concept:** `ps` and `du` have their own sort options; in `ls` the two concerns are separate flags, one choosing the key and one reversing.
- **L4 decompose:** (1) find the time flag; (2) run it; (3) find the reversing flag; (4) combine.
- **L5 near-miss:** If they used the reversing flag alone, ask what it reversed.
- **Never say:** `-t` or `-r`.

### Exercise 7
- **L1 question:** Same question as exercise 6 with a different key. Which one is size?
- **L2 locate:** Notes, "Sorting", the table.
- **L3 concept:** —
- **L4 decompose:** (1) find the size flag in the table or `man ls`; (2) confirm the largest is first without `-r`.
- **L5 near-miss:** If they sorted by the *number in the name*, point out that is a name sort.
- **Never say:** `-S`.

### Exercise 8
- **L1 question:** Does the biggest file have the newest date? Does the newest have the latest name?
- **L2 locate:** Their own output from 6 and 7.
- **L3 concept:** Name, time and size are three independent facts about a file; nothing keeps them in step.
- **L4 decompose:** (1) write the three orders as three lists of five names; (2) compare pairwise.
- **L5 near-miss:** If two of their orders match, one of the commands was wrong — ask them to re-run it.
- **Never say:** the orders.

### Exercise 9
- **L1 question:** Both commands were given the same argument. Why did only one of them go inside it?
- **L2 locate:** Notes, "The long format, field by field", the type character; `man ls`, the `-l` entry and the `-L` entry.
- **L3 concept:** `ls /bin` on this station lists hundreds of programs; `ls -l /bin` prints one line with an arrow in it. Ask which of those two answers is about the entry and which is about its target.
- **L4 decompose:** (1) run both; (2) note that no flag was needed to stop the descent; (3) read the first character of the one-line output; (4) read what follows the arrow.
- **L5 near-miss:** If they call it a directory, point at the first character and the notes' type list.
- **Never say:** the word symlink, or that `-l` implies not dereferencing.

### Exercise 10
- **L1 question:** Same flag as exercise 9. What does it mean to ask about a directory rather than through it?
- **L2 locate:** Notes, "What `ls` hides by default".
- **L3 concept:** —
- **L4 decompose:** (1) reuse the flag from 9; (2) state in your own words what it suppressed.
- **L5 near-miss:** If they explain it as "shows the directory", push for "does not descend".
- **Never say:** `-d`.

### Exercise 11
- **L1 question:** Is `A` before or after `a`, and who decides?
- **L2 locate:** Notes, "Sorting", the first three paragraphs.
- **L3 concept:** `sort` on the same list gives the same answer as `ls` does, and it is not because `sort` copied `ls` — both ask the same subsystem how to compare strings.
- **L4 decompose:** (1) run `ls`; (2) run `locale` and read the collation entry; (3) ask what values that entry could take; (4) find the command that lists the ones installed here.
- **L5 near-miss:** If they try `LC_ALL=en_US.UTF-8 ls` and nothing changes, that is the finding — ask them why it did not, and point at step (4).
- **Never say:** `LC_COLLATE`, or `locale -a`.

### Exercise 12
- **L1 question:** When does `ls` use columns, and when does it not? You proved this in `01/01`.
- **L2 locate:** Notes, "Recursion, and one column"; `01/01` notes on terminals.
- **L3 concept:** `ls | cat` on any directory comes out one-per-line, without any flag. Ask what `ls` checked.
- **L4 decompose:** (1) find the one-column flag; (2) get the same result by sending output somewhere that is not a terminal; (3) name the test `ls` is performing.
- **L5 near-miss:** If they redirected to a file and cannot see the result, have them read the file back.
- **Never say:** `-1`, or the phrase "isatty".

### Exercise 13
- **L1 question:** Is `run-10` before or after `run-9` in the default order, and why?
- **L2 locate:** Notes, "Sorting", the table — one row is about numbers inside names.
- **L3 concept:** A default sort compares character by character: `1` comes before `9`, so `x-10` precedes `x-9` regardless of magnitude. Some tools can be told to read digit runs as numbers.
- **L4 decompose:** (1) list `runs`; (2) find the row in the table about version sorting; (3) re-run; (4) state what changed.
- **L5 near-miss:** If they reached for `sort -n` in a pipe, accept it as a good instinct and ask for the `ls` flag as well.
- **Never say:** `-v`.

### Exercise 14
- **L1 question:** What does a directory with a header and nothing under it tell you?
- **L2 locate:** Notes, "Recursion, and one column", last line.
- **L3 concept:** Recursion prints one labelled block per directory visited. A visited-but-empty directory still gets its label.
- **L4 decompose:** (1) run the recursive listing; (2) count the labelled blocks; (3) subtract one for `deep` itself.
- **L5 near-miss:** If their count includes files, ask which lines end with a colon.
- **Never say:** `-R`, or the count.

### Exercise 15
- **L1 question:** With two arguments, what appears that did not appear with one?
- **L2 locate:** Notes, "Gotchas", first callout.
- **L3 concept:** Run `ls /etc /var` and look at the first line — it is not a filename.
- **L4 decompose:** (1) run the one-argument form; (2) run the two-argument form; (3) point at the lines that are labels rather than entries.
- **L5 near-miss:** If they say "it printed both directories", push for what the *shape* of the output is.
- **Never say:** the word "header" before they do.

### Exercise 16
- **L1 question:** Which of those five commands actually descended into the target, and which reported on the link?
- **L2 locate:** Notes, "What `ls` hides by default"; `02/01` on trailing slashes.
- **L3 concept:** Trailing slash is an assertion about the path — you proved that in `02/01` with a regular file. `-d` is a request about `ls`'s behaviour. They are different layers.
- **L4 decompose:** (1) write five predictions; (2) run all five; (3) group them by output; (4) explain each grouping's cause separately.
- **L5 near-miss:** If they conclude "the slash and `-d` do the same thing", ask what `ls -ld current/` did and why that combination is not silent.
- **Never say:** that a trailing slash forces the symlink to be followed.
- **Grading note:** missing written prediction fails.

### Exercise 17
- **L1 question:** How many previous directories can the shell remember?
- **L2 locate:** Notes, "`cd`, properly".
- **L3 concept:** `cd -` swaps two values. A swap performed twice is the identity.
- **L4 decompose:** (1) write five predicted `pwd` outputs; (2) run the sequence, printing `pwd` each time; (3) find the variable holding the previous directory; (4) explain the swap.
- **L5 near-miss:** If they expected a stack, ask them to name where the third-oldest directory would be stored.
- **Never say:** `OLDPWD`.
- **Grading note:** missing written prediction fails.

### Exercise 18
- **L1 question:** What is today's date, according to the container? What year are the files stamped?
- **L2 locate:** Notes, "The long format, field by field", the two bullets.
- **L3 concept:** `ls -l /etc` on a long-lived machine shows some lines with clock times and some with years. The cutoff is not "this year" — it is a distance from now.
- **L4 decompose:** (1) run `date`; (2) predict which files fall inside the window; (3) run the listing; (4) state the rule as a distance.
- **L5 near-miss:** If they say "files from a different year show the year", point at two files in the same year with different formats — or, if there are none here, ask them what would happen to a file dated two days from now.
- **Never say:** "six months".
- **Grading note:** missing written prediction fails.

### Exercise 19
- **L1 question:** Which of the five kinds of command word from `01/03` is `ls` in your interactive shell?
- **L2 locate:** `01/03` notes, "Five kinds of command word".
- **L3 concept:** `type -a grep` in this container prints more than one line for the same reason.
- **L4 decompose:** (1) ask the shell what `ls` is; (2) note the substitution; (3) find two ways to bypass it — one is a character, one is a path.
- **L5 near-miss:** If they only used the absolute path, remind them `01/03` gave a one-character method too.
- **Never say:** the backslash form, or `command`.

### Exercise 20
- **L1 question:** Which flags have you already used for: long, human sizes, time sort, reversed, dotfiles-but-not-dot-dot?
- **L2 locate:** Their own answers to exercises 1, 3, 6.
- **L3 concept:** Short flags with no arguments bundle: `tar -c -z -f` is `tar -czf`. `01/03` covered the rule.
- **L4 decompose:** (1) list the five behaviours; (2) write the flag for each; (3) concatenate them after one dash; (4) verify against running them separately.
- **L5 near-miss:** If they used `-a` instead of `-A`, point at "excluding `.` and `..`".
- **Never say:** `-lhrtA`.

### Exercise 21
- **L1 question:** The notes gave a tilde form that names the previous directory without moving. What was it?
- **L2 locate:** Notes, "`cd`, properly", third paragraph.
- **L3 concept:** `~` alone expands to home; the family has more members, and one of them pairs with `cd -`.
- **L4 decompose:** (1) get into `bay-2` from somewhere memorable; (2) recall the tilde form; (3) hand it to `ls`, not to `cd`.
- **L5 near-miss:** If they used `$OLDPWD`, accept it and ask for the tilde form as well.
- **Never say:** `~-`.

### Exercise 22
- **L1 question:** What is different about the two entries in the *parent* directory, even though their contents are identical?
- **L2 locate:** Notes, "The long format, field by field", the type character.
- **L3 concept:** `ls -ld /bin /usr/bin` on this station shows two lines whose first characters differ. Same contents, different kind of entry.
- **L4 decompose:** (1) get one line about each, not their contents; (2) compare the first character; (3) compare the arrow.
- **L5 near-miss:** If they compared `ls logs` with `ls current` and found them identical, tell them that is the point and to describe the *entries* instead.
- **Never say:** `-ld`, or the word symlink.

### Exercise 23
- **L1 question:** If colour is not coming from `ls`, where is it coming from?
- **L2 locate:** Notes, "`-F`, and why colour might not work"; `man ls`, the `--color` entry, which names the variable.
- **L3 concept:** `grep --color=auto` works here because it needs no database. `ls` needs to be told which colour goes with which file type, and that mapping lives outside the program.
- **L4 decompose:** (1) print the variable and see it is empty; (2) `man ls` names it — search the page for its name; (3) find the companion program (`apropos color` helps); (4) run it and read its output before evaluating it; (5) evaluate it into the current shell.
- **L5 near-miss:** If the program's output is an empty assignment, ask them what `TERM` is set to in this shell and try again with it set.
- **Never say:** `eval "$(dircolors -b)"`.

### Exercise 24
- **L1 question:** Can a 180-byte file and a 1400-byte file take up the same amount of disk?
- **L2 locate:** `man ls`, search for "blocks".
- **L3 concept:** Disks are handed out in fixed-size chunks. A one-character file still consumes a whole chunk.
- **L4 decompose:** (1) find the flag; (2) combine it with the long format; (3) find two files whose byte sizes differ a lot but whose block counts match; (4) infer the chunk size from the numbers.
- **L5 near-miss:** If they report `hull` as the anomaly, point out that its two numbers agree closely and ask which pair does not.
- **Never say:** `-s`, or the block size.

### Exercise 25
- **L1 question:** Is there an order that costs `ls` nothing to produce?
- **L2 locate:** Notes, "Sorting", the last row of the table.
- **L3 concept:** Sorting requires reading every entry first. Not sorting means printing entries as the directory hands them over — which is an artefact of how they were created and deleted.
- **L4 decompose:** (1) find the flag; (2) run it on `logs`; (3) compare with plain `ls`; (4) ask what the order might encode.
- **L5 near-miss:** If they say "it is random", push: is it random, or is it just not sorted?
- **Never say:** `-U`.

---

## Escalation notes

Students who "already know `ls`" tend to fail exercises 9, 16 and 22 — all three are about the
difference between an entry and what it points at. If they stall on one, do not move on; the same
confusion is what Chapter 3 is built on.
