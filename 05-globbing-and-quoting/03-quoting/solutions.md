# 05/03 — Solutions (agent eyes only)

> **Student: do not open this file.**

Measured in the container (bash 5.2.21, `LANG=C.UTF-8`). `names/` holds ten files:
`-report.txt`, `a;b.txt`, `` back`tick.txt ``, `captain's log.txt`, `cost$5.txt`,
`deck 03 readings.txt`, `plain.txt`, `star*.txt`, `tab<TAB>here.txt`, `two<NL>lines.txt`.

## Warmup

**1.** Single quotes: `$HOME * `` `echo hi` `` printed literally — nothing expanded. Double quotes:
`/home/cadet * hi` — the variable and the command substitution ran, the glob did not. Unquoted: the
variable, the substitution *and* the glob all ran, so the `*` became the directory listing.

**2.** One argument in all three cases. Proof: `printf '[%s]\n' a\ b` prints one bracketed line;
`printf '[%s]\n' a b` prints two.

**3.** `echo 'it'\''s'`. Four pieces: `'it'` (quoted), `\'` (an escaped single quote, outside any
quoting), `'s'` (quoted) — three pieces, concatenated into one word with no separator. Students often
say four because they count the backslash separately; either answer is fine if they can identify the
close-escape-reopen.

**4.** `ls` prints eleven lines; `ls -b` prints ten, showing `two\nlines.txt` with an escaped `\n`
and the space and tab names with backslashes. `two<NL>lines.txt` is the culprit.

## Core — the three mechanisms

**5.** `echo '$PATH is not expanded here'` and `echo "\$PATH is not expanded here"`. A third:
`echo \$PATH' is not expanded here'`.

**6.** `[a]` `[b]` — two arguments — versus `[a b]`, one argument. The unquoted expansion was split on
whitespace before `printf` ever saw it.

**7.** `$`, `` ` ``, `\`, and `!` (history expansion, interactive shells). Demonstrations:
`echo "$HOME"` expands; ``echo "`echo hi`"`` runs a command.

**8.** `$5` is positional parameter five, unset at the prompt, so it expands to nothing and the line
prints `the cost is `. Fixes: `echo 'the cost is $5'` or `echo "the cost is \$5"`.

**9.** `echo 'he said "it'\''s fine"'` and `echo "he said \"it's fine\""`.

**10.** `echo "a   b"` prints three spaces; `echo a   b` prints one. The shell split the unquoted line
into two words on whitespace and `echo` rejoined them with a single space. This is **word splitting
of the command line itself**, which is lesson 4's subject and is visible here for the first time.

**11.** `echo "*"` and `echo '*'` both print `*`. Both quotes suppress pathname expansion; they differ
only in what else they suppress, and `*` alone exercises none of the differences.

## Core — names that fight back

**12.** Quoted: ten lines. Unquoted: **15**. Splitting: `deck 03 readings.txt` → 3,
`captain's log.txt` → 2, `two<NL>lines.txt` → 2, `tab<TAB>here.txt` → 2. That is 4 extra words from
four files, 10 + 5 = 15. (The tab and newline both count as `IFS` whitespace.)

**13.** `ls | wc -l` = 11 because the newline in one name produces two lines. `ls -b | wc -l` = 10
because `-b` escapes the newline into the two characters `\n`. `printf '%s\n' *` = 11 for the same
reason as the first. **Ten** is the number of files. A robust count:
`find . -maxdepth 1 -type f -printf . | wc -c` → 10.

**14.** Three errors — `cat: deck: No such file or directory`, `cat: 03: …`, `cat: readings.txt: …` —
because the shell passed three arguments. Fix: `cat "deck 03 readings.txt"` or `cat deck\ 03\ readings.txt`.

**15.** `cat "captain's log.txt"` and `cat 'captain'\''s log.txt'` (or `cat captain\'s\ log.txt`).

**16.** `ls 'cost$5.txt'` works. Unquoted, `$5` expanded to the empty string, so `ls` was asked for
`cost.txt`: `ls: cannot access 'cost.txt': No such file or directory`, exit 2.

**17.** Measured:
```
ls: cannot access 'a': No such file or directory
bash: b.txt: command not found
```
The `;` is a **command separator**: the shell ran `ls a` and then tried to run `b.txt` as a command.
The first message is `ls` failing; the second is bash failing to find a command. `ls 'a;b.txt'`.

**18.** In an interactive shell, `` ls "back`tick.txt" `` leaves you at a continuation prompt — the
backtick opened a command substitution that is never closed. In a script it is
`unexpected EOF while looking for matching ` `` ` ``. `` ls 'back`tick.txt' `` works, as does
`` ls "back\`tick.txt" ``. The double-quoted version tried to *run* `tick.txt" ; ls "` as a command.

**19.** Not the same thing. `ls star*.txt` is a glob that happens to match one file; `ls 'star*.txt'`
is a literal name. Distinguishing test: `touch scratch/starXY.txt` — no; better, make a second match.
In `scratch/`, `touch 'star*.txt' starship.txt`, then `ls star*.txt` returns both and
`ls 'star*.txt'` returns one. Same technique as lesson 1 exercise 32.

**20.** `ls "-report.txt"` fails identically: `ls: invalid option -- 'e'`, exit 2. Quotes are consumed
by the **shell** during quote removal, so the **command** receives the same eleven characters either
way. Quoting controls what the shell does with text; it says nothing about how the command parses its
own arguments.

**21.** `ls -- -report.txt` and `ls ./-report.txt`.

**22.** `ls tab*` works. To type it: `Ctrl-V` then `Tab` inserts a literal tab, or use
`ls $'tab\there.txt'` — ANSI-C quoting, which interprets backslash escapes. Both measured.

**23.** `find . -maxdepth 1 -type f -printf . | wc -c` → 10, or
`find . -maxdepth 1 -type f -print0 | tr -dc '\0' | wc -c`. Anything that does not count lines.

**24.** Measured:
```
rm: invalid option -- 'e'
Try 'rm ./-report.txt' to remove the file '-report.txt'.
rc=1
```
All ten files survive. Identical in kind to lesson 1's `-dash.txt`: the glob matched, the command
rejected the argument, and the whole operation aborted before deleting anything.

**25.** `rm -- ./*` or `rm ./*.txt` plus the plain file, most simply `rm -- *`. The `--` (or the
`./`) handles the leading dash; the **glob** handles the spaces, because glob results are not word
split (lesson 1, exercise 35) — no quoting is needed at all when the names come from a glob directly
as arguments. Students who write `for f in *; do rm -- "$f"; done` are also correct and the `"$f"`
is doing real work there.

**26.** `mkdir dest && cp -- * dest/` — or `cp ./* dest/`. Load-bearing: the `--`. A student who
writes `cp "$f"` inside a loop needs the quotes instead.

## Core — quoting patterns, not filenames

**27.** `set -x` shows `+ grep comms.log errors.log sweep.log comms.log`. The glob expanded to three
filenames; the first became the **pattern** and the rest, plus the explicit `comms.log`, became the
files. So grep searched for the literal string `comms.log` in three files, found nothing, and exited
1 without an error message. Silent and completely wrong.

**28.** `grep '*.log' sweep.log` → `2187-05-30 03:00 pattern: *.log`. Two ways: the quotes stop the
**shell** globbing `*.log` into filenames, and they also present `*` to **grep**, where `*` means
"zero or more of the preceding" — a leading `*` in a basic regular expression is treated as a literal
asterisk by GNU grep, which is why this works. A student who notices that second point has understood
the exercise.

**29.** `SPEC_DIR` is unset, so `"$SPEC_DIR"` becomes the empty string and grep is given the **empty
pattern**, which matches every line — all four lines of `errors.log`, exit 0. Most dangerous because
it is a *success*: no error, nonzero output, exit 0. A script that pipes this into `xargs rm` deletes
everything.

**30.** `grep '$SPEC_DIR' errors.log`. Single quotes; double quotes would expand it to nothing again.

**31.** `grep '"outside spec"' comms.log` and `grep "\"outside spec\"" comms.log`. Both measured.

**32.** `grep '"panel-\*.log"'` is not needed — `grep '"panel-*.log"' errors.log` matches, because in
a basic regular expression `*` after `-` … in practice GNU grep matches the literal line here.
Which cares about what: the **shell** cares about the `*` (it would glob) and about nothing else on
that line; **grep** cares about the `*` (regex repetition) and about `-` only if the pattern started
with one, which it does not because of the leading quote character. The double quotes are literal
text to both.

**33.** `grep -E '\*\.(txt|bak)' sweep.log`, or `grep -e '*.txt' -e '*.bak' sweep.log`. Single quotes
outside so the shell never sees the `*`; the escaping inside is grep's business.

**34.** Line: `2187-05-30 03:00 pattern: *.log`. The shell's `*` means "any string, matched against
filenames"; grep's `*` means "zero or more of the previous character, matched against the line". They
are different languages that share a character, and the quote is what decides which language gets it.

## Core — command substitution

**35.** Unquoted prints `line one line two line three` on one line; quoted preserves all three lines.
Word splitting turned the newlines into argument separators and `echo` rejoined with single spaces.

**36.** `[  leading and trailing spaces  ]` versus `[ leading and trailing spaces ]`. Unquoted, the
leading and trailing whitespace became argument separators and vanished, and the interior runs
collapsed to one space each because `echo` joins its arguments with one space.

**37.** `note="$(cat note.txt)"; echo "says: $note"`. Break it by dropping the quotes on `$note`:
multiple spaces collapse and any glob character in the file would expand. (`note.txt` has none, so
have them add one to see it.)

**38.** `d=$(date +%H:%M)` and ``d=`date +%H:%M` ``. Nested: `$(basename "$(dirname "$PWD")")`
against `` `basename \`dirname $PWD\`` `` — backticks require escaping the inner backticks, and the
escaping compounds with each level. `$()` nests without any escaping and its quoting is independent
at each level.

**39.** Want it: `echo "built at $(date)"`. Security problem: `echo "$(cat untrusted.txt)"` is fine,
but `eval "echo $(cat untrusted.txt)"` or an unquoted `$(...)` whose output contains shell
metacharacters gets re-interpreted. The general rule is that data crossing back into the shell as
text is where injection lives.

## Core — fixing real scripts

**40.** On tidy names it works: for each `$DIR/*.txt` it runs `cp $f $DEST/$f.bak`. Note even here
`$f` is a **path**, so the destination is `$DEST/scratch/x.txt.bak` — with a relative `$DIR` that
usually still fails. Have them use `./tidy` as `$DIR` and watch it fail even on clean names if `$DIR`
is not `.`.

**41.** Measured on a copy of `names/`: five errors, of two kinds —
`cp: cannot create regular file '<dst>/<src-path>/-report.txt.bak': No such file or directory` and
`cp: target 'log.txt.bak': No such file or directory` (that one from the split
`captain's log.txt`). **Zero** files end up in `dst`.

**42.** Bugs:
- `for f in $DIR/*.txt` — `$DIR` unquoted, so a directory with a space in it breaks the glob.
- `cp $f $DEST/$f.bak` — both unquoted: names with spaces become multiple arguments.
- `DIR=$1` / `DEST=$2` — unquoted assignment is actually safe (no splitting on the right of `=`), and
  a student who "fixes" these has not understood; note it, do not penalise.
- **The non-quoting bug:** `$f` from the loop is a full **path**, not a basename, so
  `$DEST/$f.bak` is `$DEST/$DIR/name.txt.bak` — a directory that does not exist. Needs
  `"$DEST/$(basename "$f").bak"` or `"${f##*/}"`.
- No `--` before `$f`, so `-report.txt` is read as options even after quoting is fixed.

**43.** A correct fix:
```
DIR=$1
DEST=$2
for f in "$DIR"/*.txt; do
    cp -- "$f" "$DEST/${f##*/}.bak"
done
```
Verify: ten `.bak` files in `dst`, names intact. Note the glob still misses nothing here because all
ten names end in `.txt`.

**44.** Measured output of `./report.sh "deck 03"`:
```
deck 03: 2 entries, note says the readings for deck 03
done at 19:17 backup.sh report.sh
```
Three bugs: `$NAME` unquoted (invisible here, see 45), `$MSG` unquoted (its internal spacing is not
preserved), and the trailing `*` unquoted, which globbed into the directory listing.

**45.** The `$NAME` bug. `echo` joins its arguments with single spaces, so a name that was split into
two words is reassembled looking identical. `printf '[%s]\n' $NAME` shows `[deck]` and `[03]`. Any
command that cares about argument count — `cp`, `[`, another script — would break where `echo` did
not.

**46.**
```
printf '%s: %s entries, note says %s\n' "$NAME" "$COUNT" "$MSG"
echo "done at $(date +%H:%M) *"
```
Double quotes for `"$NAME"` and `"$MSG"` because the values must expand and then stop; double quotes
for the last line because `$(date …)` must still run while `*` must not glob. Single quotes would
have been wrong on the last line and are correct only if the `$(date)` is moved outside them.

## Experiment

**47.** `ls "$dir"/*.txt` works — eleven lines of output for nine matching files, because of the
newline name. `ls "$dir/*.txt"` fails: `cannot access 'names/*.txt': No such file or directory`,
because the `*` is inside the quotes and is therefore a literal character in the filename. First
case: the characters of `$dir` are quoted, the `/` and `*.txt` are not. Second: everything is.

**48.** Quoted: `+ cp 'deck 03 readings.txt' scratch/` — two arguments. Unquoted:
`+ cp deck 03 readings.txt scratch/` — four arguments, and `cp` reports three missing files. `set -x`
requotes its output, which is itself worth pointing out: bash shows you where the argument boundaries
are.

**49.** `echo "$(echo '*')"` prints `*`. `echo $(echo '*')` prints the directory listing — measured,
15 words. Inside the substitution the `*` was quoted and stayed literal; the substitution then
produced the text `*` into the **outer** command line, and the outer command line was unquoted, so
pathname expansion ran on it there. Quoting inside does not protect the result outside.

**50.** `echo "''"` prints `''` (two single quotes, literal inside double quotes). `echo '""'` prints
`""`. `echo ""''""` prints an **empty line**: four empty quoted strings concatenated into one empty
word, which `echo` prints as nothing plus a newline. Measured.

**51.** `echo $f` where `f='*.txt'` prints the nine matching filenames (15 words after splitting);
`echo "$f"` prints `*.txt`. Parameter expansion happens **before** pathname expansion, so an unquoted
variable's *contents* are globbed after substitution. This is the single most surprising ordering
fact in the chapter and it is why `"$f"` matters even when you think you know what is in `f`.

## Stretch

**52.** A defensible list: space, tab, newline, `*`, `?`, `[`, `]`, `$`, `` ` ``, `"`, `'`, `\`, `;`,
`&`, `|`, `<`, `>`, `(`, `)`, `#`, `~`, `!`, and a leading `-`. One command:
```
ls -A | grep -F -e ' ' -e '$' -e '*' -e ';' -e '`' -e "'" -e '?' -e '[' -e '('
```
It misses `-report.txt` — a leading dash is not a character *in* the name in any grep-able sense,
it is a position — and it double-counts the newline name. `find . -maxdepth 1 -print0` piped to a
loop is the honest tool. Any answer that identifies the leading-dash miss is full marks.

**53.** `grep -r 'sweep \*.log' .` — the outer single quotes are for the **shell**: without them
`\*` and `*` would be globbed. `sweep ` is literal to both. `\*` is for **grep**: it escapes the
regex repetition operator so it matches a literal asterisk. `.` (in `.log`) is a regex "any
character" that happens to match a literal dot — sloppy but working. The trailing `.` is the path
argument and belongs to neither language.

**54.** Measured: in an empty directory `find . -name *.txt` exits 0 and finds nothing — the
unmatched glob was passed through, so `find` got the pattern it wanted. In a directory containing
`a.txt` and `b.txt`, the glob expands and `find` gets `-name a.txt b.txt`, which is
`find: paths must precede expression: 'b.txt'`, exit 1. Fix: `find . -name '*.txt'`. Single quotes,
because `find` must receive the asterisk itself and nothing in the pattern needs expanding.

**55.** One single quote: `echo \'` or `echo "'"`. One backslash: `echo '\'` or `printf '%s\n' '\'`
or `echo "\\"`. All measured. Note `echo \\` also prints one backslash but for a different reason,
and `echo \` alone is a line continuation.

**56.** `printf '[%s]\n' '$1 "$2" '"'"'$3'"'"''` → `[$1 "$2" '$3']`. Measured. Any construction that
produces the exact string as one argument is correct; the point is that the single quote inside
forces the close-escape-reopen dance, and the `$` and `"` come free inside single quotes.

## Dig

**57.** The question: *which wall, and is what is written on it the same as what the sweep is
actually running?* `comms.log` records two different walls being referred to. You would read
`05/01`'s `spec/sweep-notes.txt` — a written-on-the-wall pattern list — and compare it with
`logs/sweep.log`, which records the patterns a sweep actually ran. They agree
(`*.log`, `*.txt`, `*.bak`), which is itself the finding: the published pattern is the real one, so
anybody who read the wall knew exactly what would be removed.

**58.** Arguing from the patterns alone: anything whose name begins with a dot (the sweep does not
set `dotglob`); anything in a subdirectory (the patterns do not recurse); anything whose name ends in
something other than those three extensions — a `~` backup, a `.partial`, a name with no extension.
Do not accept guesses about file contents.

**59.** Every name in `names/` ends in `.txt`, so all ten *match* `*.txt`. The one that survives is
`-report.txt`, and the mechanism is a **command** property, not a name property: the glob matched it,
`rm` read it as an option bundle, and the whole `rm` aborted with exit 1 having deleted nothing — so
in fact all ten survive, because of that one. A student who spots that the survivor protects the
other nine has the chapter's central mechanism a lesson early; do not confirm or deny, just note it
for the validator.

**60.** Accident half: `` back`tick.txt ``, `a;b.txt` and `cost$5.txt` are names nobody chooses on
purpose — they break the writer's own tools first, and each is the sort of thing produced by a script
interpolating an unquoted variable into a filename. Plan half: `-report.txt` is otherwise a
completely ordinary report name, contains no metacharacter at all, and its single unusual property is
a leading dash that no tool renders as strange — it does not look chosen, and it defeats a sweep.
`plain.txt` is the control that makes the comparison visible.

## Notes for the authoring/tutor agent

- Exercise 51 is the ordering fact the whole lesson rests on and it is the one students most often
  get backwards. If they can only take away one thing, take that.
- Exercises 20/24/59 deliberately re-run lesson 1's `-dash.txt` finding on a differently named file.
  The repetition is the point: it is the mechanism of the chapter incident and the student should
  meet it three times before they need it.
- `logs/comms.log` names rhea and cass and nobody else. Nothing in this lesson attributes the sweep
  patterns to any person, and no agent may.
- `report.sh`'s three bugs are countable; `backup.sh`'s are not, deliberately. Exercise 42 asks for
  "all of them" and a good student finds four including the non-quoting one.
