# 00/01 — Tutor hint ladder

Governed by [`docs/TUTOR_PROTOCOL.md`](../../docs/TUTOR_PROTOCOL.md). One rung per exchange.

This lesson is orientation, not skill. The main tutoring risk is a student who wants to skim it.
Don't let them off; a student who doesn't know the tiers will skip every Experiment in the course.

### Exercise 1 — the six tiers
- **L1 question:** Which tier is the one where there is no single right command?
- **L2 locate:** Notes, the table under "The six tiers".
- **L3 concept:** Tiers run from recall to invention. Ask them to sort the six by "how much of this
  did the notes hand me" and see if the order falls out.
- **L4 decompose:** Name the tiers first. Then one sentence each. Then check against the notes.
- **L5 near-miss:** If they have five, ask which end of the range is missing — the easiest or the
  hardest.
- **Never say:** the ordered list itself.

### Exercise 2 — the six files
- **L1 question:** Which file does the tutor agent read, and which does the validator read?
- **L2 locate:** Notes, "The shape of a lesson".
- **L3 concept:** Two files for the student, two for agents, one forbidden, one that builds the lab.
- **L4 decompose:** List what you'd need to teach a lesson, then to help someone stuck, then to
  grade them, then to build the lab.
- **L5 near-miss:** If they list five, ask what creates the lab directory.
- **Never say:** the six filenames as a list.

### Exercise 3 — argue both sides
- **L1 question:** Think of a time you were given an answer and it didn't stick. What was missing?
- **L2 locate:** README, "Working with AI agents"; `docs/AGENT_MODES.md`, "Why these rules exist".
- **L3 concept:** Retrieval effort predicts retention; being shown a solution feels like learning
  and mostly isn't. The counter-argument is real: unproductive struggle past a point just teaches
  frustration, which is why the escalation cap exists.
- **L4 decompose:** Write the policy's goal. Then its cost. Then who pays each.
- **L5 near-miss:** If their counter-argument is a strawman, say so and ask them to write the one
  *they* would actually make at 1am.
- **Never say:** don't write either paragraph for them, even partially.

### Exercise 4 — syllabus skim
- Purely mechanical. If stuck, they haven't opened the file. Point at it.

### Exercise 5 — history vs end state
- **L1 question:** Two students hand in identical directories. One typed the answer into a text
  editor. What would distinguish them?
- **L2 locate:** `docs/VALIDATION_PROTOCOL.md`, "Evidence, in priority order", items 1 and 2.
- **L3 concept:** End state is a photograph; history is the film. Different data: a finished
  crossword doesn't show which clues were hard, or whether someone worked backwards from the
  answers.
- **L4 decompose:** What does history show about *order*? About *time*? About *which tool*?
- **L5 near-miss:** If they have two of three, ask what timestamps specifically add.
- **Never say:** the list from the protocol document verbatim before they've predicted.
- **Note:** they must write the prediction BEFORE reading the protocol. If they've already read it,
  ask what they'd have guessed, and accept an honest answer.

### Exercise 6 — man sections
- **L1 question:** When you run `man passwd`, are you certain which thing you're reading about —
  the command, or the file?
- **L2 locate:** `man man`. Press `/`, search for `section`. Read the numbered list.
- **L3 concept:** Man pages are a numbered library, not one book. Same name can appear in several
  sections. Analogous example on different data: `man printf` and `man 3 printf` are the shell
  utility and the C function respectively — different documents, same name.
- **L4 decompose:** Find the list. Find which number covers file formats. Find how to ask for a
  specific one.
- **L5 near-miss:** If they found the section list but not the syntax, tell them it's in the
  SYNOPSIS at the very top and they scrolled past it.
- **Never say:** the section number for file formats, or the `man N name` syntax.
