# SELF_CHECK.md — checking your own work

Agent validation is the primary check in this course (`docs/VALIDATION_PROTOCOL.md`). This file is
the secondary one: what you do yourself, before you hand a chapter to a validator.

Self-checking is not grading yourself. It's catching the obvious misses so the validator's time
goes to the interesting ones.

## After every exercise

Three questions, every time:

1. **Did I get the right answer, or the right answer for the wrong reason?** If your command
   happened to work because there was only one file in the directory, it didn't work.
2. **Could I write it again tomorrow without the notes?** If not, it's a copy, not a skill.
3. **What would break it?** A filename with a space. An empty directory. A file you don't own.
   Try one of them.

## After every lesson

Close the notes. Then:

- Recite the **"Before you move on"** list at the bottom of `readme.md` from memory. Anything you
  can't state, re-read.
- For each command the lesson taught, say out loud what it does and name two flags. If you can only
  name the one you used, open `man` and skim.
- Re-run one Core exercise from a fresh lab (`kestrel reset <chapter>/<lesson>`) with the notes
  closed. This is the single highest-value habit in the course.

## After every chapter

- Take the chapter's Flag exercise again from a clean lab, timed. You should be much faster than
  the first time. If you aren't, the chapter didn't stick.
- Skim your `history` for the chapter. Look for: commands you ran and don't remember, long pipelines
  you'd have to rebuild from scratch, and anything you copied from a hint.
- Write three sentences on what the chapter was actually about, without looking. Keep them; they're
  a decent revision file by Chapter 15.

## Per-tier honesty check

| Tier | You've passed it when |
|---|---|
| **Warmup** | You didn't need the notes at all. |
| **Core** | You can do it from memory tomorrow, on different data. |
| **Experiment** | Your written prediction was wrong and you can now explain *why* your model was wrong. A right prediction that surprised you doesn't count. |
| **Stretch** | You saw which earlier chapter it was pulling from without being told. |
| **Dig** | You found the flag in `man`, not in a search engine, and you can say what it does. |
| **Flag** | You could plant a similar flag for someone else. |

## Spaced repetition

The failure mode of this course is Chapter 3 evaporating by Chapter 11. Counter it:

- **Daily, 5 minutes:** pick a random earlier lesson's Warmup tier. Do it cold.
- **Weekly:** redo one full Core tier from a chapter you finished at least two weeks ago, from a
  reset lab.
- **Before each new chapter:** re-read the previous chapter's "Before you move on" lists. They're
  short by design.
- **Keep a mistake log.** One line per error you make: what you typed, what was wrong. Re-read it
  weekly. Your own errors are worth more revision time than anyone's curriculum.

## Signs you're fooling yourself

- You reach for the hint before you've read the error message.
- You can produce the command but not predict its output.
- You've stopped running things wrong on purpose to see what happens.
- Your `history` for a hard lesson has no failures in it.

That last one is what a validator looks for too.
