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
