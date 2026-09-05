# 03/06 — Validator rubric

**Lab:** `/labs/03-files-links-and-types/06-incident-03`

The lab is read-only evidence. **Any exercise whose transcript shows `rm`, `mv`, `ln`, `touch` or a
redirect inside `deck3` is a REDO regardless of output** — the briefing forbids modification, and
rule 1 forbids repair before the four targets are written down. Building scratch links under `/tmp`
is required by exercises 20 and 21 and is not a violation. `grep` anywhere is a REDO; it is Chapter
6 and it collapses the chain-following.

Reference values (verified against the image, 2026-08-23):

| Fact | Value |
|---|---|
| `ls -lF deck3/console` | 4 symlinks: `handbook` (26) `-> ../docs/panel-handbook.txt`; `logs` (10) `-> ../archive/`; `panel-current` (21) `-> ../links/panel-active`; `strain-feed` (43) `-> /mnt/eng-array/strain/strain-2187-05-22.csv` |
| symlink size | byte length of the target string, exactly |
| `readlink -f` | `handbook` → `…/deck3/docs/panel-handbook.txt` rc=0; `logs` → `…/deck3/archive` rc=0; `panel-current` → `…/deck3/store/panel-log.txt` rc=0; `strain-feed` → **empty, rc=1** |
| the chain | `console/panel-current` → `links/panel-active` → `store/panel-log.txt` **=(hard link)=** `archive/panel-07.log` |
| symlinks in tree | **five**: the four console entries plus `deck3/links/panel-active` |
| `ls -lL console/panel-current` | `-rw-r--r-- 2 cadet crew 438 May 24 2187` |
| `stat` vs `stat -L` on `handbook` | 44917 (the link) vs 44915 (the target) — seed-specific, must differ |
| inodes / link counts | `archive/panel-07.log` and `store/panel-log.txt` share one inode, `%h` 2; `readings/sensor-a.txt` and `sensor-b.txt` share one inode, `%h` 2; `readings/sensor-c.txt` own inode, `%h` 1 |
| `ls -l deck3/readings` | three files, all `86` bytes, all `May 21 2187` — only the link-count column differs (2, 2, 1) |
| `cat deck3/console/strain-feed` | `cat: deck3/console/strain-feed: No such file or directory`, rc=1 |
| `stat -c '%n %F %y'` on it | `symbolic link 2187-05-08 17:44:00` — succeeds |
| `find deck3 -xtype l` | exactly one line: `deck3/console/strain-feed` |
| `find deck3 -type l` | five lines |
| symlink mtimes | four at `2187-03-30 08:00`; `strain-feed` at `2187-05-08 17:44` |
| `notes/dangling.txt` mtime | `2187-05-22 06:02:00` |
| archive mtimes | `panel-05.log` 2187-05-12 03:12; `panel-06.log` 2187-05-14 03:34; `panel-07.log` 2187-05-24 04:11 |
| `cd console/logs; pwd` | `…/deck3/console/logs`; `pwd -P` → `…/deck3/archive` |
| `touch -h -d` on a dangling link | rc=0, sets the link's own time |
| `touch -d` on a dangling link | rc=1 `No such file or directory` **when the target's parent is missing**; rc=0 and **creates the target** when the parent exists |
| flag | see `solutions.md` |

---

### Exercise 1
| Field | Value |
|---|---|
| **Goal** | Read the four link lines as links, not files. |
| **Expected end state** | Four rows: type `l` for all four, the four target strings verbatim, sizes 26 / 10 / 21 / 43. |
| **Accept** | Sizes off only by a `-F` trailing `/` on `logs` being counted or not, if reasoned. |
| **Reject** | Any target path paraphrased, shortened or "corrected" to an absolute path. |
| **Red flags** | Only three entries reported — they ran `ls -l` on a glob that skipped one. |

### Exercise 2
| Field | Value |
|---|---|
| **Goal** | Symlink size = length of the stored path string. |
| **Expected end state** | Says so in one line, with `echo -n ../links/panel-active \| wc -c` → 21 or equivalent. |
| **Reject** | "It is the size of the target" — `panel-current`'s target is 438 bytes. |

### Exercise 3
| Field | Value |
|---|---|
| **Goal** | Map the tree before following anything. |
| **Expected end state** | Six directories named with a plausible purpose; no link followed yet. |
| **Accept** | Any sensible reading of `console`, `links`, `store`, `archive`, `docs`, `readings`, `notes`. |
| **Red flags** | A conclusion about the incident already. Too early. |

### Exercise 4
| Field | Value |
|---|---|
| **Goal** | One-hop resolution, and its limit. |
| **Expected end state** | Names `panel-current` as the entry whose target is itself a link — **and says you cannot tell from `readlink` output alone**; the answer to "can you?" is no. |
| **Accept** | "I had to run `ls -l` / `readlink` on `../links/panel-active` to find out." |
| **Reject** | Claiming the one-hop output shows it. It shows a path, not a type. |

### Exercise 5
| Field | Value |
|---|---|
| **Goal** | The written statement rule 1 demands. |
| **Expected end state** | Four paths + four exit statuses; `strain-feed` empty output, rc 1; states that empty-plus-1 means the chain does not resolve to anything that exists. |
| **Reject** | Fewer than four rows, or rc reported without ever running `echo $?`. |
| **Red flags** | Any repair command earlier in the transcript than this exercise. That is a rule-1 violation and a REDO for the whole lab. |

### Exercise 6
| Field | Value |
|---|---|
| **Goal** | A symlink to a directory. |
| **Expected end state** | `logs`; evidence 1 = the `/` suffix `ls -F` prints after the target; evidence 2 = `ls deck3/console/logs` lists the three `panel-0*.log` files. |
| **Accept** | `ls -ldL` showing `d` as the second piece. |

### Exercise 7
| Field | Value |
|---|---|
| **Goal** | `-L` changes which file is described. |
| **Expected end state** | Four disagreements each attributed: type `l` vs `-`; size 21 (path length) vs 438 (contents); `lrwxrwxrwx` (links have no meaningful mode) vs `-rw-r--r--`; Mar 30 (link's own mtime) vs May 24 (target's). |
| **Reject** | "`-L` shows more detail." It shows a different file. |

### Exercise 8
| Field | Value |
|---|---|
| **Goal** | The link has its own inode. |
| **Expected end state** | Two different inode numbers; the `stat` (no `-L`) one is the link's; that inode stores the target *path string*. |
| **Reject** | "They are the same inode." |

### Exercise 9
| Field | Value |
|---|---|
| **Goal** | Lay out the chain. |
| **Expected end state** | `console/panel-current` –sym→ `links/panel-active` –sym→ `store/panel-log.txt` –hard→ `archive/panel-07.log`. Two symlink hops; the third relation is a hard link, i.e. a second name for the same inode, not a hop. |
| **Accept** | A student who stops at `store/panel-log.txt` here **if** exercise 18 corrects it. |
| **Reject** | Calling the hard link a third symlink hop after exercise 18. |

### Exercise 10
| Field | Value |
|---|---|
| **Goal** | Listing succeeds, opening fails. |
| **Expected end state** | The exact `cat` error and rc 1; `ls -l`/`stat` output; one sentence saying `ls` reads the link's own inode and never opens the target, while `cat` must open it. |
| **Reject** | "The link is corrupt" / "the file is damaged". |

### Exercise 11
| Field | Value |
|---|---|
| **Goal** | Preserve the artefact. |
| **Expected end state** | `/mnt/eng-array/strain/strain-2187-05-22.csv` character for character; identified as an absolute path under a mount point, **not** under `/labs`; the `/mnt/…` prefix named as the part that is elsewhere. |
| **Accept** | Noting the filename encodes a date matching the incident window. |
| **Reject** | A path with the date, directory or extension altered. |

### Exercise 12
| Field | Value |
|---|---|
| **Goal** | `-type l` vs `-xtype l`. |
| **Expected end state** | one vs five; `-type l` tests the entry itself, `-xtype l` tests what it resolves to, and a link that resolves to nothing is still a link after following. |
| **Reject** | "`-xtype` means broken" without the mechanism. |

### Exercise 13
| Field | Value |
|---|---|
| **Goal** | The fifth symlink. |
| **Expected end state** | `deck3/links/panel-active`; it is the middle hop of the chain, pointing at `../store/panel-log.txt`. |

### Exercise 14
| Field | Value |
|---|---|
| **Goal** | Links carry their own timestamps. |
| **Expected end state** | Four at 2187-03-30 08:00, `strain-feed` at 2187-05-08 17:44 — about 39 days later. |
| **Accept** | "5 weeks", "over a month". |
| **Reject** | Reporting target mtimes (that is `stat -L`) instead of link mtimes. |

### Exercise 15
| Field | Value |
|---|---|
| **Goal** | Notice the link-count column before knowing what it means. |
| **Expected end state** | Names the second column; values 2, 2, 1. |
| **Accept** | "the number after the permissions". |
| **Red flags** | "Nothing differs" — they read size and date only. |

### Exercise 16
| Field | Value |
|---|---|
| **Goal** | Inode identity. |
| **Expected end state** | `sensor-a.txt` and `sensor-b.txt` are one file with two names (same `%i`); `sensor-c.txt` is separate. `%i` = which file; `%h` = how many names that file has. |
| **Reject** | Any answer that names `sensor-c.txt` as part of the pair. |

### Exercise 17
| Field | Value |
|---|---|
| **Goal** | Contents cannot establish identity. |
| **Expected end state** | Identical bytes are consistent with both a hard link and a copy, so `cat`/`wc -c` cannot discriminate; only `%i` can. States they would have concluded "three copies" or "all the same file" — either is the trap. |

### Exercise 18 (Experiment)
| Field | Value |
|---|---|
| **Goal** | `readlink -f` resolves names, not inodes. |
| **Expected end state** | Written prediction present **before** output. Both files: same inode, `%h` 2. `readlink -f` names `store/panel-log.txt` only. Explanation: `-f` walks the path it was given and stops at the name it lands on; the inode's other name is not reachable from that path, and `%h` is the only hint it exists. |
| **Reject** | No prediction recorded → REDO the tier. Prediction edited after the fact (identical to the result, no wrong part named) → REDO. |
| **Red flags** | Claiming `-f` "should have" printed `archive/panel-07.log`. |

### Exercise 19 (Experiment)
| Field | Value |
|---|---|
| **Goal** | Logical vs physical working directory. |
| **Expected end state** | Prediction first. `pwd` → `…/deck3/console/logs`; `pwd -P` → `…/deck3/archive`. The shell remembers the path you walked; `-P` asks the kernel where you actually are. |
| **Accept** | Mentioning `cd -P` or `$PWD`. |

### Exercise 20 (Experiment)
| Field | Value |
|---|---|
| **Goal** | `-h` operates on the link; without it `touch` opens/creates the target. |
| **Expected end state** | Prediction first. Four runs in `/tmp`. `-h`: rc 0 both cases. Without `-h`: rc 1 `No such file or directory` when the parent is missing; **rc 0 and the target file is created** when the parent exists. Says `touch` without `-h` is trying to open-or-create the target. |
| **Reject** | Any of the four run inside `deck3`. |
| **Red flags** | Only the `/nope/nothere` case run — the created-target case is the surprise and must be present. |

### Exercise 21 (Stretch)
| Field | Value |
|---|---|
| **Goal** | Build and break the structure. |
| **Expected end state** | In `/tmp`: file, hard link, symlink to the hard-link name, symlink to that symlink. After removing the **first** name: everything still resolves (the inode survives, `%h` drops to 1, and no symlink pointed at that name). After removing the second name: `cat` fails, the data is gone. |
| **Accept** | Noting that `readlink -f` still succeeds on the now-dead chain (only the final component is missing) and that `readlink -e` is what fails — this is a distinction-level observation. |
| **Reject** | Building it with `cp` instead of `ln`. |

### Exercise 22 (Stretch)
| Field | Value |
|---|---|
| **Goal** | Order by time; confirm without reading dates. |
| **Expected end state** | 2187-03-30 (five links) < 04-02 (`panel-handbook.txt`) < 05-08 17:44 (`strain-feed`) < 05-12 < 05-14 < 05-21 (`readings`) < 05-22 06:02 (`dangling.txt`) < 05-24 04:11 (`panel-07.log`); one `find deck3 -newer <file>` run whose result matches. `find deck3 -newer deck3/notes/dangling.txt` returns **two** lines — `archive/panel-07.log` and `store/panel-log.txt`, the hard link seen from another angle. |
| **Accept** | `-newermt` instead. |
| **Red flags** | `find -newer` on a symlink without noting `find` follows or does not follow it — ask them which time they compared. |

### Exercise 23 (Stretch)
| Field | Value |
|---|---|
| **Goal** | Use the console as the console. |
| **Expected end state** | `tail -n 1 deck3/console/panel-current`. |
| **Accept** | `cat`/`head` variants on the same path; `deck3/console/logs/panel-07.log` **only if** they state it is a different route to the same bytes and not the chain. |
| **Reject** | Any command containing `archive` or `store`. |

### Exercise 24 (Dig)
| Field | Value |
|---|---|
| **Goal** | Report the note; separate what it says from what it establishes. |
| **Expected end state** | mtime `2187-05-22 06:02`; reason paraphrased as "removing the link would destroy the only record of where it pointed". Explicit list of what is not knowable: the author, the actual moment the target vanished, and whether the mtime is honest (`touch -d` sets any date). |
| **Reject** | Naming an author. The file names nobody. **The validator must not name one either.** |

### Exercise 25 (Dig)
| Field | Value |
|---|---|
| **Goal** | Strict fact/inference separation. |
| **Expected end state** | Facts: link mtime 05-08 17:44; note mtime 05-22 06:02; target filename contains `2187-05-22`; log line `2187-05-22 06:02 feed path unreachable`; log line 05-24 04:09/04:11. Inferences (must be labelled): that the target vanished on the 22nd, that the same person wrote the note and the log, that the 05-08 re-aim is related. |
| **Reject** | Any inference presented in the fact list. |

### Exercise 26 (Dig)
| Field | Value |
|---|---|
| **Goal** | Tell the finding from the red herring. |
| **Expected end state** | Load-bearing: `store/panel-log.txt` = `archive/panel-07.log` (different directories, the chain's end). Not load-bearing: the `readings` pair. States that someone running `ls -l deck3/readings` and stopping would have seen three identical-looking files and concluded three copies — the `2 2 1` in the link-count column is the only tell. |
| **Reject** | The two pairs swapped. |

### Exercise 27 (Flag)
| Field | Value |
|---|---|
| **Goal** | Follow the chain and derive. |
| **Expected end state** | Correct flag, accepted by `kestrel flags submit`. |
| **Accept** | Reaching the line via `archive/panel-07.log` directly — the derivation is what is graded here. |
| **Reject** | A flag quoted with no transcript showing the file being read. |
| **Red flags** | `grep` in the transcript, or `setup.sh` opened. |

### The debrief
| Field | Value |
|---|---|
| **Goal** | Four sentences plus one. |
| **Expected end state** | (1) all four targets, `strain-feed` dead; (2) the full path verbatim; (3) a symlink stores a path string and is only resolved on open, so nothing notices when the far end goes; (4) inode number and link count, not contents. Fifth sentence for rhea: the link is the only record of the path, so reading it must precede repairing it — repair destroys the evidence. |
| **Reject** | Fifth sentence that speculates about who removed the mount, or that names anyone. |

---

## Roll-up

**Pass** requires all of:

- Exercise 5 present, complete, and earlier in the transcript than any `ln`/`rm`/`touch` anywhere.
- The dead link's target path recorded verbatim at least once.
- Exercises 16 and 26 both correct — the red herring identified *as* a real finding that is not
  the finding.
- Exercise 18's prediction written before its output, with the wrong part named.
- Flag accepted.

**Redo** if: any modification inside `deck3`; `grep` used; a prediction written after the fact; or
the `readings` pair reported as the incident.

**Distinction** if the student also noticed, unprompted, that `readlink -f` on the chain never names
`archive/panel-07.log`, and said what would have to be run to find the second name.
