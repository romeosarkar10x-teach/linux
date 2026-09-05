# 13/03 — solutions

Instructor copy. No flag in this lesson. All output measured on the station.

## A. Sections

1. Section 1 — the header reads `PASSWD(1) ... User Commands`. The command that
   changes a password.
2. `passwd(5)`, `File Formats`, the format of `/etc/passwd`: the colon-separated
   line they took apart in chapter 6.
3. A command and the file it operates on are different things and each needs
   documenting; the section number is what keeps the two names apart.
4. Section 1. `man chmod` gives the command.
5. `chmod(2)` documents the system call: the thing `chmod(1)` calls, with C
   argument types and `errno` values. Wanted: they can say "one is a program,
   one is a kernel interface".
6. ```
   printf (1)           - format and print data
   printf (3)           - formatted output conversion
   ```
   Section 1 is the shell command; section 3 is the C library function that
   `printf("%s\n", x)` in a C program calls. Same name, unrelated manuals.
7. `q` moves to the next page in the sequence; `q` at the last one exits. To
   abandon the whole sequence, `Ctrl-C` at the prompt between pages.
8. `sudoers(5)` — `man -f sudoers` shows it, `man 5 sudoers` reads it. `fstab`
   gives `fstab: nothing appropriate.` on this station: `mount(8)` and its
   related pages are not part of this image. That is the real answer and it is
   the useful one — the tool tells you what it has, not what exists in general.
9. `whatis signal` or `man -f signal`, which prints both `signal(2)` and
   `signal(7)`. `man 7 signal` would open the page; `whatis` is the one that
   prints only the NAME line.
10. `ls(1)`, `open(2)`, `sudoers(5)`, `chmod(1)`, `chmod(2)`, `signal(7)`.

## B. Finding a page by what it does

11. `apropos "change file timestamps"` → `touch (1) - create file, or change
    file timestamps`, plus `futimens(3)`, `futimes(3)`, `lutimes(3)`,
    `utimensat(2)`. Section 1 is the one they wanted; the rest are the C
    interfaces underneath it.
12. `whatis` matches the page *name* exactly; `apropos` matches the description
    text. One answers "what is this", the other "what does this".
13. Identical output. `man -k` is `apropos`; they are the same program reached
    two ways.
14. **3386** on the current image. Any number is acceptable if it is theirs;
    the point is that it is a few thousand and finite.
15. `man -k -s 5 . | wc -l` → **183**. `-s` restricts by section.
16. `-e` matches whole words exactly rather than as substrings. Note it still
    matches on the description, so `apropos -e passwd` also returns
    `getpwent_r(3) - get passwd file entry reentrantly` — the word `passwd`
    appears there. Students who expect "only the page named passwd" have
    learned something worth learning.
17. `-r` treats the argument as a regular expression, so `^deck` anchors to the
    start. Without it, `^deck` is looked for literally and finds nothing.
18. `apropos hostname` → 7 lines here.
19. `man -K --regex getpwnam` finds `getent(1)` among others in about 0.35s.
    `apropos getpwnam` finds the section 3 page by description. `-K` reads
    every page's body; `apropos` reads a prebuilt index of one-line
    descriptions.
20. `-K` when you remember a phrase from the body of a page and nothing about
    its name or purpose. Not for routine lookup: it is orders of magnitude more
    work, and on a large system with full documentation it is slow.

## C. Your own manual pages

21. Four files. The directory (`man1`, `man5`, `man8`) and the extension on the
    filename both encode the section; they agree, and are expected to.
22. `No manual entry for deck-cycle` — the lab is not on the manpath. Nothing is
    wrong with the page.
23. Displays. Header: `DECK-CYCLE(1) ... Station Commands`.
24. **1** — "At least one deck was skipped". (0 is all cycled, 2 is bad usage.)
25. 30 seconds.
26. SEE ALSO lists `deck-cycle.conf(5)` and `deck-audit(8)`. The first opens.
    The second does not exist on this station — SEE ALSO is a claim by the
    author, not a guarantee, and noticing that is the exercise.
27. `.../man/man1/deck-cycle.1`, plain text: troff/man macro source, readable
    with `cat`. `man` formats it at display time.
28. `deck-cycle-archived.1.gz` — same content, gzip-compressed.
29. `man deck-cycle-archived` reads it directly. `man` decompresses on the fly;
    that is why almost every page in `/usr/share/man` ends in `.gz`.
30. `deck: nothing appropriate.` — no index has been built for this manpath.
31. `mandb -c -u man` (or with the absolute path). It reports
    `4 manual pages were added.`
32. Three: `deck-cycle(1)`, `deck-cycle-archived(1)`, `deck-cycle.conf(5)`.
33. `index.db` (a GDBM database) and `cat1`, `cat5`, `cat8` directories for
    formatted output.
34. **3**, against four pages on disk.
35. `hatch-tally(8)`. `man 8 hatch-tally` renders it in full, and `whatis
    hatch-tally` says `nothing appropriate`. A page can be perfectly readable
    and completely unfindable, because finding and reading use different
    machinery.
36. `deck-cycle.1` has a `.SH NAME` section with a `name \- description` line;
    `hatch-tally.8` starts at `.SH DESCRIPTION`. The index is built from the
    NAME line, so there is nothing to index.
37. ```
    hatch-tally.8: parse failed          (rc 2)
    deck-cycle.1: "deck-cycle - open and close a deck hatch on a timer"
    ```
    `lexgrog` is the NAME-line extractor `mandb` uses. It is the direct way to
    ask "will this page be indexable" before building anything.
38. Copy, add
    ```
    .SH NAME
    hatch-tally \- count hatch cycles per deck
    ```
    above `.SH DESCRIPTION`, then `mandb -c -u scratch` and
    `MANPATH=$PWD/scratch whatis hatch-tally`. `mandb` needs `man8/` under the
    manpath, so the copy has to go to `scratch/man8/` — students who copy it
    flat will get 0 pages added, which is a useful five minutes.

## D. Where pages live

39. ```
    /opt/kestrel/share/man:/usr/local/man:/usr/local/share/man:/usr/share/man
    ```
40. No. `man -w ls` gives
    `/nix/store/...-coreutils-full-9.11/share/man/man1/ls.1.gz`. The
    `/opt/kestrel/share/man` entry is a tree of symlinks into the Nix store, so
    the path `man` reports is the resolved target rather than the entry it
    matched. Students who say "it is not in manpath, so manpath is wrong" should
    be asked to `ls -l /opt/kestrel/share/man/man1/ls.1.gz`.
41. ```
    /nix/store/...coreutils-full-9.11/share/man/man1/printf.1.gz
    /usr/share/man/man1/printf.1.gz
    /usr/share/man/man3/printf.3.gz
    ```
    Two different section 1 pages (two packagings of coreutils) and one section
    3 page.
42. The first. Manpath order decides between the two section 1 pages —
    `/opt/kestrel/share/man` comes before `/usr/share/man` — and section order
    decides between 1 and 3.
43. Locale directories: `de`, `fr`, `ja`, `pt`, `uk` and so on, holding
    translated pages. `man` picks among them from `LC_MESSAGES`/`LANG`.
44. 180 files.
45. `No manual entry for nosuchpage`, exit status **16**.
46. `man nosuchpage; echo $?` is also 16. Piping into `head` makes `$?` report
    `head`'s status, which is 0 — the chapter 8 lesson, met again in a place
    where it silently turns a failure into a success. `${PIPESTATUS[0]}` is the
    fix.

## E. When there is no page

47. `type cd` says `cd is a shell builtin`. There is no `cd` program to
    document, so no package ships a `cd` page; `bash` documents its own
    builtins, and `help` is how you read that.
48. ```
    printf is a shell builtin
    printf is /opt/kestrel/bin/printf
    printf is /usr/bin/printf
    printf is /bin/printf
    ```
    `man printf` documents the `/opt/kestrel` one (exercise 42) — the builtin
    is documented by `help printf`, and the differences between the builtin and
    the external command are real.
49. Either a concrete example, or the stronger answer: you cannot tell from the
    outputs alone, because neither carries a date; you would have to compare
    both against the installed version (`dpkg -l`, lesson 02) or the source.
    Accept the argument, reject a bare assertion.
50. Binary, source (empty here), and manual page:
    `ls: /usr/bin/ls /nix/store/...-kestrel-env/bin/ls /usr/share/man/man1/ls.1.gz`.
51. `man: can't resolve man7/groff_man.7`. The page cross-references a groff
    page that this image does not ship — documentation was stripped when the
    image was built, the same reason `dpkg -V` reported hundreds of missing
    `/usr/share/doc` files in lesson 02. Same cause, different symptom.

## F. Stretch

52. ```bash
    mans() { apropos "$1" | sort -t'(' -k2,2; }
    ```
    Anything that sorts on the parenthesised section is fine.
53. Wanted shape:
    ```bash
    #!/usr/bin/env bash
    set -euo pipefail
    cmd=${1:?usage: whatis-or-help COMMAND}
    if whatis "$cmd" >/dev/null 2>&1; then
        whatis "$cmd"; exit 0
    elif "$cmd" --help >/dev/null 2>&1; then
        "$cmd" --help 2>&1 | head -1; exit 1
    else
        printf 'no documentation for %s\n' "$cmd" >&2; exit 2
    fi
    ```
    Running an unknown command with `--help` to see whether it exists is worth
    a conversation: it executes the thing. `command -v` first is the careful
    version.
54. `shellcheck` 0.11.0 is clean on the above.
55. ```bash
    for f in /opt/kestrel/bin/*; do
        b=$(basename "$f")
        man -w "$b" >/dev/null 2>&1 || printf 'no page: %s\n' "$b"
    done
    ```
    `/usr/local/bin` holds only `locate` here, which is why the exercise offers
    the alternative. 215 entries in `/opt/kestrel/bin`.

## G. Bring it together

56. Verifiable: `dpkg -L deck-audit` does not list `/etc/deck-report.conf`;
    `dpkg -S /etc/deck-report.conf` attributes it to `deck-report` if that
    package is still installed, and to nothing if it was purged. Two honest
    sentences name the package that does own the file, or say no package does.
    Any sentence containing a person's name fails this exercise.
57. A defensible order: `man 5 NAME` for the format; `man -k` on a distinctive
    word if the page's name is not the file's name; the package's own
    documentation under `/usr/share/doc/PACKAGE/`; and finally the file itself
    with its comments. Each is more specific to this machine and less
    authoritative about intent than the last.

## Instructor notes

- Exercise 38 is the one worth watching. The failure mode is copying the page
  to `scratch/` rather than `scratch/man8/`, and `mandb` reporting zero pages.
- Exercise 40 catches students who trust `manpath` and students who trust
  `man -w` — the reconciliation is the symlink tree.
- The arc content is one line of `notes/page.txt` about a page naming a file its
  package does not ship. Keep it at that. It is documentation rot until
  something else says otherwise, and nothing else does until lesson 06.
