# 05/01 — Exercises: Globs

Work in `/labs/05-globbing-and-quoting/01-globs`.

```
cd /labs/05-globbing-and-quoting/01-globs
ls
```

Two rules for this whole lesson:

- When an exercise says **predict**, write the prediction down before you run anything.
- `echo` is your friend here. `echo <pattern>` shows you what the shell turned the pattern into
  without running anything against it. Use it before you point a real command at a glob.

If you mangle the lab: `kestrel reset 05/01` from the repo root.

---

## Warmup

**1.** `cd panels`. Run `ls`, then `echo *`. Same names? Same *order*? Same *layout*? Describe the
difference in one sentence, and say which of the two programs did the sorting each time.

**2.** `echo *.log` and then `ls *.log`. Now say precisely what arguments `ls` received. Not "a
pattern" — the actual list.

**3.** `echo *.zip`. Report the exact output. Then `ls *.zip` and report the exact error. Explain the
error in terms of what `ls` was actually handed.

**4.** `ls *.log | wc -l`. How many? Now `ls | wc -l`. Why do the two numbers differ, and which
files account for the difference?

---

## Core

Exercises 5–20 are in `panels/`. There are fourteen entries in it and the names are not as regular
as they look.

**5.** `ls -A panels` from the lab root. List every entry whose name is *not* of the form
`panel-NN.log`. There are four.

**6.** `echo panel-??.log`. How many names? Which panel logs did it miss, and why does the pattern
exclude each one?

**7.** `echo panel-0?.log` and `echo panel-1?.log`. Together, do they cover every `panel-NN.log`?
Which names are in neither?

**8.** Predict `echo panel-[0-9].log` before you run it. Most people predict all twelve. Run it.
Explain the actual result in one sentence about what `?` and `[0-9]` each match.

**9.** Write a pattern that matches **exactly** the twelve panel logs — the ten two-digit ones,
`panel-7.log`, and `PANEL-09.LOG` — and nothing else. Test it with `echo`. (There is more than one
answer; `*` in the middle is allowed.)

**10.** `echo *.log*`. Which extra name did the trailing `*` pull in? Say why `*.log` did not match
it, given that `*` matches "any string including the empty string".

**11.** `echo [!p]*`. One name. Explain why the other thirteen are excluded, and say what `[!p]`
matched in the one that survived.

**12.** Globs are case-sensitive here. Prove it two ways: a pattern that catches `PANEL-09.LOG` and
misses the lowercase ones, and a pattern that catches all of them regardless of case. (`[Ll]` is the
technique; there is no case-insensitivity flag in a plain glob.)

**13.** `shopt nocaseglob` — is it on? Turn it on, run `echo panel*`, turn it off, run it again.
Report both. Then say why a script that relies on `nocaseglob` is a script that breaks on somebody
else's machine.

**14.** `echo .*` in `panels/`. What did you get? Now: on most systems for the last thirty years,
that pattern also matched `.` and `..`. Run `shopt globskipdots`, then turn it off, run `echo .*`
again, and turn it back on. Report the difference.

**15.** Given exercise 14: explain in two sentences why `rm -rf .*` was a famous way to destroy your
own home directory, and what `globskipdots` changed about it. (Do not run it. Anywhere. Ever.)

**16.** `echo *` misses `.panel-00.log`. `shopt -s dotglob`, run `echo *` again, `shopt -u dotglob`.
Which entries appeared? Is the leading dot a filesystem property or a shell convention — and what is
your evidence?

**17.** With `dotglob` **off**, write a single pattern that matches `.panel-00.log` and no other
entry in `panels/`.

**18.** `ls -d panel-0[135].log`. Explain the `-d`, then explain the `[135]` — is it a range, a set,
or both?

**19.** `echo panel-[0-1][0-9].log`. Which names match? Now `echo panel-[01][0-9].log` — same
result? What, if anything, does the `-` do inside brackets when the characters either side of it are
adjacent?

**20.** Count with a glob instead of with `ls`: `printf '%s\n' panel-*.log | wc -l`. Why is
`printf '%s\n'` a more honest way to count an expansion than `ls | wc -l`? (Think about a filename
with a newline in it.)

Exercises 21–28 are in `readings/`.

**21.** `cd ../readings`. `echo *` and count. Thirteen files, twelve of which are a regular series.
Which one is not, and what is the series?

**22.** Write one pattern that matches every extract from 2187-05-17 and nothing else. Then one that
matches every 0800 extract across all six days.

**23.** Write one pattern that matches the four extracts from 2187-05-15 and 2187-05-16 only, using
a bracket expression rather than two patterns.

**24.** `echo *.txt` and `echo *.txt*`. One name is in the second and not the first. Which, and why
does the filename end the way it does?

**25.** Predict, then run: `echo 2187-05-1[5-9]-*.txt`. How many? Now `echo 2187-05-[12][05]-*.txt` —
predict this one carefully, then run it, and explain any name you did not expect.

**26.** A glob matches names, not contents. Prove it: find every reading with `strain 0.47` in it
using `grep` — no globs beyond `*.txt` — and then say why no pattern in this lesson could have
selected exactly those.

**27.** Two patterns can produce the same set on today's data and different sets tomorrow. Give an
example from `readings/` — two patterns, currently identical output, and one filename that would
split them — and say which of the two you would put in a script.

**28.** `ls 2187-05-2*` and `ls 2187-05-3*`. One works and one errors. Now `ls 2187-05-2* 2187-05-3*`
— report what `ls` prints, its exit status, and how many of the two patterns it actually listed.
This is the behaviour that makes an unmatched glob dangerous inside a longer command line.

Exercises 29–36 are in `mixed/`. These names are the point of the lesson.

**29.** `cd ../mixed`, then `ls -A`. Eleven entries. For each of the following, name every entry it
matches: `*`, `*.txt`, `?.txt`, `*~`, `[a-z]*`, `[[:upper:]]*`, `[[:digit:]]*`.

**30.** `[a-z]*` misses `A.txt`. It also misses `-dash.txt`, `1st.txt`, `README` and `[set].txt`.
Explain the misses in terms of byte values, then check yourself: `printf '%d\n' "'A" "'a" "'-" "'1"
"'["`. Which of those five bytes fall inside the range `a`–`z`?

**31.** In `C.UTF-8`, `[a-z]` is a byte range. On a machine set to `en_US.UTF-8` the same pattern
matches `A.txt` as well, because that locale collates `aAbBcC…`. Which of the two behaviours does
`[[:lower:]]` give you? Test it here, and say which of `[a-z]` and `[[:lower:]]` you would write in
something you expect somebody else to run.

**32.** `star*.txt` and `what?.txt` have a `*` and a `?` **in the filename**. Run `echo star*.txt`.
Did it match the file because the name contains a star, or because the pattern's star matched the
empty string? Design a test that distinguishes those two explanations, run it, and report.

**33.** Write a pattern that matches `star*.txt` and **only** because of the literal asterisk in its
name — that is, a pattern in which the `*` character is not acting as a wildcard. (Brackets are the
tool: what does `[*]` mean?)

**34.** Do the same for `what?.txt` and for `[set].txt`. The last one is harder than it looks —
report what `echo [set].txt` does before you fix it, and explain that output.

**35.** `echo two*` matches `two words.txt` — a filename with a space in it. Predict how many
arguments `ls two*` passes to `ls`: one, or two? Run `ls two*` and `ls -l two*` and count the lines.
Then run `ls $(echo two*)` and count again. The two results differ, and the difference is the whole
of lesson 4 in one line: say which of the two mechanisms splits on the space and which does not.

**36.** `-dash.txt` starts with a dash. Run `ls *dash*` and then `ls -dash.txt`. Report both. Then
list it successfully, two different ways. (Chapter 4 taught you both.)

---

## Experiment

Write the prediction first. The wrong half is the exercise.

**37.** Predict what `set -x` will print for `ls *.log` in `panels/`. Then `set -x`, run it, and
`set +x`. Report the `+` line verbatim. What does this prove about which program does the expansion?

**38.** In `empty/`: predict the output and exit status of each of these, then run all four.
```
echo *
ls *
shopt -s nullglob; echo "[" * "]"; ls *; shopt -u nullglob
shopt -s failglob; ls *; shopt -u failglob
```
For the `failglob` one, predict whether `ls` runs at all.

**39.** Still in `empty/`: predict what `rm *.tmp` does with `nullglob` **on**. Then predict what
`cp *.tmp dest/` does with `nullglob` on. Do not run the second one against anything you care about
— run it here, where the directory is empty, and report the error. Explain why `nullglob` makes some
commands safer and others worse.

**40.** In `deep/`: predict the output of `echo deck-03/*/*` — how many entries, and of what kind.
Run it. Then predict `echo deck-03/*/*/*` and run that. Explain the shape of both results.

**41.** `shopt -s globstar`. Predict, then run, in `deep/`: `echo **/*.txt`, `echo **/`,
`echo deck-03/**`. Then answer: `deep/archive/2187-04.txt` is reachable by two paths, because
`deck-03/archive-link` is a symlink to `../archive`. Did any of the three patterns list it *through
the link*?

Now run these four and count the matches containing `link` in each:
```
cd deep;  printf '%s\n'   **/*.txt | grep -c link
          printf '%s\n' ./**/*.txt | grep -c link
cd ..;    printf '%s\n' deep/**/*.txt | grep -c link
cd deep;  printf '%s\n' **/ | grep -c link
```
Three of those four numbers agree and one does not. Report all four, and state the rule you have
just discovered as carefully as you can — it is about what appears *before* the `**`, and it is not
documented anywhere you will find easily.

**42.** Predict which of these two prints more names, and by how much, then run both:
`echo deep/*/*/*` versus `shopt -s globstar; echo deep/**`. Explain the difference in one sentence
that mentions directories.

---

## Stretch

**43.** Write a single command that prints, one per line, every file under `deep/` whose name ends
in `.txt`, using only globbing — no `find`, no `ls -R`. Then write the `find` version. Say one thing
each version does that the other cannot.

**44.** `nullglob` and `failglob` are both "fix the unmatched glob" options and they fail in opposite
directions. Write two short shell snippets: one where `nullglob` is the correct choice and
`failglob` would be wrong, and one where it is the other way round. Two or three lines each, and say
which line is the one that matters.

**45.** Turn on `dotglob` and `nullglob` together, then run `echo *` in `empty/` and in `mixed/`.
Now explain, in one sentence, why a cleanup script that enables both is *more* dangerous than one
that enables neither.

**46.** Bash has one more pattern syntax, off by default: `shopt -s extglob` gives you `!(pattern)`,
`@(a|b)`, `+(x)`, `?(x)` and `*(x)`. Turn it on **in a script file**, not on the command line — find
out the hard way why (`shopt -s extglob; echo !(a*)` on one line does not work) and explain it.
Then use `!(...)` to list everything in `mixed/` that is **not** a `.txt` file.

**47.** Write a pattern that selects, from `panels/`, exactly the logs for panels 1 through 6 — and
no others — given that one of the twelve panels is misnumbered. State whether your pattern is
correct because of the data or correct because of the pattern, and what would break it.

**48.** `ls -d */` is the standard idiom for "directories only". Run it in `deep/deck-03`. Then
explain, precisely, why the trailing slash restricts it to directories, and what happens to
`archive-link`. Compare with `ls -d */.` and say what changed.

---

## Dig

**49.** `cat ../spec/sweep-notes.txt`. Housekeeping's sweep removes `*.log`, `*.txt` and `*.bak` from
a directory it is pointed at, with no recursion and no `dotglob`. Run those three patterns yourself
in `panels/`, `readings/` and `mixed/` — with `echo`, not `rm` — and write down, per directory, what
would survive.

**50.** From your exercise 49 lists: which surviving names survive because of the *dotglob* rule,
which because of the *no-recursion* rule, and which because of neither — that is, names that simply
do not match `*.log`, `*.txt` or `*.bak` even though they are ordinary files sitting right there?

**51.** For each of the four survivor categories you can construct — a name beginning with a dot, a
name ending in `~`, a name with no extension, a name beginning with `-` — say which of the three
sweep patterns it defeats and *why*. One sentence each. Do not speculate about intent; describe
mechanism.

**52.** The sweep note says the pattern "has not changed in four years" and is "written on the wall
in engineering". State one thing that fact makes possible, and one thing it does not prove. Keep
both to a sentence, and keep the second one strict.
