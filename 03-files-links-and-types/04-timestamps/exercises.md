# 03/04 — Exercises: Timestamps

Lab: `/labs/03-files-links-and-types/04-timestamps`. Get there with `cd` before you start.

Reset any time with `kestrel reset 03/04` — it wipes the tree and re-seeds it. Several exercises
below deliberately change timestamps, so resetting between sections is normal, not a failure.

If you are stuck, read `help.md`. It asks you questions; it does not hand you commands.

---

**Ahead of the syllabus.** This lesson uses `cp`, `mv` (Chapter 4), `find -newer` and `grep`
(Chapter 6), `chmod` (Chapter 10) before the chapters that teach them. Use them exactly as written
here; you are not expected to know them yet.

## Warmup

**1.** Run `stat logs/strain-2187-05-22.csv`. Four time lines come out. Write down, in your own
words, what each of the four is measuring. Do not look anything up yet — guess, then keep the guess.

**2.** The word `Access` appears twice in that output and means two different things. What are they?

**3.** `ls -l logs`. Which of the four times is this column showing? Which three are invisible here?

**4.** `ls -l logs` shows a year for these files instead of a time of day. Run
`ls -l --full-time logs`. What has `ls -l` been hiding, and why do you think it hides it?

---

## Core

**5.** Sort `logs/` by mtime, newest first. Which file is newest?

**6.** Reverse the sort so the oldest is first. Which file is oldest?

**7.** `logs/strain-summary` claims to summarise all six `strain-2187-05-*.csv` files. Where does it
land in the `ls -lt` ordering, and what does that position tell you about whether the claim can be
true?

**8.** Name every file in `logs/` whose contents are newer than `strain-summary`, using `find` and a
comparison against `strain-summary` itself rather than typing any date.

**9.** Print just the mtime of `logs/strain-2187-05-21.csv` — that line and nothing else — using
`stat` with a format string.

**10.** Print the same mtime as seconds since the epoch. What number do you get?

**11.** Print, one file per line, the name and mtime of every file in `logs/`, in a single `stat`
command with no loop.

**12.** Every `strain-2187-05-*.csv` file was written by the same nightly job, and five of the six
mtimes show it. Print all six times of day and name the file that does not fit the pattern.

**13.** `stat -c %z` and `stat -c %y` on `logs/strain-2187-05-19.csv`. They are more than a century
apart. Explain in one sentence why that is not a bug.

**14.** Every file in `logs/` has the same ctime, to within a second or two. What single event does
that ctime record?

**15.** Read `reads/warm.txt` with `cat`. Then check its atime. Read it again and check again. Did
the atime move?

**16.** Do the same with `reads/cold.txt`, twice, checking atime after each read. Did that one move?

**17.** The two files behaved differently. Compare each file's atime with its mtime *before* the
reads (reset first if you have already disturbed them). What relationship holds for one file and not
the other?

**18.** `grep /labs /proc/mounts`. One mount option in that line explains exercises 15–17. Which
one, and what rule does it implement?

**19.** Sort `reads/` by atime rather than mtime. Which file is on top, and is that the same order
`ls -lt` gives?

**20.** `meta/panel-07.txt` and `meta/panel-07-alias` — confirm with `stat` that they are one inode
with two names.

**21.** `touch -d '2100-01-01 00:00' meta/panel-07-alias`. Now check the mtime of
`meta/panel-07.txt`. Explain the result using what Chapter 3 lesson 02 taught you about where
metadata lives.

**22.** Reset. Note `meta/moved.txt`'s three times. Run `chmod 640 meta/moved.txt`. Which of the
three moved?

**23.** Now `mv meta/moved.txt meta/renamed.txt` and check again. Which times moved this time? The
file's contents were never touched in either exercise — why did anything change at all?

**24.** Try to set the ctime of `meta/renamed.txt` to `2187-05-01`. Read `man touch` first. What do
you conclude?

**25.** `meta/panel-07.txt` has an mtime in 2187 and a ctime from today. State two *different*
plausible histories that would produce that pairing.

**26.** Reset. `cp copies/source.csv copies/plain.csv`. Compare the two files' mtimes. Which one is
"correct" for the data inside `plain.csv`?

**27.** `cp -p copies/source.csv copies/kept.csv`. Compare mtimes again.

**28.** Compare the ctimes of `source.csv`, `plain.csv` and `kept.csv`. `-p` preserved mtime — why
could it not preserve ctime?

**29.** `ls -l copies` after both copies. Something other than the timestamp differs between
`plain.csv` and `kept.csv`. What, and why?

**30.** You have a directory restored from backup with plain `cp`. Explain in two sentences why
`ls -lt` on it is worthless and what you would use instead.

**31.** Give `refs/one.txt` exactly the same mtime as `refs/anchor.txt` without typing a date
anywhere in the command.

**32.** Do the same for `two.txt` and `three.txt` in one command.

**33.** `stat -c '%n %y' refs/*.txt` to prove all four now match. Do their atimes match too? Should
they?

**34.** Note `stamps/bay-2`'s mtime. Append a line to `stamps/bay-2/torque.txt`. Check the
directory's mtime again. Did it move?

**35.** Now create `stamps/bay-2/new.txt`. Check the directory's mtime. Did it move this time?

**36.** Delete `stamps/bay-2/new.txt` and check once more.

**37.** State in one sentence what a directory's mtime actually measures.

**38.** `stat birth/first.txt`. Its Birth and Modify are the same. Why?

**39.** `stat refs/anchor.txt` — its Birth and Modify are decades apart. Which of the two is telling
you the truth about when the file came into existence on this volume?

---

## Experiment

Write your prediction down **before** you run anything. A prediction you revise after seeing the
output is not a prediction.

**40.** Predict: does `touch -c nosuch.txt` create `nosuch.txt`? Then run it and `ls`.

**41.** `reads/` has a symlink you will make yourself: `ln -s cold.txt reads/lnk`. Predict what
`touch -h -d '2187-01-01' reads/lnk` changes — the link's times, the target's, or both. Then check
with `stat reads/lnk` and `stat -L reads/lnk`.

**42.** Predict what `touch -d '2999-01-01' refs/three.txt` will report when you `stat` it
afterwards. Then run it. If the answer surprised you, work out what constrains it — the filesystem
type is in `/proc/mounts` and the field is fixed-width.

**43.** Predict which of atime, mtime and ctime move when you run `cat > refs/one.txt` and type a
line. Run it, check all three, and account for any you got wrong.

---

## Stretch

**44.** Write a one-liner that prints the name of the single most recently modified file anywhere
under the lab directory, without using `ls`.

**45.** Print every file under the lab whose mtime is newer than `logs/strain-summary` but older
than `refs/anchor.txt`, using `find` alone.

**46.** Produce a listing of `logs/` sorted by mtime, oldest first, showing the full timestamp with
no abbreviation, and nothing else on the line but the timestamp and the name.

**47.** Without using `touch -r`, copy `refs/anchor.txt`'s mtime onto a new file `refs/four.txt` —
read the timestamp with `stat`, feed it to `touch`. Then prove it worked to the second.

**48.** The station's present is 2187-06-14. Find every file in the lab whose mtime is later than
that date. Before you do, run the same search against `now` instead and explain why the container's
own clock makes that version of the question useless.

---

## Dig

**49.** `stat -c %y` reports nanoseconds. Create two files in a single `touch` command and compare
their mtimes at full precision. Are they identical to the nanosecond? What does that tell you about
how many timestamps `touch` actually took?

**50.** The `logs/` files all have ctimes from the moment the lab was seeded, but their mtimes are in
2187. Read `setup.sh` at `/course/03-files-links-and-types/04-timestamps/setup.sh` and find the
comment explaining why every `touch` in it comes *after* every `chmod` and `chown`. Would the lesson
still work if that order were reversed? Say precisely what would break.

**51.** atime is a hint, not a fact — `relatime` is why. Find the other mount options Linux offers
for atime handling (`man 8 mount`, search for `atime`). For each, say what a forensic investigator
would gain or lose.

**52.** There is a fourth timestamp. Run `stat -c '%w|%W|%x|%y|%z' <file>` on a file you have just
created and identify which field is the one you have not met. Then set that file's mtime back to
2187 with `touch -d` and read all five fields again: say which of them moved and which did not, and
why the one that did not move is the only timestamp in this lesson that `touch` has no option for.

Then find the contradiction. Ask `find` to search on that timestamp — `find . -newerBt 2026-01-01` —
and quote what it says. Explain how `stat` can report a value that `find` says the system cannot
provide, and what that means for relying on it. Name the filesystem you are on (`stat -f -c %T .`)
in your answer.

*Done looks like:* the field named, the before/after comparison, both `find` errors quoted, and the
explanation.
