# 06/02 — Validation: `grep` Flags

Judge whether the student has a model of the flags, not whether they ran all 57 exercises.

## The one thing that must be true

**The student can say which of three questions a flag answers — what matches, what is printed, where
it looks — and they know that `-c` counts lines regardless of everything else on the command line.**

A cadet who has this can work out a flag they have forgotten. A cadet who has memorised the flags and
not the categories will produce `grep -lv` when they meant `-L` and believe the output.

## Must have done

1. **Distinguished `-L` from `-lv`** with a concrete file from this lab (exercises 12–14, 54).
2. **Explained the `-w` boundary rule** as "not adjacent to a letter, digit or underscore", not as
   "a word", and used `bay-01` as the evidence (exercises 4, 5).
3. **Accounted for the 6/4/2 in `codes.txt`** line by line, including the leading-space line
   (exercises 7, 8).
4. **Explained why `-c` gives 9 and `-o | wc -l` gives 40** on `readings.csv`, in terms of two
   different questions (exercise 19), and reported that `-oc` gives 20 (exercise 45).
5. **Found the `--` separator** in context output and said it is not from the file (exercises 23–25).
6. **Noticed the merged context blocks** for entries 007/008/009 — that four matches produced one
   separator (exercise 26).
7. **Separated `--include` from `--exclude-dir`** as filename-versus-location, and given the better
   answer to exercise 35 (point `-r` at `reports/`).
8. **Reported that `-l`/`-L` in combination is last-flag-wins with no error** (exercise 50).

## Should have done

- Given exercise 18's answer — that the entry number survives a deleted line and the line number does
  not — in their own words. This is the chapter's spine; a student who has it will find the incident.
- Said that exercise 55's deck-04 half is unverifiable rather than confirmed.
- Refused to conclude anything about the two entry-007 faults in exercise 56.

## Common wrong answers

- **"`-L` means the opposite of `-l`, so `-lv` is the same thing."** The central confusion of this
  lesson. Do not let it pass with a nod; ask for the file.
- **"`-A2` on four matches prints twelve lines."** Ask them to run it and read the thirteenth.
- **"`grep -o` counts matches, so `grep -oc` counts matches."** Measured: 20, not 40.
- **"`--include` and `--exclude-dir` do the same job from opposite ends."** They filter on different
  properties; a student who says this cannot answer exercise 35 well.
- **"`grep -o 'aa'` on `aaaa` gives three."** Matches do not overlap; scanning resumes past the end
  of the previous one.
- **"`notes.txt` matching `FAULT` is a false positive."** It is a correct answer to the wrong
  question. The distinction matters for the rest of the chapter.
- **"The two entry-007 faults are the same fault."** Identical detail lines prove a common source,
  not a common cause — and one live possibility is that the second report was generated from stale
  data.

## Red flags

- Counts that do not match the lab: 8/5/1 for `bay`, 6/4/2 for `E-104`, 9/40/20 for `readings.csv`,
  13/11/13 for `-A2`/`-B1`/`-C1`, 6/3/4 for the `-rl` families. Guessed answers show up here first.
- Any narrative about who lower-cased the fault markers in `archive/`. Not knowable.
- Using `-r` with no path anywhere in their transcript without remarking on it (exercise 36).

## Sign-off question

> You have a directory of two thousand log files. You need: the names of the files that never logged
> a heartbeat, the number of heartbeats in each file that did, and the three lines around the last
> heartbeat in the noisiest file. Which flags, in which order, and where does `grep` stop being the
> right tool?

A ready student gives `grep -rL --include='*.log' 'heartbeat' logs/` for the first;
`grep -rc --include='*.log' 'heartbeat' logs/ | grep -v ':0$'` for the second, noting that `-c` is
per line; and `grep -C1 'heartbeat' <file> | tail` for the third while saying that "the last match"
and "the noisiest file" are both ordering questions, which `grep` cannot answer — sorting the counts
and picking a maximum is Chapter 7's work. Credit anyone who flags that `-L` on two thousand files
is cheap and `-c` is not, because `-L` stops at the first match.
