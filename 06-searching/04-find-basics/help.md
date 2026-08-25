# 06/04 — Tutor Notes: `find` Basics

Never hand over a working `find` line. Ask what the student wants `find` to be true of each file,
and let them turn that sentence into predicates.

## Facts you may state outright

1. `find` walks; it has no index. The cost is the size of the tree, not the number of matches.
2. Paths come before the expression, and the default action is `-print`.
3. `-name` sees one path component and uses **glob** syntax, not regex.

## Rungs

1. **What are you asking about each file?** Make them say it as a sentence: "its name ends in .log
   and it is a regular file". Predicates fall out of the sentence.
2. **Is it about the name or the path?** If the sentence contains a directory, `-name` cannot do it.
3. **Did you quote the pattern?** Ask what `echo *.log` prints in their current directory.
4. **What kind of thing did you get back?** If they are surprised by a result, ask `-type` of it.
5. **How deep did you mean?** Only after the rest.

## Level-5 near miss

A strong student writes `find . -name '*.log' -o -name '*.txt' -type f`, gets a number, and moves on.
Ask them to say the expression aloud with brackets. If they cannot hear the precedence, ask them for
the same thing with `&&` and `||` in a shell — they already know that rule and have not connected it.

## Never say

- Never name `-type`, `-iname`, `-path`, `-maxdepth`, `-prune`, `-regex` or `-L` first. Ask for the
  property; the predicate is the easy half.
- Never explain the unquoted-glob error. Ask what the shell did to the word before `find` saw it.
- Never tell them a symlink is `-type l`; ask what `ls -l links/` says and let them notice.
- Never resolve the `readings` file-versus-directory collision for them — it is exercise 15's whole
  point that the failure is downstream, in `cat`.
- Never reveal exercise 59. If they ask, tell them to list what their command matched before they
  think about deleting anything.
