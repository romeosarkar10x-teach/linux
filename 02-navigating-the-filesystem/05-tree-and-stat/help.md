# 02/05 — Tutor hint ladder

Read `docs/TUTOR_PROTOCOL.md` first. One rung per exchange. Never state a command.

**Escalation notes**

- The lesson has one real idea — *size is not one number* — and it appears three times: exercises
  17–18 (hidden contents), 20–21 (sparse), 22 (block granularity). If a student gets 20 on their own,
  go faster on 21 and 22. If they are stuck on 17, slow everything down; 17 is the one the chapter
  finale needs.
- Exercise 17's answer is a callback to `02/02`, not new material. Ask what they learned there before
  offering anything about `du`.
- `tree`, `stat`, `file`, `du` and `df` all have long man pages with the answer in a table. For the
  Dig tier (27–30) the correct help is almost always "search that table", not a concept.
- If a student is producing right answers with no `man` in their history for the Dig exercises, ask
  where they found the flag. Guessing is fine; pretending to have read is what the rubric catches.

---

### Exercise 1
- **L1 question:** Which command draws a directory as a picture rather than a list?
- **L2 locate:** Notes, "`tree` — the shape of a directory".
- **L3 concept:** The last line is part of the output, not decoration.
- **L4 decompose:** (1) run it on `bays`; (2) read the last line; (3) report both numbers.
- **L5 near-miss:** If they report only directories, ask what the second number is.
- **Never say:** `tree bays`.

### Exercise 2
- **L1 question:** `ls -l` gives you five or six facts. What gives you all of them?
- **L2 locate:** Notes, "`stat` — everything the filesystem records".
- **L3 concept:** Every field you need is labelled in the default output; no flags required yet.
- **L4 decompose:** (1) run it; (2) find `Size:`; (3) find `Inode:`; (4) find the type at the end of
  the same line as `IO Block`.
- **L5 near-miss:** If they report blocks as the size, point at the two adjacent labels.
- **Never say:** `stat`.

### Exercise 3
- **L1 question:** The name tells you nothing. What reads the contents instead?
- **L2 locate:** Notes, "`file` — what something actually is".
- **L3 concept:** The first bytes of a compiled program are a fixed signature, the same way a PNG
  always starts with the same bytes.
- **L4 decompose:** (1) run it; (2) report the first two words of the answer.
- **L5 near-miss:** If the output overwhelms them, ask only what kind of thing it is.
- **Never say:** `file`, `ELF`.

### Exercise 4
- **L1 question:** Which of `du` and `df` walks a directory and adds it up?
- **L2 locate:** Notes, "`du` and `df`".
- **L3 concept:** By default `du` prints a line per subdirectory. You want one number.
- **L4 decompose:** (1) run `du` on it plainly; (2) notice how many lines you got; (3) find the flag
  that summarises, and the flag that scales the units.
- **L5 near-miss:** If they read the first line of an unsummarised run, ask which line is the total.
- **Never say:** `du -sh`.

### Exercise 5
- **L1 question:** What did `tree` leave out, and what did you learn in `02/02` about names starting
  with a dot?
- **L2 locate:** Notes, the `tree` flag table, first row.
- **L3 concept:** The flag adds hidden *directories* too, and a hidden directory brings its whole
  contents with it — which is why the file count can jump by more than one.
- **L4 decompose:** (1) run with the flag; (2) diff the two last lines; (3) list what is new.
- **L5 near-miss:** If they name only the dot-directory, ask what is inside it.
- **Never say:** `-a`, `.calibration`.

### Exercise 6
- **L1 question:** Two separate restrictions: what to show, and how deep to go. Which flags?
- **L2 locate:** Notes, the `tree` flag table.
- **L3 concept:** The depth flag takes a number as its argument; the type flag does not.
- **L4 decompose:** (1) get directories-only working; (2) add the depth limit; (3) check the count.
- **L5 near-miss:** If they pass the number to the wrong flag, the error message names the flag.
- **Never say:** `-d -L 2`.

### Exercise 7
- **L1 question:** If you wanted to copy a line of `tree` output and paste it into a `cd`, what is
  missing from it?
- **L2 locate:** Notes, the `tree` flag table.
- **L3 concept:** The default output is drawn for a human reading it top-down; the alternative is
  drawn for something that will consume one line at a time.
- **L4 decompose:** (1) find the flag; (2) run it; (3) name a use for the output.
- **L5 near-miss:** If they say "it looks worse", agree — and ask who else reads output.
- **Never say:** `-f`.

### Exercise 8
- **L1 question:** Which lesson in this chapter changed a file's mode, and which file?
- **L2 locate:** `stamps/` — and the notes' `tree` flag table for the permissions flag.
- **L3 concept:** `tree` can prefix each line with the same bits `ls -l` puts in its first column.
- **L4 decompose:** (1) find the flag; (2) run it on the lab, not just `bays`; (3) find the odd one.
- **L5 near-miss:** If they only ran it on `bays`, note that nothing in `bays` was chmodded.
- **Never say:** `-p`, `chmodded.txt`.

### Exercise 9
- **L1 question:** Which of the three timestamps moves when you *read* a file, and which when you
  *write* one?
- **L2 locate:** Notes, the three-timestamp table.
- **L3 concept:** `stat`'s labels are `Access`, `Modify`, `Change` — not `atime`, `mtime`, `ctime`.
  Mapping those two vocabularies is most of this exercise.
- **L4 decompose:** (1) stat all three files; (2) build a small table; (3) read down each column.
- **L5 near-miss:** If they conflate `Change` with `Modify`, ask what "change" could mean other than
  contents.
- **Never say:** which file wins which column.

### Exercise 10
- **L1 question:** Which of the three timestamps can a command set to any value you like, and which
  cannot?
- **L2 locate:** Notes, the callout under the timestamp table.
- **L3 concept:** Backdating a file is itself a modification of the inode, and the inode records when
  it was last modified. The act of hiding leaves a mark.
- **L4 decompose:** (1) say which dates were set by the setup script; (2) say which one it could not
  set; (3) say which you would present as evidence.
- **L5 near-miss:** If they say "both are equally reliable", ask which one an attacker controls.
- **Never say:** "touch cannot set ctime".

### Exercise 11
- **L1 question:** `ls -l` picks one of three timestamps. Is there a flag that picks a different one?
- **L2 locate:** Notes, the two consequences under the timestamp table. `man ls`, search for `-u`.
- **L3 concept:** The flag does not add a column — it changes which timestamp the existing column
  shows. Easy to misread as "nothing happened".
- **L4 decompose:** (1) plain `ls -l`; (2) find the atime flag; (3) find the ctime flag; (4) compare.
- **L5 near-miss:** If two of the three outputs look identical, check whether they actually are —
  read the years.
- **Never say:** `-lu`, `-lc`.

### Exercise 12
- **L1 question:** `stat`'s default output is twelve lines. Is there a way to ask for exactly the
  fields you want?
- **L2 locate:** Notes, the `stat -c` example and the `%` table. `man stat`, the FORMAT section.
- **L3 concept:** A format string is a template with placeholders — the same idea as a fill-in-the-
  blanks sentence, where each blank names a field.
- **L4 decompose:** (1) get one field working on one file; (2) add the other two; (3) pass all the
  files at once.
- **L5 near-miss:** If they get permissions as `-rw-r--r--` when octal was asked for, there are two
  different placeholders — one upper case, one lower.
- **Never say:** `stat -c '%n %s %a'`.

### Exercise 13
- **L1 question:** What fields does the filesystem store about a file? Is "what kind of data is in
  it" one of them?
- **L2 locate:** Exercise 2's output — read every label and ask which one could hold "this is text".
- **L3 concept:** The inode stores size, owner, mode, times and where the blocks are. Content type
  is absent by design: the filesystem stores bytes and refuses to have an opinion about them.
- **L4 decompose:** (1) stat both; (2) `file` both; (3) say which of the two tools opened the file.
- **L5 near-miss:** If they say the filesystem "should" record the type, ask what would happen the
  day someone invents a new format.
- **Never say:** "the inode has no type field for content".

### Exercise 14
- **L1 question:** Which files are named as one thing and reported as another?
- **L2 locate:** Notes, the `file` worked example.
- **L3 concept:** Run it over the whole directory at once and read down the right-hand column
  looking for a mismatch with the left.
- **L4 decompose:** (1) run `file` on everything; (2) for each line, ask "does the extension predict
  this?"; (3) name the two.
- **L5 near-miss:** If they find one, ask them to check the `.txt` files specifically.
- **Never say:** `telemetry.txt`, `readme.txt`.

### Exercise 15
- **L1 question:** By default, is `file` describing the link or the thing at the other end?
- **L2 locate:** Notes, the `file` behaviours list. `man file`, search for `-L`.
- **L3 concept:** Every tool that meets a symlink chooses: describe the signpost, or walk to where it
  points. Following a signpost to nowhere is an error; describing one is not.
- **L4 decompose:** (1) run it plainly; (2) run it following the link; (3) quote the error exactly.
- **L5 near-miss:** If they call the error a bug, ask what `file` was asked to open.
- **Never say:** the error text.

### Exercise 16
- **L1 question:** Where did you last see a file that reports as empty and is not?
- **L2 locate:** `02/04`, exercise 17.
- **L3 concept:** `file` asks the same question `ls -l` asks before deciding there is nothing to
  read. Anything whose contents are generated at read time defeats both.
- **L4 decompose:** (1) find the empty one in `manifest`; (2) recall the size-zero surprise; (3) run
  `file` on that path to confirm.
- **L5 near-miss:** If they hunt the filesystem at random, point them at last lesson.
- **Never say:** `/proc/cpuinfo`.

### Exercise 17
- **L1 question:** `du` walked into that directory and found forty megabytes. Why did `ls` not show
  you what `du` found?
- **L2 locate:** `02/02`, the first exercise about hidden entries.
- **L3 concept:** `ls` shows what it was asked to show. `du` was never told to skip anything.
- **L4 decompose:** (1) list it again showing everything; (2) descend; (3) report.
- **L5 near-miss:** If they conclude `du` is wrong, ask them to prove it by finding a directory `du`
  overcounted.
- **Never say:** `ls -a`, `.staging`.

### Exercise 18
- **L1 question:** Now that you can see inside, which single file accounts for essentially all of it?
- **L2 locate:** Exercise 17's listing.
- **L3 concept:** `du` will do the arithmetic for you if you ask it to report files, not just
  directories.
- **L4 decompose:** (1) descend; (2) `ls -l` or `du` per file; (3) report the full path.
- **L5 near-miss:** If they report the directory, re-read the exercise: it asks for the file.
- **Never say:** the filename.

### Exercise 19
- **L1 question:** You want one line per top-level directory. What is the default `du` doing
  differently?
- **L2 locate:** Notes, the `du` flag list — the depth flag.
- **L3 concept:** Depth-limiting sums everything below the cut and reports it at the cut, so nothing
  is lost, only collapsed.
- **L4 decompose:** (1) run plain `du` and see the volume; (2) add the depth limit; (3) add human
  units.
- **L5 near-miss:** If they use `-s` on each directory by hand, accept it — then show them the flag
  exists.
- **Never say:** `du -h -d 1`.

### Exercise 20
- **L1 question:** `ls` reports one thing about size and `du` reports another. What are the two
  different things?
- **L2 locate:** Notes, "The size that is a lie".
- **L3 concept:** One number is where the end of the file is. The other is how much storage was
  actually handed out. Nothing requires them to match.
- **L4 decompose:** (1) both commands; (2) `stat` the file; (3) find the two adjacent fields on
  `stat`'s second line.
- **L5 near-miss:** If they say the file is corrupt, ask them to read the first megabyte of it.
- **Never say:** `Size` / `Blocks`, or "sparse".
- **Load-bearing.**

### Exercise 21 — Experiment
- **L1 question:** Before running anything: which of these five commands do you expect to agree with
  each other, and why?
- **L2 locate:** Notes, the `du` flag list.
- **L3 concept:** The apparent-size mode asks "how many bytes would I read"; the default asks "how
  much space would I free by deleting this". For an ordinary file both give the same answer, which is
  why most people never notice there are two questions.
- **L4 decompose:** (1) write predictions for all five; (2) run them; (3) mark which predictions were
  wrong; (4) answer the USB-stick question.
- **L5 near-miss:** If they answer the USB question with the apparent size, ask what the USB stick
  actually has to store — and whether copying preserves sparseness.
- **Never say:** which mode to use for the USB stick.
- **No prediction ⇒ PASS-WITH-NOTES cap.**

### Exercise 22 — Experiment
- **L1 question:** What is the smallest amount of storage a filesystem is willing to hand out?
- **L2 locate:** Notes, the paragraph after "The size that is a lie". `stat`'s `IO Block` field.
- **L3 concept:** Storage is sold in fixed lots. A 23-byte file and a 3000-byte file cost the same,
  the way a parking space costs the same for a motorbike as for a car.
- **L4 decompose:** (1) predict; (2) check four small files; (3) multiply by a million.
- **L5 near-miss:** If they say "the file is padded with spaces", ask them to `wc -c` it.
- **Never say:** "4 KB block".
- **No prediction ⇒ PASS-WITH-NOTES cap.**

### Exercise 23
- **L1 question:** What would happen to a program that walked into `loop` and kept going?
- **L2 locate:** Notes, the symlinks-and-loops callout.
- **L3 concept:** Following the link puts you above the directory you started in, which contains the
  link, which you would follow again. Something has to notice.
- **L4 decompose:** (1) predict both; (2) run both; (3) copy the marker exactly, brackets included.
- **L5 near-miss:** If the second run prints a huge tree, that is expected — the marker is in it.
- **Never say:** the marker text.

### Exercise 24
- **L1 question:** `df` takes a path. What does it tell you about the path you give it?
- **L2 locate:** Notes, the `df` flag list.
- **L3 concept:** `df` reports the filesystem *containing* the path, not the path. Two paths on one
  machine can land on completely different storage.
- **L4 decompose:** (1) `df` on `/labs`; (2) `df` on `/`; (3) add the type flag; (4) say which one
  holds your work.
- **L5 near-miss:** If they say both are the same because both say 358G, look at the Filesystem
  column and the Type column.
- **Never say:** "`/labs` is a volume, so it survives".

### Exercise 25
- **L1 question:** A filesystem can run out of two different things. Blocks is one. What is the other?
- **L2 locate:** Notes, the `df` flag list, third entry. `man df`.
- **L3 concept:** Each file needs a record of its own, and there is a fixed supply of those records,
  fixed when the filesystem was created.
- **L4 decompose:** (1) find the flag; (2) run it; (3) describe the failure it explains.
- **L5 near-miss:** If they describe it as "the disk is full", be precise: `df` would show free
  space, and creation would still fail.
- **Never say:** `df -i`, "inodes".

### Exercise 26
- **L1 question:** What is a directory's link count counting, if the directory is empty?
- **L2 locate:** `stat`'s `Links:` field; `02/01`'s work on `.` and `..`.
- **L3 concept:** A directory is referred to by name from its parent, and by `.` from inside itself.
  That is already two. Each subdirectory's `..` adds another.
- **L4 decompose:** (1) stat it; (2) read `Links:`; (3) enumerate what refers to it.
- **L5 near-miss:** If they say 2 is a bug, ask them to name the two references.
- **Never say:** "`.` and the parent entry".

### Exercise 27 — Dig
- **L1 question:** By default `tree -h` prints a directory's own size, which is always about the
  same. What would be more useful?
- **L2 locate:** `man tree`, search for `du`.
- **L3 concept:** It is a long option, spelled like the command whose behaviour it borrows.
- **L4 decompose:** (1) find it; (2) remember hidden entries and depth, or the totals are wrong;
  (3) read the two figures; (4) compare to exercise 20.
- **L5 near-miss:** If `ledger` reads 4.0K, they limited the depth or dropped `-a`.
- **Never say:** `--du`, or that it sums apparent sizes.

### Exercise 28 — Dig
- **L1 question:** Every `stat` you have run described a file. Could it describe the ground the file
  is standing on?
- **L2 locate:** `man stat`, the flag list — it is a single letter and it changes the whole output
  format.
- **L3 concept:** The alternative output has its own format placeholders and its own fields — block
  size, free blocks, name length limit, a type.
- **L4 decompose:** (1) find the flag; (2) run it on `/labs`; (3) read the block size; (4) read the
  type and compare with `df -T`.
- **L5 near-miss:** On the disagreement: one tool is naming a magic number it recognises, the other
  is reading a mount table. Ask which source could be out of date rather than wrong.
- **Never say:** `stat -f`, or which one to trust.

### Exercise 29 — Dig
- **L1 question:** You gave `du` three arguments and got three answers. How do you also get their sum?
- **L2 locate:** `man du`, search for `total`.
- **L3 concept:** The same letter does the same job in several tools that print lists of numbers.
- **L4 decompose:** (1) find it; (2) combine with the summarise and human flags; (3) read the last
  line.
- **L5 near-miss:** If they add the three numbers by hand, that is the right total and the wrong
  exercise — the flag exists.
- **Never say:** `-c`.

### Exercise 30 — Dig
- **L1 question:** "Bourne-Again shell script, ASCII text executable" is a sentence. What would a
  program want instead?
- **L2 locate:** `man file`, search for `mime`.
- **L3 concept:** A short fixed vocabulary of `type/subtype` strings, the same ones a web server
  sends. Easy to compare; impossible to write a paragraph in.
- **L4 decompose:** (1) find the flag; (2) run it on the three files; (3) say why a program prefers
  it.
- **L5 near-miss:** If they say "it is shorter", push: what property makes it *safe* to compare?
- **Never say:** `file -i`.
