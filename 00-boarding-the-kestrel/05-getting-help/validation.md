# 00/05 — Validator rubric

Governed by [`docs/VALIDATION_PROTOCOL.md`](../../docs/VALIDATION_PROTOCOL.md).

Evidence: container `history` (heavily — this lesson is *about* using the machine's docs),
`~/00-05-answers.md`, and the exercise 6 transcript.

---

### Exercise 1 — `ls -S`
| Field | |
|---|---|
| **Goal** | Can find a flag's meaning in a man page and verify it empirically. |
| **Expected end state** | Correct meaning, sourced, plus a demonstrating output. |
| **Evidence commands** | `history \| grep -E 'man ls\|ls --help\|ls -S'` |
| **Accept** | `man ls` or `ls --help`. Both are the machine. |
| **Reject** | Correct answer with neither in history. |
| **Red flags** | No verification run. |
| **Probe question** | "What does `-S` combine with to reverse the order?" |

### Exercise 2 — `cd` has no man page
| Field | |
|---|---|
| **Goal** | Knows builtins exist and are documented elsewhere. Sets up 01/03. |
| **Expected end state** | `help cd` (or `man bash`) identified; explanation references builtins. |
| **Evidence commands** | `history \| grep -E 'man cd\|help cd\|type cd'` |
| **Accept** | `help cd`, or finding it inside `man bash`. |
| **Reject** | "cd is undocumented." |
| **Red flags** | Never ran `man cd` to see it fail. |
| **Probe question** | "Why can't `cd` be an external program?" (A child process can't change the parent's directory — 01/03.) |

### Exercise 3 — write a help request
| Field | |
|---|---|
| **Goal** | Can ask for help in a form that's actually answerable. |
| **Expected end state** | Three sections with real pasted command and output. |
| **Evidence commands** | `cat ~/00-05-answers.md`; cross-check the command appears in history |
| **Accept** | Any genuine failing command. |
| **Reject** | Invented output, or a description where the paste should be. Check history for the command. |
| **Red flags** | Output that doesn't match what that command actually prints on this system. |
| **Probe question** | "Which of the three parts tells a tutor the most, and why?" |

### Exercise 4 — search by description
| Field | |
|---|---|
| **Goal** | Can find a command by concept rather than name. |
| **Expected end state** | `apropos`/`man -k` used; `chown` (and likely `chgrp`) found. |
| **Evidence commands** | `history \| grep -E 'apropos\|man -k'` |
| **Accept** | Either tool, any reasonable keyword. |
| **Reject** | Named `chown` from memory with no search in history — the search is the exercise. |
| **Red flags** | — |
| **Probe question** | "What builds the database `apropos` searches, and what if it's empty?" |

### Exercise 5 — read the protocol
| Field | |
|---|---|
| **Goal** | Knows the rules well enough to work with them rather than against them. |
| **Expected end state** | A named rung and an honest cost. |
| **Evidence commands** | `cat ~/00-05-answers.md` |
| **Accept** | Any honest answer. "Rung 2, because reading man pages is slow" is a good one. |
| **Reject** | Answers showing they didn't open the document. |
| **Red flags** | — |
| **Probe question** | "What happens after rung 5?" (Parallel problem — not the answer.) |

### Exercise 6 — tutor session *(Experiment)*
| Field | |
|---|---|
| **Goal** | Knows from experience what the tutor will and won't do, before they need it. |
| **Expected end state** | Prediction, transcript/summary, jailbreak outcome, reconciliation. |
| **Evidence commands** | `cat ~/00-05-answers.md` and the transcript |
| **Accept** | Any honest session. A successful jailbreak reported honestly is a full PASS **and a course bug** — record it. |
| **Reject** | No transcript, or a session where they didn't actually play stuck. |
| **Red flags** | A transcript reading as if the student already knew the answer. |
| **Probe question** | "What did it ask for before it helped, and why those three things?" |

### Exercise 7 — man 5 *(Stretch)*
| Field | |
|---|---|
| **Goal** | Uses section numbers deliberately; connects 00/01 to a real file. |
| **Expected end state** | `man 5 passwd` run; the second field explained. |
| **Evidence commands** | `history \| grep 'man 5'` |
| **Accept** | Correct field meaning, i.e. the encrypted-password placeholder field, now conventionally `x` with the real hash in `/etc/shadow`. |
| **Reject** | Read the section-1 page instead. |
| **Red flags** | Answer without `man 5` in history. |
| **Probe question** | "Why is the real password not in that file, given the file is world-readable?" |

### Exercise 8 — full-text search *(Dig)*
| Field | |
|---|---|
| **Goal** | Knows man has a full-text search and how it differs from `apropos`. |
| **Expected end state** | `man -K` identified; difference explained; run on "sticky bit". |
| **Evidence commands** | `history \| grep -E 'man -K\|man man'` |
| **Accept** | `-K` with a correct description-index vs full-text explanation. |
| **Reject** | Confusing `-K` with `-k`. |
| **Red flags** | No `man man` in history. |
| **Probe question** | "Why is `-K` so much slower?" |

### Exercise 9 — all sections *(Dig)*
| Field | |
|---|---|
| **Goal** | Can control which man page they get. |
| **Expected end state** | `man -a passwd` showing more than one section. |
| **Evidence commands** | `history \| grep 'man -a'` |
| **Accept** | `-a`. Finding `-f`/`whatis` as well is a bonus, not a substitute — it lists rather than displays. |
| **Reject** | `-f` alone. |
| **Red flags** | — |
| **Probe question** | "How many `passwd` pages does this system have, and what is each about?" |

---

## Lesson roll-up

**Load-bearing:** 1, 4, 8. These three are the actual skill — finding things in the machine's own
documentation — and every Dig exercise for the next fifteen chapters assumes it.

**Nice-to-have:** 2, 3, 5, 6, 7, 9.

Weight history heavily here. A student who answers all nine correctly with no `man` invocations has
demonstrated the exact opposite of what the lesson teaches.
