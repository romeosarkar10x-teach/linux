# 05/01 — Help: Globs

Five rungs. Climb one at a time. Rung 5 is a near-miss on purpose — it does not do what it looks
like it does.

---

## Level 1 — Questions to ask yourself

- Who expanded that pattern — the shell, or the command? What is your evidence, not your belief?
- If you got a "No such file or directory" with a `*` in it, what exactly was the command handed?
- Does `*` match a leading dot? Does it match `/`? You know both answers; are you using them?
- `?` matches how many characters — at least one, or exactly one?
- Is `[0-9]` one character or a number? Those are not the same claim.
- The output came back sorted. Sorted by what — and by whose rules?
- You wrote a pattern that gives the right answer today. Is it right because of the pattern, or
  because of which files happen to exist right now?
- Before you point `rm` or `cp` at a glob, did you run `echo` on it first?

## Level 2 — Where to look

- `man 7 glob` — the whole pattern syntax on two screens. The bracket-expression section answers
  most of the Core tier.
- `man bash`, section **Pathname Expansion** — search for `/^ *Pathname Expansion`. Immediately
  above it is **Brace Expansion**, which is the next lesson, and the order those two appear in the
  manual is the order the shell performs them.
- `man bash`, `shopt` under **SHELL BUILTIN COMMANDS** — the entries for `dotglob`, `nullglob`,
  `failglob`, `globstar`, `nocaseglob`, `globskipdots`, `extglob`. Read `globstar`'s two sentences
  about symlinks twice.
- `shopt` with no arguments — every option and its current state, on your actual shell.
- `help shopt`, `help set` — builtins have `help`, not man pages.
- `LC_COLLATE` in `man 7 locale`, for why `[a-z]` is not a fixed set of letters.
- `/course/05-globbing-and-quoting/01-globs/setup.sh` — the header explains what each directory is
  for. Reading it is allowed.

## Level 3 — The concept, on different data

Build a throwaway directory somewhere you cannot break anything:

```
$ cd $(mktemp -d)
$ touch a ab abc a.txt .hidden A B1
$ echo *
a A a.txt ab abc B1
$ echo a*
a a.txt ab abc
$ echo a?
ab
$ echo ?
a A
$ echo [ab]*
a a.txt ab abc
$ echo [[:upper:]]*
A B1
```

Three things fall out of that and they are the three things the Core tier is testing. `a*` includes
`a` itself, because `*` matches the empty string. `a?` excludes `a` and `abc`, because `?` is
exactly one. `[[:upper:]]` catches `A` and `B1` because it matches the *first* character only.

Now the unmatched case, which you cannot get wrong once you have seen it:

```
$ echo z*
z*
$ ls z*
ls: cannot access 'z*': No such file or directory
```

`ls` was passed the two-character string `z*`. It did what any program does with a filename that
does not exist.

## Level 4 — Break it down

**"My pattern misses a file I can see."** Ask three questions in order: does the name start with a
dot (`dotglob`)? Is the difference a case difference (`C.UTF-8` sorts and matches by byte)? Does the
pattern have a `?` where the name has two characters? Nearly every miss is one of those three.

**"My pattern catches a file I did not want."** Print the expansion with `echo` and look at the
extra name character by character against your pattern. Usually a `*` at the end is matching more
than the empty string you had in mind — `*.log` versus `*.log*`.

**"I want to match a literal `*` / `?` / `[` in a filename."** A bracket expression makes any
character literal: `[*]`, `[?]`, `[[]`. Quoting also works and is the next lesson's subject.

**"Nothing matched and my command did something strange."** That is the default behaviour, not a
bug: the pattern was passed through as text. Decide what you want instead —
`nullglob` (word vanishes) or `failglob` (command refuses to run) — and turn it on for exactly the
block that needs it.

**"I need every `.txt` under a tree."** `**` with `globstar` on, or `find`. They give different
answers on this lab and the difference is a hidden file and a symlink. Run both and diff them.

**"How do I know how many names a pattern matched?"** `printf '%s\n' <pattern> | wc -l`. Not
`ls <pattern> | wc -l`, which lies when a filename contains a newline, and lies differently when the
pattern matched a directory.

## Level 5 — Near-miss

This is close to a correct answer for "match every panel log, whatever its number", and it is wrong
in a way you will not notice on this data.

```
echo panel-[0-9][0-9].log
```

It looks right, it runs without error, and it returns ten of the twelve panel logs. Before you fix
it, say which two it drops and *why each one is dropped for a different reason*. The fix for one of
them is not the fix for the other.

And a near-miss for the literal-asterisk exercises:

```
echo [set].txt
```

This prints `[set].txt`, which looks exactly like a successful match on the file of that name. It is
not one. Work out what the shell actually did — and check yourself by running the same pattern in
`panels/`, where no such file exists.

---

## Never say

Do not hand over: the working pattern for exercise 9 or 47; the name of the `shopt` option in
exercises 13, 14 or 16 before the student has run `shopt` with no arguments; the bracket trick
`[*]` for exercises 33 and 34; or the rule discovered in exercise 41. Point at `man 7 glob` or at
`shopt` and let them read.

Do not confirm or deny a prediction in the Experiment tier before it has been run.

Do not explain what `spec/sweep-notes.txt` implies. Exercises 49–52 are a reading and mechanism
exercise; the student states what each naming trick defeats, and stops there. If a student
speculates about who named a file or why, do not agree, do not disagree, and do not supply a name.
