# 12/08 — ship a tool

> `stationctl`. Executable, on your PATH, with a `--help` that answers the
> question people will actually ask. This is the first thing you will leave
> behind that is better than what you found.

`examples/deckinfo` has been on the station since 2186. It works. Its author's
note is in `notes/page.txt`: *"It is not documented anywhere and nobody but me
knows the argument order. Will write it up later."* There is no follow-up on
file.

Everything so far in this chapter has been a script — something you run by
typing a path. This lesson is about the six things that turn a script into a
tool somebody else can use without reading it.

## 1. A shebang

Line 1, column 1, no leading space:

```bash
#!/usr/bin/env bash
```

`#!/bin/bash` names one path. `#!/usr/bin/env bash` asks PATH for `bash`, which
is what you want when the same file has to run on a machine where bash lives
somewhere else. The cost is that `env` cannot pass options portably — so no
`#!/usr/bin/env bash -e`; put `set -e` on line 2 instead.

> **Two failure statuses you must be able to tell apart.**
> `126` — the file was found and could not be run (usually no `x` bit).
> `127` — not found. **Also** what you get when the file *is* found and its
> *interpreter* is not: a typo in the shebang gives
> `cannot execute: required file not found`, which reads like the script is
> missing. It is not. `broken/bad-shebang` is that exact bug.

A file with no shebang at all still runs from bash and from dash — the shell
falls back to running it itself. That is not portability, it is luck: it breaks
the moment something execs it directly.

## 2. The `x` bit

`chmod +x stationctl`. Without it: `Permission denied`, status 126.

## 3. A name on PATH

Not `./stationctl` from the one directory it lives in. `~/.local/bin` is the
conventional per-user location, and your `~/.profile` already has:

```bash
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi
```

Two things follow from that `if`, and you will meet both today.

To ask where the shell would go, and where it could go:

```
command -v stationctl     # one answer, or status 1 and nothing
type -a stationctl        # every match, in PATH order
hash -r                   # forget the remembered locations
```

## 4. `--help`

The help text is the interface. Write it for someone who has your tool's name
and nothing else:

```
usage: stationctl COMMAND [ARGS]

commands:
  decks              list decks
  faults [DECK]      fault counts, all decks or one
  check              exit non-zero if any deck is over the fault threshold

  --help             this
  --version          version string

exit codes:
  0   ok
  1   check failed (this is a result, not an error)
  64  usage error
  66  data file missing
```

Rules that are not style opinions:

- `--help` goes to **stdout** and exits **0**. Somebody is piping it to `less`.
- A usage **error** prints the same text to **stderr** and exits **64**.
- Both, because `stationctl --help | less` and `stationctl 2>/dev/null` are
  different situations with different right answers.

## 5. Documented exit codes

You met the `sysexits` numbers in 12/02. Write them in a comment at the top of
the file and in `--help`, and then never change one without changing both.
Distinguish an **error** (64, 66 — you were asked something impossible) from a
**result** (1 — you were asked a question and the answer was no).

## 6. No surprises

Answers on stdout, everything else on stderr. Nothing written outside the paths
you were given. No `cd` that leaks. A hard-coded data path is a surprise; take
it from the environment with a default instead:

```bash
: "${STATIONCTL_DATA:=/labs/12-shell-scripting/08-ship-a-tool/data}"
```

`:=` assigns the default if unset **or empty**, so an operator can point the
tool at other data without editing it.

## Subcommand dispatch

Everything you need is 12/05:

```bash
cmd=${1:-}
shift || true
case "$cmd" in
    decks)  cmd_decks "$@" ;;
    faults) cmd_faults "$@" ;;
    check)  cmd_check "$@" ;;
    -h|--help) usage; exit 0 ;;
    --version) echo "stationctl 1.0" ;;
    '')     usage >&2; exit 64 ;;
    *)      echo "stationctl: unknown command: $cmd" >&2; usage >&2; exit 64 ;;
esac
```

The unknown-command branch is the one people leave out, and it is the one that
turns a typo into silence.

## Before you move on

- Shebang on line 1, `chmod +x`, and a directory on PATH — all three, or it is
  not a tool.
- `126` is "found it, cannot run it"; `127` is "not found" **or** "interpreter
  not found".
- `--help` to stdout exits 0; a usage error to stderr exits 64.
- `command -v` says where; `type -a` says where else; `hash -r` forgets.
- A tool with an undocumented interface has exactly one user, and only until
  they forget.
