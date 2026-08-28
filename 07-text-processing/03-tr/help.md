# 07/03 — Tutor guide: `tr`

`tr` is the smallest tool in the chapter. A student can learn every flag in twenty minutes, which
means the lesson's value is entirely in the four places it surprises them:

1. It cannot open a file.
2. It maps **characters**, so `tr 'cat' 'dog'` does not touch the word "cat".
3. `[:cntrl:]` includes the newline, and `-d` on it destroys the file's line structure.
4. It operates on **bytes**, so multi-byte characters pass through un-folded or get cut in half.

Guide with questions. Every answer in this lesson is derivable; do not shortcut the derivation.

## Where students stall, and what to ask

**Exercise 1** — students assume a typo. Ask them to read the error word by word: "extra operand".
Then: "how many operands did you give, and how many does `tr SET1 SET2` take?" Then exercise 3, which
is the interesting half: not "why can't it" but "what is `tr` for, such that it doesn't need to".

**Exercise 10 (padding)** — most predict `xy` followed by `cdef` unchanged, i.e. the `-t` behaviour.
Let them predict, then run. After the surprise, exercise 13 is essential: send them looking for a case
where padding is the *point*. If they cannot find one, ask what `tr '[:digit:]' '#'` would do if SET2
were not padded.

**Exercise 15** — the big one. If the student predicts "the cat becomes dog", let them run it and then
ask them to account for **every** changed character, including the `t` in "the". Make them say out
loud that `tr` has no concept of a word. This is the sentence the lesson exists to install, and lesson
04 opens by needing it.

**Exercise 22** — students often predict correctly and are still shocked by the output. Do not warn
them. Afterwards ask: "which character in `[:cntrl:]` did that?" If they do not know, ask what a
newline's byte value is and whether it is printable. Then exercise 24 — get the principle stated in
their own words before moving on. "Say what you keep, not what you remove" is worth more than the rest
of the lesson combined.

**Exercise 30** — some students will not connect it to lesson 02. Ask: "what did `cut -d' '` do to
this file last lesson, and what changed?"

**Exercise 37–38** — students report the two numbers and stop. Push for the *exact* accounting: five
extra lines, and they should be able to point at five specific places in the prose. If they are stuck,
suggest `grep -n '^$'` on the un-squeezed output and then counting characters at those positions in
the source.

**Exercise 45–49** — the byte lesson. If a student says `tr` is "broken" for not folding `é`, ask what
bytes `é` is made of and whether any of them is between `a` and `z`. Exercise 48 is worth doing for
real; seeing `303` alone in `od -c` output is more convincing than any explanation.

**Exercise 53** — students predict `e`. Let them. The space winning by double is the point, and the
follow-up question is good: "why did you not predict a character you type more than any other?"

## The rot13 note

Exercises 41–44 exist to make the student decode something to read it. If they ask what the note says,
the answer is "decode it". If they decode it and want to discuss it, that is a good use of time — the
last line ("what you have found is not a cipher; you have found somebody who believed it was one") is
worth sitting with, and it is a habit of mind this course wants.

Do not tell them the plaintext. It appears nowhere in the lab on purpose.

## Never say

- The counts 18 and 7; 54 and 59; 50/24/22/20/18; the top-five word table.
- That exercise 9's answer is empty.
- The words "newline is a control character" before exercise 22.
- `tr -cd '[:print:]\n'` before exercise 23.
- Any part of the decoded rot13 note.
- Anything about the chapter's incident.

## If a student is far ahead

"You have a file where every line ends `\r\n` **and** some values contain a literal `\r` in the
middle. `tr -d '\r'` fixes the line endings and silently corrupts those values. What in this lesson
detects that, and what would you use instead?" (Nothing in this lesson detects it — `tr` has no
position. `sed 's/\r$//'` anchors to the end of the line, and that is exactly what lesson 04 is for.)
