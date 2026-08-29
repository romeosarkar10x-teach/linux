# 09/04 — Exercises: kill, pkill and pgrep

```
cd /labs/09-processes-and-job-control/04-kill-pkill-pgrep
ls -F bin
```

Chapters 1–9 tools. Wrecked the lab? `kestrel reset 09/04`.

Start every group by launching what it needs, and clean up after yourself at the end of each group —
`pkill -ef 'bin/'` will do it, and by exercise 20 you will know why that is a rougher command than it
looks.

---

## Warmup — pids by hand, one last time

**1.** `bin/panel-mon 300 &`. Find its pid three ways: from `$!`, from `ps -ef | grep panel-mon`, and
from `pgrep -f panel-mon`. Do all three agree?

**2.** The `ps -ef | grep` version returned an extra line. Which process was it, and why is it there?

**3.** `pgrep -f panel-mon` did not return an extra line for itself. Why not — what does `pgrep` do
that `grep` cannot?

**4.** `kill $(pgrep -f panel-mon)`. It worked. Write down what would have happened if `pgrep` had
matched three processes, and whether you would have known.

**5.** `cat notes/page.txt`, then `cat notes/incident-log.txt`. What exactly went wrong on
2187-03-02? Quote the command.

**6.** Before reading further: predict what `pkill -f panel-mon` matches in this lab. Write the
prediction down. You will check it in exercise 13.

## comm, and what "the name" means

**7.** `bin/panelctl 300 &`, then `pgrep panelctl`. Nothing, rc 1. The process is running. What is
`pgrep` looking at?

**8.** `ps -p $! -o pid,comm,args`. Three columns. Which one did `pgrep` search, and what is in it?

**9.** `pgrep -af panelctl`. Now it is found. State the difference between the two searches in one
sentence.

**10.** `bin/deckwatch 300 &` and `ps -p $! -o comm=`. It is neither `bash` nor `deckwatch`. Read
`bin/deckwatch` and explain what `comm` actually reports.

**11.** `bin/deckwatch-long 300 &`, then `ps -p $! -o comm=`. Count the characters. What happened to
the end of the name?

**12.** `pgrep -x panel-watchdog-daemon`. Read the message it prints — this is one of the few tools
that tells you the trap instead of returning nothing. What does it suggest, and does the suggestion
work?

## The substring problem

**13.** Start both: `bin/panel-mon 300 & bin/panel-monitor 300 &`. Now `pgrep -af panel-mon`. How many
pids? Compare with your prediction from exercise 6.

**14.** Nothing warned you. Which of the two would you have stopped, and which is the one
`notes/incident-log.txt` says mattered?

**15.** Fix it with `-x`: `pgrep -xf 'bash bin/panel-mon 300'`. One pid. Why does the pattern have to
start with `bash`?

**16.** Fix it a different way, with an anchor: `pgrep -af 'panel-mon [0-9]+$'`. Does it work? Try
`'panel-mon '` with the trailing space and say which of the three fixes you would actually type at
three in the morning.

**17.** `pgrep -cf panel`. A count. Now `pgrep -af panel` and check the count by eye. When is `-c` the
right tool and when is it a way to avoid looking?

**18.** `bin/pane 300 &`, then `pgrep -af 'panel*'`. Four matches, and one of them is `pane`. The
pattern is not a glob. Say what `panel*` means as an ERE, character by character.

**19.** Write the ERE that means what a shell user thinks `panel*` means. Test it.

**20.** `pgrep -af 'bin/'` — everything in this lab, and whatever else on the station happens to have
`bin/` in its command line. Count it. Would you hand that pattern to `pkill`?

## Selecting properly

**21.** `pgrep -af panel-monitor` then `pkill -ef panel-monitor`. Read `pkill -e`'s output. What does
the `-e` buy you that you did not have?

**22.** Note the name `pkill -e` reported. It is not `panel-monitor`. Why not — and which of the two
matching modes was `-e` reporting from?

**23.** `pgrep -u cadet -c`. How many processes does cadet own? Compare with `ps -e --no-headers |
wc -l` from lesson 01 and explain the difference.

**24.** `pgrep -af -u cadet panel`. Combine a user filter with a pattern. Now do the same with a user
who owns nothing: `pgrep -u root -af panel`. What is the rc, and is that a failure?

**25.** Start four: `for l in alpha beta gamma delta; do bin/named $l 300 & done`. `pgrep -a named`
finds nothing; `pgrep -af named` finds four. Now select only `gamma`, and say which field made that
possible.

**26.** `pgrep -naf named` and `pgrep -oaf named`. Newest and oldest. Which label did each return, and
does that match the order you started them in?

**27.** `bin/fleet 3 300 &`. Find the fleet's pid, then `pgrep -aP <that pid>`. Three children. What
is `-P` matching on, and note that it takes a pid, not a pattern.

**28.** Kill the fleet's parent with TERM and then run `pgrep -af panel-mon` again. The children are
still there. Whose children are they now? (Lesson 03, exercise 47.)

**29.** So `-P` is a selection you can make *before* you kill the parent and not after. Write the
two-command sequence you would use to stop a parent and its children deliberately.

**30.** `pgrep -vf panel -u cadet -c`. Invert. What is it counting, and why is `-v` more dangerous
than the others when handed to `pkill`?

## Signalling

**31.** `pkill --signal HUP -ef panelctl`. Which signal did it send, and what was the default it
replaced?

**32.** `pkill -HUP -ef panelctl` — the short form. Both work. `man pkill` on `--signal`: is there any
case where the short form is ambiguous?

**33.** `bin/panel-mon 300 &` and then `pkill -9 -ef panel-mon`. It dies. Now say, from lesson 03, what
`bin/panel-mon` did not get to do.

**34.** `pkill -ef nothing-matches-this; echo rc=$?`. rc 1. Is that an error? Write the `&&`/`||`
version of "kill it if it is there and say so if it is not" using Chapter 8's chaining.

**35.** `killall panel-mon; echo rc=$?`. It says no process found, even though one is running. Why —
what does `killall` match that `pkill` does not?

**36.** `killall bash`. **Do not run this.** Say what it would do on this station, and which processes
would be included that you did not have in mind.

**37.** Process groups. Start `bin/fleet 2 300 &`, find its pid with `pgrep -xf 'bash bin/fleet 2
300'`, then `ps -o pid,pgid,args -p <pid>`. Is the pgid the same as the pid? Do the same for one of
its children.

**37a.** `man kill` on a **negative** pid: it signals a whole process group. From an interactive
shell, `kill -TERM -<pgid>` stops the fleet and its children in one go. Try it, and check with
`pgrep -af panel-mon`.

**37b.** Now the trap. Put the same three lines in a script in `scratch/` and run it. The script
dies. Look at the pgid column again and say why — what else was in that group, and who put it
there?

**38.** Compare: signalling one pid, signalling a process group with a negative pid, and `pkill -u
cadet`. Rank them by how much you can get wrong with one keystroke.

## Reporting

**39.** Write the two-line entry you would add to `notes/incident-log.txt` if you had made the March
mistake. It should say what you matched, not what you intended.

**40.** rhea asked to see the `pgrep` first. Write the exact pair of commands you would send her for
"stop the panel-mon on deck 05, leave everything else alone".

**41.** Somebody hands you `pkill -f panel`. List three things you would check before running it, each
of which is one command.

**42.** Write the rule for your own runbook in one sentence. It must contain the word "read".

## Experiment

**43.** Does `pgrep` match zombies? This station has plenty:
`ps -eo pid,stat --no-headers | awk '$2 ~ /^Z/ {print $1; exit}'` gives you one. Then
`pgrep -a sleep | grep <that pid>`. It is listed, as `[sleep] <defunct>`. Would `pkill` have "worked"
on it, and what does that mean for a script that decides "still running" from `pgrep`'s rc?

**44.** `pgrep -f pgrep` in one shell while another runs a long `pgrep`. Can you catch it? What does
this tell you about the self-exclusion in exercise 3 — is it excluding itself, or all `pgrep`s?

**45.** Rename a copy: `cp bin/panel-mon scratch/pm; scratch/pm 60 &`. Does `pgrep -f panel-mon` find
it? Does `pgrep -f pm`? What did the rename change and what did it not?

**46.** Start `bin/named alpha 300 &` twice. Two processes, identical command lines. Select exactly
one of them. Which options can distinguish them and which cannot?

**47.** `pkill -f 'bin/named'` with all four labels running. Then check `pkill`'s rc. Does rc tell you
how many it killed? What would?

**48.** Write a shell function `preview() { … }` that takes the same arguments you would give `pkill`,
runs `pgrep -a` with them, prints the count, and asks for confirmation before running `pkill`. Test
it against `panel-mon`.

**49.** Time your function against typing the two commands. If it is not faster, is it still worth
having? Answer honestly.

**50.** `pgrep -af '.'` versus `ps -e --no-headers | wc -l`. The two numbers agree here. Given
exercise 43, that is not obvious — a zombie has no command line left. Find out what `pgrep -af`
prints for one, and say which string it matched on.

## Stretch

**51.** `pkill` and `pgrep` take `--ns` and `--nslist`. Read the manual entry. Say in one sentence
what it would be for, and why it does nothing useful for you inside this container.

**52.** Write a selection that means "every process cadet owns that has been running longer than an
hour, excluding the shell I am typing in". You will need `ps` and `etime` as well as `pgrep`; say
which tool did which half.

**53.** `pgrep` has no `--dry-run` because it *is* the dry run. Argue the other side: what would a
`pkill --dry-run` give you that `pgrep -a` does not?

**54.** The March incident would not have happened with `-x`. It also would not have happened if the
two programs had been named differently. Which fix is cheaper, which is more reliable, and which one
can you actually make from where you sit?

**55.** Lesson 06 will show you that a process's environment dies with it. Given that, rewrite your
exercise-48 function so that the preview it prints is worth keeping. What would you add to it, and
where would you put the output?
