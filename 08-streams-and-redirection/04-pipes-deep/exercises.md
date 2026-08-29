# 08/04 — Exercises: pipes, properly

```
cd /labs/08-streams-and-redirection/04-pipes-deep
ls -F
```

Chapters 1–8 tools. Wrecked the lab? `kestrel reset 08/04`. Write your own files under `scratch/`.

Several exercises here deliberately hang until you stop them. Use `timeout 3 …` or Ctrl-C. That is
part of the lesson, not a fault.

---

## Warmup — what a pipe is

**1.** `cat notes/pipes.txt`. Six headings. List them before you run anything; you will meet each one.

**2.** `cat notes/page.txt`. rhea reports two things and says they are not the same thing. Are they
right? Do not answer yet — write down your guess and come back at exercise 63.

**3.** `bin/noisy`. How many lines, and on which fds? Prove the split with `2>/dev/null` and then
`1>/dev/null`.

**4.** `echo hi | { readlink /proc/self/fd/0; }`. What is standard input in a pipeline? Could you
open that by name?

**5.** `{ sleep 1; echo x; } | { read -r v; date +%s.%N; }` with a `date +%s.%N` before it. How long
did the second stage wait, and what does that prove about when it started?

**6.** Is `a | b` two processes or one? Justify with something you ran, not with the manual.

**7.** `seq 1 5 | cat | cat | cat | wc -l`. Five stages. Does the answer change? What did the middle
three cost you?

## Only fd 1 goes down the pipe

**8.** `bin/noisy | wc -l`. The number is 6, and six other lines appeared on your screen. Where did
they come from and why did `wc` not count them?

**9.** `bin/noisy 2>&1 | wc -l`. Now 12. What did `2>&1` copy, and what was fd 1 at the moment it ran?

**10.** `bin/noisy |& wc -l`. Same answer. What is `|&` shorthand for?

**11.** `bin/noisy | wc -l 2>&1`. Predict before running. Whose stderr did you just redirect?

**12.** Write the command that counts **only** the stderr lines from `bin/noisy`, discarding stdout.
(Lesson 02, exercise "the trap", if you need the shape.)

**13.** `bin/failmid | grep reading`. Three lines matched, and one line appeared that `grep` never
saw. Which, and why is that useful rather than annoying?

**14.** rhea's filter "never sees the warnings". Write the one-sentence diagnosis and the one-token
fix.

**15.** Send `bin/noisy`'s stdout to `scratch/out.txt` and its stderr into `wc -l`, in one command.

## Exit status

**16.** `false | true; echo $?`. Then `true | false; echo $?`. State the rule.

**17.** `bin/failmid | wc -l; echo $?`. `failmid` exits 4. What did the pipeline report?

**18.** Now `echo "${PIPESTATUS[@]}"` immediately after. Two numbers. Which is which?

**19.** Run the pipeline, then `true`, then `echo "${PIPESTATUS[@]}"`. What happened? State the rule
about when you may read it.

**20.** `bin/failmid | grep reading | wc -l` then `PIPESTATUS`. Three numbers. Read them left to
right and describe what happened in the pipeline.

**21.** Capture the status of the *first* stage into a variable while still printing the pipeline's
output. One command plus one assignment.

**22.** In a subshell: `( set -o pipefail; bin/failmid | wc -l; echo $? )`. What changed?

**23.** With `pipefail` on and two failing stages with different statuses, which one is reported?
Construct the test.

**24.** `( set -o pipefail; seq 1 100000 | head -1 >/dev/null; echo $? )`. **141.** Explain it — and
say why this is a real problem for scripts that turn `pipefail` on globally.

**25.** Would `set -e` have caught the `failmid` failure in exercise 17? Test it. Explain the result
in terms of exercise 16.

## Subshells

**26.** `n=0; seq 1 3 | while read -r l; do n=$((n+1)); done; echo $n`. Answer, and why.

**27.** Same loop, fed with `< <(seq 1 3)`. Answer, and why it differs.

**28.** Same loop with a heredoc, from lesson 03. Which of the three forms would you use to count
lines matching a pattern in a command's output, and what is the honest simplest answer to that
particular problem?

**29.** `( shopt -s lastpipe; set +m; n=0; seq 1 3 | while read -r l; do n=$((n+1)); done; echo $n )`.
It works. Read `help shopt` on `lastpipe` and say why you should not rely on it.

**30.** `seq 1 3 | read -r a; echo "[$a]"`. Empty. Rewrite it three ways so it is not.

## SIGPIPE

**31.** `yes | head -2`. It terminates. What stopped `yes`?

**32.** `seq 1 100000 | head -1; echo "${PIPESTATUS[@]}"`. Explain both numbers. What is 141 in
signal terms?

**33.** `bin/countdown | head -1`. `countdown` prints a completion line on fd 2. Did you see it? What
does that tell you about how far the writer got?

**34.** `seq 1 100000 | tee scratch/big.txt | head -1 >/dev/null`, then `wc -l < scratch/big.txt` and
`PIPESTATUS`. How many lines survived, and what happened to `tee`?

**35.** From 34: name a real situation where this silently loses data, and one where it is exactly
what you want.

**36.** Is SIGPIPE an error? Argue both sides in two sentences, then say which side a script should
take.

**37.** `bin/slowtick 40 | head -2`. Time it. Why is it fast, and what would it have cost without
SIGPIPE?

## Buffering

**38.** `timeout 2 bash -c 'bin/slowtick 40 | grep tick | head -3'`. What did you get in two seconds?

**39.** Same with `grep --line-buffered`. Now? State the difference in one sentence.

**40.** Same with `stdbuf -oL grep tick`. Does it work? What is `stdbuf` doing that the flag did
directly?

**41.** `timeout 2 bash -c 'bin/slowtick 40 | sed -u "s/tick/T/" | head -2'` and the same with
`awk '{print; fflush()}'`. Three tools, three spellings of the same fix. Write them down together.

**42.** `timeout 2 bash -c 'bin/slowtick 40 | cat | head -2'`. `cat` needed no flag. Why not?

**43.** `bin/bufdemo | cat` — the first line appears immediately even though this is a pipe. `bufdemo`
is a bash script using `echo`. What does that tell you about which programs the buffering rule
applies to?

**44.** `timeout 2 bash -c 'bin/slowtick 40 | wc -l'`. Nothing. Is this buffering? Answer carefully —
`wc` is not the same case as `grep`.

**45.** Sort the following into "buffering" and "cannot stream by nature": `grep`, `wc -l`, `sed`,
`sort`, `tac`, `awk`, `head`, `tail -f`.

**46.** How would you decide, for an unfamiliar tool, which of the two you are looking at? Give a test
you could run in ten seconds.

**47.** The rule is "line buffered to a terminal, block buffered to a pipe". Devise the experiment
that shows the *same* command changing behaviour with nothing changed but its destination.

## `tee`

**48.** `bin/noisy 2>/dev/null | tee scratch/t.txt | wc -l`. Two numbers should agree. Do they?

**49.** `bin/noisy 2>&1 | tee scratch/t2.txt | wc -l`. Now 12 in both. What did `tee` capture that it
did not before?

**50.** `tee -a` versus `tee`. Demonstrate the difference with two runs into the same file.

**51.** `seq 1 3 | tee scratch/f1 scratch/f2 >/dev/null`. Several files at once. How many copies of
the data exist at that moment?

**52.** `bin/slowtick 5 | tee /dev/tty | wc -l`. What is `/dev/tty` and why is this useful?

**53.** `bin/noisy 2>/dev/null | tee >(wc -l > scratch/c1.txt) >/dev/null`, then read `scratch/c1.txt`.
Explain what `>(…)` gave you that a file could not.

**54.** `bin/failmid | tee scratch/t3.txt >/dev/null; echo "$? ${PIPESTATUS[*]}"`. Does `tee` change
the status? Should it?

**55.** You want to keep a full copy of a long pipeline's *input* while a `head` at the end cuts it
short. Given exercise 34, is that possible? Say what you would do instead.

## Reporting

**56.** Write rhea a reply. Two paragraphs, one per complaint, each naming the mechanism and the fix.
Say explicitly that they are unrelated — or, if you decide they are related, say how.

**57.** Someone proposes "always add `2>&1` to every pipeline, then nothing gets lost". Give the
strongest argument for and the strongest against.

**58.** Write the rule you would put in the team's script guide about `pipefail`, including the
SIGPIPE caveat from exercise 24.

**59.** A colleague's script ends `cmd | grep -q ERROR && alert`. Two independent bugs. Name them.

## Experiment

**60.** Build a pipeline that reports every stage's exit status in one line, for an arbitrary number
of stages. Test it on a pipeline where stages 1 and 3 fail.

**61.** Measure the pipe buffer: how many bytes can the writer put in before it blocks with no reader
consuming? Design the test. (`timeout`, a writer that reports progress on fd 2, and a reader that
sleeps.)

**62.** Compare `a | b | c` with `a > tmp1; b < tmp1 > tmp2; c < tmp2` on `data/readings.txt`. Same
answer. Name three differences that are not the answer.

**63.** Return to exercise 2. Were rhea's two problems the same problem? Write the sentence you would
now send.

**64.** Make a pipeline where the *second* stage dies and the first keeps writing into a pipe with no
reader. What happens to the first stage, and when?

**65.** `data/panels.csv` has a header. Write a pipeline that counts `clamped` rows without counting
the header, and then say for each stage whether it could stream or had to buffer.

## Stretch

**66.** Write `pipestat`: run a pipeline given as a string and report each stage's status. Then say
why this is much harder to do correctly than it looks, and what `PIPESTATUS` already gives you free.

**67.** `set -o pipefail` plus `set -e` plus a `head` at the end of a pipeline is a well-known way to
make a script fail at random. Reproduce it, then write the three-line rule that avoids it.

**68.** Why does a pipeline of ten `cat`s still produce the right answer but cost measurably more?
Measure it with `time` on `data/readings.txt` scaled up, and say where the cost is.

**69.** Explain to a colleague why `tail -f log | grep ERROR` shows nothing for minutes and then a
burst, and why `tail -f log | grep --line-buffered ERROR | tee found.txt` is the version to use. Be
precise about which stage was buffering.

**70.** `bin/slowtick 40 | head -3` kills `slowtick`. Now write a version that lets `slowtick` finish
its work while still only showing you the first three lines. What did you have to give up?

**71.** Chapter 8's incident involves a tool whose stderr goes somewhere unhelpful. From this lesson
alone, list the three ways a pipeline can lose a stream without anything reporting an error. One
sentence each. Do not go looking for the tool.
