# 05/05 — Help

For the tutor agent. The student is finishing Chapter 5. Everything they need was measured in
lessons 01–04 of this chapter; nothing here needs a tool they have not already used.

## Three facts the student already owns

1. `*` does not match a leading dot unless `dotglob` is set, and `*.log` does not match `*.log~`.
   Both were measured in 05/01.
2. An unquoted `$f` is word split. A filename with a space becomes two arguments. Measured in 05/04.
3. `rm -f` suppresses prompts *and* missing-file errors, so a `rm -f $f` that splits a name into two
   nonexistent names fails **silently**. `rm` still reads a leading dash as options, and that one
   fails **loudly**. Chapter 4, lesson 04.

Everything in this incident is those three facts plus a timestamp.

## The rungs

**Level 1 — where to look.** "You have a script, a log of what it did, a manifest of what was there,
and seven files that are still there. Which of those four tells you what the script *meant* to do,
and which tells you what it actually did? Start with the one you can run."

**Level 2 — read the loop as bash.** "Read `sweep.sh` out loud, but read it the way the shell does.
On the `for` line, what list does the shell hand the loop — the three patterns, or something else?
And on the `rm` line, what does the shell hand `rm`?"

**Level 3 — one file at a time.** "Take `-strain-05.log`. Was it in the list the glob produced? Yes.
So the loop tried to remove it. Why is it still here? Now do the same two questions for
`.handover-05.log`, and notice the answer comes at a completely different point in the process."

**Level 4 — design against accident.** "Seven files, and rhea only wants the arranged ones. You
cannot tell by looking at names — one of the accidents has a space in it too. What else does a file
carry that a name does not? You spent Chapter 3 on that question." If they still stall: "`ls -Al
--time-style=full-iso deck-05`. Now group them."

**Level 5 — the glob.** "What do your five have in common that the other two do not, character by
character in the name?" Then: "Your glob returns four. Which one is missing, and what did lesson 01
say about it?" Then, on the error: "`cat` is telling you it does not have an option called `r`.
Where would it have got an `r` from? Quoting will not save you here — the file really is named that.
What ends a command's options?"

**Level 5 near-miss, common:** the student writes `cat deck-05/*.log deck-05/*.log~` — two globs.
That produces the right five files but breaks the constraint and, more importantly, breaks the
ordering, so the phrase does not read. Ask them what order the words came out in and why.

## Never say

- Never name the four mechanisms. The whole lesson is deriving them from a four-line script.
- Never say "check the modification times" before Level 4, and never say "the five you want were
  written two minutes before the sweep." Give them `ls -Al --time-style=full-iso` at most.
- Never write `shopt -s dotglob` for them, and never write the glob `*.log*`. Level 5 asks the two
  questions that produce both.
- Never explain `--`. Ask what ends a command's options.
- Never spell the phrase or any of the five tags.
- **Dig stage 1:** never write the character class. The notice says `bay-NN-<something>.tar`; let
  them discover that most of the `bay-0N` files are `.txt`.
- **Dig stage 2:** never say 18, and never say `draft/panel-05-b.note`. If they start `ls`-ing all
  eighteen by hand, ask whether brace expansion produces words the shell then has to check, or words
  it checks for them — and what one command would test all eighteen at once.
- **Dig stage 3:** never say 3, and never give them `'\*'`. Make them run the unquoted version first
  and *notice it did not error*. That noticing is the point of the stage.
- **Dig stage 4:** never say `IFS=:` or which variable ends up with the token. Ask what happens to
  the leftovers when there are more fields than variables.
- Never confirm or deny any theory about who named the files. The lab does not record it. If the
  student asks, say the evidence stops at "somebody read the notice" and ask them what a name would
  add to the finding.
