# 02/01 — Validator rubric

Protocol: `docs/VALIDATION_PROTOCOL.md`. Evidence commands are read-only. Grade reasoning, not
just output — most of this lesson produces output a student could have typed by hand.

Lab: `/labs/02-navigating-the-filesystem/01-filesystem-tree`

---

### Exercise 1
| Field | Value |
|---|---|
| Goal | Knows `pwd`, and knows bare `cd` goes home |
| Expected end state | Two `pwd` outputs recorded; a one-line statement that `cd` alone means `cd ~` |
| Evidence commands | `history` — look for `pwd`, `cd`, `pwd` in sequence |
| Accept | Any phrasing of "home directory"; `$HOME` named instead of `~` |
| Reject | "It goes to `/`"; "it goes to the previous directory" |
| Red flags | No `cd` in history at all |
| Probe | "If your home directory were `/opt/cadet`, where would bare `cd` take you?" |

### Exercise 2
| Field | Value |
|---|---|
| Goal | Absolute paths work from anywhere |
| Expected end state | `roster.txt` contents displayed; command begins with `/` |
| Evidence commands | `history \| grep roster` |
| Accept | `cat /labs/.../roster.txt`, `less`, `head`, `more` |
| Reject | A `cd` into the lab first; a relative path; `~/`-anchored path that only worked by luck |
| Red flags | Path pasted with no preceding `pwd` or `ls` to derive it — ask where it came from |
| Probe | "Would that same command work from `/tmp`?" |

### Exercise 3
| Field | Value |
|---|---|
| Goal | Relative paths resolve from the working directory |
| Expected end state | Command is the bare filename with no slashes at all |
| Evidence commands | `history \| grep roster` |
| Accept | `cat roster.txt`; `cat ./roster.txt` with an explanation of the `./` |
| Reject | Any absolute path |
| Red flags | — |
| Probe | "Why did this work here and not from your home directory?" |

### Exercise 4
| Field | Value |
|---|---|
| Goal | One directory has many names |
| Expected end state | Three recorded commands, all listing `deck-3`; the third contains `..` |
| Evidence commands | `history \| grep deck-3` |
| Accept | Third form as `../01-filesystem-tree/deck-3` or any longer up-and-down walk |
| Reject | Third form with no `..` in it; three variants that are all relative or all absolute |
| Red flags | Only one command in history — the other two invented in the answer file |
| Probe | "Is there a fourth name? What about one using `.`?" |

### Exercise 5
| Field | Value |
|---|---|
| Goal | Sibling traversal via the shared parent |
| Expected end state | `bay 1: 12 panels...` displayed while standing in `bay-3` |
| Evidence commands | `history` — a single `cd` to `bay-3`, then a `cat` containing `..` |
| Accept | `../bay-1/survey.txt` |
| Reject | An absolute path; a second `cd`; `cd ..` followed by `cat bay-1/survey.txt` (that is two `cd`s in effect — but accept it if they only ran one `cd` total and it was the one to `bay-3`) |
| Red flags | Output pasted without the `cd` appearing in history |
| Probe | "What directory does the `..` in your command name?" |

### Exercise 6
| Field | Value |
|---|---|
| Goal | Multi-level `..` chains |
| Expected end state | Roster contents shown from inside `bay-3` |
| Evidence commands | `history \| grep roster` |
| Accept | `../../roster.txt` |
| Reject | One `..`; absolute path |
| Red flags | — |
| Probe | "How would the command change from `bay-2/panels/panel-07`?" |

### Exercise 7 *(load-bearing)*
| Field | Value |
|---|---|
| Goal | A single relative path can go up and back down |
| Expected end state | Working directory is `deck-3/bay-2`; exactly one `cd` used |
| Evidence commands | `history \| grep '^ *[0-9]* *cd'` |
| Accept | `cd ../bay-2` |
| Reject | `cd ..` then `cd bay-2`; any absolute path — the exercise rules both out explicitly |
| Red flags | — |
| Probe | "Which directory does the shell visit in the middle of resolving that path?" |

### Exercise 8
| Field | Value |
|---|---|
| Goal | Counting path components |
| Expected end state | Back at lab root; a written count with a justification tied to `pwd` |
| Evidence commands | `history`; `pwd` |
| Accept | `cd ../../../..` with "four components below the lab root" or equivalent |
| Reject | A count with no reasoning; `cd` to an absolute path |
| Red flags | Count correct but justification is "I tried until it worked" — that is a partial pass at best |
| Probe | "Which four names did you cross off?" |

### Exercise 9
| Field | Value |
|---|---|
| Goal | Choosing between the two path kinds on purpose |
| Expected end state | Both commands recorded; one line of justification |
| Evidence commands | `history \| grep bay-3` |
| Accept | Either choice, if justified. "Absolute, because a script's working directory is not guaranteed" and "relative, because the tree can be relocated" are both correct |
| Reject | No justification; a justification that is just "it is shorter" |
| Red flags | — |
| Probe | "What breaks each of them?" |

### Exercise 10 *(load-bearing)*
| Field | Value |
|---|---|
| Goal | Logical vs physical working directory |
| Expected end state | Two different strings recorded — one ending `/shortcut`, one ending `/deck-3/bay-2` |
| Evidence commands | `history \| grep pwd` |
| Accept | `pwd` and `pwd -P`; `pwd` and `realpath .`; `pwd` and `/bin/pwd` (the external `pwd` defaults to physical) |
| Reject | Two identical outputs — means they never entered through the symlink |
| Red flags | Only one command in history and two outputs in the answer file |
| Probe | "Which one is a real directory on disk?" |

### Exercise 11
| Field | Value |
|---|---|
| Goal | Resolving a path without moving |
| Expected end state | `.../deck-3/bay-2/survey.txt` printed; `pwd` unchanged before and after |
| Evidence commands | `history` — no `cd` between the previous exercise and this one |
| Accept | `realpath shortcut/survey.txt`; `readlink -f shortcut/survey.txt` |
| Reject | `cd shortcut` first; hand-typed output |
| Red flags | — |
| Probe | "What would `readlink` without `-f` have given you, and why?" |

### Exercise 12 *(load-bearing)*
| Field | Value |
|---|---|
| Goal | Explains why `..` from a symlinked directory is not the physical parent |
| Expected end state | Landed at the lab root, not at `deck-3`; two lines naming the shell's logical bookkeeping |
| Evidence commands | `history`; the written answer |
| Accept | Any answer saying the shell tracks the path you typed (`$PWD`) and computes `..` from it textually, before the kernel is involved |
| Reject | "Symlinks always behave like that"; "`..` is broken"; an answer that only restates what happened without naming the cause |
| Red flags | Answer copied from the notes verbatim — probe it |
| Probe | "If you had used the flag from exercise 21 to enter, where would `cd ..` have put you?" |

### Exercise 13
| Field | Value |
|---|---|
| Goal | `..` chain to a file two levels up |
| Expected end state | Three `readings.log` lines displayed from inside `panel-07` |
| Evidence commands | `history \| grep readings` |
| Accept | `../../readings.log` |
| Reject | Absolute path |
| Red flags | — |
| Probe | "Where does one `..` land you?" |

### Exercise 14
| Field | Value |
|---|---|
| Goal | `dirname` / `basename`, including suffix stripping |
| Expected end state | Three outputs: `deck-3/bay-2`, `readings.log`, `readings` |
| Evidence commands | `history \| grep -E 'dirname\|basename'` |
| Accept | Suffix given as `.log`; `log` (without the dot) is wrong output — check the third line really says `readings` |
| Reject | Any use of an editor or manual retyping to strip the extension |
| Red flags | — |
| Probe | "Do either of these check that the file exists?" |

### Exercise 15 *(Experiment — prediction required)*
| Field | Value |
|---|---|
| Goal | Separates three distinct path rules: interior slash collapsing, the leading slash as root, the trailing slash as a directory assertion |
| Expected end state | Four written predictions, four observations, an explanation covering all three rules |
| Evidence commands | `history` — all four commands present, in order, before the answer was written |
| Accept | Interior/trailing runs collapse; `//deck-3` is **absolute** and fails because `/deck-3` does not exist; trailing slash asserts directory-ness and yields `Not a directory` |
| Reject | **Missing prediction — fail regardless of how good the explanation is.** Also reject "the double slash broke it" as the explanation for the third command — that is the trap the exercise is built around. A wrong prediction with a correct explanation passes |
| Red flags | Predictions matching output exactly on all four, written in the same session as the run — probe with a case they have not run |
| Probe | "What does `ls /deck-3` do, and how is that different from what you just explained?" |

### Exercise 16 *(Experiment — prediction required)*
| Field | Value |
|---|---|
| Goal | `~` is a shell expansion; quoting suppresses it |
| Expected end state | Five predictions, five observations, an explanation naming the shell as the actor |
| Evidence commands | `history` |
| Accept | "The shell expands `~` before `echo` runs; both quote styles suppress it; `echo` never sees a tilde in the unquoted case." Plus: `..` in `/` points at `/`, so the walk cannot go above root |
| Reject | Missing prediction; "`echo` prints the home directory"; an explanation that credits `echo` |
| Red flags | — |
| Probe | "What does `echo ~cass` print, and who computed it?" |

### Exercise 17
| Field | Value |
|---|---|
| Goal | Connects `$PWD` to the working directory |
| Expected end state | `echo $PWD` (or `${PWD}`) matching `pwd`, then differing after a `cd` |
| Evidence commands | `history \| grep PWD` |
| Accept | `echo $PWD`; `printf '%s\n' "$PWD"` |
| Reject | Running `pwd` inside a substitution — that is still running `pwd` |
| Red flags | — |
| Probe | "Who updates that variable, and when?" |

### Exercise 18
| Field | Value |
|---|---|
| Goal | The working directory can outlive the directory |
| Expected end state | Recorded: `pwd` still prints the name, `pwd -P` fails with a `getcwd` error, `ls` fails |
| Evidence commands | `history` — a `mkdir`, a `cd`, an `rmdir`/`rm -r`, then the three probes |
| Accept | Any answer naming that the shell's variable is stale while the kernel has no path for the directory; escape by `cd` to any absolute path |
| Reject | An answer claiming `pwd` also failed (it does not — that difference is the exercise) |
| Red flags | The three outputs recorded but no `rmdir` in history |
| Probe | "Which of the three answers came from the shell and which from the kernel?" |

### Exercise 19 *(Dig)*
| Field | Value |
|---|---|
| Goal | Reads a short man page fully; finds `-a` and `-s` |
| Expected end state | One `dirname` call with three paths; one `basename` call with `-a` and `-s` producing three `survey` lines |
| Evidence commands | `history \| grep basename` |
| Accept | `basename -a -s .txt ...`; `basename -as .txt ...`; also accept `--multiple` / `--suffix` |
| Reject | Three separate `basename` calls; a loop (correct in spirit, but the exercise names the flags — accept as partial and ask for the flags) |
| Red flags | Flags used with no `man`/`--help` in history — ask where they came from |
| Probe | "Why does `basename` need to be told, when `dirname` does not?" (Answer: `basename`'s second operand is already claimed by the suffix form.) |

### Exercise 20 *(Dig)*
| Field | Value |
|---|---|
| Goal | Finds `--relative-to` |
| Expected end state | Output `../../../bay-3/survey.txt`, verified by use |
| Evidence commands | `history \| grep realpath` |
| Accept | `realpath --relative-to=<dir> <path>`; the two-word form |
| Reject | A hand-counted answer with no `realpath` call |
| Red flags | Used `--relative-base` and reported an absolute path as correct |
| Probe | "What does `--relative-base` do differently?" |

### Exercise 21 *(Dig)*
| Field | Value |
|---|---|
| Goal | `cd -P`, and `set -o physical` |
| Expected end state | `cd -P shortcut` followed by `pwd` printing the `deck-3/bay-2` path; `set -o physical` named |
| Evidence commands | `history \| grep -E 'cd -P\|set -o'` |
| Accept | Also accept discovering it via `help cd` |
| Reject | `cd shortcut` then `pwd -P` — that answers exercise 10, not this one |
| Red flags | `man cd` in history with no result, then a correct answer appearing anyway — probe the source |
| Probe | "With `set -o physical` on, what does `cd shortcut; cd ..` do?" |

---

## Lesson roll-up

**Load-bearing — must PASS:** 7, 10, 12, 15, 16.

Everything else is nice-to-have. 12 is the one that matters most: a student who cannot explain why
`cd ..` from a symlinked directory lands where it does will misread the symlink chain in Chapter 3
and the `$PWD` behaviour in Chapter 11.

**Partial-credit note.** Exercises 2–9 all produce output that is trivially fakeable. Weight the
probe questions heavily here; a student who can answer "what directory does your `..` name?" for
exercises 5, 6 and 13 has demonstrated the skill even if one of the commands was wrong.

**Cap.** If the two Experiment exercises have no written prediction, the lesson caps at
PASS-WITH-NOTES regardless of the rest.
