# 11/02 — Exercises: PATH

```
cd /labs/11-environment-and-config/02-path
ls -F
```

Chapters 1–11 tools. Wrecked the lab? `kestrel reset 11/02`. Wrecked your **shell** — commands
suddenly not found, or the wrong ones running? `exit`, then `kestrel enter`. That is not giving up;
it is exercise 46.

A convention for this lesson: `L=$PWD` first, so you can write `$L/bin` instead of the full path.

---

## Reading the list

**1.** `echo "$PATH"`. One line, colons. Now `echo "$PATH" | tr : '\n' | nl`. How many entries?

**2.** Two of those entries are the same directory. Find them with `ls -ld` on each, and say what
makes them the same.

**3.** `which -a ls`. Three lines. Reconcile that with your answer to exercise 2 — how many distinct
*files* is it showing you?

**4.** `stat -c '%i %n' /usr/bin/ls /bin/ls /opt/kestrel/bin/ls`. Confirm your answer to 3 with inode
numbers. Which chapter taught you that a shared inode means one file?

**5.** In your own words, in one sentence: what does bash do with the word `ls` after you press
Enter?

**6.** Which entry of `PATH` supplies the `ls` you actually run? Answer from exercise 1's numbered
list, not by guessing.

## Five tools, three answers

**7.** `type ls`. That is not a path. What is it?

**8.** `type -a ls`. Now you get the alias *and* the files, in order. Which one wins, and why is it
first in the list?

**9.** `which ls`. Compare with exercise 7. `which` is confident and it has just misled you — about
what, exactly?

**10.** `type -t ls`, `type -t cd`, `type -t lab`, `type -t bash`. Four words. Write them down.

**11.** `type cd`. Now `which cd`. Explain the difference in one sentence about what each program can
see.

**12.** Why can `cd` not be a program in `/usr/bin`? Answer with a sentence from lesson 01.

**13.** `command -v ls` and `command -v cd`. What does `command -v` print for the alias, and for the
builtin?

**14.** `command -v nosuchthing; echo "rc=$?"`. Now `which nosuchthing; echo "rc=$?"`. Both fail.
Which one would you use in a script, and what else does `command -v` have going for it there?

**15.** State the rule: when do you reach for `type`, and when for `which -a`?

## First match wins

**16.** `L=$PWD`. Now `PATH="$L/bin:$PATH" station-status`. Which version ran?

**17.** `PATH="$L/override:$L/bin:$PATH" station-status`. Which version now? You did not change either
file.

**18.** Swap the two directories: `PATH="$L/bin:$L/override:$PATH" station-status`. Predict before you
run it.

**19.** Same two orders, with `deck-report`. The two versions name different source directories. If
these were real, what would the consequence of the order be — beyond one line of output?

**20.** `PATH="$L/override:$L/bin:$PATH" bash -c 'type -a station-status'`. Two paths, in order. Which
list is this — the candidates, or the winner?

**21.** `PATH="$L/override:$L/bin:$PATH" bash -c 'which -a station-status'`. Same answer, different
program. Why does `which -a` get this one right when exercise 9 showed it getting `ls` wrong?

**22.** All of exercises 16–21 used the prefix form from lesson 01. `echo "$PATH"` now. Explain why
your shell is untouched.

## Shadowing

**23.** `cat override/ls`. Read it before you run it. What does it do, and what does it not do?

**24.** `PATH="$L/override:$PATH" ls`. You have just changed what `ls` means. How many characters did
that take?

**25.** `ls` is an alias in your shell — `ls --color=auto` — and the wrapper ran anyway, in front of
it. Work out why, and note that the wrapper received `--color=auto` as an argument. What is the first
word of the alias's *replacement text*, and where does bash look that up?

**26.** `override/ls` announces itself on standard error. Rewrite the sentence in its comment as a
threat model: what would a hostile version change, and would you notice?

**27.** `PATH="$L/override:$PATH" ls > /tmp/out 2>/dev/null; cat /tmp/out`. The banner is gone and the
output is right. Which chapter-8 fact makes that unsurprising, and what does it say about detecting
a wrapper by eye?

**28.** Name three things a wrapper on `ls` could hide from you without changing any file it lists.

**29.** rhea asks in `notes/page.txt` whether you could *detect* this rather than fix it. Give two
commands you would run on somebody else's terminal to answer it.

## The file that will not run

**30.** `ls -l broken/station-status`. What is missing?

**31.** `PATH="$L/broken:$L/bin:$PATH" station-status; echo "rc=$?"`. Which version ran? Was that your
prediction?

**32.** `PATH="$L/broken:/usr/bin:/bin" station-status; echo "rc=$?"`. Now there is no other copy.
Read the message and the status carefully. Is this "command not found"?

**33.** Exit status `127` and exit status `126` mean two different things. From exercises 31–32 and
one more test of your own, state both.

**34.** With `PATH="$L/broken:/usr/bin:/bin"`, run each of these and record the output *and* the exit
status: `type station-status`, `type -a station-status`, `type -t station-status`,
`command -v station-status`, `which -a station-status`.

**35.** You now have three different answers from five commands. Group them, and for each group say
what question that tool was actually answering.

**36.** Which of the five would have told you, on its own, that the command was going to fail?

**37.** `chmod +x` would fix it. Do not — instead, say what you would have wanted the *station's*
tooling to check before shipping this file.

## The hash table

**38.** `hash -r`, then `hash`. Empty. Now run `ls`, `wc`, `date`, and `hash` again. What is it
recording, and what is the `hits` column for?

**39.** `hash -t ls`. One path. Compare with exercise 6's answer.

**40.** In `scratch/`: `mkdir -p mine`, put a two-line script called `deck-report` in it that prints
something you will recognise, and `chmod 755` it.

**41.** `PATH="$L/scratch/mine:$PATH"` — this time set it in your shell, not as a prefix. Run
`deck-report`. Yours runs.

**42.** Now `rm scratch/mine/deck-report` and run `deck-report` again. Read the error extremely
carefully. Which part of it did you never type?

**43.** That is the fingerprint. Fix it with one command, and confirm `deck-report` now finds nothing
at all (there is no other copy on your `PATH`).

**44.** Put the script back, run it once, then `mv scratch/mine/deck-report scratch/mine/dr`. Run
`deck-report`. Same class of error? Now `hash -d deck-report` and try again. What is the difference
between `hash -d` and `hash -r`?

**45.** Does *assigning* `PATH` clear the hash table? Test it: `hash -r`, run `ls`, check `hash`, then
`export PATH="$PATH"` — the same value it already had — and check `hash` again. Given that result,
name the one situation in which a stale entry can still bite you.

## Editing PATH without regret

**46.** In a **throwaway subshell** — `( ... )`, so you cannot hurt yourself — run
`( export PATH=$HOME/bin; ls )` and read the failure. Now explain exercise 46's mention in the readme:
why is leaving the shell the right fix, and what did the missing `$PATH:` cost you?

**47.** The correct forms are `export PATH="$HOME/bin:$PATH"` and `export PATH="$PATH:$HOME/bin"`.
State, in one sentence each, what each one means about trust.

**48.** `mkdir -p ~/bin`, move your `deck-report` script there, and add `~/bin` to the front of your
`PATH`. Confirm with `type deck-report` that yours wins.

**49.** `exit`, `kestrel enter`, `type deck-report`. Gone. The script is still on disk. What was lost,
and which lesson makes it stick?

**50.** `PATH=":/usr/bin"` in a subshell, `cd /tmp`, create an executable file called `qq` there, and
run `qq`. It works. Explain which element of that `PATH` found it.

**51.** Write the same hazard three ways: leading colon, trailing colon, doubled colon in the middle.

**52.** Somebody argues that `.` in `PATH` is fine "as long as it's last". Give the concrete attack
that survives being last. (Hint: what happens when you typo a common command?)

**53.** What should you type instead, when you genuinely want to run something in the current
directory?

## Debrief

**54.** `notes/page.txt` again. Answer rhea's actual question: how do cass and rhea get different
output from the same word in the same directory? Name at least two mechanisms from this lesson that
would produce it.

**55.** She asks what you would need to see to say who got "the right answer". Answer her, and then
say why she put that phrase in quotes.

**56.** In three sentences: what is `PATH`, who sets it, and what does its order encode?
