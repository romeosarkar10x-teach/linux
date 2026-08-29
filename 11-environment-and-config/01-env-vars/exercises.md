# 11/01 — Exercises: environment variables

```
cd /labs/11-environment-and-config/01-env-vars
ls -F
```

Chapters 1–11 tools. Wrecked the lab? `kestrel reset 11/01`. Wrecked your *shell*? Type `exit` and
`kestrel enter` again — nothing you do to a variable survives that, which is exercise 64.

Several exercises below tell you to open a fresh shell. Take them literally; a stale variable from
three exercises ago will make the next answer wrong and it will look like the lesson is lying.

---

## Warmup — the one-word difference

**1.** `DECK=05` then `echo "$DECK"`. Now `bash -c 'echo "[$DECK]"'`. Note the single quotes and
explain, before you run it, why double quotes would prove nothing. What did the second command print?

**2.** `export DECK=05`, then the same `bash -c 'echo "[$DECK]"'`. What changed? How many characters
of typing separated the two results?

**3.** In one sentence: where does an unexported variable stop?

**4.** `unset DECK`. Now `DECK = 05` — with spaces. Read the error exactly. What did bash think you
were asking it to do?

**5.** `deck=05` and `DECK=07`. Are these the same variable? Confirm with `echo "$deck $DECK"`.

**6.** Set `CYCLE=41` without exporting it, then `export CYCLE`. Did you have to retype the value?
When is that spelling the useful one?

**7.** `./bin/count-env`. That number is the size of the environment your shell handed it. Now
`export TEMP1=x` and run it again. Then `TEMP2=y` (no export) and run it a third time. Explain the
two results in one sentence each.

**8.** `unset TEMP1 TEMP2`. Confirm with `./bin/count-env` that you are back where you started.

**9.** Read `notes/variables.txt` as far as the line about inheritance. Which sentence in it makes
exercise 7's third result unsurprising?

**10.** `./bin/show-inherited`. Five names, and the script says of each whether it arrived. How is it
answering that question — what would you have to be careful about if you tried to answer it with
`echo` instead?

## Asking the right process

**11.** `env | wc -l` and `set | wc -l`. The second is more than a hundred times the first. Give two
separate reasons for the gap.

**12.** `env | sort`. Read all of it — it is short. Which of these did you set, and which arrived
before you did?

**13.** `export -p`. Same information as `env`, different shape. What is the shape *for* — what could
you do with that output that you could not do with `env`'s?

**14.** Find a variable that `set` shows and `env` does not. (`set | grep -c .` is not the point;
name one.) Why is that variable in one list and not the other?

**15.** `printenv HOME` then `printenv NOPE; echo "rc=$?"`. Now `echo "$NOPE"; echo "rc=$?"`. Two
ways to ask about a variable that is not set. Which one can a script act on?

**16.** `printenv PATH` and `echo "$PATH"` agree. Construct a case where `printenv NAME` and
`echo "$NAME"` disagree, using only what is in exercise 1.

**17.** `type -t lab`. `lab` is not a program and not a variable. Does it appear in `set`? Does it
appear in `env`? Explain both answers.

**18.** `echo "$SHLVL"`, then `bash -c 'echo "$SHLVL"'`. This is the one variable deliberately
different in the child. What is it counting?

**19.** `echo "$_"` immediately after running `env`. Then immediately after running `ls`. What is
this variable, and why is it useless in a script?

**20.** State the rule in your own words: when do you reach for `set`, and when for `env`?

## Crossing the boundary

**21.** `unset DECK` if it is set. Now `./bin/deck-report`. Read the error. Which line of the script
produced it — open `bin/deck-report` and find it.

**22.** `DECK=05 ./bin/deck-report` — one line, one space, no semicolon. It works.

**23.** Now, on two separate lines: `DECK=05` then `./bin/deck-report`. It fails. You typed the same
characters. Explain the difference in terms of *when* the assignment is visible and to *whom*.

**24.** After exercise 22, `echo "[$DECK]"`. After exercise 23, `echo "[$DECK]"`. The prefix form
leaves nothing behind. Which of the two is safer in a shared shell, and why?

**25.** `export DECK=05` then `./bin/deck-report`. Three spellings now work. Rank them by how long
the variable lasts.

**26.** `./bin/show-inherited` with `DECK` exported. Then `unset DECK` and run it again. You are
watching one line of its output change; nothing about the script changed.

**27.** `DECK=05 CYCLE=99 ./bin/deck-report`. Two prefixes, one command. Which line of output moved?

**28.** `bash -c './bin/deck-report'` with `DECK` exported. It works — and there are now three
processes involved. Name them in order.

**29.** `./bin/set-station`. Read its output: it says `STATION is now kestrel-7`. Now
`echo "[${STATION-UNSET}]"` in your shell. Explain the contradiction.

**30.** `source ./bin/set-station`, then `echo "[$STATION]"` again. What is different about `source`?
How many processes ran this time?

**31.** `unset STATION`. Now `( . ./bin/set-station; echo "inside=[$STATION]" )` and then
`echo "outside=[${STATION-UNSET}]"`. You sourced it, and it still did not escape. What did the
parentheses do?

**32.** From exercises 29–31, write the rule for when a script's variables reach you. Two clauses.

## Removing, demoting, and the difference

**33.** `export KEEP=1`, confirm with `env | grep KEEP`, then `unset KEEP`. Confirm it is gone from
both `env` and `set`.

**34.** `export KEEP=1` again, then `export -n KEEP`. Is it in `env`? Is it in `set`? Is it in
`echo "$KEEP"`?

**35.** `bash -c 'echo "[${KEEP-UNSET}]"'` after exercise 34. This is the only place the demotion is
visible. Say why `export -n` exists at all — what would you use it for?

**36.** `unset KEEP`. Now `readonly FIXED=1` and try `FIXED=2`. Read the error. Can you `unset` it?

**37.** Open a fresh shell (`exit`, `kestrel enter`). Is `FIXED` still readonly? What does that tell
you about where readonly lives?

**38.** `export EMPTY=` — exported, and empty. Is it in `env`? What does `env | grep EMPTY` print?

**39.** Contrast exercise 38 with `unset EMPTY`. `echo "$EMPTY"` gives the same output in both cases.
Name the tool from this lesson that distinguishes them.

**40.** Why does `unset` take a name and not `$name`? Try `unset $EMPTY` and explain what actually
happened.

## Unset, empty, and insisting

**41.** `unset DECK`. `echo "${DECK-none}"`. Now `DECK=` and the same command. Explain the second
result.

**42.** Same two states, with `echo "${DECK:-none}"`. One colon. State the rule for what the colon
adds.

**43.** `DECK=1 CYCLE=99 ./bin/deck-report` and `DECK=1 CYCLE= ./bin/deck-report`. The second prints
`cycle : 41`. Find the line in the script that decided that and say which form it used.

**44.** `DECK=1 REPORT_SOURCE= ./bin/deck-report | tail -1`. Same behaviour, different spelling in
the script. Find it. Why would an author choose `:=` over `:-` — what does the assignment form buy
inside a longer program?

**45.** `DECK= ./bin/deck-report; echo "rc=$?"`. `DECK` is set and empty, and the script still
refuses. Which form did it use, and what exit status did you get?

**46.** Rewrite in words what `: "${DECK:?DECK is not set in my environment}"` does, including why
the line begins with a colon.

**47.** Compare that line with a script that just prints `deck : ` and carries on. Give one concrete
harm the second version causes that the first prevents.

**48.** `DECK=05 ./bin/deck-report > /dev/null; echo "rc=$?"` and then the same with `DECK` unset.
A program that fails loudly is a program you can test. What would you have tested here?

## env, in full

**49.** `env DECK=05 ./bin/deck-report`. The long spelling of exercise 22. When would you need it —
what can `env NAME=value` do that the bare prefix cannot? (Hint: what if the "command" is a shell
builtin or an alias?)

**50.** `env -u PATH ./bin/count-env`. One fewer. Now `env -u PATH ls` and explain the result.

**51.** `env -i ./bin/count-env`. Three, from an environment that was emptied. Run
`env -i bash -c env` and name all three. Then run `env -i env` and explain why *that* prints nothing
at all — the difference between the two commands is the whole answer.

**52.** `env -i bash -c 'echo "$PATH"'`. Compare with your own `$PATH`. Which entry is missing, and
what does that tell you about where your `PATH` comes from?

**53.** `env -i DECK=05 ./bin/deck-report`. It works, with an environment of essentially nothing.
What does that prove about the script's dependencies?

**54.** `env -i ./bin/deck-report`. Read the failure. Is this the same failure as exercise 21?

**55.** Why is `env -i` the right first move when a program "works for me and not for the cron job"?

**56.** `env` with no arguments and `env | wc -l` differ by nothing, but `env` inside a pipeline and
`env` alone can differ by one line. Run `env | grep -c _` and `env > /tmp/e; grep -c _ /tmp/e`.
Explain any difference you see, or say why there is none.

## The nightly job

**57.** `cat notes/page.txt`. rhea asks you not to fix it. Note what she does ask for.

**58.** `cat logs/nightly.log`. On what date did it start failing, and how many consecutive nights?

**59.** `stat -c '%y %n' bin/deck-report`. rhea says she checked the mtime. Confirm it. Is the script
newer or older than the first failure?

**60.** The failing line names a variable. From the log alone, can you tell whether `DECK` was
*unset* or *empty* on those nights? Say which exercise in this lesson decides that question.

**61.** The job ran for eleven months and then stopped working with no change to the script and no
change to the command. Name three things that could have changed instead, all of them from this
lesson, and say which one you would check first.

**62.** Write rhea's one-sentence answer. It must name a class of thing, not a culprit, and it must
not name a person.

## Debrief

**63.** Somebody tells you their setup script "sets JAVA_HOME in your shell". They are describing one
of two things. Name both, and say how you would tell which from the outside.

**64.** `export MINE=1`, then `exit`, then `kestrel enter`, then `echo "[${MINE-UNSET}]"`. Where did
it go? Which chapter-11 lesson is about making it come back?

**65.** In three sentences: what is an environment variable, who gives it to you, and who can take it
away?
