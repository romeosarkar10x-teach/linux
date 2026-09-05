# 01/07 — Validator rubric

Governed by [`docs/VALIDATION_PROTOCOL.md`](../../docs/VALIDATION_PROTOCOL.md).

Evidence: `~/01-07-answers.md`, `~/01-07-debrief.md`, `history`, and the lab's state.

Lab: `/labs/01-shell-and-terminal/07-incident-01/`

## Integrity check — do this first

```bash
ls -l /labs/01-shell-and-terminal/07-incident-01/dorn-bash-history
md5sum /labs/01-shell-and-terminal/07-incident-01/dorn-bash-history
```

The file must be **mode 444**, owned by `cadet`, **13 lines**, ending with
`./check-sample-integrity.sh strain-2187-0` and no trailing newline issues introduced.

If it was modified, the incident's one stated rule was broken. That is a **PASS-WITH-NOTES ceiling**
for the lesson even if everything else is perfect, and the note should say why: evidence handling is
the skill, and this is the first time the course has asked for it. Have them `kestrel reset 01/07`
and confirm the reconstruction still holds.

Modifying it is not, by itself, a failure. Not noticing that it mattered is.

---

### Exercise 1 — count the commands
| Field | |
|---|---|
| **Goal** | Reads a timestamped history file correctly. |
| **Expected end state** | **11 commands**, 22 lines. |
| **Evidence commands** | `cat dorn-bash-history` |
| **Accept** | 11, with the `#` lines identified as timestamps. |
| **Reject** | 22. |
| **Red flags** | — |
| **Probe question** | "How would you count them if the file were ten thousand lines?" (Chapter 6. A shrug is fine.) |

### Exercise 2 — the working directory
| Field | |
|---|---|
| **Goal** | State accumulates through a history in order. |
| **Expected end state** | `~/samples`, established by the `cd ~/samples` line — the **second** directory change, not the first. |
| **Evidence commands** | `cat dorn-bash-history` |
| **Accept** | `~/samples` or `/home/dorn/samples`. |
| **Reject** | `/var/log/station` — that is the first `cd`, later superseded. |
| **Red flags** | — |
| **Probe question** | "Two `cd`s. Why does the second one win?" |

### Exercise 3 — the two non-leads
| Field | |
|---|---|
| **Goal** | Elimination before reconstruction. The core investigative habit. |
| **Expected end state** | Both identified: (a) the long `find ... -mtime +30 -size +1M` — routine housekeeping, looking for old large logs; (b) the `statoin`/`station` pair — a typo, corrected on the very next line. |
| **Evidence commands** | Read the answers file; check its timestamp against the flag capture if possible. |
| **Accept** | Both, with correct characterisation. Accept "a search for old log files" without the student understanding `find`'s flags — that is Chapter 6 and is not required here. |
| **Reject** | Only one. Or an answer that treats the `find` as significant because it is long and unfamiliar. |
| **Red flags** | The answer written after the flag was captured — the exercise says to do it first. If the file's ordering suggests that, ask. |
| **Probe question** | "What made the `find` line look interesting, and what actually makes a line interesting?" |

### Exercise 4 — locate the cut
| Field | |
|---|---|
| **Goal** | Precision about the evidence. |
| **Expected end state** | Fragment quoted exactly: `./check-sample-integrity.sh strain-2187-0`. Cut located inside the filename argument, after the `0` of the month field. |
| **Evidence commands** | `tail -1 dorn-bash-history` |
| **Accept** | Any precise statement of where it stops. |
| **Reject** | Approximation — "it stops near the end". |
| **Red flags** | A quoted fragment that does not match the file. |
| **Probe question** | "Are the characters that *are* there wrong, or just incomplete?" |

### Exercise 5 — reconstruct
| Field | |
|---|---|
| **Goal** | Evidence-based reconstruction, not guessing. This is the exercise. |
| **Expected end state** | `./check-sample-integrity.sh strain-2187-05.dat`, justified from: the three candidate files in the directory (`ls`), **and** the two earlier history lines that name `strain-2187-05.dat` specifically (`head -3` and `wc -l`). |
| **Evidence commands** | `ls`; `cat dorn-bash-history`; read the answers file. |
| **Accept** | The reconstruction **with** the earlier-history justification. |
| **Reject** | The right answer justified only as "I tried all three and one worked". That is exercise 7's territory, not exercise 5's — mark exercise 5 as not met and say so. It is a real distinction: one is investigation, the other is brute force, and the flag does not tell them apart. |
| **Red flags** | No `cat` of the history file before the successful run, in `history`. Suggests they went straight to the script. |
| **Probe question** | "Three files matched that prefix. What in the history singled one out?" |

### Exercise 6 — the flag
| Field | |
|---|---|
| **Goal** | The chapter's flag. |
| **Expected end state** | `KESTREL{he_never_finished_typing}` submitted and accepted; `01/07` recorded as captured. |
| **Evidence commands** | `kestrel flags` (from the VM); `history \| grep check-sample` |
| **Accept** | — |
| **Reject** | A token obtained from a source other than running the script. |
| **Red flags** | The flag submitted with no `./check-sample-integrity.sh` anywhere in the container's history. |
| **Probe question** | "Where did the words in that token come from? They are not in the script." |

### Exercise 7 — the other sample sets
| Field | |
|---|---|
| **Goal** | Understands why the wrong answers fail loudly, and what that buys. |
| **Expected end state** | `strain-2187-04.dat` → declared 8, present 4, `INTEGRITY: FAIL`, exit 1. `strain-2187-03.dat` → declared 6, present 3, same. Neither prints a token. |
| **Evidence commands** | Re-run both. |
| **Accept** | Conclusion that only one reconstruction produces a token, so the answer is verifiable rather than merely plausible. |
| **Reject** | Claiming the others produced different tokens. They do not — there are no decoy flags in this course. |
| **Red flags** | — |
| **Probe question** | "If all three had printed a token, how would you have known which to submit?" |

### Exercise 8 — the `history -c` (Experiment)
| Field | |
|---|---|
| **Goal** | Applies 01/06's memory-versus-disk model to real evidence. |
| **Expected end state** | Prediction written. Two commands do appear after it. Explanation: the clear emptied the in-memory list; the two commands typed afterwards entered the now-empty list and were written at exit. |
| **Evidence commands** | `cat dorn-bash-history` |
| **Accept** | Any account consistent with 01/06's mechanism. Also fully acceptable: noting the earlier lines survived because they had already been written by a previous session. |
| **Reject** | No prediction. |
| **Red flags** | — |
| **Probe question** | "Does the presence of a `history -c` tell you anything about intent?" **The correct answer is no** — people clear history routinely. A student who says so is reasoning well. Do not lead them toward a sinister reading, and do not reward one. |

### Exercise 9 — load it into a shell (Experiment)
| Field | |
|---|---|
| **Goal** | 01/06 exercise 20's skill on the evidence, safely. |
| **Expected end state** | Predictions written. In a child shell, `history -r dorn-bash-history` then `history` shows the commands dated 2187-05-24, including the truncated line as an ordinary, recallable entry. |
| **Evidence commands** | Reproduce in a child shell. |
| **Accept** | Reason for the child shell: otherwise those lines join the student's own history file permanently. |
| **Reject** | No prediction. |
| **Red flags** | **Check `~/.bash_history` for 2187 timestamps.** If present, they did it in the main shell. Note it; it also contaminates the history evidence for every other exercise, so weight that accordingly. |
| **Probe question** | "A month from now, could you tell those lines apart from your own?" |

### Exercise 10 — the timestamp (Stretch)
| Field | |
|---|---|
| **Goal** | Epoch conversion on the evidence. |
| **Expected end state** | `6860261520` → **2187-05-24 04:12:00** (UTC). Previous command `6860261100` → 04:05:00, so **7 minutes** earlier. |
| **Evidence commands** | `date -d @6860261520 '+%F %T'` |
| **Accept** | Correct date; interval of 7 minutes. |
| **Reject** | Converting the wrong line. |
| **Red flags** | — |
| **Probe question** | "What was the command seven minutes earlier?" |

### Exercise 11 — why `./` (Stretch)
| Field | |
|---|---|
| **Goal** | 01/03's PATH lesson, recalled unprompted. |
| **Expected end state** | Two sentences: the current directory is not on `PATH`; without the prefix the shell searches `PATH`, does not find it, and reports `command not found`. |
| **Evidence commands** | `check-sample-integrity.sh` without the prefix — should fail. |
| **Accept** | — |
| **Reject** | "`./` means execute." |
| **Red flags** | — |
| **Probe question** | "Why is the current directory deliberately left off `PATH`?" |

### Exercise 12 — the mechanism (Stretch)
| Field | |
|---|---|
| **Goal** | A mechanical account, not a narrative one. |
| **Expected end state** | Three or four sentences: the list was in memory; the shell writes it to the file as it exits; the write proceeds through the list; the process ended partway through, so the flushed part is on disk and the remainder never arrived. |
| **Evidence commands** | Read the answers file. |
| **Accept** | Any mechanically coherent account. **Explicitly accept, and prefer,** a student who notes that the evidence does not distinguish an interrupted write from a deliberate truncation, and declines to choose. That is better reasoning than picking one. |
| **Reject** | "The session ended" with no mechanism. |
| **Red flags** | An account that asserts intent as established fact — in either direction. |
| **Probe question** | "What evidence would let you tell an interrupted write from a deliberate one?" |

### Exercise 13 — strip the timestamps (Dig)
| Field | |
|---|---|
| **Goal** | Feels the absence of a filtering tool. Sets up Chapter 6. |
| **Expected end state** | A file in `~` with 11 lines and no `#` lines. |
| **Evidence commands** | `wc -l ~/*history*`; read it. |
| **Accept** | Any method: retyping, an editor, copy-and-delete, redirection line by line. Also accept `grep -v '^#'` if they found it — but then require the wish-list answer, since the point was to articulate the need. |
| **Reject** | Modifying the original. |
| **Red flags** | The original's line count changed. |
| **Probe question** | "How long would your method take on a ten-thousand-line file?" |

### Exercise 14 — read-only (Dig)
| Field | |
|---|---|
| **Goal** | Permissions are advisory against the owner; real immutability is elsewhere. |
| **Expected end state** | Error quoted, e.g. `bash: dorn-bash-history: Permission denied`. Two sentences: the file is owned by `root` and mode 444 gives nobody write permission, so two things refuse them at once; root can write regardless, and an owner can always `chmod` first — a read-only bit is a guard against accident, not against intent. |
| **Evidence commands** | `ls -l dorn-bash-history`; check the file is still 444 and unmodified. |
| **Accept** | Mentioning root, or the owner's ability to `chmod`. Bonus for contrasting with `/course`, which is read-only at the mount. |
| **Reject** | "Nobody can modify it." |
| **Red flags** | **The file's mode is no longer 444, or its contents changed.** They demonstrated it by doing it. See the integrity check at the top. |
| **Probe question** | "Who owns that file, and what can an owner always do?" A student who says `cadet` has not looked. |

### The debrief — required
| Field | |
|---|---|
| **Goal** | Can explain the repair, not just perform it. |
| **Expected end state** | `~/01-07-debrief.md`, three sentences answering the three questions. |
| **Evidence commands** | `cat ~/01-07-debrief.md` |
| **Accept** | (1) Verifying a sample set's declared record count against its actual records. (2) The fragment was a true prefix, the directory held three candidates, and earlier history lines named one of them. (3) The file is written at exit, so an interrupted exit leaves the last line unfinished. |
| **Reject** | Missing debrief, or a debrief that restates the flag. |
| **Red flags** | Debrief that describes brute force while exercise 5 claims investigation. |
| **Probe question** | Ask them to answer question 3 without using the word "history". |

---

## Lesson roll-up

**Load-bearing (must PASS):** 3, 4, 5, 6, and the debrief.

Exercise 5 is the lesson. The flag is checkable and therefore easy to over-weight: a student can
capture it by running the script three times and reading the one that worked. Grade 5 on the
**justification**, not the answer, and use the probe. Exercise 3 is the tell — a student who
eliminated first almost certainly reconstructed rather than guessed.

**Nice to have:** 1, 2, 7, 8, 9, 10, 11, 12.

**Dig (attempts noted, not required):** 13, 14.

**Chapter roll-up.** This is Chapter 1's finale. Before signing the chapter off, confirm the student
can, unprompted: name their running shell without `$SHELL` (01/01, 01/02), classify a word (01/03),
tell unset from empty (01/04), reuse the previous line's last argument without arrow keys (01/05),
and explain a truncated history file (01/06). If any of those is shaky, the flag does not cover it.

**Do not discuss the arc.** This lab is trace 1 of sixteen. If the student has noticed something odd
and asks, confirm only what the artefacts support and let them keep it. Telling them there is an arc
removes the reward for having spotted it.
