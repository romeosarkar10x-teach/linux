# 13/04 — validation

For the validating agent. No flag. Ask, do not tell.

## Hard gates

1. The station is clean: `ncdu` and `ripgrep` purged, no `deck-lint` in
   `/usr/local/bin` or `~/.local/bin`, `dpkg --audit` silent. Lesson 06 depends
   on this; do not pass a student who left tools installed.
2. They installed something from the archive and something from a tarball, and
   can say which directories each landed in.
3. They can state the three losses from route three without prompting.

## Understanding — ask these

4. "`apt-cache policy htop` says not installed, and `htop` runs. Explain."
   Wanted: a second packaging system apt has no knowledge of; `command -v` and
   `man -w` both point at it. This is the load-bearing question of the lesson.
5. "How do you check whether a machine has a given command?" Wanted:
   `command -v`. If they answer `dpkg -l` or `apt list`, go back to 4.
6. "Why `/usr/local` rather than `/usr/bin`?" Wanted: the package manager never
   writes to `/usr/local`, so hand-installed files are never overwritten and
   never overwrite. Bonus: `/usr/local/bin` precedes `/usr/bin` on `PATH`, so a
   local copy shadows a packaged one — a feature and a hazard.
7. "Why list a tarball before extracting it?" Wanted: no undo; an archive
   without a single top-level directory scatters files into the current
   directory.
8. "You installed `deck-lint` by copying. What can you no longer do?" Wanted:
   upgrade it, attribute its files, remove it with one command.
9. "Your script needs `jq`. What does it do at start-up?" Wanted: check with
   `command -v`, fail early with a clear message, do not install anything.
10. "Archive version 1.2 or upstream 2.0 as a tarball?" Any argued answer.
    Reject an unargued preference in either direction.
11. "`curl | sudo bash` — what is the objection?" Wanted: unread code, run as
    root, unverified, unrecorded, unremovable.

## On the arc

12. Exercise 59: they must report that no station-wide record exists. If they
    offer `ls -l`'s mtime and owner as provenance, ask what `touch` and `chown`
    do to that claim. The correct end state is "`/usr/local` records nothing,
    by design" — held as a fact, not as a suspicion about anyone.
13. Nobody in this lesson has done anything wrong. If the student's writeup
    reads as an accusation, ask them which sentence they could defend to the
    person accused.

## Common failure modes

- Trusting `apt list --installed` as a census of what is on the machine.
- Extracting a tarball without listing it first, then losing track of the mess.
- Copying into `~/.local/bin` and not understanding why nothing runs.
- Forgetting `sudo mandb` after installing a page into `/usr/local`.
- Leaving `ripgrep` installed, which quietly defuses lesson 06.
