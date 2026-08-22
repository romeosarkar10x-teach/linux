# 00/03 — Validator rubric

Governed by [`docs/VALIDATION_PROTOCOL.md`](../../docs/VALIDATION_PROTOCOL.md).

Evidence: `~/00-03-answers.md`, the VM's `history`, and live `docker` output.

---

### Exercise 1 — install
| Field | |
|---|---|
| **Goal** | Working Docker Engine from Docker's own repository. |
| **Expected end state** | `docker --version` works; `/etc/apt/sources.list.d/docker.list` exists. |
| **Evidence commands** | `docker --version`; `cat /etc/apt/sources.list.d/docker.list`; `apt policy docker-ce` |
| **Accept** | Any install from Docker's repo. |
| **Reject** | `docker.io` from Ubuntu's repo — the exercise is the repository setup, not just having docker. |
| **Red flags** | — |
| **Probe question** | "What is the `signed-by=` part of that sources line doing?" |

### Exercise 2 — the docker group
| Field | |
|---|---|
| **Goal** | Understands that credentials are fixed at login. Recurs in 10/02. |
| **Expected end state** | `id` includes `docker`; `docker ps` works without `sudo`. |
| **Evidence commands** | `id`; `getent group docker`; `history \| grep usermod` |
| **Accept** | Working, by `usermod -aG` or `gpasswd -a`. |
| **Reject** | Achieved by `chmod 666 /var/run/docker.sock`, or by aliasing `docker` to `sudo docker`. Both "work" and both miss the lesson — REDO. |
| **Red flags** | History shows repeated `newgrp` attempts and no logout — probe whether they understand *why* it worked. |
| **Probe question** | "Why isn't a new terminal window enough?" Must reference credentials being copied at session creation. |

### Exercise 3 — counts
| Field | |
|---|---|
| **Goal** | Image vs container distinction. |
| **Expected end state** | Two counts plus an explanation. |
| **Evidence commands** | `docker ps -a`; `docker images` |
| **Accept** | Counts matching their actual machine, with a correct template-vs-instance explanation. |
| **Reject** | Explanation that conflates the two. |
| **Red flags** | Counts that don't match live output. |
| **Probe question** | "You run `hello-world` ten more times. How many images do you have?" |

### Exercise 4 — the four steps
| Field | |
|---|---|
| **Goal** | Reads output instead of skipping it. |
| **Expected end state** | Four steps in their own words; correctly identifies the pull as skipped once cached. |
| **Evidence commands** | `cat ~/00-03-answers.md` |
| **Accept** | Any faithful paraphrase. |
| **Reject** | Verbatim copy of the message — ask them to explain step 2 in other words. |
| **Red flags** | — |
| **Probe question** | "Which of those four steps touches the network, and how do you know?" |

### Exercise 5 — cleanup
| Field | |
|---|---|
| **Goal** | Container lifecycle; `rm` vs `rmi`. |
| **Expected end state** | Stopped containers removed, image retained, a disk figure recorded. |
| **Evidence commands** | `docker ps -a`; `docker images`; `docker system df` |
| **Accept** | Any removal route, including `docker container prune`. |
| **Reject** | Removed the image too — they didn't distinguish the two. |
| **Red flags** | — |
| **Probe question** | "What's the difference between `docker rm` and `docker rmi`?" |

### Exercise 6 — namespaces *(Experiment)*
| Field | |
|---|---|
| **Goal** | Correct model: containers are isolated by namespaces, not by a separate kernel. |
| **Expected end state** | Three written predictions, three outputs, and a paragraph on the `ps aux` result. |
| **Evidence commands** | `cat ~/00-03-answers.md`; `history \| grep 'docker run'` |
| **Accept** | Wrong predictions with good reconciliation are a full PASS. The key realisation is that the container's `ps` shows only its own processes. |
| **Reject** | Prediction written after observation — check `stat` on the answers file against history timestamps. |
| **Red flags** | Three flawless predictions and nothing learned; probe hard. |
| **Probe question** | "The container shares your VM's kernel. So why can't its `ps` see your VM's processes?" |

### Exercise 7 — comparison *(Stretch)*
| Field | |
|---|---|
| **Goal** | Connects 00/02 baseline to container isolation; notices `df` is the odd one out. |
| **Expected end state** | Comparison table with an explanation per row. |
| **Evidence commands** | `cat ~/00-03-answers.md`; `cat ~/00-02-answers.md` |
| **Accept** | Recognising hostname and user changed while the disk is the VM's, seen through the container's mount namespace. |
| **Reject** | Claiming the container has its own physical disk. |
| **Red flags** | No 00/02 answers file to compare against. |
| **Probe question** | "If you fill the container's disk, what runs out?" |

### Exercise 8 — run flags *(Dig)*
| Field | |
|---|---|
| **Goal** | Finds flags in built-in help; understands `-i` and `-t` are separate concerns. |
| **Expected end state** | Both flags explained; a working interactive throwaway shell. |
| **Evidence commands** | `history \| grep -E 'docker (run\|help)'` |
| **Accept** | Correct flags with a real explanation of each. Extra credit for explaining what `-t` alone does. |
| **Reject** | Correct command with no help/doc invocation in history. |
| **Red flags** | Straight to `-it --rm` with no exploration — probe whether they can say what each letter does. |
| **Probe question** | "What breaks if you use only one of the two interactive flags?" |

---

## Lesson roll-up

**Load-bearing:** 2, 6. Exercise 2's *reason* (not just its outcome) is directly re-tested in
10/02; exercise 6 is the mental model the rest of the course's container work rests on.

**Nice-to-have:** 1, 3, 4, 5, 7, 8.

Watch for exercise 2 solved by loosening socket permissions. It's a real security mistake and a
teachable one — REDO, and ask what the permissions on that socket are protecting.
