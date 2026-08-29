# 08/02 — Validation rubric

For an agent in VALIDATION mode. Sections 1 and 3 are **must-pass**. This is the lesson the rest of
the chapter stands on; a soft pass here produces a student who cannot debug lesson 06.

## 1. Order of assignment — must pass

The student must trace a redirection they have not seen before. Give them one:

```
prog 2> a.txt > b.txt 2>&1
```

and ask what ends up where. A pass produces the three assignments in order (fd2:=a, fd1:=b,
fd2:=copy of fd1 → b) and concludes that `a.txt` is created and left empty. Accept any notation;
require the word "then" or an equivalent ordering.

A student who answers correctly for `> f 2>&1` and `2>&1 > f` but cannot do a novel one has
memorised, not learned. That is a fail on this section.

## 2. The operators

- `>` versus `>>` explained as a flag at open time, not as "overwrite versus add".
- Knows `>` alone means `1>`.
- Knows `&>` is bash shorthand and equals `> f 2>&1`, and verified it with `cmp` rather than
  asserting it.
- Can say what `< /dev/null` promises a program.

## 3. Truncation — must pass

- Can state that `> file` truncates when the **shell** builds the descriptor table, before the
  program runs.
- Has actually destroyed a copy with `sort r.txt > r.txt` and can explain each step as correct
  behaviour. "It's a bug in sort" is a fail.
- Can give at least one working in-place alternative and say why the rename is the safe part.
- Knows `noclobber` exists and can name something it does not protect.

## 4. Reading someone else's redirection (exercises 39–44)

- Predicted before running. Ask to see the predictions; if there are none, this section is
  incomplete regardless of the final answers.
- Identified entry C as deliberate and can say what it is for.
- Explained entry A as a stream split rather than a typo.
- Identified D as the destructive one.

## 5. Judgement

- Exercise 43: argues both sides rather than declaring B wrong.
- Exercise 46: the divergence is about the world changing, not the scripts.
- Exercise 38: prefers `2>&1` to `/dev/stderr`-style paths in a script, with a reason.

## 6. Restraint

- Worked in `scratch/`; `data/readings.txt` and `logs/deck05.log` are intact. Check them.
- Did not chase exercise 57 into `/var/tmp`. If they did, ask what question they were answering —
  curiosity is not a fault, but the chapter's finale must stay unspoiled.

## Sign-off scenario

> A nightly job runs `check.sh >> /var/log/check.log 2>&1`. Somebody "tidied" it to
> `check.sh 2>&1 >> /var/log/check.log`. Nothing appears to change for three weeks. What changed on
> day one, and what happens on the day the check fails?

A pass says the complaints stopped going into the log on day one and have been going to the job's
terminal — which is nowhere — ever since; and that on the day it fails, the log will contain the
normal output and no sign of the failure. Bonus if they note the exit status is unaffected and is
now the only evidence left.
