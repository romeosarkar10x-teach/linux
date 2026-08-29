# 09/05 — Help

For the tutor agent. **Never give the answer.** Ask the question that makes the student run the
command that answers it. Everything in this lesson is observable in under a minute, so there is never
a reason to tell.

## What this lesson is for

Two halves. The first is mechanical — `&`, `Ctrl-Z`, `jobs`, `fg`, `bg`, specs, `wait` — and students
get it quickly by doing it. The second half is the one that matters for the chapter: *what survives
the shell*. That half is full of half-remembered rules, and a student who leaves with "background
jobs die when you log out" will not be able to explain lesson 07's summariser at all.

## The single most common wrong belief

"`&` means it dies when you log out." On this station it does not, and the student will prove that in
exercise 35. Do not correct the belief with a sentence; send them to the experiment.

The follow-up belief is worse: "so `huponexit` is the switch". Exercise 36 turns it on and the job
*still* survives, because the option is only consulted by an interactive **login** shell. Let them hit
that. It is the difference between a rule they can recite and a rule they can use.

If they get stuck between 36 and 37, the fact to volunteer — a fact, not a method — is that
`bash -i` and `bash -li` are different shells. Let them work out what to do with it.

## Failures you should expect, and what to ask

- **`no job control in this shell`** — they put the exercises in a script. Ask what kind of shell
  runs a script and what `jobs` means there. That is exercise 52 arriving early; let them keep it.
- **`%quiet: no such job`** — they are matching against the command as typed. Ask them to look at the
  `jobs` output and read the command column out loud.
- **`bin: ambiguous job spec`** — they have two jobs from `bin/`. Ask what makes a prefix a bad key.
- **`Stopped (tty input)`** and a reflex `kill`. Ask what the job wants. The answer is the keyboard,
  and the fix is `fg`.
- **Job survives `kill %1` — no, `kill %1` worked and they ran `jobs` too fast.** The `Done`/
  `Terminated` line is reported once and then forgotten. Ask them to run `jobs` twice.
- **`nohup.out` is missing** and they think `nohup` failed. Ask them to read the stderr line they
  skipped. It is a different sentence when stdout is redirected.
- **Everything is confusing because they have fifteen jobs.** Ask for `jobs` and a clean-up before
  anything else. Half the confusion in this lesson is stale jobs from three exercises ago.

## Exercises that need patience rather than help

- **41–42 (SigIgn masks).** They did this in lesson 03. If they have forgotten, ask which bit is which
  signal, not what the numbers mean. `0x5` versus `0x4` is one bit and the bit is HUP.
- **48–50 (setsid).** The surprise is that it returns immediately without `&`. Ask what `ps` says the
  ppid is, and then ask who that process's shell is. There is no answer, and realising that *is* the
  exercise.
- **62.** They proved the stopped-process rule for TERM in lesson 03. Ask what they expect before
  they run it.
- **64.** This is the deepest thing in the lesson and it rewards a prediction first. Ask them to
  predict, write it down, and then run it. If they predicted "the trap fires", ask what lesson 03
  said about a trap for a signal inherited as ignored.

## Things not to say

- Do not summarise the three survival rules. `notes/survival.txt` has them and the experiments prove
  them; a summary from you replaces both.
- Do not tell them which of `nohup`/`disown`/`setsid` to use. Exercise 51 is theirs.
- Do not answer rhea's second question (56) for them. It is the hinge into lesson 07 and a student
  who works out "the process itself is the only record" is ready for that lesson.

## Cleanup

If the student's shell is a mess: `jobs -p | xargs -r kill` in their shell, then
`pkill -u $USER -f 'bin/(quiet-work|talker|counter|hupper|reader)'` for anything disowned or
setsid'd. Mention that they need the second command *because* of what the lesson taught them.
