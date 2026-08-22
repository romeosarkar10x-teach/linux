# 00/04 — Validator rubric

Governed by [`docs/VALIDATION_PROTOCOL.md`](../../docs/VALIDATION_PROTOCOL.md).

Evidence: the container's filesystem, `history` inside the container, the VM's `history` for
`kestrel`/`docker` commands, and `~/00-04-answers.md`.

Lab: `/labs/00-boarding-the-kestrel/04-course-container/`

---

### Exercise 1 — build and enter
| Field | |
|---|---|
| **Goal** | Working container. Everything else depends on it. |
| **Expected end state** | `hostname` → `kestrel`, `whoami` → `cadet`. |
| **Evidence commands** | `docker ps`; inside: `hostname; whoami; id` |
| **Accept** | Working container. |
| **Reject** | Running as root inside (they bypassed the helper with their own `docker run -u root`). |
| **Red flags** | — |
| **Probe question** | "Why does `kestrel` have to run in the VM rather than in the container?" |

### Exercise 2 — seed and jump
| Field | |
|---|---|
| **Goal** | Can seed a lab and navigate to it. |
| **Expected end state** | Lab dir exists and is populated. |
| **Evidence commands** | `ls -la /labs/00-boarding-the-kestrel/04-course-container/` |
| **Accept** | Used `lab 00/04` or `cd` to the full path. |
| **Reject** | Lab created by hand with `mkdir` instead of seeded — then the flag file won't exist. |
| **Red flags** | — |
| **Probe question** | "What creates that directory?" |

### Exercise 3 — three places
| Field | |
|---|---|
| **Goal** | Knows `/course` is read-only and can read an error message to find out why. |
| **Expected end state** | Two successes, one failure with the error recorded. |
| **Evidence commands** | `mount \| grep course`; `cat ~/00-04-answers.md`; `history \| grep course` |
| **Accept** | Any explanation identifying a read-only mount. |
| **Reject** | Attributing it to file permissions or to being the wrong user. |
| **Red flags** | No attempt in history. |
| **Probe question** | "Would `sudo` help? Why not?" (It wouldn't — the mount is read-only.) |

### Exercise 4 — the crew
| Field | |
|---|---|
| **Goal** | Can find information they haven't been taught to find. Preview of Chapter 10. |
| **Expected end state** | `rhea`, `cass`, `dorn`, `ops-bot`, `cadet` listed with groups; `ops-bot` identified as unable to log in. |
| **Evidence commands** | `history \| grep -E 'passwd\|group\|getent\|home'`; `cat ~/00-04-answers.md` |
| **Accept** | Any discovery route — `/etc/passwd`, `getent`, `ls /home`, `man 5 passwd`. Method stated. |
| **Reject** | A list with no stated method, especially if it matches the notes exactly — the notes name the accounts, so the *finding* is the exercise. |
| **Red flags** | Names copied from the readme with no commands in history. |
| **Probe question** | "How did you tell `ops-bot` apart from the others? What field?" |

### Exercise 5 — persistence
| Field | |
|---|---|
| **Goal** | Knows what a volume protects and what it doesn't. Prevents real data loss later. |
| **Expected end state** | Both files survive stop/start; correct reasoning that only `/labs` survives container recreation. |
| **Evidence commands** | `docker volume ls`; `ls -la` in both locations; VM `history \| grep kestrel` |
| **Accept** | Correct reasoning about the volume vs the container's writable layer. |
| **Reject** | Claiming `/home/cadet` survives container deletion. Correct it — this one costs them transcripts later. |
| **Red flags** | No stop/start in the VM's history. |
| **Probe question** | "You rebuild the image next week. What do you lose?" |

### Exercise 6 — missing tools
| Field | |
|---|---|
| **Goal** | Confirms the Chapter 13 setup is intact, and hasn't spoiled it. |
| **Expected end state** | Two tools confirmed absent. Still absent. |
| **Evidence commands** | `command -v ncdu rg tldr`; `history \| grep -E 'apt install'` |
| **Accept** | Any check: running it, `command -v`, `which`, `dpkg -l`. |
| **Reject** | **Installed them.** REDO the setup: `sudo apt remove` and leave them alone. Note it for Chapter 13. |
| **Red flags** | `apt install` in history for any of the reserved tools. |
| **Probe question** | "Could a program be installed and still give you 'command not found'?" (Yes — not on PATH. 11/02.) |

### Exercise 7 — reset scope *(Experiment)*
| Field | |
|---|---|
| **Goal** | Correct model of reset's blast radius. Directly prevents lost work. |
| **Expected end state** | Four predictions, four observations, reconciliation. Lab reset; home file and the other lab intact; flag still captured. |
| **Evidence commands** | VM `history \| grep 'kestrel reset'`; `ls -la /labs/*/*/`; `kestrel flags` |
| **Accept** | Wrong predictions with honest reconciliation are a full PASS. |
| **Reject** | No `kestrel reset` in VM history — answered from the notes. |
| **Red flags** | Predictions matching perfectly with nothing learned. |
| **Probe question** | "You're mid-Chapter-9 and reset 09/07. What have you lost, and what have you kept?" |

### Exercise 8 — /labs vs / *(Stretch)*
| Field | |
|---|---|
| **Goal** | Connects volumes to what `df` shows. |
| **Expected end state** | Outputs plus an explanation that `/labs` is a separate mount. |
| **Evidence commands** | `df -h / /labs /course`; `mount \| grep -E 'labs\|course'` |
| **Accept** | Recognising `/labs` as a distinct mount/device even where sizes match. |
| **Reject** | "They're the same because the numbers match." |
| **Red flags** | — |
| **Probe question** | "Why do `/` and `/labs` show the same size?" (Same underlying VM disk.) |

### Exercise 9 — docker exec *(Dig)*
| Field | |
|---|---|
| **Goal** | Found a subcommand's syntax from built-in help. |
| **Expected end state** | A working one-shot exec, output recorded, source cited. |
| **Evidence commands** | VM `history \| grep -E 'docker (exec\|help)'` |
| **Accept** | Any correct exec form. `uptime` is the natural command; `cat /proc/uptime` also fine and arguably better. |
| **Reject** | Correct command with no help invocation in history. |
| **Red flags** | Perfect first try with no exploration — probe. |
| **Probe question** | "Why does adding `-it` to a non-interactive command sometimes hang?" |

### Exercise 10 — the flag *(Flag)*
| Field | |
|---|---|
| **Goal** | The whole chain works: container, seeding, discovery, submission. |
| **Expected end state** | `kestrel flags` shows `00/04 captured`. |
| **Evidence commands** | `kestrel flags`; container `history \| grep -E 'cat\|ls\|less'` |
| **Accept** | Any reading method. |
| **Reject** | Nothing to reject — this one is meant to be easy. |
| **Red flags** | Captured with no `ls` or read commands in history at all. |
| **Probe question** | "Why single quotes around the flag when you submit it?" |

---

## Lesson roll-up

**Load-bearing:** 1, 5, 7. Without a working container (1) nothing proceeds; 5 and 7 are the two
exercises that stop a student destroying weeks of their own work later.

**Nice-to-have:** 2, 3, 4, 6, 8, 9, 10.

Special case: if exercise 6 shows they installed the reserved tools, that isn't a failure of
understanding, but fix it now — uninstall, and flag it so Chapter 13 still works.
