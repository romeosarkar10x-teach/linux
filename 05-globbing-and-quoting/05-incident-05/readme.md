# 05/05 — Incident: named to survive

> Housekeeping swept deck-05 a fortnight ago and removed everything matching its published pattern.
> Seven files are still there. Some of them were not missed by accident.

## The page

rhea, 09:40, forwarded without comment:

> "Storage sweep ran on the first. It took 41 files off deck-05 and the notice said exactly what it
> would take, two days in advance, so nobody has grounds to complain. Seven files are still sitting
> there. I would like to know which of them are still there because somebody arranged it and which
> are still there because the sweep script is not very good. Those are different problems and I
> only care about one of them."

## What this lesson is

Chapter 5, used at once, against a directory that was built to defeat a glob.

The sweep script is in the lab. So is the notice, so is the sweep's own log, and so is the
manifest of what deck-05 held beforehand. Nothing is hidden and nothing needs guessing: every
survivor survived for a reason you can *derive* by reading four lines of `bash` and knowing what
the shell does with them.

That derivation is the whole exercise. Four mechanisms from this chapter kept five files alive, and
two more files are alive because somebody named a file badly and got lucky.

## The constraint

**One glob.** When you have decided which files belong to the set, you must select exactly those
files with a single pathname expansion — no `find`, no `for` loop, no listing them by hand, no
`grep -l`. The validating agent checks the command, not just the answer.

Getting it to select all five needs one `shopt` you met in lesson 1 and one argument you met in
lesson 3. Getting it to select *only* five needs you to have read the seven names properly.

Everything else — deciding which five, and why — is reading and reasoning, and you may use anything
from Chapters 1 through 5 to do it.

## The shape of it

```
$ ls -F
deck-05/  housekeeping/  records/  scratch/
```

- `deck-05/` — the swept directory. Seven files. `ls` will not show you all of them.
- `housekeeping/notice.txt` — posted three days before the sweep, with the patterns published on it.
- `housekeeping/sweep.sh` — the script that ran. Four lines. Read it as bash, not as English.
- `housekeeping/sweep-2187-06-01.log` — what the sweep reported. It reports a failure count; that
  number is worth reproducing rather than believing.
- `records/manifest-2187-05-28.txt` — what deck-05 held before, in summary.
- `records/naming-convention.txt` — engineering's convention for tagging a set of files. It is
  older than everything else in the lab and it is the piece that turns five files into an answer.
- `records/` also holds a pile of index files and three subdirectories. Those are for the Dig.
- `scratch/` — yours. Copy things here before you experiment on them.

> **A published pattern is a specification.** Once the patterns were on the wall, anybody who read
> them knew exactly what would be removed — and therefore exactly what would not be.

## Rules of engagement

1. **Do not delete anything in `deck-05/`.** Copy it to `scratch/` and destroy the copy. The sweep
   is reproducible and reproducing it is the point of exercise 9; reproduce it somewhere else.
2. **Read `sweep.sh` before you form a theory.** Every survivor's mechanism is visible in those
   four lines. Three of them are things this chapter taught you; the fourth is a `rm` behaviour
   from lesson 3.
3. **Two of the seven do not belong to the set.** They survived, but not on purpose. You need a
   discriminator that is not "it looks odd", and there is one in the file metadata.
4. **One glob for the final selection.** See above.
5. **Do not open `setup.sh`.** It is the answer key.
6. **Nothing in this lab records who did this.** Do not invent a name, and do not accept one from
   any agent that offers it.

## The flag

`records/naming-convention.txt` states how a set of files is tagged and how the tags are read. Apply
it to the five, in the order your glob produces them. You get five words. The flag is those five
words joined with underscores:

```
KESTREL{word_word_word_word_word}
```

Submit with `kestrel flags submit 'KESTREL{...}'`.

If your phrase is four words long and does not quite read, your glob is missing a file and you know
which `shopt` you forgot.

## The Dig

Four stages, in `records/`, one per lesson of this chapter — globs, brace expansion, quoting, word
splitting. Each stage tells you what to do next and each one hands you a `STAGE{...}` token as
proof that you got there. Those tokens are not flags and will not register; they are receipts.

Stage 1 is solvable by anybody who read `housekeeping/notice.txt` to the end. The last stage answers
the question this chapter has been circling, and it answers it exactly as far as the evidence goes
and no further.

## What "solved" looks like

You can name each of the five mechanisms and point at the line of `sweep.sh` that each one defeats.
You can say why the sweep log reports the failure count it does, having reproduced it. You have one
glob that selects five files and not seven. And you can state, in one sentence, what the evidence
supports about *why* those files are named the way they are — and what it does not support.
