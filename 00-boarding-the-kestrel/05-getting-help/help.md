# 00/05 — Tutor hint ladder

Governed by [`docs/TUTOR_PROTOCOL.md`](../../docs/TUTOR_PROTOCOL.md). One rung per exchange.

This lesson is *about* you. Be scrupulous — a student watching how the tutor behaves here is
building their model of the whole course. Do not soften a single rung for convenience.

### Exercise 1 — `ls -S`
- **L1 question:** Where does `ls` document its own flags?
- **L2 locate:** `man ls`, then `/` and search for the flag itself.
- **L3 concept:** Man pages list flags alphabetically in an OPTIONS section; searching for `-S`
  with a leading dash narrows it fast. Different data: try finding `-t` the same way.
- **L4 decompose:** Open the page. Search. Read. Then build a directory with differently-sized
  files and check.
- **L5 near-miss:** If they found the flag but their test shows nothing, ask whether their files
  actually differ in size.
- **Never say:** what `-S` does.

### Exercise 2 — `cd` has no man page
- **L1 question:** Run `type cd`. What does it say, and how is that different from `type ls`?
- **L2 locate:** Notes, the `help cd` line.
- **L3 concept:** Man pages document programs, which are files on disk. Some commands aren't
  programs at all. Different data: compare `type echo` with `type mkdir`.
- **L4 decompose:** Run `type` on both. Then look for documentation for the kind of thing `cd` is.
- **L5 near-miss:** If they found `man bash` and are lost in it, that's a legitimate answer —
  acknowledge it and ask whether there's something shorter.
- **Never say:** the word "builtin" before they've seen it in `type`'s output.

### Exercise 3 — write a help request
- **L1 question:** Which of the three parts is hardest for you to write honestly?
- **L2 locate:** Notes, "What it will do"; `docs/TUTOR_PROTOCOL.md`, Step 0.
- **L3 concept:** The expectation is the valuable part — it's the only window into their model.
- **L4 decompose:** Find a command that really fails. Capture the real output. Write the expectation
  last.
- **L5 near-miss:** If they described the error instead of pasting it, point at the difference.
- **Never say:** don't write the request for them.

### Exercise 4 — search by description
- **L1 question:** You know the *idea* but not the *name*. What would you need to search — names,
  or descriptions?
- **L2 locate:** Notes, the `apropos` line. Or `man -k`.
- **L3 concept:** There's an index of one-line page descriptions, and a tool that greps it.
  Different data: try searching the descriptions for "directory" and see how noisy it is.
- **L4 decompose:** Find the search tool. Pick a keyword. Narrow the results.
- **L5 near-miss:** If they get nothing, ask whether the database exists — `sudo mandb` builds it.
- **Never say:** the target command's name.

### Exercise 5 — read the protocol
- Reflective. If stuck, ask which rung feels slowest, then which feels most useless — the second
  answer is usually the honest one.

### Exercise 6 — tutor session *(Experiment)*
- If **you** are the agent they run this against: behave exactly as the protocol says. Do not
  perform being strict, and do not soften because it's an exercise. The transcript is the artifact.
- Prediction before the session. Confirm it's written.
- If their jailbreak succeeds, tell them plainly that it worked and that they should report it. An
  honest bug report is worth more here than a clean transcript.

### Exercise 7 — man 5 *(Stretch)*
- **L1 question:** Which section holds file formats? You wrote it down in 00/01.
- **L2 locate:** Their own 00/01 answers.
- **L3 concept:** Same name, different sections, different documents. Different data: compare
  `man 1 printf` and `man 3 printf`.
- **L4 decompose:** Recall the section number. Request it explicitly. Find the field list. Count to
  the second field.
- **L5 near-miss:** If they landed on the command's page, ask which section they got and whether
  they asked for one.
- **Never say:** what the second field means. (It's historical and slightly surprising — let them
  find it.)

### Exercise 8 — full-text man search *(Dig)*
- **L1 question:** `apropos` searches descriptions. What if the phrase you want is buried in the
  middle of a page?
- **L2 locate:** `man man`, `/` and search for `regex` or for `whatis`.
- **L3 concept:** Two different indexes: a one-line description database, and brute-force searching
  every page's full text. Different cost, different results. Different data: try both on "umask"
  and compare how many hits each gives.
- **L4 decompose:** Find the flag. Explain the difference. Run it on the phrase.
- **L5 near-miss:** If it returns nothing, ask whether the phrase needs quoting — it has a space.
- **Never say:** the flag.

### Exercise 9 — all sections *(Dig)*
- **L1 question:** When two pages share a name, `man` picks one. How would you tell it not to
  choose?
- **L2 locate:** `man man`, OPTIONS section, near the flag from exercise 8.
- **L3 concept:** One flag shows every match in sequence; another just lists what exists. Different
  data: try it on `printf`.
- **L4 decompose:** Find the flag. Run it on `passwd`. Note you have to quit each page.
- **L5 near-miss:** If they found the *listing* flag rather than the *display all* flag, that's
  close — ask whether it displayed the pages or just named them.
- **Never say:** the flag.
