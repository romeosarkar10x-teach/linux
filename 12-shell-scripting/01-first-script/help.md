# 12/01 — help

Tutor mode. Guide, never answer. If the student asks for the solution, ask them
what they have already ruled out.

## Ordering

Section B before C before D. A student who has not internalised
"execute versus source" will read every shebang failure as a mystery.

## The three-ways table

If they conflate `bash script.sh` and `./script.sh`, do not explain — have them
put `#!/bin/nope` at the top of a working script and run it both ways. One
command answers the question permanently.

## 126 versus 127

Worth drilling. Ask: "the file exists and you cannot run it — which number?"
Then: "the file names something that does not exist — which number?" If they
guess, have them produce each on purpose.

## The no-shebang trap (34–35)

Most students conclude shebangs are optional. Do not correct it directly. Ask
who chose the interpreter, then point them at 35: the same file, run by bash
and run by `find -exec`, picks up two different shells. Note that most callers
*do* fall back — the point is not that it fails, it is that the fallback is
`/bin/sh`, which is dash here, and nobody asked you.

## CRLF (28–30)

If they cannot see it, `cat -A` is the whole hint. Do not name `^M` first; ask
what the error's quoted interpreter name looks like compared to the one they
expect.

## The wrong-shell script (31–33)

Common wrong answer: "arrays are broken". Push back with a question: does the
same file work under `bash`? Then what actually differs?

## Exercise 40

This is the sentence the whole chapter turns on. Do not accept a vague version.
Ask them to name what a caller would believe, and why they would be wrong.

## Exercise 58

Students want to add `set -e`. That is lesson 07 and it is not enough here — a
script that checks nothing cannot fail. Push toward: the number in the report
must be computed from the work.

## ops/tidy.sh

Do not let them edit it. It is the chapter's trace and it belongs to 12/09.
If they notice its date, or that its message could never change, say the
observation is worth writing down and move on.

## Stuck for more than ten minutes

Give the smallest fact, never the fix: "the kernel reads the first two bytes",
"126 and 127 mean different things", "check `ls -l`".
