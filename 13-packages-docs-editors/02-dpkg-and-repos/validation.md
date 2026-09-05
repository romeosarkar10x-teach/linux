# 13/02 — validation

For the validating agent. No flag. Ask, do not tell.

## Hard gates

1. `/etc/apt/sources.list.d/station.list` is back to its original contents,
   `[trusted=yes]` included, and `sudo apt update` is clean. Exercise 40 breaks
   this on purpose and exercise 42 fixes it; a student who stopped at 40 will
   find lesson 04 mysteriously broken.
2. `dpkg -l 'hatch*'` reports nothing — they purged what they installed.
3. They have personally seen the `iU` state and can reproduce it on request.
4. They can name what `-c` and `-I` do without looking.

## Understanding — ask these

5. "What is the difference between apt and dpkg, in one sentence?" Wanted: apt
   decides what to install and where to get it; dpkg installs it. Anything
   about "apt is newer" is a fail.
6. "You ran a program from a package that failed to install. Explain." Wanted:
   unpacking puts files on disk, configuring is a separate step, and the kernel
   does not consult dpkg before executing a file.
7. "Why did `apt -f install` remove `hatch-report`?" Wanted: the missing
   dependency was in no repository, so the only available way to reach a
   consistent state was removal.
8. "Why can `dpkg -i` downgrade when `apt` refuses?" Wanted: dpkg has no
   candidate list and no policy; it does what it is told.
9. "`dpkg -V` printed a difference. What did it exit with?" Wanted: 0. If they
   guess 1, have them run it. Then: "so what does your script test?"
10. "What does `[trusted=yes]` actually switch off?" Wanted: verification of the
    archive against a key. Not encryption, not the download, not dpkg's own
    behaviour. Bonus: it is the correct setting for a local mirror.
11. "Why did `apt update` refuse the source without it?" Wanted: no `Release`
    file, so there is nothing to verify — refusal, not a signature failure.
12. "Give me a file on this station that `dpkg -S` cannot attribute, and say
    what that gap means." Wanted: anything under `/labs` or `/usr/local`; the
    gap is that dpkg only knows what dpkg installed.
13. "Where would you look to find when a package was installed?" Wanted:
    `/var/log/dpkg.log`, with the caveat that it rotates.

## On the arc

14. If the student concludes that the extra source file in `sources.list.d` was
    put there maliciously, or by a named person, push back once: what in the
    evidence supports that? The correct position after this lesson is that a
    file exists, it is unsigned, and nobody has established who wrote it.
15. If they instead say "it is probably fine, unsigned local repos are normal" —
    accept it. It is also correct, and it is the reason the trace survived.

## Common failure modes

- Measuring a pipeline's exit status instead of `dpkg`'s (exercise 23).
- Reading only the last line of a dpkg error.
- Believing `dpkg -V`'s exit status.
- Leaving apt in the broken state from exercise 40.
- Treating `dpkg -S` as a filesystem search.
