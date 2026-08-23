# 05/02 — Brace Expansion

> A glob asks the filesystem a question. A brace expression does not ask anybody anything. That one
> difference is the whole lesson, and it is the reason braces can build a tree that does not exist
> yet.

## What this lesson is

You spent the last lesson learning that `*.log` is turned into a list of filenames before the command
runs. Brace expansion also produces a list before the command runs — and produces it out of nothing.

`echo panel-{01,02,99}.log` prints all three names, including `panel-99.log`, which does not exist
and never has. Nothing checked. Nothing was consulted. The shell did string arithmetic and handed
the result over.

That is why braces are the tool for **creating**, and globs are the tool for **selecting**. Reach for
the wrong one and you get a mistake with a particular flavour: a glob that silently matches nothing,
or a brace expression that confidently names files that were never there.

## The three forms

**List.** `{a,b,c}` — one output per element, in the order you wrote them. `echo {b,a,c}` prints
`b a c`; braces do not sort, unlike globs.

**Sequence.** `{1..5}`, `{a..e}`, `{01..05}`, `{0..20..5}`. Numeric or single-character alphabetic,
optionally with a step. Zero-padding in *either* endpoint pads the whole series, which is how you get
`bay-01` rather than `bay-1`. Reversed endpoints count down.

**Combination.** Adjacent expressions multiply: `{a,b}{1,2}` is four strings, not two. Nested
expressions work too: `a{b,c{d,e}}f` gives `abf acdf acef`. Every combination is produced, whether or
not it means anything.

The empty element is the idiom worth memorising on sight:

```
mv panel-03.cfg{,.bak}
```

`{,.bak}` is a two-element list whose first element is the empty string, so that line expands to
`mv panel-03.cfg panel-03.cfg.bak` and the filename is written once. When you see it in somebody
else's script, that is what it is.

## When braces do nothing

A brace expression the shell does not recognise is left alone, exactly like an unmatched glob:

- `{abc}` — no comma, no `..`. Printed literally.
- `{a}` — one element is not a list.
- `{a, b}` — the space breaks it.
- `{a,b` — unmatched. Printed literally.
- `{a..3}` — endpoints must both be numbers or both be single letters.

So the failure mode is the same as last lesson's: no error, no warning, and a command that receives
the pattern as text.

## The ordering fact that catches everybody

**Brace expansion happens first — before parameter expansion, before globbing, before anything.**

```
n=5; echo {1..$n}
```

prints `{1..$n}`. Not `1 2 3 4 5`. By the time `$n` becomes `5`, the shell has already looked at the
braces, seen something that is not a number, and given up. Braces cannot take a variable bound. Use
`seq` or a C-style `for ((i=1; i<=n; i++))` loop, or — if you must — `eval`, with all the care that
implies.

The ordering also explains why braces and globs compose so well: `panel-{0,1}*.log` expands to two
*patterns*, `panel-0*.log` and `panel-1*.log`, and each is then matched against the filesystem. You
get the union of two globs.

## The shape of the lab

`spec/deck-spec.txt` is the deck-05 layout: eight bays with three subdirectories each, three panels
with two each. `spec/gaps.txt` records three ways the layout is less regular than it reads — the
whole point of the lesson's centrepiece, which is building the tree correctly in **one** command.

`build/` is where your tree goes. `existing/` is a half-built version of it, for finding out what
brace expansion knows about what already exists (nothing). `backup/` has four `.cfg` files, two of
which already have a `.bak` beside them. `seq/` and `scratch/` are yours.

## Rules of engagement

Every brace expression goes through `echo` before it goes through `mkdir`. A wrong glob usually does
nothing; a wrong brace expression usually does something, forty times.

`kestrel reset 05/02` if `build/` gets away from you.

## What "solved" looks like

You can build the whole deck-05 tree with one `mkdir -p`, including all three irregularities, and
say why the obvious expression is wrong. You can read `mv f{,.bak}` without pausing. You can say what
`echo {1..$n}` prints and why. And you can state the difference between a brace expression and a glob
in one sentence, in terms of who gets asked.

## Before you move on

Both lessons so far have been about the shell building a list of words for you. The next one is about
stopping it.
