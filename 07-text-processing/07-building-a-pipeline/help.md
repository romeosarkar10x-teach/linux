# 07/07 — Tutor guide: building a pipeline

There is nothing to teach in this lesson except a habit, and habits are not taught by explanation.
Your job is to make the student experience being wrong cheaply, three or four times, until looking
after each stage feels faster than not looking.

Do not explain the field-count trap before exercise 13. The whole design of exercises 9–15 is that
the student walks into it, and the walk is the lesson.

## Where students stall, and what to ask

**Exercise 4.** They will say the numbers add up when they do not. Make them subtract. The one
leftover line is the point.

**Exercise 10.** Some students will not run it — they will assume field 4 and move on. If they do,
let them get to exercise 11 and produce the mixed table. Then ask: "at which stage did this become
wrong?" and make them go back and run stage two alone. That round trip is the lesson.

**Exercise 11.** Do not say "field 4 is wrong". Ask: "how many kinds of thing are in that table?"

**Exercise 12.** This is the important one. The count check *passes* on a wrong answer. If a student
concludes counts are useless, push back: ask what the check did tell them (no records were lost) and
what it cannot tell them (whether the right thing was extracted). Checks have scopes.

**Exercise 13.** If they cannot explain `6` and `7`, have them run
`grep ERROR logs/maint-raw.txt | head -1` and `grep INFO logs/maint-raw.txt | head -1` and count by
eye. Do not give them the space inside the brackets — ask what is different between the two lines.

**Exercise 30.** Both explanations are hard. Accept one good one and supply the other.

**Exercise 37.** Students report "it did nothing". Ask where `wc`'s output went, then ask what `cat`
had to read. The silent success is what makes this bug worth an exercise.

**Exercise 45.** If they cannot find a pipeline that `pipefail` would break, point at lesson 06's
`seq | head` and let them connect it.

**Exercise 52.** Expect the `-F,` bug. When it happens, do not fix it — ask them to print `$1` and
`$2` in brackets and read what came out. `[      3 p-a][]` explains itself.

**Exercise 54.** Students want a right answer. There isn't one. Keep asking who reads the report and
what they do next. If they say "sort by criticality", ask what happens when a fifth criticality level
is added and alphabetical order stops matching severity order.

**Exercise 58.** `NR` versus a counter is the same class of mistake as field 4: a builtin whose
meaning is *close* to what you wanted. Say that connection out loud; it is the generalisation the
lesson is for.

## Questions that work when they are stuck

- "What is in the stream right now? One noun."
- "Which stage did you add last?"
- "Run just the first two stages. Does that look right?"
- "Do the counts add up to 120?"
- "What did that command actually print, not what did you expect."

## Do not

- Do not let them build the exercise-56 pipeline in one go, even if they can. Make them show the
  intermediate outputs. A correct answer arrived at by guessing has not passed this lesson.
- Do not introduce `join`, `paste -d`, or process substitution. Everything here is chapter 1–7 tools.
- Do not let "it worked" stand as an answer anywhere in exercises 31–40. Four of those five pipelines
  run without error.
- Do not turn `pipefail` into a rule. It is a trade-off, and exercise 45 is where they see the cost.
