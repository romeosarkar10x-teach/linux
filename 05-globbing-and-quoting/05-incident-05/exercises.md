# 05/05 — Exercises: Incident, named to survive

Work in `/labs/05-globbing-and-quoting/05-incident-05`.

```
cd /labs/05-globbing-and-quoting/05-incident-05
ls -F
```

Chapters 1–5 tools. For the **final selection** in exercise 27 you are held to a single glob: no
`find`, no loop, no hand-typed list. Wrecked the lab? `kestrel reset 05/05`.

---

## Warmup — what is actually there

**1.** `ls deck-05`. How many files? Now `ls -A deck-05`. A different number. Which is right, and
what did `ls` decide for you without saying so?

**2.** `ls -Al deck-05`. Write down all seven names exactly, including the leading and trailing
characters. Two of them will not survive a copy-paste; note which and why.

**3.** `cat housekeeping/notice.txt`. What three patterns were published, and how many days'
warning was given?

**4.** `cat housekeeping/sweep-2187-06-01.log`. How many files did the sweep say it removed, and how
many failures did it report?

**5.** `cat records/manifest-2187-05-28.txt`. 48 entries before, 41 removed. Does 48 − 41 agree with
what is in `deck-05/` now?

## Core — reading the script as bash

**6.** `cat housekeeping/sweep.sh`. Write out, in English, what the four working lines do. Do not
skip the `for` line: say exactly what the shell hands to the loop.

**7.** The loop body is `rm -f $f` — unquoted. Name the two lessons in this chapter that tell you
that is a bug, and say what each one contributes.

**8.** `for f in *.log *.txt *.bak` with `dotglob` off. Which of the seven surviving names can this
list possibly contain? Answer before you run anything, then check with
`printf '[%s]\n' deck-05/*.log deck-05/*.txt deck-05/*.bak`.

**9.** Reproduce the sweep. Copy `deck-05/` into `scratch/`, add three ordinary files that *should*
be swept (`a.log`, `b.txt`, `c.bak`), and run the loop from `sweep.sh` by hand in the copy. Record
what is removed, what is left, and every error message.

**10.** How many loud failures did your reproduction produce? Compare with the count in
`sweep-2187-06-01.log`. Do they agree?

**11.** One of the surviving files was matched by the glob and *not* removed, and produced **no**
error at all. Which one, and which flag on the `rm` line is responsible for the silence?

**12.** One of the surviving files was matched by the glob and produced a loud error. Which one, and
what did `rm` think you were asking for?

**13.** For each of the seven files in `deck-05/`, write one line: the name, and the single reason
it is still there. You should end up with four distinct mechanisms.

**14.** Which of your four mechanisms is a property of the **shell**, and which is a property of
**`rm`**? Two and two, or three and one? Justify.

## Core — separating design from accident

**15.** Seven files, and rhea only cares about the ones that were arranged. You need a discriminator
that is not aesthetic judgement. `ls -Al --time-style=full-iso deck-05` — what do you see?

**16.** Group the seven by modification time. How many groups, and how big?

**17.** What is the sweep's start time, from its own log? How long before it were the files in your
largest group last written?

**18.** State the inference the timestamps support, in one sentence, and then state one alternative
explanation for the same timestamps that you cannot rule out from the lab.

**19.** `cat records/naming-convention.txt`. What marks a file as belonging to a set, and where in
the file does the mark live?

**20.** Check your grouping against the convention: do the files in your candidate set carry the
mark, and do the other two lack it? Note that this is a *second, independent* discriminator — say
whether the two agree.

**21.** `stat` one file from each group. Is there anything in the inode numbers, sizes or owners
that separates them? (Answer honestly, including if the answer is no.)

## Core — the one glob

**22.** Write down the five names you intend to select. Now find what all five have in common in
their names, and what the other two do not have.

**23.** `cd deck-05` — work inside the directory from here on, the way `sweep.sh` did. Now
`printf '[%s]\n' *.log*` — how many? Which of the five is missing, and why?

**24.** Fix that with one `shopt`. Which one, and what does it change?

**25.** With `dotglob` on, run `cat *.log*`. It fails. What is the error, which file caused
it, and why does quoting not help?

**26.** Fix that with one argument. Which one? There is also a second fix that needs no cooperation
from `cat` at all — you used it on `rm` in Chapter 4. Name it, and say why the constraint in
`readme.md` still allows it.

**27.** Put it together: **one** command, one glob, that prints the tag lines of exactly the five
files in glob order. Record the command.

**28.** In what order did the five come out, and what determines that order? Is it the order `ls`
would give? Is it alphabetical in the way you would sort them by hand?

**29.** Read the five tags in that order as a phrase. Does it read? Apply the flag format from
`readme.md`.

**30.** Submit it: `kestrel flags submit 'KESTREL{...}'`.

**31.** Now break it deliberately: run your command with `dotglob` off and read the phrase you get.
Explain, in terms of the convention in `records/naming-convention.txt`, how a set tells you a file
is missing without a manifest.

## Reasoning — what the evidence supports

**32.** Which of these does the lab actually establish? For each, answer yes or no and cite the
file. (a) The patterns were published in advance. (b) The five files were written after the notice
was posted. (c) The five files were renamed rather than created. (d) One person did all five.
(e) The sweep script is defective.

**33.** The two accidental survivors. Write one sentence each on the most likely mundane reason
those names ended up like that.

**34.** Suppose all seven had the same timestamp. What would you have left as a discriminator, and
would it be enough?

**35.** Suppose the notice had never been posted. Which parts of your conclusion survive that
change, and which collapse?

**36.** Write the finding for rhea. Three sentences: what survived by design, what survived by
accident, and how you told them apart. Do not write a fourth sentence.

## Experiment

**37.** In `scratch/`, create a file that would survive all three published patterns *and* be
invisible to `ls`, `ls -A` and a `dotglob` glob. Is that possible? What is the closest you can get?

**38.** Create a file whose name defeats `sweep.sh` for a **fifth** reason not used in `deck-05/`.
(Hint: `sweep.sh` does not `cd` anywhere the student can reach — think about what `*` does not
descend into.)

**39.** Rewrite `sweep.sh` in `scratch/` so that it removes all three of your ordinary test files
and every one of the five designed survivors, correctly, in four lines. Which chapter-5 fixes did
you need?

**40.** Your fixed sweep now deletes things it should not have to. Add the one thing that makes it
safe to run twice, and say what `rm -f` was already doing for you there.

## Stretch

**41.** `sweep.sh` iterates `*.log *.txt *.bak`. If `deck-05/` had contained no `.bak` files at all,
what would the loop have tried to remove, and what would `rm -f` have done about it? Reproduce it in
`scratch/`.

**42.** Now set `nullglob` and reproduce it again. Different behaviour. Which one would you rather a
housekeeping script had, and why is the honest answer "neither, use `failglob`"?

**43.** Write a one-line audit that reports, for any directory, every filename that would defeat a
naive `rm -f $f` loop. Name what your audit cannot detect.

**44.** The sweep removed 41 files. Using only the manifest and what is in front of you, can you
name a single one of them? State what would have had to be recorded for that to be possible.

## Dig — the chain

Four stages, `STAGE{...}` tokens, one per lesson of this chapter. They do not register with
`kestrel flags`; they are receipts.

**45.** `housekeeping/notice.txt` ends by telling you how the record index files in `records/` are
named. Exactly one file in `records/` matches the pattern that description implies. Find it with a
glob — a character class will do it in one — and read it. Record the token.

**46.** Stage 2 gives you a brace expression and tells you one of its expansions exists. How many
words does the expression expand to? Find the one that is there without checking them by hand, and
without a loop if you can manage it. Record the token.

**47.** Stage 3 asks you to count something in `notice.txt`. Do it wrong first — unquoted — and
record the number you get and the fact that you got no error. Then do it right. Record both numbers
and the token.

**48.** Stage 4 hands you a colon-separated record with six fields, one of them empty. Read it with
a single `read` and report field 6. Record the token.

**49.** Four tokens. Write down which lesson each stage tested and which one you would have failed a
week ago.

**50.** The last stage says something about intent and then stops. Write down where it stops, and
why a file in a lab is the wrong place to go further.
