# 05/03 — Quoting

> The last two lessons were about the shell building lists of words for you. This one is about
> making it stop.

## What this lesson is

Quoting is not decoration and it is not a style preference. It is the mechanism that turns off
specific shell behaviours over a specific stretch of text, and there are exactly three of them with
exactly three different strengths.

Almost every shell bug that survives review is a quoting bug, and they have a signature: the script
works for months, then somebody creates a file with a space in the name and it deletes the wrong
thing. This lab is full of such files. They are not exotic; the station is full of them too.

## The three quotes

**Single quotes** `'…'` — everything inside is literal. No expansion of any kind: no `$`, no
backtick, no `*`, no `~`. The only character that cannot appear inside single quotes is a single
quote, and there is no escape for it. To get one, you close, escape, and reopen: `'it'\''s'`, which
is four pieces glued together and prints `it's`.

**Double quotes** `"…"` — literal *except* for `$`, backtick, `\` and `!` under history expansion.
Variables expand, command substitution runs, and globbing does **not** happen. This is the one you
want almost always, because you nearly always mean "expand my variable, then stop".

**Backslash** `\` — escapes exactly the next character. Useful for one or two characters, unreadable
for more.

The rule that follows:

```
echo '$HOME * `date`'    ->  $HOME * `date`
echo "$HOME * `date`"    ->  /home/cadet * Sun Aug 23 …
```

Single quotes stopped everything. Double quotes stopped the glob and let the variable and the command
substitution through. Neither is "safer" — they are different tools, and the question to ask is
always *which expansions do I want here*.

## The one rule that matters

**Quote every variable expansion unless you have a specific reason not to.**

`"$f"`, not `$f`. `"$@"`, not `$@`. `"$(cat file)"`, not `$(cat file)`. The reason is word splitting,
which is lesson 4's subject, but you can see the effect now: an unquoted `$f` holding
`deck 03 readings.txt` becomes **three** arguments, and every command downstream is looking at files
called `deck`, `03` and `readings.txt`.

The exceptions are rare and deliberate: you *want* splitting (`for w in $sentence`), or you are
passing a set of flags held in a variable. Both are better done with arrays. Neither is a reason to
leave the other ninety-nine expansions unquoted.

## Quoting is per-character, not per-word

This is the part that reads as a trick and is not:

```
"$dir"/*.txt
'it'\''s'
--name="$value"
```

A word can be part quoted and part not, and the quotes vanish from the result. `"$dir"/*.txt` quotes
the variable and leaves the glob live — which is exactly what you usually want and cannot express
with quotes around the whole thing.

## What quoting does not do

Quoting protects text from the **shell**. It does not protect it from the command.

You saw this in lesson 1 with `-dash.txt`. Quoting the name does not help: `rm "-report.txt"` and
`rm -report.txt` are identical by the time `rm` runs, because the quotes were consumed by the shell.
The fixes are `--` and `./`, and they are the command's business, not the shell's.

Hold onto this distinction. Half the confusion about quoting comes from expecting it to solve
problems that live on the other side of the boundary.

## The shape of the lab

`names/` holds ten files whose names are all the ways a filename can fight you: a space, a leading
dash, a tab, a newline, an apostrophe, a dollar sign, a semicolon, a backtick, a literal asterisk,
and one plain one for contrast. `logs/` holds three logs whose *contents* contain quotes, dollar
signs and glob characters — for the other half of the lesson, which is quoting patterns rather than
filenames. `msg/` is for command substitution. `scripts/` holds two working scripts with quoting bugs
in them, and you will fix both.

## Rules of engagement

Anything destructive happens on a copy: `d=$(mktemp -d); cp -a names/. "$d/"`. Note the quotes in
that line.

When something behaves strangely, `set -x` and read what the command actually received. Every
exercise in this lesson is ultimately about the difference between what you typed and what the
command got.

## What "solved" looks like

You can list the three quoting mechanisms and say precisely what each one turns off. You can
construct a string containing a single quote. You can handle every file in `names/` without renaming
any of them. You can say why quoting does not fix `-report.txt`. And your reflex, when writing
`$anything`, is to put quotes round it.

## Before you move on

You now know how to stop word splitting. Next lesson is about what word splitting actually is, and
why the shell does it in the first place.
