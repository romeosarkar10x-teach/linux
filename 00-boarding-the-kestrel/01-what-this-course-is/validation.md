# 00/01 — Validator rubric

Governed by [`docs/VALIDATION_PROTOCOL.md`](../../docs/VALIDATION_PROTOCOL.md).

Evidence for this lesson is the student's `00-01-answers.md` plus conversation. There is no lab
directory and no history to inspect except for exercise 6.

---

### Exercise 1 — the six tiers
| Field | |
|---|---|
| **Goal** | Knows the course's own structure well enough not to skip a tier. |
| **Expected end state** | Six tiers named in order in `00-01-answers.md`, one sentence each. |
| **Evidence commands** | `cat 00-01-answers.md` |
| **Accept** | Correct names, roughly correct order, purposes right in substance. Self-corrections marked rather than erased are a positive. |
| **Reject** | A copy of the table from the notes. Ask them to close the file and say it aloud. |
| **Red flags** | Wording identical to the notes; no marked mistakes anywhere in the file. |
| **Probe question** | "Which tier would you be most tempted to skip, and what would that cost you?" |

### Exercise 2 — the six files
| Field | |
|---|---|
| **Goal** | Knows where to look, and knows `solutions.md` is off limits. |
| **Expected end state** | Six filenames; `readme.md` and `exercises.md` marked as theirs. |
| **Evidence commands** | `cat 00-01-answers.md` |
| **Accept** | All six named; correct two marked. |
| **Reject** | Marking `help.md` as student-facing — a real misunderstanding, correct it now. |
| **Red flags** | — |
| **Probe question** | "What actually stops you opening `solutions.md`?" (Correct answer: nothing. That's the point.) |

### Exercise 3 — argue both sides
| Field | |
|---|---|
| **Goal** | Has bought into the no-answers policy for real reasons, not compliance. |
| **Expected end state** | Two paragraphs; the counter-argument is genuinely strong. |
| **Evidence commands** | `cat 00-01-answers.md` |
| **Accept** | Any coherent take on retrieval effort vs. unproductive struggle. Disagreeing with the policy while understanding it is a full PASS. |
| **Reject** | A strawman counter-argument ("some people are just lazy"). Send it back. |
| **Red flags** | Generic LLM-flavoured prose; ask them to defend a specific sentence. |
| **Probe question** | "When should the tutor break the rule?" (Best answer: never — it offers a parallel problem instead.) |

### Exercise 4 — syllabus skim
| Field | |
|---|---|
| **Goal** | Has read the syllabus and has a calibrated self-estimate on record. |
| **Expected end state** | Two lists of three with chapter/lesson numbers. |
| **Evidence commands** | `cat 00-01-answers.md` |
| **Accept** | Any six honest picks with valid references. |
| **Reject** | Topics not in the syllabus — they didn't open it. |
| **Red flags** | — |
| **Probe question** | "Pick one from your 'know it cold' list. What are two flags for it you've never used?" |

### Exercise 5 — history vs end state *(Experiment)*
| Field | |
|---|---|
| **Goal** | Understands what evidence they're generating, and how to make it truthful. |
| **Expected end state** | A prediction, the actual list, and an honest reconciliation. |
| **Evidence commands** | `cat 00-01-answers.md` |
| **Accept** | Prediction covering roughly: order of operations, timing/pacing, failed attempts, which tool was used. Getting it *wrong* and explaining why is a full PASS. |
| **Reject** | Prediction and "actual" identical with no reconciliation — written after reading. |
| **Red flags** | A suspiciously complete prediction and nothing learned. |
| **Probe question** | "Your history shows no failures on a hard lesson. What would I conclude, and would I be right?" |

### Exercise 6 — man sections *(Dig)*
| Field | |
|---|---|
| **Goal** | Can navigate a man page and knows man is sectioned. |
| **Expected end state** | Section list, the file-formats section number, and the explicit-section syntax. |
| **Evidence commands** | `history \| grep -w man`; `cat 00-01-answers.md` |
| **Accept** | The answer plus a statement of where in `man man` it was found. |
| **Reject** | A correct answer with no `man` invocation in history — the exercise is the reading, not the fact. |
| **Red flags** | No `man` in history; phrasing lifted from a search engine. |
| **Probe question** | "Give me a command name that exists in two different sections, and say what each one is." |

---

## Lesson roll-up

**Load-bearing:** 1, 2, 5, 6. A student who can't navigate `man` (6) or won't write real
predictions (5) will fail progressively harder for the next fifteen chapters — catch it here.

**Nice-to-have:** 3, 4.

Nothing in this lesson is technically difficult, so the only real signal is honesty. Weight the
probe questions accordingly.
