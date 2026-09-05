# Incident 12 — Solutions

All answers measured on the station.

## A. Look before you touch

1. (a) which file configured the source we did not expect; (b) which version of
   `deck-verify` the station should be running; (c) what
   `libhatch-telemetry0` actually is.
2. Two.
3. `Candidate: 1.4.0`.
4. `500 file:/labs/13-packages-docs-editors/06-incident-12/repo-unknown ./ Packages`
5. `repo-station` offers `1.0.0`.
6. Highest version number. apt is not preferring the station's source — both
   sources sit at priority 500, so the version number decides.
7. `apt list -a deck-verify` prints two lines and is easier to paste, but it
   does not print the source URI, which is the whole point tonight. Paste
   `apt-cache policy`.
8. Four: `bay-tools.list`, `station.list`, `station-13.list`, `ubuntu.sources`.
9. `/etc/apt/sources.list.d/bay-tools.list`.
10. `2187-06-28 03:41` — eight days before the incident, and out of step with
    the other files in the directory.
11. It records a URI, the `[trusted=yes]` option and a distribution field. It
    records no author, no ticket, no comment. A file's owner is `root` because
    only root can write there; that is not authorship.
12. `dpkg -s deck-verify` (or `dpkg-query -W deck-verify`) — reports not
    installed. `which` would only tell you whether something with that name is
    on `PATH`.

## B. Reading a package you have not installed

13. `repo-station/deck-verify_1.0.0_all.deb` 2110 bytes;
    `repo-unknown/deck-verify_1.4.0_all.deb` 882 bytes;
    `repo-station/libhatch-telemetry0_2.4.1_all.deb` 818 bytes.
14. `Kestrel Station Engineering <engineering@kestrel.example>`.
15. `unknown <unknown@localhost>`.
16. The one-line summary is identical, word for word. The station package adds
    two paragraphs saying it is the station build; the other stops after the
    summary. Copied text is evidence that one was derived from the other. It
    does not tell you in which direction.
17. `X-Station-Token: STAGE{one-tool-two-sources}` — found with
    `dpkg -I repo-station/deck-verify_1.0.0_all.deb`.
18. `X-Station-Token: STAGE{higher-version-wins}`.
19. The station's `deck-verify` declares `Depends: libhatch-telemetry0`.
20. The 1.4.0 package declares nothing. Not reassuring: it means it does not
    need the telemetry reader that the real tool reads the log with, which is
    odd for something claiming to do the same job.
21. Two real files each — a program in `/usr/bin` and a `README` under
    `/usr/share/doc`. `dpkg -c` also lists the directories.
22. Neither ships a man page. Both ship a `README`; the 1.4.0 one says only
    that no documentation was shipped.
23. Not present. `dpkg -I` and `dpkg -c` read the archive and touch nothing
    else.
24. 1.0.0 from `repo-station`: named maintainer, declares the dependency the
    job needs, ships documentation, and comes from a source that was configured
    deliberately.

## C. The package that was already there

25. `Status: install ok installed`, version `2.4.1`.
26. "hatch telemetry log reader" — a shared reader for the hatch telemetry log
    format, used by `deck-verify`, `deck-audit` and the tally tools.
27. Same maintainer as the station's `deck-verify`:
    `Kestrel Station Engineering <engineering@kestrel.example>`.
28. `deck-verify` depends on it. That is the answer to "why is this here."
29. Two: `/usr/lib/kestrel/hatch-telemetry.sh` and
    `/usr/share/doc/libhatch-telemetry0/README`.
30. No. `ls -l` shows `-rw-r--r--` on the `.sh` — no execute bit, so it is
    sourced by other tools, not run.
31. `dpkg -V` prints nothing and exits 0: every file it installed is still
    there with the contents and permissions it shipped. Nothing has been
    tampered with.
32. `apt-cache policy libhatch-telemetry0` shows it at 2.4.1 from
    `file:.../repo-station` — the station's own source, the one that was
    configured on purpose.
33. Not a finding: it is a documented station-maintained library that an
    installed station tool depends on and that has not been modified. It would
    become one if nothing depended on it, or if it came from the unexpected
    source, or if `dpkg -V` flagged its files.
34. Yes. "It may be nothing" is an accurate description of an unresolved
    observation. It hands over a thing to check without asserting a conclusion
    the writer had not reached.

## D. Installing the version you chose

35. `sudo rm /etc/apt/sources.list.d/bay-tools.list`. Not finished: apt still
    has the old index cached until `sudo apt update`.
36. Yes, but only one version now.
37. `Candidate: 1.0.0`.
38. `sudo apt install -y deck-verify=1.0.0`. The habit is worth keeping because
    the pin is what makes the command reproducible in a handover: the same
    line typed on another station, or on this one next week, installs the same
    thing regardless of what sources happen to be configured then.
39. Nothing new. `libhatch-telemetry0` was already installed at 2.4.1, which
    satisfies the dependency.
40. `deck-verify 1.0.0 (station build)`.
41. ```
    deck-verify: sources clean, station build 1.0.0 installed
    deck-verify: STAGE{the-source-comes-off-first}
    ```
    Exit status 0.
42. Exit status 3, with `deck-verify: REFUSING TO RUN` and the path of the
    offending file.
43. It would say the installed `deck-verify` is not the station build (1.0.0)
    and exit 4. The version check is separate from the source check.
44. `/usr/bin/deck-verify` and `/usr/share/doc/deck-verify/README`. Same paths
    the other package would have used — which is why installing it first, then
    checking, would have overwritten the evidence.

## E. The attestation

45. ```
    bay-tools.list
    1.0.0
    libhatch-telemetry0
    ```
    A full path on line 1 is accepted; the check takes the basename.
46. Each wrong line is reported by number, and the whole attempt exits 5.
47. `KESTREL{a_source_no_one_signed_and_no_one_added}`
48. Because a correct write-up on a broken station is a report, not a fix. The
    deliverable is a station that is right, evidenced by a write-up — not a
    write-up that describes one.
49. For example: *deck-verify was not installed. apt offered 1.4.0 from
    file:.../repo-unknown, configured by /etc/apt/sources.list.d/bay-tools.list,
    mtime 2187-06-28 03:41. That file was removed and 1.0.0 installed from the
    station source. libhatch-telemetry0 is a station library that deck-verify
    depends on; not a finding. Unexplained: how bay-tools.list came to exist.*
50. That a source was configured on 2187-06-28 that nobody has accounted for,
    and that it would have supplied the tool if a plain `apt install` had been
    run. Not entitled to conclude: who created it, or that whoever did meant
    harm. A file's mtime is when, never who.

## F. Going further

51. It shows every file and prefixes each line with the filename, so you get
    "what is configured" and "which file configured it" in one pass — and it
    cannot miss a file you forgot to `cat`.
52. Signature verification. With `[trusted=yes]` apt accepts the index and the
    packages without checking any signature, which is why the source could
    exist at all without a key being installed for it.
53. Unchanged: the version number, that higher version wins, that a plain
    `apt install` would have taken 1.4.0. Changed: it would no longer be a
    finding at all — a signed source from a known origin is an ordinary
    configuration item, and the question becomes a change-control question
    rather than an integrity one.
54. Every remote Ubuntu source and both `file:` sources are at 500;
    `/var/lib/dpkg/status` sits at 100. Equal priority is why the version
    number was the tiebreak.
55. `deck-verify`: only *available*, never installed from the unexpected source
    — nothing from it ever reached the disk. `libhatch-telemetry0`: actually
    installed, and from the station's own source. The alarming one was never
    installed; the installed one was never alarming.
56. `deck-verify` 1.0.0 is now installed, which is the point of the shift.
    `bay-tools.list` is gone. `sudo apt-get purge -y deck-verify` and re-running
    `setup.sh` returns the lab to its opening state; `dpkg -l deck-verify` and
    `ls /etc/apt/sources.list.d/` confirm it.

## CTF chain

| Stage | Where | Token |
|---|---|---|
| 1 | `dpkg -I repo-station/deck-verify_1.0.0_all.deb` — the `X-` control field | `STAGE{one-tool-two-sources}` |
| 2 | `dpkg -I repo-unknown/deck-verify_1.4.0_all.deb` — same field, other value | `STAGE{higher-version-wins}` |
| 3 | remove `bay-tools.list`, `apt update`, install `deck-verify=1.0.0`, then `deck-verify --self-test` | `STAGE{the-source-comes-off-first}` |
| 4 | `deck-verify --attest` with the three correct findings | `KESTREL{a_source_no_one_signed_and_no_one_added}` |

Stage 3 is the cliff: it is the only stage that requires changing the station
rather than reading it, and it fails loudly two different ways — exit 3 while
the source file is still present, exit 4 if the wrong version got installed.
