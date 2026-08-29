# 08/01 — Validation rubric

For an agent in VALIDATION mode (`docs/VALIDATION_PROTOCOL.md`). The student passes on
understanding, not on having typed every command. Sections 2 and 4 are **must-pass**.

## 1. The three descriptors (exercises 1–4)

- Names 0/1/2 correctly and unprompted.
- Says what `fdreport` showed at a terminal: all three at the same `/dev/pts/N`.
- Can say why the split is invisible at a terminal without using the word "colour".
- Bonus, not required: knows what fd 255 is.

## 2. Separation — must pass

The student must demonstrate, in their own words and with a command they can run:

- **A pipe carries fd 1 only.** Ask them to explain `panelcheck >/dev/null | wc -l` printing `0`
  while six lines appeared on screen. A student who cannot do this has not done the lesson,
  regardless of how many exercises they completed.
- **`panelcheck | grep -c panel` = 8, and the missing lines were never received.** Accept any
  phrasing of "a filter cannot filter what it was not given". Do **not** accept "grep ignored them".
- **Redirection moves a stream, it does not delete one.** Exercise 23 is the evidence.

Failure mode to probe for: a student who has memorised "stdout is output, stderr is errors" and can
still answer the questions by pattern-matching. Break it by asking which stream `askdeck`'s prompt
is on and why.

## 3. Programs are indifferent (exercises 16–19)

- Can state that the shell sets the descriptors up before the program starts.
- Explains `pipe:[12345]` as an inode with no name, not as a filename they failed to read.
- Explains how `fdreport` knows its stdin is a file without reading it.

## 4. Exit status — must pass

- `panelcheck` exits 0 **and** printed six complaints; both are true at once.
- The student can state what exit 0 does and does not claim (exercise 40). Required: it is a claim
  about the program finishing, not about the state of the deck.
- The student has read `notes/dorn-readme.txt` and can give dorn's reason without calling it a bug.

If a student reports "panelcheck is broken", that is not a fail — it is the beginning of the
conversation. It is a fail if they still say so after exercise 14.

## 5. Judgement (exercises 33, 36, 44, 50)

- Identifies at least one genuinely debatable case and argues both sides.
- Does not claim `cp -v` is unambiguously wrong or unambiguously right.
- On exercise 44, gives a reason tied to what the caller does with the status.

## 6. Restraint

- Did not go looking for the chapter's incident. `/var/tmp/panelcheck.d` is mentioned by
  `panelcheck`'s own output and is not part of this lesson; a student who chased it should be asked
  what question they were answering.
- Did not edit anything under `bin/` in place. Experiments belong in `scratch/`.

## Sign-off scenario

Give them this and listen:

> A colleague says: "I ran the deck report into a file and the file is fine, but my terminal was
> full of junk. Where did the junk come from and how do I keep it?"

A pass names fd 2, says the redirection only moved fd 1, and proposes an experiment. It is **not**
required that they know `2>` yet, though many will guess it — what is required is that they can say
which stream they are chasing and why it went where it went.
