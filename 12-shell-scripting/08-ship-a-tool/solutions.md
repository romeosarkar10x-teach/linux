# 12/08 — solutions

All outputs measured in the container.

## A. The three requirements

1. `bash: broken/noexec: Permission denied`, status **126**.
2. `chmod +x broken/noexec`; then `ran`, status 0.
3. ```
   bash: broken/bad-shebang: cannot execute: required file not found
   ```

   Status **127**.
4. The **interpreter**. `#!/bin/bahs` does not exist, so the kernel cannot start
   the script. The message names the script, which is why this bug is usually
   mis-diagnosed as a missing or deleted file.
5. `bahs` → `bash`. Then `ran`.
6. It runs because bash and dash both fall back to interpreting a file with no
   shebang themselves. It is a bug because nothing in the file says which
   language it is: exec'd directly, or run from a shell that is not
   POSIX-ish, it fails — and the file is a lie to every reader and editor.
7. Last byte of line 1 is `0d` (CR). The error is:

   ```
   /usr/bin/env: 'bash\r': No such file or directory
   /usr/bin/env: use -[v]S to pass options in shebang lines
   ```

   Status 127. The interpreter name literally includes the carriage return.
8. **126** is found-but-not-runnable. **127** is not-found — either the command
   itself, or its interpreter.

## B. PATH

9. Nothing printed, status 1. `command -v` is silent on failure, which is what
   makes it usable in an `if`.
10. It does not exist. `~/.profile` adds it to PATH **only if the directory
    already exists** at the time the profile is read.
11. No. The current shell's PATH is unchanged.
12. `~/.profile` is read by **login** shells, at login. Creating the directory
    now changes nothing about a shell that started before it existed — the `if`
    was evaluated in the past. Two things had to be true and neither is
    retroactive.
13. Either `export PATH="$HOME/.local/bin:$PATH"` (this shell only) or
    `. ~/.profile` (re-runs the file). The first is honest about its scope; the
    second re-runs everything else in the profile too, which is usually fine and
    occasionally not.
14. ```
    $ bash -l -c 'echo "$PATH"'
    /home/cadet/.local/bin:/opt/kestrel/bin:/usr/local/sbin:...
    ```
15. Any two lines with a shebang and `chmod +x`. Running it from `/` proves the
    PATH lookup rather than the current directory.
16. ```
    bash is /usr/bin/bash
    bash is /bin/bash
    ```

    Two paths (`/bin` is a symlink to `/usr/bin` on this system, so it is one
    file with two names). The **first** wins — `type -a` lists in PATH order.
17. The **old** one, `~/.local/bin/demo`, still ran. Measured: `late`.
18. bash remembers the full path of a command the first time it looks it up.
    `hash -r` empties that table, so the next lookup walks PATH again and finds
    the new, earlier file — measured: `early`.
19. Run the command once (populating the hash), add the shadowing file, then
    `PATH="$PATH"` and run again. If the shadow now wins, the assignment cleared
    the table. Measured: it does. The distinguishing control is exercise 17 —
    same setup, *no* assignment, old file still wins — which proves the hash was
    consulted.
20. `rm` both, then `command -v demo` prints nothing, status 1.

## C. The tool you are replacing

21. stdout. `examples/logsize --help > /dev/null` prints nothing;
    `examples/logsize --help 2>/dev/null` prints everything.
22. Only the destination and the status: stderr, 64. The text is identical
    on purpose — one help text, two situations.
23. `--help` 0, no argument 64, missing file 66, real file 0
    (`data/decks.txt: 90 bytes, 5 lines`).
24. With no argument it prints **all five decks**:

    ```
    deck-01 engineering
    deck-02 hydroponics
    deck-03 cargo
    deck-04 medical
    deck-05 observation
    ```

    Status 0.
25. `grep "$1"` with `$1` unset. An empty pattern matches every line, so a
    missing argument turns into "print the whole file" — and it looks like a
    feature until somebody scripts against it.
26. `deckinfo 01` and `deckinfo engineering` both work because the argument is a
    substring pattern, not a deck id. That is not a feature, it is an
    unspecified one: `deckinfo deck-0` matches five decks. A usable help line
    would be: *"ARG is a grep pattern matched against the whole line; it is not
    anchored and it is not a deck id."*
27. It cannot be tested against sample data; it cannot be moved or installed
    anywhere else; and the path is invisible to anyone who runs `--help`,
    because there is no `--help`.
28. Status **1**, silently. That status came from `grep`, not from `deckinfo` —
    the last command's status became the script's. It is accidentally right
    today and wrong the moment anything is added below that line, and it comes
    with no message, so the caller cannot tell "no such deck" from "no faults
    recorded" from "the data file moved".
29. Fails 4 (`--help`), 5 (exit codes), and 6 (no surprises — the hard-coded
    path, and the empty-argument behaviour). It passes 1, 2 and 3 as installed.
30. Every caller has had to read the source to learn the argument order, and
    every one of them learned an unspecified behaviour that the author never
    promised and cannot now change.

## D. `stationctl`

Reference implementation — `shellcheck` clean, status 0:

```bash
#!/usr/bin/env bash
# stationctl -- station deck and fault reporting
#
# exit: 0 ok, 1 check failed (a result, not an error),
#       64 usage error, 66 data missing
set -euo pipefail

: "${STATIONCTL_DATA:=/labs/12-shell-scripting/08-ship-a-tool/data}"
VERSION="stationctl 1.0"

usage() {
    cat <<USAGE
usage: stationctl COMMAND [ARGS]

commands:
  decks              list decks
  faults [DECK]      fault counts, all decks or one
  check              exit 1 if any deck is over the fault threshold

  --help             this text
  --version          version string

environment:
  STATIONCTL_DATA    data directory (default: $STATIONCTL_DATA)

exit codes:
  0   ok
  1   check failed -- a result, not an error
  64  usage error
  66  data missing
USAGE
}

need_data() {
    [ -d "$STATIONCTL_DATA" ] || {
        echo "stationctl: no data directory: $STATIONCTL_DATA" >&2; exit 66; }
    [ -f "$STATIONCTL_DATA/$1" ] || {
        echo "stationctl: missing data file: $STATIONCTL_DATA/$1" >&2; exit 66; }
}

cmd_decks() { need_data decks.txt; cat "$STATIONCTL_DATA/decks.txt"; }

cmd_faults() {
    need_data faults.txt
    if [ $# -eq 0 ]; then
        awk '{print $2}' "$STATIONCTL_DATA/faults.txt" | sort | uniq -c \
            | sort -rn | awk '{print $2, $1}'
        return 0
    fi
    need_data decks.txt
    local deck=$1
    grep -q "^$deck " "$STATIONCTL_DATA/decks.txt" || {
        echo "stationctl: no such deck: $deck" >&2; exit 66; }
    local n
    n=$(grep -c " $deck " "$STATIONCTL_DATA/faults.txt" || true)
    echo "$deck $n"
}

cmd_check() {
    need_data faults.txt
    local over
    over=$(awk '{c[$2]++} END {for (d in c) if (c[d] > 2) print d, c[d]}' \
        "$STATIONCTL_DATA/faults.txt" | sort)
    [ -n "$over" ] || return 0
    echo "$over"
    return 1
}

cmd=${1:-}
[ $# -gt 0 ] && shift
case "$cmd" in
    decks)     cmd_decks "$@" ;;
    faults)    cmd_faults "$@" ;;
    check)     cmd_check "$@" ;;
    -h|--help) usage; exit 0 ;;
    --version) echo "$VERSION" ;;
    "")        usage >&2; exit 64 ;;
    *)         echo "stationctl: unknown command: $cmd" >&2; usage >&2; exit 64 ;;
esac
```

Measured behaviour, run from `/`:

```
--help      the help text on stdout            rc 0
(none)      the help text on stderr            rc 64
wobble      stationctl: unknown command: wobble + help on stderr   rc 64
--version   stationctl 1.0                     rc 0
decks       the five decks                     rc 0
faults      deck-03 3 / deck-05 1 / deck-01 1  rc 0
check       deck-03 3                          rc 1
```

31–34. As above. Note `[ $# -gt 0 ] && shift` rather than `shift || true`: under
`set -e` a bare `shift` with no arguments is a failing command, and the guard
says what you meant.

35. `:=` assigns when the variable is unset **or empty**. Plain `=` is not an
    assignment form at all in this context — `${VAR=default}` is, and it leaves
    an explicitly-empty `STATIONCTL_DATA=` in place, which then fails as a
    directory name with a confusing message.
36. `need_data`, above. The message names the path, because "data missing" with
    no path is a second debugging session.
37–40. As above. `check` trips on **deck-03**, with three faults.
41. In the `exit codes:` block: `1  check failed -- a result, not an error`.
    It matters because `stationctl check || alert` and `set -e` both treat a
    non-zero status as failure; the caller has to know which of your non-zero
    statuses mean "the answer is no" and which mean "I could not answer".
42. It does, because `STATIONCTL_DATA` defaults to an absolute path and every
    file reference goes through it.
43. Clean, status 0.
44. The help must state that `faults` takes a **deck id** (not a pattern), and
    that `decks` lists them — otherwise the reader cannot get a valid deck id
    from the tool itself, which is exactly `deckinfo`'s failure.

## E. Experiment

45. `0` and `64`. Redirection never changes a status.
46. ```
    stationctl: no data directory: /nonexistent
    ```

    Status 66. Actionable because it names the path and the variable is
    documented in `--help`.
47. `bash: /home/cadet/.local/bin/stationctl: Permission denied`, status
    **126** — the shell found it on PATH and could not run it.
48. `stationctl: no such deck: `, status 66. Correct, and ugly: the empty
    argument should be its own message. Adding `[ -n "$deck" ] || { ...; exit
    64; }` makes it a usage error, which is what it is.
49. `grep -q "^$deck "` still matches, and the `faults.txt` format is
    whitespace-separated, so a deck name with a space cannot be represented in
    the fault log at all. The honest fix is a delimiter the data can carry
    (12/06's colon-separated `crew.csv`), not more quoting.
50. ```
    bash: stationctl: command not found
    ```

    Status **127** — the command itself was not found, since `~/.local/bin` was
    not on that PATH. Exercise 8's other 127.

## F. Stretch

51. The trap is quoting the values, not building the braces. Emit with `printf
    '{"deck":"%s","faults":%s}\n' "$d" "$n"` and note that this is safe only
    because deck ids contain no quotes or backslashes — which is an assumption
    you should write down next to the code.
52. Parse before dispatching, reuse 12/06's `case ''|*[!0-9]*` digit check, exit
    64 with a message naming the bad value.
53. Any help that states: the argument is an unanchored pattern, the data path
    is fixed, and the status is `grep`'s. The note for `notes/` is the one
    sentence rhea did not write in 2186.
54. Looking for a message about the interface: commands, exit codes, the
    environment variable — not "added awk pipeline".

## G. Dig

55. `type` and `command` are **shell builtins**; `which` is `/usr/bin/which`, a
    separate program that does not know about builtins, functions or aliases and
    whose output format varies between systems. `command -v` is POSIX, built in,
    and silent-with-status-1 on failure — the only one of the three safe in a
    script.
56. `#!/usr/bin/env -S bash -euo pipefail`. From `man env`: *"process and split S
    into separate arguments; used to pass multiple arguments on shebang lines"*.
57. `command NAME` ignores functions (and `command -p` also ignores your PATH,
    using a default one). Measured: with `ls() { echo FUNC; }` defined, `ls`
    prints `FUNC` and `command ls -d /` prints `/`. A script that defines a
    helper function shadowing a real command — a `log()`, a `test()`, an
    `ls()` — breaks every later call to the real one unless it uses `command`.

## H. Bring it together

58. Self-scored, in writing. Look for honesty about 6: a hard-coded default path
    is a surprise mitigated by the environment variable and the `--help` line,
    not eliminated.
59. Looking for: the interface is written down in two places that ship with the
    tool — the exit-code comment block at the top and `--help` — so nobody has to
    read the source or ask the author, and the author being unavailable costs
    nothing.
