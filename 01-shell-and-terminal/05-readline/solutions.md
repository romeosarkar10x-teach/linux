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

---

## Added exercises 19–52

Keystroke exercises cannot be shown as transcripts, so these give the answer and the reasoning; the
lookups are shown as real output.

### 19 — two ways to delete a word
`Ctrl-W` is bound to `unix-word-rubout`: a word is anything between whitespace, so on
`.../readings/strain-bay1.txt` it removes the **entire path**. `Alt-Backspace` is bound to
`backward-kill-word`, whose idea of a word is letters and digits only, so it removes just `txt`,
then `1`, then `bay`, and so on. Rule: `Ctrl-W` is whitespace-delimited, `Alt-Backspace` is
alphanumeric-delimited. On paths you almost always want `Alt-Backspace`.

### 20 — undo
`Ctrl-_` (or `Ctrl-X Ctrl-U`). One press undoes one editing group — a whole `Ctrl-U` comes back at
once, not character by character. Repeated presses walk further back, to the empty line.

### 21 — the kill ring is a ring
`Ctrl-Y` pastes the most recent kill. `Alt-Y` immediately afterwards *replaces* what was just
yanked with the kill before it, and again for the one before that. Things come back
most-recent-first; `Alt-Y` only works directly after a `Ctrl-Y` or another `Alt-Y`.

### 23 — what the kill ring keeps
`Ctrl-U` (`unix-line-discard`) cuts to the start; `Ctrl-K` (`kill-line`) cuts to the end. Both are
kills, so both go on the ring and both can be brought back with `Ctrl-Y`. Nothing in this lesson
deletes without saving except backspace and `Ctrl-D`.

### 25 — quoted-insert
`Ctrl-V` is `quoted-insert`: it takes the next keystroke literally instead of acting on it, so
`Ctrl-V Ctrl-A` puts a literal control character on the line, displayed as `^A`. This is how you
type a character the terminal would otherwise eat — a literal Tab, or an escape. It is also the
honest way to see that `Ctrl-A` *is* a character being sent, not a message about a key.

### 26 — where completion stops
`readings/st` has five matches, so Tab completes only as far as they agree — `readings/st` is
already the common prefix, so nothing appears to happen; a second Tab lists all five.
`readings/str` has three (`strain-bay1`, `strain-bay2`, `strain-bay3`), and the common prefix now
extends to `strain-bay`, so Tab fills that in and stops at the digit where they diverge. Completion
never guesses: it inserts only what every match agrees on.

### 27 — the last character
A directory completes to `readings/` — trailing slash, no space, so you can keep going. A file
completes to `strain-bay1.txt ` — trailing **space**, because the word is finished. That trailing
character is readline telling you which kind of thing it found.

### 28 — case
Nothing completes because completion is case-sensitive by default and there is no `READINGS`. The
setting is `completion-ignore-case`, currently `off`:
```
$ bind -v | grep completion-ignore-case
set completion-ignore-case off
```

### 30 — completion and quoting
Readline inserts the name with the space **escaped** — `my\ file.txt` — not quoted. That is the
same protection 01/04's quoting gives you, applied for you: without it the space would split the
name into two arguments. Completion knows about word splitting because it has to.

### 32–33 — pulling arguments
`Alt-.` gives the last argument of the previous line; pressing it again replaces that with the last
argument of the line before, and so on backwards through history. The first argument of the previous
line is `Alt-Ctrl-Y` (`yank-nth-arg`), which with no count gives the *first* argument.
```
$ bind -q insert-last-argument
insert-last-argument can be invoked via "\e.", "\e_".
```

### 35–36 — predictions
On `cat foo bar baz`: `Ctrl-W` leaves `cat foo bar `, then `cat foo `, then `cat `. On a cursor
already at the end, `Ctrl-K` kills nothing — and, importantly, kills *nothing onto the ring*, so a
following `Ctrl-Y` pastes whatever was killed previously, not an empty string. That surprise is
worth having once.

### 37–38 — the screen and the line
`Ctrl-L` redraws the screen with your half-typed line intact; `clear` is a program, so it can only
run once you press Enter, which means abandoning the line first. `Ctrl-C` abandons the line and gives
a fresh prompt — and the abandoned line is **not** in history and not recoverable. `Ctrl-U` then
`Ctrl-Y` is the recoverable version of the same gesture.

### 39–40 — looking bindings up
```
$ bind -q undo
undo can be invoked via "\C-x\C-u", "\C-_".
$ bind -p | grep '"\\C-t"'
"\C-t": transpose-chars
```
`bind -q NAME` goes from command to keys; `bind -p` prints every binding, which is the way from key
to command. From a non-interactive shell:
```
$ bash -c 'bind -q undo'
bash: line 1: bind: warning: line editing not enabled
undo can be invoked via "\C-x\C-u", "\C-_".
```
The warning is 01/01's interactive-versus-non-interactive distinction showing through: readline is
only attached when the shell is talking to a terminal. The answer is still correct because the
bindings exist regardless; nothing is listening for them.

### 41 — settings, not just keys
`bind -v` prints readline variables with their current values. Three that change completion:
```
set completion-ignore-case off
set show-all-if-ambiguous off
set page-completions on
```
`show-all-if-ambiguous on` is the one that makes a single Tab list matches instead of two.

### 42 — the editor escape hatch
`Ctrl-X Ctrl-E` (`edit-and-execute-command`) opens the line in `$EDITOR` and runs it on save. Better
than editing in place when the line is long enough that moving around it costs more than opening an
editor — a multi-line loop, or a command you want to reread before running.

### 44 — the other editor
```
$ set -o vi
$ set -o emacs
```
In vi mode you start in insert mode; `Esc` leaves it, and then `0` goes to the start of the line —
`Ctrl-A` no longer jumps anywhere. The readline variable behind it is `editing-mode`, default
`emacs`. Switching back is `set -o emacs`; a probe who does not confirm the switch back has left the
shell in a state that will confuse them later.

### 45–46 — three lookups
`Alt-?` (`possible-completions`) lists matches without inserting; `Alt-*` (`insert-completions`)
inserts every match onto the line at once, which is how you build an argument list. `Alt-#`
(`insert-comment`) prefixes the line with `#` and submits it: the line is not run but *is* stored in
history, so you can recall and uncomment it later. It is the safe way to park a dangerous command
you are not ready to run.

### 47–48 — the command list
```
$ bind -l | wc -l
173
```
Names never mentioned in this lesson include `revert-line` (undo every edit to a recalled history
line), `quoted-insert`, and `shell-transpose-words`. Entries marked "not bound" — `menu-complete`,
`copy-backward-word` and the whole `vi-*` family in emacs mode — exist because a command and a key
are separate things: the command ships with the library, and whether a key reaches it is your
configuration's business. `menu-complete` is a good example, since many people bind it deliberately.

### 49 — unix words versus shell words
`Ctrl-W` (`unix-word-rubout`) splits on whitespace only. `Alt-Ctrl-D` (`shell-kill-word`) and
`Alt-Ctrl-B`/`Alt-Ctrl-F` use the **shell's** idea of a word, which respects quoting. On
`deck-3-structural-strain-sampler-output-2187-05.log`, `Ctrl-W` and the shell-word commands both
treat the whole hyphenated name as one word, while `Alt-Backspace` chews it up one hyphen-separated
piece at a time. Three different word definitions live in the same line editor.

### 50 — the startup file
Per-user `~/.inputrc`, system-wide `/etc/inputrc`, named in `man bash` under READLINE. On this
container **neither exists**:
```
$ ls -l /etc/inputrc ~/.inputrc
ls: cannot access '/etc/inputrc': No such file or directory
ls: cannot access '/home/cadet/.inputrc': No such file or directory
```
Everything you saw from `bind -v` is readline's compiled-in default. That is why the behaviour has
been identical for every cadet on this posting.

### 51 — who actually uses readline here
```
$ ldd /bin/bash | grep -i readline
$ ldd "$(command -v openssl)" | grep -i readline
$ ldd "$(command -v perl)" | grep -i readline
```
All three print nothing. Bash on this image has readline linked **statically**, and no other program
installed here links it at all — there is no `python3`, `gdb` or `psql` on the station. So the claim
"these keys work everywhere" is true of the wider world and not demonstrable on this box. The lesson
is the check itself: `ldd` on the binary, before assuming a key will work.

### 52 — too many matches
```
$ bind -v | grep page-completions
set page-completions on
```
With it on, a long match list is paged through a pager rather than scrolled off the screen. Related
is the "display all N possibilities?" prompt, whose threshold is the `completion-query-items`
setting.
