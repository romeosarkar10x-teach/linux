# 01/04 — Validator rubric

Governed by [`docs/VALIDATION_PROTOCOL.md`](../../docs/VALIDATION_PROTOCOL.md).

Evidence: `~/01-04-answers.md`, `history`, and re-running read-only commands.

Lab: `/labs/01-shell-and-terminal/04-variables/`

**Check the lab is intact:** `report.sh` must be unmodified — exercise 13 says to work on a copy.

---

### Exercise 1 — assign and append
| Field | |
|---|---|
| **Goal** | Braces mark where a name ends. |
| **Expected end state** | `3` then `3plating`. |
| **Evidence commands** | `deck=3; echo "$deck"; echo "${deck}plating"` |
| **Accept** | `${deck}plating`. Also `"$deck"plating` — correct, and worth a nod. |
| **Reject** | Inserting a space; hard-coding `3plating`. |
| **Red flags** | — |
| **Probe question** | "What name did the shell look for when you wrote it without braces?" |

### Exercise 2 — exit status
| Field | |
|---|---|
| **Goal** | `$?` exists and is read immediately. |
| **Expected end state** | A `0` and a non-zero, each read right after its command. |
| **Evidence commands** | `true; echo $?; false; echo $?` |
| **Accept** | Any failing command. |
| **Reject** | A non-zero reading taken more than one command later. |
| **Red flags** | Two identical readings claimed for different commands. |
| **Probe question** | "Does a non-zero value tell you *what* went wrong?" |

### Exercise 3 — home and cwd
| Field | |
|---|---|
| **Goal** | The shell keeps location state in ordinary variables. |
| **Expected end state** | `/home/cadet` and the lab path. |
| **Evidence commands** | `echo "$HOME"; echo "$PWD"` |
| **Accept** | Both variables. |
| **Reject** | Typing the paths literally. |
| **Red flags** | — |
| **Probe question** | "Which of the two changes as you move around?" |

### Exercise 4 — three assignment errors
| Field | |
|---|---|
| **Goal** | Assignment is recognised by word shape; break the shape and it becomes a command. |
| **Expected end state** | `deck = 3` → `bash: deck: command not found`; `deck =3` → the same; `deck= 3` → `bash: 3: command not found`. |
| **Evidence commands** | Re-run all three. |
| **Accept** | Explanation for the third naming that `deck=` was a valid assignment and `3` then became the command word. |
| **Reject** | Calling any of these a syntax error. |
| **Red flags** | Errors quoted that do not match a re-run. |
| **Probe question** | "In the third case, does `deck` end up set? To what?" |

### Exercise 5 — three states
| Field | |
|---|---|
| **Goal** | The central distinction of the lesson. |
| **Expected end state** | Three states demonstrated; identical blank `echo` output for unset and empty; a test that separates them. |
| **Evidence commands** | `unset c; echo "[$c]"; c=; echo "[$c]"; c=red; echo "[$c]"; unset c; echo "${c-UNSET}"; c=; echo "${c-UNSET}"` |
| **Accept** | `${c-d}` versus `${c:-d}`. Also accept `${c+SET}`, or `declare -p c` failing on unset — both are legitimate discriminators. |
| **Reject** | Claiming `echo` distinguishes them. |
| **Red flags** | — |
| **Probe question** | "Name a real setting where blank and absent should mean different things." |

### Exercise 6 — values with spaces
| Field | |
|---|---|
| **Goal** | The value is stored intact; quoting controls what happens after expansion. |
| **Expected end state** | Quoted: `deck 3 bay 2` exactly. Unquoted: same words, runs of whitespace collapsed to single spaces. |
| **Evidence commands** | `n="deck 3 bay 2"; echo "$n"; echo $n` |
| **Accept** | Sentence noting the value itself never changed. |
| **Reject** | Concluding the assignment mangled the value. |
| **Red flags** | Reporting no difference — likely both quoted. With single internal spaces the difference is subtle; if they saw none, have them retry with a value containing doubled spaces. |
| **Probe question** | "Did the variable change, or did what the shell handed to `echo` change?" |

### Exercise 7 — removing a variable
| Field | |
|---|---|
| **Goal** | `unset` deletes the name; `x=` does not. |
| **Expected end state** | Both operations, distinguished by a colon-less default or equivalent. |
| **Evidence commands** | `x=1; unset x; echo "${x-GONE}"; x=; echo "${x-GONE}"` |
| **Accept** | Any correct discriminator. |
| **Reject** | `x=` offered as a way to unset. |
| **Red flags** | — |
| **Probe question** | "Which of the two would `set -u` complain about?" |

### Exercise 8 — reading deck-config
| Field | |
|---|---|
| **Goal** | The right expansion follows from the file's stated contract, not from syntax alone. |
| **Expected end state** | `SAMPLE_INTERVAL` set-with-value; `ALERT_THRESHOLD` set-but-empty; `RETENTION_DAYS` unset. All three read with the **colon** forms, because the file's comment says a blank value means "use the built-in default" — so blank must be treated like absent. |
| **Evidence commands** | `cat deck-config`; read the answers file. |
| **Accept** | Colon forms for all three **with the comment cited as the reason**. Also accept a student who argues for the colon-less form on `ALERT_THRESHOLD` *and* explicitly notes it would contradict the file's comment — that is a reasoned disagreement, PASS-WITH-NOTES. |
| **Reject** | Colon forms chosen with no reference to the comment, or a claim that `ALERT_THRESHOLD` is unset. |
| **Red flags** | Answer identical in shape for all three with no mention of the blank case at all — they did not read the file. |
| **Probe question** | "If the comment had said blank means *no threshold at all*, which form would you switch to?" |

### Exercise 9 — the colon
| Field | |
|---|---|
| **Goal** | One character decides whether empty counts as missing. |
| **Expected end state** | `${ALERT_THRESHOLD:-default}` → `default`; `${ALERT_THRESHOLD-default}` → empty. |
| **Evidence commands** | Re-run both with the variable set to empty. |
| **Accept** | The colon named explicitly. |
| **Reject** | Both forms producing `default` — that means the variable was unset, not empty. |
| **Red flags** | — |
| **Probe question** | "What would both forms do if it were unset?" |

### Exercise 10 — :- versus :=
| Field | |
|---|---|
| **Goal** | Substitution versus substitution-and-assignment. |
| **Expected end state** | After `:-`, the variable is still unset. After `:=`, it holds the default. |
| **Evidence commands** | `unset a; echo "${a:-d}"; echo "${a-STILL_UNSET}"; unset b; echo "${b:=d}"; echo "${b-STILL_UNSET}"` |
| **Accept** | Distinct variable names for the two tests. |
| **Reject** | Reusing one name — the second test is then contaminated and proves nothing. |
| **Red flags** | — |
| **Probe question** | "Why would a script prefer the non-assigning one?" |

### Exercise 11 — fail if unset
| Field | |
|---|---|
| **Goal** | Loud early failure over silent empty expansion. |
| **Expected end state** | An error naming the variable, a non-zero status, then success once set. |
| **Evidence commands** | `( echo "${nope:?not configured}" ); echo $?` |
| **Accept** | Run in a subshell or in a non-interactive shell. Message text is the student's own. |
| **Reject** | Reporting the exit status without measuring it. |
| **Red flags** | — |
| **Probe question** | "Where in a script would you put these?" |

### Exercise 12 — reading report.sh (Experiment)
| Field | |
|---|---|
| **Goal** | An unset name expands to nothing, silently. |
| **Expected end state** | Predictions written first. Actual: `label:  3bay`, `padded:` followed by nothing, `title:  deck 3 bay 2`. Explanation identifies `$labelplate` as a lookup of a name that does not exist. |
| **Evidence commands** | `./report.sh` |
| **Accept** | Wrong prediction with correct explanation is a full pass. |
| **Reject** | No prediction. Also reject "the script has a typo" with no identification of the actual name looked up. |
| **Red flags** | `report.sh` modified. |
| **Probe question** | "Did the script fail? What was its exit status?" |

### Exercise 13 — unquoted assignment (Experiment)
| Field | |
|---|---|
| **Goal** | Connects the assignment-shape rule to a realistic edit. |
| **Expected end state** | Prediction with reasoning. Observed: `3: command not found`, and `title` ends up holding `deck`. |
| **Evidence commands** | Re-run on a copy. |
| **Accept** | Predicting a syntax error and then explaining the real result correctly — full pass. |
| **Reject** | No reasoning with the prediction. Modifying `report.sh` itself. |
| **Red flags** | `report.sh` no longer matches the seeded version — check with `kestrel reset` if unsure. |
| **Probe question** | "What is `title` set to after that line runs?" |

### Exercise 14 — reading `$?` twice (Experiment)
| Field | |
|---|---|
| **Goal** | `$?` is overwritten by every command, including the one reading it. |
| **Expected end state** | Predictions written. Actual: `2`, then `0`. |
| **Evidence commands** | `ls /nonexistent; echo $?; echo $?` |
| **Accept** | Explanation naming the first `echo` as the command the second reading describes. |
| **Reject** | No prediction. |
| **Red flags** | — |
| **Probe question** | "How would you keep the value around to use twice?" |

### Exercise 15 — is unset a program (Stretch)
| Field | |
|---|---|
| **Goal** | Same reasoning as `cd`: it must run in the shell itself. |
| **Expected end state** | Classified as a builtin, with the reason. |
| **Evidence commands** | `type unset` |
| **Accept** | Reason citing that a child process cannot modify its parent's variables. |
| **Reject** | Classification with no reasoning. |
| **Red flags** | — |
| **Probe question** | "Name two other builtins that exist for the same reason." |

### Exercise 16 — three labelled values (Stretch)
| Field | |
|---|---|
| **Goal** | Braces where required, and only where required. |
| **Expected end state** | One line, three labelled values, readable. |
| **Evidence commands** | Re-run their line. |
| **Accept** | Any punctuation that keeps it readable. Bracing everything is acceptable. |
| **Reject** | Output where a value has run into a following letter. |
| **Red flags** | — |
| **Probe question** | "Which of your three expansions genuinely needed the braces?" |

### Exercise 17 — EDITOR fallback (Stretch)
| Field | |
|---|---|
| **Goal** | Mechanics plus a judgement about what empty should mean. |
| **Expected end state** | `${EDITOR:-nano}` → `nano` in both cases (unset and empty); a stated judgement with a reason. |
| **Evidence commands** | `unset EDITOR; echo "${EDITOR:-nano}"; EDITOR=; echo "${EDITOR:-nano}"` |
| **Accept** | **Either** judgement, if reasoned. "Treat empty as unset, nobody sets an editor to nothing on purpose" and "respect empty, the user may mean no editor" are both good answers. |
| **Reject** | Mechanics only, no judgement. That is the graded half. |
| **Red flags** | Claiming the two runs differed — they do not with the colon form. |
| **Probe question** | "Which form would you use for `PAGER`, and would your answer change?" |

### Exercise 18 — length (Dig)
| Field | |
|---|---|
| **Goal** | Finds parameter expansion in `man bash`. |
| **Expected end state** | `${#name}`; e.g. `12` for `deck 3 bay 2`; `0` for an unset name. |
| **Evidence commands** | `n="deck 3 bay 2"; echo "${#n}"; unset z; echo "${#z}"` |
| **Accept** | Sentence noting the unset case yields `0` — indistinguishable from an empty value, so it is not an existence test. |
| **Reject** | Concluding the length expansion can tell unset from empty. |
| **Red flags** | No man-page access in history. |
| **Probe question** | "Could you use this to check whether a variable is set?" |

### Exercise 19 — the `:+` form (Dig)
| Field | |
|---|---|
| **Goal** | The mirror form, plus the newline distinction. |
| **Expected end state** | `printf '%s' "${SAMPLE_INTERVAL:+interval is set}"` — output when set, **zero bytes** when not. Evidence that no newline was emitted. |
| **Evidence commands** | `unset SAMPLE_INTERVAL; printf '%s' "${SAMPLE_INTERVAL:+interval is set}" \| od -c` |
| **Accept** | `od -c`, `xxd`, `wc -c`, or piping into something that shows byte counts. |
| **Reject** | Using `echo` and claiming nothing was printed — `echo ""` emits a newline. This is the exercise. |
| **Red flags** | Claimed zero bytes with no byte-level evidence. |
| **Probe question** | "How many bytes did `echo` emit in the 'nothing' case?" |

### Exercise 20 — the strict option (Dig)
| Field | |
|---|---|
| **Goal** | `set -u`, and why the default-value forms are exempt. |
| **Expected end state** | `( set -u; echo "$nope" )` → `bash: nope: unbound variable`. `( set -u; echo "${nope:-d}" )` → `d`. |
| **Evidence commands** | Re-run both subshells. |
| **Accept** | Sentence noting that without the exemption you could not write optional settings at all. |
| **Reject** | Setting it in the interactive shell and having to restart — accept it but note it, since the exercise said to use a subshell. |
| **Red flags** | Reporting a failure for the fallback form — it does not fail. |
| **Probe question** | "Does this catch a *misspelled* variable name?" |

---

## Lesson roll-up

**Load-bearing (must PASS):** 4, 5, 9, 12, 14.
Exercise 5 and 9 are the pair that matter: a student who cannot separate unset from empty will write
configuration handling that fails in production and nowhere else. Exercise 12 is the silent-failure
lesson, which pairs with 01/03 exercise 7.

**Nice to have:** 1, 2, 3, 6, 7, 8, 10, 11, 13, 15, 16, 17.

**Dig (attempts noted, not required):** 18, 19, 20.

Exercise 17 is graded on the **judgement**, not the syntax. Both defensible answers are full passes.
Exercise 8 likewise: the reasoning about the file's comment is the deliverable.
