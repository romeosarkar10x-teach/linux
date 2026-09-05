# Solutions — Triage  ·  AGENT EYES ONLY

**Student: do not open this file.** The tutor may read it to know where it is
steering and must never quote it. No flag in this lesson.

Values marked *(varies)* depend on when the student started the process.

---

## A. Warmup

1. `uid=1005(cadet) gid=1008(cadet) groups=1008(cadet),27(sudo),999(plocate),1001(crew)`.
   The `sudo` group is the one that matters later.
2. `ops-bot:x:1004:1007::/home/ops-bot:/usr/sbin/nologin` — name `ops-bot`,
   password in shadow, uid 1004, gid 1007, empty GECOS, home
   `/home/ops-bot`, shell `/usr/sbin/nologin`.
3. **Exit 2.** No such account. `getent` exits 2 when the key is not found.
4. Nine-ish *(varies)*. A container runs one process tree from an init stub;
   there is no init system, no logging daemon, no getty per tty.

## B. Accounts

5. `awk -F: '$3>=1000 && $3<65534 {print $1, $3, $7}' /etc/passwd` →
   `ubuntu 1000`, `rhea 1001`, `cass 1002`, `dorn 1003`, `ops-bot 1004`,
   `cadet 1005`. Accept `$3>=1000` alone with `nobody` (65534) included if they
   notice it.
6. `ops-bot`, shell `/usr/sbin/nologin`.
7. `crew: rhea,cass,dorn,cadet`. `ops: dorn,ops-bot`.
8. `ops-bot` is in `ops` only. `dorn` is in both.
9. `rhea` has `engineering` (gid 1002). Nobody else does. This is the group
   that has been refusing the student access since chapter 10.
10. `cat: /etc/shadow: Permission denied`. `ls -l` shows
    `-rw-r----- 1 root shadow`, so only root and the `shadow` group can read it.
11. `sudo awk -F: '{print $1, substr($2,1,3)}' /etc/shadow`:
    `rhea`, `cass`, `dorn`, `cadet` have `$y$` (yescrypt) hashes; `ops-bot` and
    `ubuntu` have `!`; the system accounts have `*`. `!` means the password is
    locked — no password will ever match. `*` means the same thing by a
    different convention. Neither prevents `sudo -u` from running something as
    that account, and that is the point.
12. Model: *"The account `ops-bot` has uid 1004, is a member of `ops`, and its
    login shell is `/usr/sbin/nologin`."* Reject anything containing "automated",
    "unattended" or "nobody is watching it" in a `says` line.

## C. What is running

13. Only the student's own shell and whatever they started. Before exercise 14
    there is nothing owned by `ops-bot`.
14. `pgrep -u ops-bot -f strain-summary` returns one pid *(varies)*.
15. A `sleep 5`. It changes every run because the script spawns a fresh `sleep`
    each cycle — the pid is different because it is a different process, not
    because a pid changed.
16. The parent is a `sudo` process owned by **root**. `lstart` is the wall-clock
    start; `etimes` is seconds since.
17. `docker-init(1)---sudo(PID)---strain-summary(PID)---sleep(PID)`.
18. `sudo` starts as root, and root may `setuid()` to another account before
    exec'ing. Privilege is dropped, never gained, by the child.
19. `State: S (sleeping)` — it is in `sleep`. `PPid:` is the sudo pid. The four
    `Uid:` numbers are real, effective, saved-set and filesystem uid, all 1004
    here; they differ for setuid programs, which is lesson 04's subject.
20. `tr '\0' '\n' < /proc/PID/cmdline` → `/bin/bash` and
    `./bin/strain-summary`.
21. `Permission denied`. `environ` is mode 400 to the process owner.
22. **It fails**, with the same `Permission denied`, because the shell — running
    as cadet — opens the file to build the redirection before `sudo` is ever
    executed. `sudo` never sees the file.
23. `sudo cat /proc/PID/environ | tr '\0' '\n'`. `STRAIN_TOLERANCE` is **not**
    set — the script falls back to its `${STRAIN_TOLERANCE:-6.0}` default. A
    student who reports "tolerance is configured to 6.0" has over-read the
    evidence: what is configured is a default in the script.
24. `/labs/15-capstone-kestrel-breach/02-triage`.
25. `deck-watch` is owned by `cadet`, has a bash parent (the student's shell),
    and a small `etimes`. For "how long has this been running", quote
    **`lstart`** — an absolute time survives being copied into a report, and
    `etimes` does not.
26. It exits, the pid is gone, and `ps` shows nothing. Five seconds later they
    would have seen it and concluded it was running. A snapshot is a snapshot.

## D. Open files

27. `3w` → `var/summary.log`, `4w` → `var/summary.err`, `255r` → the script
    itself.
28. bash opens the script it is executing on a high descriptor (255) and reads
    the file as it goes, which is why editing a running script can corrupt its
    execution mid-run. Worth saying out loud.
29. `ls -l /proc/PID/fd` — same symlinks, no package required. `lsof` is the
    convenience; `/proc` is the source.
30. One `cycle=` line every five seconds, plus one `start` line.
31. `strain-summary: value 6.1 above tolerance 6.0, clamped` (values vary). It
    goes to fd **4**, `var/summary.err` — a path nobody reads. It has been
    complaining the whole time.
32. Any line where `raw` exceeds 6.0 and `reported` is exactly `6.0`.
33. `grep -c clamped var/summary.err` over the cycle count in `summary.log`.
    Roughly a third *(varies)*.
34. Nothing visible happens.
35. `sudo lsof -p PID` still shows fd 3, now with **`(deleted)`** appended and a
    `NLINK` of 0. The `sleep` child shows it too — it inherited the descriptor.
36. Yes, still writing, into an unlinked inode. The data is reachable through
    `/proc/PID/fd/3` for exactly as long as the process lives.
37. `sudo cat /proc/PID/fd/3 > recovered.log`, or `cp` from the same path.
38. The last reference to the inode would have closed and the data would be
    gone with no way back. That sequence — delete the log, restart the service
    to "fix" it — destroys exactly the evidence you came for.

## E. Experiment

39. Most students predict `pgrep strain-summary` fails and that `-f` is
    required. **It succeeds**: bash sets the process's `comm` to the script
    name, and `strain-summary` is 14 characters, inside the 15-character limit
    `pgrep` matches against. `-f` matches the full command line instead, which
    is what you need when the name is `bash` or when you want to match an
    argument. A student who predicted correctly should be asked what would have
    happened if the script were named `strain-summariser` (16 characters:
    `pgrep` without `-f` would miss it).
40. `lstart` is fixed; `etimes` increases every time. Only one of them can be
    pasted into a report.
41. Prediction should be: **no**, `kill` fails with
    `Operation not permitted`, because the process is owned by `ops-bot` and
    cadet is neither its owner nor root. Signals require matching real or
    effective uid, or `CAP_KILL`. Accept a correct prediction with a wrong
    reason at partial credit; the reason is the exercise.
42. Sometimes visible, sometimes not — the `sleep` exists for five seconds out
    of every five, but `ps` samples at one instant and the child is respawned.
    The honest description is that the child is short-lived and `ps` is a
    sample.

## F. The logs

43. `eng-access.log` 13, `crew-shell.log` 9.
44. `awk '{print $3}' access/eng-access.log | sort -u` → **three**: `dorn`,
    `eng-svc`, `rhea`.
45. `eng-svc`. `getent passwd eng-svc` exits 2.
46. **Twice**, both on **2187-01-18 at 03:26:12**: a `move` of
    `/mnt/eng-archive/strain/summary/pre-2186-10/` into
    `/mnt/eng-archive/.retired/`, and a session `close`.
47. No, it does not appear in `crew-shell.log`. That means no interactive shell
    session was recorded for it on the station host. It does **not** mean the
    account never existed, was never used, or is not still configured
    somewhere — the two logs come from two different hosts. Students who say
    "so it was never a real account" have over-read; that is the exact error
    rule 7 is aimed at.
48. `2187-02-02` back to `2187-01-18` is not the largest; for `rhea` the largest
    gap is **2187-04-27 to 2187-06-03**, 37 days. Any correct pipeline is
    accepted — typically `awk` to pair account and date, `sort`, then a
    `date -d` difference or a manual count. The point is that they computed it.
49. The last line, `2187-05-23 09:00:14 cadet login pts/0`, is out of order.
    `sort -c access/crew-shell.log` reports
    `disorder: 2187-05-23 09:00:14 cadet login pts/0` and exits 1. It is **not**
    a finding: it is the student's own arrival, appended when the copy was
    taken. Report it as noise, with the reason.
50. `dorn`, `2187-05-24 04:12:38` — the same minute as
    `brief/handover/notes.txt` in lesson 01. Cross-artefact corroboration is
    the first real timeline work in the chapter, and lesson 03 is built on it.

## G. Stretch and Dig

51. Three or more claim files, all passing `roe-check` from lesson 01 if they
    copied it across; otherwise the same six fields by hand.
52. **2186-10-06 02:14.** Every other date in this chapter so far is in May or
    June 2187. It is seven and a half months older than the rest and nothing in
    lesson 02 explains why. Do not resolve this; it is lesson 03's subject.
53. ```bash
    #!/bin/bash
    set -euo pipefail
    ps -eo pid=,user=,lstart=,cmd= |
        awk -v me="$(id -un)" '$2 != "root" && $2 != me'
    ```
    Silence when there is nothing to report is the requirement; a script that
    prints a header unconditionally fails it.
54. `etime` (human, `[[DD-]hh:]mm:ss`) and `etimes` (seconds). On a process
    running two minutes: `01:53` and `113`.
55. `lsof +L1` — selects open files with link count below 1. It shows the
    deleted `summary.log` held by both the summariser **and** its `sleep`
    child, which is a good moment to point out descriptor inheritance.
56. `pgrep -o` — oldest only. Right when you want the long-running parent and
    not its short-lived children. Dangerously wrong when you feed it to `kill`
    on a pattern that matches more than you think, because it silently picks
    one of several.

---

## Load-bearing

Exercises **3, 6, 11, 18, 22, 27, 31, 35, 36, 38, 45, 46, 47, 50, 52** must
pass. 22, 38 and 47 are where students most often produce a confident wrong
answer.
