# 01/04 — Tutor hint ladder

Governed by [`docs/TUTOR_PROTOCOL.md`](../../docs/TUTOR_PROTOCOL.md). One rung per exchange.

**Diagnose first:** most trouble here is one of two wrong models — "the shell has types" or "unset
and empty are the same thing". Find out which one they hold before hinting.

### Exercise 1 — assign and append
- **L1 question:** When you write `$deckplating`, what name is the shell actually looking for?
- **L2 locate:** Notes, "Reading a variable".
- **L3 concept:** The shell reads a name greedily — letters, digits, underscores — so you need a way
  to mark where the name stops. Different example: `${user}s` versus `$users`.
- **L4 decompose:** Assign. Print plainly. Then print with the extra word attached.
- **L5 near-miss:** If they inserted a space to make it work, that is a different output — ask them
  to produce it with no space.
- **Never say:** `${deck}plating`.

### Exercise 2 — exit status
- **L1 question:** Which variable holds the result of the last command?
- **L2 locate:** Notes, "Variables the shell sets for you".
- **L3 concept:** Every command leaves a number behind; zero means success. Different example: `true`
  and `false` are real programs whose entire job is to set it.
- **L4 decompose:** Run something that works. Read it. Run something that fails. Read it.
- **L5 near-miss:** If they get `0` for the failing case, ask what command ran between the failure
  and the reading.
- **Never say:** `$?`.

### Exercise 3 — home and cwd
- **L1 question:** The notes list variables the shell maintains. Which two describe locations?
- **L2 locate:** Notes, "Variables the shell sets for you".
- **L3 concept:** The shell keeps its own state in ordinary variables you can read.
- **L4 decompose:** Print each.
- **L5 near-miss:** If they run `pwd`, accept it as a bonus but ask for the variable.
- **Never say:** —

### Exercise 4 — three assignment errors
- **L1 question:** Take `deck = 3`. Split it into words the way lesson 01/03 said the shell does.
  What is word one?
- **L2 locate:** Notes, "Assignment: the whitespace rule"; and 01/03, "The shape of a line".
- **L3 concept:** An assignment is recognised only when the whole first word has the shape
  `name=value` with nothing between. Break that shape and the word becomes a command name.
  Different example: `x =1` and `x= 1` fail differently for this reason.
- **L4 decompose:** For each of the three, ask: what did the shell take as the command word, and
  what did it take as arguments?
- **L5 near-miss:** If they cannot explain the third, ask which part of it *did* look like a valid
  assignment, and what the shell then did with the rest of the line.
- **Never say:** that the third one assigns an empty string and runs `3`.

### Exercise 5 — three states
- **L1 question:** If `echo` prints a blank line in two different cases, what does that tell you
  about `echo` as a diagnostic?
- **L2 locate:** Notes, "Unset is not empty".
- **L3 concept:** Printing a value cannot distinguish "no value" from "empty value", because both
  print as nothing. You need something that asks about existence rather than content. Different
  example: an empty file and a missing file also look the same to `cat`.
- **L4 decompose:** Produce all three states. Print each. Then find a form in the notes that reacts
  differently to unset than to empty.
- **L5 near-miss:** If they use `:-` for both and get the same answer, point out that the notes
  mention a variant of it, and ask what the difference in spelling is.
- **Never say:** the colon rule.

### Exercise 6 — values with spaces
- **L1 question:** How many words does the shell see when you expand an unquoted variable containing
  spaces?
- **L2 locate:** Notes, the "Habit worth forming now" callout.
- **L3 concept:** The value is stored intact; what changes is what happens to it *after* expansion.
  Different example: assign `a="x  y"` with two spaces and watch them collapse when unquoted.
- **L4 decompose:** Assign with quotes. Print quoted. Print unquoted. Compare character by
  character.
- **L5 near-miss:** If both look the same to them, ask about the number of spaces between words.
- **Never say:** the phrase "word splitting" as an explanation — they get that in Chapter 5.

### Exercise 7 — removing a variable
- **L1 question:** Is there a command that deletes a name, as opposed to assigning to it?
- **L2 locate:** Notes, "Unset is not empty", first block.
- **L3 concept:** Deleting a name and emptying it are different operations with different
  observable consequences.
- **L4 decompose:** Assign. Delete. Test. Then assign empty. Test again with the same test.
- **L5 near-miss:** If their test is `echo`, send them back to exercise 5.
- **Never say:** `unset`.

### Exercise 8 — reading deck-config
- **L1 question:** Read the comment at the top of the file. What does it say a blank value means?
- **L2 locate:** `deck-config`; notes, "Default-value expansions".
- **L3 concept:** The right expansion depends on the *contract*, not just the syntax. If blank means
  "use the default", then blank and absent should be treated the same. If blank meant "explicitly
  none", they must not be. Different example: an empty `TZ` is meaningfully different from an unset
  one on some systems.
- **L4 decompose:** Classify each of the three by state. Then, for each, ask: should blank behave
  like absent here? Choose the form that matches.
- **L5 near-miss:** If they pick the colon form for all three without reading the comment, ask them
  what the comment is for.
- **Never say:** which form goes with which setting.

### Exercise 9 — the colon
- **L1 question:** Write the two forms next to each other. What is different about them, purely as
  text?
- **L2 locate:** Notes, "Unset is not empty", the second block.
- **L3 concept:** One character changes whether "empty" counts as "missing".
- **L4 decompose:** Set the variable empty. Run both forms. Name the character.
- **L5 near-miss:** If they get identical results, check the variable is empty rather than unset.
- **Never say:** ":".

### Exercise 10 — :- versus :=
- **L1 question:** Which of the two does the notes' table describe as assigning?
- **L2 locate:** Notes, "Default-value expansions", the table.
- **L3 concept:** Substitution and assignment are separable — a form can supply a value for this one
  expansion, or supply it and keep it.
- **L4 decompose:** Fresh name. Expand with the first form. Read the variable. Fresh name again.
  Expand with the second. Read again.
- **L5 near-miss:** If they reuse the same variable name, the second test is contaminated — have
  them start over.
- **Never say:** —

### Exercise 11 — fail if unset
- **L1 question:** Which row of the table describes failing rather than substituting?
- **L2 locate:** Notes, "Default-value expansions".
- **L3 concept:** Making a missing value loud, early, and at the top of a script is worth more than
  a clever fallback halfway down.
- **L4 decompose:** Find the form. Use it on something unset. Read the exit status. Set it. Repeat.
- **L5 near-miss:** If their shell exits entirely, that is correct behaviour in some contexts —
  suggest they test inside a subshell.
- **Never say:** `:?`.

### Exercise 12 — reading report.sh (Experiment)
- **L1 question:** For each `echo` line in that script, what name is the shell looking up?
- **L2 locate:** Notes, "Reading a variable".
- **L3 concept:** A name that runs on into the following letters is a *different name*, and an
  unset name expands to nothing without complaint. The line does not fail; it silently produces
  less than intended. Different example: `echo "$HOMEwork"` prints nothing.
- **L4 decompose:** Predictions in writing first. Then run. Then, for the mismatched line, ask what
  name was actually looked up.
- **L5 near-miss:** If they say the script has a typo, ask them to name the variable that does not
  exist.
- **Never say:** `labelplate`.

### Exercise 13 — unquoted assignment (Experiment)
- **L1 question:** Which of the three errors in exercise 4 does `title=deck 3 bay 2` most resemble?
- **L2 locate:** Notes, "Assignment: the whitespace rule".
- **L3 concept:** The assignment ends at the first space; everything after it is a command line that
  runs *with that assignment in effect*.
- **L4 decompose:** Prediction and reasoning in writing. Copy the file. Edit the copy. Run it.
- **L5 near-miss:** If they predicted a syntax error and got a `command not found`, that is the
  intended surprise — ask them what the shell thought the command was.
- **Never say:** the outcome before their prediction exists.

### Exercise 14 — reading `$?` twice (Experiment)
- **L1 question:** What is the "last command" at the moment of the second reading?
- **L2 locate:** Notes, "Variables the shell sets for you", the `$?` block.
- **L3 concept:** The variable is overwritten by every command, including the one that printed it.
  Different example: two `false` calls in a row.
- **L4 decompose:** Both predictions written. Run. Compare.
- **L5 near-miss:** If they predicted the same number twice, ask what the first `echo` returned.
- **Never say:** the second number.

### Exercise 15 — is unset a program (Stretch)
- **L1 question:** Which command from 01/03 answers "what kind of thing is this word"?
- **L2 locate:** 01/03 notes, "`type` — the question to ask first".
- **L3 concept:** The same argument as `cd`: a child process cannot reach into its parent's
  variables, so anything that changes them must be executed by the shell itself.
- **L4 decompose:** Classify it. Then ask what a separate program would have to be able to do.
- **L5 near-miss:** If they classify it correctly but cannot explain why, ask where the variable
  lives.
- **Never say:** "builtin".

### Exercise 16 — three labelled values (Stretch)
- **L1 question:** Which of your three values will sit directly against a letter in the output?
- **L2 locate:** Notes, "Reading a variable".
- **L3 concept:** Braces are needed exactly where the following character could be part of a name —
  and punctuation or a space means they are not needed at all.
- **L4 decompose:** Write the line. Check each expansion for what follows it. Add braces only where
  required.
- **L5 near-miss:** If they brace everything, that is correct and slightly noisy — ask which ones
  were actually necessary.
- **Never say:** the finished line.

### Exercise 17 — EDITOR fallback (Stretch)
- **L1 question:** Which form supplies a fallback without an `if`?
- **L2 locate:** Notes, "Default-value expansions".
- **L3 concept:** The judgement half is the real exercise: for an editor, is an explicitly empty
  setting a deliberate choice or a mistake? Different example: an empty `PAGER` almost certainly
  means "no pager", and should be respected.
- **L4 decompose:** Write the line. Run unset. Set empty. Run again. Then decide which behaviour you
  want and say why.
- **L5 near-miss:** If they only report the mechanics, push for the judgement — that is the graded
  half.
- **Never say:** which behaviour is "right"; both are defensible and the reason is what counts.

### Exercise 18 — length (Dig)
- **L1 question:** `man bash` has a section on Parameter Expansion. What is the first form listed
  there?
- **L2 locate:** `man bash`, EXPANSION → Parameter Expansion.
- **L3 concept:** The same `${...}` syntax carries a family of operations; length is one of them.
- **L4 decompose:** Find the form. Apply to a value. Apply to an unset name. Ask whether the second
  result is a length or an absence.
- **L5 near-miss:** If they pipe into a character counter, that works — accept it, and ask for the
  expansion as well since that is the skill.
- **Never say:** `${#x}`.

### Exercise 19 — the `:+` form (Dig)
- **L1 question:** What does `echo` add to its output that you did not ask for?
- **L2 locate:** Notes, the expansion table; `help echo`.
- **L3 concept:** "Prints nothing" and "prints an empty line" are different, and the difference is
  invisible on a terminal. You need either a different printing command or a way to make the bytes
  visible. Different example: an empty file versus a file containing one newline.
- **L4 decompose:** Get the substitution right first. Then deal with the newline. Then find a way to
  see the actual bytes.
- **L5 near-miss:** If they claim success while still using `echo`, ask them to prove there is no
  newline.
- **Never say:** `printf`, or `od -c`.

### Exercise 20 — the strict option (Dig)
- **L1 question:** `help set` lists the shell's options. Which one mentions unset variables?
- **L2 locate:** `help set`; `man bash`, the `set` builtin.
- **L3 concept:** The option turns a silent empty expansion into an error, which is why it is the
  first line of most serious scripts. It deliberately does not apply to the default-value forms —
  otherwise you could never write an optional setting.
- **L4 decompose:** Find the option. Run it inside parentheses so it cannot leak. Reference something
  unset. Then try the fallback form under the same option.
- **L5 near-miss:** If it kills their session, they set it in the current shell — remind them of the
  subshell and note that this is exactly why the exercise said to.
- **Never say:** `set -u`.
