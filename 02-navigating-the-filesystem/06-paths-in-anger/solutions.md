# 02/06 — Solutions (agent-eyes-only)

> **Student: do not open this file.** It contains the answers. The tutor agent may read it to know
> where it is steering, and must never quote it.

Inode numbers vary; everything else below is exact for a freshly seeded lab.

---

**1.** `ls awkward` prints **seven lines for six entries**. The six are: ` notes.txt` (leading
space), `deck 3 bay 2`, `notes.txt`, `notes.txt ` (trailing space), `panel<TAB>report.txt`, and a
name containing a newline. The newline splits that last name across two output lines.

**2.** `ls -b awkward`:
```
\ notes.txt
deck\ 3\ bay\ 2
notes.txt
notes.txt\
panel\treport.txt
two\nlines.txt
```
(The fourth line ends in `\` followed by a space.)

**3.** Any of: `cat 'awkward/deck 3 bay 2/strain log.txt'`, the same with backslashes, or
`cat awkward/deck<Tab>` completed. Contents: `strain 0.41 nominal`.

**4.**
| Name | Contents |
|---|---|
| ` notes.txt` | `filed with a leading space` |
| `notes.txt` | `no whitespace at all` |
| `notes.txt ` | `filed with a trailing space` |

**5.** `cd 'awkward/deck 3 bay 2'`, `pwd`, then `cd -`. `cd -` also prints the directory it returns
to, which is a free confirmation.

**6.** `panel<TAB>report.txt`, shown by `ls -b` as `panel\treport.txt`. The `\t` escape is what proves
it: `-Q` would print `"panel	report.txt"`, with the tab still rendered as whitespace, and `-b` is the
only one of the two that names the character.

**7.** The file is 36 bytes (`stat -c %s` on the completed name). It is more dangerous than the
tab because a newline is what nearly every tool uses to separate one filename from the next. A tab
makes a name awkward to *type*; a newline makes a name capable of *lying* to a program about how many
files exist. Exercise 28 demonstrates it.

**8.** Typing `cat awkward/note` then Tab completes to `notes.txt` — the longest common prefix of the
three candidates — and stops. A second Tab lists all three. Because one candidate is a strict prefix
of another, the student must supply the disambiguating character: after `notes.txt`, pressing Tab
again offers the trailing-space variant, which bash inserts as `notes.txt\ `. Accept any account
showing they saw the stall, saw the candidate list, and let the shell insert the escape.

**9.** `cat dashes/-audit` passes the word `dashes/-audit`, whose first character is `d`. From inside
the directory the word is `-audit`, whose first character is `-`, so `cat` parses it as options and
fails at the first letter: `cat: invalid option -- 'a'`. The file is identical in both cases; only
the word changed.

**10.** `cat ./-audit` and `cat -- -audit`. Both print `not an option, a file`.

**11.** `cat ./--help` and `cat -- --help` both work; both print `still not an option`. The
interesting case is the bare `cat --help`, which does **not** fail — it prints cat's usage message.
That is the point: a name that collides with a real option produces silent wrong behaviour rather
than an error.

**12.** `ls -audit` runs a listing with `-a` (all entries), `-u` (sort by / show atime), `-d`
(directories themselves, not their contents), `-i` (show inode numbers) and `-t` (sort by time). On
`dashes` it prints one line: the inode number and the name of the directory itself. Nothing errors,
and nothing the student wanted happened.

**13.** `cd ./-staging` or `cd -- -staging`, then `cd -`. Bare `cd -staging` gives
`bash: cd: -s: invalid option` — and note this is bash's own error, not a program's, because `cd` is
a builtin.

**14.** `ls lookalikes` reports **five** entries; a reader sees **three** distinct names
(`deck.txt`, `panel.txt`, `strain-log.txt`), two of them apparently duplicated. Two files in one
directory cannot share a name, so the eyes are wrong.

**15.** `LC_ALL=C ls -b lookalikes`:
```
deck.txt
d\320\265ck.txt
panel\342\200\213.txt
strain-log.txt
strain\342\200\221log.txt
```
Plain `ls -b` is not enough: the container's locale is `C.UTF-8`, where those characters are
printable and are printed as-is.

**16.** `strain-log.txt` → `ASCII hyphen-minus, U+002D`. `strain‑log.txt` (escaped
`strain\342\200\221log.txt`) → `NON-BREAKING HYPHEN, U+2011`. The three bytes `\342\200\221` are
UTF-8 for U+2011.

**17.** `deck.txt` → `Latin e, U+0065`. `dеck.txt` (escaped `d\320\265ck.txt`) →
`CYRILLIC SMALL LETTER IE, U+0435`, two bytes in UTF-8.

**18.** `panel\342\200\213.txt` — a ZERO WIDTH SPACE (U+200B) sits between `panel` and `.txt`. It
occupies three bytes and zero columns, so the rendered name is `panel.txt` and
`cat lookalikes/panel.txt` fails with `No such file or directory`.

**19.** Tab completion: `cat lookalikes/d` then Tab. The two candidates share only `d`, so the shell
stalls immediately; a second Tab lists both, and picking the Cyrillic one is then a matter of one
more keystroke or a menu selection. Copy-pasting the escaped form from exercise 15 is the other
acceptable route. Typing the character by hand is not — the exercise forbids it, and the point is
that they *cannot*.

**20.** `ls dotted` → 1 (`dot`). `ls -a dotted` → 7 (`.`, `..`, `...`, `..double-dot`, `.cache`,
`.hidden-note`, `dot`). `ls -A dotted` → 5 (the same minus `.` and `..`).

**21.** `...` contains `name is three dots`; `..double-dot` contains `name begins with two dots`.
Neither is `..`: `..` is an entry every directory has, created by the filesystem, which refers to the
parent. These merely start with the same characters. `cd ...` fails; `cd ..` does not.

**22.** `ls -A dotted/.cache` prints nothing, and `du -sh dotted/.cache` reports `4.0K` — the
directory's own block, with nothing inside. The `02/05` lesson is that plain `ls` cannot establish
emptiness, because it hides dot-names; the pair of a hidden-inclusive listing and a size check can.

**23.** Any non-`ls` walker: `du -ah dotted` lists `.hidden-note`, `..double-dot`, `...` and `.cache`
with no special flag; `stat dotted/.hidden-note` works with no flag; `tree` is a poor choice because
it copies `ls`'s convention and needs `-a`. Naming `tree` and explaining why it is a bad example is a
strong answer.

**24.**
| Name | Bare attempt |
|---|---|
| `metachars/$HOME.txt` | expands, fails: `cat: metachars//home/cadet.txt: No such file` |
| `metachars/glob*star.txt` | glob with no match — bash passes the word through unchanged, so it works by accident |
| `metachars/what?.txt` | same: `?` matches one character, and the literal name matches itself |
| `metachars/range[0-9].txt` | same |
| `metachars/dorn's notes.txt` | the apostrophe opens a quote; the shell waits at a continuation prompt |

The subtle finding is that three of the five *appear* to work unquoted. They work because the glob
happens to match the file itself; in a directory with different contents they would not. Quoting all
five is the right habit. A student who reports "only two needed quoting" has observed correctly; the
probe question is what makes the other three fragile.

**25.** `cat "metachars/$HOME.txt"` → `cat: metachars//home/cadet.txt: No such file or directory` —
double quotes stop word splitting but still expand the variable. `cat 'metachars/$HOME.txt'` →
`a dollar sign in the name`. Reporting the two behaviours is enough; the rules are Chapter 5.

**26.** `cat "metachars/dorn's notes.txt"` (double quotes), or backslash-escaping the apostrophe, or
tab completion, which produces `metachars/dorn\'s\ notes.txt`. Single-quoting the whole name fails
because the apostrophe *is* the closing quote — the shell ends the string at `dorn`, and then hits an
unterminated quote and drops to a `>` continuation prompt.

**27.** Predictions required in writing first.
```
ls report                 works — four entries shown (.draft hidden)
ls -b report              works — same four, escaped
cat report/-summary.txt   works — the leading dash is not the first character of the word
cd report && cat -summary.txt   FAILS — cat: invalid option -- 's'
ls report/old runs        FAILS — two arguments, neither exists
ls -a report              works — seven lines: the four above, plus .draft, plus . and ..
```
The two interesting ones are `cat report/-summary.txt` (succeeds, and teaches that the *word*, not
the file, is what matters) and, in a directory with different contents, the pattern in line 5. But
the intended answer for "interesting" is: the two that neither error nor do what was asked — plain
`ls report`, which silently omits `.draft`, and `cat report/-summary.txt`, which silently succeeds
where the same file failed one line later. Accept any pair the student argues for, provided the
argument is about *silent* behaviour rather than about which lines errored.

**28.** Prediction required in writing first. `ls awkward | wc -l` prints **7**; there are **6**
files. The rule: filenames may contain newlines, so any tool that treats "one line = one filename" is
wrong in a way that cannot be detected from its own output. This is why robust scripts use NUL
separators, which Chapters 6 and 8 return to.

Note also that `ls` behaves differently in a pipe than on a terminal — in a pipe it prints one entry
per line and does *not* substitute `?` for control characters. A student who notices that has found
something real.

**29.** `ls -RAb report` (or `-Rab`). `-R` descends into `old runs`, `-A` includes `.draft` without
the `.`/`..` noise, `-b` makes `strain 2187-06-12.csv` and `old runs` unambiguous. `-a` in place of
`-A` is fine.

**30.** `stat -c '%N %s' metachars/*`:
```
'metachars/$HOME.txt' 26
"metachars/dorn's notes.txt" 26
'metachars/glob*star.txt' 29
'metachars/range[0-9].txt' 17
'metachars/what?.txt' 22
```
`%N` quotes; `%n` does not. Note `stat` switches to double quotes for the name containing an
apostrophe — exactly the fix exercise 26 needed.

**31.** Two different inode numbers (e.g. 44738 and 44739) and two different sizes (27 and 28 bytes).
They are two distinct files. Two names can refer to one file only if they are links to the same
inode — that is Chapter 3's material, and it is a property of the *inode*, not of how the names look.
No amount of visual similarity creates it.

**32.** `ls -q awkward` prints `two?lines.txt` on a single line, substituting `?` for the newline.
`-b` also gives one line per entry; `-q` is the one that keeps the *layout* rather than the pasteable
form. `-q` is `ls`'s default when writing to a terminal, which is why the raw one-per-line output in
this lab only appears when the output is piped or captured.

**33.** `--quoting-style=WORD`. Accepted values: `literal`, `locale`, `shell`, `shell-always`,
`shell-escape`, `shell-escape-always`, `c`, `escape`. `shell-escape` is the shell-ready one;
`LC_ALL=C ls --quoting-style=shell-escape lookalikes` gives `'d'$'\320\265''ck.txt'`.

**34.** `QUOTING_STYLE`. `QUOTING_STYLE=escape ls awkward` reproduces `ls -b`'s output. On
`lookalikes` it changes nothing visible, because in a UTF-8 locale those characters are printable —
`LC_ALL=C` is still required. The flag overrides the variable.

**35.**
```
LC_ALL=C ls -b        d\320\265ck.txt
stat -c %N            'lookalikes/d'$'\320\265''ck.txt'
```
Same bytes, different wrapping. `stat`'s form is directly pasteable, because bash's `$'…'` syntax
turns the escapes back into the original bytes. `ls -b`'s bare backslash escapes are *not* processed
by bash in an unquoted word, so pasting it produces a different name. Students frequently assume the
opposite; make them test it.

**36.** `-q` / `--hide-control-chars` substitutes `?`; `--show-control-chars` prints them raw. Use
`-q` (or the escaping forms) over an untrusted connection: a filename may contain terminal escape
sequences, and printing them raw lets a name reposition the cursor, change colours, clear the screen
or — with some terminal configurations — do considerably worse. `ls` defaults to `-q` on a terminal
for exactly this reason.

---

## Added exercises 37–52

**37.** `literal`, `shell`, `shell-escape` and `escape` all print:
```
deck.txt
dеck.txt
panel​.txt
strain-log.txt
strain‑log.txt
```
`locale` wraps each in `‘…’` and `c` in `"…"`. The four agree because the terminal's locale is
UTF-8: the Cyrillic `е`, the non-breaking hyphen and the zero-width space are all **printable
characters in this locale**, so no style has anything to escape. The escaping styles only differ from
`literal` when they meet a byte the locale says is not printable.

**38.** With `LC_ALL=C`, every multi-byte character becomes unprintable bytes:
```
escape:        d\320\265ck.txt
c:             "d\320\265ck.txt"
shell-escape:  'd'$'\320\265''ck.txt'
```
**Only `shell-escape` pastes back unchanged.** `escape`'s bare backslashes mean nothing to `bash`
outside `$'…'`; `c`'s double quotes do not interpret `\320` the way C does. `shell-escape` emits
`$'…'` around exactly the bytes that need it, which is bash syntax.

**39.**
```
$ ls --quoting-style=shell-escape awkward
' notes.txt'
'deck 3 bay 2'
notes.txt
'notes.txt '
'panel'$'\t''report.txt'
'two'$'\n''lines.txt'

$ ls --quoting-style=shell-escape-always awkward
' notes.txt'
'deck 3 bay 2'
'notes.txt'
'notes.txt '
'panel'$'\t''report.txt'
'two'$'\n''lines.txt'
```
Only `notes.txt` differs. Use the "always" form when the output is being read by a program or pasted
in bulk: with it, *every* line is a quoted word, so a consumer never has to decide whether a given
line was quoted. Uniformity beats brevity as soon as something other than a human is reading.

**40.**
```
$ ls -N awkward | cat -A
 notes.txt$
deck 3 bay 2$
notes.txt$
notes.txt $
panel^Ireport.txt$
two$
lines.txt$
```
**Seven lines for six entries.** `two\nlines.txt` is one name containing a newline, so it occupies
two lines; `cat -A` also exposes the tab in `panel^Ireport.txt` and the trailing space before the `$`
on line 4.

**41.**
```
$ ls --zero awkward | cat -A
 notes.txt^@deck 3 bay 2^@notes.txt^@notes.txt ^@panel^Ireport.txt^@two$
lines.txt^@
```
NUL is safe because **it is the one byte a filename may not contain**. A path is a NUL-terminated
string at the kernel interface, so the kernel could not store a name containing one. Newline, tab,
space, quotes and backslash are all legal in a name; NUL alone is structurally impossible, which is
why every careful tool pair (`find -print0`, `xargs -0`, `ls --zero`) settled on it.

**42.** `QUOTING_STYLE=shell-escape ls awkward` reproduces exercise 39's first listing exactly. The
cost of setting it permanently: your `ls` output stops matching everyone else's. Documentation,
tutorials and your own scripts' expectations assume the default, and a name you can now paste is a
name you can no longer read at a glance. Worse, a colleague at your keyboard sees quoting they did
not ask for and mistakes it for part of the name.

**43.**
```
$ ls dotted        → dot
$ ls -a dotted     → .  ..  ...  ..double-dot  .cache  .hidden-note  dot
$ ls -A dotted     → ...  ..double-dot  .cache  .hidden-note  dot
```
`-A` drops exactly `.` and `..`. Those two are not hidden files that happen to start with a dot: they
are directory entries the filesystem itself maintains, pointing at this directory and its parent.
Every other dotted name here is an ordinary file whose only distinction is the leading character.
Note that `...` and `..double-dot` survive `-A` — they merely *look* like the special entries.

**44.** `ls --ignore='*.txt' awkward` leaves:
```
deck 3 bay 2
notes.txt 
```
`notes.txt ` has a **trailing space**: its name ends in a space, not in `.txt`, and `*.txt` requires
the name to end in exactly those four characters. The pattern matches against the whole name, and one
invisible byte at the end defeats it. This is the entire lesson of the lab in
one flag: the eye reads `notes.txt`, the matcher reads `notes.txt `.

**45.**
```
$ ls --hide='notes*' awkward
 notes.txt
deck 3 bay 2
panel	report.txt
two
lines.txt

$ ls -a --hide='notes*' awkward
 notes.txt
.
..
deck 3 bay 2
notes.txt
notes.txt 
panel	report.txt
two
lines.txt
```
**`--hide` is cancelled by `-a` (and `-A`); `--ignore` is not** — `ls -a --ignore='notes*'` still
suppresses them. Use `--ignore` in a script: its behaviour does not change depending on which other
flags someone later adds. `--hide` is a convenience for interactive use, where `-a` meaning "no,
really show me everything" is what you want.

**46.**
```
$ ls -1i lookalikes
300198 strain-log.txt
300199 strain‑log.txt
300200 deck.txt
300201 dеck.txt
300202 panel​.txt
```
Five distinct inodes, so five distinct files. Two names could refer to one file only if they were
hard links — same device, same inode — which these are not and, for names that differ in their bytes,
would have to be created deliberately.

**47.**
```
$ ls -Rb report
report:
-summary.txt
old\ runs
strain\ 2187-06-12.csv
strain\ 2187-06-13.csv

report/old runs:
run\ 1.log
run\ 2.log

$ ls report/old\ runs    → run 1.log   run 2.log
$ ls "report/old runs"   → run 1.log   run 2.log

$ ls report/old runs
ls: cannot access 'report/old': No such file or directory
ls: cannot access 'runs': No such file or directory
```
The unquoted form is **two arguments**, `report/old` and `runs`. In this lab both fail. Change the directory names slightly — a real `report/old` beside a real
`runs` — and it succeeds, listing two directories that have nothing to do with the one you meant,
with no error and no indication anything went wrong. **Silent success on the wrong target is worse
than any error**, because nothing prompts you to look.

**48.**
```
$ printf '%q\n' metachars/*
metachars/\$HOME.txt
metachars/dorn\'s\ notes.txt
metachars/glob\*star.txt
metachars/range\[0-9\].txt
metachars/what\?.txt
```
`dorn's notes.txt` gets **two** escapes — the apostrophe and the space. `range[0-9].txt` gets both
brackets escaped. `%q` uses backslashes rather than quotes precisely so it never has to solve the
"apostrophe inside single quotes" problem that exercise 26 made you solve by hand.

**49.**
```
$ stat -c '%N %s' metachars/*
'metachars/$HOME.txt' 26
"metachars/dorn's notes.txt" 26
'metachars/glob*star.txt' 29
'metachars/range[0-9].txt' 17
'metachars/what?.txt' 22
```
`%N` prefers single quotes, but a name containing an apostrophe cannot be single-quoted, so for that
one line it switches to double quotes. This is the same rule a careful human applies: use the quote
character the name does not contain. It is not shell-safe in general — inside double quotes, `$HOME`
would expand — which is why it is a *display* quoting, and `%q` or `shell-escape` is what you paste.

**50.**
```
$ cd 'awkward/deck 3 bay 2' ; pwd
/labs/02-navigating-the-filesystem/06-paths-in-anger/awkward/deck 3 bay 2
$ cd - ; pwd
/labs/02-navigating-the-filesystem/06-paths-in-anger/awkward
```
`cd -` reads `$OLDPWD`, which the shell set when you last changed directory. It survives spaces
because the path never passes through the command line at all: the shell holds it as one string and
hands it straight to `chdir`. Retyping the path by hand reintroduces every quoting hazard the lab is
about.

**51.** A filename may contain any byte except `/` and NUL, including the ESC that begins a terminal
control sequence. `ls -N` writes those bytes straight to the terminal, so a name can move the cursor,
repaint earlier lines, change colours, or — on terminals with title-setting and title-reporting both
enabled — arrange for text of the attacker's choosing to appear as if you had typed it. `ls -q`
replaces every non-printable byte with `?`, and `ls -b` replaces it with a visible backslash escape
that also tells you which byte it was. **`-q` is the default when output is a terminal**; use `-b`
when reading a directory that someone else can write to, because it is both safe and diagnostic.

**52.**
```
$ stat -c '%N' lookalikes/dеck.txt
'lookalikes/dеck.txt'

$ LC_ALL=C ls --quoting-style=shell-escape lookalikes
'd'$'\320\265''ck.txt'
```
**`shell-escape` round-trips.** Its `$'\320\265'` is bash syntax for those two exact bytes, so the
word survives being pasted into any command. `%N`'s output is quoting for a *reader*: it makes the
boundaries of the name visible, and in a UTF-8 terminal it does not escape the Cyrillic character at
all — which is precisely the confusion the lab exists to teach you about.

---

## Tutor notes

- Exercises 14–19 are the chapter's incident in miniature. A student who finishes them can solve
  `07-incident-02`; one who fakes them cannot. Weight your time here.
- Do not let a student rename anything. If they have, `kestrel reset 02/06` restores the lab.
- Exercise 24's "three of them work unquoted" result surprises people who were told globs are
  dangerous. The mechanism — a glob with a literal match — is Chapter 5's, and it is fine to leave
  it as an observation here.
- Exercise 27's answer is deliberately arguable. Grade the argument.
- Nothing in this lesson names the arc. The story page's "whether that was carelessness" is the only
  gesture toward it and must not be expanded.

## Flags

None. Chapter 2's flag is in `07-incident-02`, which uses every technique in this lesson.
