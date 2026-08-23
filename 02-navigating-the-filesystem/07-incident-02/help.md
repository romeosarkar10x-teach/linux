# 02/07 — Tutor hint ladder

**Tutor rules.** Never state the directory's name. Never state the flag. Never type the escape
sequence `\302\240` or the words "no-break space" before the student has produced the byte dump
themselves — exercise 10 is the whole incident and giving it away ends the lesson. Steer to the
command that reveals it, never to the answer.

**Arc discipline.** `audit-notes.txt` is unattributed on purpose. If the student asks who wrote it,
the honest answer is that the file does not say and nothing in this chapter establishes it. Do not
supply a name. Do not confirm or deny a guess. "What in the file tells you that?" is the reply.

---

### Exercise 1
- **L1 question:** Did `ls` fail, or did it succeed and print nothing? How would you tell those apart?
- **L2 locate:** Notes, "The two numbers". `echo $?` after the command.
- **L3 concept:** `wc -l < /dev/null` prints `0` and exits 0. Empty output is a result, not an error.
- **L4 decompose:** run `ls maintenance`; run `echo $?`; run `du -sh maintenance`; write both down.
- **L5 near-miss:** if they say "ls is broken", ask what exit status a broken `ls` would give.
- **Never say:** that the directory has hidden entries.

### Exercise 2
- **L1 question:** `du` recursed and gave you one total. What option controls how deep it reports?
- **L2 locate:** `man du`, search `depth`.
- **L3 concept:** On some other tree, `du -h -d 1 /usr` attributes the total to `/usr/lib`, `/usr/share`… rather than printing one line.
- **L4 decompose:** find the depth option; combine with `-h`; run on `maintenance`.
- **L5 near-miss:** if they used `-a` and got a wall of output, point at depth rather than at everything.
- **Never say:** the name that appears in the output.

### Exercise 3
- **L1 question:** Which `ls` option changes *what it is willing to show*, not how it is formatted?
- **L2 locate:** Chapter 2 lesson 2, "showing everything"; `man ls`, `-a` and `-A`.
- **L3 concept:** `ls -a ~` on your home directory prints far more than `ls ~` does, and none of it is new — it was always there.
- **L4 decompose:** `ls -a maintenance`; count lines; subtract the two entries that are in every directory.
- **L5 near-miss:** if they get 4 and say "4 things in there", ask what `.` and `..` are.
- **Never say:** which of the entries is the interesting one.

### Exercise 4
- **L1 question:** You have two candidate names and one 40M figure. What did exercise 2 already tell you?
- **L2 locate:** their own exercise 2 output.
- **L3 concept:** `du -h -d 1` prints one line per child; the child that carries the bytes is the one whose line carries the number.
- **L4 decompose:** re-read the exercise 2 output; match each line to a name from exercise 3.
- **L5 near-miss:** if they guess by name plausibility, ask which command they would defend that with.
- **Never say:** the answer.

### Exercise 5
- **L1 question:** How were you fooled the first time? What would fool you the same way again?
- **L2 locate:** exercise 3's technique.
- **L3 concept:** proving a directory empty needs a listing that hides nothing — the same flag that broke the illusion the first time.
- **L4 decompose:** list `.cache` including hidden entries; also `du -sh .cache` — a directory holding something is rarely exactly one block.
- **L5 near-miss:** if they run plain `ls .cache` and declare it empty, ask why that evidence is now worthless.
- **Never say:** that `.cache` is a decoy.

### Exercise 6
- **L1 question:** What is in it, and how big is it? Two commands, no theory.
- **L2 locate:** `ls -l overnight`, `du -sh overnight`, `cat` one file.
- **L3 concept:** an item is relevant to a size discrepancy if it carries size. 24K is not 40M.
- **L4 decompose:** size it; read one file; state relevance.
- **L5 near-miss:** if they build a theory from the log text, ask what number would have to be true for it to matter.
- **Never say:** "it is a red herring" — make them size it.

### Exercise 7
- **L1 question:** What exactly did you type, and what exactly did the shell say back?
- **L2 locate:** Chapter 2 lesson 6, "names that resist typing".
- **L3 concept:** `cd "deck 3 bay 2"` fails with `No such file or directory` when the real name is `deck 3  bay 2` — two spaces. The error does not tell you which character was wrong; it only tells you the string you built is not a name that exists.
- **L4 decompose:** attempt it; record the error; then reach for completion instead of typing.
- **L5 near-miss:** if they are hammering quotes, tell them the quoting is fine and the *string* is not — do not say why.
- **Never say:** which character is wrong.

### Exercise 8
- **L1 question:** Which flag shows entries a plain listing omits? You used it in exercise 3.
- **L2 locate:** `ls -la`.
- **L3 concept:** two of the three files here are content and one is a marker; all three appear only under a listing that hides nothing.
- **L4 decompose:** `pwd`; `ls -la`; write the three names.
- **L5 near-miss:** if they list two files, ask what they used and whether it hides dotfiles.
- **Never say:** the file names.

### Exercise 9
- **L1 question:** Which of the three files could plausibly be 40M, and what command gives you an exact byte count?
- **L2 locate:** `ls -l`, `stat -c %s`, `file`.
- **L3 concept:** `file` reads content, not the extension: a `.txt` can be reported as `gzip compressed data`.
- **L4 decompose:** size all three; run `file` on the big one; then write the one-sentence link between `du` and `ls -a`.
- **L5 near-miss:** if the sentence says "du was wrong", ask which byte `du` counted that was not really there.
- **Never say:** that the file is filler.

### Exercise 10
- **L1 question:** Your terminal prints the name. Your keyboard cannot produce it. What does that imply about the bytes?
- **L2 locate:** Chapter 2 lesson 6, the load-bearing technique; `man ls` for `-b`; and why the locale mattered there.
- **L3 concept:** in `C.UTF-8`, `ls -b` leaves non-ASCII bytes alone; forcing the C locale for the command makes them print as octal escapes. Try it on a name you build yourself in `/tmp` if you want to see it work first.
- **L4 decompose:** list the parent with byte escaping under `LC_ALL=C`; read the escapes; count how many are not plain spaces.
- **L5 near-miss:** if they run `ls -b` and see nothing unusual, point at the locale — that is exactly what lesson 6 was for.
- **Never say:** the escape value, or the name of the character.

### Exercise 11
- **L1 question:** Which `stat` format specifier prints the name *quoted*?
- **L2 locate:** `man stat`, the `%N` line.
- **L3 concept:** quoting protects the shell from a name. It does not protect a human from it — a character that prints as blank stays blank inside the quotes.
- **L4 decompose:** `stat -c %N` on the directory; compare with the exercise 10 escapes; state what is present in one and invisible in the other.
- **L5 near-miss:** if they claim `%N` shows everything, ask them to count the characters between two specific words in each output.
- **Never say:** which character survives invisibly.

### Exercise 12
- **L1 question:** Prediction written down? Nothing runs until it is.
- **L2 locate:** their own exercise 7 and 10 notes.
- **L3 concept:** a glob is expanded by the shell against what is on disk, so it never has to be typed correctly — it only has to match. Completion is the same trick with a different interface.
- **L4 decompose:** try each of the four in order; record success or the exact error.
- **L5 near-miss:** if a prediction was wrong, ask what they had assumed the shell does with the characters between the quotes.
- **Never say:** which of the four work — that is the experiment.

### Exercise 13
- **L1 question:** What is the documented difference between `-a` and `-A`?
- **L2 locate:** `man ls`; `man tree` for its `-a`.
- **L3 concept:** on any directory, `ls -a` and `ls -A` differ by exactly two lines, always the same two.
- **L4 decompose:** predict; run all four commands; explain the counts.
- **L5 near-miss:** if the tree counts confuse them, ask which entries `tree` was allowed to see in each run.
- **Never say:** the counts.

### Exercise 14
- **L1 question:** Which two `du` options let you swap `M` for bytes, and disk usage for apparent size?
- **L2 locate:** `man du` — the block size option and `--apparent-size`.
- **L3 concept:** a filesystem hands out whole blocks. A 10-byte file occupies 4096. Directories occupy blocks too — and `du --apparent-size` does not report them the way you might expect.
- **L4 decompose:** get both totals in bytes; subtract; then enumerate everything in the tree that could round up, and check whether the arithmetic closes.
- **L5 near-miss:** if they are short by a few kilobytes, ask how many directories are in the tree and what each costs.
- **Never say:** the difference or its breakdown.

### Exercise 15
- **L1 question:** What is the file's size, and could a file that size be the 40M?
- **L2 locate:** their exercise 9 numbers.
- **L3 concept:** a document can be significant and irrelevant to the metric at the same time; the incident cass reported is a number, not a story.
- **L4 decompose:** read it; state the size; answer the metric question; keep the two separate.
- **L5 near-miss:** if they attribute the notes to a crew member, ask which line of the file says so.
- **Never say:** who wrote it. Nothing in Chapter 2 establishes that.

### Exercise 16
- **L1 question:** Which timestamp is "modification", and which `ls` or `stat` invocation shows it in full?
- **L2 locate:** Chapter 2 lesson 5, the timestamp exercises; `stat -c %y`.
- **L3 concept:** an mtime is a number a file carries. It records when content last changed — not when the file was created, and not that it was honest.
- **L4 decompose:** print both mtimes; state the gap; then write the "does not let you conclude" half, which is the graded half.
- **L5 near-miss:** if they conclude someone hid the file on that date, ask what else can set an mtime.
- **Never say:** any interpretation of the date.

### Exercise 17
- **L1 question:** Do you know the option for one-entry-per-line? For inode numbers?
- **L2 locate:** `man ls`, `-1` and `-i`.
- **L3 concept:** an inode number identifies a file within a filesystem; two names with the same inode are one file, two different inodes are two files no matter how similar the names look.
- **L4 decompose:** combine both options with the one that shows hidden entries; read the two numbers.
- **L5 near-miss:** if they say the numbers prove the directories are related, ask what equal inodes would have meant instead.
- **Never say:** the inode values.

### Exercise 18
- **L1 question:** What makes `du` report files as well as directories?
- **L2 locate:** `man du`, `-a`, and the bytes option you found in exercise 14.
- **L3 concept:** `du -ab /etc/hostname` prints that one file's byte count; on a tree it prints every file, then the totals.
- **L4 decompose:** combine the two options; run on `maintenance`; identify the single line carrying the bulk.
- **L5 near-miss:** if the output scrolls, ask how many files the tree actually has — it is three.
- **Never say:** the byte count.

### Exercise 19
- **L1 question:** What exactly is the directory's name, byte for byte? You established that in exercise 10.
- **L2 locate:** their own exercise 10 output.
- **L3 concept:** "each run of whitespace becomes one underscore" includes whitespace that prints as nothing. If your byte dump has an escape in it, that escape is whitespace and it counts.
- **L4 decompose:** write the name out from the escapes; drop the leading dot; lowercase; substitute; drop a trailing underscore; wrap and submit.
- **L5 near-miss:** if `kestrel flags submit` rejects it, ask how many underscores they have and how many whitespace runs the byte dump showed. Do not count for them.
- **Never say:** the flag, any part of it, or the number of underscores.

### Exercise 20
- **L1 question:** Which of the four sentences are you least sure of? Write that one first.
- **L2 locate:** their own logs from exercises 1, 9, 10.
- **L3 concept:** a good debrief names the mechanism, not the mood: "`ls` omits entries beginning with `.` unless asked" is a finding; "the file was sneaky" is not.
- **L4 decompose:** one sentence per bullet, then the sentence for cass.
- **L5 near-miss:** if the cass sentence blames someone, ask what evidence in the lab identifies a person.
- **Never say:** who is responsible. The lab does not establish that and neither does the chapter.

---

## Escalation notes

- The single hardest step is exercise 10, and the whole incident routes through it. A student stuck
  there is stuck on the locale, not on `ls`. Rung 3 is the place to say so.
- Exercise 7 will produce frustration. It is meant to. Confirm that their quoting is correct as
  soon as it is — the lesson is that correct quoting of a wrong string still fails.
- If a student solves the flag by tab-completing into the directory without ever running the byte
  dump, they got in but did not solve it: they will fail exercise 19's substitution. Send them
  back to 10 rather than debugging their flag string.
- Do not let the notes file become the story. It is trace material and it is not the answer to
  cass's question.
