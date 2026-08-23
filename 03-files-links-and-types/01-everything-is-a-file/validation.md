# 03/01 — Validation

Grade the reasoning, not the transcript. A student who ran the right command and drew the wrong
conclusion has not passed the exercise.

---

| # | Goal | Expected end state | Evidence commands | Accept | Reject | Red flags | Probe |
|---|---|---|---|---|---|---|---|
| 1 | Read the type column | Seven names, seven characters, correctly paired | `ls -l types` | All seven of `s d p l - b c` present and matched to the right names | Any pair swapped; fewer than seven listed | Only `-` and `d` named; the rest called "other" | "Which entry is the block device and how do you know from this line alone?" |
| 2 | Recall the seven | Written definitions, self-marked | student notes | All seven defined in the student's own words; wrong ones flagged honestly | Definitions copied verbatim from the readme with nothing marked wrong | No errors admitted at all | "Which one did you have to look up?" |
| 3 | `-F` blind spot | Markers listed; device nodes and regular files identified as unmarked | `ls -F types` | States that `b` and `c` get no marker, and that regular files get none either | Says `-F` shows all types | Claims device nodes got a marker | "In `-F` output, how would you tell `scratch-disk` from `regular.txt`?" |
| 4 | `stat` format string | One command, seven typed lines | `stat -c '%n %F' types/*` | Uses one invocation with a glob and `%F` | Seven separate `stat` calls | Uses `ls` and reads the character off | "What does `%F` print for a symlink, and did your glob pass the link or its target?" |
| 5 | `stat` vs `file` wording | Table; three differences named | `file types/*` | Names fifo/socket/device wording differences correctly | Says the two tools disagree about the *facts* | Treats one tool's wording as the authoritative name | "If a script parsed `file` output for the word `fifo`, would it match `stat`'s?" |
| 6 | Read a char device | `0` reported; behaviour explained | `head -c 10 types/void \| wc -c` | Says the read returned end-of-file immediately, not that the file was empty | "The file has nothing in it" with no notion of a driver | Concludes the device is broken | "Is 0 bytes here the same fact as 0 bytes from `sizes/nothing.txt`?" |
| 7 | Write to a char device | Write succeeds; read still empty | `echo hello > types/void; cat types/void` | Identifies the write as discarded by the driver | Thinks the write failed | Believes the data is stored somewhere retrievable | "Did the shell report an error? Then where did the bytes go?" |
| 8 | Major/minor identity | `1, 3` identified as the shared field | `ls -l /dev/null types/void` | Names major and minor, and concludes the two nodes address the same driver instance | Says they are the same because both are 0 bytes | Says the names being different means the devices differ | "If I made a third node with `c 1 3`, how many devices would exist?" |
| **9** | Symlink size | 11 bytes = length of `regular.txt` | `ls -l types/pointer` | States the size is the target path string's length | Says 11 is the target file's size | Says a symlink "contains" the file | "What size would a link to `/a` be?" |
| **10** | `-L` semantics | Both lines fully accounted for | `ls -l`, `ls -lL types/pointer` | Explains `l`→`-`, size 11→36, arrow disappearing, all as "the tool now describes the target" | Notices the difference without naming which object each line describes | Thinks `-L` "fixed" the listing | "Which of the two lines would change if I edited `regular.txt`?" |
| 11 | `file` vs extension | Seven rows; two disagreements marked | `file manifest/*` | Marks `panel.png` (text) and `survey.txt` (gzip) | Marks only one, or marks `hull-log` (which has no extension to lie) | Concludes the files are corrupt | "Is `panel.png` broken?" |
| 12 | `empty` | `file` says `empty` | `file manifest/empty` | Explains that `empty` distinguishes "no bytes" from "bytes that look like text" | Just reports the word | Says the file does not exist | "Why can't `file` call a zero-byte file ASCII text?" |
| **13** | Encodings | `ISO-8859 text` vs `Unicode text, UTF-8 text`; byte counts | `file`, `od -c manifest/latin1.txt` | Shows `351` as one byte and the em dash as three (`342 200 224`), and links byte count to the verdict | Reports the two `file` answers without the dump | Calls the ISO-8859 file "corrupt" or "wrong" | "Which byte made `file` rule out UTF-8?" |
| 14 | MIME output | Two MIME types reported | `file -i manifest/survey.txt manifest/panel.png` | `application/gzip` and `text/plain`, plus a scripting or HTTP use case | Only the two strings, no use case | Thinks `-i` inspects more deeply than the default | "Which form would you parse in a script, and why?" |
| **15** | FIFO blocks | Prediction written *first*; socket error captured; hang experienced | `cat types/control.sock`, `cat types/pipeline` | Prediction predates the runs; quotes `No such device or address`; describes the hang as waiting, not crashing | Prediction written after the fact, or absent | Reports killing the container or "fixing" the FIFO | "What would have to happen for `cat types/pipeline` to return?" |
| **16** | Detached block device | Three outputs reconciled | `head -c 10 types/scratch-disk`, `stat -c '%s %b'`, `file -s` | Quotes `Operation not permitted`, notes size 0 blocks 0, and concludes the node names a driver with nothing attached | Concludes the file is empty | Concludes the disk is full or damaged | "Does the node existing mean a device exists?" |
| 17 | `test` loop | Loop reproduces exercise 4's output | student's loop | Correct flag per type, including `-L` before `-f` (a symlink to a regular file passes `-f`) | Loop reports `pointer` as a regular file and the student does not notice | Claims the loop is equivalent in every way | "What does your loop say about `pointer`, and what does `stat -c %F` say?" |
| **18** | Two kinds of zero | Three `stat` triples; the distinction stated | `stat -c '%s %b %B' sizes/four-k.txt sizes/nothing.txt types/void` | Says `nothing.txt` is a real file with no bytes, `void` has no bytes *to* have | Treats both zeros as the same fact | Says the device is an empty file | "Could you make `nothing.txt` non-zero? Could you make `void` non-zero?" |
| 19 | Magic numbers | `\177ELF` and `#!` shown | `od -c manifest/hull-log \| head -1` | Shows both first-byte sequences and ties each to `file`'s verdict | Reports `file`'s output only | Says `file` used the executable bit | "If I stripped the `#!` line, what would `file` say?" |
| 20 | `man file` | `-h/--no-dereference` and `-L/--dereference` found | `man 1 file` | Explains that the default flips with `POSIXLY_CORRECT`, so both directions need a name | Names the options without the reason | Invents a reason not in the man page | "What is the default on this system, and how do you know?" |
| 21 | `mknod` semantics | `c 1 5` = a second `/dev/zero` | `man 1 mknod`, `ls -l /dev/zero` | Names `/dev/zero` and cites the major/minor as the evidence | Guesses from the letter `c` alone | Says it would create a new kind of device | "What makes it a duplicate rather than a new device?" |
| **22** | Why root | `mknod: mine: Operation not permitted` | as given | Quotes the error and explains that a device node is an access path to a driver, so creating one is a privilege escalation route | Says only "you need root" | Says the directory is read-only, or that the filesystem does not support it | "What node would you create if you wanted to read the whole disk?" |

## Load-bearing

Exercises **9, 10, 13, 15, 16, 18, 22**. A student who passes everything else and fails these has
learned the vocabulary and not the model.

- **9 and 10** carry Chapter 3 lesson 3 entirely. If the student thinks a symlink contains the file
  rather than the path, the whole hard-vs-soft lesson lands wrong and the incident is unsolvable.
- **13** is the one place in this lesson where the student reads bytes to settle a question a tool
  answered in prose. That habit is the course.
- **15 and 16** are the two failures. A student who "fixed" either has misunderstood both.
- **18** separates size-as-measurement from size-as-not-applicable, which Chapter 14 depends on.
- **22** is the security reasoning; do not accept "needs root".

Do not pass the lesson while the student still says "everything is a file" as a slogan. Ask them for
two things in this lab that are not storage. If the answer is not immediate, go back to exercise 1.
