# 02/06 — Tutor hint ladder

Read `docs/TUTOR_PROTOCOL.md` first. One rung per exchange. Never state a command.

**Escalation notes**

- This lesson frustrates students faster than any other in the chapter, because failures here look
  like the *tool* is broken. The first move whenever they are stuck is always the same question:
  "what did the shell actually pass to the program?" Ask it before offering anything.
- Two techniques unlock nearly everything: `ls -b` and tab completion. If a student is fighting a
  name by retyping it, steer to completion before any flag.
- The lookalikes (14–19) are the section students most often fake — they report "they look the same"
  and stop. The deliverable is the escaped bytes; hold them to it.
- The chapter's incident is next and is solved with exactly these skills. Do not tell them that. If
  they are floundering at exercise 17 it is better to spend three more exchanges here than to let
  them into `07-incident-02` unequipped.
- Never suggest renaming anything. The lab says so and students will ask.

---

### Exercise 1
- **L1 question:** Does every filename contain only characters that stay on one line?
- **L2 locate:** Notes, "Whitespace you cannot see".
- **L3 concept:** `ls` writes a name and then a newline. If the name itself has a newline in it, the
  output has more lines than entries — nothing has gone wrong, the display is just ambiguous.
- **L4 decompose:** (1) list it; (2) count lines; (3) count entries another way; (4) explain.
- **L5 near-miss:** If they insist there are seven files, ask them to read the last two lines
  together.
- **Never say:** "one of the names contains a newline".

### Exercise 2
- **L1 question:** Is there an `ls` flag that prints names unambiguously?
- **L2 locate:** Notes, the `ls -b` block.
- **L3 concept:** The escaped form is a *rendering* of the same bytes, chosen so no two different
  names can render alike.
- **L4 decompose:** (1) find the flag; (2) run it; (3) copy all six lines exactly.
- **L5 near-miss:** If they use `-Q`, ask what it shows for the tab.
- **Never say:** `-b`.

### Exercise 3
- **L1 question:** How many words does the shell think `cat deck 3 bay 2/strain log.txt` is?
- **L2 locate:** Notes, the three-method table.
- **L3 concept:** Try `cat 'a b'` on a file you create in `/tmp` and watch it work; the mechanism is
  identical.
- **L4 decompose:** (1) pick a method; (2) apply it to every space in the path; (3) read the file.
- **L5 near-miss:** If they quote only part of the path, the error names the piece they missed.
- **Never say:** the completed command.

### Exercise 4
- **L1 question:** How would you refer to a name that begins with a space, in a way the shell keeps?
- **L2 locate:** Exercise 2's escaped listing — those forms are valid input.
- **L3 concept:** The escaped output is designed to be pasted back. That is the whole reason it
  exists.
- **L4 decompose:** (1) get the escaped names; (2) paste each into a read command; (3) match contents
  to names.
- **L5 near-miss:** If two of the three give the same content, they read the same file twice.
- **Never say:** how to type a leading space.

### Exercise 5
- **L1 question:** Which command from `02/02` returns you to the previous directory without naming
  it?
- **L2 locate:** `02/02`, the `cd -` section.
- **L3 concept:** The shell remembers exactly one previous directory, in a variable.
- **L4 decompose:** (1) cd in, quoting or completing; (2) `pwd`; (3) come back.
- **L5 near-miss:** If they use `cd ../..`, that works but names a path — re-read the exercise.
- **Never say:** `cd -`.

### Exercise 6
- **L1 question:** In the plain listing, could you tell a tab from three spaces?
- **L2 locate:** Notes, the `-b` block; the escape for a tab is in the sample output.
- **L3 concept:** A tab renders as horizontal space whose width depends on the column it starts in.
  Spaces do not. The rendering cannot distinguish them; the escape can.
- **L4 decompose:** (1) escaped listing; (2) find the two-character escape; (3) report the full name.
- **L5 near-miss:** If they claim `-Q` proved it, ask what `-Q` printed between `panel` and `report`.
- **Never say:** `\t`.

### Exercise 7
- **L1 question:** What do most command-line tools assume separates one filename from the next?
- **L2 locate:** Notes, gotchas, the newline entry.
- **L3 concept:** A tab is awkward for a human to type. A newline is *invisible to a program* that
  splits input into lines — it does not look awkward, it looks like two files.
- **L4 decompose:** (1) stat the file, escaping or completing the name; (2) report the size; (3)
  compare the two dangers.
- **L5 near-miss:** If they say "both are just annoying", ask what `wc -l` would report.
- **Never say:** the exercise-28 answer.

### Exercise 8
- **L1 question:** You press Tab after `note`. Three names share that prefix. What can the shell
  safely do?
- **L2 locate:** Notes, the gotcha about a unique prefix; `02/02` and Chapter 1 on completion.
- **L3 concept:** Completion fills in the longest unambiguous part and then stops. The stall is the
  signal that more than one candidate exists — press Tab again to see them.
- **L4 decompose:** (1) type the prefix; (2) Tab; (3) Tab again and read the candidates; (4) add the
  one character that disambiguates, then Tab once more.
- **L5 near-miss:** If they cannot see how to add a trailing space "by hand", note that completion
  will add it for them once the choice is unique.
- **Never say:** how to escape a trailing space.

### Exercise 9
- **L1 question:** In the working case, what is the first character of the argument? In the failing
  case?
- **L2 locate:** Notes, "Names that begin with a dash".
- **L3 concept:** Nothing about the file changed. The *word the shell handed over* changed, and the
  program parses that word before it ever touches a filesystem.
- **L4 decompose:** (1) run both; (2) read the error; (3) note which letter it complains about.
- **L5 near-miss:** If they say `cd` broke something, ask what `cat` printed.
- **Never say:** "the dash makes it look like an option".

### Exercise 10
- **L1 question:** Two ways to stop a word looking like an option: change the word, or tell the
  program to stop looking. Which is which?
- **L2 locate:** Notes, the two-fix block.
- **L3 concept:** One prefixes a path component so the first character is no longer a dash; the other
  is a separator every GNU tool honours.
- **L4 decompose:** (1) do the path one; (2) do the separator one; (3) report both.
- **L5 near-miss:** If they put the separator after the filename, the error will say so.
- **Never say:** `./` or `--` spelled out.

### Exercise 11
- **L1 question:** Is `--help` a valid option to `cat`? What does `cat --help` do?
- **L2 locate:** Exercise 10's two fixes, tried on this file.
- **L3 concept:** Both fixes still work here — the interesting part is what happens with *neither*,
  and why that failure is silent success rather than an error.
- **L4 decompose:** (1) try the bare name; (2) try both fixes; (3) explain what the bare attempt did.
- **L5 near-miss:** If they report "it printed the help", that is the finding — now ask which fix
  they would trust in a script.
- **Never say:** which fix to prefer.

### Exercise 12
- **L1 question:** Are `a`, `u`, `d`, `i` and `t` all real `ls` flags?
- **L2 locate:** Notes, the `ls -audit` callout; `man ls` for each letter.
- **L3 concept:** A word of five letters after a dash is five separate short options. The word being
  pronounceable is a coincidence.
- **L4 decompose:** (1) run it; (2) look up each letter; (3) describe the listing you got.
- **L5 near-miss:** If they cannot say why an inode number appeared, look up `-i`.
- **Never say:** the five expansions.

### Exercise 13
- **L1 question:** Does `cd` take options? What happens to a directory name starting with a dash?
- **L2 locate:** Exercise 10's fixes — they apply to `cd` as well.
- **L3 concept:** `cd -` already means something else entirely, which makes a directory whose name
  starts with a dash particularly nasty.
- **L4 decompose:** (1) try it bare and read the failure; (2) apply a fix; (3) come back.
- **L5 near-miss:** If `cd -staging` silently took them somewhere unexpected, ask where they are.
- **Never say:** the working form.

### Exercise 14
- **L1 question:** Count the lines. Now count the *distinct-looking* names. Are those numbers the
  same?
- **L2 locate:** Notes, "Names that render identically".
- **L3 concept:** Two files in one directory cannot have the same name — the filesystem forbids it.
  So if you see a duplicate, your eyes are wrong, not the filesystem.
- **L4 decompose:** (1) list; (2) write both counts down before investigating.
- **L5 near-miss:** If they immediately jump to escapes, good — but make them write the two counts
  first, because the gap is the finding.
- **Never say:** how many pairs there are.

### Exercise 15
- **L1 question:** What made the tab visible in exercise 6? Will it do the same for a character
  outside ASCII?
- **L2 locate:** Notes, the `LC_ALL=C ls -b` block.
- **L3 concept:** "Printable" is a locale question. In a UTF-8 locale Cyrillic is printable and gets
  printed; in the C locale nothing above ASCII is, so it is escaped instead.
- **L4 decompose:** (1) try the escaping flag alone and note it changes nothing here; (2) set the
  locale for one command; (3) re-run; (4) report five lines.
- **L5 near-miss:** If they set the variable permanently with `export`, that works but ask them to do
  it for one command instead, and why that is better.
- **Never say:** `LC_ALL=C`.
- **Load-bearing.**

### Exercise 16
- **L1 question:** You have two escaped names. Which one has extra bytes in it, and where?
- **L2 locate:** Exercise 15's output; the file contents name the character.
- **L3 concept:** The escaped digits are the bytes of one character in UTF-8. You do not have to
  decode them — the file tells you, and you only need to attach the right file to the right name.
- **L4 decompose:** (1) read both files; (2) match the one whose name shows escapes to the one whose
  contents name a non-ASCII character.
- **L5 near-miss:** If they guess the mapping, ask how they would prove it.
- **Never say:** which is which.

### Exercise 17
- **L1 question:** Same as 16, applied to a different pair. Which name is longer in bytes?
- **L2 locate:** Exercise 15's output.
- **L3 concept:** `stat -c %s` is not the tool here — you want the *name's* length, not the file's.
  Compare the escaped forms, or count what the shell shows you.
- **L4 decompose:** (1) escaped names; (2) read both files; (3) match.
- **L5 near-miss:** If they say both look like `deck.txt` and stop, that is exercise 14's answer, not
  this one's.
- **Never say:** "Cyrillic".

### Exercise 18
- **L1 question:** Compare the escaped name to the rendered name. Which is longer, and by how much?
- **L2 locate:** Exercise 15's output, third line.
- **L3 concept:** A character can have a width of zero. It occupies bytes in the name and no space on
  the screen — so the rendered name is a strict subset of the truth.
- **L4 decompose:** (1) find the escape; (2) count its bytes; (3) read the file, which names it.
- **L5 near-miss:** If they say the name is just `panel.txt`, ask why `cat lookalikes/panel.txt`
  fails.
- **Never say:** "zero width space".

### Exercise 19
- **L1 question:** How did you get any awkward name into a command line earlier in this lesson
  without typing it?
- **L2 locate:** Notes, the tab-completion row; exercise 8.
- **L3 concept:** Completion works from bytes, so it will happily complete a name you could not type.
  Copy-pasting the escaped form is the other legitimate route.
- **L4 decompose:** (1) type the unambiguous prefix; (2) Tab; (3) if it stalls, add one character and
  Tab again.
- **L5 near-miss:** If they cannot make completion pick the Cyrillic one, ask what prefix the two
  names share — the answer is `d`, and nothing more.
- **Never say:** the paste-the-escaped-form trick, unless they have already tried completion.

### Exercise 20
- **L1 question:** Which two entries does the "show everything" flag include that you almost never
  want?
- **L2 locate:** Notes, the dots section, third bullet.
- **L3 concept:** Three levels: hide dot-names, show all, show all but the two navigational ones.
- **L4 decompose:** (1) three listings; (2) three counts; (3) explain each difference.
- **L5 near-miss:** If two counts are equal, one of the listings is not what they think it is.
- **Never say:** `-a` / `-A`.

### Exercise 21
- **L1 question:** Is `..` a name stored in the directory, or a thing `ls` invents?
- **L2 locate:** `02/01`, on `.` and `..`; notes, the dots section.
- **L3 concept:** `..` is a real entry with a fixed meaning. `..double-dot` merely starts with the
  same two characters, the way `note` and `notes` are different words.
- **L4 decompose:** (1) list all; (2) read both odd files; (3) say what `..` points at and what these
  point at.
- **L5 near-miss:** If they claim `...` means "grandparent", ask them to `cd` into it.
- **Never say:** "they are ordinary filenames".

### Exercise 22
- **L1 question:** What did an apparently empty directory turn out to contain last lesson?
- **L2 locate:** `02/05`, exercise 17.
- **L3 concept:** "Empty" is a claim that requires seeing hidden entries too, and ideally a
  disk-usage number that agrees.
- **L4 decompose:** (1) listing with hidden entries; (2) a size check; (3) state the conclusion.
- **L5 near-miss:** If they used plain `ls` and called it proven, ask what plain `ls` would have said
  about `accounting`.
- **Never say:** the flag combination.

### Exercise 23
- **L1 question:** Which tools did *not* hide the dot-directory in the previous lesson?
- **L2 locate:** Notes, the dots section, first bullet.
- **L3 concept:** Hiding lives in one program's display logic. Anything that walks a directory
  through the kernel sees every entry.
- **L4 decompose:** (1) pick a walking tool; (2) point it at `dotted`; (3) report.
- **L5 near-miss:** If they pick `tree`, remind them `tree` has the same convention — which flag is
  needed, and does that prove or undermine the point?
- **Never say:** `du`.

### Exercise 24
- **L1 question:** For each name, ask: does the shell do anything to this word before the program
  sees it?
- **L2 locate:** Notes, "Metacharacters".
- **L3 concept:** Four of the five names contain a character the shell treats specially. Which one
  does not is part of the answer.
- **L4 decompose:** (1) try each bare; (2) note which fail and how; (3) fix each.
- **L5 near-miss:** If a bare attempt silently succeeded, ask whether the shell had any reason to
  change that word.
- **Never say:** which characters are special.

### Exercise 25
- **L1 question:** What is `$HOME` when you type it bare? Is that the shell or the program doing it?
- **L2 locate:** Chapter 1, `04-variables`.
- **L3 concept:** One kind of quote stops the shell interpreting almost everything; the other still
  allows variable expansion. You do not need the full rules to observe which is which.
- **L4 decompose:** (1) try double quotes; (2) try single; (3) report both, including any error.
- **L5 near-miss:** If both appear to fail, look closely at what the error names — it will be a path
  in `/home`.
- **Never say:** which quote does which.

### Exercise 26
- **L1 question:** If the name contains the same character you are quoting with, where does the quote
  end?
- **L2 locate:** Notes, the metacharacters section; the three-method table at the top.
- **L3 concept:** The apostrophe closes the quote early, so the rest of the name becomes something
  else. Another quoting style, or escaping that one character, avoids the collision.
- **L4 decompose:** (1) try single quotes and read the failure; (2) pick a different method; (3)
  report.
- **L5 near-miss:** If their shell is sitting at a continuation prompt waiting for a closing quote,
  that *is* the lesson — Ctrl-C and explain it.
- **Never say:** the working form.

### Exercise 27 — Experiment
- **L1 question:** Before running: which of these six lines contains a word the shell will split, and
  which contains a word a program will read as an option?
- **L2 locate:** All three sections of the notes — this exercise mixes them deliberately.
- **L3 concept:** The two interesting lines are the ones that neither error nor do what was asked.
  Silent wrong behaviour is the thing to fear.
- **L4 decompose:** (1) predictions for all six; (2) run; (3) mark which predictions were wrong;
  (4) name the two interesting ones.
- **L5 near-miss:** If they name a line that errored as "interesting", ask whether an error is
  dangerous or helpful.
- **Never say:** which two.
- **No prediction ⇒ PASS-WITH-NOTES cap.**

### Exercise 28 — Experiment
- **L1 question:** How many lines did `ls awkward` print in exercise 1?
- **L2 locate:** Exercise 1 and 7.
- **L3 concept:** Counting lines only counts filenames if filenames cannot contain newlines. That
  assumption is baked into an enormous amount of shell code and it is false.
- **L4 decompose:** (1) predict; (2) run; (3) compare with the real count; (4) state the rule.
- **L5 near-miss:** If they say "so the count is off by one", push for the general statement.
- **Never say:** the number.
- **No prediction ⇒ PASS-WITH-NOTES cap.**

### Exercise 29
- **L1 question:** Three separate requirements: hidden entries, descend, unambiguous. Which flag does
  each?
- **L2 locate:** `02/02` for recursion, this lesson for escaping.
- **L3 concept:** They compose. Each flag answers one question and none of them overlap.
- **L4 decompose:** (1) build it one flag at a time, checking each addition; (2) justify each.
- **L5 near-miss:** If `.draft` is missing, one requirement is unmet.
- **Never say:** the combination.

### Exercise 30
- **L1 question:** Which `stat` placeholder gives you a name you could paste back?
- **L2 locate:** `man stat`, the format table — it is one letter, upper case.
- **L3 concept:** There is a lower-case placeholder for the raw name and an upper-case one for the
  quoted name. Same pattern as the permissions placeholders you already met.
- **L4 decompose:** (1) find it; (2) combine with the size; (3) run over the directory.
- **L5 near-miss:** If the output has unquoted spaces, they used the raw one.
- **Never say:** `%N`.

### Exercise 31
- **L1 question:** What makes two names refer to the same file?
- **L2 locate:** `02/05`, exercise 26 and the `stat` fields.
- **L3 concept:** Same inode on the same filesystem means the same file. Different inodes means two
  files that merely look alike.
- **L4 decompose:** (1) stat both; (2) compare inodes; (3) answer the "could they" question.
- **L5 near-miss:** If they say "yes, if you renamed one", note that renaming removes a name rather
  than adding one — the mechanism they want is Chapter 3.
- **Never say:** "hard link".

### Exercise 32
- **L1 question:** Is there a listing option that replaces awkward characters with a placeholder
  rather than escaping them?
- **L2 locate:** `man ls` — a single lower-case letter, near `-b`.
- **L3 concept:** Two different goals: keep the name pasteable (escape), or keep the layout intact
  (substitute). This exercise wants the second.
- **L4 decompose:** (1) find it; (2) run it; (3) confirm one line per entry.
- **L5 near-miss:** If they use the escaping flag, that also gives one line — ask which one is
  `ls`'s default when writing to a terminal, and why.
- **Never say:** `-q`.

### Exercise 33 — Dig
- **L1 question:** `-b` and `-Q` cannot be the only two styles. Is there a general form?
- **L2 locate:** `man ls`, search for `quoting`.
- **L3 concept:** One long option taking a word, with about eight accepted values; two of them
  mention the shell in their names.
- **L4 decompose:** (1) find it; (2) list the values; (3) pick the shell-ready one and run it.
- **L5 near-miss:** If they pick the plain shell style and the non-ASCII names come out raw, that is
  a locale question — see exercise 15.
- **Never say:** the option name or any value.

### Exercise 34 — Dig
- **L1 question:** The man page entry for that option mentions something that overrides it. What?
- **L2 locate:** `man ls`, the same paragraph as exercise 33's option.
- **L3 concept:** Many GNU tools read a variable named after the behaviour it controls, so a
  preference can be set once instead of typed every time.
- **L4 decompose:** (1) find the variable; (2) set it for one command; (3) try it on both directories
  and explain the difference.
- **L5 near-miss:** If it appears to do nothing on the lookalikes, that is the expected result — ask
  what else exercise 15 needed.
- **Never say:** the variable name.

### Exercise 35 — Dig
- **L1 question:** Both tools escape the same bytes. Do they wrap the result the same way?
- **L2 locate:** Exercises 15 and 30's outputs, side by side.
- **L3 concept:** One produces a bare escaped word; the other produces a quoted string, splicing in
  a `$'…'` fragment for the awkward bytes. Only one of those is directly pasteable.
- **L4 decompose:** (1) run both; (2) put the two Cyrillic lines side by side; (3) test which one
  works when pasted.
- **L5 near-miss:** If they assert one is pasteable without trying it, ask them to try it.
- **Never say:** which one wins.

### Exercise 36 — Dig
- **L1 question:** What could a filename contain that would change your terminal rather than just
  display oddly?
- **L2 locate:** `man ls` — one short flag and one long option, described near each other.
- **L3 concept:** A name can contain the same escape sequences a program uses to move the cursor,
  change colours, or clear the screen. Printing it raw executes them.
- **L4 decompose:** (1) find both; (2) run both over `awkward`; (3) reason about the untrusted case.
- **L5 near-miss:** If they prefer raw because it is "more accurate", ask what accuracy is worth if
  the output can rewrite itself.
- **Never say:** `-q` / `--show-control-chars` as the answer, and never suggest creating a file with
  escape sequences in its name to test it.
