# 02/06 — Paths in anger

> Somebody on this station names files as though nobody will ever have to type them. You are about
> to find out whether that was carelessness.

Everything so far assumed filenames behave. This lesson removes that assumption.

A Linux filename is a sequence of bytes. **Two bytes are forbidden**: `/`, because it separates
components, and the NUL byte, because it terminates the name. Everything else is legal — spaces,
newlines, control characters, leading dashes, emoji, and characters that render exactly like other
characters. The kernel does not care. Your shell, your terminal and your eyes all do.

That gap — between what the filesystem stores and what you see — is where this lesson lives, and it
is the whole of the chapter's incident.

## Whitespace

The shell splits a command line into words at spaces. So this:

```bash
cat deck 3 bay 2/strain log.txt
```

is not one filename. It is four arguments, none of which exist. Three ways to fix it:

| Method | Looks like | Notes |
|---|---|---|
| Quotes | `cat 'deck 3 bay 2/strain log.txt'` | simplest; Chapter 5 covers what each kind of quote disables |
| Backslash | `cat deck\ 3\ bay\ 2/strain\ log.txt` | escapes exactly one following character |
| Tab completion | type `cat deck<Tab>` | **the shell inserts the escapes for you** |

Tab completion is the one to reach for, and not only for typing speed: it is *evidence*. If the
shell completes a name, that name exists exactly as completed. If it does not complete, what you
believe about the name is wrong.

### Whitespace you cannot see

```
$ ls awkward
 notes.txt
deck 3 bay 2
notes.txt
notes.txt 
panel	report.txt
two
lines.txt
```

Seven lines for six files. There are three entries here whose names all render as `notes.txt`: one
plain, one with a leading space, one with a trailing space — and in a terminal, where `ls` prints in
columns rather than one per line, they are even harder to separate. Plain `ls` gives you no
way to tell them apart, and the last entry's name contains a **newline**, which is why the listing
appears to have a stray line in it.

`ls -b` prints names with escapes instead:

```
$ ls -b awkward
\ notes.txt
deck\ 3\ bay\ 2
notes.txt
notes.txt\
panel\treport.txt
two\nlines.txt
```

Now every name is unambiguous and every one of them is copy-pasteable. `ls -Q` is the other option:
it wraps each name in double quotes, which is enough to spot a leading or trailing space but does
not reveal a tab.

> **Rule of thumb.** When a listing surprises you, re-run it with `-b`. It costs three keystrokes
> and it is the difference between "that directory is empty" and "that directory contains a name I
> could not see".

## Names that begin with a dash

```
$ cat -audit
cat: invalid option -- 'a'
```

`cat` never saw a filename. The shell passed the word `-audit` through unchanged, and `cat` — like
almost every program — treats a leading `-` as the start of options. The file is not the problem;
the convention is.

Two fixes, and you should know both:

```bash
cat ./-audit      # give it a path, so the first character is not a dash
cat -- -audit     # -- says "no more options; everything after this is an operand"
```

`--` is a convention honoured by essentially every GNU tool. It is the safer of the two when the
name is coming from somewhere you do not control, and it is the one that matters most in Chapter 4,
where the command after it is `rm`.

> **`ls` has a trap here.** `ls -audit` does not error at all: `-a`, `-u`, `-d`, `-i` and `-t` are
> all valid `ls` flags, so it silently runs a listing you did not ask for. A command that succeeds
> while doing the wrong thing is worse than one that fails.

## Names that render identically

```
$ ls lookalikes
deck.txt  dеck.txt  panel.txt  strain-log.txt  strain‑log.txt
```

Two of those pairs are different files with names that look the same. One `strain-log.txt` uses the
ordinary hyphen-minus, `-` (U+002D); the other uses NON-BREAKING HYPHEN (U+2011). One `deck.txt` uses
the Latin letter `e`; the other uses CYRILLIC SMALL LETTER IE, which in most fonts is drawn the same
way. And one name has a ZERO WIDTH SPACE in it, which renders as nothing at all.

You cannot see this. You have to make the shell show you the bytes:

```
$ LC_ALL=C ls -b lookalikes
deck.txt
d\320\265ck.txt
panel\342\200\213.txt
strain-log.txt
strain\342\200\221log.txt
```

Setting `LC_ALL=C` for one command tells the tools to treat anything outside ASCII as non-printable,
and `-b` then escapes it as octal. `\320\265` is the two bytes UTF-8 uses for Cyrillic `е`;
`\342\200\213` is the three bytes of ZERO WIDTH SPACE.

`stat -c %N` does something similar — it prints the name in a form the shell would accept back.

This is not an exotic problem. It is the mechanism behind a whole family of real attacks, and it is
also what happens by accident when a name is pasted out of a document that helpfully "improved" a
hyphen.

## Dots

You know `.` and `..` and that a leading dot hides a name from `ls`. Three details that matter here:

- **Hiding is entirely `ls`'s doing.** The kernel has no concept of a hidden file. `du`, `tar`,
  `stat` and every other tool see dot-names normally — which is exactly why `du` and `ls` disagreed
  in the last lesson.
- `..double-dot` is a perfectly ordinary filename that starts with two dots. It is not `..`.
  Similarly `...` is a legal three-character name, and `ls -a` shows all three of `.`, `..` and `...`
  next to each other, which reads like a rendering glitch and is not.
- `ls -A` shows hidden entries *except* `.` and `..`, which is usually what you actually wanted.

## Metacharacters

Some characters are meaningful to the **shell** before any program runs. A file called
`glob*star.txt` or `what?.txt` or `range[0-9].txt` or `$HOME.txt` is fine on disk; typing it
unquoted is not, because the shell rewrites those words before the command ever sees them. Quoting
prevents that. Chapter 5 is entirely about the rules; for now: **quote anything with a character you
did not choose yourself**, and prefer tab completion, which quotes for you.

## Doing it properly

A short checklist that will serve you for the rest of the course:

1. If a listing looks wrong, re-run it with `-b`.
2. Tab-complete instead of typing awkward names.
3. Put `--` before an operand you did not choose, or prefix it with `./`.
4. Quote every path that contains anything but letters, digits, `.`, `-` and `_`.
5. If two names look identical, they are not — go and look at the bytes.

## Gotchas

- Tab completion needs a unique prefix. With `notes.txt` and `notes.txt ` present, completing
  `note<Tab>` gets you as far as the common part and then stops. That stall is information.
- `--` must come before the operand, and after it *everything* is an operand — including things that
  really were meant as flags.
- `ls -b` escapes for display, but the escaped form is also valid input, which is why it is safe to
  copy.
- A newline in a filename breaks any pipeline that reads "one name per line". This is the main reason
  experienced people treat such names as a bug, not a curiosity.
- `rm -- -rf` deletes a file called `-rf`. `rm -rf` does something else entirely. Chapter 4.

## Before you move on

- A filename is bytes; only `/` and NUL are forbidden.
- `ls -b` escapes; `ls -Q` quotes; `LC_ALL=C ls -b` exposes non-ASCII as octal.
- `--` and `./` are the two ways to say "this is a filename, not an option".
- Hiding is a convention inside `ls`, not a property of the file.
- Tab completion proves a name exists, and escapes it for you.
