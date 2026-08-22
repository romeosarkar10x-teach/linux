# 01/06 — Validator rubric

Governed by [`docs/VALIDATION_PROTOCOL.md`](../../docs/VALIDATION_PROTOCOL.md).

Evidence: `~/01-06-answers.md`, `history`, `~/.bash_history`, and re-running read-only commands.

Lab: `/labs/01-shell-and-terminal/06-history/`

**Check first:** `maint-old-history` must be unmodified, and the student's own history must still
be intact. If `~/.bash_history` is empty or `HISTSIZE` is tiny in their session, exercises 11, 12,
16 or 20 were run outside a child shell. Note it, do not fail them for it, and be aware that the
history evidence for *other* exercises may have been destroyed by it.

**A caution specific to this lesson.** History is your usual evidence source, and this lesson
deliberately teaches the student how to keep things out of it. A missing history line here is
ambiguous — it may mean the work was not done, or it may mean exercise 11 worked. Ask before
concluding.

---

### Exercise 1 — last ten
| Field | |
|---|---|
| **Goal** | Reads the list, with numbers. |
| **Expected end state** | Ten numbered lines, timestamped (this image sets `HISTTIMEFORMAT`). |
| **Evidence commands** | `history 10` |
| **Accept** | `history 10`, or `history` piped to a limiter. |
| **Reject** | `cat ~/.bash_history` — that is the file, not the list, and it is the distinction the lesson is about. |
| **Red flags** | — |
| **Probe question** | "Are those numbers the same in another terminal?" |

### Exercise 2 — re-run the previous
| Field | |
|---|---|
| **Goal** | `!!`. |
| **Expected end state** | A command appearing twice consecutively. |
| **Evidence commands** | `history 5` |
| **Accept** | `!!`. Up-arrow accepted only as a supplement. |
| **Reject** | Retyping. |
| **Red flags** | — |
| **Probe question** | "What does `sudo !!` do, and why is it the most-used form?" |

### Exercise 3 — last argument
| Field | |
|---|---|
| **Goal** | `!$`, and noticing bash echoes the expansion. |
| **Expected end state** | Both commands ran; the echoed line `head -1 sampler-notes.txt` quoted. |
| **Evidence commands** | `history 5` |
| **Accept** | The echo quoted from their transcript. |
| **Reject** | Answer with no mention of the echoed line — that is half the exercise. |
| **Red flags** | — |
| **Probe question** | "Why does bash print the line before running it?" |

### Exercise 4 — search without running
| Field | |
|---|---|
| **Goal** | `Ctrl-R`, and the escape that does not execute. |
| **Expected end state** | A command found and **not** run. |
| **Evidence commands** | The found command should be absent from the tail of `history`. Demonstration preferred. |
| **Accept** | `Esc`, right-arrow, `Ctrl-G` (abandons entirely — accept with a note that it also discards the find). |
| **Reject** | Pressing Enter. |
| **Red flags** | The command present in history immediately after the search. |
| **Probe question** | "You searched for `rm` and the first hit is not the one you meant. Which key saves you?" |

### Exercise 5 — search and run
| Field | |
|---|---|
| **Goal** | Same tool, deliberate execution, and awareness of the risk. |
| **Expected end state** | Command re-run; sentence preferring inspect-first. |
| **Evidence commands** | `history 5` |
| **Accept** | Any sensible risk statement. |
| **Reject** | No sentence. |
| **Red flags** | — |
| **Probe question** | "How do you know the match you saw was the one you wanted?" |

### Exercise 6 — three recall forms
| Field | |
|---|---|
| **Goal** | Positional, prefix, and substring recall. |
| **Expected end state** | Three recalls: `!n`, `!cat`, `!?strain?`. |
| **Evidence commands** | `history 20` |
| **Accept** | All three forms, each identified. |
| **Reject** | Three uses of the same form. |
| **Red flags** | A `!n` whose number does not correspond to anything in their list. |
| **Probe question** | "Which of the three would you avoid on a shared machine, and why?" |

### Exercise 7 — list versus file
| Field | |
|---|---|
| **Goal** | The central distinction of the lesson. |
| **Expected end state** | A distinctive command present in `history`, absent from `~/.bash_history`, then present after `history -a`. |
| **Evidence commands** | `history \| tail -3`; `tail -3 ~/.bash_history` |
| **Accept** | `history -a`. `history -w` accepted with a note that it overwrites rather than appends. |
| **Reject** | Exiting the shell to make it appear — the exercise says without exiting. |
| **Red flags** | No `grep`/`tail` of the file in history at the "absent" stage — they may have asserted it. |
| **Probe question** | "You have three terminals open. Which one's history wins?" |

### Exercise 8 — reading maint-old-history
| Field | |
|---|---|
| **Goal** | A history file is plain text with an interleaved timestamp format. |
| **Expected end state** | **Six** commands. `#` lines are seconds since the epoch, written because `HISTTIMEFORMAT` was set in that session. Last complete command: `ls -l`. |
| **Evidence commands** | `cat maint-old-history` |
| **Accept** | Count of 6. Explanation naming epoch seconds, or "a timestamp", with the connection to timestamped history. |
| **Reject** | Counting 13 lines as 13 commands. Naming `cat sampler-not` as the last *complete* command — it is not complete. |
| **Red flags** | File modified. |
| **Probe question** | "Would this file look different if timestamps had been switched off?" |

### Exercise 9 — the truncated last line
| Field | |
|---|---|
| **Goal** | The load-bearing insight for 01/07. |
| **Expected end state** | Reconstruction: `cat sampler-notes.txt`, the file being present in the same lab. Reason: the file is written as the session ends, so an interrupted or killed session leaves the last line unfinished. |
| **Evidence commands** | `ls`; `cat maint-old-history` |
| **Accept** | Any correct mechanism: session killed, connection dropped, shell terminated before finishing the write. |
| **Reject** | "The user made a typo." A typo produces wrong letters, not a word that stops. Push back with the probe. |
| **Red flags** | A reconstruction naming a file that is not in the directory. |
| **Probe question** | "If it were a typo, what would you expect the rest of the line to look like?" |

### Exercise 10 — what history -c does not do
| Field | |
|---|---|
| **Goal** | Memory versus disk, applied to a destructive-looking command. |
| **Expected end state** | Two sentences: it clears the in-memory list; it does not delete or truncate the file at that moment. The later commands are there because they were typed after the clear and written on exit. |
| **Evidence commands** | `cat maint-old-history` |
| **Accept** | Correct on both halves. |
| **Reject** | "It deleted the history file" — the file is right there with lines both before and after it. |
| **Red flags** | — |
| **Probe question** | "The commands *before* the clear are also still in the file. Explain that." (They were already written by an earlier session, or the clear did not reach the disk. Either reasoning is acceptable; the point is that memory and disk are separate.) |

### Exercise 11 — the leading space
| Field | |
|---|---|
| **Goal** | `ignorespace`, and why it exists. |
| **Expected end state** | Command absent from the child shell's list; `HISTCONTROL` shown as `ignoreboth`. |
| **Evidence commands** | `echo "$HISTCONTROL"` |
| **Accept** | Recognising that `ignoreboth` includes `ignorespace`. |
| **Reject** | Concluding the setting is absent because the word `ignorespace` does not literally appear. |
| **Red flags** | Done in the main shell — harmless here, but check. |
| **Probe question** | "Name a command you would genuinely want to hide this way." |

### Exercise 12 — a tiny HISTSIZE
| Field | |
|---|---|
| **Goal** | The cap applies to memory, and child-shell settings do not propagate upward. |
| **Expected end state** | Child's list holds roughly 3 entries; main session unaffected. |
| **Evidence commands** | In the main shell afterwards: `echo $HISTSIZE`; `history \| wc -l` |
| **Accept** | Noting that the parent was untouched — that is the more important half. |
| **Reject** | Main session's history destroyed and reported as expected behaviour. |
| **Red flags** | `HISTSIZE=3` still set in the main shell during grading. |
| **Probe question** | "Why did your parent shell not inherit that setting?" (Chapter 11 answers it properly; a partial answer is fine.) |

### Exercise 13 — `!!` twice (Experiment)
| Field | |
|---|---|
| **Goal** | The reference moves, because the expansion is itself recorded. |
| **Expected end state** | Predictions written. Third line runs `echo two`. Fourth `!!` also runs `echo two`, because line three *became* `echo two` in history. |
| **Evidence commands** | Reproduce. |
| **Accept** | Predicting the fourth would run `echo one` is a good, wrong prediction — full pass with a correct follow-up explanation. |
| **Reject** | No prediction. |
| **Red flags** | — |
| **Probe question** | "What text did line three actually add to your history?" |

### Exercise 14 — `!$` and `!^` (Experiment)
| Field | |
|---|---|
| **Goal** | The biggest history-expansion surprise, verified in the image. |
| **Expected end state** | Predictions written. `echo !$` → `scratch`. `echo !^` → **also `scratch`**, because the previous command is now `echo scratch`, whose first argument is `scratch`. |
| **Evidence commands** | Reproduce the three lines in order. |
| **Accept** | Predicting `sampler-notes.txt` for `!^` is the intuitive and wrong answer — full pass with a correct explanation afterwards. The explanation must identify that history advanced. |
| **Reject** | No prediction. Reporting `sampler-notes.txt` as the *observed* output — they did not run it, or not in order. |
| **Red flags** | Observations inconsistent with a reproduction. |
| **Probe question** | "Which command was `!^` actually looking at?" |

### Exercise 15 — two shells (Experiment)
| Field | |
|---|---|
| **Goal** | Two processes, two lists, no live sharing. |
| **Expected end state** | Predictions written. B does not see A's command. After A exits and B runs `history -r`, B does. |
| **Evidence commands** | Reproduce with two `kestrel enter` sessions. |
| **Accept** | Explanation citing separate process memory. |
| **Reject** | No prediction. |
| **Red flags** | Claiming B saw it live. |
| **Probe question** | "What would you have to run in A to make it visible to B sooner?" |

### Exercise 16 — HISTFILE unset versus empty (Stretch)
| Field | |
|---|---|
| **Goal** | Carries 01/04's distinction into a real setting — and finds it does not always matter. |
| **Expected end state** | Prediction, then both cases tested. In bash, **both** suppress writing the history file on exit. |
| **Evidence commands** | Check `~/.bash_history`'s modification time before and after each child shell exits. |
| **Accept** | Concluding the distinction did **not** produce different behaviour here. That is the correct finding and a full pass. |
| **Reject** | Claiming a difference without evidence — check their method; a stale modification time is easy to misread. |
| **Red flags** | Their own history file emptied. |
| **Probe question** | "Does that mean unset and empty are the same thing? Or just that this program treats them the same?" |

### Exercise 17 — where `!$` bites (Stretch)
| Field | |
|---|---|
| **Goal** | Expansion timing, and why inspect-before-commit wins. |
| **Expected end state** | A constructed case where the previous command's last argument is not the wanted one — a destination directory is the classic. |
| **Evidence commands** | Read the answers file; `history`. |
| **Accept** | Any genuine case. Bonus if their example would have been destructive. |
| **Reject** | An example where both approaches give the same result — it does not demonstrate anything. |
| **Red flags** | — |
| **Probe question** | "At what moment did you find out it was wrong, in each case?" |

### Exercise 18 — classify history (Stretch)
| Field | |
|---|---|
| **Goal** | Third instance of the builtin-necessity argument. |
| **Expected end state** | `history is a shell builtin`; reasoning that the list is in the shell's own memory. |
| **Evidence commands** | `type history` |
| **Accept** | Reasoning citing process memory. |
| **Reject** | "It reads the file, so it could be a program" — ask how it shows unwritten commands. |
| **Red flags** | — |
| **Probe question** | "Name the three builtins you have now met that exist for this same reason." |

### Exercise 19 — decoding the epoch (Dig)
| Field | |
|---|---|
| **Goal** | Epoch seconds are a standard representation; `date -d @N` converts. |
| **Expected end state** | `date -d @6839203404` → `2186-09-22 10:43:24`, the `ls -l` that is the last complete command. |
| **Evidence commands** | `date -d @6839203404 '+%F %T'` |
| **Accept** | Any correct conversion route. Timezone differences are acceptable if consistent — the container runs UTC. |
| **Reject** | Converting the final, truncated line's timestamp and calling it the last complete command. |
| **Red flags** | No `man date` in history. |
| **Probe question** | "What is second zero of that count?" |

### Exercise 20 — loading another history file (Dig)
| Field | |
|---|---|
| **Goal** | `history -r <file>`, and understanding the contamination risk. |
| **Expected end state** | In a child shell, `history` shows `maint-old-history`'s commands dated 2186-09-22. |
| **Evidence commands** | `bash -i` then `history -r maint-old-history; history 6` |
| **Accept** | Reason: those lines join your list and would be written into *your* history file on exit, permanently mixing another account's commands into your own record. |
| **Reject** | Doing it in the main shell and not noticing the consequence. If they did, have them check whether their history file now contains 2186 entries. |
| **Red flags** | 2186 timestamps present in the student's own `~/.bash_history`. |
| **Probe question** | "What would a validator conclude if they found those lines in your history a week from now?" |

### Exercise 21 — substitution on recall (Dig)
| Field | |
|---|---|
| **Goal** | Reads HISTORY EXPANSION properly — the deepest man-page dive in the chapter. |
| **Expected end state** | `^sampler-notes.txt^maint-old-history` or `!!:s/sampler-notes.txt/maint-old-history/`; the echoed expansion shown. |
| **Evidence commands** | `history 5` |
| **Accept** | Either form. |
| **Reject** | Retyping the command with the new filename. |
| **Red flags** | No `man bash` access in history. |
| **Probe question** | "Does the shorthand form replace every occurrence, or just the first?" (Just the first.) |

---

## Lesson roll-up

**Load-bearing (must PASS):** 7, 8, 9, 13, 14.

Exercise 9 is the one that matters beyond this lesson — 01/07's incident turns entirely on
understanding why a history file's last line is unfinished. A student who has not got that should
not proceed to the incident; send them back to 9 rather than letting them brute-force the finale.

Exercises 13 and 14 together are the history-expansion trap, and 14 is verified: `!^` really does
give `scratch`. A student reporting otherwise did not run it in order.

**Nice to have:** 1, 2, 3, 4, 5, 6, 10, 11, 12, 15, 16, 17, 18.

**Dig (attempts noted, not required):** 19, 20, 21.

**Before signing off:** check `HISTSIZE`, `HISTFILE` and `HISTCONTROL` in the student's main shell
are unmodified, and that their `~/.bash_history` contains no 2186 timestamps from exercise 20.
