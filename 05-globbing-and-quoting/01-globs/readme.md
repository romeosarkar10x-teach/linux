# 05/01 — Globs

> The shell rewrites your command before the command ever sees it. Everybody knows this. Almost
> nobody knows exactly when.

## What this lesson is

You have typed `*.log` a hundred times. This lesson is about who expands it, when, into what, and
what happens to every command you run when the answer is "nothing".

The single most useful fact in this chapter, and the one people quietly get wrong for years:

> **`ls *.log` is not a command with a wildcard in it.** By the time `ls` starts, the wildcard is
> gone. The shell has already replaced it with a list of filenames, and `ls` sees only that list.

`ls` has no idea a glob was involved. Neither does `rm`, `cp`, or anything else. This explains
nearly every surprising thing a glob does, including the error messages, so hold onto it.

## Where the expansion happens

Type this:

```
ls *.log
```

The shell splits the line into words, then looks at each word for the characters `*`, `?` and `[`.
When it finds them, it treats that word as a **pattern**, matches it against the names in the
relevant directory, sorts the matches, and substitutes them in place of the word. Then, and only
then, it runs `ls` with those names as arguments.

So `ls *.log` in a directory with three logs is exactly `ls panel-01.log panel-02.log panel-03.log`.
The `*` never reaches `ls`. You can watch it happen — `set -x` prints the command *after* expansion,
which is one of the exercises and worth doing early.

## The pattern characters

| Pattern | Matches |
|---|---|
| `*` | any string, including the empty string |
| `?` | exactly one character |
| `[abc]` | one character, from that set |
| `[a-z]` | one character, from that range |
| `[!abc]` or `[^abc]` | one character, **not** from that set |
| `[[:digit:]]` | one character in that POSIX class — also `:alpha:`, `:upper:`, `:lower:`, `:space:` |

Two rules that are not in the table and matter more than it does.

**A glob never matches `/`.** `*` will not cross a directory boundary, which is why `deck-*/bay-*`
has to be written with the slash in it. `a*c` cannot match `a/b/c`.

**A glob never matches a leading dot.** `*` will not match `.cfg`, `.bashrc`, or anything else whose
name starts with `.` — not because those files are special to the filesystem, but because the shell
has a rule about it. `.*` matches them, and there is a subtlety in that which you will meet in the
exercises.

## Glob is not regex

They share two characters and mean different things by both. In a glob, `*` means "any string"; in a
regex, `*` means "zero or more of the previous thing". In a glob, `.` is an ordinary dot; in a regex,
it is any character.

| | glob | regex |
|---|---|---|
| `*` | any string | zero-or-more of the previous atom |
| `?` | exactly one character | zero-or-one of the previous atom |
| `.` | a literal dot | any character |
| `a+` | a literal `a+` | one or more `a` |

`*.txt` as a regex means something almost nobody wants. `.*\.txt` as a glob matches a file whose
name literally contains `.*\.txt`. Chapter 6 is regex; keep the two apart until then.

## When nothing matches

This is the behaviour that catches everyone. By default, **a pattern that matches nothing is left
alone, unexpanded, and passed to the command as a literal string.**

```
$ ls *.zip
ls: cannot access '*.zip': No such file or directory
```

Read that error again. `ls` is complaining about a file *called* `*.zip`, because that is genuinely
what it was handed. The shell found no matches, shrugged, and passed the pattern through as text.
Once you see this, every "no such file or directory" with an asterisk in it becomes obvious.

Three `shopt` options change it:

- `nullglob` — an unmatched pattern expands to **nothing at all**, removing the word entirely
- `failglob` — an unmatched pattern is an **error**; the command does not run
- `dotglob` — `*` starts matching names that begin with a dot

`nullglob` sounds like the fix and has its own trap: `rm *.zip` with `nullglob` on becomes `rm` with
no arguments. There is a reason none of these are on by default, and there is a reason careful
scripts turn them on deliberately for one block and off again.

## `globstar`

`**` is not special by default. With `shopt -s globstar`, `**` matches across directory boundaries,
so `**/*.txt` finds every `.txt` at any depth. Two details worth knowing before you rely on it: `**`
does not descend through a symlinked directory, and `**/` matches directories only.

## Sorting

The expansion comes back **sorted**, which means output order is decided by the shell and not by the
command. The sort is by the current locale's collation. This container runs `C.UTF-8`, which sorts
by byte value: every uppercase letter sorts before every lowercase one, and `-` and digits sort
before both. That is why `[a-z]*` here does **not** match `A.txt` — and why the same glob on a
machine set to `en_US.UTF-8` would. A glob is not as portable as it looks.

Also: it is a *string* sort. `panel-10.log` comes before `panel-2.log`.

## What you will do

Read a directory with patterns instead of with your eyes; find out exactly which names each pattern
picks up and which it misses; meet a set of filenames chosen to defeat the obvious pattern; and turn
`dotglob`, `nullglob`, `failglob` and `globstar` on and off until you can predict the difference
without running it.

The last exercise reads `spec/sweep-notes.txt`, which is housekeeping's cleanup pattern. You will
meet that pattern again at the end of the chapter, from the other side.

## Start

```
cd /labs/05-globbing-and-quoting/01-globs
ls
```

Then open `exercises.md`. Stuck: `help.md` — five rungs, climb one at a time.
