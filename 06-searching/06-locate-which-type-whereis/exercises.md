# 06/06 — Exercises: `locate`, `which`, `type`, `whereis`

```
cd /labs/06-searching/06-locate-which-type-whereis
cat notes/handover.txt
cat notes/paths.txt
```

Exercises 20 onwards assume you have run the `export PATH=…` line from `notes/paths.txt` in your
current shell. `exec bash -l` undoes it. Do not edit `~/.bashrc`.

---

## The index, before you touch it

Do these **before** running `updatedb`. Once you rebuild the index you cannot get this state back
without `kestrel reset` and a rebuilt container, so read each one first.

**1.** `locate strain`. One line. Read the path carefully — it is not a strain log. Where in that
path does the word `strain` appear?

**2.** From exercise 1: what is `locate` matching against — the file name, the full path, or a glob?
State it precisely.

**3.** `locate /labs`. One line, and it is a man page. Same lesson as exercise 2, said differently.

**4.** `find /labs/06-searching -name '*strain*' | wc -l`. Compare with `locate -c strain`. Two tools,
two answers, both correct. Correct about what?

**5.** `locate strain; echo "rc=$?"`. Status 0, one hit. Now imagine it had printed nothing. What
would status 0 with no output have told you, and what would it *not* have told you?

**6.** `ls -l /var/cache/locatedb` and `stat -c '%y' /var/cache/locatedb`. When was the index built?
Compare with `date`. How stale is it?

**7.** `locate -c ''` counts every path in the database. Write the number down. Compare it to
`find / -xdev 2>/dev/null | wc -l` if you have the patience — and time both.

**8.** `updatedb` as yourself. Quote the error and the exit status. Why does building this index
need root, given that reading it does not?

## The index, after you rebuild it

**9.** `sudo updatedb`, then `locate -c strain`. The number changed. By how much, and what did those
files have in common before?

**10.** `locate strain | head -20`. These are from chapters you have already done. Is `locate` a
reasonable way to find a lab you half-remember? Say when it is and when it is not.

**11.** `locate -b strain-2187-06-03.log`. One hit. What did `-b` change about the match?

**12.** `locate -i STRAIN | wc -l` versus `locate STRAIN | wc -l` versus `locate strain | wc -l`.
The case-insensitive count is one higher than the lowercase count. Find the extra file and say why
it is the only one.

**13.** `locate -r 'strain-2187-06-0[39]\.log$'`. Two hits. What kind of regex is that — BRE or ERE?
(Lesson 03 has the vocabulary. Check by trying `\|` and `|`.)

**14.** `locate -l 3 strain`. What did `-l` do, and is the result the *first* three in any meaningful
order?

**15.** `rm archive/panel-index-05.txt`, then `locate panel-index-05`. The file is gone and `locate`
still prints it. Explain in one sentence.

**16.** Same command with `-e`. No output, and note the exit status. What is `-e` doing, and what is
it costing you?

**17.** Restore the file (`printf 'panel index, deck 05\n' > archive/panel-index-05.txt`), then
`locate panel-index-05` again — without running `updatedb`. Now `touch scratch/vanish.log` and
`locate vanish`. Two different kinds of wrong answer in two commands. Name each.

**18.** Write one sentence you would put in a runbook telling a colleague when `locate` is the right
tool and when it is not.

**19.** `locate -0 strain | tr '\0' '\n' | wc -l`. Same count as before. Why does `-0` exist, and
which lesson-05 flag is it the twin of?

## Which command will actually run

From here on, set your `PATH`:

```
export PATH="$PWD/tools:$PWD/tools-b:$PATH"
```

**20.** `which strain-report`. Which of the two copies? Now `cat` both files and say whether the
winner is the newer one, the better one, or neither.

**21.** `which -a strain-report`. Two lines, in an order that is not alphabetical. What order is it?

**22.** `strain-report`. Which version ran? Does it agree with exercise 20?

**23.** `which echo`. It prints a path to a real, executable file. Now run `echo hello`. Explain the
contradiction.

**24.** `type echo`, then `type -a echo`. How many `echo`s are there on this system, and which one
wins?

**25.** `type -P echo`. What does `-P` mean, and when would you want it?

**26.** `which cd`, and its exit status. Then `type cd`. Which of the two answered the question you
asked?

**27.** Define an alias: `alias panel-check='echo aliased'` (you may need `shopt -s expand_aliases`
if you are running this from a script). Now `which panel-check`, `type panel-check`, `command -v
panel-check`. Three different answers, and one of them is empty. Account for each — and note the exit
status of the empty one before you decide what it means.

**28.** Define a function: `deck-scan() { echo "function version"; }`. Now `which deck-scan` — it
prints a file path, with status 0. Run `deck-scan`. What ran? State the general rule about why
`which` cannot get this right, in terms of processes.

**29.** `type -t` on each of `echo`, `cd`, `if`, `deck-scan`, `strain-report`, `nosuchcmd`. Six
answers, one of them empty. Write the five categories down; this is the list the whole lesson is
about.

**30.** `type if`. `if` is not a command at all. What is it, and what would `which if` say?

**31.** `command -v` on the same six names. Compare with `type -t`. Which output would you rather
parse in a script, and why?

**32.** `command -v nosuchcmd; echo "rc=$?"`. Now write the one-line guard clause a script should use
to require a tool, with a useful error message.

**33.** `command -V echo` versus `type echo`. Any difference? Say which one you would type from
memory.

**34.** `\strain-report` with a leading backslash, while the alias from exercise 27 is defined for
that name too (`alias strain-report='echo ALIASED'`). What does the backslash suppress, and what does
it *not* suppress?

**35.** `command -pv echo` — `-p` uses a default `PATH` instead of yours. It still says `echo`. Why
did `-p` not help, and what would it have helped with?

## The file that cannot run

**36.** `ls -l tools/panel-check`. What is missing?

**37.** `type panel-check` and `command -v panel-check` (with the alias from 27 removed —
`unalias panel-check`). Both report the path, with status 0. Now run `panel-check`. Quote the error
and the exit status.

**38.** Exercise 37 is a genuine surprise: the shell's own lookup reported a file it will refuse to
execute. What does that mean for a script that tests `command -v foo` before running `foo`, and how
would you write the test properly? (`[ -x … ]` is the other half.)

**39.** `which panel-check` and its status. `which` disagrees with `type` here, and this time
`which` is arguably right. Say why, and note that being right for the wrong reason is still a bad
tool.

**40.** Make it runnable (`chmod +x tools/panel-check`) and re-run exercises 37 and 39. Then put it
back with `chmod 644`.

## `PATH` order and `hash`

**41.** `echo "$PATH" | tr ':' '\n' | head -5`. Read the order aloud. Which directory would you have
to be able to write to in order to shadow `grep` for your own shell?

**42.** `PATH="$PWD/tools-b:$PATH" bash -c 'strain-report'`. Different version. You changed nothing on
disk. What did you change?

**43.** `hash -r`, then `strain-report`, then `hash`. What is in the table, and what is the `hits`
column?

**44.** With the table warm, prepend `tools-b` to `PATH` in the *same* shell and run `strain-report`
again. Predict "still the cached one" — then run it. You are wrong. What did assigning to `PATH` do
to the hash table?

**44b.** Now build the case that *does* stick: with `tools-b` first on `PATH` and `strain-report`
already hashed from `tools-b`, copy a new script into `tools/`… no — that is behind you on `PATH`.
Work it out: which directory must you drop a file into, relative to the cached one, for the cache to
be wrong? Do it in `scratch/`, and confirm with `type` before and after `hash -r`.

**45.** You have just installed a newer version of a tool and "it is still running the old one".
List, in order, the three things you would check.

**46.** `type strain-report` after `hash -r` versus before. Does `type` report the cached path or the
`PATH` search? Check the bash manual (`help type`) and say what `-a` does about caching.

## `whereis`

**47.** `whereis grep`. Four paths. Categorise each one: which is the binary, which is the manual,
which is something else?

**48.** `whereis -b bash` and `whereis -m bash`. What do the two flags select?

**49.** `whereis -l | head`. What is this list, and where did it come from? Is `$PATH` in it?

**50.** `whereis nosuchcmd; echo "rc=$?"`. Quote the output and the status exactly. Why does this make
`whereis` unusable in an `if`?

**51.** `whereis strain-report`. It found both copies in the lab. Given exercise 49, how? Try again
from a shell where `PATH` does not include `tools/` (`env -u PATH …` or a fresh `bash -l`).

**52.** Three tools, one table. For each of `locate`, `which`, `type`, `whereis`, write one line:
what question it answers, what it searches, and one situation where it gives a confidently wrong
answer.

## Experiment

**53.** Make a file in `scratch/` called `ls`, make it executable, put `scratch/` first on `PATH`,
and run `ls`. Then get the real `ls` to run three different ways without changing `PATH` back.

**54.** Build the case where `which` and `type` disagree in the *other* direction: `type` finds
something and `which` finds nothing. (Two ways; you have both already.)

**55.** `enable -n echo` disables the builtin for this shell. Now run `echo hello`. What ran? Restore
it with `enable echo`. What does this prove about the "builtins always win" rule?

**56.** Time it: `time locate strain` versus `time find / -xdev -name '*strain*' 2>/dev/null`. Report
both. Then say what you would have to add to the `locate` time to make the comparison honest.

## Stretch

**57.** Write a shell function `whichreally NAME` that prints what will actually run, handling
aliases, functions, builtins, keywords and files, and exits non-zero if the name does not resolve.
Use `type -t` to branch. Test it on all six names from exercise 29.

**58.** `updatedb` has a config file that controls what it indexes and what it skips (`man updatedb`,
`man updatedb.conf`). Name two directory types it excludes by default and say why each exclusion is
correct. Then check whether this station has that config file at all, and whether `/proc` ended up in
the index. Do not assume the answer from the man page.

**59.** Your colleague reports "`locate` says the file is there but I cannot open it". Give three
distinct explanations, only one of which involves the index being stale.

**60.** `type -a echo` listed four file paths. Explain why a system has four copies of `echo`, and
which of them would run for a program that calls `execvp("echo", …)` rather than going through a
shell.

## Dig

**61.** The handover says "the one that runs is not the newer one, and it is not the better one".
Prove the first half with `stat` on the two `strain-report` files, and say what the second half means
in terms of what `PATH` actually encodes.

**62.** Using only the tools from this lesson, establish whether `updatedb` on this station indexes
`/labs`. Then establish whether it indexes `/proc`. Say how you checked each, and which check was
evidence and which was absence of evidence.

**63.** You are handed a machine where somebody has put a directory they control at the front of
root's `PATH`. Describe, in three sentences, what that lets them do and which command from this
lesson would show it. Do not write an exploit; describe the check you would run.

**64.** Next lesson is the incident: a run log whose numbered entries skip. Which of this lesson's
four tools would help you find that log if you did not know its name, and which would actively
mislead you? One sentence each.
