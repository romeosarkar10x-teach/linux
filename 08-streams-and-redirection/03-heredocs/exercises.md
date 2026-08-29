# 08/03 — Exercises: here-documents and herestrings

```
cd /labs/08-streams-and-redirection/03-heredocs
ls -F
```

Chapters 1–8 tools. Wrecked the lab? `kestrel reset 08/03`. Write your own files under `scratch/`.

Several exercises here deliberately produce a shell **syntax error** or an unterminated heredoc. That
is the exercise. Run them in a subshell — `bash /tmp/try.sh` or `bash -c '…'` — so a broken heredoc
cannot eat the rest of an interactive session.

---

## Warmup — the shape

**1.** `cat notes/heredoc.txt`. Two decisions are named as the ones that matter. Write them down
before you run anything.

**2.** `sort <<EOF` with body `c`, `a`, `b`. What did `sort` read from, and how would `sort` know the
difference between this and `sort < afile`?

**3.** Same, but use `END` as the delimiter instead of `EOF`. Does anything change? What does that
tell you about `EOF`?

**4.** `wc -l <<EOF` with a three-line body. Now `wc -c`. Account for every byte.

**5.** Put the body of exercise 2 in a file under `scratch/` and run `sort < scratch/thatfile`.
Compare. State the one thing the heredoc version does not need.

**6.** `cat <<EOF` with an **empty** body — delimiter on the very next line. What does `cat` print,
and what is its exit status?

**7.** `grep -c deck <<EOF` with body `deck 03`, `deck 05`, `nope`. Answer? You just used a heredoc
in a place where you would normally have typed a filename.

**8.** Explain, in one sentence, why `cat <<EOF` needs no file and creates no file.

## Quoted versus unquoted — the decision

**9.** `v=05`, then run these three in turn with body `1 $v`, `2 $v`, `3 $v`:
`cat <<EOF`, `cat <<"EOF"`, `cat <<\EOF`. Write down all three outputs.

**10.** From exercise 9: how many distinct behaviours are there, and how many spellings? Which
spellings are the same thing?

**11.** Add `cat <<'EOF'` to the set. Which group is it in?

**12.** Unquoted delimiter, body `tick: $(id -un)`. What happened? Name precisely what ran and when.

**13.** Quoted delimiter, same body. Now `` `id -un` `` as well. Both survive as text?

**14.** Unquoted, body:
```
dollar: \$HOME
back: \\
```
Explain each output line. Which character did the shell consume?

**15.** Unquoted, body `$((6*7))`. Arithmetic expansion happens too. List every expansion you now
know is active inside an unquoted heredoc.

**16.** You want to write a file containing the literal text `PATH=$PATH:/opt/bin`. Write it two
ways: once with a quoted delimiter, once with an unquoted delimiter and escaping. Which would you put
in a script somebody else maintains, and why?

**17.** `unset NOPE`, then unquoted heredoc with body `field: $NOPE.` What is printed? Was there any
error, warning, or non-zero status?

**18.** Exercise 17 is the whole bug in this lab. Say in one sentence why it is worse than a command
that fails.

## The broken banner

**19.** `cat notes/page.txt`. What has cass actually observed, and what have they concluded? Keep
those separate.

**20.** `bin/mkbanner`. Read the output. Which line is wrong, and what is wrong with it?

**21.** `bin/mkbanner | wc -l`. Five lines. Which fd did they arrive on? Check.

**22.** `bin/mkbanner | sed -n 3p | cat -A`. What is between `fields:` and `and`, exactly?

**23.** `bin/mkbanner-fixed`. Compare with exercise 20 by eye first, then
`diff <(bin/mkbanner) <(bin/mkbanner-fixed)`. How many lines of diff?

**24.** Now `diff bin/mkbanner bin/mkbanner-fixed`, ignoring the comment lines. What is the actual
difference in the code?

**25.** cass said the two scripts look identical. They were reading the *output* of one and the
*source* of the other. Which single character is the whole bug?

**26.** In `mkbanner`, `$DECK` and `$SHIFT` expand correctly while `$DECK_NAME` and `$SHIFT_LEAD`
vanish. Why? Both pairs are in the same heredoc.

**27.** Careful: is `$DECK_NAME` the variable `DECK` followed by the text `_NAME`? Test it. `DECK=05;
echo "$DECK_NAME"` and `echo "${DECK}_NAME"`. What does this tell you about where a variable name
ends?

**28.** Which is the right fix here — quote the delimiter, or set the two variables? Argue for one.
The answer depends on what the banner is *for*, so say what you assume.

**29.** Copy `mkbanner` into `scratch/`, apply your fix, run it, and confirm the output. Do not edit
anything in `bin/`.

**30.** `bin/seedform SH-12 05`. It uses an unquoted delimiter on purpose. Why is that correct here,
and what would break if you quoted it?

**31.** `bin/seedform` with no arguments. Read the error. Which chapter-5 construct produced it, and
which fd did it come out on?

## `<<-` and the tab rule

**32.** `cat -A templates/tabbed.txt` and `cat -A templates/spaced.txt`. Same visible text. What is
different in the first column?

**33.** `md5sum templates/tabbed.txt templates/spaced.txt`. Different. State the difference in bytes.

**34.** Write a script in `scratch/` containing an indented function whose body is
`cat <<-END` … `END`, with the body and the closing `END` indented with **real tabs**. Run it. What
happened to the indentation?

**35.** Same script, but indent the body and the delimiter with **four spaces** instead. Run it with
`bash`. Quote the exact message you get and its exit status.

**36.** From exercise 35: two things went wrong at once. Name both. Which one caused the error, and
which one merely failed silently?

**37.** Indent the body with tabs but the closing delimiter with spaces. Predict, then test.

**38.** Indent the body with a tab followed by two spaces. What survives the strip? State the rule
`<<-` actually implements, in one sentence.

**39.** Why do you think the feature strips tabs and not spaces? (There is a historical answer, and a
practical one about how you would ever turn it off.)

**40.** Write the sentence you would put in a team style guide about `<<-`. It should tell somebody
what to configure in their editor.

## Delimiter accidents

**41.** In a script under `scratch/`, put a **trailing space** after the closing `EOF`. Run it with
`bash`. Quote the warning exactly, and record the script's exit status.

**42.** Exercise 41 exits 0 on this shell. Why is that worse than exiting non-zero?

**43.** Indent the closing delimiter by one space with a plain `<<EOF` (not `<<-`). Same failure?

**44.** Put text on the closing line after the delimiter — `EOF done`. What happens?

**45.** Use a delimiter that also appears as a line in the body. Predict the result before running it.
Then state the rule for choosing a delimiter.

**46.** Two heredocs on one command line: `cat <<'A' <<'B'` with bodies `first doc` and `second doc`.
Only one appears. Which, and why? Connect this to lesson 02's rule about the same fd twice.

**47.** Now feed two heredocs as two *separate* inputs to one command, using process substitution
from Chapter 7: `paste <(cat <<'A' … A ) <(cat <<'B' … B )`. Does it work? Why does this one not
collide?

## Herestrings

**48.** `wc -c <<<'deck 05'` and `printf 'deck 05' | wc -c`. Two numbers. Explain the difference.

**49.** `d=05`. `cat <<<"deck $d"` and `cat <<<'deck $d'`. Which quoting rules apply — heredoc rules
or ordinary Chapter 5 rules?

**50.** `read -r deck shift <<<"05 beta"`, then `echo "$deck / $shift"`. What did you avoid by not
using `echo … | read`?

**51.** `t=$'l1\nl2\nl3'`. `wc -l <<<"$t"` and `grep -c l <<<"$t"`. Both 3. Now try `<<<$t` unquoted.
Same answer? What does that tell you about splitting on a herestring?

**52.** `wc -c <<<""`. One byte. Which byte?

**53.** Rewrite `grep -c deck data/decks.txt` as a herestring over the contents of the file, without
using `cat`. (`$(< file)` is the Chapter-7 way to read a file into a string.)

**54.** When would you reach for `<<<` instead of `<<`, and when is a pipe simply better than either?

## Composition — heredocs are just fd 0

**55.** `cat > scratch/a.txt <<'EOF'` versus `cat <<'EOF' > scratch/a.txt`. Are these the same
command? Prove it rather than asserting it.

**56.** Feed a heredoc to `bash` itself: `bash <<'EOF'` with body `echo out; echo err >&2`. Where did
each line go? Redirect only fd 2 to a file and confirm.

**57.** `readlink /proc/self/fd/0 <<'EOF'` (body: anything). What is fd 0 during a heredoc on this
shell? Is it something you could open by name?

**58.** Loop with a heredoc:
```
n=0; while read -r l; do n=$((n+1)); done <<'EOF'
one
two
EOF
echo $n
```
Then the pipe version: `n=0; printf 'one\ntwo\n' | while read -r l; do n=$((n+1)); done; echo $n`.
Two different answers. Explain the difference using the word *subshell*.

**59.** Which of the two forms in exercise 58 would you use to count something you need after the
loop? What if the input genuinely comes from another command's stdout — what is your option then?

**60.** Use a heredoc to feed `sort -k2 -n` a table you type inline, then redirect its stdout to a
file and its stderr to `/dev/null`, in one command. Write it out.

## Reporting

**61.** Write cass a three-sentence answer: what the banner bug is, why both scripts looked the same
to them, and what to change. Do not use the word "obviously".

**62.** Write the one-line check somebody could run to find every other script on the station with an
unquoted heredoc delimiter. It will have false positives — say what kind.

**63.** `bin/mkbanner` has been printing a wrong line since 2186 and nobody noticed. Give two reasons
a wrong-but-plausible line survives longer than a crash.

## Experiment

**64.** Generate a small shell script with a heredoc, `chmod +x` it, and run it. Do it once with a
quoted delimiter and once unquoted, with a `$1` in the body. Which one produced a working script?

**65.** Nest a heredoc inside a heredoc — an outer one that writes a script containing an inner one.
Pick delimiters that make it readable. What is the rule you had to follow about the two delimiters?

**66.** Write a heredoc body containing the exact text `EOF` on its own line, using a delimiter that
still works. Then do it a second way, without changing the delimiter. (Hint: `<<-` and a tab.)

**67.** How long can a heredoc body be? Generate one with `seq 1 100000` into a script and run it.
Anything change about where the shell keeps the text? Check `readlink /proc/self/fd/0` inside.

**68.** Does the shell read the heredoc body before or after it runs the command? Design a test that
distinguishes the two, using a body that would only be readable at one of those moments.

**69.** `cat <<EOF` where the body contains `$(sleep 3; echo done)`. Time it. When did the sleep
happen relative to `cat` starting?

## Stretch

**70.** Write `mkform NAME DECK` in `scratch/`: it prints a blank form using an unquoted heredoc for
the two fields and escapes everything else. Run `shellcheck`-style reasoning over it by hand: list
every `$` in the body and say why each is or is not escaped.

**71.** A colleague's deployment script writes a config file with an unquoted heredoc, and the config
contains `${PORT}` placeholders meant to be filled in *later* by another tool. Describe the failure
mode in the running system, and the two-character fix.

**72.** Build a template renderer: a function that takes a template file with `$FIELD` placeholders
and produces the filled version, using a heredoc — and then say why `envsubst` or a `sed` pass is a
better answer than the clever heredoc trick.

**73.** `bin/mkbanner`'s bug would have been caught by a test that ran the script and checked its
output. Write that test as a shell function returning 0 or 1. Which line of output do you assert on,
and why not all of them?

**74.** Explain to somebody who knows Python why a heredoc is not a triple-quoted string, using fd 0
in your answer.

**75.** Chapter 8 has a wrapper somewhere that logs a tool's output to a path built from a date. You
have not been asked to find it yet. Say only which of this lesson's facts would matter if the wrapper
turned out to build that path inside an unquoted heredoc. One sentence. Do not go looking.
