# 01/05 — Validator rubric

Governed by [`docs/VALIDATION_PROTOCOL.md`](../../docs/VALIDATION_PROTOCOL.md).

Lab: `/labs/01-shell-and-terminal/05-readline/`

## Read this before grading

**This lesson cannot be validated from the filesystem or from `history`.** Keystrokes leave no
record. `Ctrl-A` and thirty left-arrows produce byte-identical history entries, and every exercise
here "works" when done the slow way.

Primary evidence is therefore, in order of preference:

1. **A recording** — `script`, asciinema, or video (`docs/RECORDING.md`). A `script` typescript
   preserves the raw byte stream, so control characters *are* visible in it.
2. **A live demonstration** — ask the student to repeat two exercises while you watch.
3. **Written answers naming the specific keys**, cross-examined with the probe questions.

Written answers alone cap this lesson at **PASS-WITH-NOTES**. Say so to the student; it is not a
punishment, it is the honest limit of the evidence.

**Grading stance:** a student who names the right keys, can answer the probes, and demonstrates two
of them live has passed. Do not demand a recording that was never made — ask for the demonstration
instead.

**One thing that is checkable:** `history` shows whether the *outcomes* happened — that both
commands in exercise 5 ran with the same long filename, that the corrected line in exercise 4
exists. Use it to confirm the work was done, then use the probes to test how.

---

### Exercise 1 — jump and abandon
| Field | |
|---|---|
| **Goal** | Single-keystroke line navigation exists and is used. |
| **Expected end state** | Three keys named: start, end, abandon. Nothing executed. |
| **Evidence commands** | `history \| tail -20` — the long `cat` should **not** appear. |
| **Accept** | `Ctrl-A`, `Ctrl-E`, `Ctrl-C`. |
| **Reject** | Home/End keys named as the answer — they often work, but the exercise is about the readline bindings that work everywhere, including over connections where Home/End do not. Accept as a note. |
| **Red flags** | The `cat` command present in history — they ran it. |
| **Probe question** | "Why would `Ctrl-A` be more reliable than Home on a machine you have just connected to?" |

### Exercise 2 — delete word, delete line
| Field | |
|---|---|
| **Goal** | Deletion by unit rather than by character. |
| **Expected end state** | `Ctrl-W` and `Ctrl-U` named. |
| **Evidence commands** | Demonstration. |
| **Accept** | `Ctrl-U` for the line. `Ctrl-A` then `Ctrl-K` is also correct and worth acknowledging. |
| **Reject** | Backspace, explicitly banned by the exercise. |
| **Red flags** | — |
| **Probe question** | "Your cursor is in the middle of the line. What does `Ctrl-U` remove?" |

### Exercise 3 — delete and restore
| Field | |
|---|---|
| **Goal** | Deletions are recoverable; the kill ring exists. |
| **Expected end state** | `Ctrl-W` then `Ctrl-Y`, text restored intact. |
| **Evidence commands** | Demonstration. |
| **Accept** | Any cut key followed by the yank. |
| **Reject** | Retyping the word. |
| **Red flags** | — |
| **Probe question** | "Is that text on your system clipboard? Could you paste it into a browser?" |

### Exercise 4 — 05 to 06
| Field | |
|---|---|
| **Goal** | Minimal, targeted editing. |
| **Expected end state** | The corrected line in history; a key sequence written out. |
| **Evidence commands** | `history \| grep 2187-06` |
| **Accept** | Any route under about five movements. `Alt-B` to the target, `Ctrl-W`, retype. Backspace-and-retype from the end. |
| **Reject** | Retyping the whole line — check the sequence they wrote, not just the result. |
| **Red flags** | A sequence that could not produce the stated result — walk through it with them. |
| **Probe question** | "Which key got you closest to the target fastest?" |

### Exercise 5 — reuse the last argument
| Field | |
|---|---|
| **Goal** | `Alt-.` — the highest-value binding in the lesson. |
| **Expected end state** | Two consecutive history entries with the same long filename, the second not up-arrow-derived. |
| **Evidence commands** | `history \| tail -10` |
| **Accept** | `Alt-.` or `Esc .`. `!$` also produces the same result and is 01/06's material — accept it, note that the exercise wanted the keystroke, and ask for that too. |
| **Reject** | Up-arrow and edit, explicitly banned. Copy-paste with the mouse. |
| **Red flags** | Only one of the two commands present. |
| **Probe question** | "What if you needed the *second*-to-last argument?" |

### Exercise 6 — three deep
| Field | |
|---|---|
| **Goal** | Repeated presses walk back through history. |
| **Expected end state** | Three commands, same filename; sentence describing repeated presses cycling backwards. |
| **Evidence commands** | `history \| tail -10` |
| **Accept** | Sentence noting you keep pressing until the right argument appears. |
| **Reject** | "It only works once." |
| **Red flags** | — |
| **Probe question** | "You pressed it once too many. How do you get back?" |

### Exercise 7 — cut and paste an argument
| Field | |
|---|---|
| **Goal** | Cut-to-end plus yank as a move operation. |
| **Expected end state** | Final line correct; `Ctrl-K` and `Ctrl-Y` named. |
| **Evidence commands** | Demonstration; `history`. |
| **Accept** | `Ctrl-U`/`Ctrl-Y` variant if their cursor placement made it the right cut. |
| **Reject** | Mouse selection. |
| **Red flags** | — |
| **Probe question** | "Where does the text land when you yank — at the cursor, or at the end?" |

### Exercise 8 — front and back
| Field | |
|---|---|
| **Goal** | The keystroke count is the measurement. |
| **Expected end state** | A count in the low single digits. |
| **Evidence commands** | Demonstration. |
| **Accept** | 2–4 keystrokes plus the typed word. |
| **Reject** | A count in the dozens — they used arrows. |
| **Red flags** | An implausibly low count with no demonstration. |
| **Probe question** | "Would that count change if the line were three times longer?" (It should not.) |

### Exercise 9 — Tab ambiguity (Experiment)
| Field | |
|---|---|
| **Goal** | Completion fills the unambiguous prefix and stops. |
| **Expected end state** | Predictions written first. `readings/s` + Tab → completes to `readings/st` (all five share `st`); second Tab lists all five. `readings/str` + Tab → completes to `readings/strain-bay` and stops, three candidates remaining. |
| **Evidence commands** | Reproduce in the lab. |
| **Accept** | Wrong prediction with correct observation and explanation — full pass. The key insight: the first press did *something*, just not a full completion. |
| **Reject** | No prediction. Claiming the first press did literally nothing without checking the line. |
| **Red flags** | Observations that do not match a reproduction — the five seeded filenames are fixed. |
| **Probe question** | "After the first Tab, what exactly was on your line?" |

### Exercise 10 — no matches (Experiment)
| Field | |
|---|---|
| **Goal** | Silence is information; Tab as a cheap existence check. |
| **Expected end state** | Prediction; nothing completes (possibly a bell); the check articulated. |
| **Evidence commands** | Demonstration. |
| **Accept** | Use case: type a short prefix, press Tab, and if nothing fills in, the path is wrong — found out in one second. |
| **Reject** | Calling it broken. |
| **Red flags** | — |
| **Probe question** | "Where would this have saved you time already in this course?" |

### Exercise 11 — Ctrl-D twice (Experiment)
| Field | |
|---|---|
| **Goal** | One rule — end of input — with two visible outcomes. |
| **Expected end state** | Both predictions; with text, one character deleted; on an empty line, the child shell exits. |
| **Evidence commands** | Demonstration in a child shell. |
| **Accept** | Explanation framing both as "end of input", not as two unrelated behaviours. Losing the session by doing it in the main shell is acceptable if noted honestly. |
| **Reject** | No prediction. |
| **Red flags** | Claiming it exited *and* claiming they never left their shell. |
| **Probe question** | "Where else in this course have you pressed `Ctrl-D` to mean the same thing?" |

### Exercise 12 — back in the parent (Stretch)
| Field | |
|---|---|
| **Goal** | Ties the keystroke to the process model. |
| **Expected end state** | PID before equals PID after. |
| **Evidence commands** | `echo $$` before and after. |
| **Accept** | — |
| **Reject** | Asserting without measuring. |
| **Red flags** | — |
| **Probe question** | "Is `Ctrl-D` on an empty line the same as typing `exit`?" |

### Exercise 13 — Ctrl-L versus clear (Stretch)
| Field | |
|---|---|
| **Goal** | Readline action versus external program. |
| **Expected end state** | With a half-typed line: `Ctrl-L` clears and **redraws the partial line**; `clear` cannot even be run without first abandoning or submitting what is typed. |
| **Evidence commands** | Demonstration. |
| **Accept** | Any correct statement of the preserved-line difference. |
| **Reject** | "They are identical." |
| **Red flags** | — |
| **Probe question** | "Could you run `clear` without losing what you had typed?" |

### Exercise 14 — classifying clear (Stretch)
| Field | |
|---|---|
| **Goal** | A key binding never enters command resolution at all. |
| **Expected end state** | `clear is /usr/bin/clear`; reasoning that `Ctrl-L` is consumed by readline before any line is submitted, so it is neither builtin nor file. |
| **Evidence commands** | `type clear` |
| **Accept** | "It is a key binding, not a command." |
| **Reject** | Calling `Ctrl-L` a builtin. |
| **Red flags** | — |
| **Probe question** | "Does the shell ever see the `Ctrl-L` keystroke as a word?" |

### Exercise 15 — timing (Stretch)
| Field | |
|---|---|
| **Goal** | Makes the argument for the lesson quantitative. |
| **Expected end state** | Two durations, a ratio, and an extrapolation. |
| **Evidence commands** | Read the answers file. |
| **Accept** | Any honest numbers. A ratio near 1 is acceptable **if** they explain it — a fast touch-typist on a short path is a real result. |
| **Reject** | Numbers with no method described. |
| **Red flags** | Suspiciously round figures. |
| **Probe question** | "Did you count the time spent fixing typos?" |

### Exercise 16 — the readline config file (Dig)
| Field | |
|---|---|
| **Goal** | Finds the READLINE section of `man bash`. |
| **Expected end state** | `~/.inputrc` (also `INPUTRC`, and `/etc/inputrc` — **which does not exist in this image**, a legitimate finding). Setting: `show-all-if-ambiguous`. |
| **Evidence commands** | `history \| grep man`; `ls /etc/inputrc` → absent. |
| **Accept** | Either filename. Bonus for noticing `/etc/inputrc` is absent here. |
| **Reject** | Naming `.bashrc` — a common confusion, and the distinction matters in Chapter 11. |
| **Red flags** | Setting named with no man-page access. |
| **Probe question** | "Would that setting affect `python3`'s prompt as well? Why?" |

### Exercise 17 — listing bindings (Dig)
| Field | |
|---|---|
| **Goal** | Bindings are inspectable at run time. |
| **Expected end state** | `bind -P` (or `-p`, `-l`); two binding lines quoted, e.g. `beginning-of-line can be found on "\C-a"`. |
| **Evidence commands** | `bind -P \| head` |
| **Accept** | Any of the listing flags. |
| **Reject** | Quoting the notes' table instead of the command's output. |
| **Red flags** | — |
| **Probe question** | "Which is authoritative for this machine — the table in the notes or that output?" |

### Exercise 18 — the other editing mode (Dig)
| Field | |
|---|---|
| **Goal** | The keymap is swappable; the lesson's keys are emacs-mode bindings. |
| **Expected end state** | `set -o vi`, `Ctrl-A` no longer jumps to start, `set -o emacs` restores it. |
| **Evidence commands** | `set -o \| grep -E 'vi\|emacs'` — confirm `emacs on`, `vi off` at the end. |
| **Accept** | Getting stuck and escaping via `Esc` counts as a successful demonstration. |
| **Reject** | Leaving the shell in vi mode. Check this — it will confuse every later lesson. |
| **Red flags** | `set -o` showing `vi on` during grading. |
| **Probe question** | "What is the equivalent of `Ctrl-A` in the other mode?" |

---

## Lesson roll-up

**Load-bearing (must PASS):** 1, 2, 5, 9, 11.
Exercise 5 is the one with the highest daily return. Exercise 9 is the one that stops a student
believing Tab is broken.

**Nice to have:** 3, 4, 6, 7, 8, 10, 12, 13, 14, 15.

**Dig (attempts noted, not required):** 16, 17, 18.

**Before signing off:** confirm the student's shell is not left in vi mode (18) and that they are not
sitting in an orphaned child shell (11). Both are easy to leave behind and both will look like
mysterious breakage in 01/06.
