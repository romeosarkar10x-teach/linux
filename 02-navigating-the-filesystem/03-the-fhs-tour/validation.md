# 02/03 — Validator rubric

Protocol: `docs/VALIDATION_PROTOCOL.md`. Read-only evidence. Much of this lesson is written
answers in `answers.md`; grade the reasoning, and prefer a defended wrong answer to an undefended
right one.

Lab: `/labs/02-navigating-the-filesystem/03-the-fhs-tour`

---

### Exercise 1
| Field | Value |
|---|---|
| Goal | `ls -ld` on many arguments; reading type characters |
| Expected end state | 22 top-level entries; 4 of them symlinks |
| Evidence commands | `history \| grep ' /'` |
| Accept | Counts of 22 and 4 |
| Reject | Counting the contents of the directories |
| Red flags | — |
| Probe | "Which entries did you count that would not exist on the VM outside?" |

### Exercise 2
| Field | Value |
|---|---|
| Goal | Reading symlink targets from a long listing |
| Expected end state | `/bin -> usr/bin`, `/lib -> usr/lib`, `/lib64 -> usr/lib64`, `/sbin -> usr/sbin`; all four point into `/usr` |
| Evidence commands | `ls -ld /bin /lib /sbin` |
| Accept | Targets reported as relative (`usr/bin`) — that is what the listing says |
| Reject | Naming only three and omitting `/lib64`; missing the commonality that every one of them points into `/usr` |
| Red flags | — |
| Probe | "Is `usr/bin` relative to your working directory or to something else?" |

### Exercise 3
| Field | Value |
|---|---|
| Goal | Uses `man` with an explicit section |
| Expected end state | One fact from `hier(7)`'s `/var` section not in the notes |
| Evidence commands | `history \| grep 'man 7'` |
| Accept | Anything genuinely from the page — `/var/account`, `/var/crash`, `/var/spool/mail` as a symlink target, the "variable data" wording |
| Reject | A fact restated from the lesson notes; a fact from a web search |
| Red flags | No `man` in history |
| Probe | "What section is `hier` in, and how would you have found that without being told?" |

### Exercise 4 *(load-bearing)*
| Field | Value |
|---|---|
| Goal | Multi-argument `ls` to survey quickly; and a correct causal explanation |
| Expected end state | `/boot`, `/media`, `/mnt`, `/srv` named |
| Evidence commands | `ls -A /boot /media /mnt /srv` |
| Accept | Reason naming containerisation: the container shares the host kernel so needs no `/boot`, has no removable media, and serves nothing |
| Reject | "Ubuntu does not use them"; "they are deprecated"; naming `/proc` or `/sys` as empty |
| Red flags | Four correct names with a reason that does not mention the container |
| Probe | "What is in `/boot` on the VM outside, and why does the container not need it?" |

### Exercise 5
| Field | Value |
|---|---|
| Goal | `/etc` holds machine identity in text |
| Expected end state | `/etc/os-release` named; Ubuntu 24.04 reported |
| Evidence commands | `history \| grep os-release` |
| Accept | `/etc/lsb-release` as an additional answer; `/etc/issue` as a partial |
| Reject | `uname -a` alone — it does not name a `/etc` file, and reports the *host* kernel here |
| Red flags | — |
| Probe | "Why is this not in `/usr`, given that it never changes while the system runs?" (Because it is machine-specific, not because it is variable.) |

### Exercise 6
| Field | Value |
|---|---|
| Goal | Recognising `/etc`'s line-per-record convention |
| Expected end state | `/etc/shells` plus two others named, each with what a line represents |
| Evidence commands | `history` |
| Accept | `/etc/passwd`, `/etc/group`, `/etc/hosts`, `/etc/fstab`, `/etc/services`, `/etc/shells.state` — any two, correctly described |
| Reject | Naming directories; naming a file without saying what a line is |
| Red flags | — |
| Probe | "What separates the fields in the one you picked?" |

### Exercise 7
| Field | Value |
|---|---|
| Goal | `/var/log`, and the package log |
| Expected end state | `/var/log/dpkg.log` named |
| Evidence commands | `ls /var/log` |
| Accept | `/var/log/apt/` as an additional answer with the note that it is a directory |
| Reject | Naming `/var/log/apt` as *the file* |
| Red flags | The file's contents pasted — the exercise said not to read it |
| Probe | "Why is this under `/var` and not `/etc`?" |

### Exercise 8
| Field | Value |
|---|---|
| Goal | `/usr/bin` versus `/usr/sbin` |
| Expected end state | `ls` at `/opt/kestrel/bin/ls`; `useradd` at `/usr/sbin/useradd` |
| Evidence commands | `type -p ls; type -p useradd` |
| Accept | **`ls` resolving to `/opt/kestrel/bin/ls` is the correct answer on this station** — `/usr/bin/ls` also exists, and a student who reports both and explains `PATH` order has done better |
| Reject | An explanation that `sbin` means "static binaries" |
| Red flags | `which` used after `01/03` taught otherwise — note it, do not fail it |
| Probe | "There are two `ls` binaries here. Which one runs, and why that one?" |

### Exercise 9
| Field | Value |
|---|---|
| Goal | `/opt/kestrel/bin` is a directory of symlinks into `/nix/store` |
| Expected end state | A long listing showing `l` type characters and `/nix/store/...` targets |
| Evidence commands | `ls -l /opt/kestrel/bin \| head` |
| Accept | Any entry; the answer must say "symlink" and name the store path |
| Reject | "It is a binary"; a plain `ls` with no type information |
| Red flags | — |
| Probe | "What does the long hash in the target path buy you?" |

### Exercise 10
| Field | Value |
|---|---|
| Goal | Notices the sticky bit and states its rule |
| Expected end state | Final `t` on `/tmp` and `/var/tmp`, absent on `/var/log`; named as the sticky bit; rule stated; the world-writable precondition named |
| Evidence commands | `ls -ld /tmp /var/tmp /var/log` |
| Accept | "Anyone can create files, only the owner (or root) can delete their own." The reason those two need it: they are the two world-writable shared scratch directories, so without it any user could delete another's files |
| Reject | "`t` means temporary"; claiming `/tmp` and `/var/tmp` differ from each other |
| Red flags | — |
| Probe | "What would go wrong in `/tmp` without it?" |

### Exercise 11
| Field | Value |
|---|---|
| Goal | Reads a permission failure off the mode |
| Expected end state | `ls: cannot open directory '/root': Permission denied` recorded; mode `drwx------` read; the "other" block identified as all dashes |
| Evidence commands | `ls -ld /root` |
| Accept | Naming `r` as the missing permission (`x` is also missing; both are correct if reasoned) |
| Reject | Using `sudo` to get in; "root files are protected by the kernel" |
| Red flags | A successful listing of `/root` in history — that means `sudo` |
| Probe | "Which of the three permission blocks applies to you here, and how did you decide?" |

### Exercise 12
| Field | Value |
|---|---|
| Goal | Applies the static/variable and shareable/local axes to concrete files |
| Expected end state | `answers.md` table filled in, six rows, each with a reason |
| Evidence commands | `cat /labs/.../answers.md` |
| Accept | Canonical: `hullscan` → `/usr/local/bin` (or `/opt/hullscan/bin`); `hullscan.conf` → `/etc`; `hullscan.1` → `/usr/local/share/man/man1` (or `/usr/share/man/man1`); `strain-archive.csv` → `/var/lib` or `/srv`; `scratch-run.tmp` → `/tmp`; `kestrel-ops.pid` → `/run` |
| Reject | Any row with a blank reason. A row placing the `.conf` under `/usr` or the `.pid` under `/var/log` |
| Red flags | Six perfect answers with reasons copied from the notes verbatim |
| Probe | "Which axis decided the `.csv`, and which decided the `.pid`?" |

### Exercise 13
| Field | Value |
|---|---|
| Goal | Recognises where the convention genuinely forks |
| Expected end state | Two items named with alternatives |
| Evidence commands | `answers.md` |
| Accept | The intended pair is `hullscan` (`/usr/local/bin` vs `/opt/...`) and `strain-archive.csv` (`/var/lib` vs `/srv`). Also accept `scratch-run.tmp` (`/tmp` vs `/var/tmp`) with a survival-time argument, and the man page (`/usr/local/share/man` vs `/usr/share/man`) |
| Reject | Naming the `.conf` — `/etc` is not seriously contested |
| Red flags | — |
| Probe | "What single fact about the file would settle it?" |

### Exercise 14
| Field | Value |
|---|---|
| Goal | Argues a genuine trade-off |
| Expected end state | Three lines committing to one option |
| Evidence commands | `answers.md` |
| Accept | **Either conclusion.** `/usr/local/bin`: already on `PATH`, standard shape, package manager stays out. `/opt/hullscan/bin`: self-contained, deletable in one move, versions side by side, at the cost of a `PATH` entry |
| Reject | Refusing to commit; `/usr/bin` as the answer; three lines with no trade-off named |
| Red flags | — |
| Probe | "Your answer, but for a program with twelve support files instead of one. Same choice?" |

### Exercise 15 *(Experiment — prediction required)*
| Field | Value |
|---|---|
| Goal | usrmerge, observed rather than asserted |
| Expected end state | Five predictions, five observations; the two counts identical; `realpath /bin` → `/usr/bin`; `cd /bin && pwd` → `/bin`, then `cd .. && pwd` → `/` |
| Evidence commands | `history` |
| Accept | Explanation that `/bin` is a name for `/usr/bin`, so both listings are the same directory; and that `cd ..` used the logical path from `02/01` |
| Reject | Missing prediction; "`/bin` holds the essential subset" as a present-tense claim about this machine |
| Red flags | Counts reported as different |
| Probe | "If you deleted a file in `/usr/bin`, what happens to `/bin`?" |

### Exercise 16 *(Experiment — prediction required; load-bearing)*
| Field | Value |
|---|---|
| Goal | Distinguishes what the evidence shows from what the documentation claims |
| Expected end state | Four predictions with reasons; `df` run on all four paths; the observation that **all four report the same overlay filesystem** |
| Evidence commands | `history \| grep df` |
| Accept | The correct conclusion: `df` here supports *none* of the reboot claims, because the container has flattened the distinctions the FHS describes — `/run` is not a tmpfs on this station. The documentation claims (`/tmp` and `/run` cleared, `/var/tmp` and `/var/log` retained) stand on the documentation, not on anything they measured |
| Reject | **Missing prediction — fail.** Also reject any claim to have *proven* the reboot behaviour from inside a container that has not rebooted, and any report that `/run` is memory-backed here |
| Red flags | A `df` output pasted that shows four different filesystems — not possible on this image; ask them to re-run |
| Probe | "What experiment would actually settle it, and where would you have to run it?" |

### Exercise 17
| Field | Value |
|---|---|
| Goal | Combines `-l`, `-d`, `-t`, `-r` on many arguments |
| Expected end state | One command; oldest-first ordering; newest entry identified |
| Evidence commands | `history \| grep -- '-ltrd\|-ld'` |
| Accept | `ls -ltrd /*`; the letters in any order; typing all the paths by hand is also correct. The newest entry is one of the kernel-backed or actively-written ones — `/sys`, `/tmp` or `/labs`, depending on when they ran it; accept any of these with a coherent reason |
| Reject | A listing of contents rather than entries |
| Red flags | — |
| Probe | "Why does `/sys` have a modification time at all?" |

### Exercise 18
| Field | Value |
|---|---|
| Goal | Applies FHS reasoning to two non-FHS directories |
| Expected end state | For each: a purist location, and a practical objection |
| Evidence commands | `answers.md` or the transcript |
| Accept | `/course` → `/opt/kestrel/course` or `/usr/local/share`; `/labs` → `/home/cadet/labs`, `/srv`, or `/var/lib`. Practical reason: both are typed constantly and are separate mounts, so a short top-level name is worth the deviation |
| Reject | "It does not matter"; no alternative named |
| Red flags | — |
| Probe | "If `/labs` lived under your home directory, what would `kestrel reset` have to be careful about?" |

### Exercise 19
| Field | Value |
|---|---|
| Goal | Documentation is in more than one place |
| Expected end state | Three paths: `/usr/share/man`, `/usr/share/doc`, `/opt/kestrel/share/man` |
| Evidence commands | `manpath` |
| Accept | `/usr/local/share/man` in place of the third, if they explain it is empty here |
| Reject | Three subdirectories of one tree |
| Red flags | — |
| Probe | "How did `man` learn about the third one?" |

### Exercise 20 *(Dig)*
| Field | Value |
|---|---|
| Goal | Reads `hier(7)` against reality and finds a gap |
| Expected end state | One documented-but-absent path named, with what it holds |
| Evidence commands | `history \| grep -E 'man 7 hier\|ls /usr'` |
| Accept | `/usr/X11R6` (legacy X11 tree) is the cleanest. Also accept `/usr/dict`, `/usr/doc`, `/usr/etc`, `/var/yp`, `/var/msgs`, `/lost+found`, `/media/floppy` and similar, provided they say what it would hold |
| Reject | Naming something that does exist here; naming a directory the page does not document |
| Red flags | — |
| Probe | "Is the page wrong, or is the system?" (Neither — the page documents a convention across decades.) |

### Exercise 21 *(Dig)*
| Field | Value |
|---|---|
| Goal | `apropos` proves absence better than a failed `man` |
| Expected end state | `file-hierarchy(7)` named; `apropos hierarchy` / `man -k` run and shown not to list it |
| Evidence commands | `history \| grep -E 'apropos\|man -k'` |
| Accept | The reasoning that a failed `man` has several causes (typo, wrong section, unbuilt index) while an index search that lists `hier(7)` and not `file-hierarchy(7)` distinguishes them |
| Reject | "`man` said no manual entry, so it is not installed" as the whole answer |
| Red flags | — |
| Probe | "What would you check if `apropos` returned nothing at all?" (`mandb`.) |

### Exercise 22 *(Dig)*
| Field | Value |
|---|---|
| Goal | `du -sh` per-argument, plus a human-numeric sort |
| Expected end state | `/usr/share/doc` ≈ 4.8M total; largest subdirectory is `manpages` (≈552K) |
| Evidence commands | `history \| grep du` |
| Accept | `du -sh /usr/share/doc/* \| sort -h \| tail -1`; also accept `sort -rh \| head -1`, or reading it by eye |
| Reject | A sort that ranked `999K` above `1.2M` and reported the wrong winner |
| Red flags | `find` in history — it has not been taught, and the exercise says it is not needed |
| Probe | "Why does a plain `sort` get this wrong?" |

---

## Lesson roll-up

**Load-bearing — must PASS:** 4, 12, 16.

12 is the point of the lesson: the student should be reasoning from the two axes, not reciting a
memorised list. 16 is the honesty exercise — a student who claims to have proven reboot semantics
inside a container that has never rebooted has learned the wrong lesson, and that is worth a REDO
on its own.

**Cap.** Missing predictions on 15 or 16 caps the lesson at PASS-WITH-NOTES.

**Note.** Exercises 12–14, 18 and 20 have more than one defensible answer. The rubric's job here
is to check that a reason was given and that it follows from the file's properties, not to match a
key.
