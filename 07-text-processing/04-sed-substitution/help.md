# 07/04 — Tutor guide: `sed` substitution

The student arrives with `grep` (chapter 6) and `tr` (lesson 03). `sed` is the first tool that both
matches a pattern **and** rewrites it, and the lesson's job is to install four things:

1. `s///` replaces the **first** match on the line unless you say otherwise.
2. `.*` is greedy and will not stop where you pictured it stopping.
3. Addresses select lines; the command runs only on those.
4. `-i` is the only destructive thing in the chapter.

Never hand over an answer. Every result here is one command away from being checked, so send them to
the terminal instead of telling them.

## Where students stall, and what to ask

**Exercise 5** (`p` without `-n`). Students often skip it because the command "looks the same as
exercise 4". Insist. When they see the doubled lines, ask: "who printed each line, and how many times
did each one print?" Then: "so what is `-n` turning off?" A student who cannot answer that will write
`sed -n` as a superstition for the rest of the course.

**Exercise 6** (exit status). Some will assume 1 by analogy with `grep`. Let them predict, then run,
then ask what `grep`'s 1 actually means and why `sed` has nothing equivalent to report. This is the
seed of "a `sed` typo is silent" — do not say that sentence for them; exercise 33 will.

**Exercises 8–11** (the first-match trap). Do not let them settle after exercise 8. Exercise 11 is
where it lands: ask them to *guess* how many lines of the log have two zeros before counting. Most
guess a fraction. The answer is 600 of 600, because the date contains two. Then ask what
`wc -l` before and after such a botched fix would have shown. Answer: no difference at all.

**Exercise 13–16** (capture groups). If they can write `\(…\)` but cannot say what `\1` refers to,
have them run it with `\1\1` and with `\2\2\2`. If they are fighting BRE backslashes, push them to
`-E` — but make them do exercise 16, because "backslashes disappear from the pattern but not from the
replacement" is a genuine confusion and it is worth ten seconds of surprise.

**Exercise 29** (greed). The pivotal exercise of the lesson. Let them predict, let them be wrong, and
then do **not** give them `[^"]*`. Ask: "the regex is allowed to stop at the second quote — why
didn't it?" and then "what would you have to forbid, for it to have no choice?" Students who derive
the negated class remember it. Students who are told it look it up again in six months.

**Exercise 37** (`sed` versus `tr` for case). If they claim `tr` can do it, let them try. The question
that unlocks it: "where on the line is `tr` looking?" Answer: everywhere, always, with no idea where
the line starts. That is the whole distinction between the two lessons.

**Exercise 41** (regex ranges). Ask what happens if the END pattern never matches. If they do not
know, have them run `sed -n '/BEGIN summary/,/nosuchline/p'`. The range running to end of file is a
real production bug and cheap to demonstrate.

**Exercises 50–51** (the `^M`). Do not warn them in advance. When their trailing-whitespace strip
leaves something behind, ask them to `cat -A` and name the character. Then: "is `\r` a space? is it a
tab?" Then: "so which command has to run first?" This pair is the most reusable thing in the lesson
and it must be discovered, not announced.

**Exercise 55** (`-i` with no suffix). Some students will not feel it because `data/report.txt` still
exists. Make the point explicit by asking what they would have done if `scratch/report.txt` had been
the only copy. Do not stage an actual loss.

## Questions that work when they are stuck generally

- "What did the pattern match — say it character by character."
- "How many times could that pattern match on this line?"
- "Run it without `-n` and tell me what changed."
- "Which part of that is the address and which part is the command?"
- "What would this do to a line that does not match at all?"

## Do not

- Do not give them `[^"]*` before exercise 30.
- Do not explain `-n` before they have run exercise 5.
- Do not let a student leave section "The report cleanup" without stating the CR-before-whitespace
  ordering in their own words.
- Do not let them treat exercise 48 as the right way to extract a field. Ask what it becomes if a
  field gains a space, and leave the discomfort there for lesson 05.
- Do not answer "why does `sed` have so many ways to say the same thing" with history. Answer with
  the one they should write and the reason (readability), and move on.
