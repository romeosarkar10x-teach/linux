# 03/02 — Validation

For the agent in **validator mode**. Read `docs/VALIDATION_PROTOCOL.md` first. Grade the student's
log and the lab state; there is no auto-grader.

**Inode numbers are not fixed.** They change on every seed and differ per machine. Never grade
against a literal number. Grade the *relations*: same/different, count before/after, and whether the
student's own captured numbers are internally consistent.

Run `kestrel reset 03/02` before checking anything that depends on a clean lab; several exercises
instruct the student to reset mid-lesson, so lab state alone proves little. The log is the evidence.

---

## Warmup

**1.** *Goal:* one command yields inode numbers for all entries including hidden.
*Accept:* `ls -ia roster` or `ls -lia roster`, and a written list covering `.`, `..`, `.backup`,
`copy.txt`, `crew-list.txt`, `roster.txt`.
*Reject:* two commands; any listing missing `.` and `..`.
*Probe:* "which of those numbers appears twice?"

**2.** *Accept:* `roster.txt` and `crew-list.txt` named as the pair, `copy.txt` as the odd one out.
*Reject:* naming `.backup` as the pair (it is a directory with its own number).
*Red flag:* the student says the pair share a number "because they have the same contents" — that is
exercise 5's trap, arriving early. Note it and let 5 correct them.

**3.** *Accept:* second column of `ls -l` output, value 3.
*Reject:* "the number after the permissions" without a position; counting the inode column when
`-i` was left on and shifting everything by one — check which command they actually ran.

## Core

**4.** *Accept:* a single `stat -c '%i %h %s %n'` with four path arguments (a glob that reaches
`.backup/names.txt` is fine, `roster/*` alone is not — it misses the hidden directory).
*Evidence:* four lines; three share an inode and show `3`; one is unique and shows `1`.
*Reject:* four separate `stat` calls.

**5.** *Accept:* `cmp` (silent = identical) or `diff`; plus a sentence saying identical contents are
not identity — two inodes can hold the same bytes.
*Reject:* `ls -l` sizes offered as proof; `md5sum` is acceptable as a byte comparison but ask the
probe.
*Probe:* "if I edit one of them now, does the other change? Which pair, and why?"

**6.** *Accept:* `roster/.backup/names.txt`, found by listing the hidden directory, with the
reasoning that the count said 3 and only 2 were visible.
*Reject:* found by `find` (that is Dig 26; if they jumped ahead, accept but note it).
*Red flag:* "the third link is `.`" — a fundamental confusion; send them back to L1 of the tutor
ladder.

**7.** *Expected end state:* `roster.txt` and `crew-list.txt` both show the appended line;
`copy.txt` does not.
*Accept:* both results explained by "the same inode versus a different one".
*Reject:* explaining `copy.txt` as "not updated yet" or as a caching effect.

**8.** *Evidence:* link count 3 before `ln`, 4 after, 3 after the `rm`.
*Accept:* `manifest.txt` reads the roster contents after `roster.txt` is gone.
*Reject:* `ln -s` used — a symlink here would dangle after the `rm`, and if the student's
`manifest.txt` still reads fine, check they did not simply skip the deletion.
*Red flag:* surprise that the data survived. Genuine, but it means 14–15 will need care.

**9.** *Accept:* the question has no answer, supported by `stat` on both names showing an identical
record, or by the observation that the directory entries are the same kind of thing.
*Reject:* "the one created first", "the one with the original name", or anything appealing to
creation order — nothing on disk records it. `Birth` in `stat` belongs to the inode, and is the same
for both names, so quoting it *supports* the correct answer, not the wrong one.

**10.** *Accept:* one `stat -c '%i %h %n'` with four arguments; `decks` shows 5, each `deck-N` shows 2.

**11.** *Accept:* five entries named individually — `decks` as it appears in the lab root, `.` inside
`decks`, and `..` inside each of `deck-3`, `deck-4`, `deck-5`.
*Reject:* "three subdirectories plus two" without naming which two.
*Probe:* "which directory holds the entry that is the fifth link?"

**12.** *Evidence:* a prediction written before the check. `deck-3` is 2 (itself plus its own `.`; no
subdirectories). A freshly made empty directory is also 2.
*Reject:* a prediction supplied after the number.

**13.** *Accept:* at least three paths resolving to one inode — e.g. `.`, `decks/..`,
`decks/deck-3/../..`, all giving the lab root's number.
*Reject:* an argument from documentation with no numbers.

**14.** *Evidence:* both names share an inode, count 2; after `rm`, the survivor has the *same* inode
and count 1.
*Accept:* "the `rm` removed a directory entry and decremented the count; it did not touch the inode
or the data".
*Red flag:* a different inode number after the `rm` means they reset the lab in between and did not
say so — ask.

**15.** *Accept:* names `unlink`.
*Reject:* "delete" or "remove" as the syscall name.

**16.** *Evidence:* the copies have new inode numbers and link count 1; `crew-list.txt` and
`roster.txt` in the copy are now two independent files.
*Accept:* `-d`, `--preserve=links`, or `-a` (which implies it) found in `man cp`, with a note that
`-a` alone is the usual answer.
*Reject:* `-p` — it preserves mode and timestamps, not link structure.

**17.** *Evidence:* the append fails with `Permission denied`; the `rm` prompts
`rm: remove write-protected regular file 'locked/notes.txt'?` and succeeds on `y`.
*Accept:* an explanation naming the file's mode for the failure and the *directory's* write
permission for the success.
*Reject:* "root can delete anything" (they are `cadet`); "the prompt means it asked permission" — the
prompt is `rm` being cautious, not the kernel granting anything.
*Probe:* "if you had run `rm -f`, what would have changed? Anything about permissions?" Correct
answer: only the prompt.

**18.** *Accept:* remove write permission from `locked/` — the directory, not the file — verified with
`ls -ld locked`.
*Reject:* any answer that changes `notes.txt`'s mode.

**19.** *Evidence:* append succeeds; `rm` fails with
`rm: cannot remove 'sealed/bolted.txt': Permission denied`; creating a new file fails the same way.
*Accept:* a one-sentence rule of the form "what you may do *to* a file is the file's mode; what names
may exist in a directory is the directory's mode".

## Experiment

**20.** *Load-bearing.* *Evidence:* a written prediction, then
`ln: decks: hard link not allowed for directory`.
*Accept:* an explanation covering ambiguous `..` and unbounded traversal — `find`, `du`, `rm -r` and
`pwd` all assume the tree is a tree.
*Reject:* no prediction recorded; "because directories are special" with no mechanism.
*Red flag:* claiming root could do it. On Linux it is refused for everyone.

**21.** *Load-bearing.* *Evidence:*
`ln: failed to create hard link '/home/cadet/x' => '...': Invalid cross-device link`, plus `df`
output showing one device and `%d` showing two different numbers.
*Accept:* the reconciliation — a hard link is an entry pointing at an inode *number*, which is only
meaningful within one filesystem; `/labs` and `/home/cadet` are separate mounts even though the same
physical disk backs them, and the kernel's device number is the authority.
*Reject:* "different partitions" as a bare claim; `df` disproves it.

## Stretch

**22.** *Evidence:* the same inode number before and after `mv`.
*Accept:* rename edits directory entries only; across filesystems `mv` must copy every byte and then
unlink the source, which is why it is slow and why it can fail halfway.

**23.** *Accept:* either outcome reported honestly. Reuse is common but not guaranteed.
*Accept the conclusion:* an inode number identifies a file only while at least one name for it still
exists; it is unsafe as a stored identifier across a deletion.
*Reject:* "inode numbers are unique forever".

**24.** *Accept:* `stat -c '%d %i %n'` (or `%D`/`%i`), with the reasoning that inode numbers restart
per filesystem, so two mounted filesystems can both contain inode 44805.

**25.** *Evidence:* before — two names, one inode, count 2. After — two names, two inodes, counts 1
and 1, different contents, and no `rm` anywhere in the log.
*Accept:* `cp` to a third name then `mv` over one original; any equivalent that never unlinks
explicitly.
*Reject:* an `rm` in the transcript.
*Probe:* "so what does an editor that saves by write-and-rename do to a file you had hard-linked?"

## Dig

**26.** *Accept:* `find . -samefile roster/roster.txt` and `find . -inum <n>`, both yielding the three
paths; `-samefile` preferred in a script because it needs no number and survives a re-seed.
*Reject:* only one of the two options found.

**27.** *Accept:* the data is not freed while a process still holds the file open; the space returns
when the last descriptor closes.
*Reject:* answers about the trash, journaling, or recovery tools.

**28.** *Accept:* the totals read off `df -i /labs`, plus the failure mode — a filesystem with free
blocks that cannot create a file because it has no free inodes, which `df -h` reports as having room.

---

## Load-bearing exercises

A student who has not got these has not got the lesson, whatever else is in the log:

- **6** — found the third name from the count, not from a search.
- **11** — accounted for all five directory links by name.
- **14/15** — knows `rm` unlinks a name and named the syscall.
- **17** — deletion is governed by the directory's permission.
- **20/21** — the two things `ln` refuses, each with a mechanism.

If 17 is wrong, do not pass the lesson. Chapter 10 builds directly on it and the capstone assumes it.
