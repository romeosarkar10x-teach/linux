# Solutions — Remediation  ·  AGENT EYES ONLY

**Student: do not open this file.** No flag in this lesson; the chapter flag is
in lesson 05.

## A. Survey before you touch

1. **Five** fail, one passes (the loop is not running, because nothing has been
   started yet). Exit status **1**.
2. In order: a string in any file under `eng/repo.d`; the mode of
   `station/var`; the count of files with the setuid bit under the lab; whether
   `backup/strain-summary.orig` and the live script differ; a string in
   `home/ops-bot/.bashrc`; whether any process matches `summariser/loop`.
3. Several answers are defensible; the strongest is the **apt check**. It greps
   for the literal string `trusted=yes`, so a source configured the same way by
   another spelling, or a second unsigned mirror added under a different name,
   passes. The summariser check is also weak: it proves the live file matches
   the backup, not that the backup is good. Accept either with reasoning.
4. `station/var` at `1777`, and `station/summariser` at `775` group-writable by
   `ops`. The second is arguable and should be *recorded*, not necessarily
   changed — good students raise it.
5. `-perm -4000` finds `./bin/eng-scan`. `-perm -2000` finds nothing, and exits
   **0** anyway — `find` does not signal "no matches", which is worth pointing
   out to anyone using its exit status in a script.
6. `bin/eng-scan` (root), and everything under `station/summariser`,
   `station/var` and `home/ops-bot` (**ops-bot**, which owns the most).
7. Any capture. The point is that they have a before state to diff against; a
   student who skips this cannot honestly fill in the `before` field later.

## B. Close

8. `eng/repo.d/third-party.list`, line 2.
9. Signature verification — the package manager installs from that source
   without checking that anything came from who it claims.
10. `station.list` uses plain `http` with no `trusted=yes`. It still verifies
    signatures, so its packages are authenticated even though the transport is
    not. Different problem, much smaller. A student who says "http is the
    problem" has the wrong end of it.
11. Any of the three, if justified. Deleting the file is cleanest; commenting
    the line preserves the evidence of what was there, which on a system under
    investigation is often the better call. Reject "I deleted it" with no
    reason.
12. `grep -rn 'trusted=yes' eng/repo.d/; echo $?` → no output, exit 1.
13. It does not remove or re-verify anything **already installed** from that
    mirror. Those packages are still on the system and still unverified. The
    fix is a package audit and reinstall from a trusted source, which is out of
    scope here — it belongs in the report as an open item, and exercise 54
    turns it into a brief.
14. `1` sticky, `7` owner rwx, `7` group rwx, `7` other rwx.
15. The final `7` — world-writable — is the problem. The sticky `1` is a
    *mitigation* and should be kept: it stops one account deleting another's
    files in a shared directory.
16. `sudo chmod o-w station/var` → `1775`. They need `sudo`; the directory is
    ops-bot's and cadet gets `Operation not permitted` without it.
17. `stat -c '%a' station/var` → `1775`. `chmod 775` would have given `775`,
    silently dropping the sticky bit. This is the whole argument for symbolic
    modes and it is worth making them try both.
18. Directory permissions govern creating, deleting and renaming *entries*, not
    the contents of files already there. Existing files keep their own modes.
    With the sticky bit set, a file can be deleted by its owner, by ops-bot as
    the directory owner, and by root — not by everyone.
19. `bin/eng-scan`, owned by `root:root`, mode `4755`.
20. `eng-scan: running as uid 1005, euid 1005`.
21. Let them sit with it. Setuid says "run as the owner", the owner is root,
    and the effective uid is theirs.
22. The kernel refuses to honour setuid on interpreted files. Historically this
    is because of an unavoidable race between the kernel checking the file and
    the interpreter opening it by name, plus the interpreter's own environment
    and argument handling being trivially subvertible. So this file grants no
    privilege — but it is **not** harmless: it is a mode nobody set by accident,
    it will show up on every audit, and it may indicate an attempt that failed
    rather than an absence of one. Accept "harmless in effect, significant as
    evidence".
23. `sudo chmod u-s bin/eng-scan`.
24. `find . -perm -4000` → nothing; `./bin/postcheck` shows that check PASS.

## C. Fix

25. The live script replaces any value above 6.0 with `$STRAIN_TOLERANCE`
    (default 6.0) and logs that to stderr; the backup reports each raw value
    unchanged.
26. Cycles **3, 4, 6, 7, 10** — raw 6.1, 6.8, 6.6, 7.3, 6.5, all reported
    as 6.0.
27. **Five** lines, one per clamp, naming the cycle and the original value. The
    program has been recording exactly what it discarded, on a stream nobody
    captured. Same shape as lesson 02's `summary.err`.
28. **7.3**, at cycle 7.
29. Mean **5.88** (accept 5.9), and **five** values above 6.0. E.g.
    `awk '{s+=$2; if($2>6)e++} END{print s/NR, e}' station/var/raw-sample.txt`.
30. The report says peak 6.0, mean 5.6, exceedances 0. The clamped run gives
    peak 6.0 and mean 5.55, which rounds to 5.6. The true run gives 7.3 and
    5.88. **The report was produced by the clamping version.**
31. Model: *"The report's three figures match the output of the clamping
    summariser and do not match the raw sample, so the report was generated
    after the clamp was in place."* Reject any sentence containing a person, a
    motive, or the word "falsified".
32. `cp backup/strain-summary.orig station/summariser/strain-summary`. Backwards
    overwrites the only known-good copy with the faulty one and destroys the
    ability to prove anything — which is why you hash both first.
33. `diff` exits **0** when the files are identical.
34. For: preserving mtime keeps the artefact's history honest. Against: this is
    not the original file, it is a new file you wrote today, and stamping it
    2186 makes your own change invisible to the next investigator. **Decide
    against.** Your changes should be visible; that is the point of a record.
35. `station/summariser/strain-summary` (before the restore — it *read* the
    variable) and `home/ops-bot/.bashrc` (which exports it). After the restore
    only `.bashrc` matches.
36. Yes, still worth removing, but the honest reason is different now: it is no
    longer live, so it is not a fault, it is **residue**. Leaving it means the
    next person to restore the clamping script gets the clamp configured for
    free. Accept "it does nothing now but it should not be there".
37. `sed -i '/STRAIN_TOLERANCE/d' home/ops-bot/.bashrc` — needs `sudo`, the
    file is ops-bot's.
38. A `nologin` shell blocks interactive logins; it does not stop
    `sudo -u ops-bot bash`, which starts a bash that reads `.bashrc` for an
    interactive shell. Lesson 02 exercise 11 covers this. Whoever set that
    variable expected a bash to run as ops-bot.

## D. Stop

39. `pgrep -af summariser/loop` shows two or more pids — the script and the
    subshell of its pipeline.
40. The **restored** one: every `reported=` equals its `raw=`, including values
    above 6.0, and `summary.err` gains no new lines. A student who says
    "clamping" has not read the output.
41. **No.** bash reads the script incrementally but the running loop is already
    inside its `while`; more importantly the summariser was `exec`'d once at
    pipeline setup and holds the old code. The general rule — a running program
    does not pick up edits to its file — is what matters. (Editing a running
    bash script *in place* can corrupt it mid-run, which is the other half of
    the reason not to.)
42. **SIGTERM** (15). The process is asked to exit and may clean up.
43. `pgrep -af summariser/loop` returns nothing, exit 1; `postcheck`'s last
    check passes.
44. `SIGKILL` gives the process no chance to flush. Lesson 02 showed a log held
    open on fd 3 — killed hard, buffered lines never reach the file, and on a
    system you are investigating that is evidence you destroyed yourself.

## E. Restore and prove

45. `./station/summariser/strain-summary < station/var/raw-sample.txt` piped
    through `awk`, written into the report in the same three fields.
46. peak **7.3**, mean **5.88** (5.9), exceedances **5**.
47. `reversible`: technically yes — the old file's content is in their
    `before.txt` if they did exercise 7, and can be reproduced by re-running
    the clamping script. Honest answers say "yes, because I recorded the old
    content" or "no, I overwrote it without keeping a copy" — the second is a
    true and useful confession, and should be marked as such rather than
    punished.
48. Six PASS, exit 0.
49. It catches it. Testing the test is worth it because a check that never
    fails is indistinguishable from a check that is not running — and
    `postcheck`'s apt and `.bashrc` checks are `grep`s whose exit-status
    inversion is easy to get backwards.
50. At least six: apt source, directory mode, setuid bit, summariser restore,
    `.bashrc` export, report regeneration. `verified by` must hold a real
    command, not "checked it".

## F. Stretch

51. ```bash
    #!/bin/bash
    set -euo pipefail
    raw="${1:?usage: report-check RAW REPORT}"
    rep="${2:?usage: report-check RAW REPORT}"
    read -r peak mean exc < <(awk '{s+=$2; if($2>m)m=$2; if($2>6)e++}
        END{printf "%.1f %.1f %d\n", m, s/NR, e}' "$raw")
    fail=0
    check() { grep -q "$1[[:space:]]\+$2" "$rep" || { echo "mismatch: $1 $2"; fail=1; }; }
    check 'peak reported' "$peak"
    check 'mean reported' "$mean"
    check 'exceedances'   "$exc"
    exit "$fail"
    ```
52. `find /labs \( -perm -4000 -o -perm -2000 \) -printf '%u %m %p\n' 2>/dev/null | sort`
53. `X` sets the execute bit only on directories and on files that already have
    execute set for somebody; `x` sets it on every file, making data files
    executable. You want `X` on any recursive `chmod`, essentially always.
54. Model: *"Packages installed from the eng-mirror source between 2187-05-16
    and today were installed without signature verification. Identify them,
    reinstall each from a signed source, and confirm afterwards that every
    installed package verifies against its repository signature."* Any brief
    with a concrete action and a stated verification passes.

## G. Dig

55. A setuid-root program that can execute arbitrary commands runs those
    commands as root, so the privilege boundary is gone entirely — it does not
    matter that the caller is unprivileged. `find` is the classic example
    because `-exec` runs anything; editors and pagers with shell-escape are the
    other standard family. No student should create one to check.
56. Three from: it does not establish that the fixes were the *right* fixes;
    that no second copy of any fault exists outside this lab; that nothing was
    installed, scheduled or left behind by whoever made the changes; that the
    packages from the unsigned mirror are clean; that the historical reports
    were ever corrected; that the account which made the changes no longer has
    access.

---

## Load-bearing

Exercises **3, 15, 17, 21, 22, 30, 31, 34, 36, 38, 41, 44, 49, 56**.
Exercise 31 is the chapter's fulcrum: it is the first time the student has
enough to state a conclusion about the report, and the first place they can
ruin it by naming someone.
