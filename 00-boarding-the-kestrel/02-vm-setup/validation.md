# 00/02 — Validator rubric

Governed by [`docs/VALIDATION_PROTOCOL.md`](../../docs/VALIDATION_PROTOCOL.md).

Evidence: `~/00-02-answers.md` in the VM, the VM's `history`, the VirtualBox snapshot tree
(ask for a screenshot or `VBoxManage snapshot <vm> list` output), and the video.

---

### Exercise 1 — Guest Additions
| Field | |
|---|---|
| **Goal** | Working environment; resizable display and shared clipboard. |
| **Expected end state** | Desktop resolution follows window resize; host→guest paste works. |
| **Evidence commands** | `lsmod \| grep -i vbox`; `systemctl status vboxadd-service` (or ask for a live resize on camera) |
| **Accept** | Working setup by any route, including the ISO-based Guest Additions install rather than apt. |
| **Reject** | Claimed working with no vbox modules loaded. |
| **Red flags** | "It works" with no observable evidence. |
| **Probe question** | "Why does resizing need software installed *inside* the guest?" |

### Exercise 2 — three commands
| Field | |
|---|---|
| **Goal** | Baseline for the container comparison in 00/04. |
| **Expected end state** | Three outputs recorded. |
| **Evidence commands** | `cat ~/00-02-answers.md`; `history \| grep -E 'hostname\|whoami\|df'` |
| **Accept** | Any correct outputs. |
| **Reject** | Outputs that don't match the actual machine. |
| **Red flags** | — |
| **Probe question** | "Which of these three will differ inside the container, and which won't?" |

### Exercise 3 — the canary
| Field | |
|---|---|
| **Goal** | Has felt, not just read, that restore discards later work. |
| **Expected end state** | `~/canary.txt` gone after restore; snapshot `clean-install` exists with a description. |
| **Evidence commands** | `ls -la ~/canary.txt`; `VBoxManage snapshot <vm> list --details` (host) |
| **Accept** | Correct observation and a correct explanation. |
| **Reject** | Answered from theory without performing the restore — check history for the file creation, and the snapshot timestamps. |
| **Red flags** | No `canary.txt` ever created in history; snapshot with an empty description. |
| **Probe question** | "You're on Chapter 9 and restore `clean-install`. What exactly have you lost?" (Must include: all lab work, since `/labs` lives on the VM disk.) |

### Exercise 4 — dynamic disk
| Field | |
|---|---|
| **Goal** | Understands thin provisioning; relevant again in Chapter 14. |
| **Expected end state** | Two numbers and an explanation of the gap. |
| **Evidence commands** | `cat ~/00-02-answers.md`; `df -h /` in the VM |
| **Accept** | Any correct statement that the `.vdi` grows on demand up to the declared maximum. |
| **Reject** | Claiming they're equal, or that the VM "compresses" the disk. |
| **Red flags** | Numbers that don't correspond to the actual machine. |
| **Probe question** | "If you delete 5 GB inside the VM, does the `.vdi` shrink?" (No, not without explicit compaction.) |

### Exercise 5 — recovery plan
| Field | |
|---|---|
| **Goal** | Has a plan before they need one. |
| **Expected end state** | Numbered steps naming a specific snapshot and the loss it implies. |
| **Evidence commands** | `cat ~/00-02-answers.md` |
| **Accept** | Any workable plan. Bonus for saving coursework first, or for repairing in place before restoring. |
| **Reject** | "Reinstall Ubuntu" as step one. |
| **Red flags** | — |
| **Probe question** | "What would you save before restoring, and how?" |

### Exercise 6 — snapshot tree *(Experiment)*
| Field | |
|---|---|
| **Goal** | Correct model of snapshots as a tree with a movable current-state pointer. |
| **Expected end state** | Two written predictions, two observations, a reconciliation. |
| **Evidence commands** | `cat ~/00-02-answers.md`; `VBoxManage snapshot <vm> list` |
| **Accept** | A wrong prediction with a good reconciliation is a full PASS. |
| **Reject** | Prediction written after the fact — check whether the file was edited after the snapshot timestamps (`stat`). |
| **Red flags** | Prediction matches observation exactly with nothing learned. |
| **Probe question** | "Where does the *current state* sit in the tree after restoring `clean-install`?" |

### Exercise 7 — VBoxManage *(Dig)*
| Field | |
|---|---|
| **Goal** | Habit of finding CLI equivalents from built-in help rather than the web. |
| **Expected end state** | Two working commands with output, and cited sources. |
| **Evidence commands** | host `history \| grep VBoxManage` |
| **Accept** | Correct commands found in `VBoxManage --help` or the official manual. |
| **Reject** | Correct commands with no `VBoxManage` help invocation in history and a blog cited. |
| **Red flags** | Straight to a perfect command with no exploration. |
| **Probe question** | "How would you find the subcommand for taking a snapshot, without searching the web?" |

---

## Lesson roll-up

**Load-bearing:** 1, 3, 6. Without a working display/clipboard (1) the course is painful; without
having *seen* a restore discard work (3, 6) a student will eventually lose a chapter of coursework.

**Nice-to-have:** 2, 4, 5, 7.

If exercise 3 is a REDO, do not let them proceed to 00/03. This is the one lesson where the cost of
a misunderstanding is other people's work — their own, weeks from now.
