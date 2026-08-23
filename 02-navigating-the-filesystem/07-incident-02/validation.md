# 02/07 — Validator rubric

**Lab:** `/labs/02-navigating-the-filesystem/07-incident-02`

The lab is read-only evidence. **Any exercise whose transcript shows `mv`, `rm`, `chmod` or a
redirect inside the lab is a REDO regardless of output** — the briefing forbids modification.
`find` or `grep` anywhere in the transcript is also a REDO: the incident is defined by their
absence, and both trivialise it.

Reference values (verified against the image, 2026-08-23):

| Fact | Value |
|---|---|
| `du -sh maintenance` | `40M` |
| `ls maintenance` | no output, exit 0 |
| `ls -a maintenance` | 4 lines; `ls -A maintenance` 2 lines |
| entries of `maintenance` | `.a name you cannot type ` (dot, spaces, **U+00A0** between `cannot` and `type`, trailing space) and `.cache` |
| inodes | the two subdirectories differ (e.g. 44766 vs 44765) — never equal |
| `LC_ALL=C ls -b -A maintenance` | `.a\ name\ you\ cannot\302\240type\ ` and `.cache` |
| `stat -c %N` on it | `'maintenance/.a name you cannot type '` — the U+00A0 prints as a blank |
| files inside | `.keep` (0), `audit-notes.txt` (687), `ballast.bin` (41926656) |
| `file ballast.bin` | `ASCII text, with very long lines (65536), with no line terminators` (40 MiB of `e`) |
| `audit-notes.txt` mtime | `2187-05-15 23:41:00`; `ballast.bin` mtime is the seed time |
| `tree maintenance` | `0 directories, 0 files`; `tree -a maintenance` `3 directories, 3 files` |
| `du -s -B1 maintenance` | `41943040`; `--apparent-size` `41927343`; difference `15697` |
| `du -sh overnight` | `24K`, 5 files |
| `du -sh maintenance/.cache` | `4.0K`, genuinely empty |
| flag | see `solutions.md` |

---

### Exercise 1
| Field | Value |
|---|---|
| **Goal** | Distinguish "printed nothing" from "failed". |
| **Expected end state** | Both numbers recorded: no output at exit 0, and `40M`. |
| **Evidence** | `history` shows `ls maintenance` and `du -sh maintenance`; ideally `echo $?`. |
| **Accept** | Any phrasing that says `ls` succeeded and produced no output. `du -s maintenance` in blocks is fine if converted. |
| **Reject** | "`ls` errored", "the directory does not exist", or a claimed exit status with no command that produced one. |
| **Red flags** | The `40M` figure quoted without `du` ever appearing in history. |
| **Probe** | "What would this have looked like if `ls` had actually failed?" |

### Exercise 2
| Field | Value |
|---|---|
| **Goal** | Attribute a `du` total to a child. |
| **Expected end state** | Output showing 40M against one subdirectory and 4.0K against the other. |
| **Evidence** | `du -h -d 1 maintenance` (or `--max-depth=1`, or `-h -a` filtered by eye). |
| **Accept** | Any depth-limited or per-entry `du` that attributes the bytes. |
| **Reject** | Guessing the culprit from exercise 3's names with no sizing command. |
| **Red flags** | Correct attribution before any listing has revealed the names. |
| **Probe** | "Which line carries the bytes, and how do you know the other one does not?" |

### Exercise 3
| Field | Value |
|---|---|
| **Goal** | `ls` hides dot-prefixed entries; `.` and `..` are entries. |
| **Expected end state** | 4 including `.`/`..`, 2 excluding. |
| **Accept** | `ls -a` + counting, `ls -A`, `ls -a \| wc -l`, `tree -a`. |
| **Reject** | The answer 4 given as "four things in the directory". |
| **Red flags** | Counts that do not match any command in history. |
| **Probe** | "What are `.` and `..`, and does a directory ever lack them?" |

### Exercise 4 — **load-bearing**
| Field | Value |
|---|---|
| **Goal** | Bind the 40M to the hidden name rather than the plausible one. |
| **Expected end state** | The dot-space name identified as the 40M; `.cache` as 4.0K. |
| **Evidence** | `du` output from exercise 2 plus the listing from 3. |
| **Accept** | Any correct attribution backed by a sizing command. |
| **Reject** | "`.cache` is a cache so it is the big one" — plausible, unsupported, and wrong. |
| **Red flags** | Names transcribed by hand with the spaces normalised — a tell they never copied the real name. |
| **Probe** | "If the names had been swapped, would your evidence have changed?" |

### Exercise 5
| Field | Value |
|---|---|
| **Goal** | Not be fooled twice by the same mechanism. |
| **Expected end state** | `.cache` shown empty by a listing that includes hidden entries. |
| **Evidence** | `ls -a maintenance/.cache` (2 lines) or `ls -A` (0 lines); `du -sh` of it. |
| **Accept** | `-a`/`-A` listing, optionally reinforced by `du -sh` = 4.0K or `tree -a`. |
| **Reject** | Plain `ls maintenance/.cache` as the proof — that is the exact error the lesson just corrected. |
| **Red flags** | "Empty" asserted with no command against `.cache` at all. |
| **Probe** | "What did you rule out, and how?" |

### Exercise 6
| Field | Value |
|---|---|
| **Goal** | Dismiss a visible distractor on evidence, not on vibe. |
| **Expected end state** | `overnight` sized (24K, 5 files) and declared irrelevant to a 40M discrepancy. |
| **Accept** | Sizing plus a one-line reason. Reading a log file is fine and not required. |
| **Reject** | Dismissed without sizing; or a theory built on the log text that ignores the size. |
| **Red flags** | Long analysis of the log contents and no `du`. |
| **Probe** | "What would have made this relevant?" |

### Exercise 7 — **load-bearing**
| Field | Value |
|---|---|
| **Goal** | Meet a name that correct quoting does not save you from, and record the failure. |
| **Expected end state** | At least one verbatim failed `cd` with `No such file or directory`, followed by a successful entry. |
| **Evidence** | `history`; the student's log. |
| **Accept** | Any failure recorded verbatim, then entry by completion, glob, or pasted `%N` output. |
| **Reject** | A transcript showing only success — either they tab-completed immediately without trying, in which case ask them to reproduce the failure, or they are reporting someone else's session. |
| **Red flags** | The failure "reconstructed" afterwards with an error string that does not match bash's wording. |
| **Probe** | "Your quoting was right. Why did it still fail?" |

### Exercise 8
| Field | Value |
|---|---|
| **Goal** | Hidden entries again, one level deeper. |
| **Expected end state** | `pwd` inside the directory; all three files named, `.keep` included. |
| **Accept** | `ls -a` or `ls -la`. |
| **Reject** | Two files reported — they used a plain listing and did not notice. |
| **Red flags** | `pwd` output typed rather than run (a hand-typed one usually normalises the spacing). |
| **Probe** | "How many entries, and how do you know there is not a fourth?" |

### Exercise 9 — **load-bearing**
| Field | Value |
|---|---|
| **Goal** | Separate "what `du` counts" from "what `ls` shows". |
| **Expected end state** | `ballast.bin`, `41926656` bytes, `file` says ASCII text. One sentence stating the two facts are independent. |
| **Evidence** | `stat -c %s`, `ls -l`, `file`. |
| **Accept** | Sentences of the form "`du` counts bytes on disk regardless of the name; `ls` omits names beginning with `.`". |
| **Reject** | "`ls` was wrong" or "`du` counted a hidden thing it should not have". Also reject `file` guessing from the `.bin` extension. |
| **Red flags** | Size quoted as `40M` only, with no byte figure — `stat`/`ls -l` never run. |
| **Probe** | "Would `du` have reported differently if the directory had not been hidden?" |

### Exercise 10 — **load-bearing. This is the incident.**
| Field | Value |
|---|---|
| **Goal** | Reveal a non-typeable byte in a filename. |
| **Expected end state** | The escaped form produced, and the U+00A0 identified as a non-ASCII blank, plus the trailing space. |
| **Evidence** | `LC_ALL=C ls -b -A maintenance` (or `-Q`, `-b` with the locale forced, `--quoting-style=escape`, `--quoting-style=c`). |
| **Accept** | Any invocation that prints `\302\240`, with the student stating that it is one character that prints as a blank and is not the space key. Naming it (no-break space, U+00A0) is a bonus, not required. Recognising the trailing space is required. |
| **Reject** | Plain `ls -b` output as the answer — under `C.UTF-8` it escapes nothing and shows the name identically to `ls`. Reject "the name has spaces in it" as complete: that is true of a name they could have typed. |
| **Red flags** | The escape value quoted without the locale-forcing command in history. |
| **Probe** | "How many characters are between `cannot` and `type`, and which of them can you type?" |

### Exercise 11
| Field | Value |
|---|---|
| **Goal** | Quoting protects the shell, not the reader. |
| **Expected end state** | `%N` output shown; the student states it is paste-safe but does not reveal the invisible byte. |
| **Evidence** | `stat -c %N` on the directory. |
| **Accept** | Any statement that `%N` renders the character as a blank because it is printable, so quoting does not disclose it. |
| **Reject** | "`%N` shows the real name" with no comparison to the escape output. |
| **Red flags** | No exercise 10 output to compare against. |
| **Probe** | "Copy that name and type it out yourself. Does it work?" |

### Exercise 12 — Experiment
| Field | Value |
|---|---|
| **Goal** | Understand what the shell resolves versus what the user types. |
| **Expected end state** | A written prediction for all four, then results: (a) fails, (b) succeeds, (c) succeeds, (d) succeeds. |
| **Evidence** | The written prediction; `history`. |
| **Accept** | A wrong prediction with a correct post-hoc explanation. |
| **Reject** | **No prediction — cap at PASS-WITH-NOTES**, per the Experiment rule. Also reject an explanation that says the quotes were wrong in (a); the quotes were fine. |
| **Red flags** | A prediction that reads exactly like the results, written after the fact. |
| **Probe** | "In (c), who produced the name that `cd` received — you or the shell?" |

### Exercise 13 — Experiment
| Field | Value |
|---|---|
| **Goal** | `-a` vs `-A`; `tree` obeys the same rule. |
| **Expected end state** | Prediction, then: `ls -A` 2 lines, `tree` `0 directories, 0 files`, `tree -a` `3 directories, 3 files`. |
| **Accept** | Explanation naming the dot rule, and noting `tree`'s plain count is 0 because it could not descend into either child. |
| **Reject** | No prediction (cap at PASS-WITH-NOTES). An explanation that says `tree` counts differently from `ls`. |
| **Red flags** | Counts not matching any run. |
| **Probe** | "Why did plain `tree` say zero directories when there are two?" |

### Exercise 14 — Stretch
| Field | Value |
|---|---|
| **Goal** | Blocks versus bytes, and what `--apparent-size` leaves out. |
| **Expected end state** | `41943040` and `41927343`, difference `15697`, accounted for. |
| **Evidence** | `du -s -B1` and `du -s -B1 --apparent-size` (or `du -sb`). |
| **Accept** | Accounting that reaches `15697` as: three directories at 4096 each plus `audit-notes.txt` rounded 687 → 4096, i.e. 16384 on disk against 687 apparent; `ballast.bin` is an exact multiple of 4096 and contributes nothing. Answer to the second half: the on-disk figure. |
| **Reject** | "Sparse file" — nothing here is sparse. Hand-waving "block rounding" without arithmetic that closes. |
| **Red flags** | The difference stated but never computed from any output. |
| **Probe** | "Which of the two numbers would still be 40M if the file were sparse?" |

### Exercise 15 — Stretch, **arc-sensitive**
| Field | Value |
|---|---|
| **Goal** | Read evidence without inventing attribution; keep a document separate from a metric. |
| **Expected end state** | Contents summarised; conclusion that the notes (687 bytes) do not explain 40M — `ballast.bin` does. |
| **Accept** | A summary that stays close to the text. Curiosity about who wrote it, stated as an open question. |
| **Reject** | **Any confident attribution to a named crew member.** Nothing in the lab names an author. Reject also "the notes are the 40M". |
| **Red flags** | A name appearing that occurs nowhere in the file. |
| **Probe** | "Which line tells you who wrote this?" (Correct answer: none.) |

### Exercise 16 — Stretch, **arc-sensitive**
| Field | Value |
|---|---|
| **Goal** | Read an mtime and refuse to over-read it. |
| **Expected end state** | `2187-05-15 23:41` reported; the gap to `ballast.bin`'s mtime noted. |
| **Accept** | "The notes were last modified long before the filler file existed" plus an explicit statement that an mtime can be set arbitrarily and does not establish who did anything or in what order events happened. |
| **Reject** | A conclusion that someone deliberately hid the directory on that date, presented as established. |
| **Red flags** | Only the first half written — the "does not let you conclude" half is the graded one. |
| **Probe** | "What is the cheapest way to make a file claim any date you like?" |

### Exercise 17 — Dig
| Field | Value |
|---|---|
| **Goal** | `-1` and `-i`. |
| **Expected end state** | Two distinct inode numbers reported. |
| **Accept** | `ls -1iA maintenance` or equivalent; the conclusion that the two subdirectories are two separate directories, not two names for one. |
| **Reject** | Reading the inode numbers as sizes or as ordering. |
| **Red flags** | Numbers quoted that do not match a live run (they are seed-specific). |
| **Probe** | "What would equal inode numbers have meant?" |

### Exercise 18 — Dig
| Field | Value |
|---|---|
| **Goal** | `du -a` plus a byte block size. |
| **Expected end state** | One command showing `41926656` against `ballast.bin`. |
| **Accept** | `du -ab`, `du -a -B1`, `du -a --apparent-size -B1`, `du --all --bytes`. |
| **Reject** | `stat` or `ls -l` — the exercise names `du`. |
| **Red flags** | `-h` still present, so no byte figure was actually produced. |
| **Probe** | "What does `-a` change about which lines you get?" |

### Exercise 19 — **Flag, load-bearing**
| Field | Value |
|---|---|
| **Goal** | Convert an observed byte sequence into the flag. |
| **Expected end state** | `kestrel flags submit 'KESTREL{...}'` accepted, recorded as `02/07`. |
| **Evidence** | `kestrel flags` (the registry listing shows `02/07 captured`); `history` shows the exercise 10 byte dump before the submission. |
| **Accept** | The correct flag, derived from the escaped name. |
| **Reject** | A correct flag with no byte dump anywhere in history — they guessed the name from the rendered listing and got lucky with the U+00A0 mapping. Send them to exercise 10. Reject brute-forced submissions (many rejected attempts varying underscores). |
| **Red flags** | Submission timestamp before any listing of `maintenance`. |
| **Probe** | "Which underscore in your flag came from a character you cannot type?" |

### Exercise 20 — Debrief, **load-bearing**
| Field | Value |
|---|---|
| **Goal** | State the four mechanisms plainly. |
| **Expected end state** | Four sentences plus the sentence for cass. |
| **Accept** | (1) `ls` omits entries whose names begin with `.` unless asked. (2) `du` counts bytes on disk and does not consult the dot rule. (3) 40 MiB of filler in one file, `ballast.bin`. (4) A filename is a sequence of bytes — anything except `/` and NUL — so it can contain bytes that render as nothing. For cass: neither the disk nor she was lying; the two commands answer different questions. |
| **Reject** | Anything naming a culprit. Anything that says a tool was wrong or buggy. Sentence (4) reduced to "filenames can have spaces". |
| **Red flags** | Prose lifted from `readme.md` verbatim rather than from their own findings. |
| **Probe** | "If you had to give cass one command that would have shown her this in one line, what is it?" |

---

## Lesson roll-up

**Must PASS:** 4, 7, 9, 10, 19, 20. Exercise 10 is the incident — a student who reaches the flag
without it has entered the directory but has not understood the name, and 19's rubric will catch it.

**Nice to have:** 5, 6, 12, 13, 14, 15, 16, 17, 18.

**Arc discipline.** Exercises 15 and 16 are trace material. The notes file is unattributed and the
chapter establishes no author; a confident attribution is a REDO, and a validator must not supply
the name either. "The evidence does not distinguish" is the highest-scoring answer available here.
