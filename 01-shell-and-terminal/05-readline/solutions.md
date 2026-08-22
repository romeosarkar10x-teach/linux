# 01/05 — Solutions

> **Student: do not read this file.**
> **Agents:** steering only. See `docs/AGENT_MODES.md`.

No flag in this lesson.

**Verified against the course image.**

### 1 — jump and abandon
`Ctrl-A` (start), `Ctrl-E` (end), `Ctrl-C` (abandon). The line must not appear in history.

Home/End usually work too, but they are terminal-dependent: over some connections, and in some
terminal configurations, they send sequences the remote readline does not recognise. `Ctrl-A` and
`Ctrl-E` are part of readline itself and work wherever readline does.

### 2 — delete word, delete line
`Ctrl-W` then `Ctrl-U`. Note `Ctrl-U` deletes from the cursor to the *start*, so from mid-line it
leaves the tail behind — `Ctrl-A` `Ctrl-K` is the reliable "delete everything" pair.

### 3 — delete and restore
`Ctrl-W`, then `Ctrl-Y`. The text goes to readline's kill ring, which is internal to the process —
it is not the system clipboard and cannot be pasted into another application.

### 4 — 05 to 06
One good route:
```
Alt-B          (back a word -- lands near "log")
Alt-B          (again -- now at "05")
```
then edit the two characters. Or, from the end of the line: `Alt-B` twice, `Ctrl-W`, retype
`05.log` as `06.log`.

Cheapest of all: `Ctrl-E`, then six backspaces and retype `06.log`. Accept anything under about five
movement keys. What fails is retyping the whole line.

### 5 — reuse the last argument
```bash
ls -l deck-3-structural-strain-sampler-output-2187-06.log
wc -l <Alt-.>
```
`Alt-.`, or `Esc` then `.` if the terminal eats Alt.

`!$` gives the same result and belongs to 01/06. If a student uses it, accept it and ask for the
keystroke as well — the keystroke works while you are still composing the line, which `!$` does not.

### 6 — three deep
Each new command pulls the previous line's last argument. Pressing it repeatedly walks further back
through history — press once too many and keep pressing, or press it again to continue past and
around.

### 7 — cut and paste an argument
Cursor before the argument, `Ctrl-K` to cut to end, edit, `Ctrl-E`, `Ctrl-Y`. The yank inserts **at
the cursor**, not at the end — a common surprise.

### 8 — front and back
`Ctrl-A`, type the word, `Ctrl-E`. Two navigation keystrokes, and the count does not change with
line length. That invariance is the whole point.

### 9 — Tab ambiguity (Experiment)
Seeded files: `strain-bay1 strain-bay2 strain-bay3 stress-bay1 stress-bay2`.

- `cat readings/s` + Tab → completes to `readings/st`, since all five share `st`. It looks like
  "nothing happened" only to someone not reading the line.
- Second Tab → lists all five.
- `cat readings/str` + Tab → completes to `readings/strain-bay` and stops; three candidates remain.

The lesson: completion always fills in as much as is unambiguous, then stops. "Nothing happened"
almost always means "there was nothing unambiguous left to add", which tells you there are multiple
matches.

### 10 — no matches (Experiment)
Nothing completes; you may get a terminal bell. Nothing is inserted and nothing is listed.

As a check: before typing a long path, type a short prefix and press Tab. If nothing fills in, the
prefix is already wrong, and you know in one second instead of after a failed command. This is the
cheapest existence test available and costs one keystroke.

### 11 — Ctrl-D twice (Experiment)
With text on the line: deletes the character under the cursor.
On an empty line: end-of-input — the shell has no more commands, so it exits.

One rule, two outcomes. It is the same end-of-input signal that finishes `cat > file` typing.

Do it in a child shell. A student who did it in their main session and got disconnected has
demonstrated the point thoroughly; note it and move on.

### 12 — back in the parent (Stretch)
```bash
echo $$        # 2417
bash
echo $$        # 2588
<Ctrl-D>
echo $$        # 2417
```
`Ctrl-D` on an empty line is equivalent to `exit` here, and the PID confirms it.

### 13 — Ctrl-L versus clear (Stretch)
Type half a command and do not press Enter.

`Ctrl-L` clears the screen and **redraws your partial line** at the top — you carry on typing.
`clear` is a program; to run it you would first have to abandon or submit whatever you had typed, so
the partial line is gone by definition.

Identical when the line is empty, different whenever it is not.

### 14 — classifying clear (Stretch)
```
$ type clear
clear is /usr/bin/clear
```
`Ctrl-L` is neither a builtin nor a file. Readline consumes the keystroke while the line is being
composed, before anything is submitted, so the shell's command resolution never sees it at all. It
is a key binding — a fourth category that does not appear in `type`'s answers because it operates at
a different layer entirely.

### 15 — timing (Stretch)
Typical: 12–20 seconds typed out, including at least one correction; 3–5 seconds with Tab. Ratio
around 3–4×.

Across forty thousand commands the arithmetic is absurd, and the real gain is bigger than the
timing suggests: Tab-completed paths do not contain typos, so the failed-command-and-retry cycle
disappears too.

A fast typist on a short path may honestly measure a ratio near 1. Accept it if the method is
described — and point out that the seeded filename in this lab is 51 characters for a reason.

### 16 — the readline config file (Dig)
`~/.inputrc`, per `man bash` → READLINE → "the file named in the `INPUTRC` variable, or
`~/.inputrc`". A system-wide `/etc/inputrc` is also documented — and **is not present in this
image**, which a thorough student will notice and which is a correct finding, not an error.

The setting is `show-all-if-ambiguous`; set `on`, an ambiguous first Tab lists the matches
immediately rather than requiring a second press.

Do not let them confuse this with `.bashrc`. They are read by different things at different times,
and Chapter 11 depends on the distinction.

### 17 — listing bindings (Dig)
```
$ bind -P | head
abort can be found on "\C-g", "\C-x\C-g", "\e\C-g".
...
$ bind -P | grep beginning-of-line
beginning-of-line can be found on "\C-a".
```
`bind -p` gives re-readable inputrc format; `bind -l` lists function names only.

This output is authoritative for the running shell; the notes' table is a description of the
defaults.

### 18 — the other editing mode (Dig)
```
$ set -o vi
$ # Ctrl-A no longer jumps to start -- in vi insert mode it is not bound
$ set -o emacs
```
Readline's default keymap is emacs-based, which is where every binding in this lesson comes from.
vi mode is modal: `Esc` for command mode, `i` to insert, `0` for start of line, `$` for end.

**Check they switched back.** A shell left in vi mode makes every subsequent lesson feel broken, and
the student will not connect it to this exercise.
