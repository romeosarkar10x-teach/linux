# 01/04 — Solutions

> **Student: do not read this file.**
> **Agents:** steering only. See `docs/AGENT_MODES.md`.

No flag in this lesson.

**Verified against the course image.**

### 1 — assign and append
```bash
deck=3
echo "$deck"            # 3
echo "${deck}plating"   # 3plating
```
`"$deck"plating` also works — the quotes end the expansion just as the brace does.

### 2 — exit status
```bash
true;  echo $?    # 0
false; echo $?    # 1
```
Any failing command does. `ls /nonexistent` gives `2`. The specific non-zero value is the program's
own convention; only zero is standardised.

### 3 — home and cwd
```bash
echo "$HOME"   # /home/cadet
echo "$PWD"    # /labs/01-shell-and-terminal/04-variables
```

### 4 — three assignment errors
```
$ deck = 3
bash: deck: command not found
$ deck =3
bash: deck: command not found
$ deck= 3
bash: 3: command not found
```
The first two: the first word is `deck` with nothing attached, so it is a command word, and `=` and
`3` are its arguments.

The third is different. `deck=` **is** a well-formed assignment, so the shell consumes it as one,
and the next word `3` becomes the command to run. A leading assignment applies only to that
command's environment, so `deck` is *not* left set afterwards — worth checking with the student.

None of the three is a syntax error. All three parse fine; they just do not mean what was intended.

### 5 — three states
```bash
unset c; echo "[$c]"     # []
c=;      echo "[$c]"     # []
c=red;   echo "[$c]"     # [red]
```
`echo` cannot separate the first two. The colon-less default can:
```bash
unset c; echo "${c-UNSET}"   # UNSET
c=;      echo "${c-UNSET}"   #          (blank)
```
`${c+SET}` is the mirror and equally valid. `declare -p c` failing on an unset name is a third
route.

### 6 — values with spaces
```bash
n="deck 3 bay 2"
echo "$n"    # deck 3 bay 2
echo $n      # deck 3 bay 2
```
With single spaces these look identical, which is the trap. The variable is unchanged either way;
what differs is that the unquoted form is split into four separate arguments before `echo` sees it,
and `echo` rejoins them with one space each. Assign `n="deck   3"` with three spaces and the
difference becomes visible.

### 7 — removing a variable
```bash
x=1; unset x; echo "${x-GONE}"   # GONE
x=;             echo "${x-GONE}" #        (blank -- it exists)
```

### 8 — reading deck-config
| Setting | State | Expansion |
|---|---|---|
| `SAMPLE_INTERVAL=360` | set with a value | `${SAMPLE_INTERVAL:-360}` — any form works |
| `ALERT_THRESHOLD=` | set but empty | `${ALERT_THRESHOLD:-<default>}` — **colon** form |
| `RETENTION_DAYS` absent | unset | `${RETENTION_DAYS:-<default>}` |

The blank one is the exercise. The file's own comment says *"Blank value means use the built-in
default"* — so the contract requires blank to behave exactly like absent, and only the colon form
does that. Had the comment said blank means "no threshold at all", the colon-less form would be the
correct choice and the colon form would silently override a deliberate setting.

The point: the syntax follows the contract, and the contract is written in the file.

### 9 — the colon
```bash
ALERT_THRESHOLD=
echo "${ALERT_THRESHOLD:-default}"   # default
echo "${ALERT_THRESHOLD-default}"    #          (blank)
```
The colon. It always means "treat empty the same as unset", in every member of the family.

### 10 — :- versus :=
```bash
unset a; echo "${a:-d}"; echo "${a-STILL_UNSET}"    # d   then STILL_UNSET
unset b; echo "${b:=d}"; echo "${b-STILL_UNSET}"    # d   then d
```
`:-` supplies a value for this one expansion. `:=` supplies it and keeps it. Scripts usually want
`:-`, because assigning changes state that later code — or an exported child — may see.

### 11 — fail if unset
```bash
$ ( echo "${nope:?not configured}" ); echo $?
bash: nope: not configured
1
$ nope=x; ( echo "${nope:?not configured}" )
x
```
Run it in a subshell: in a non-interactive shell this form **exits**, which is exactly why it
belongs at the top of a script.

### 12 — reading report.sh (Experiment)
```
label:  3bay
padded:
title:  deck 3 bay 2
```
The middle line is the surprise. `$labelplate` is not `$label` followed by `plate` — it is a lookup
of a variable named `labelplate`, which does not exist, and an unset variable expands to nothing
without any complaint. The script does not fail; its exit status is 0. It just quietly produces
less than intended.

Same family of failure as 01/03 exercise 7: the loud errors are the easy ones.

### 13 — unquoted assignment (Experiment)
```
$ title=deck 3 bay 2
bash: 3: command not found
```
`title=deck` is a complete assignment; the space ends it; `3` becomes the command word and `bay 2`
its arguments. Afterwards `title` holds `deck` — or, if the assignment was a prefix to a command
that never ran, is not set at all. Have the student check.

Same rule as exercise 4's third case.

### 14 — reading `$?` twice (Experiment)
```
$ ls /nonexistent
ls: cannot access '/nonexistent': No such file or directory
$ echo $?
2
$ echo $?
0
```
The second reading describes the first `echo`, which succeeded. To use the value twice, save it:
`rc=$?`.

### 15 — is unset a program (Stretch)
```
$ type unset
unset is a shell builtin
```
It has to be. Variables live in the shell process; a separate program would be a child, and a child
cannot reach into its parent to delete a name. Same argument as `cd`, `export` and `read`.

### 16 — three labelled values (Stretch)
```bash
echo "pid=${$}s invoked=$0 status=$?"
```
More typically:
```bash
echo "pid=$$ invoked=$0 status=$?"
```
Braces are needed only where the next character could continue a name. After `$$`, `$0` and `$?` a
space or punctuation follows, so none are strictly required here — the honest answer to the probe is
"none of them". A student who braced everything is not wrong, just verbose.

### 17 — EDITOR fallback (Stretch)
```bash
unset EDITOR;  echo "${EDITOR:-nano}"   # nano
EDITOR=;       echo "${EDITOR:-nano}"   # nano
```
Unchanged, because the colon form treats empty as missing.

Both judgements pass:
- *Treat empty as unset* — nobody deliberately configures an editor of nothing, so a blank value is
  almost certainly a bug in whatever set it, and falling back is kinder.
- *Respect empty* — an explicitly cleared setting is a choice, and overriding it means the user has
  no way to say "none".

For `PAGER` the second argument is much stronger: an empty `PAGER` plausibly means "do not page".
That asymmetry is the thing worth them noticing.

### 18 — length (Dig)
```bash
n="deck 3 bay 2"; echo "${#n}"    # 12
unset z;          echo "${#z}"    # 0
```
`0` for unset — identical to what an empty value gives. So it measures content, not existence, and
is not an existence test. `man bash`, EXPANSION → Parameter Expansion, first form listed.

### 19 — the `:+` form (Dig)
```bash
$ SAMPLE_INTERVAL=360
$ printf '%s' "${SAMPLE_INTERVAL:+interval is set}"; echo
interval is set
$ unset SAMPLE_INTERVAL
$ printf '%s' "${SAMPLE_INTERVAL:+interval is set}" | od -c
0000000
```
Zero bytes. `od -c` showing only the terminating offset is the proof.

The trap is `echo`: `echo "${x:+...}"` in the unset case still emits a newline, so the terminal looks
empty while one byte was written. `wc -c` would show `1`. Distinguishing "nothing" from "an empty
line" matters as soon as output is piped rather than watched.

### 20 — the strict option (Dig)
```
$ ( set -u; echo "$nope" )
bash: line 1: nope: unbound variable
$ ( set -u; echo "${nope:-d}" )
d
```
`set -u` — found in `help set`. The subshell keeps it from killing the interactive session.

The exemption is what makes it usable: `set -u` catches typos and forgotten configuration, while
`${x:-default}` remains the explicit way to say "this one is optional". Without that, no script
using `set -u` could have optional settings at all.

Note for the probe: it does catch a misspelled variable *read*, which is most of its value. It
cannot catch a misspelled variable *write* — `retries=3` next to `${reties}` is caught; `reties=3`
next to `${reties}` is not.

---

## Added exercises 21–52

Only the load-bearing ones are worked here. The rest are runs whose output speaks for itself.

### 21 — three ways to write an assignment
```
$ deck = 3
bash: deck: command not found
$ echo $?
127
$ deck= 3
bash: 3: command not found
$ echo $?
127
$ deck=3
$
```
Three different readings of the same three characters. `deck = 3` is a command called `deck` with
arguments `=` and `3`. `deck= 3` is a per-command assignment `deck=` (empty) followed by the command
`3`. Only `deck=3`, with no space on either side of the `=`, is an assignment. Both failures are
status 127 — "not found" — which is the giveaway: the shell was looking for a program, not
complaining about syntax.

### 23 — keeping a literal dollar
```
$ msg='cost is $5'
$ echo "$msg"
cost is $5
$ msg="cost is $5"
$ echo "$msg"
cost is
```
Single quotes suppress expansion. Inside double quotes, `$5` is the fifth positional parameter,
which is unset here, so it expands to nothing. Backslash also works: `msg="cost is \$5"`.

### 24 — command substitution and status
```
$ names=$(cat sample-names.txt)
$ echo "$names"
...
$ bad=$(cat no-such-file)
cat: no-such-file: No such file or directory
$ echo "[$bad] $?"
[] 0
```
The trap: `$?` after the *echo* is echo's status. Check `$?` on the line immediately after the
assignment — there it is `1`, cat's status. A command substitution that fails still assigns; it
assigns the empty string, silently, unless you look.

### 25 — what a name may be
`deck3=x` assigns. `3deck=x` gives `bash: 3deck=x: command not found` — the shell refused to read it
as an assignment, so it tried to run it. Names are letters, digits and underscore, and may not start
with a digit.

### 26 — case is convention, not rule
```
$ deck=3; DECK=4; echo "$deck $DECK"
3 4
```
Two distinct variables; the shell applies no rule to case. The convention — uppercase for exported
environment variables, lowercase for your own — exists so that a reader can tell at a glance whether
a name is likely to be visible to child processes. It buys you nothing mechanically and everything in
readability.

### 27 — per-command assignment
```
$ a=1 b=2 deck-report "$a"
$ echo "after=[$a]"
after=[]
```
Two facts at once. The assignments are in effect *for that command only*: `a` is unset afterwards.
And `"$a"` in the argument list was expanded *before* the assignment took effect, so the report
received an empty argument, not `1`. Per-command assignments configure the command; they do not
build up a value for the rest of the line.

### 28–29 — the table
With `x` unset, then `x=`, then `x=' '`, then `x=hello`:

| state | `$x` | `${x:-D}` | `${x-D}` | `${#x}` |
|---|---|---|---|---|
| unset | (nothing) | `D` | `D` | `0` |
| empty | (nothing) | `D` | (nothing) | `0` |
| one space | ` ` | ` ` | ` ` | `1` |
| `hello` | `hello` | `hello` | `hello` | `5` |

The sentence: `:-` substitutes the default when the variable is unset *or* empty; `-` substitutes it
only when the variable is unset. The empty row is the only one where they disagree, and it is the row
that matters, because an empty value is what a configuration file with a blank setting produces.

### 30–31 — `deck-config`'s two kinds of missing
`ALERT_THRESHOLD=` is blank; `RETENTION_DAYS` is absent. `${ALERT_THRESHOLD-60}` treats them
differently — blank stays blank, absent becomes 60. `${ALERT_THRESHOLD:-60}` treats them the same.

`[ -z "$THRESHOLD" ]` is true for both, so it catches blank and absent alike and cannot tell them
apart. To catch only the absent one you need the shell to distinguish them for you:
`[ -z "${THRESHOLD+set}" ]` — the `+` form expands to `set` if the variable exists at all, blank or
not. The comment in `deck-config` says blank means "use the built-in default", so here the sloppy
test happens to do the right thing; on a file where blank meant "alert on everything", it would not.

### 32 — the loud form
```
$ ( echo "${nope:?missing setting}" )
bash: nope: missing setting
$ echo $?
1
```
Status 1, and the subshell died at that point — the `echo` never ran. In a script, that is the whole
point: stop where the setting is missing rather than three steps later with an empty string.

### 34–35 — who sets what
`$PWD` and `$OLDPWD` are set by the shell, by `cd` itself. Nothing you ran sets them; that is why
they are already correct in a shell you have never configured.

```
$ false
$ echo $?
1
$ echo $?
0
```
The second `0` is the status of the first `echo`, which succeeded. `$?` is always the status of the
*previous* command, and reading it is itself a command. Capture it into a variable on the very next
line if you need it twice.

### 36 — stable versus per-session
Stable across machines and days: `$HOME`, `$USER`, and — for a given account — `$PATH` and `$PS1`,
which come from startup files. Per-session: `$PWD`, `$OLDPWD`, `$$` (the shell's process id) and
`$?`. Pasting `$$` into a report and expecting a colleague to see the same number is the classic
version of this mistake.

### 37 — the prompt is a variable
`PS1=uglyprompt$ ` changes the prompt immediately; restoring the old value restores it. An accidental
`PS1=` in a startup file gives you a shell with no prompt at all — it looks hung or broken, but the
shell is working perfectly and will run anything you type. Confusing, not fatal.

### 38 — self-reference
`11`. The right-hand side is expanded fully before the assignment happens, so both `$x` are the old
value. There is no moment where the variable is half-updated.

### 40 — what braces are for
```
$ x=hello
$ echo "$xworld"

$ echo "${x}world"
helloworld
```
Without braces the shell reads the longest valid name it can, which is `xworld` — a different,
unset variable. Braces say where the name ends. This is the one case where they are not optional.

### 41 — subshell scope
`inner` then the outer value. A subshell gets a copy of the parent's variables; changes to the copy
are discarded when it exits. This is the same mechanism as 01/02's parent-and-child shells, seen from
the variable side.

### 42 — the shell without a `PATH`
```
$ ( PATH=; ls )
bash: ls: No such file or directory
```
Not "command not found" — with an empty `PATH` there is nowhere to look, and the shell's message is
about the file. Recovery inside a broken shell is `/bin/ls` by absolute path, or reassigning `PATH`,
which works because assignment is a builtin and needs no `PATH` to run. Doing it in a subshell means
there is nothing to recover.

### 43 — a report that fails loudly
```sh
#!/bin/bash
: "${DECK:?DECK not set}"
: "${SAMPLE_INTERVAL:?SAMPLE_INTERVAL not set}"
echo "deck $DECK sampled every ${SAMPLE_INTERVAL}s"
```
`:` is the do-nothing builtin; its only job here is to be a place to put the expansion. Remove one
setting and the script stops on that line with a named message instead of printing a sentence with a
hole in it.

### 44 — when a default is a bug
`${VAR:-default}` is right when the default is genuinely correct and the setting genuinely optional —
a retry count, a page width. It ships a bug quietly when the default is merely *plausible*: a missing
alert threshold silently becoming 60 means the monitoring runs, reports nothing wrong, and looks
healthy. The rule of thumb: if being wrong here would be invisible, fail instead of defaulting.

### 45 — three settings, three forms
```sh
interval=${SAMPLE_INTERVAL:-360}      # optional, a real default exists
threshold=${ALERT_THRESHOLD-}          # blank is meaningful; keep it distinct from absent
retention=${RETENTION_DAYS:?not set}   # no safe default; refuse to guess
```

### 46 — no types
Every variable holds a string; `deck=3` and `deck=three` are the same kind of thing to the shell. The
cost is that arithmetic, comparison and validation are all things you must ask for explicitly, and
nothing stops a number-shaped variable from holding a word until the moment something tries to use it.

### 47–48 — the two Dig expansions
```
$ p=/labs/01-shell-and-terminal/04-variables
$ echo "${p#/labs/}"
01-shell-and-terminal/04-variables
$ echo "${PATH:0:3}"
/op
```
`${var#prefix}` removes a matching prefix; `${var:offset:length}` takes a substring. Both are in
`man bash` under "Parameter Expansion", which is where a probe should say they found them.

### 49 — `readonly`
```
$ bash -c 'readonly r=1; r=2; echo reached'
bash: r: readonly variable
$ echo $?
1
$ ( readonly r=1; unset r )
bash: unset: r: cannot unset: readonly variable
```
Note what did *not* happen: `reached` never printed. In a non-interactive shell, assigning to a
readonly variable is fatal — the shell exits. And no, you cannot unset it; the only way out is to
end the shell.

### 50 — `declare -p`
```
$ deck=3; declare -p deck
declare -- deck="3"
$ declare -p HOME
declare -x HOME="/home/cadet"
```
The letters are attribute flags. `--` means no attributes; `-x` means exported, which is exactly the
distinction between "a variable in this shell" and "a variable children will inherit". `declare -p`
with no name prints every variable, which is a better answer to "what is actually set" than `echo`
one at a time.

### 52 — `exec bash`
```
$ x=abc
$ ( export x; exec bash -c 'echo exported=[$x]' )
exported=[abc]
$ ( exec bash -c 'echo plain=[$x]' )
plain=[]
```
`exec` replaces the shell with a new one in the same process. Unexported variables belonged to the
old shell's memory and are gone; exported ones were in the environment, which survives the replace.
It is the same parent-and-child rule from 01/02 exercise 39, minus the child — the process is reused,
but the shell's private state is not.
