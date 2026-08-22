# 01/03 — Validator rubric

Governed by [`docs/VALIDATION_PROTOCOL.md`](../../docs/VALIDATION_PROTOCOL.md).

Evidence: `~/01-03-answers.md`, `history`, and re-running read-only commands.

Lab: `/labs/01-shell-and-terminal/03-command-anatomy/`

**Before grading, check the lab is intact:** the files `-l` and `--help` must still exist. If they
were renamed, several exercises were solved by cheating around the problem — see exercise 6's
Reject row.

---

### Exercise 1 — classify five words
| Field | |
|---|---|
| **Goal** | Reaches for `type` as the default question. |
| **Expected end state** | `cd` builtin, `ls` file, `if` keyword, `echo` builtin, `type` builtin. |
| **Evidence commands** | `type cd ls if echo type` |
| **Accept** | `type`, `type -t`, `command -v` with correct interpretation. |
| **Reject** | Answers derived from `which` alone — it returns nothing for `cd` and `if`. |
| **Red flags** | Correct answers with no classifier in history. |
| **Probe question** | "Which of those five could not possibly be a program on disk, and why?" |

### Exercise 2 — three arguments
| Field | |
|---|---|
| **Goal** | The shell splits on whitespace; the program receives a list. |
| **Expected end state** | `3 argument(s)` and three bracketed lines. |
| **Evidence commands** | `./bin/deck-report a b c` |
| **Accept** | Sentence identifying whitespace as the splitter. |
| **Reject** | "The shell passed the arguments to the flags." |
| **Red flags** | — |
| **Probe question** | "Does the shell know what any of those three mean?" |

### Exercise 3 — one argument with a space
| Field | |
|---|---|
| **Goal** | Quoting groups a word before splitting. |
| **Expected end state** | `1 argument(s)`, the bracketed value containing a space. |
| **Evidence commands** | `./bin/deck-report "deck 3"` |
| **Accept** | Single quotes, double quotes, or a backslash-escaped space. |
| **Reject** | Removing the space. |
| **Red flags** | — |
| **Probe question** | "At what point did the grouping happen — before or after the program started?" |

### Exercise 4 — every echo
| Field | |
|---|---|
| **Goal** | Resolution order, and that the first match wins. |
| **Expected end state** | Four entries: the builtin, then `/opt/kestrel/bin/echo`, `/usr/bin/echo`, `/bin/echo`. Builtin identified as the winner. |
| **Evidence commands** | `type -a echo` |
| **Accept** | Count of 4. Reason must be "builtins are resolved before PATH files", not "it is alphabetically first" or "it is fastest". |
| **Reject** | Naming a PATH file as the winner. |
| **Red flags** | — |
| **Probe question** | "How would you run `/bin/echo` instead, without changing anything?" |

### Exercise 5 — which vs type
| Field | |
|---|---|
| **Goal** | `which` searches the filesystem and is blind to everything else. |
| **Expected end state** | `which echo` → one path; `which -a echo` → three paths, **no builtin**; `which cd` → nothing; `type cd` → builtin. |
| **Evidence commands** | `which echo; which -a echo; which cd; type cd` |
| **Accept** | Sentence naming builtins/keywords/aliases/functions as what `which` cannot see. |
| **Reject** | Concluding `cd` is missing or broken. |
| **Red flags** | — |
| **Probe question** | "`which -a echo` listed three. `type -a echo` listed four. Which extra one, and does it matter?" |

### Exercise 6 — the file named -l
| Field | |
|---|---|
| **Goal** | Leading dashes are interpreted by the *program*, and there are two independent ways out. |
| **Expected end state** | Contents read twice, by `--` and by a path form. Naive attempt's error quoted: `cat: invalid option -- 'l'`. |
| **Evidence commands** | `cat -- -l`; `cat ./-l` |
| **Accept** | `--`, `./-l`, or an absolute path. Any two distinct ones. |
| **Reject** | Renaming or moving the file. Also reject `cat < -l` presented as one of the two — it works, but it is a third method, so accept it only as a bonus alongside two of the above. |
| **Red flags** | The file `-l` no longer exists in the lab. |
| **Probe question** | "Which of your two methods would still work against a program that does not support `--`?" |

### Exercise 7 — the file named --help
| Field | |
|---|---|
| **Goal** | The dangerous failure: a mistaken argument that silently succeeds at something else. |
| **Expected end state** | Naive attempt printed `cat`'s **usage/help text**, not an error. Contents then read via both methods. |
| **Evidence commands** | `cat --help \| head -1`; `cat -- --help`; `cat ./--help` |
| **Accept** | Sentence identifying that exercise 6 failed loudly and this one failed quietly — output appeared, exit status was 0, and nothing indicated the file was never opened. |
| **Reject** | Reporting an error for `cat --help`. They did not run it. |
| **Red flags** | — |
| **Probe question** | "If this were in a script, how long would it take you to notice?" |

### Exercise 8 — the ll alias
| Field | |
|---|---|
| **Goal** | Aliases are inspectable, bypassable, removable, and resolved first. |
| **Expected end state** | Four steps: defined; `type ll` reports an alias; `\ll` or `command ll` bypasses (and errors, since no such program exists — that is the correct proof); removed and `type ll` reports not found. |
| **Evidence commands** | `alias ll='ls -l'; type ll; unalias ll; type ll` |
| **Accept** | Bypass demonstrated on `ll` (fails, proving the alias was doing the work) **or** on an alias that shadows a real command. |
| **Reject** | Skipping the classifier step and asserting it is an alias. |
| **Red flags** | — |
| **Probe question** | "Will your alias still be there tomorrow?" |

### Exercise 9 — command not found
| Field | |
|---|---|
| **Goal** | The current directory is not on `PATH`; naming a path bypasses the search. |
| **Expected end state** | Two successful runs by two distinct path spellings, one relative and one absolute. |
| **Evidence commands** | `./bin/deck-report x`; `/labs/01-shell-and-terminal/03-command-anatomy/bin/deck-report x` |
| **Accept** | Sentence naming `PATH` and the absence of `.` from it. |
| **Reject** | Only one path form. Modifying `PATH` **instead of** giving paths — accept it as an extra, not as the answer. |
| **Red flags** | — |
| **Probe question** | "Why would putting the current directory on `PATH` be a bad idea?" |

### Exercise 10 — four odd arguments
| Field | |
|---|---|
| **Goal** | Accurate observation without premature theory. Sets up Chapter 5. |
| **Expected end state** | Four transcripts. The `*` run reports one argument **per file in the lab directory**, including `-l` and `--help`. |
| **Evidence commands** | Re-run all four. |
| **Accept** | Honest transcription. An empty string reported as `[]` with `1 argument(s)`. |
| **Reject** | An explanation of the `*` result that invents a rule. The exercise explicitly asked them not to. A student who says "I don't know why yet" is doing it right. |
| **Red flags** | The `*` output showing one argument containing an asterisk — that means they quoted it, so they did not run what was asked. |
| **Probe question** | "Who expanded the `*` — the shell, or `deck-report`? How could you tell from the output alone?" |

### Exercise 11 — the decoy ls
| Field | |
|---|---|
| **Goal** | Same name, two files, search order decides. |
| **Expected end state** | `./bin/ls` prints the decoy line; bare `ls` lists files. |
| **Evidence commands** | `./bin/ls`; `ls` |
| **Accept** | Sentence stating that if `bin/` came earlier on `PATH` the decoy would win every bare `ls`. |
| **Reject** | Editing `PATH` and leaving it edited. |
| **Red flags** | — |
| **Probe question** | "How would you find out that this had happened to you?" |

### Exercise 12 — two echoes (Experiment)
| Field | |
|---|---|
| **Goal** | The builtin and the external program are genuinely different programs. |
| **Expected end state** | Prediction written first. `echo --version` prints the literal text `--version`; `/usr/bin/echo --version` prints coreutils version information. |
| **Evidence commands** | `echo --version; /usr/bin/echo --version` |
| **Accept** | Explanation citing the resolution order — the bare word hits the builtin, which does not implement `--version` and so treats it as text to print. Wrong prediction with correct explanation is a full pass. |
| **Reject** | No prediction. |
| **Red flags** | — |
| **Probe question** | "Which of the two is a script more likely to get, and does the script know?" |

### Exercise 13 — the recursive alias (Experiment)
| Field | |
|---|---|
| **Goal** | Alias expansion is not re-applied to the same name. |
| **Expected end state** | Prediction **with reasoning**; observation that `ls` gives a long listing and does not loop. |
| **Evidence commands** | `alias ls='ls -l'; ls; unalias ls` |
| **Accept** | Predicting infinite recursion is a good prediction, correctly reasoned. Full pass, provided the follow-up sentence states the rule they discovered. |
| **Reject** | No prediction, or leaving the alias defined afterwards. |
| **Red flags** | Prediction that matches the answer exactly with no reasoning — likely written afterwards. |
| **Probe question** | "What would the shell have to remember to make that rule work?" |

### Exercise 14 — classifying in dash (Stretch)
| Field | |
|---|---|
| **Goal** | Classification is per-shell, tying back to 01/02 ex 9. |
| **Expected end state** | In dash: `cd` and `echo` are builtins; `[[` is not found. |
| **Evidence commands** | `dash -c 'command -v cd; command -v echo; command -v "[["'` |
| **Accept** | `command -v`. `type` also works in dash and is acceptable. |
| **Reject** | Running it in bash and reporting bash's answers. |
| **Red flags** | `[[` reported as a keyword — that is bash's answer. |
| **Probe question** | "Which of the three differed, and does that match the error you saw in 01/02?" |

### Exercise 15 — how many processes (Stretch)
| Field | |
|---|---|
| **Goal** | Running a script starts an interpreter process. |
| **Expected end state** | At least one new process — a `bash` running the script — a child of the interactive shell. |
| **Evidence commands** | Reasoning only; no measurement required. |
| **Accept** | "One new bash, child of my shell." Also accept students who note that `echo` and `printf` are builtins and so add no processes — that is the better answer. |
| **Reject** | "None — it is just a file." |
| **Red flags** | — |
| **Probe question** | "Would the count change if the script used `/usr/bin/echo`?" |

### Exercise 16 — one line for a colleague (Stretch)
| Field | |
|---|---|
| **Goal** | Picks a diagnostic on coverage, not habit. |
| **Expected end state** | `type grep` or `type -a grep`, with a justification. |
| **Evidence commands** | `cat ~/01-03-answers.md` |
| **Accept** | `type`, `type -a`, or `command -v` with a stated trade-off. |
| **Reject** | `which`, unless they explicitly justify it and acknowledge its blind spots — then PASS-WITH-NOTES. |
| **Red flags** | — |
| **Probe question** | "What would yours report if `grep` were a function?" |

### Exercise 17 — the bare-path flag (Dig)
| Field | |
|---|---|
| **Goal** | The flag reports a path only when the resolution ends at a file. |
| **Expected end state** | `type -p ls` → a path. `type -p echo` → **nothing**, because `echo` resolves to a builtin. |
| **Evidence commands** | `type -p ls; type -p echo` |
| **Accept** | Explanation that a builtin has no path to report, so empty output is correct. Use cases: good for scripts that need a path; misleading when empty output is read as "not installed". |
| **Reject** | Calling the empty output a bug or claiming `echo` is not installed. |
| **Red flags** | The flag appearing with no `help type` or `man bash` in history. |
| **Probe question** | "A script does `p=$(type -p echo)` and then runs `$p`. What happens?" |

### Exercise 18 — the PATH cache (Dig)
| Field | |
|---|---|
| **Goal** | The shell caches command locations, and the cache can go stale. |
| **Expected end state** | `hash` shows entries after running some programs; `hash -r` empties it; `hash` then reports empty. |
| **Evidence commands** | `hash; ls >/dev/null; hash; hash -r; hash` |
| **Accept** | Bug sentence: a program moved or replaced on disk while the shell is running keeps resolving to the old location until the cache is cleared. |
| **Reject** | Describing it as a cache of command *output*. |
| **Red flags** | Reporting entries in a shell where nothing has been run — possible but unlikely; ask them to reproduce. |
| **Probe question** | "You just installed a newer `jq` earlier on PATH and the old one still runs. Now what?" |

### Exercise 19 — switching a builtin off (Dig)
| Field | |
|---|---|
| **Goal** | The resolution order can be changed at the builtin end, not only the PATH end. |
| **Expected end state** | `enable -n echo`; `type echo` → a file path; `echo --version` → coreutils version; `enable echo`; `type echo` → shell builtin. |
| **Evidence commands** | Re-run the sequence. |
| **Accept** | Sentence noting this is scoped to the current shell, reversible in one word, and does not disturb `PATH` for anything else. |
| **Reject** | Achieving it by editing `PATH`. That is the thing the exercise asked them not to do. |
| **Red flags** | Never restoring the builtin — check `type echo` at the end of their session. |
| **Probe question** | "Does this affect a script you launch from this shell?" |

---

## Lesson roll-up

**Load-bearing (must PASS):** 1, 4, 6, 9, 12.
Exercise 6 is the one with the longest reach — Chapter 5's incident is built on adversarial
filenames, and a student without the `--` and `./` reflexes will be stuck there. Exercise 4 plus 12
together are what make "it wasn't the program you thought" concrete.

**Nice to have:** 2, 3, 5, 7, 8, 10, 11, 13, 14, 15, 16.

**Dig (attempts noted, not required):** 17, 18, 19.

Exercise 10 is graded on **accuracy of observation only**. Do not require, hint at, or reward an
explanation of the `*` result; a confident wrong rule invented here will have to be unlearned in
Chapter 5.
