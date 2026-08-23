# 02/04 — Validator rubric

Read `docs/VALIDATION_PROTOCOL.md` first. Written answers live in
`/labs/02-navigating-the-filesystem/04-proc-and-sys/answers.md`.

**Container-specific facts this rubric depends on** (verified against the image; re-check if the
image changes):

- `/etc/os-release` → `PRETTY_NAME="Ubuntu 24.04.4 LTS"`; `/proc/version` → `Linux version
  7.0.13-arch1-1 ... (linux@archlinux)`. The host is Arch; the container is Ubuntu.
- `/sys/devices/system/cpu/online` → `0-23`, i.e. 24 CPUs.
- `/proc/meminfo` `MemTotal` is in **kB**, ~31933460 kB.
- `ls -l /proc/cpuinfo` → size `0`; `wc -l /proc/cpuinfo` → `672`.
- PID 1 is `sleep infinity`; `/proc/1/comm` is `sleep`; `/proc/1/exe` points into the Nix store at a
  **coreutils** multicall binary, not at a `sleep` binary.
- `waiter.sh`'s `/proc/<pid>/exe` → `/usr/bin/bash`; its `cmdline` is `bash\0./waiter.sh\0deck-3\0`.
- `/proc/mounts` has 27 lines; `df` reports 5 filesystems. `/proc/sys` is mounted `ro`.
- `/proc/cmdline` → `root=UUID=03a6f6d4-... resume=UUID=08448299-... rw iommu=pt
  initrd=\initramfs-linux.img`.
- Open-files limit: soft `1024`, hard `524288`. `man ulimit` resolves to `ulimit(3)`, not the bash
  builtin.
- `/proc/self/comm` is mode `-rw-r--r--` (writable by its owner); most other `/proc` files are `r--`.

Because much of this lesson is read-only inspection, history is the primary evidence. A student who
produces correct values with no `/proc` reads in their history did not do the exercise.

---

### Exercise 1
| Field | Value |
|---|---|
| Goal | See that `/proc` holds two populations: numbered per-process directories and named global files |
| Expected end state | A one-line description naming both kinds |
| Evidence commands | `history` for an `ls /proc` |
| Accept | Any wording that distinguishes "one directory per running process, named by PID" from "system-wide files" |
| Reject | "Lots of files" with no distinction; naming only one population |
| Red flags | No `ls /proc` in history |
| Probe | "Pick a number you saw. What would make it disappear?" |

### Exercise 2
| Field | Value |
|---|---|
| Goal | Read two global `/proc` files by name |
| Expected end state | The kernel version string and an uptime in seconds |
| Evidence commands | `history` for reads of `/proc/version` and `/proc/uptime` |
| Accept | `cat`, `head`, `less` — any reader. Reporting the first of `/proc/uptime`'s two numbers |
| Reject | `uname -a` or `uptime(1)` as the *only* route — the exercise says from `/proc` |
| Red flags | Uptime reported in hours with no arithmetic shown |
| Probe | "There are two numbers in the uptime file. What is the second?" (idle time, summed across CPUs — it may exceed the first) |

### Exercise 3
| Field | Value |
|---|---|
| Goal | Use `/proc/self` |
| Expected end state | Output is the name of the reading program (`cat`, `head`, …), not `bash` |
| Evidence commands | `history` |
| Accept | Reading `/proc/self/comm` |
| Reject | Reading `comm` for a hard-coded PID; answering `bash` without noticing the reader is a different process |
| Red flags | Answer given as `bash` — that means they did not run it |
| Probe | "Why is the answer not `bash`?" |

### Exercise 4
| Field | Value |
|---|---|
| Goal | Find the same fact through both pseudo-filesystems |
| Expected end state | **24**, with two paths: `/proc/cpuinfo` and something under `/sys/devices/system/cpu/` |
| Evidence commands | `history`; `cat /sys/devices/system/cpu/online` → `0-23` |
| Accept | Counting `processor` (or `model name`, or `core id`) blocks in `cpuinfo`; `online`, `possible`, `present`, or counting `cpu0..cpu23` directories |
| Reject | Answering `0-23` as if it were the count; a single source when two were asked for; `nproc` alone |
| Red flags | 24 quoted with no path |
| Probe | "Which of your two sources would still be right if a CPU were taken offline?" |

### Exercise 5
| Field | Value |
|---|---|
| Goal | Read the unit, not assume it |
| Expected end state | ~31933460 **kB** ≈ 30.5 GiB, with the unit stated |
| Evidence commands | `head -1 /proc/meminfo` |
| Accept | kB stated explicitly; any correct conversion |
| Reject | "32 million bytes"; unit omitted |
| Red flags | A tidy "32 GB" with no reference to the file's own number |
| Probe | "What would you have concluded if you had assumed bytes?" |

### Exercise 6
| Field | Value |
|---|---|
| Goal | Treat `/proc` and `/sys` as a source you can cite |
| Expected end state | Three facts in `answers.md`, **each with the exact path** |
| Evidence commands | `cat answers.md`; cross-check each path exists and its content supports the claim |
| Accept | Any three genuine facts (CPU count, memory, uptime, load, mounts, kernel version, MTU, CPU model…) so long as path and claim match |
| Reject | Facts with no path; a path that does not contain the claimed fact; facts obtainable from `ls`/`cd` (file names, directory sizes) |
| Red flags | All three from one file — permitted but probe whether they explored |
| Probe | "Read me the line your second fact came from." |
| **Load-bearing** | yes |

### Exercise 7
| Field | Value |
|---|---|
| Goal | Use `man 5 proc` as a reference, and search inside a long page |
| Expected end state | Fields 1–3: load averages over 1, 5, 15 minutes. Field 4: runnable-or-running entities / total entities. Field 5: the most recently created PID |
| Evidence commands | `history` for `man 5 proc` and a `/proc/loadavg` read |
| Accept | Correct on all five, however worded ("kernel scheduling entities" ≈ "processes and threads" is fine) |
| Reject | Field 4 called "CPU usage" or "percentage"; field 5 called "number of processes" |
| Red flags | Perfectly worded man-page phrasing with no `man` in history — probe |
| Probe | "How did you find the loadavg paragraph in that page?" |
| **Load-bearing** | yes |

### Exercise 8
| Field | Value |
|---|---|
| Goal | Understand PID 1, and that a container's PID 1 is whatever it was told to run |
| Expected end state | PID 1 is `sleep infinity`; `comm` is `sleep`; contrast drawn with an init system on the VM |
| Evidence commands | `cat /proc/1/cmdline`, `cat /proc/1/comm` in history |
| Accept | Naming `sleep infinity` from the file; explaining that the container is started to run one command and that command becomes PID 1; saying the container exits if it dies |
| Reject | "systemd" (recalled, not read); claiming the container has no PID 1 |
| Red flags | Answer matches the VM rather than the container — they read the wrong `/proc` |
| Probe | "What would `kill 1` do here?" |

### Exercise 9
| Field | Value |
|---|---|
| Goal | Map a PID to its directory |
| Expected end state | A listing of `/proc/<pid>` for their own `waiter.sh` |
| Evidence commands | `history` |
| Accept | Any listing form |
| Reject | Listing `/proc/self` and calling it the waiter |
| Red flags | PID appears in history before `waiter.sh` was ever started |
| Probe | "Where did that number come from?" |

### Exercise 10
| Field | Value |
|---|---|
| Goal | Read the `cwd` and `exe` symlinks; understand that a script's process runs an interpreter |
| Expected end state | `cwd` → the lab dir; `exe` → `/usr/bin/bash`, **not** `waiter.sh` |
| Evidence commands | `ls -l /proc/<pid>/cwd /proc/<pid>/exe` |
| Accept | Explaining that the kernel executes `bash`, which interprets the script, via the shebang line |
| Reject | "The link is broken"; claiming `exe` should say `waiter.sh`; not noticing the surprise at all |
| Red flags | `readlink`/`ls -l` never run |
| Probe | "If you had written the script in C and compiled it, what would `exe` say?" |
| **Load-bearing** | yes |

### Exercise 11
| Field | Value |
|---|---|
| Goal | The NUL-separated `cmdline` |
| Expected end state | Output runs together (`bash./waiter.shdeck-3`); explanation names an invisible separator between arguments |
| Evidence commands | `cat /proc/<pid>/cmdline` |
| Accept | "Arguments are stored as a list, separated by a non-printing byte, so the terminal shows them joined." Naming NUL is a bonus, not required. Some terminals render NUL as a space — accept that observation too, provided they do not conclude the separator *is* a space |
| Reject | "The spaces were removed/stripped"; "the file is corrupt" |
| Red flags | A cleanly spaced answer — that means they used `ps`, not the file |
| Probe | "Why not separate them with spaces?" (a filename may legally contain a space) |
| Notes | `tr`/`xargs` are Chapter 7. If they found one anyway, accept and note it — do not require it |

### Exercise 12
| Field | Value |
|---|---|
| Goal | Read fields out of `status` |
| Expected end state | `State: S (sleeping)`, a `PPid` matching their shell, `Threads: 1` |
| Evidence commands | `cat /proc/<pid>/status` |
| Accept | The three values; `PPid` verified against their shell's PID is a bonus |
| Reject | Values invented; `Threads` reported from `Tgid` |
| Red flags | State reported as "running" — it is sleeping in `sleep 900` |
| Probe | "Whose PID is `PPid`?" |

### Exercise 13
| Field | Value |
|---|---|
| Goal | See standard descriptors as symlinks |
| Expected end state | 0, 1, 2 identified. In an interactive shell all three point at a `/dev/pts/N`; if they ran it non-interactively they may be `/dev/null` and pipes — both are correct findings |
| Evidence commands | `ls -l /proc/<pid>/fd` |
| Accept | Naming input/output/error and reporting the actual targets they saw. Noticing fd 255 (bash's copy of the script) is a bonus |
| Reject | Reporting `/dev/pts/N` when their transcript shows a pipe, or vice versa — the answer must match their own run |
| Red flags | `Permission denied` unmentioned — `fd/` is owner-only, so it means they inspected someone else's process |
| Probe | "Which of the three would change if you redirected the script's output to a file?" |

### Exercise 14
| Field | Value |
|---|---|
| Goal | Process directories are not records |
| Expected end state | The exact error, e.g. `ls: cannot access '/proc/1390': No such file or directory` |
| Evidence commands | `history` shows `kill` then the failed `ls` |
| Accept | Any exact quotation of the error; explanation that the directory existed only while the process did |
| Reject | Paraphrase only; claiming the directory is "empty now" |
| Red flags | The error quoted but no `kill` in history |
| Probe | "Where would you look to find out what that process did, after it exited?" (nowhere in `/proc` — that is the point) |

### Exercise 15
| Field | Value |
|---|---|
| Goal | Observe the disagreement before explaining it |
| Expected end state | Both strings recorded verbatim in `answers.md`: Ubuntu 24.04 and a `...-arch1-...` kernel |
| Evidence commands | `cat answers.md` |
| Accept | Both quoted accurately |
| Reject | Only one recorded; either paraphrased into "Linux" |
| Red flags | Version numbers that do not match the image |
| Probe | "Which of the two would change if I rebuilt this image from Debian?" |

### Exercise 16
| Field | Value |
|---|---|
| Goal | The container shares the host kernel |
| Expected end state | Three lines: `/etc` is userland shipped by the image; `/proc/version` is the running kernel; a container does not have its own kernel, so it reports the host's. Plus a second file with a give-away quoted |
| Evidence commands | `cat answers.md`; check the named second file really contains what they quoted |
| Accept as the second evidence | `/proc/cmdline` (host disk UUIDs, `initrd=\initramfs-linux.img`); `/proc/meminfo` or `/proc/cpuinfo` (host-wide totals, 24 CPUs, ~30 GiB); `/proc/uptime` (older than the container); `/proc/loadavg` (host-wide, and its last-PID field far exceeds anything in this container); `/proc/mounts` host device names |
| Reject | "One of the files is wrong/lying"; "Docker patches `/proc`"; a second file named with nothing quoted from it; only restating exercise 15 |
| Red flags | A fluent kernel-sharing explanation with no second file — the second file is what proves they looked |
| Probe | "Your container started minutes ago. Read me `/proc/uptime` and tell me whose uptime that is." |
| **Load-bearing** | yes |

### Exercise 17 — Experiment
| Field | Value |
|---|---|
| Goal | Files whose contents are generated at read time |
| Expected end state | A **written prediction**, then: `ls -l /proc/cpuinfo` size `0`; `wc -l` `672`; `/proc/self/comm` size `0` yet readable; `cat /proc/self/cmdline` prints its own arguments run together |
| Evidence commands | `cat answers.md` or the transcript for the prediction; `history` for the five commands |
| Accept | An explanation that `ls` asks the filesystem for recorded metadata while `cat` asks it to produce content, and that procfs has nothing recorded because nothing is stored — the text is manufactured per read. The fifth line explained separately as the NUL separator, not as another size effect |
| Reject | "The file is empty"; "procfs is broken"; conflating the two phenomena; missing prediction ⇒ **cap at PASS-WITH-NOTES** even if the explanation is perfect |
| Red flags | Prediction that exactly matches the surprising result — probe whether it was written after running |
| Probe | "How much work would it be for the kernel to report a true size here?" (it would have to generate the whole file on every `stat`) |
| **Load-bearing** | yes |

### Exercise 18 — Experiment
| Field | Value |
|---|---|
| Goal | `self` resolves per-reader |
| Expected end state | A written prediction; two `ls -ld /proc/self` runs showing **different** PIDs; `comm` reporting `cat` |
| Evidence commands | transcript; `history` |
| Accept | "Each command is a new process; `self` is resolved for whoever is reading, so the second `ls` is a different process with a different PID." Noting the numbers are close but not always consecutive is a bonus |
| Reject | "The PID incremented because time passed"; expecting the shell's PID; missing prediction ⇒ cap at PASS-WITH-NOTES |
| Red flags | Identical PIDs reported — impossible for two separate commands; means fabricated |
| Probe | "What PID would you get if bash itself read the file with a redirect instead of running `cat`?" (bash's own) |

### Exercise 19
| Field | Value |
|---|---|
| Goal | Feel the cost of a linear scan, and earn Chapter 6 |
| Expected end state | The correct PID found; a count of directories opened; a statement about why recursive search tools exist |
| Evidence commands | `history` — expect many `cat /proc/<n>/cmdline` lines |
| Accept | Any by-hand approach: reading each numbered directory, or narrowing to high PIDs first (a legitimate heuristic — new processes get large numbers) and saying so |
| Reject | `ps`, `pgrep`, `grep`, `find` — all out of scope here; a count with no evidence of the reads in history |
| Red flags | One `cat` in history and a confident PID — they used `jobs` or `ps` and did not say |
| Probe | "How would this scale to 4000 processes?" (the host has ~3900 — see `/proc/loadavg` field 4) |

### Exercise 20
| Field | Value |
|---|---|
| Goal | Connect the size-zero surprise to a future tool |
| Expected end state | Two lines in `answers.md`: a size-based search will not report `/proc/cpuinfo` as large, because its recorded size is 0; and that this is correct/unavoidable behaviour for the tool, not a bug |
| Evidence commands | `cat answers.md` |
| Accept | Either "correct — the tool can only use the recorded size" or "correct but misleading, and this is why you exclude `/proc` from filesystem-wide searches". Both are good answers |
| Reject | "The search tool is broken"; claiming the file would be found |
| Red flags | Answer contradicts their own exercise 17 finding |
| Probe | "Should a search tool descend into `/proc` at all?" |

### Exercise 21
| Field | Value |
|---|---|
| Goal | A mount table is not a space report |
| Expected end state | One filesystem named that appears in `/proc/mounts` but not in `df`, with an explanation |
| Evidence commands | `cat /proc/mounts` (27 lines); `df` (5 filesystems) |
| Accept | Naming any pseudo/bind mount — `proc`, `sysfs`, `cgroup`, `devpts`, `mqueue`, the `ro` re-mounts of `/proc/bus` etc. — and explaining that `df` omits filesystems with no meaningful capacity, or collapses duplicates. Also accept the reverse direction if argued (`/dev` and `/labs` appearing distinctly) |
| Reject | "The two outputs contradict each other"; a filesystem named that actually appears in both |
| Red flags | Both commands absent from history |
| Probe | "What size would `df` print for `proc`?" |

### Exercise 22 — Dig
| Field | Value |
|---|---|
| Goal | Distinguish a permission refusal from a mount-option refusal |
| Expected end state | Exact error `bash: /proc/sys/...: Read-only file system`; identification of the `ro` mount option on `/proc/sys` in `/proc/mounts` |
| Evidence commands | `history`; `grep "/proc/sys" /proc/mounts` → `proc /proc/sys proc ro,nosuid,nodev,noexec,relatime 0 0` |
| Accept | Naming the mount option as the cause, and saying `sudo` would not help. Noting that the *shell* produced this error before any program ran is a bonus |
| Reject | "Because I am not root" as the sole answer; quoting `Permission denied` (they did not get that error); no mount evidence |
| Red flags | Claim without ever reading `/proc/mounts` |
| Probe | "What error would you expect if permissions were the reason?" |
| **Load-bearing** | yes |

### Exercise 23 — Dig
| Field | Value |
|---|---|
| Goal | Resource limits, and that shell builtins are documented by the shell |
| Expected end state | `Max open files 1024 (soft) / 524288 (hard)`; the builtin identified as `ulimit`, with the flag for open files and the flag for the hard value |
| Evidence commands | `history` for `help ulimit`; `cat /proc/self/limits` |
| Accept | Both numbers; `ulimit -n` and `ulimit -Hn`; explaining soft vs hard |
| Reject | Only one number; `man ulimit` given as the successful route — in this image it resolves to `ulimit(3)`, an obsolete C library function, which is the wrong document; soft and hard swapped |
| Red flags | Correct flags with no `help` in history — probe |
| Probe | "Could you raise the soft limit to 2000? To 600000?" (yes; no) |
| Notes | Bonus credit if they noticed `man ulimit` gave them `ulimit(3)` and recognised it as the wrong thing rather than trusting it |

### Exercise 24 — Dig
| Field | Value |
|---|---|
| Goal | `/proc/cmdline` describes the host's boot |
| Expected end state | The boot string quoted; one host-disk token named (`root=UUID=03a6f6d4-…`, `resume=UUID=08448299-…`, or `initrd=\initramfs-linux.img`); a security observation |
| Evidence commands | `cat /proc/cmdline` |
| Accept | Any of the three tokens with a reason it is about the host — the container has no bootloader, no initramfs and did not mount a root device by UUID. Security point: it is world-readable and identifies host disks / boot layout to anyone who lands a shell in any container on this machine |
| Reject | Naming `rw` or `iommu=pt` as disk-related; "it is about the container"; no security observation |
| Red flags | Confusing `/proc/cmdline` with `/proc/self/cmdline` |
| Probe | "This container has no bootloader. Who wrote that string, and when?" |

---

## Lesson roll-up

**Must PASS (load-bearing):** 6, 7, 10, 16, 17, 22.

- **17** is the lesson. Without it, exercises 20 and half of Chapter 6's mental model do not land.
- **16** is the arc-relevant one: the student must be able to say what a container is and is not.
- **22** teaches error-reading, which every later chapter leans on.
- **10** kills the "a script is an executable" misconception before Chapter 12.
- **6** and **7** prove they can navigate a reference rather than recall trivia.

**Nice to have:** 1–5, 8, 9, 11–15, 18–21, 23, 24.

**Automatic PASS-WITH-NOTES cap:** any Experiment (17, 18) submitted without a written prediction,
regardless of how good the explanation is.

**Whole-lesson red flag:** correct values throughout with a history containing no reads under
`/proc`. This lesson's facts are all a web search away; the transcript is the only proof of work.
