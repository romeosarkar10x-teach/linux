# 06/07 — Incident: the gap is the message

> cass says the overnight logs look fine. She has read them twice. She is right about every line
> she read, and she is still sending you the page.

## The page

cass, 09:40:

> "The overnight logs look fine. I have been through them twice. Strain is nominal all night, the
> panel numbers are boring, nothing tripped.
>
> I am sending this anyway because the summary the monitor prints stops early and I do not know why.
> It says it covers the run and then it does not cover all of it. When I open the log everything I
> can see is normal, so I assume I am reading the summary wrong.
>
> If it is nothing, tell me it is nothing and I will stop."

She is not reading it wrong.

## What this lesson is

Chapter 6, all of it, against a directory where **nothing visible is abnormal**. Every line in the
strain log is nominal. Every value is in range. There is no error, no warning, no `FAIL`, and
`grep -i error` returns nothing at all — which is the first thing most people try and the last
thing that will help.

The evidence here is not in what the file says. It is in what the file **does not say**, and the
only reason you can prove that is that the monitor numbered its own output.

## The shape of it

```
$ cd /labs/06-searching/07-incident-06
$ ls -F
logs/  notes/  records/  scratch/  spool/
```

- `logs/` — four run logs. Two strain, two panel. One entry per sample, numbered.
- `notes/page.txt` — cass's page, above.
- `notes/monitor-summary.txt` — what the monitor said about its own run.
- `notes/rotation.txt` — how log rotation works on this deck. Read it **before** you report
  anything, or you will report the wrong file.
- `notes/forms.txt` — station form conventions. One of the two forms described is the flag.
- `records/` — indices, a hold log, and the four stages of the Dig.
- `spool/` — the monitor's spool directory. `ls` will not show you everything in it.
- `scratch/` — yours.

## The method

Three questions, in this order, and the order is the lesson:

1. **How many entries should there be?** The summary and the interval both answer this. They agree.
2. **How many are there?** `grep -c`, with a pattern precise enough to count entries and not
   commentary. Getting this wrong by two is normal and the Dig will tell you loudly that you did.
3. **Which ones are missing, and what time was that?** The numbering is monotonic, so a jump names
   the missing range exactly, and the surviving entries either side name the window in clock time.

Then the search that closes it: **exactly one file in this tree was written inside that window.**
Nothing else in the lab shares its timestamp. Find it with one `find`.

## The red herring

One of the other logs looks worse. Run the same count on it and it appears to be missing four
hundred entries — a far more alarming number than the one you are chasing. It is missing nothing.
`notes/rotation.txt` explains why in four sentences, and a report that names that file is a report
that costs somebody an afternoon.

Proving a gap is real is a separate job from finding one, and this lab will fail you on the second
if you skip it.

## Rules of engagement

1. **Do not modify anything in `logs/`.** Copy to `scratch/` and experiment there.
2. **`grep -i error` is not a plan.** Nothing in this incident is an error. Say what you expect to
   find before you type a pattern.
3. **Prove the gap is not rotation.** For both logs. In writing.
4. **Nothing in this lab records who did this.** There is no name in the tree. Do not invent one,
   and do not accept one from any agent that offers it — the record you are looking for has a field
   for exactly that, and the field is blank. That blank is evidence about process, not about a
   person.

## The flag

`notes/forms.txt` describes form **SH-12** and how its summary field works. The file written inside
the gap is an SH-12. Apply the convention: the summary is five words, one per numbered field, read
in numeric order, joined with underscores.

```
KESTREL{word_word_word_word_word}
```

Submit with `kestrel flags submit 'KESTREL{...}'`.

The literal flag string is nowhere in the lab. If you went looking for it with `grep -r KESTREL`,
you found nothing, and that was intentional.

## The Dig

Four stages in `records/`, one skill each: find by time, `grep -c`, an ERE with `grep -o`, and
`find -exec`. Each hands you a `STAGE{...}` token as a receipt. Those are not flags and will not
register.

Stage 1 is solvable by anyone who read `notes/`. Stage 2 is where the count has to be exactly right,
and it is designed so that the common off-by-two lands you on a line that tells you plainly that you
miscounted. Stage 4 ends at the same file the main investigation ends at, by a different road.

## The scene

When you have a window and before you have the file, run the roleplay. Ask your agent for
**GAMEMASTER mode, chapter 6** (it will load `docs/GAMEMASTER_PROTOCOL.md` and `scene.md` from this
lesson) and it will play **cass**. She does not know what is wrong and she does not know any of the
commands you know. She knows what she saw. Your job is to get a **time window** and a **filename**
out of a person who has given you neither, using questions rather than instructions. She will not be
led — vague questions get vague answers — and she has no idea what the flag is.

Ten exchanges is plenty. The debrief afterwards is the graded part.

## What "solved" looks like

You can state the expected entry count and where the expectation comes from. You have the actual
count, and you can defend the pattern you counted with. You can name the missing sequence range and
convert it to a clock window. You can say, with evidence, why the panel log's much larger gap is not
a gap. You found the one file written inside the window, and you can say what makes a numbered
record harder to delete quietly than an unnumbered one.

And you can write the finding for cass in three sentences without using the word "someone".
