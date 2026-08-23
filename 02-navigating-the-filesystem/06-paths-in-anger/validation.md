# 02/06 — Validator rubric

Read `docs/VALIDATION_PROTOCOL.md` first. Lab:
`/labs/02-navigating-the-filesystem/06-paths-in-anger`. Written answers go in `answers.md`, which the
student creates themselves.

**Reference values for a freshly seeded lab:**

- `awkward` holds **6 entries** and `ls` prints **7 lines**: ` notes.txt`, `deck 3 bay 2`,
  `notes.txt`, `notes.txt ` (trailing space), `panel\treport.txt`, `two\nlines.txt` (36 bytes).
- `dashes`: `-audit`, `--help`, `-rf`, `manifest.txt`, and the directory `-staging`.
- `lookalikes`: 5 entries; `LC_ALL=C ls -b` → `deck.txt`, `d\320\265ck.txt`,
  `panel\342\200\213.txt`, `strain-log.txt`, `strain\342\200\221log.txt`. Two distinct inodes per
  pair; the `strain` pair is 27 and 28 bytes.
- `dotted`: `ls` 1, `ls -a` 7, `ls -A` 5.
- `metachars`: `$HOME.txt`, `dorn's notes.txt`, `glob*star.txt`, `range[0-9].txt`, `what?.txt`.
- `report`: `ls` 4 lines, `ls -a` 7 lines; `.draft` is the hidden one.
- Container locale is `C.UTF-8`, so plain `ls -b` does **not** escape the non-ASCII names.

**Integrity check before grading anything:** the lab must be unmodified. Re-run
`ls -b` over each subdirectory and compare against the list above. A renamed file means the student
solved a different, easier lab — REDO, and re-seed.

---

### Exercise 1
| Field | Value |
|---|---|
| Goal | Output lines are not entries |
| Expected end state | 6 files, 7 lines, explained by a newline in a name |
| Evidence | `history` |
| Accept | Correct counts with the newline named as the cause |
| Reject | "7 files"; a correct count with no explanation |
| Red flags | — |
| Probe | "Which two lines are one name?" |

### Exercise 2
| Field | Value |
|---|---|
| Goal | `ls -b` |
| Expected end state | The six escaped names, including `notes.txt\ ` and `two\nlines.txt` |
| Evidence | `ls -b awkward` |
| Accept | `-b` or `--quoting-style=escape` |
| Reject | `-Q` alone (the tab stays invisible); hand-annotated plain output |
| Red flags | Escapes that do not match the reference list |
| Probe | "Which escape is the tab?" |

### Exercise 3
| Field | Value |
|---|---|
| Goal | Getting a spaced path into a command |
| Expected end state | `strain 0.41 nominal` |
| Evidence | `history` |
| Accept | Quotes, backslashes or completion — and the method named |
| Reject | Renaming the directory; contents quoted without any read in history |
| Red flags | — |
| Probe | "How many words did the shell make of your command line?" |

### Exercise 4
| Field | Value |
|---|---|
| Goal | Distinguishing three names that render alike |
| Expected end state | leading-space → "filed with a leading space"; plain → "no whitespace at all"; trailing-space → "filed with a trailing space" |
| Evidence | Three reads in history |
| Accept | Correct mapping by any method |
| Reject | Two reads and an inference; the same file read twice |
| Red flags | Mapping that contradicts their own transcript |
| Probe | "Which of the three did you read first, and how did you type it?" |
| **Load-bearing** | yes |

### Exercise 5
| Field | Value |
|---|---|
| Goal | `cd` into an awkward path; `cd -` back |
| Expected end state | `pwd` shows `.../awkward/deck 3 bay 2`; return via `cd -` |
| Evidence | `history` |
| Accept | `cd -` only (the exercise forbids naming the path); `~-` accepted |
| Reject | `cd ../..`; `cd $OLDPWD` is acceptable — it does not name the path — accept with a note |
| Red flags | — |
| Probe | "Where does `cd -` get the path from?" |

### Exercise 6
| Field | Value |
|---|---|
| Goal | A tab is not spaces |
| Expected end state | `panel\treport.txt`; `-b` named as the proof |
| Evidence | `history` |
| Accept | `-b`; also `stat -c %N`, or `--quoting-style=c` |
| Reject | `-Q` claimed as proof; "it looked wider than a space" |
| Red flags | — |
| Probe | "What would `-Q` have shown you there?" |

### Exercise 7
| Field | Value |
|---|---|
| Goal | Why a newline is worse than a tab |
| Expected end state | 36 bytes; the danger stated as tools splitting input on newlines |
| Evidence | `stat` in history |
| Accept | Any phrasing of "a newline makes one file look like two to a line-oriented tool" |
| Reject | "Both are equally bad"; "it is harder to type" as the whole answer |
| Red flags | Size reported without a `stat` |
| Probe | "What would `wc -l` say?" |
| **Load-bearing** | yes |

### Exercise 8
| Field | Value |
|---|---|
| Goal | Completion as a tool, and reading its stall |
| Expected end state | An account of: Tab completes to the common prefix and stops; a second Tab lists candidates; the shell inserts `\ ` for the trailing space |
| Evidence | `history` shows the escaped form, which is what bash inserts |
| Accept | Any accurate description of the stall-and-disambiguate cycle |
| Reject | A typed-out escaped name with no account of completion; copy-paste |
| Red flags | History showing the name typed in one go — completion leaves a characteristic escaped form, but so does careful typing; use the probe |
| Probe | "How many candidates did the second Tab show, and what were they?" |

### Exercise 9
| Field | Value |
|---|---|
| Goal | The word, not the file, decides |
| Expected end state | One line: the first character of the argument differs; `cat` parses a leading `-` as options |
| Evidence | Both commands in history |
| Accept | Any phrasing that locates the difference in the argument rather than the file |
| Reject | "The file is protected"; "cd broke it"; "the file only works from outside" |
| Red flags | — |
| Probe | "Is `-audit` a different file from `dashes/-audit`?" |
| **Load-bearing** | yes |

### Exercise 10
| Field | Value |
|---|---|
| Goal | The two escapes |
| Expected end state | `cat ./-audit` and `cat -- -audit`, both printing `not an option, a file` |
| Evidence | `history` |
| Accept | Both forms |
| Reject | One form twice; `cat < -audit` (works, but is neither of the two asked for — accept with a note as a third route) |
| Red flags | — |
| Probe | "Which of the two would you use on a filename supplied by someone else?" |

### Exercise 11
| Field | Value |
|---|---|
| Goal | A name that collides with a real option |
| Expected end state | Both fixes work; the bare attempt prints cat's usage and does not error |
| Evidence | `history` shows the bare attempt too |
| Accept | Noting the silent wrong behaviour as the finding |
| Reject | "Neither fix works"; not trying the bare form |
| Red flags | — |
| Probe | "Which is worse: a command that fails, or one that succeeds at the wrong thing?" |

### Exercise 12
| Field | Value |
|---|---|
| Goal | Short options concatenate |
| Expected end state | `-a -u -d -i -t` identified; the output described (inode number plus the directory itself) |
| Evidence | `history` |
| Accept | All five letters mapped; approximate wording of each flag's job |
| Reject | Fewer than five; "it errored" (it does not) |
| Red flags | Letters listed with no `man ls` and no output shown |
| Probe | "Which of the five explains the number at the start of the line?" |

### Exercise 13
| Field | Value |
|---|---|
| Goal | The escapes work for builtins too |
| Expected end state | `cd ./-staging` or `cd -- -staging`, then back |
| Evidence | `history` |
| Accept | Either fix; noting `bash: cd: -s: invalid option` from the bare attempt is a bonus |
| Reject | Renaming; `cd` by absolute path is acceptable but ask for the general fix |
| Red flags | — |
| Probe | "Whose error message was that — bash's or a program's?" |

### Exercise 14
| Field | Value |
|---|---|
| Goal | Notice the gap before investigating |
| Expected end state | 5 entries, 3 distinct-looking names, both written down first |
| Evidence | `answers.md` |
| Accept | Both numbers, recorded before the escaped listing |
| Reject | Only the escaped result; "there are 5 different names" |
| Red flags | Answer written after exercise 15, with the surprise removed |
| Probe | "Can two files in one directory have the same name?" |

### Exercise 15
| Field | Value |
|---|---|
| Goal | Force the bytes into view |
| Expected end state | The five escaped names exactly as in the reference list |
| Evidence | `history` shows the locale set for the command |
| Accept | `LC_ALL=C` (or `LC_CTYPE=C`) with `-b` or an escaping quoting style; `stat -c %N` accepted as an alternate route |
| Reject | Plain `ls -b` output presented as the answer — in `C.UTF-8` it does not escape these; escapes copied from the notes |
| Red flags | Correct escapes with no locale-setting command anywhere in history |
| Probe | "Why did `-b` alone not do it?" |
| **Load-bearing** | yes |

### Exercise 16
| Field | Value |
|---|---|
| Goal | Attach a name to a character |
| Expected end state | ASCII `-` is U+002D; the escaped one is U+2011 NON-BREAKING HYPHEN |
| Evidence | Both files read |
| Accept | Correct pairing; naming the code points from the file contents |
| Reject | Pairing asserted without reading both files; the two swapped |
| Red flags | — |
| Probe | "Which of the two would a person get by pasting from a word processor?" |

### Exercise 17
| Field | Value |
|---|---|
| Goal | Same, for a homoglyph letter |
| Expected end state | Latin `e` U+0065 vs Cyrillic `е` U+0435 |
| Evidence | Both files read |
| Accept | Correct pairing |
| Reject | Swapped; only one read |
| Red flags | — |
| Probe | "How many bytes is the Cyrillic one?" (two) |

### Exercise 18
| Field | Value |
|---|---|
| Goal | A zero-width character |
| Expected end state | `panel\342\200\213.txt`; ZERO WIDTH SPACE named |
| Evidence | `history` |
| Accept | The escaped name plus "a character that occupies bytes and no screen columns" |
| Reject | "It is a space"; claiming the name is `panel.txt` |
| Red flags | — |
| Probe | "What does `cat lookalikes/panel.txt` do?" (fails) |

### Exercise 19
| Field | Value |
|---|---|
| Goal | Get an untypeable name into a command |
| Expected end state | The Cyrillic file read; the method described |
| Evidence | `history` |
| Accept | Tab completion, or pasting the escaped/`%N` form |
| Reject | Claiming they typed the character; renaming |
| Red flags | The name appearing in history in raw form with no completion story — possible, via paste, so use the probe rather than failing outright |
| Probe | "What prefix did you give Tab, and what happened?" |

### Exercise 20
| Field | Value |
|---|---|
| Goal | Three listing modes |
| Expected end state | 1, 7, 5 |
| Evidence | Three listings in history |
| Accept | The three counts with the difference explained |
| Reject | 7 and 5 swapped; counts with no listings |
| Red flags | — |
| Probe | "What are the two entries `-A` drops?" |

### Exercise 21
| Field | Value |
|---|---|
| Goal | `..` is an entry, not a prefix |
| Expected end state | Both files read; a statement that `..` is a real entry meaning the parent, and these merely begin with dots |
| Evidence | `history` |
| Accept | Any correct account; testing `cd ...` and reporting the failure is a bonus |
| Reject | "`...` means two levels up" |
| Red flags | — |
| Probe | "Who creates `..` — the filesystem, or `ls`?" |

### Exercise 22
| Field | Value |
|---|---|
| Goal | Proving emptiness |
| Expected end state | A hidden-inclusive listing showing nothing, plus a size check (`du -sh` → `4.0K`) |
| Evidence | `history` |
| Accept | Both halves; explicit reference to why plain `ls` is insufficient |
| Reject | Plain `ls` alone; "it is empty because the name says cache" |
| Red flags | — |
| Probe | "What did plain `ls` say about `accounting` last lesson?" |

### Exercise 23
| Field | Value |
|---|---|
| Goal | Hiding is `ls`'s convention |
| Expected end state | A non-`ls` tool showing dot-names with no flag |
| Evidence | `history` |
| Accept | `du -a`, `stat`, `wc`, `cat` on a dot-name — anything that never had a hiding rule. Naming `tree` **as a bad example**, because it copies the convention, is a strong answer |
| Reject | `tree -a` presented as proof that hiding is not `ls`'s doing |
| Red flags | — |
| Probe | "Does the kernel have a concept of a hidden file?" |

### Exercise 24
| Field | Value |
|---|---|
| Goal | Which characters the shell acts on |
| Expected end state | `$HOME.txt` and `dorn's notes.txt` genuinely need quoting; the three glob-ish names happen to work bare |
| Evidence | Five reads in history, ideally with the failed bare attempts |
| Accept | Either "two needed it" or "all five should be quoted anyway", provided the glob-matches-itself mechanism is understood |
| Reject | Claiming all five failed bare (they do not); claiming none needed quoting |
| Red flags | No failed attempts anywhere — this lab is impossible to complete without some |
| Probe | "Why did `glob*star.txt` work unquoted, and when would it stop working?" |

### Exercise 25
| Field | Value |
|---|---|
| Goal | Observe that the two quote styles differ |
| Expected end state | Double quotes → `cat: metachars//home/cadet.txt: No such file or directory`; single quotes → `a dollar sign in the name` |
| Evidence | Both attempts in history |
| Accept | The two observations; no rule-stating required |
| Reject | Reporting only one; a described difference with no run |
| Red flags | — |
| Probe | "Who turned `$HOME` into a path — the shell or `cat`?" |

### Exercise 26
| Field | Value |
|---|---|
| Goal | A quote character inside a name |
| Expected end state | The file read; single-quoting explained as closing the quote early |
| Evidence | `history` — often includes a stranded continuation prompt |
| Accept | Double quotes, backslash escape, or completion |
| Reject | "The file is unreadable"; renaming |
| Red flags | — |
| Probe | "What was your shell waiting for when it showed you `>`?" |

### Exercise 27 — Experiment
| Field | Value |
|---|---|
| Goal | Predict six behaviours across everything in the lesson |
| Expected end state | Written predictions, then the six results; two named as interesting with an argument |
| Evidence | `answers.md`; `history` |
| Accept | Correct results; **any** defensible pair for "interesting" provided the argument is about silent wrong behaviour rather than about which commands errored |
| Reject | Missing prediction ⇒ **cap at PASS-WITH-NOTES**; "interesting = the ones that failed" with no further argument |
| Red flags | Six perfect predictions and no wrong ones — probe hard |
| Probe | "Which of these six would you be most likely to get wrong in a hurry, six months from now?" |
| **Load-bearing** | yes |

### Exercise 28 — Experiment
| Field | Value |
|---|---|
| Goal | Line-counting is not file-counting |
| Expected end state | Prediction; `7` from `wc -l`; 6 files; the general rule stated |
| Evidence | `history` |
| Accept | The rule stated generally — any tool assuming one name per line is wrong. Noticing that `ls` behaves differently in a pipe is a bonus |
| Reject | "The count is off by one" with no general rule; missing prediction ⇒ cap at PASS-WITH-NOTES |
| Red flags | — |
| Probe | "How would you count them correctly?" (Chapters 6 and 8 — NUL separators; an honest "I do not know yet" is fine) |
| **Load-bearing** | yes |

### Exercise 29
| Field | Value |
|---|---|
| Goal | Composing flags |
| Expected end state | `ls -RAb report` or equivalent; `old runs`' contents shown; `.draft` present; every name escaped |
| Evidence | `history` |
| Accept | `-a` for `-A`; flags in any order; each flag justified |
| Reject | Any of the three requirements unmet; justification missing |
| Red flags | — |
| Probe | "Which flag would you drop if you only cared about pasting the paths?" |

### Exercise 30
| Field | Value |
|---|---|
| Goal | `stat -c %N` |
| Expected end state | Five lines, names quoted, sizes 26, 26, 29, 17, 22 |
| Evidence | `history` |
| Accept | `%N` with `%s`; a glob or explicit list |
| Reject | `%n` (unquoted); hand-added quotes |
| Red flags | — |
| Probe | "Why is one of those five in double quotes and the rest in single?" |

### Exercise 31
| Field | Value |
|---|---|
| Goal | Identity is the inode |
| Expected end state | Two different inodes, sizes 27 and 28; "same file" requires links to one inode |
| Evidence | `stat` in history |
| Accept | Any correct account; not knowing the Chapter 3 term is fine |
| Reject | "They could be the same if you renamed one"; comparing names instead of inodes |
| Red flags | Inode numbers that are identical — impossible here |
| Probe | "If they had the same inode, what would `ls` show?" |

### Exercise 32
| Field | Value |
|---|---|
| Goal | `-q` |
| Expected end state | `two?lines.txt` on one line |
| Evidence | `history` |
| Accept | `-q` or `--hide-control-chars` |
| Reject | `-b` presented as the answer without noting it is the escaping form (accept with a note if they distinguish the two) |
| Red flags | — |
| Probe | "Why did you not need this flag when running `ls` in a terminal?" |

### Exercise 33 — Dig
| Field | Value |
|---|---|
| Goal | `--quoting-style` |
| Expected end state | The eight values listed; `shell-escape` run against `lookalikes` |
| Evidence | `man ls` in history |
| Accept | All eight values (`literal, locale, shell, shell-always, shell-escape, shell-escape-always, c, escape`); `shell-escape` or `shell-escape-always` used |
| Reject | Fewer than the full list; a style that leaves the names raw, presented as shell-ready |
| Red flags | — |
| Probe | "Which value reproduces `-b`?" (`escape`) |

### Exercise 34 — Dig
| Field | Value |
|---|---|
| Goal | `QUOTING_STYLE` |
| Expected end state | Set for one command; works on `awkward`; changes nothing visible on `lookalikes` without `LC_ALL=C` |
| Evidence | `history` |
| Accept | The variable found and demonstrated, plus the locale caveat |
| Reject | `export` used permanently with no demonstration; the caveat missing |
| Red flags | — |
| Probe | "If both the variable and the flag are set, which wins?" (the flag) |

### Exercise 35 — Dig
| Field | Value |
|---|---|
| Goal | Two escape formats, one pasteable |
| Expected end state | `d\320\265ck.txt` versus `'lookalikes/d'$'\320\265''ck.txt'`; `stat`'s form is the pasteable one |
| Evidence | `history` shows both, and ideally a paste test |
| Accept | The correct conclusion **with** a test |
| Reject | The conclusion asserted without testing; claiming `ls -b`'s form pastes correctly |
| Red flags | — |
| Probe | "Paste the `ls -b` form into a `cat`. What did you get?" |

### Exercise 36 — Dig
| Field | Value |
|---|---|
| Goal | Why `ls` defaults to hiding control characters |
| Expected end state | `-q`/`--hide-control-chars` and `--show-control-chars`; `-q` preferred; reason given as terminal escape sequences in filenames |
| Evidence | `history` |
| Accept | Any accurate account of a filename carrying escape sequences |
| Reject | Preferring raw output "for accuracy" with no acknowledgement of the risk |
| Red flags | **Any attempt to create a file with escape sequences in its name.** Stop the student; it is unnecessary and can wreck their terminal |
| Probe | "What is `ls`'s default when it writes to a terminal, and why is that not the default in a pipe?" |

---

## Lesson roll-up

**Must PASS (load-bearing):** 4, 7, 9, 15, 27, 28.

- **15** is the technique the chapter's incident needs. Without it, `07-incident-02` degenerates into
  guessing.
- **9** is the mental model — the shell hands over a word, and the word is what gets parsed.
- **4** and **7** are the whitespace pair: one proves rendering is ambiguous, the other proves the
  ambiguity is dangerous.
- **27** and **28** are where the student has to commit to a prediction and be wrong.

**Nice to have:** everything else. The Dig tier (33–36) is genuinely optional.

**Automatic PASS-WITH-NOTES cap:** Experiments 27 and 28 without a written prediction.

**Whole-lesson red flags:**
- No failed commands anywhere in history. This lab cannot be completed without failures; a clean
  transcript means the answers came from somewhere else.
- Any `mv` or `rename` inside the lab. The names are the exercise.
- Escaped forms reported that match the reference list exactly while no escaping command appears in
  history — they were copied from this file or from the notes.
