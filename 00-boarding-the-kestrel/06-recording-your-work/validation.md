# 00/06 — Validator rubric

Governed by [`docs/VALIDATION_PROTOCOL.md`](../../docs/VALIDATION_PROTOCOL.md).

Evidence: `~/transcripts/` in the container, `~/.bash_history`, the copied-out directory on the VM,
the OBS clip, and `~/00-06-answers.md`.

This lesson validates the student's ability to be validated. A REDO here is blocking.

---

### Exercise 1 — timestamps
| Field | |
|---|---|
| **Goal** | History is a timeline, not just a list. |
| **Expected end state** | `history` output shows dates and times; `HISTTIMEFORMAT` named. |
| **Evidence commands** | `echo "$HISTTIMEFORMAT"`; `history \| tail -5`; `grep HISTTIMEFORMAT ~/.bashrc` |
| **Accept** | Any format string producing a readable timestamp. |
| **Reject** | No timestamps — fix before proceeding; the rest of the course depends on it. |
| **Red flags** | — |
| **Probe question** | "Are the timestamps stored in the file, or added at display time?" (Stored, as `#epoch` lines.) |

### Exercise 2 — first transcript
| Field | |
|---|---|
| **Goal** | Can produce a transcript containing output, not just commands. |
| **Expected end state** | `~/transcripts/00-06-practice.log` with three commands including a failure. |
| **Evidence commands** | `ls -la ~/transcripts/`; `cat -v ~/transcripts/00-06-practice.log \| head -40` |
| **Accept** | Any `script` invocation producing a complete log. |
| **Reject** | A hand-written file. Control characters and the `Script started` structure are the tell — a clean file is a forged one. |
| **Red flags** | No escape sequences at all; no `script` in history. |
| **Probe question** | "Why does the file look full of junk when you `cat` it?" |

### Exercise 3 — replay
| Field | |
|---|---|
| **Goal** | Understands what timing data adds. |
| **Expected end state** | A successful replay; a correct statement about pacing. |
| **Evidence commands** | `history \| grep scriptreplay`; `ls -la ~/transcripts/*.timing` |
| **Accept** | Any correct statement that timing reconstructs *when*, revealing pauses and pace. |
| **Reject** | "It makes it prettier." |
| **Red flags** | No `.timing` file. |
| **Probe question** | "Why is a replay harder to fake than a log?" |

### Exercise 4 — per-lesson snapshot
| Field | |
|---|---|
| **Goal** | Habit of flushing and snapshotting history per lesson. |
| **Expected end state** | `~/transcripts/00-06.history` containing this session. |
| **Evidence commands** | `tail -20 ~/transcripts/00-06.history`; `history \| grep 'history -a'` |
| **Accept** | Flush then snapshot, in that order. |
| **Reject** | Snapshot without flush, missing recent commands — send them back to observe why. |
| **Red flags** | — |
| **Probe question** | "You snapshot without flushing first. What's missing, and why?" |

### Exercise 5 — docker cp
| Field | |
|---|---|
| **Goal** | Coursework leaves the container. Prevents real loss. |
| **Expected end state** | `transcripts/` present on the VM and in the container after a stop/start. |
| **Evidence commands** | VM: `ls -la ./transcripts`; container: `ls -la ~/transcripts`; VM `history \| grep 'docker cp'` |
| **Accept** | `docker cp` either direction, or a bind mount. |
| **Reject** | Claiming `/home/cadet` survives container deletion. |
| **Red flags** | No copy in the VM's history. |
| **Probe question** | "When exactly must you have copied out by?" (Before any container recreation.) |

### Exercise 6 — OBS
| Field | |
|---|---|
| **Goal** | A recording that is actually readable. |
| **Expected end state** | A playable clip; smallest terminal text legible **in the file**. |
| **Evidence commands** | Watch the clip. Ask them to read a specific short string from playback. |
| **Accept** | Any readable capture at 720p+. |
| **Reject** | Text you cannot read. This is the most common failure in the course and it invalidates the video evidence — REDO with a larger font. |
| **Red flags** | Clip shows only the desktop with no terminal visible. |
| **Probe question** | "What must be visible in every recording?" (Terminal, commands, output, working directory.) |

### Exercise 7 — what gets recorded *(Experiment)*
| Field | |
|---|---|
| **Goal** | Knows the gaps in their own evidence, and that history is filterable. |
| **Expected end state** | Six predictions, six observations, settings named for the surprises. |
| **Evidence commands** | `echo "$HISTCONTROL"`; `tail -40 ~/.bash_history`; `cat ~/00-06-answers.md` |
| **Accept** | Wrong predictions with good reconciliation are a full PASS. Key findings: leading space suppresses (with `ignorespace`/`ignoreboth`); consecutive duplicates suppressed with `ignoredups`; Ctrl-C'd lines *are* recorded; commands inside a `script` session go to the same history. |
| **Reject** | Predictions written after the fact — check `stat` against history timestamps. |
| **Red flags** | All six right with nothing learned. |
| **Probe question** | "How would someone hide a command from their history, and how would I notice?" (Gaps in the timestamps.) |

### Exercise 8 — timing from history *(Stretch)*
| Field | |
|---|---|
| **Goal** | Can read their own evidence the way a validator will. |
| **Expected end state** | Elapsed total and longest gap, with method stated. |
| **Evidence commands** | `cat ~/00-06-answers.md`; cross-check against `history` |
| **Accept** | By eye, explicitly stated. Any correct method. |
| **Reject** | Figures that don't match the actual history. |
| **Red flags** | A Chapter 7 pipeline appearing here with no exposure to those tools — ask them to explain it line by line. |
| **Probe question** | "You have a 40-minute gap mid-lesson. Two innocent explanations and one suspicious one?" |

### Exercise 9 — script flags *(Dig)*
| Field | |
|---|---|
| **Goal** | Knows transcripts can be lost to buffering, and how to prevent it. |
| **Expected end state** | `-a` and `-f` identified and explained; correct answer on the crash case. |
| **Evidence commands** | `history \| grep 'man script'` |
| **Accept** | `-f`/`--flush` for the crash case, with a buffering explanation. |
| **Reject** | `-a` for the crash case. |
| **Red flags** | No `man script` in history. |
| **Probe question** | "What's the cost of flushing after every write?" |

### Exercise 10 — HISTCONTROL *(Dig)*
| Field | |
|---|---|
| **Goal** | Knows history is filterable, and which filter destroys evidence. |
| **Expected end state** | `HISTCONTROL` named; `ignorespace`, `ignoredups`, `ignoreboth`, `erasedups` listed; `erasedups` identified as evidence-destroying. |
| **Evidence commands** | `history \| grep 'man bash'`; `cat ~/00-06-answers.md` |
| **Accept** | All four values with meanings, plus a defensible pick. `erasedups` is the strongest answer — it removes *prior* matching entries, deleting the record of repeated attempts. |
| **Reject** | Named the variable with no values. |
| **Red flags** | Answer with no `man bash` in history; **`HISTCONTROL=erasedups` now set in their `.bashrc`** — ask why. |
| **Probe question** | "Why would `erasedups` specifically make a lesson look like copy-paste?" |

---

## Lesson roll-up

**Load-bearing:** 1, 2, 4, 6, 7. Without timestamps (1), transcripts (2, 4), a legible video (6), or
an understanding of what history omits (7), nothing after this chapter can be validated properly.

**Nice-to-have:** 3, 5, 8, 9, 10.

Check at every later validation that these habits persisted. The common failure is a student who
records 00/06 diligently and nothing afterwards — call it out the first time a lesson arrives with
no transcript.
