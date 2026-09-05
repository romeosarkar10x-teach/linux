# 13/01 — solutions

Instructor copy. No flag in this lesson.

Lab: `/labs/13-packages-docs-editors/01-apt`. Everything here was measured in
the station container against the lab's local `file:` repository.

## A. Warmup

1. Four `.deb` files, three distinct package names.
2. `deck-audit`, at `2.0.1` and `2.1.0`.
3. Four stanzas, separated by a blank line. This is the same
   `Field: value`-plus-blank-line format as `DEBIAN/control` and as
   `/var/lib/dpkg/status`; recognising it is worth more than the exercise.
4. `Filename: ./deck-audit_2.0.1_all.deb` — relative, to the repository's own
   base URL. That is what makes a repository relocatable.
5. `deb [trusted=yes] file:/labs/13-packages-docs-editors/01-apt/repo ./`
6. It applies to the source line as a whole. Accept any guess; lesson 02 grades
   it. Do not confirm or deny here.
7. `update`, `upgrade`, `install`, `remove`, `purge`. Not `search`, `show`,
   `list`.
8. Around 111 lines on the stock image, and it moves as they install things.
   Exact number is not the point; order of magnitude is.
9. `name/suite,now version arch [installed]` — for example
   `bash/noble,now 5.2.21-2ubuntu4 amd64 [installed]`.
10. Nothing, or nothing relevant. The catalogue has not been told about the
    lab's repository yet, so a package sitting in a directory two commands away
    is invisible. Availability is a property of the catalogue, not of the disk.

## B. The catalogue

11. `update` refreshes the catalogue of what is available and changes nothing
    installed. `upgrade` installs newer versions of what is installed, using
    whatever the catalogue currently says.
12. The copy. `apt` reads `/etc/apt/sources.list.d/*.list`; the original is just
    a file in a lab directory. Students who expect the original to work have not
    yet separated "a file exists" from "something reads it".
13. ```
    Get:3 file:/labs/.../01-apt/repo ./ Packages [1844 B]
    ```
    plus a `Method gave a blank filename` line, which is normal for a flat
    `file:` repository and is not an error.
14. Three `deck-*` packages now appear. Nothing installed changed, because
    `update` writes to the catalogue, not to the system.
15. `Depends: deck-common`
16. `APT-Sources: file:/labs/.../repo ./ Packages` — it names which repository
    this candidate came from. That is the field that answers "where did this
    package on my machine come from", which is the question the whole chapter is
    building toward.
17. Two versions are available, `2.1.0` and `2.0.1`. `-a` shows all of them
    rather than only the candidate.
18. `unknown` is the suite name, and there is none, because a flat repository
    has no `Release` file declaring one. Compare `bash/noble,now`, where `noble`
    is the suite and `now` means "the installed version". Students who say
    "unknown means broken" should be shown the `bash` line.
19. `2.1.0`. Both come from the same source with the same priority, so apt takes
    the highest version.

## C. Installing

20. `deck-common` and `deck-report`.
21. One asked for, two installed.
22. It arrived as a dependency of `deck-report`.
23. `ii`. First character: desired state. Second: current state. Lesson 02.
24. Only `deck-report`. `deck-common` was installed automatically, so it is not
    manual. This is the flag `autoremove` reads.
25. ```
    $ sudo apt install deck-audit=2.0.1
    $ deck-audit
    deck-audit 2.0.1
    ```
26. ```
    deck-audit/unknown 2.1.0 all [upgradable from: 2.0.1]
    ```
    Because "upgradable" means "the catalogue's candidate is newer than what is
    installed", and they deliberately installed an older one.
27. Upgraded `deck-audit` to 2.1.0 and left everything else alone:
    `1 upgraded, 0 newly installed, 0 to remove and 0 not upgraded.`
28. `deck-audit 2.1.0`. The old package's files were removed and the new
    package's files unpacked in their place — an upgrade is a remove and an
    install that dpkg performs together, not an edit of the files on disk.

## D. Removing

29. `deck-report`, from its `conffiles` list. A file in `/etc` is only treated as
    configuration because the package said so.
30. `echo modified | sudo tee -a /etc/deck-report.conf`
31. Yes. `remove` deletes the package's files and keeps its configuration.
32. ```
    rc  deck-report    1.2.0  all  summarise deck status from a manifest
    ```
    `rc` = removed, config-files remaining. The package is gone; dpkg still has
    a record of it because the configuration is still on disk.
33. `Purging configuration files for deck-report (1.2.0) ...`, the file is gone,
    and `dpkg -l deck-report` now says
    `dpkg-query: no packages found matching deck-report`.
34. It is correct behaviour — `purge` is documented to remove configuration, and
    "configuration" includes yours; dpkg cannot tell a local edit from a
    default. The thing to have done first is copy the file somewhere. Accept any
    answer that lands on "back it up", reject "apt should have asked me".
35. `deck-common`. Exercise 33 purged the only package that needed it, leaving
    an automatic package with no reason to exist.
36. It removes **both**:
    ```
    The following packages will be REMOVED:
    Removing deck-report (1.2.0) ...
    Removing deck-common (0.9.4) ...
    ```
37. The list you asked for is one name. The list apt prints is the transitive
    consequence. Reading it is the entire safety mechanism; `-y` skips it, which
    is exercise 52.

## E. Experiment

38. Exit status **100**, and `E: No packages found`. Worth dwelling on: not 1,
    not 2. apt's error status is 100 and it means "apt failed", not "no".
39. ```
    $ sudo apt-get install -y deck-repot
    E: Unable to locate package deck-repot
    rc=100
    ```
    `sudo` makes no difference to the outcome here — but note that without
    `sudo` the failure you get first is
    `E: Unable to acquire the dpkg frontend lock ... are you root?`, which is a
    *different* error hiding the real one. Typing `sudo` reflexively is not the
    danger; not reading which error you got is.
40. ```
    WARNING: apt does not have a stable CLI interface. Use with caution in
    scripts.
    ```
    In a script, use `apt-get`, `apt-cache` or `dpkg-query`.
41. `apt-get search deck` fails with `E: Invalid operation search` — searching
    lives in `apt-cache search`, which prints `name - description` and does not
    warn when piped. `apt` merged several older tools' jobs into one command;
    the older tools are still there and are the scriptable ones.
42. Measured: `apt search deck | wc -l` → 41, `apt-cache search deck | wc -l` →
    14. `apt search` prints a two-line stanza per hit plus a header and the
    warning; `apt-cache search` prints one line per hit. Note both find real
    Ubuntu packages containing "deck" as well as the lab's three.
43. `Installed-Size` and `Download-Size`. `Installed-Size: unknown` here because
    the lab's packages do not declare one in their control file — it is
    optional, and `dpkg-deb --build` does not invent it.
44. Measured, and it splits in two. A package that is **not installed**
    disappears from `apt search` only after the next `sudo apt update` —
    deleting a source file does not clear the catalogue already fetched. A
    package that **is** installed keeps showing up regardless, because dpkg's
    own status file is also a source:

    ```
    $ sudo mv /etc/apt/sources.list.d/station.list /tmp/
    $ apt search deck-audit
    deck-audit/now 2.1.0 all [installed,local]
    $ sudo apt update && apt search deck-audit
    deck-audit/now 2.1.0 all [installed,local]
    ```

    `now` as the suite and `local` in the brackets both mean the same thing:
    this package is on the machine and no repository currently offers it. That
    is exactly the state a package installed from a repository that has since
    been removed would be in — remember the shape of this line.

45. No. The checksums are identical; `update` does not write to
    `/etc/apt/sources.list.d/`.
46. `/var/lib/apt/lists/`. Each source becomes a file named after its URL —
    for example `_labs_13-packages-docs-editors_01-apt_repo_._Packages.lz4`.
    To answer "when did this machine last refresh", look at the mtimes there.

## F. Stretch

47. `dpkg-query -W -f='${Package}\n' 'deck*'`, or `dpkg -l 'deck-*'` filtered.
    Accept either; require the quotes, because the glob must reach dpkg and not
    the shell (chapter 5).
48. Reference:

    ```bash
    #!/usr/bin/env bash
    # pkgstate -- report whether a package is installed, removed or absent.
    # exit: 0 installed, 1 removed (config remains), 2 absent, 64 usage
    set -euo pipefail

    usage() { cat <<'EOF'
    usage: pkgstate PACKAGE
    Print installed, removed or absent for PACKAGE.
    EOF
    }

    case "${1:-}" in
        -h|--help) usage; exit 0 ;;
        '')        usage >&2; exit 64 ;;
    esac

    # dpkg-query, not apt: apt's output is explicitly unstable, and dpkg-query
    # takes a format string so nothing here depends on column widths.
    state=$(dpkg-query -W -f='${db:Status-Status}' "$1" 2>/dev/null) || {
        echo absent; exit 2
    }

    case "$state" in
        installed)     echo installed; exit 0 ;;
        config-files)  echo removed;   exit 1 ;;
        *)             echo absent;    exit 2 ;;
    esac
    ```

49. As above. Codes documented in the header, one per state.
50. Clean under `shellcheck` 0.11.0.

## G. Dig

51. `--dry-run` (also `-s`, `--simulate`, `--just-print`). On an already
    installed package it reports
    `deck-report is already the newest version (1.2.0).`
52. `-y` / `--yes` / `--assume-yes`. Reasonable in a script whose package list
    you wrote and reviewed. It is how you lose a machine when it is combined
    with a wildcard, a variable, or a package name you have not read the
    dependency list for — because `-y` is exactly the mechanism that skips
    exercise 37's list.
53. ```
    deck-audit:
      Installed: 2.1.0
      Candidate: 2.1.0
      Version table:
     *** 2.1.0 500
            500 file:/labs/.../repo ./ Packages
            100 /var/lib/dpkg/status
         2.0.1 500
    ```
    `500` is the pin priority of that source: the default for a normal
    repository. `100` on `/var/lib/dpkg/status` is the priority of "already
    installed". Priorities, not version numbers, decide the candidate; the
    version only breaks ties within a priority.
54. `/var/cache/apt/archives/`, emptied by `apt clean` (or `apt autoclean` for
    the obsolete ones). It is empty here after three installs because a `file:`
    repository is not downloaded — apt reads the `.deb` in place.

## H. Bring it together

55. Something like: "`deck-report` is installed on the maintenance account. It
    came from the station-local repository at `file:/labs/.../repo`, which is
    not signed, and I have not found who added it — I will have an answer after
    I have looked." No accusation, no name, and no claim beyond what was
    checked.
56. ```
    dpkg -l PACKAGE          # is it installed, and at what version
    apt-cache policy PACKAGE # candidate, and which source it comes from
    apt show PACKAGE         # what it claims to be, and what it depends on
    dpkg -L PACKAGE          # what it actually put on disk (lesson 02)
    ```
57. Wanted: `remove` by default, `purge` when you are sure you will not want the
    configuration back — with the exception being a package whose configuration
    is broken and is why you are reinstalling it.

## Instructor notes

- setup.sh sets SOURCE_DATE_EPOCH before dpkg-deb so the built .deb files are
  byte-for-byte reproducible; without it the archives differ on every run and
  the lab is not idempotent (measured).
- The whole lesson runs with no network. If a student's `apt update` reaches
  Ubuntu's mirrors as well, nothing here changes except that `apt search deck`
  returns about a dozen extra real packages, which is a fine thing to see.
- Students will leave `deck-*` packages installed and a `station.list` in
  `/etc/apt/sources.list.d/`. That is intentional and lesson 02 uses both.
- If a student breaks their apt state: `sudo apt purge -y 'deck-*'`,
  `sudo rm -f /etc/apt/sources.list.d/station.list`, `sudo apt update`, then
  re-run `setup.sh`.
- Do not answer exercise 6 for anyone. `[trusted=yes]` is lesson 02's hinge and
  the chapter's arc runs through it.
