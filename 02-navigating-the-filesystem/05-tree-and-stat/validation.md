# 02/05 — Validator rubric

Read `docs/VALIDATION_PROTOCOL.md` first. Lab:
`/labs/02-navigating-the-filesystem/05-tree-and-stat`. Written answers go in `answers.md`, which the
student creates themselves.

**Reference values for a freshly seeded lab** (re-derive if the setup script changes):

- `tree bays` → `9 directories, 5 files`; `tree -a bays` → `10 directories, 7 files`.
- `manifest` sizes: `notes.txt` 23, `check.sh` 33, `strain.csv` 34, `drift.txt` 30, `empty.log` 0,
  `telemetry.txt` 46, `hullscan` 26936, `readme.txt` 26936, `dangling.link` 42, `subsystem` 4096.
- `du -sh accounting` → `40M`; the file is `accounting/.staging/dump.bin`, 41926656 bytes.
- `ledger/reserved.img`: `Size: 52428800`, `Blocks: 0`; `du -h` → `0`, `--apparent-size` → `50M`;
  `du -sh ledger` → `8.0K`, with `--apparent-size` → `51M`.
- `du -h -d 1 .` → accounting 40M, stamps 16K, ledger 8.0K, bays 64K, manifest 84K, total 41M.
- `stamps`: `read-me.txt` a=2187-06-20 m=2187-06-01; `written.txt` a=2187-06-02 m=2187-06-14;
  `chmodded.txt` a=m=2187-06-07, mode 640. **All three ctimes are the seed date.**
- `df -T /labs` → `ext4` on `/dev/nvme2n1p2`; `df -T /` → `overlay`. `stat -f /labs` → `ext2/ext3`,
  block size 4096. `df -i /labs` → ~23.9M inodes, ~11% used.
- `file -i`: `application/gzip`, `text/plain; charset=utf-8`, `application/x-pie-executable`.

Sizes and counts are stable; inode numbers, free space and the ctime date are not — never fail a
student on those.

---

### Exercise 1
| Field | Value |
|---|---|
| Goal | `tree`, and reading its summary line |
| Expected end state | `9 directories, 5 files` |
| Evidence | `history` |
| Accept | The two counts |
| Reject | `ls -R` output with counts made up; only one count |
| Red flags | Counts that match `-a` without `-a` in history |
| Probe | "What is the ninth directory?" |

### Exercise 2
| Field | Value |
|---|---|
| Goal | `stat`'s default output |
| Expected end state | Size 23, a plausible inode, `regular file` |
| Evidence | `stat manifest/notes.txt` |
| Accept | Any inode number — it varies |
| Reject | `Blocks: 8` reported as the size; `ls -l` used instead |
| Red flags | — |
| Probe | "Which line has the type on it?" |

### Exercise 3
| Field | Value |
|---|---|
| Goal | `file` on an extension-less binary |
| Expected end state | Identified as an ELF executable |
| Evidence | `file manifest/hullscan` |
| Accept | "a compiled program / executable / binary" |
| Reject | Guessing from the name; `cat`ting it (and note if their terminal broke — that is the lesson, not a failure) |
| Red flags | — |
| Probe | "What told `file` that, if not the name?" |

### Exercise 4
| Field | Value |
|---|---|
| Goal | `du -sh` |
| Expected end state | `40M` |
| Evidence | `history` |
| Accept | `40M`; `du -s` with a hand conversion |
| Reject | The first line of an unsummarised `du`; `ls -l accounting` (which reports the directory, 4096) |
| Red flags | — |
| Probe | "What would `du` without `-s` have printed here?" |

### Exercise 5
| Field | Value |
|---|---|
| Goal | Hidden entries change both counts |
| Expected end state | `10 directories, 7 files`; the three new entries named: `.calibration`, `.calibration/offsets.txt`, `.treeignore-note` |
| Evidence | `tree -a bays` |
| Accept | All three named; explanation that the dot-directory brought a file with it |
| Reject | Only the dot-directory named; counts without the entries |
| Red flags | — |
| Probe | "Why did the file count go up by two when you only revealed one hidden file at the top level?" |
| **Load-bearing** | yes |

### Exercise 6
| Field | Value |
|---|---|
| Goal | Combining two `tree` restrictions |
| Expected end state | Directories only, two levels |
| Evidence | `history` |
| Accept | `-d` with `-L 2` in either order |
| Reject | Depth achieved by eyeballing full output |
| Red flags | — |
| Probe | "What does `-L 1` show?" |

### Exercise 7
| Field | Value |
|---|---|
| Goal | `tree -f` and why it exists |
| Expected end state | Full-path output plus a use case |
| Evidence | `history` |
| Accept | Any of: paths can be copied into another command, fed to a tool line by line, or grepped later |
| Reject | Output only, no use case |
| Red flags | — |
| Probe | "Which form would you send to a colleague in a bug report?" |

### Exercise 8
| Field | Value |
|---|---|
| Goal | `tree -p`, and noticing a mode set by this lesson's own setup |
| Expected end state | `stamps/chmodded.txt` at `-rw-r-----` against siblings' `-rw-r--r--` |
| Evidence | `tree -p` over the lab root |
| Accept | Correct file named; recognising it was seeded that way for the timestamp exercise |
| Reject | Running only on `bays` and reporting "no difference" as the final answer — the exercise says an entry differs |
| Red flags | Answer produced with `ls -l` only |
| Probe | "What operation sets that mode, and what does it do to ctime?" |

### Exercise 9
| Field | Value |
|---|---|
| Goal | Read all three timestamps and see that their orders disagree |
| Expected end state | A table of nine values; oldest mtime and newest atime both `read-me.txt` |
| Evidence | `stat stamps/*` |
| Accept | Correct values however laid out; explanation that a file written once long ago and read recently holds both records |
| Reject | Mapping `Change` to "created"; claiming two different files |
| Red flags | Values that match neither the lab nor their own transcript |
| Probe | "Which of the three would `ls -l` have shown you?" |
| **Load-bearing** | yes |

### Exercise 10
| Field | Value |
|---|---|
| Goal | ctime cannot be backdated, and is therefore the evidentiary one |
| Expected end state | Two lines: `touch` set atime/mtime; ctime records the inode change and so shows today. ctime is the trustworthy field |
| Evidence | `cat answers.md` |
| Accept | Any phrasing of "setting the times is itself a change, and ctime records changes"; naming ctime as evidence |
| Reject | "The clock is wrong"; "the files are from the future"; naming mtime as the reliable one |
| Red flags | Fluent answer with no `stat` in history |
| Probe | "How would you backdate ctime? What would it take?" (root plus raw device access, or moving the system clock — not `touch`) |
| **Load-bearing** | yes |

### Exercise 11
| Field | Value |
|---|---|
| Goal | `ls -lu` / `-lc` change which timestamp the column shows |
| Expected end state | Three orderings: mtime → `written.txt` newest; atime → `read-me.txt` newest; ctime → all today |
| Evidence | `history` shows all three |
| Accept | The three orderings |
| Reject | Two runs and an assumption; `stat` used instead (the exercise says `ls` alone) |
| Red flags | Reporting three distinct ctimes — they are effectively identical |
| Probe | "Did `-u` add a column or change one?" |

### Exercise 12
| Field | Value |
|---|---|
| Goal | `stat -c` format strings |
| Expected end state | One line per file: name, byte size, octal mode |
| Evidence | `history` |
| Accept | `%n %s %a` in any order/separator; a glob or explicit file list |
| Reject | `%A` (symbolic) where octal was asked; one `stat` per file typed out by hand — note it and accept with a nudge; hand-assembled output |
| Red flags | Sizes that do not match the reference list |
| Probe | "How would you add the owner?" |

### Exercise 13
| Field | Value |
|---|---|
| Goal | The filesystem stores no content type |
| Expected end state | Both `regular file` to `stat` (23 vs 26936 bytes); ASCII text vs ELF to `file`; the filesystem records nothing distinguishing them |
| Evidence | `history` shows both tools |
| Accept | "Type is not an inode field" plus any sound reason: new formats appear, the filesystem would have to be wrong or be updated, bytes are bytes |
| Reject | "The filesystem knows it is a binary because of the execute bit" (the setup script strips the execute bit: both are 644, and mode is not type in any case — a directory is 755 and an ELF can be 644) |
| Red flags | — |
| Probe | "What does the filesystem store that `file` does not look at at all?" |

### Exercise 14
| Field | Value |
|---|---|
| Goal | Extensions are decoration |
| Expected end state | `telemetry.txt` = gzip data; `readme.txt` = an ELF executable |
| Evidence | `file manifest/*` |
| Accept | Both named with what they actually are |
| Reject | Only one; naming `hullscan` (its lack of extension is not a mismatch); naming `dangling.link` |
| Red flags | — |
| Probe | "What would `cat telemetry.txt` do to your terminal?" |
| **Load-bearing** | yes |

### Exercise 15
| Field | Value |
|---|---|
| Goal | Describing a link versus following it |
| Expected end state | Default: `broken symbolic link to ../accounting/.staging/dump-2187-06-12.bin`. With `-L`: `cannot open 'manifest/dangling.link' (No such file or directory)` |
| Evidence | `history` |
| Accept | Both outputs, and an explanation that reading a link always succeeds because the link itself exists, while opening its target can fail |
| Reject | "The link is corrupt"; paraphrasing the error |
| Red flags | `-L` output invented — it is an error, not a description |
| Probe | "The link file itself is 42 bytes. What is in it?" |

### Exercise 16
| Field | Value |
|---|---|
| Goal | Connect `file`'s `empty` to last lesson's size-zero finding |
| Expected end state | `manifest/empty.log`; and `/proc/cpuinfo` (or any `/proc` file) reported `empty` while producing hundreds of lines |
| Evidence | `history` shows `file` on a `/proc` path |
| Accept | Any procfs file; explanation that `file` checks the recorded size first |
| Reject | Creating a new file to demonstrate; a `/proc` file named without running `file` on it |
| Red flags | — |
| Probe | "Does `file` open it at all?" |

### Exercise 17
| Field | Value |
|---|---|
| Goal | `ls` hides; `du` does not |
| Expected end state | `.staging` revealed; a listing that shows it |
| Evidence | `ls -a accounting` or `tree -a accounting` in history |
| Accept | Either tool; explanation that `ls` omits dot entries by default and `du` has no such rule |
| Reject | "`du` is counting something else / is wrong"; "there is a bug" |
| Red flags | The path named with no listing that could have found it |
| Probe | "Which of the two commands would you trust to tell you a directory is genuinely empty?" |
| **Load-bearing** | yes |

### Exercise 18
| Field | Value |
|---|---|
| Goal | Locate the bulk |
| Expected end state | `accounting/.staging/dump.bin`, ~41926656 bytes / 40M |
| Evidence | `history` |
| Accept | Size in bytes or human units |
| Reject | The directory reported instead of the file |
| Red flags | — |
| Probe | "What is the other file in there?" (`note.txt`, dated 2187-06-12) |

### Exercise 19
| Field | Value |
|---|---|
| Goal | Depth-limited `du` |
| Expected end state | Five directory lines plus a 41M total; `accounting` named as the bulk |
| Evidence | `history` |
| Accept | `-d 1` / `--max-depth=1`; or five separate `du -sh` runs, with a note that the flag exists |
| Reject | Only the total; per-file output unaggregated |
| Red flags | — |
| Probe | "Where did `ledger`'s 50 MB go in this table?" |

### Exercise 20
| Field | Value |
|---|---|
| Goal | Apparent size versus allocated blocks |
| Expected end state | 52428800 vs `0`; `Size:` and `Blocks:` named from `stat` |
| Evidence | `history` shows all three commands |
| Accept | Both fields named; any correct account of the difference. Using the word "sparse" is a bonus, not required |
| Reject | "The file is corrupt/empty/broken"; naming `IO Block` as the explaining field |
| Red flags | Explanation with no `stat` run |
| Probe | "Read the first megabyte of it. What do you get, and where did it come from?" |
| **Load-bearing** | yes |

### Exercise 21 — Experiment
| Field | Value |
|---|---|
| Goal | The two questions `du` can answer |
| Expected end state | Written prediction, then `0`, `50M`, `8.0K`, `51M`, `52428800`; three lines of explanation; USB answer |
| Evidence | `answers.md`/transcript for the prediction; `history` for the five commands |
| Accept | Default = space reclaimable; `--apparent-size` = bytes readable. **USB answer: apparent size**, because an ordinary copy writes the zeros out |
| Reject | "Allocated blocks, because that is what it really uses" — defensible but wrong; use the probe before deciding. Missing prediction ⇒ **cap at PASS-WITH-NOTES** |
| Red flags | Prediction identical to output in all five |
| Probe | "Copy it to `/tmp` and `du` the copy." (it becomes 50M of real blocks) |
| **Load-bearing** | yes |

### Exercise 22 — Experiment
| Field | Value |
|---|---|
| Goal | Block granularity |
| Expected end state | Prediction; `4.0K` for a 23-byte file; three more small files also `4.0K`; `empty.log` at `0` |
| Evidence | transcript; `history` |
| Accept | 4 K identified as the block size (`stat`'s `IO Block: 4096` is good corroboration); the million-files conclusion |
| Reject | "The file is bigger than it looks"; missing prediction ⇒ cap at PASS-WITH-NOTES |
| Red flags | Claiming `empty.log` is also 4.0K — it is 0 |
| Probe | "Why is the empty one 0 and not 4.0K?" (no data block is needed; only an inode) |

### Exercise 23
| Field | Value |
|---|---|
| Goal | Symlink loops and cycle detection |
| Expected end state | Default stops at `loop -> ../..`; `-l` walks the whole lab and prints `[recursive, not followed]` |
| Evidence | `history` shows both |
| Accept | The marker quoted with its brackets; a statement that an unguarded tool would recurse until it hit a path-length or symlink limit |
| Reject | Marker paraphrased; claiming the default follows it |
| Red flags | `-l` output identical to the default's |
| Probe | "How could `tree` tell it had been there before?" (it tracks device and inode numbers) |

### Exercise 24
| Field | Value |
|---|---|
| Goal | `df` reports the containing filesystem |
| Expected end state | `/labs` = `ext4` on `/dev/nvme2n1p2`; `/` = `overlay`; lab files are on `/labs` and survive `docker rm` |
| Evidence | `df -T` runs in history |
| Accept | Correct types; the volume-versus-container-layer distinction, however phrased |
| Reject | "They are the same filesystem because the sizes match"; claiming work in `/home/cadet` also survives |
| Red flags | Types recalled from Chapter 0 rather than run |
| Probe | "You wrote a note to `~/notes.txt`. Does it survive?" (no) |

### Exercise 25
| Field | Value |
|---|---|
| Goal | Inode exhaustion |
| Expected end state | `df -i /labs` run; the failure described as "free space but cannot create files" |
| Evidence | `history` |
| Accept | Any wording of the inode supply being fixed at filesystem creation |
| Reject | "It shows file counts, which is interesting" with no failure described |
| Red flags | — |
| Probe | "Which exercise in this lesson describes the workload that causes it?" (22 — a million tiny files) |

### Exercise 26
| Field | Value |
|---|---|
| Goal | Directory link counts |
| Expected end state | `directory`, `Links: 2`, counting the parent's entry and its own `.` |
| Evidence | `stat manifest/subsystem` |
| Accept | Both references enumerated |
| Reject | "2 because there are two files in it" (it is empty); "it is a symlink" |
| Red flags | — |
| Probe | "What would it be if you made three directories inside it?" (5) |

### Exercise 27 — Dig
| Field | Value |
|---|---|
| Goal | `tree --du`, and that it reports apparent sizes |
| Expected end state | `accounting` 40M, `ledger` **50M**; the `ledger` figure contradicts `du -sh ledger` = 8.0K |
| Evidence | `history` shows `--du` with `-a` and no `-L` |
| Accept | Correct identification of `ledger` as the contradiction, explained as apparent size versus allocated blocks |
| Reject | `ledger` reported as 4.0K/8.0K (they limited depth or dropped `-a`); naming `accounting` as the contradiction |
| Red flags | Figures reported with `--du` absent from history |
| Probe | "Which of the two tools told you which question it was answering?" (neither, by default) |

### Exercise 28 — Dig
| Field | Value |
|---|---|
| Goal | `stat -f`, and reconciling a disagreement between two tools |
| Expected end state | Block size 4096, type `ext2/ext3`, against `df -T`'s `ext4`; `df -T` trusted, checkable in `/proc/mounts` |
| Evidence | `history` |
| Accept | Trusting `df -T`, with any sound reason: the mount table names the actual driver, while the magic number is shared across the ext family |
| Reject | "One of them is a bug"; trusting `stat -f`; no method offered for checking |
| Red flags | — |
| Probe | "Where does `df` get its answer from?" (`/proc/mounts`, from last lesson) |

### Exercise 29 — Dig
| Field | Value |
|---|---|
| Goal | `du -c` |
| Expected end state | Three lines plus `41M total` |
| Evidence | `history` |
| Accept | `-c` combined with `-s`/`-h` |
| Reject | Hand-summed total with no flag found |
| Red flags | — |
| Probe | "Does the total use apparent size or blocks?" (blocks, unless asked otherwise) |

### Exercise 30 — Dig
| Field | Value |
|---|---|
| Goal | `file -i` and why machine-readable output matters |
| Expected end state | `application/gzip`, `text/plain; charset=utf-8`, `application/x-pie-executable` |
| Evidence | `history` |
| Accept | All three; reason must be about a fixed, comparable vocabulary — not merely brevity |
| Reject | Only "it is shorter"; MIME types invented |
| Red flags | — |
| Probe | "What breaks if `file`'s English description is reworded in the next release?" |

---

## Lesson roll-up

**Must PASS (load-bearing):** 5, 9, 10, 14, 17, 20, 21.

- **17** and **20** are the two halves of the lesson's one idea, in opposite directions. A student who
  passes 20 but not 17 has learned about sparse files and not about `ls`.
- **10** is the technique Chapter 15's argument rests on. It must be solid.
- **5** and **14** kill two beginner assumptions — "the listing is the contents" and "the extension is
  the type" — that every later chapter depends on being dead.
- **9** is the vocabulary the rest of the course uses for timestamps.

**Nice to have:** 1–4, 6–8, 11–13, 15, 16, 18, 19, 22–30.

**Automatic PASS-WITH-NOTES cap:** Experiments 21 and 22 submitted without a written prediction.

**Whole-lesson red flag:** correct sizes throughout with no `stat`, `du` or `file` in history. Every
number in this lesson is one command away, and the transcript is the proof.
