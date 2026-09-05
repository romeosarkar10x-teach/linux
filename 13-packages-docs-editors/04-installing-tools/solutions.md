# 13/04 — solutions

Instructor copy. No flag in this lesson. Measured on the station.

## A. What is already here

1. Free. The list is designed so that a confident guess is wrong.
2. Present: `htop`, `tree`, `jq`, `shellcheck`, and the locate tool. Absent:
   `ripgrep`, `ncdu`.
3. `plocate` provides the command `locate`, not `plocate`. The package name and
   the command name are different things, and this is the cheapest possible
   demonstration.
4. ```
   htop:
     Installed: (none)
     Candidate: 3.3.0-4build1
   ```
5. `htop` was installed by a second packaging system — `man -w htop` resolves to
   `/nix/store/...-htop-3.5.3-man/share/man/man1/htop.1.gz`, and `command -v`
   gives `/opt/kestrel/bin/htop`. apt is reporting accurately on the packages
   *apt* manages. Two package managers, one machine, neither aware of the other.
6. ```
   dpkg-query: no path found matching pattern /opt/kestrel/bin/jq
   rc=1
   ```
   Same reason as lesson 02 exercise 15: dpkg knows what dpkg installed.
7. `command -v NAME`. Ask the system whether the command exists; ask the package
   manager only when you want to know who owns it.
8. ```
   ls is /opt/kestrel/bin/ls
   ls is /usr/bin/ls
   ls is /bin/ls
   ```
   The first runs. `PATH` order decides, and `/opt/kestrel/bin` is first on
   this station's `PATH`.

## B. From the archive

9. `apt search "disk usage"` and read the descriptions —
   `ncdu ... ncurses disk usage viewer`.
10. `Section: universe/admin`, `Installed-Size: 117 kB`, `Version: 1.19-0.1`.
11. Installs. `Processing triggers for man-db` is dpkg telling `man-db` to
    reindex, because the package added manual pages — the same index they built
    by hand in lesson 03, maintained automatically for packaged software.
12. A navigable tree with per-directory sizes, sorted, that you can descend
    into. `du -sh` gives one number.
13. `ii`.
14. 12 entries; `/usr/share/man/man1/ncdu.1.gz` among them.
15. `rg`.
16. `/usr/bin/rg`. Yes — `/usr/bin` is the distribution's directory, and this
    is the distribution installing into it, which is exactly the case where
    that is correct. The prohibition is on *you* writing there by hand.
17. Measured: `rg -l` gives 76, `grep -rl` gives 79.
18. `rg` skips hidden files and directories (and honours ignore files) by
    default; `grep -r` descends into everything. The confirming test:
    ```
    mkdir -p /tmp/t/.hidden && echo deck > /tmp/t/.hidden/x && echo deck > /tmp/t/y
    rg -l deck /tmp/t        # /tmp/t/y
    grep -rl deck /tmp/t     # both
    ```
    Note that this makes `rg` a bad default for auditing, and a good one for
    working in a source tree. Both halves matter.
19. `Installed: 14.1.0-1`, where `htop` said `(none)`. Same command, opposite
    answer, because this one really did come from apt.

## C. From a tarball

20. `deck-tools-1.3.tar.gz` — name, version, and that it is a gzipped tar
    archive, before opening anything.
21. Nine entries; one top-level directory, `deck-tools-1.3/`.
22. Because extraction has no undo. An archive built without a top-level
    directory ("a tarbomb") drops its contents into the current directory,
    mixed in with whatever is already there, and untangling that by hand is the
    whole afternoon.
23. `tar -xzf dist/deck-tools-1.3.tar.gz -C scratch`
24. That there is no installer: copy `bin` and `share` into a prefix, and if
    the prefix is not `/usr/local`, put its `bin` on `PATH` and its `share/man`
    on `MANPATH`.
25. ```
    scratch/deck-cycle.conf:4: not "deck-NN SECONDS": deck-9 60
    scratch/deck-cycle.conf:5: not "deck-NN SECONDS": deck-11 forty
    ```
26. **1** — "At least one bad line", per the page in
    `scratch/deck-tools-1.3/share/man/man1/deck-lint.1`, read with
    `MANPATH=$PWD/scratch/deck-tools-1.3/share/man man deck-lint` or simply
    `less` on the source.
27. Line 4: `deck-9` is one digit, and the format is two (`deck-09`). Line 5:
    `forty` is not a number of seconds.
28. `deck-09 60` and a number on line 5; status 0, and it prints
    `scratch/deck-cycle.conf: ok`.
29. `--quiet` prints nothing in both cases and communicates only through the
    exit status. A script wants that: it tests the status and produces its own
    message, rather than parsing someone else's output. (Chapter 8 and chapter
    12, arriving in a real tool.)
30. `sudo cp -r scratch/deck-tools-1.3/bin scratch/deck-tools-1.3/share /usr/local/`
    — `bin` and `share`, and deliberately not `etc`, which holds only a sample.
31. `/usr/local/bin/deck-lint`.
32. `/usr/local/bin` is already on `PATH` — that is what makes `/usr/local` the
    conventional prefix rather than an arbitrary one.
33. `man deck-lint` works immediately; `whatis deck-lint` says
    `nothing appropriate`.
34. `sudo mandb -q`. Lesson 03 built an index inside a manpath the student
    owned; `/usr/local/share/man` is root's, so writing its index needs root.
    The permission model has not changed, only the directory.
35. `dpkg-query: no path found matching pattern /usr/local/bin/deck-lint`.
36. Nothing.
37. No upgrade path; no attribution (`dpkg -S` cannot name it); no removal
    command — you must remember the files yourself.

## D. Prefixes

38. Measured order:
    ```
    /opt/kestrel/bin
    /usr/local/sbin
    /usr/local/bin
    /usr/sbin
    /usr/bin
    /sbin
    /bin
    ```
    `/usr/local/bin` comes before `/usr/bin`.
39. The `/usr/local` one, by `PATH` order. Note that a program in
    `/opt/kestrel/bin` would beat both on this particular station.
40. Both arguments are acceptable if argued. For: a local override is the point
    of `/usr/local`, and an operator's deliberate choice should win. Against: a
    forgotten file in `/usr/local/bin` silently shadows a packaged, patched,
    upgraded program, and nothing will ever warn you. The strongest answers say
    "yes, and that is exactly why exercise 58 exists".
41. `manpath` lists `/usr/local/man` and `/usr/local/share/man`, and
    `ls -ld /usr/local/man` shows `/usr/local/man -> share/man`. Two entries,
    one directory — historical duplication, harmless.
42. `mkdir -p ~/.local/bin && cp .../bin/deck-lint ~/.local/bin/`. It does
    **not** run: `~/.local/bin` does not exist on this station and is not on
    `PATH`.
43. Add `export PATH="$HOME/.local/bin:$PATH"` to `~/.bashrc` (chapter 10). Some
    distributions add `~/.local/bin` automatically when it exists at login;
    this one does not, and the honest check is `echo "$PATH"` after a fresh
    login rather than an assumption.
44. `~/.local/bin`: no root needed, no effect on anyone else, easy to reason
    about per-user. `/usr/local/bin`: one copy for the whole crew, works for
    scripts run as other users, and survives a home directory being wiped.
45. `/opt` is for self-contained third-party trees that keep their own
    `bin`/`lib`/`share` together. `/opt/kestrel` on this station is a live
    example — and, per exercise 8, the one at the front of `PATH`.

## E. Judgement

46. Defensible either way. Take the archive version by default: it is patched,
    signed, and upgraded. Take upstream when you need a specific fix or feature
    that 1.2 lacks, and say what you will do about future security updates
    since nothing will deliver them. What should change their mind: a CVE, a
    hard dependency, or a colleague who has to maintain it.
47. It executes code from a URL as root, unread, with no signature check, no
    record of what it installed, and no way to remove it. Route one verifies a
    signature, records every file, and removes in one command. A student who
    says "it is the same as apt, apt also runs code as root" has half a point —
    the difference is verification and accountability, and they should say so.
48. Check for it at start-up and fail immediately with a clear message, rather
    than failing halfway through with a confusing one. It must not install
    anything: a script that installs packages behind its user's back is a worse
    problem than a missing dependency.
49. ```bash
    for tool in jq; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            printf '%s: required tool not found: %s\n' "${0##*/}" "$tool" >&2
            exit 1
        fi
    done
    ```
50. Clean under `shellcheck` 0.11.0 as written.
51. Build a `.deb` — lesson 01's `dpkg-deb --build` on a tree with a
    `DEBIAN/control` — and install it with `apt install ./deck-tools.deb`, or
    put it in the station's local repository so `apt install deck-tools` works
    everywhere. That converts route three into route one and buys back all
    three losses from exercise 37.

## F. Put it back

52. `sudo apt purge ncdu ripgrep`. `remove` would leave configuration files
    behind; neither of these has a conffile that matters, so the practical
    difference here is nil — and being able to say *why* it is nil is the
    answer.
53. From the README, and from their own memory of what they copied. There is no
    command that will tell them, which is exercise 37 landing.
54. `sudo mandb -q; whatis deck-lint` → `nothing appropriate`.
55. Prints nothing, exits 1.
56. Silent, exit 0.

## G. Bring it together

57. ```bash
    #!/usr/bin/env bash
    set -euo pipefail
    for name in "$@"; do
        path=$(command -v "$name" 2>/dev/null) || { printf '%s: not found\n' "$name"; continue; }
        real=$(readlink -f "$path")
        if owner=$(dpkg -S "$real" 2>/dev/null); then
            printf '%s\t%s\t%s\n' "$name" "$path" "${owner%%:*}"
        else
            printf '%s\t%s\tunpackaged\n' "$name" "$path"
        fi
    done
    ```
    `ls` → `coreutils` only if `readlink -f` is applied, because
    `/opt/kestrel/bin/ls` is a symlink into `/nix/store` and that path is
    unpackaged too — so on this station `ls` may legitimately come back
    `unpackaged`. Accept either, insist they explain which they got.
58. Empty on a clean station, apart from `locate`. A non-empty result is a list
    of programs that shadow the distribution's, installed by a person, recorded
    nowhere — which is the first thing to look at when a command starts
    behaving unlike its documentation.
59. There is no such record. `dpkg -l`, `dpkg -S`, `/var/log/dpkg.log` and
    `apt-cache policy` all know nothing about it. The only trace is the file's
    own mtime and owner (`ls -l`), which says when it was copied and by which
    account — and both are trivially settable with `touch` and `chown`, as
    chapter 4 showed. Students who cite mtime as proof should be asked how much
    they would stake on it.

## Instructor notes

- Leave the station clean: `ncdu` and `ripgrep` purged, nothing in
  `/usr/local/bin`. Lesson 06 assumes a missing tool, and a student who left
  `ripgrep` installed will find the incident's opening move already done.
- Exercise 5 is the one to insist on. "apt says not installed but the command
  runs" is the fact that makes lesson 06's investigation honest.
- Exercise 59 is arc material and the last one before the incident. The point
  is not suspicion; it is that `/usr/local` has no provenance, by design, and
  the student needs that fact in hand before lesson 06 rather than after.
