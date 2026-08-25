# 06/04 — Validation: `find` Basics

Ask for commands and numbers, not descriptions. Everything here is one line in the lab.

## The one thing that must be true

**The student quotes `-name` patterns by reflex and can explain all three outcomes of not doing it** —
accidental success, silent wrong answer, and the two-line error — and knows the silent wrong answer
is the dangerous one.

## Must be able to do

1. Say what `-name` is compared against (the base name) and why a pattern containing `/` matches
   nothing.
2. Explain the difference between `find . -name '*.log'` (13) and `find . -name '*.log' -type f` (11)
   by naming the two entries removed.
3. Separate the file `readings` from the directory `readings`, and say what breaks downstream if they
   do not.
4. State what `-maxdepth 1` and `-maxdepth 0` mean without hedging.
5. Read `find . -name '*.log' -o -name '*.txt' -type f` aloud with the correct precedence and give
   the grouped version.
6. Say why a broken symlink is still `-type l`, and which predicate finds broken links.
7. Say what `find` does *not* do: it never opens a file, so no question about content is a `find`
   question.

## Should be able to do

- Explain `-path` versus changing the starting path, and prefer the starting path in a script.
- Say that `find` sees dotfiles and the shell does not, and why.
- Name the cost of piping `find` into another tool (newlines in filenames).

## Common wrong answers

- "`-name '*.log'` finds all the logs." It misses `.LOG` and includes two symlinks.
- "`*.log` matches `panel-03.log~`." It does not; the pattern must match the whole base name.
- "`-maxdepth` has to come first or it errors." findutils 4.11 accepts it anywhere and prints no
  warning; the reason to write it first is habit and portability, not this version's behaviour.
- "`find -L … -type l` finds broken links." It finds exactly the broken ones for the wrong reason and
  nothing else; `-xtype l` is the predicate.
- "`find` is like `grep -r`." One filters names and metadata, the other reads bytes.

## Red flags

- Writes `find . -name *.log` and does not notice.
- Pipes `find` output into a `for` loop over `$(…)` without mentioning word splitting.
- Answers a "how many logs" question with a single number and no definition.
- Uses `-regex` before trying `-name`, or expects `-regex` to match part of a path.

## Sign-off question

> Somebody hands you a script that finds every log on a deck and deletes the ones nobody has touched.
> Before you run it, what do you check about the `find` half of it, and name one file in this lab it
> would get wrong in each direction.

A good answer names quoting, `-type f`, symlink handling and the case convention, and gives at least
one false negative (`strain-02.LOG`) and one false positive (`links/latest.log` under `-L`, or the
`readings` directory).
