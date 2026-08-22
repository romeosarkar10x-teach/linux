# 01/01 — Validator rubric

Governed by [`docs/VALIDATION_PROTOCOL.md`](../../docs/VALIDATION_PROTOCOL.md).

Evidence: `~/01-01-answers.md`, the container's `history`, and live re-runs of read-only commands.

Lab: `/labs/01-shell-and-terminal/01-terminal-vs-shell-vs-tty/`

**Note on evidence.** Most of this lesson's outputs are session-specific — the PIDs and tty in the
answers file will not match the validator's own session, and must not be expected to. Check
*internal consistency* instead: the tty in exercise 1 should match the TTY column in exercise 3,
and the PIDs in exercise 6 should relate as described.

---

### Exercise 1 — tty, PID, program
| Field | |
|---|---|
| **Goal** | Can locate themselves: which terminal, which process, which program. |
| **Expected end state** | Three recorded outputs: a `/dev/pts/N` path, a number, a `ps` line naming `bash`. |
| **Evidence commands** | `history \| grep -E 'tty\|ps -p\|echo \$\$'` |
| **Accept** | `tty`; `echo $$`; `ps -p $$`. Also `ps -p "$(echo $$)"`, `ps $$`. |
| **Reject** | `echo $SHELL` offered as the answer to "what program". |
| **Red flags** | A PID that does not appear anywhere in their history's `ps` output; a `/dev/tty1` path in a container. |
| **Probe question** | "If you had only the PID and not the shell, how would you find out what it was?" |

### Exercise 2 — whoami vs id
| Field | |
|---|---|
| **Goal** | Knows identity is numeric with names layered on, and that group membership is part of it. |
| **Expected end state** | Both outputs plus one sentence naming a fact unique to `id`. |
| **Evidence commands** | `whoami; id` |
| **Accept** | Sentence naming uid/gid numbers, or supplementary groups. |
| **Reject** | "id gives more detail" with no specific fact. |
| **Red flags** | — |
| **Probe question** | "Which of those two would you need to explain a permission denied?" |

### Exercise 3 — processes on your tty
| Field | |
|---|---|
| **Goal** | Default `ps` behaviour, and that the listing includes itself. |
| **Expected end state** | A listing with at least `bash` and `ps`. |
| **Evidence commands** | `ps` |
| **Accept** | Bare `ps`. `ps -f` fine. |
| **Reject** | `ps aux` presented as "the processes on my tty" — it is not. |
| **Red flags** | — |
| **Probe question** | "Why is `ps` itself in that list?" |

### Exercise 4 — not a tty
| Field | |
|---|---|
| **Goal** | Understands that a program's connection to a terminal is a property of its environment. |
| **Expected end state** | Both outputs plus a sentence about output being redirected into a pipe. |
| **Evidence commands** | `history \| grep tty` |
| **Accept** | Any pipe into `tty`; also `tty < /dev/null`, `tty \| cat` reasoning if explained. |
| **Reject** | Editing the answers file by hand with an invented `not a tty` line and no matching history. |
| **Red flags** | No pipe anywhere in history. |
| **Probe question** | "Did `tty` behave differently, or did its surroundings?" |

### Exercise 5 — ls through a pipe
| Field | |
|---|---|
| **Goal** | The surprise: a tool changes its output format based on where the output goes. |
| **Expected end state** | Columnised output in one case, one-per-line in the other, plus the reason. |
| **Evidence commands** | `ls consoles`; `ls consoles \| cat` |
| **Accept** | Reason mentioning machine-readability, or that the program detects a terminal. |
| **Reject** | Claiming `ls` output is always identical. |
| **Red flags** | Reported outputs identical — they likely piped into something that re-columnises, or ran both bare. |
| **Probe question** | "If you wrote a program that read `ls` output, which form would you want?" |

### Exercise 6 — child shell
| Field | |
|---|---|
| **Goal** | Shells nest as separate processes; exiting returns to the parent unchanged. |
| **Expected end state** | Four PID readings; first and last equal; middle two differ from them. |
| **Evidence commands** | Cross-check the recorded PIDs against `history`. |
| **Accept** | `bash` as the child. `sh`, `dash` equally fine. |
| **Reject** | Opening a second terminal window and calling it a child shell — it is a sibling, not a child. |
| **Red flags** | Outer PIDs unequal. |
| **Probe question** | "Was the second shell inside the first, or beside it? How can you tell?" |

### Exercise 7 — three deep
| Field | |
|---|---|
| **Goal** | Can read nesting depth off the process table rather than guessing. |
| **Expected end state** | A `ps` listing with four shell entries (original + 3), and a count of 3 exits. |
| **Evidence commands** | Re-run: nest three, `ps`. |
| **Accept** | Count of 3, or 4 if they include exiting the login shell — accept with the reasoning stated. |
| **Reject** | Ctrl-D or window-close substituted without noticing the difference. |
| **Red flags** | Listing shows one shell. |
| **Probe question** | "What would the listing look like if you had gone two deep instead?" |

### Exercise 8 — SHELL vs ps
| Field | |
|---|---|
| **Goal** | Distinguishes a recorded preference from a live measurement. |
| **Expected end state** | Two readings that disagree, and a stated preference for the measurement. |
| **Evidence commands** | `echo $SHELL`; `ps -p $$` |
| **Accept** | Any second shell (`dash`, `sh`, `zsh` if installed). |
| **Reject** | Reassigning `SHELL` by hand to force disagreement — that proves the variable is writable, not the point. |
| **Red flags** | No shell change in history. |
| **Probe question** | "Which of the two would still be right if someone had changed your login shell an hour ago and you had not logged out?" |

### Exercise 9 — the device file
| Field | |
|---|---|
| **Goal** | The tty is a file in the filesystem, and it is not a regular file. |
| **Expected end state** | A long listing of their own `/dev/pts/N`, type identified as a character device. |
| **Evidence commands** | `ls -l "$(tty)"` |
| **Accept** | "character device", "character special", or "c means a device you read as a stream of characters". |
| **Reject** | "It is a normal file." |
| **Red flags** | Listed `/dev` wholesale and picked a random entry. |
| **Probe question** | "What else in `/dev` has that same first character?" |

### Exercise 10 — two sessions (Experiment)
| Field | |
|---|---|
| **Goal** | Predict-then-observe discipline; sessions are independent. |
| **Expected end state** | A written prediction *preceding* the observation, both ttys and both PIDs, and an explanation. |
| **Evidence commands** | Read the answers file; check the prediction is present and distinct from the observation. |
| **Accept** | A wrong prediction with a correct explanation. That is a full pass. |
| **Reject** | Observation only, no prediction. This is the one thing that fails this exercise. |
| **Red flags** | Prediction and observation identical in wording — written after the fact. |
| **Probe question** | "What did you expect, and what specifically changed your mind?" |

### Exercise 11 — exit and the child (Experiment)
| Field | |
|---|---|
| **Goal** | A finished process leaves the table; PID reuse is not immediate or predictable. |
| **Expected end state** | Prediction, observation, and a sentence saying the child is gone from the listing. |
| **Evidence commands** | Read the answers file. |
| **Accept** | "It disappeared." Bonus if they note PIDs are eventually reused. |
| **Reject** | Claiming the PID was immediately reassigned, without evidence. |
| **Red flags** | Missing prediction. |
| **Probe question** | "How long is a PID guaranteed to stay unique?" |

### Exercise 12 — identify this session (Stretch)
| Field | |
|---|---|
| **Goal** | Composes several small facts into one useful diagnostic line. |
| **Expected end state** | One line carrying user, host, shell, tty, PID, with the command for each. |
| **Evidence commands** | `cat ~/01-01-answers.md` |
| **Accept** | Hand-assembled. Pipelines and command substitution are not required and not penalised. |
| **Reject** | Fewer than five facts. |
| **Red flags** | — |
| **Probe question** | "Which of those five would change if you opened a new window right now?" |

### Exercise 13 — tty3 vs pts (Stretch)
| Field | |
|---|---|
| **Goal** | Hardware console versus pseudo-terminal. |
| **Expected end state** | Two sentences with the distinction correct. |
| **Evidence commands** | `cat ~/01-01-answers.md` |
| **Accept** | Anything capturing "one is a physical console, one is created by software for a session". |
| **Reject** | "They are the same thing with different numbers." |
| **Red flags** | — |
| **Probe question** | "Where does a `/dev/pts` entry go when you close the window?" |

### Exercise 14 — parent PID (Dig)
| Field | |
|---|---|
| **Goal** | Can get an undocumented-in-notes column out of `ps` by reading its man page. |
| **Expected end state** | Output showing both PID and PPID, plus the parent named. |
| **Evidence commands** | `history \| grep ps`; check for a man page read. |
| **Accept** | `ps -o pid,ppid,comm -p $$`, `ps -f -p $$`, `ps -lp $$`. Any route that shows the parent. |
| **Reject** | Reading `/proc/$$/status` **only** — correct, but it dodges the skill being taught. Accept it as an *additional* answer. |
| **Red flags** | The exact option appearing with no man page access and no failed attempts. |
| **Probe question** | "Where in the man page did you find the field name?" |

### Exercise 15 — who and w (Dig)
| Field | |
|---|---|
| **Goal** | Two similar tools, one meaningful difference; reads man pages to separate them. |
| **Expected end state** | Both outputs, two sentences. |
| **Evidence commands** | `who; w` |
| **Accept** | Identifying that `w` shows current activity per session and `who` does not. |
| **Reject** | "They are the same." |
| **Red flags** | — |
| **Probe question** | "Which would you run first on a machine you suspect someone else is using?" |

---

## Lesson roll-up

**Load-bearing (must PASS):** 1, 4, 6, 8, 10.
Exercise 8 is the one that matters most — a student who still believes `$SHELL` reports the running
shell will misdiagnose things for the rest of the course.

**Nice to have:** 2, 3, 5, 7, 9, 11, 12, 13.

**Dig (not required to pass the lesson, but note attempts):** 14, 15.

A student who passes 1, 4, 6 and 8 but produced no written prediction for 10 gets
**PASS-WITH-NOTES**, and the note is about method, not knowledge.
