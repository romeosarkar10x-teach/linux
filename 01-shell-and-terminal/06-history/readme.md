# 01/06 — History

> Every account on the station keeps a record of what it typed. Yours will too. This is the lesson
> where that stops being trivia.

Your shell remembers what you have typed. That is a convenience while you work, a diagnostic when
something breaks, and — as you are about to find out — a record that outlives the person who made
it.

## Two places, not one

This is the thing everybody gets wrong, so take it first.

| | Lives in | Holds |
|---|---|---|
| **the history list** | your running shell's memory | this session's commands |
| **the history file** | `~/.bash_history` on disk | commands from *finished* sessions |

They are not the same thing and they are not continuously synchronised. A running shell accumulates
lines in memory, and **writes them to the file when the shell exits**.

Consequences worth memorising:

- A command you ran ten seconds ago is in the list, not yet in the file.
- Two shells open at once each keep their own list, and whichever exits last writes over — or
  appends after — the other's contribution, depending on configuration.
- A shell that is killed rather than exited may write nothing at all.
- **The last line in a history file is often incomplete or missing**, because the session ended
  before the shell got to write it properly.

That last point will matter more than it currently sounds like it will.

## Reading the list

```bash
$ history
  501  cd /labs
  502  ls -l
  503  history
$ history 5          # just the last five
```

Each line has a number. The numbering is per-list, and it is what `!n` refers to.

This image sets `HISTTIMEFORMAT`, so your `history` output carries timestamps:

```bash
$ history 3
  501  2187-06-14 09:02:11 cd /labs
  502  2187-06-14 09:02:14 ls -l
```

That is a display setting, but it has a side effect on disk: when `HISTTIMEFORMAT` is set, bash
writes a `#<seconds-since-1970>` comment line before each command in the history file. Look at a
history file from a shell that had it set and you will see pairs of lines.

## Re-running things

| Form | Means |
|---|---|
| `!!` | the previous command, entire |
| `!n` | history line number `n` |
| `!-2` | two commands back |
| `!cat` | the most recent command *starting with* `cat` |
| `!?strain?` | the most recent command *containing* `strain` |
| `!$` | the **last argument** of the previous command |
| `!^` | the first argument of the previous command |
| `!*` | all arguments of the previous command |

`sudo !!` is the classic: run something, get "permission denied", re-run it with `sudo` without
retyping.

```bash
$ wc -l deck-3-structural-strain-sampler-output-2187-06.log
3 deck-3-...
$ head -2 !$
head -2 deck-3-structural-strain-sampler-output-2187-06.log
```

Note what happened there: bash **printed the expanded line** before running it. That is deliberate,
and it is your chance to notice that `!$` grabbed something other than what you meant.

> **`!$` versus `Alt-.`** — they produce the same text and they are not the same tool. `Alt-.`
> inserts the text into the line you are composing, so you can see it and edit it. `!$` is expanded
> when you press Enter, so you find out what it meant afterwards. Prefer `Alt-.` while typing;
> `!$` is for when you have already pressed Enter on the previous line and want to be quick.

## Searching: `Ctrl-R`

The single most useful thing in this lesson.

```
(reverse-i-search)`strain': wc -l deck-3-structural-strain-sampler-output-2187-06.log
```

Press `Ctrl-R`, type any fragment of a command you ran before, and it searches backwards as you
type.

- `Ctrl-R` again — the next older match.
- `Enter` — run it.
- **`Esc` or the right arrow — put it on the line to edit instead of running.** Learn this one; it
  turns a risky "run whatever I found" into a safe "show me and let me look".
- `Ctrl-G` — abandon the search, restore the line you had.

## Controlling what gets recorded

```bash
$ echo "$HISTCONTROL"
ignoreboth
```

`HISTCONTROL` takes a colon-separated set:

| Value | Effect |
|---|---|
| `ignoredups` | do not record a command identical to the previous one |
| `ignorespace` | **do not record any command that starts with a space** |
| `ignoreboth` | both of the above |
| `erasedups` | remove all previous copies of this command from the list |

`ignorespace` is the interesting one. Prefix a command with a single space and it never enters the
list at all:

```bash
$  echo "this line is not recorded"
```

The intended use is keeping a password or a token out of a file that sits in your home directory in
plain text. It has other uses.

Two more:

```bash
HISTSIZE=100000        # lines kept in memory
HISTFILESIZE=200000    # lines kept in the file
HISTFILE=~/.bash_history
```

Set `HISTSIZE` to a small number and the shell forgets things. Set `HISTFILE` to nothing and the
shell writes no file at all.

## Moving history between shells

```bash
history -a     # append this session's new lines to the file, now
history -r     # read the file into this session's list
history -c     # clear this session's list (memory only)
history -w     # write the whole list to the file, overwriting
```

`history -a` is how people keep several terminals in sync without waiting for exits.

> **`history -c` does not delete the file.** It clears memory. If the shell then exits with default
> settings it may write an *empty* list over the file — which is how people delete their history by
> accident, and how a file ends up truncated at an odd place.

## The file is just a file

```bash
$ ls -l ~/.bash_history
$ cat ~/.bash_history
```

Plain text, one command per line, `#<epoch>` comments interleaved if timestamps are on. It is owned
by you, readable by you, and it does not vanish when the account stops being used.

Any account's history file sits in that account's home directory, subject to permissions. Chapter 10
is about those permissions. This lesson is about what the file is.

## Before you move on

- The difference between the history list and the history file, and when the second gets written.
- Why the last line of a history file is often incomplete.
- What `!$` does, and why `Alt-.` is safer while composing.
- What a leading space does to a command, and why that facility exists.
- What `history -c` clears, and what it does not.
