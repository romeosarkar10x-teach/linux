# 02/02 — Validator rubric

Protocol: `docs/VALIDATION_PROTOCOL.md`. Read-only evidence commands. Most outputs here are
trivially fakeable; weight the probe questions.

Lab: `/labs/02-navigating-the-filesystem/02-cd-and-ls-deep`

---

### Exercise 1
| Field | Value |
|---|---|
| Goal | Dotfiles are hidden by naming convention |
| Expected end state | For `logs`: 5 plain, 7 with `-A`, 9 with `-a`. For the lab root: 7 plain, 9 with `-a`, and 7 with `-A` — because the lab root has no dotfiles of its own, so `-a`'s only additions are `.` and `..` |
| Evidence commands | `history \| grep ' ls'` |
| Accept | Either flag, provided the counts match the flag used, and the lab-root explanation names `.` and `..` as the whole difference |
| Reject | "The extra files are system files"; any answer implying a hidden attribute |
| Red flags | Counts that match neither flag |
| Probe | "What would I have to do to hide a file from `ls` without moving it?" |

### Exercise 2
| Field | Value |
|---|---|
| Goal | `-a` vs `-A` |
| Expected end state | One line: `-a` includes `.` and `..`, `-A` omits them |
| Evidence commands | `history` |
| Accept | Any phrasing naming the two entries |
| Reject | "`-A` shows fewer hidden files" |
| Red flags | — |
| Probe | "Where do `.` and `..` come from?" |

### Exercise 3
| Field | Value |
|---|---|
| Goal | `-h` |
| Expected end state | Long listing of `logs`, `879K` visible |
| Evidence commands | `history \| grep logs` |
| Accept | `ls -lh logs`, `ls -l -h logs` |
| Reject | `-h` without `-l`; sizes converted by hand |
| Red flags | — |
| Probe | "Did the `total` line change too?" |

### Exercise 4
| Field | Value |
|---|---|
| Goal | Finds hidden entries one level down, including a hidden directory |
| Expected end state | `.rotated` named as the directory; the leading dot named as the cause of invisibility |
| Evidence commands | `ls -A /labs/.../logs` |
| Accept | Told it was a directory by `-l`'s type character, by `-F`'s trailing `/`, or by listing it |
| Reject | Naming `.keep` as the directory; "it is a system directory" as the cause |
| Red flags | — |
| Probe | "Which of them is a directory, and how did you tell?" |

### Exercise 5
| Field | Value |
|---|---|
| Goal | Listing by path without `cd` |
| Expected end state | `strain-2187-04.log.2` and `strain-2187-05.log.1` shown |
| Evidence commands | `history` — no `cd` into `.rotated` |
| Accept | `ls logs/.rotated`; absolute path |
| Reject | A `cd` into it first |
| Red flags | — |
| Probe | "Why did you not need `-a` for this one?" |

### Exercise 6
| Field | Value |
|---|---|
| Goal | `-t` and `-r` as separate concerns |
| Expected end state | Newest-first has `strain-2187-06-12.log` at top; reversed has `hull-2187-06-10.log` at top |
| Evidence commands | `history \| grep -- '-t'` |
| Accept | `ls -t` / `ls -tr`; long forms |
| Reject | Sorting by the date *in the filename* — that is a name sort and gives a different answer here, by design |
| Red flags | Correct order but no `-t` in history |
| Probe | "Is the newest file the one with the latest date in its name?" (No — that is the trap.) |

### Exercise 7
| Field | Value |
|---|---|
| Goal | `-S` |
| Expected end state | `hull-2187-06-10.log` first |
| Evidence commands | `history \| grep -- '-S'` |
| Accept | `ls -S logs`, `ls -lS logs` |
| Reject | `-s` (lowercase) alone — that prints block counts and does not sort |
| Red flags | — |
| Probe | "Where did the smallest file end up, and which is it?" |

### Exercise 8 *(load-bearing)*
| Field | Value |
|---|---|
| Goal | Name, time and size are independent |
| Expected end state | Three orders written out; a statement that no two agree |
| Evidence commands | The written answer against the lab's actual state |
| Accept | Correct three orders. Name: hull, strain-11, strain-12, strain-13, thermal-13. Time (newest first): strain-12, thermal-13, strain-13, strain-11, hull. Size: hull, strain-12, thermal-13, strain-13, strain-11 |
| Reject | Any claim that two of the orders agree; the assertion that the date in the filename is the modification time |
| Red flags | Orders written without the corresponding commands in history |
| Probe | "Which file has the newest name and the oldest content? What would explain that on a real station?" |

### Exercise 9 *(load-bearing)*
| Field | Value |
|---|---|
| Goal | `-l` on a symlink argument reports the link, not the target |
| Expected end state | `ls current` → five files; `ls -l current` → one line beginning `l` and ending `current -> logs` |
| Evidence commands | `history \| grep current` |
| Accept | The stated rule in any phrasing: with `-l`, `ls` describes the link itself rather than following it |
| Reject | An answer that used `-d` to get the one-line output and concluded `-d` was necessary — it is not, and that misconception breaks exercise 16 |
| Red flags | Only one of the two commands in history |
| Probe | "What is `-L` for, then?" |

### Exercise 10
| Field | Value |
|---|---|
| Goal | `-d` |
| Expected end state | `ls -ld logs` → one line, type `d` |
| Evidence commands | `history \| grep -- '-ld'` |
| Accept | Explanation as "do not descend" or "treat the directory as the thing being listed" |
| Reject | "`-d` means directory" |
| Red flags | — |
| Probe | "What does `ls -d *` do in a directory of files?" |

### Exercise 11
| Field | Value |
|---|---|
| Goal | Sort order is a locale property; and this image ships only C locales |
| Expected end state | `Archive` before `archive` recorded; collation named; `locale -a` run, showing only `C`, `C.utf8`, `POSIX` |
| Evidence commands | `history \| grep locale` |
| Accept | Naming `LC_COLLATE` (or `LC_ALL`/`LANG` as the thing that sets it); reporting honestly that no alternative locale is installed, so the contrast cannot be demonstrated here |
| Reject | Claiming they demonstrated `en_US.UTF-8` ordering on this box — it is not installed, so they did not. Also reject "`ls` sorts capitals first" as a general fact |
| Red flags | A reported before/after that differs — impossible here; ask them to re-run |
| Probe | "You set `LC_ALL=en_US.UTF-8` and nothing changed. Why not?" |

### Exercise 12
| Field | Value |
|---|---|
| Goal | Column output depends on whether stdout is a terminal |
| Expected end state | `ls -1 logs` and a piped/redirected `ls logs` producing the same one-per-line output |
| Evidence commands | `history \| grep -E 'ls.*\\\|\|ls.*>'` |
| Accept | `ls logs \| cat`, `ls logs > f` then reading `f` |
| Reject | Explaining it as "pipes remove formatting" |
| Red flags | — |
| Probe | "Which program decided — `ls` or the pipe?" |

### Exercise 13
| Field | Value |
|---|---|
| Goal | `-v` |
| Expected end state | Default order has `run-10.log` before `run-2.log`; `-v` order runs 1,2,3,9,10,11,20 |
| Evidence commands | `history \| grep runs` |
| Accept | `ls -v runs`; also accept `sort -V` in a pipe **in addition** to the flag |
| Reject | Renaming the files with zero padding — correct engineering advice, wrong exercise |
| Red flags | — |
| Probe | "What is the default sort comparing, character by character?" |

### Exercise 14
| Field | Value |
|---|---|
| Goal | `-R`, and reading its labelled blocks |
| Expected end state | Answer: `deep` contains two directories at any depth (`deck-3`, `deck-3/bay-2`). Empty-directory reasoning stated |
| Evidence commands | `history \| grep -- '-R'` |
| Accept | The count 2; the reasoning that `empty-bay` appears as a label with no entries beneath it |
| Reject | A count of 3 that includes `deep` itself, unless they say so explicitly |
| Red flags | — |
| Probe | "How would the output differ if `empty-bay` had been unreadable rather than empty?" |

### Exercise 15
| Field | Value |
|---|---|
| Goal | Multi-argument output shape |
| Expected end state | Description mentioning per-directory labels ending in `:` and blank-line separation |
| Evidence commands | `history` |
| Accept | The script consequence: the first line is a label, not a filename, so the parse breaks |
| Reject | "It printed them one after another" with no mention of labels |
| Red flags | — |
| Probe | "What happens with `ls file1 dir1` — where does the file go?" |

### Exercise 16 *(Experiment — prediction required; load-bearing)*
| Field | Value |
|---|---|
| Goal | Separates two mechanisms: `-l`'s non-dereferencing, and a trailing slash forcing dereference |
| Expected end state | Five predictions, five observations, an explanation with two distinct causes |
| Evidence commands | `history` — all five present |
| Accept | Observed: `ls current` and `ls current/` both list the five files; `ls -l current` shows the link line; `ls -ld current` shows the link line; `ls -ld current/` shows a **directory** line. Explanation: `-d` stops `ls` descending, `-l` reports the link rather than the target, and the trailing slash is a path-level assertion that resolves the symlink before `ls` gets a choice |
| Reject | **Missing prediction — fail.** Also reject the conflation "`-d` and `/` do the same thing" — the `ls -ld current/` case exists specifically to break it |
| Red flags | Five predictions all exactly right, no `man` in history — probe |
| Probe | "Predict `ls -l current/` before running it." |

### Exercise 17 *(Experiment — prediction required)*
| Field | Value |
|---|---|
| Goal | `cd -` is a two-value swap, not a stack |
| Expected end state | Five predicted `pwd` values, five observed; explanation naming a single stored previous directory |
| Evidence commands | `history` |
| Accept | Ending back in `logs` after two `cd -`; the explanation that `OLDPWD` holds exactly one path and `cd -` swaps it with `PWD` |
| Reject | Missing prediction; "it goes back through history" |
| Red flags | — |
| Probe | "How would you get back two directories? What would you have to keep yourself?" (Leads to `pushd`/`popd` — do not require it.) |

### Exercise 18 *(Experiment — prediction required)*
| Field | Value |
|---|---|
| Goal | `ls -l`'s time column switches format by age |
| Expected end state | Prediction; then the observation that all five show a year; the rule stated as a distance from now |
| Evidence commands | `history \| grep date` |
| Accept | "Older or newer than about six months from now shows the year instead of the clock time." Accepting that all five here are ~161 years in the future is required |
| Reject | Missing prediction; "files from a previous year show the year" — every file here is dated 2187 and the container's clock is not, so that rule is untestable and wrong |
| Red flags | A prediction claiming some would show clock times, then an answer that quietly does not address it — that is fine as a *wrong prediction*, but the explanation must acknowledge it |
| Probe | "Touch a file to today's date and re-run. What does it show?" |

### Exercise 19
| Field | Value |
|---|---|
| Goal | Alias vs binary; two bypass methods |
| Expected end state | `type ls` (or `type -a ls`) showing the alias; two invocations of the real binary |
| Evidence commands | `history \| grep -E 'type\|\\\\ls\|command ls'` |
| Accept | `\ls`, `command ls`, `/opt/kestrel/bin/ls`, `'ls'`, `"ls"` — any two |
| Reject | `unalias ls` as one of the two methods (it removes the alias rather than bypassing it) unless they restore it and explain the difference |
| Red flags | Only `which ls` used — `01/03` established why that is the wrong tool |
| Probe | "Why does quoting the command name defeat an alias?" |

### Exercise 20
| Field | Value |
|---|---|
| Goal | Flag bundling |
| Expected end state | `ls -lhrtA logs` (any order of letters) plus an expansion into five separate flags |
| Evidence commands | `history` |
| Accept | Any permutation; separate flags also acceptable *if* they also give the bundle |
| Reject | `-a` instead of `-A`; missing `-h` or `-r` |
| Red flags | — |
| Probe | "Which of those letters could not be bundled if it took a value?" |

### Exercise 21
| Field | Value |
|---|---|
| Goal | `~-` |
| Expected end state | Contents of the previous directory listed from `bay-2`, no path typed, `pwd` unchanged |
| Evidence commands | `history \| grep '~-'` |
| Accept | `ls ~-`; accept `ls "$OLDPWD"` as a partial, then require the tilde form |
| Reject | Typing the path |
| Red flags | — |
| Probe | "Who expands `~-`, and when?" |

### Exercise 22
| Field | Value |
|---|---|
| Goal | Two entries, same contents, different kind |
| Expected end state | A command whose output differs — `ls -ld logs current` is the canonical one |
| Evidence commands | `history` |
| Accept | `ls -ld`, `stat`, `readlink`, `file`, `ls -i` on the two entries (note `ls -i logs current` lists *contents* and does **not** differ — if they used that and concluded "same", correct them) |
| Reject | A comparison of the two directory listings — those are identical, which is the premise, not the answer |
| Red flags | — |
| Probe | "If I deleted `logs`, what happens to `current`?" |

### Exercise 23 *(Dig)*
| Field | Value |
|---|---|
| Goal | Colour comes from `LS_COLORS`, populated by `dircolors` |
| Expected end state | `LS_COLORS` shown empty; `eval "$(dircolors -b)"` run; `ls --color=always ... \| cat -v` or a visible colour change demonstrated |
| Evidence commands | `history \| grep dircolors` |
| Accept | `eval "$(dircolors -b)"`; setting `LS_COLORS` by hand also counts if they explain what the values mean. The permanence answer must name a shell startup file without editing it |
| Reject | "Colour is off because it is a container"; editing `~/.bashrc` now (Chapter 11 owns it, and the exercise says not yet) |
| Red flags | `dircolors -b` producing an empty assignment and the student reporting success anyway — check whether `TERM` was set |
| Probe | "Why does `grep --color` work here when `ls --color` does not?" |

### Exercise 24 *(Dig)*
| Field | Value |
|---|---|
| Goal | Allocation is quantised |
| Expected end state | `ls -ls logs`; the pair identified is `strain-2187-06-11.log` (180 B) and `strain-2187-06-13.log` (1400 B), both reporting 4 blocks |
| Evidence commands | `history \| grep -- '-s'` |
| Accept | An explanation naming a fixed allocation unit; inferring 4096 bytes from the numbers is a strong answer but not required |
| Reject | Naming `hull` — its numbers agree; naming `thermal` alone |
| Red flags | — |
| Probe | "What is the smallest amount of disk a one-byte file can occupy here?" |

### Exercise 25 *(Dig)*
| Field | Value |
|---|---|
| Goal | `-U` |
| Expected end state | An order differing from the default (here: thermal, strain-13, strain-12, hull, strain-11) |
| Evidence commands | `history \| grep -- '-U'` |
| Accept | The forensic point in any phrasing: the order reflects how the directory was built up and reused, which sorting destroys |
| Reject | "It is random" |
| Red flags | An order identical to the default — they likely ran `ls -u` (access-time sort), which is a different flag |
| Probe | "What would change this order without any file changing size or name?" |

---

## Lesson roll-up

**Load-bearing — must PASS:** 8, 9, 16, and both of 6 and 7 together.

9 and 16 are the ones to hold the line on. A student who believes `-d` is what makes `ls` stop
following a symlink will misread every listing in Chapter 3, and will misdiagnose the Chapter 2
incident.

**Cap.** Missing written predictions on 16, 17 or 18 caps the lesson at PASS-WITH-NOTES.

**Note on exercise 11.** Reporting "I could not demonstrate it, because only C locales are
installed" is the *correct* answer, not a failure. A student who claims to have shown the contrast
here is reporting something that did not happen — probe it.
