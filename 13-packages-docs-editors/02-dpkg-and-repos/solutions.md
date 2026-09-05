# 13/02 — solutions

Instructor copy. No flag in this lesson.

Lab: `/labs/13-packages-docs-editors/02-dpkg-and-repos`. All output below was
measured in the station container.

## A. Reading a `.deb`

1. `name_version_architecture.deb` — `hatch-log`, `1.0.0`, `all`. `all` means
   architecture-independent.
2. Four files, in `/etc`, `/usr/bin` and `/usr/share/doc/hatch-log/`:
   ```
   -rw-r--r-- root/root  12 2020-01-01 00:00 ./etc/hatch-log.conf
   -rwxr-xr-x root/root  33 2020-01-01 00:00 ./usr/bin/hatch-log
   -rw-r--r-- root/root  38 ./usr/share/doc/hatch-log/README
   ```
   Plus the directories themselves, which the archive also carries.
3. `root/root`, mode `rwxr-xr-x`. Ownership and mode travel *inside* the
   package; they are not decided at install time.
4. `Description: record hatch cycles to a log file`
5. `Depends: hatch-common (>= 2.0)`
6. `-I` reads the control archive (the `Package:`/`Depends:` stanza, the
   `conffiles` list, the maintainer scripts); `-c` reads the data archive (a
   `tar` listing of files with modes and sizes). The output shape says which:
   fields versus a long listing.
7. Neither writes anything or reads anything privileged — a `.deb` is a file,
   and they are reading it.
8. `/etc/hatch-log.conf`. Listing it as a conffile is what makes `remove` keep
   it and `purge` delete it (lesson 01, exercises 31–33). A file dropped in
   `/etc` that is *not* listed there is just a file, and gets deleted on remove
   like any other.

## B. The database

9. `ii`.
10. `ii` for whatever survived lesson 01, and `rc` for anything removed but not
    purged. `rc` means the files are gone and the configuration is not.
11. Four paths plus the directories: `/etc/deck-common.conf`,
    `/usr/bin/deck-common`, `/usr/share/doc/deck-common/README`.
12. For a package in `rc` state, `dpkg -L` lists only what is still on disk —
    the `/etc` entries. The short list *is* the answer: the package's files were
    removed and its configuration was not.
13. `coreutils: /usr/bin/ls`
14. ```
    dpkg-query: no path found matching pattern /labs/.../notes/dpkg.txt
    rc=1
    ```
15. Nothing installed that file, so no package's file list contains it. `dpkg -S`
    searches package file lists, not the filesystem. Anything that arrived by
    `tar`, `cp`, `make install`, or a lab setup script is invisible to it — and
    that gap is exercise 51 and half of a real audit.
16. `Status: install ok installed` — desired action, error flag, current state.
17. `/var/lib/dpkg/status`.
18. Measured: `grep -c '^Package:' /var/lib/dpkg/status` → 112,
    `dpkg -l | wc -l` → 117. `dpkg -l` prints five header lines. Students who
    report "off by five" without finding the reason should run `dpkg -l | head`.

## C. Installing by hand

19. `Selecting previously unselected package hatch-log.` … `Unpacking` …
    `Setting up hatch-log (1.0.0) ...` — unpack and configure, the two phases.
20. `/usr/bin/hatch-log`; `dpkg -L hatch-log` or `command -v hatch-log`.
21. `ii`.
22. ```
    dpkg: dependency problems prevent configuration of hatch-report:
     hatch-report depends on hatch-common; however:
      Package hatch-common is not installed.
    ```
23. **1**. `dpkg` reports failure. (Note that the *pipeline* status students
    often measure is `tail`'s — a chapter 8 habit worth re-checking here.)
24. `iU`. `i` = installation was requested; `U` = the package is unpacked and
    not configured.
25. It runs:
    ```
    $ hatch-report
    hatch-report 1.4.2
    ```
    Unpacking put the file on disk with its mode. Configuring is a separate
    step — running `postinst`, registering the package as usable. Nothing stops
    the kernel executing a file that dpkg considers half-installed.
26. Wanted, roughly: a program running proves its bytes are on disk; it proves
    nothing about whether its configuration ran, its dependencies exist, or its
    state is one the package manager will act on next time. The failure it hides
    surfaces later, on the next upgrade, in someone else's shift.
27. Measured — it **removed** `hatch-report`:
    ```
    Removing hatch-report (1.4.2) ...
    ```
28. `apt -f install` fixes a broken state by any means available, and the only
    two means are "install the missing dependency" or "remove the broken
    package". `hatch-common` is in no repository this station knows about, so
    only the second was available. This surprises students, and it is the right
    behaviour: apt's job is a consistent system, not a preserved package.
29. `rc` — the package's files went, its conffile stayed in `/etc`.
30. It is in `scratch/found/hatch-common_2.1.0_all.deb`. After
    `sudo dpkg -i scratch/found/hatch-common_2.1.0_all.deb`, `hatch-report` is
    **still `rc`**: installing a dependency does not resurrect a package apt
    already removed.
31. `sudo dpkg -i debs/hatch-report_1.4.2_all.deb` now succeeds and gives `ii`,
    because the dependency is present. `sudo apt install ./debs/...` would also
    work. Either is fine as long as they can say why it works *now*.
32. Nothing: `dpkg-query: no packages found matching hatch*`.

## D. Sources

33. `station.list` (theirs, from lesson 01) and `ubuntu.sources` (the image's).
34. Only a comment, pointing at `/etc/apt/sources.list.d/ubuntu.sources` and
    the deb822 format. Ubuntu has moved the real configuration into the
    directory; the file remains so that anything still reading it works.
35. `deb` (type), URI, suite, components.
36. `Suites:` corresponds to the suite; `Components:` to `main restricted`.
37. deb822: `Signed-By: /usr/share/keyrings/example-archive-keyring.gpg`. The
    one-line format needs `[signed-by=...]` in brackets to say the same thing.
38. `unsigned.list` disables verification with `[trusted=yes]`;
    `ppa-style.list` keeps verification and names the key to verify against.
    Same shape, opposite meaning.
39. `deb-src` sources point at source packages, for building from source or
    `apt source`. Not needed here — nothing on this station is built from
    Debian sources.
40. ```
    E: The repository 'file:/labs/13-packages-docs-editors/01-apt/repo ./ Release'
    does not have a Release file.
    ```
41. Not a bad signature — there is nothing to check at all. A flat directory
    with a `Packages` file and no `Release` cannot be verified, so apt refuses
    rather than guessing. `[trusted=yes]` does not add a signature; it tells apt
    to proceed unverified.
42. `apt-cache policy deck-audit` shows the `file:` source at priority 500 again.
43. It lists every package source apt currently knows, each with its pin
    priority and its release fields:
    ```
    Package files:
     100 /var/lib/dpkg/status
         release a=now
     500 https://.../noble-security/multiverse amd64 Packages
    ```
    The number is the pin priority (`apt_preferences(5)`), not a version.

## E. Experiment

44. ```
    ??5??????   /usr/bin/deck-report
    ```
45. Exit status **0** — measured, twice, with and without differences. `dpkg -V`
    reports discrepancies on stdout and does not signal them in its status, so a
    script must test whether the output was empty, not whether the command
    succeeded. This is a genuine trap and worth making them prove.
46. Third position, which is the md5sum check; `5` is the letter dpkg uses for
    "checksum differs". The other positions are shown as `?` because dpkg only
    verifies the checksum, not size, mode or ownership.
47. `sudo apt install --reinstall deck-report`, after which `dpkg -V` prints
    nothing.
48. Fast — measured at 0.054s for the whole station — and it reports a page of
    `missing /usr/share/doc/...` lines. Container images are built with
    documentation stripped, so those files really are absent. Excellent thing to
    see: a verification tool whose default output on a healthy system is not
    empty, and which therefore trains people to ignore it.
49. It unpacks over itself and configures again — effectively a reinstall, with
    no complaint.
50. It downgrades, silently:
    ```
    Unpacking deck-audit (2.0.1) over (2.1.0) ...
    $ deck-audit
    deck-audit 2.0.1
    ```
    `apt` would have refused without `--allow-downgrades`. `dpkg -i` has no
    opinion about versions; it does what it is told. That is the whole
    difference between the two layers in one command.

## F. Stretch

51. ```
    find /usr/local -type f | while read -r f; do
        dpkg -S "$f" >/dev/null 2>&1 || printf '%s\n' "$f"
    done
    ```
    `/usr/local` is the interesting one because it is the directory the
    packaging system is guaranteed never to write to — everything there arrived
    some other way, which is exactly what an audit wants listed.
52. Requires `readlink -f` (or `realpath`) before the lookup, because `dpkg -S`
    matches against absolute paths as recorded, and a relative path will never
    match.
53. `dpkg -V PACKAGE` and treat any output as the finding, per exercise 45.
54. Clean under `shellcheck` 0.11.0.

## G. Dig

55. `dpkg-deb -c` (which is what `dpkg -c` calls) lists from the `.deb` file;
    `-L` lists from the installed database. One describes a file you have, the
    other describes a machine you have.
56. `/var/log/dpkg.log`, with a timestamp and a state transition per line:
    ```
    2026-09-05 06:06:15 status unpacked deck-audit:all 2.0.1
    ```
    This is the only place that answers "when was this installed", and it
    rotates, so it also answers it only for as long as it is kept.
57. `-r` removes, `-P` purges. Same distinction as `apt remove`/`apt purge`,
    one layer down — because apt is telling dpkg to do exactly this.
58. `dpkg --audit` reports packages in a broken state. On a healthy station it
    prints nothing and exits 0; run it while `hatch-report` is `iU` and it names
    it. That is the one-command version of exercise 24.

## H. Bring it together

59. Establishable without accusing anyone: the URI it points at
    (`cat` the file), whether it is signed (`signed-by=`/`Signed-By:` present,
    or `[trusted=yes]`), whether apt can currently reach it (`apt update`
    output), what it offers (`apt-cache policy`, and `grep` in
    `/var/lib/apt/lists/`), and which installed packages have it as their
    `APT-Sources` (lesson 01, exercise 16). None of that names a person, and
    the exercise should be marked down if the student's writeup does.
60. `apt-cache policy PACKAGE` for each installed package shows the source of
    its *candidate*. The gap: dpkg does not record which repository a package
    was installed from, so if the source has since changed or been removed, the
    installed package no longer points anywhere. That is the missing link the
    chapter closes in lesson 06 by other means.
61. `rc` is a tidy-up question. `iU` means something is on disk, executable, and
    outside the package manager's model of the system — so it will not be
    upgraded, will not be patched, and will still run.

## Instructor notes

- Students end this lesson with `hatch-*` purged and lesson 01's `deck-*`
  installed. That is the state lesson 04 expects.
- If a student's apt is wedged: `sudo dpkg --audit`, then
  `sudo apt-get -f install`, then `sudo apt update`.
- Exercise 40 asks them to break their own apt configuration and put it back.
  Confirm they ran exercise 42 before moving on; a missing `[trusted=yes]` will
  make lesson 04 look broken for reasons that have nothing to do with lesson 04.
- The chapter arc runs through `notes/page.txt`. It states a fact about
  `sources.list.d` and nothing else. Do not let a discussion here turn into a
  name; the evidence does not support one and will not until lesson 06.
