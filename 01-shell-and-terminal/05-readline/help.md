# 01/05 — Tutor hint ladder

Governed by [`docs/TUTOR_PROTOCOL.md`](../../docs/TUTOR_PROTOCOL.md). One rung per exchange.

**Diagnose first, and differently from other lessons.** The failure mode here is not
misunderstanding — it is a student quietly using arrow keys and reporting success. Before hinting,
ask what they actually pressed. If the answer is vague, that is the finding.

**Second diagnostic:** if `Alt-` bindings do nothing, it is the terminal, not the student. Send them
to the `Esc`-then-letter form immediately; do not let them spend twenty minutes on a configuration
problem in a muscle-memory lesson.

**A standing note for this lesson:** the "Never say" lines below are unusually strict. Naming a key
combination hands over the entire exercise, because there is nothing else to it. Describe what the
key *does*, and let them find it in the tables.

### Exercise 1 — jump and abandon
- **L1 question:** The notes group keys by what they do. Which group has "start of line"?
- **L2 locate:** Notes, "Moving" and "The rest of the line".
- **L3 concept:** Line navigation is a single keystroke, not a held-down arrow. The abandon key is
  in the last table.
- **L4 decompose:** Type the line. Find the start key. Find the end key. Find the abandon key.
- **L5 near-miss:** If they pressed Enter, ask them to try again — the exercise is about not running
  it.
- **Never say:** any of the three key names.

### Exercise 2 — delete word, delete line
- **L1 question:** Which table lists deletions, and which entries mention "word" and "start of
  line"?
- **L2 locate:** Notes, "Deleting".
- **L3 concept:** Deletion comes in units — character, word, to-start, to-end. Pick the unit that
  matches the job.
- **L4 decompose:** Delete one word. Then, from wherever you are, remove everything before the
  cursor.
- **L5 near-miss:** If they used the to-end key and nothing vanished, ask where their cursor was.
- **Never say:** the key names.

### Exercise 3 — delete and restore
- **L1 question:** Where do you think the deleted text went?
- **L2 locate:** Notes, "Putting it back".
- **L3 concept:** Readline deletions are cuts, not destructions — there is a buffer, and a key that
  pastes from it. Different example: cut a whole line, run something else, paste it into a new
  command.
- **L4 decompose:** Delete a word. Find the paste key. Press it.
- **L5 near-miss:** If they try their terminal's paste shortcut, point out that the text never went
  to the system clipboard.
- **Never say:** the key name.

### Exercise 4 — 05 to 06
- **L1 question:** How many characters actually need to change?
- **L2 locate:** Notes, "Moving" and "Deleting".
- **L3 concept:** Editing is: get the cursor near the target cheaply, then change as little as
  possible. Word-wise movement gets you close in one or two presses.
- **L4 decompose:** Where is the target relative to the end of the line? What is the cheapest way to
  get there? What is the smallest edit?
- **L5 near-miss:** If they retyped the tail from the dash onwards, that works — ask if they can do
  it in fewer than five keys.
- **Never say:** a key sequence.

### Exercise 5 — reuse the last argument
- **L1 question:** The notes call one key the highest-value key in the lesson. Which section is it
  in?
- **L2 locate:** Notes, "Reusing the last line".
- **L3 concept:** The previous command's final argument is available on demand, so a long path
  typed once can be reused indefinitely. Different example: `mkdir /some/deep/new/dir` then `cd`
  plus that key.
- **L4 decompose:** Run the first command. Type the second command word. Insert.
- **L5 near-miss:** If they used up-arrow and edited, that is banned by the exercise — ask them to
  do it forwards instead of backwards.
- **Never say:** `Alt-.`.

### Exercise 6 — three deep
- **L1 question:** What happens if you press that key twice in a row?
- **L2 locate:** Notes, "Reusing the last line", last sentence.
- **L3 concept:** Repeated presses walk backwards through history's last arguments, so the wrong
  one is recoverable without leaving the line.
- **L4 decompose:** Chain the three commands. Then, deliberately, press it one time too many and
  watch what appears.
- **L5 near-miss:** If they think it only works once, have them press it three times on one line.
- **Never say:** —

### Exercise 7 — cut and paste an argument
- **L1 question:** Which delete key takes everything from the cursor to the end?
- **L2 locate:** Notes, "Deleting" and "Putting it back".
- **L3 concept:** Cut-to-end plus paste is a full move operation, entirely on the keyboard.
- **L4 decompose:** Put the cursor before the argument. Cut to end. Edit what remains. Go to end.
  Paste.
- **L5 near-miss:** If the paste lands in the wrong place, ask where the cursor was when they
  pressed it.
- **Never say:** the key names.

### Exercise 8 — front and back
- **L1 question:** Can you get to the start of a line in one keystroke?
- **L2 locate:** Notes, "Moving".
- **L3 concept:** The count is the exercise. If it took more than about four presses, a
  single-keystroke jump was available and was not used.
- **L4 decompose:** Start key, type, end key. Count.
- **L5 near-miss:** If they report thirty presses, ask which row of the Moving table they skipped.
- **Never say:** —

### Exercise 9 — Tab ambiguity (Experiment)
- **L1 question:** How many of the five files begin with the letter you typed?
- **L2 locate:** Notes, "Completion".
- **L3 concept:** Completion can only fill in what is unambiguous. With several candidates it
  completes the shared prefix and stops; a second press asks to see the options. Different example:
  two directories called `logs` and `logging` — completion stops at `log`.
- **L4 decompose:** Predictions in writing. Then the one-letter case, both presses. Then the
  three-letter case.
- **L5 near-miss:** If they report the first press did nothing at all, ask them to look very
  carefully at the line — a shared prefix may have been filled in.
- **Never say:** what happens on each press.

### Exercise 10 — no matches (Experiment)
- **L1 question:** If completion has nothing to offer, what is the honest thing for it to do?
- **L2 locate:** Notes, "Completion", third bullet.
- **L3 concept:** Silence is a result. Before typing a forty-character path, type six characters and
  press Tab — if nothing happens, you were wrong, and you found out in one second instead of after
  a failed command.
- **L4 decompose:** Prediction. Try it. Then articulate the check.
- **L5 near-miss:** If they think it is broken, ask what they would want it to invent.
- **Never say:** —

### Exercise 11 — Ctrl-D twice (Experiment)
- **L1 question:** Read the callout in the notes. What is different about the two situations?
- **L2 locate:** Notes, the "Careful with `Ctrl-D`" callout.
- **L3 concept:** The key means "end of input". With characters on the line there is input to
  consume, so it consumes one. With nothing on the line, end-of-input means the shell has no more
  commands coming — so it exits. One consistent rule, two very different outcomes.
- **L4 decompose:** Start a child shell **first**. Predictions in writing. Then both cases.
- **L5 near-miss:** If they killed their session, they skipped the child shell — no harm, have them
  reconnect and note it.
- **Never say:** —

### Exercise 12 — back in the parent (Stretch)
- **L1 question:** What did you note before you started the child shell?
- **L2 locate:** 01/01, "Nesting".
- **L3 concept:** Same check as 01/01 exercise 6, arrived at by a different route.
- **L4 decompose:** PID before. Child. Exit by keystroke. PID after.
- **L5 near-miss:** If the PIDs differ, ask how many shells they were in.
- **Never say:** —

### Exercise 13 — Ctrl-L versus clear (Stretch)
- **L1 question:** What state does each of them preserve?
- **L2 locate:** Notes, "The rest of the line".
- **L3 concept:** One is a readline action that redraws around your current line; the other is a
  program that runs and returns you to a fresh prompt. The difference is only visible when there is
  something half-typed.
- **L4 decompose:** Type half a command. Try each. Compare what is on screen afterwards.
- **L5 near-miss:** If they see no difference, ask whether they had anything typed at the time.
- **Never say:** the answer.

### Exercise 14 — classifying clear (Stretch)
- **L1 question:** Which command from 01/03 answers what kind of thing a word is?
- **L2 locate:** 01/03 notes.
- **L3 concept:** A key binding is not a command word at all — it never reaches the shell's command
  resolution, because readline consumes it before a line is ever submitted.
- **L4 decompose:** Classify the word. Then ask: does the shell ever see the keystroke as a word?
- **L5 near-miss:** If they try to classify the keystroke, that is the insight — ask what they would
  type to look it up.
- **Never say:** —

### Exercise 15 — timing (Stretch)
- **L1 question:** Are you measuring honestly, including your typos?
- **L2 locate:** —
- **L3 concept:** The ratio is the argument for the whole lesson. Typos are part of the cost of
  typing it out, and excluding them is cheating in your own favour.
- **L4 decompose:** Time both. Divide. Multiply out over a realistic command count.
- **L5 near-miss:** If the ratio is near 1, ask whether they included the retries.
- **Never say:** —

### Exercise 16 — the readline config file (Dig)
- **L1 question:** `man bash` has a section devoted to readline. Have you found it?
- **L2 locate:** `man bash`, the READLINE section — search with `/READLINE`.
- **L3 concept:** Readline reads a startup file of its own, separate from bash's, and its settings
  are named options with on/off values. The one wanted here changes what happens on an ambiguous
  first press.
- **L4 decompose:** Find the section. Find the file it names. Find the variables list. Look for one
  mentioning ambiguous completion.
- **L5 near-miss:** If they find `completion-query-items` and stop, ask whether that changes the
  *first* press.
- **Never say:** `~/.inputrc`, `show-all-if-ambiguous`.

### Exercise 17 — listing bindings (Dig)
- **L1 question:** If readline is configurable from a file, is there a builtin that talks to it
  directly?
- **L2 locate:** `man bash`, SHELL BUILTIN COMMANDS; or `help` with no arguments and read the list.
- **L3 concept:** The bindings are inspectable at run time, which is the fastest way to find out
  what a key actually does on *this* machine rather than what a table says.
- **L4 decompose:** Find the builtin. Find the flag that prints bindings. Search the output for the
  actions you know.
- **L5 near-miss:** If the output floods the screen, ask how they would look at it a page at a time
  — `less` is available.
- **Never say:** `bind -P`.

### Exercise 18 — the other editing mode (Dig)
- **L1 question:** Readline's default bindings come from one famous editor. Is there another?
- **L2 locate:** `man bash`, READLINE section, and the `set` builtin's options.
- **L3 concept:** The whole keymap can be swapped. In the other mode, keys are modal — there is an
  insert mode and a command mode — and the single-key jumps from this lesson are simply not bound.
- **L4 decompose:** Find the option. Switch. Test one key from this lesson. Switch back.
- **L5 near-miss:** If they get stuck in the other mode and cannot type, tell them to press `Esc`
  then `i` — and treat that as a successful demonstration.
- **Never say:** `set -o vi`.
