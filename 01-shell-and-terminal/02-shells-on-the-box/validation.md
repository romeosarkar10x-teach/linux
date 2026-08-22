# 01/02 — Validator rubric

Governed by [`docs/VALIDATION_PROTOCOL.md`](../../docs/VALIDATION_PROTOCOL.md).

Evidence: `~/01-02-answers.md`, `history`, and re-running read-only commands.

Lab: `/labs/01-shell-and-terminal/02-shells-on-the-box/`

---

### Exercise 1 — /bin/sh
| Field | |
|---|---|
| **Goal** | Knows `sh` is an interface, not a program, and can read a symlink off a listing. |
| **Expected end state** | Target identified as `dash`. |
| **Evidence commands** | `ls -l /bin/sh` |
| **Accept** | `ls -l`, `readlink`, `file`, `stat`. |
| **Reject** | "`sh` is a smaller version of bash." Common and wrong. |
| **Red flags** | — |
| **Probe question** | "If Ubuntu switched `/bin/sh` to point at bash tomorrow, what would break?" |

### Exercise 2 — /etc/shells
| Field | |
|---|---|
| **Goal** | Can find and read the registered-shells file. |
| **Expected end state** | The file's contents recorded. |
| **Evidence commands** | `cat /etc/shells` |
| **Accept** | Any reader. |
| **Reject** | — |
| **Red flags** | — |
| **Probe question** | "Does that file install anything?" |

### Exercise 3 — three readings
| Field | |
|---|---|
| **Goal** | Preference vs invocation name vs kernel fact. |
| **Expected end state** | Three outputs plus a stated preference for `ps -p $$`. |
| **Evidence commands** | `echo $SHELL; echo $0; ps -p $$` |
| **Accept** | Preferring `ps`. Preferring `$0` **with** a reason acknowledging it can be set by the caller is also acceptable. |
| **Reject** | Preferring `$SHELL`. |
| **Red flags** | — |
| **Probe question** | "Which of the three could another program lie to you about?" |

### Exercise 4 — inside dash
| Field | |
|---|---|
| **Goal** | Environment variables are inherited; `$0` and the process table describe the child. |
| **Expected end state** | `$SHELL` unchanged, `$0` → `dash`, `ps -p $$` → `dash`. |
| **Evidence commands** | Re-run inside `dash`. |
| **Accept** | Explanation citing inheritance, or "it was set at login and nothing updated it". |
| **Reject** | Reporting that `$SHELL` changed — they misread, or they set it. |
| **Red flags** | — |
| **Probe question** | "What would have to happen for `$SHELL` to become `/bin/dash`?" |

### Exercise 5 — stale shells list
| Field | |
|---|---|
| **Goal** | A config file copied from elsewhere is not evidence about this machine. |
| **Expected end state** | Four findings, per the exercise. |
| **Evidence commands** | `cat station-shells /etc/shells`; existence tests on each path. |
| **Accept** | Extras identified as `/bin/dash`, `/bin/ksh`, `/usr/bin/zsh`; `ksh` and `zsh` absent here; `/bin/dash` present but **not registered** in this machine's file; omissions include the `rbash` entries and `/usr/bin/sh`. Full credit does not require every path enumerated — it requires the *shape*: some extras are absent, at least one extra is present-but-unregistered, and the copy is missing entries this machine has. |
| **Reject** | Concluding `ksh`/`zsh` are installed because a file lists them. That is the exact error the exercise exists to prevent. |
| **Red flags** | No existence tests in history — they compared the two files only and guessed the rest. |
| **Probe question** | "You found one path that exists here but is not in `/etc/shells`. Could you still run it?" |

### Exercise 6 — nologin
| Field | |
|---|---|
| **Goal** | The login-shell field can hold a program whose job is to refuse. |
| **Expected end state** | `ops-bot` and `sensors` named. |
| **Evidence commands** | `cat crew-shells.txt`; `man nologin` |
| **Accept** | "It prints a message and exits, so the account cannot be used interactively." |
| **Reject** | "Those accounts have no shell" — the field is not empty, and the distinction matters. |
| **Red flags** | — |
| **Probe question** | "Why give an account a shell that refuses, rather than leaving the field blank?" |

### Exercise 7 — a shell that is not there
| Field | |
|---|---|
| **Goal** | Repeats the exercise-5 skill against an account record. |
| **Expected end state** | `maint-old` named, `/bin/ksh` shown absent. |
| **Evidence commands** | `ls -l /bin/ksh` (fails) |
| **Accept** | Predicted outcome: the login fails or the shell cannot start; credentials may be accepted but no usable session results. |
| **Reject** | "Nothing would happen." |
| **Red flags** | — |
| **Probe question** | "Would the password still be checked?" |

### Exercise 8 — greet.sh two ways
| Field | |
|---|---|
| **Goal** | The interpreter is a choice, and it changes the outcome. |
| **Expected end state** | Under bash: `structural monitoring: deck 3`. Under sh: `greet.sh: 2: [[: not found` and no output line. Both exit statuses recorded; **both are 0**. |
| **Evidence commands** | `bash greet.sh; echo $?`; `sh greet.sh; echo $?` |
| **Accept** | Error quoted with the line number and the offending token. |
| **Reject** | Reporting a non-zero exit status for the `sh` run without having measured it. |
| **Red flags** | Exit statuses that do not match a re-run. |
| **Probe question** | "It printed an error and still exited 0. Where did that 0 come from?" |

### Exercise 9 — explaining the error
| Field | |
|---|---|
| **Goal** | The deep point: this is a command-lookup failure, not a parse failure. |
| **Expected end state** | Two sentences, both halves right. |
| **Evidence commands** | Read the answers file. |
| **Accept** | Names `[[` as a bash keyword dash lacks; explains that dash, not recognising the word, treats it as a command name and fails to find it. |
| **Reject** | "dash cannot parse it" / "syntax error". This is the exercise. |
| **Red flags** | — |
| **Probe question** | "If dash had a program on disk named `[[`, what would have happened?" |

### Exercise 10 — --version
| Field | |
|---|---|
| **Goal** | Options are per-program convention, not standard. |
| **Expected end state** | bash version printed; dash reports `dash: 0: Illegal option --`. |
| **Evidence commands** | `bash --version; dash --version` |
| **Accept** | Conclusion that a common flag may still be absent. |
| **Reject** | "dash has no version." |
| **Red flags** | — |
| **Probe question** | "How would you find dash's version another way?" (Chapter 13 answers it; a shrug is fine.) |

### Exercise 11 — nesting mixed shells (Experiment)
| Field | |
|---|---|
| **Goal** | Nesting is about processes, independent of which shell. |
| **Expected end state** | Prediction written first; listing shows `bash`, `dash`, `bash`, plus `ps`. |
| **Evidence commands** | Re-run the nesting. |
| **Accept** | Wrong prediction with a correct explanation. |
| **Reject** | No prediction. |
| **Red flags** | Prediction phrased identically to the observation. |
| **Probe question** | "Did entering dash end the bash you came from?" |

### Exercise 12 — `$0` three ways (Experiment)
| Field | |
|---|---|
| **Goal** | Argument zero is chosen by whoever starts the process. |
| **Expected end state** | All three read `bash` (the container's shells are not started by a login program). Sentence identifies the login program as the thing that adds the dash. |
| **Evidence commands** | `echo $0`; `bash -c 'echo $0'`; `bash -l -c 'echo $0'` |
| **Accept** | Any answer naming the *caller* — `login`, `su -`, `sshd`, "whatever starts the shell" — as the source of the dash. |
| **Reject** | "`-l` is broken." |
| **Red flags** | Reporting `-bash` for (c) — they did not run it. |
| **Probe question** | "Can a process choose its own argument zero?" |

### Exercise 13 — dash's parent (Stretch)
| Field | |
|---|---|
| **Goal** | Applies 01/01's Dig to a new situation. |
| **Expected end state** | dash's PPID equals the bash PID noted beforehand. |
| **Evidence commands** | Re-run: note bash PID, `dash`, `ps -o pid,ppid,comm -p $$`. |
| **Accept** | Any route that shows PPID, including `/proc/$$/status`. |
| **Reject** | Asserting the relationship without measuring it. |
| **Red flags** | — |
| **Probe question** | "What would the PPID be if you had gone bash → bash → dash?" |

### Exercise 14 — the shebang (Stretch)
| Field | |
|---|---|
| **Goal** | The shebang, not the launching shell, picks the interpreter. |
| **Expected end state** | `greet.sh` begins `#!/bin/bash` (or `#!/usr/bin/env bash`), is executable, and runs correctly as `./greet.sh`. |
| **Evidence commands** | `head -1 greet.sh`; `ls -l greet.sh`; `./greet.sh` |
| **Accept** | Either shebang form. Sentence must say the launching shell has no say. |
| **Reject** | `#!/bin/sh` — it does not work here, and shipping it means they did not test. Also reject a correct shebang with no exec bit and no successful run. |
| **Red flags** | File edited but never executed as a program. |
| **Probe question** | "You are sitting in bash. Why isn't that enough?" |

### Exercise 15 — fixing the roster (Stretch)
| Field | |
|---|---|
| **Goal** | Installed and registered are independent conditions. |
| **Expected end state** | `crew-shells-fixed.txt` exists; `maint-old` reassigned to a shell that is both present and listed in `/etc/shells`. |
| **Evidence commands** | `cat crew-shells-fixed.txt`; verify the chosen path exists and appears in `/etc/shells`. |
| **Accept** | `/bin/bash`, `/usr/bin/bash`, `/bin/sh`, `/usr/bin/dash`. Reasons must cover both conditions: unregistered breaks `chsh`; absent breaks the login itself. |
| **Reject** | `/bin/dash` — present but **not** in this machine's `/etc/shells`, so it fails one of the two stated conditions. If they chose it and correctly explained the trade-off, PASS-WITH-NOTES. |
| **Red flags** | Original file modified rather than copied. |
| **Probe question** | "Which of your two conditions does `/bin/dash` fail here?" |

### Exercise 16 — syntax check without running (Dig)
| Field | |
|---|---|
| **Goal** | Parsing and execution are separate phases; a syntax check cannot catch a missing command. |
| **Expected end state** | `bash -n greet.sh` and `sh -n greet.sh` **both** exit 0. Explanation ties back to exercise 9. |
| **Evidence commands** | `bash -n greet.sh; echo $?`; `sh -n greet.sh; echo $?` |
| **Accept** | "`[[` is syntactically a valid command word, so the parse succeeds; the failure only happens at run time when dash looks for a command by that name." |
| **Reject** | Claiming `sh -n` failed. It does not; if they report a failure they did not run it. |
| **Red flags** | Option appears with no man-page access in history. |
| **Probe question** | "Name a script that would pass this check and still fail on every line." |

### Exercise 17 — the type builtin (Dig)
| Field | |
|---|---|
| **Goal** | Names are classified before they are run, and the classification is per-shell. |
| **Expected end state** | In bash: `[[` is a shell keyword, `echo` is a shell builtin, `dash` is a file with a path. In dash: `[[` is reported as not found. |
| **Evidence commands** | `type '[['; type echo; type dash`; then `dash -c 'type "[["'` |
| **Accept** | Any correct four. Sentence must attribute the difference to `[[` being part of bash's grammar and absent from dash's. |
| **Reject** | Using `which` alone and concluding `[[` does not exist. |
| **Red flags** | — |
| **Probe question** | "Why can't `which` find `[[` in either shell?" |

---

## Lesson roll-up

**Load-bearing (must PASS):** 1, 5, 8, 9, 14.
Exercise 9 is the deep one — a student who thinks the dash failure was a syntax error will
misread shell errors for the rest of the course. Exercise 5 is the one that teaches skepticism
about config files, which Chapter 13 relies on.

**Nice to have:** 2, 3, 4, 6, 7, 10, 11, 12, 13, 15.

**Dig (attempts noted, not required):** 16, 17.

Exercise 12 and 16 are both designed so the expected answer is wrong. Do **not** mark a student
down for predicting the intuitive thing; mark them down only for not writing the prediction, or for
reporting an observation they did not make.
