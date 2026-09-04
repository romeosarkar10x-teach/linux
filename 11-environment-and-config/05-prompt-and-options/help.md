# Tutor notes — 11/05 prompt and options

Never hand over an answer. Ask the question that makes the student measure.

## The one thing they must leave with

A default is a decision somebody made for you. The audit script is not broken:
`cat` failed correctly, `wc` succeeded correctly, the pipeline reported its last
stage correctly, and the result was a wrong number filed as fact for forty
cycles. `set -euo pipefail` is not a style preference; it is the line where you
say which of those correct behaviours you refuse to accept.

The prompt half is the same shape wearing a costume: readline behaves correctly
given a string that lies about its own width.

## Stuck points

- **Ex 13–14 (when is PS1 expanded).** If they think `PS1` is expanded once at
  assignment, do not tell them. Ask what `\t` would show if that were true.
- **Ex 17 (sourcing prompts.sh changes nothing).** Very common. Ask them to
  `grep PS1 rc/prompts.sh`. The file never assigns it.
- **Ex 20–23 (rhea's bug) — the cliff for the first half.** They will often say
  "the colours look the same, so the prompts are the same". Push them to `diff`
  it (ex 22) rather than to look harder. If they still cannot see why invisible
  characters matter, ask: *how does the shell know where your cursor is?*
- **Ex 32 (extglob on interactively, off in a script).** Students conclude the
  measurement is wrong. It is not. This is the same class of surprise as 11/03's
  `expand_aliases`: interactive and non-interactive shells are configured
  differently, and code that only ever ran interactively has never been tested.
- **Ex 38–40 (why set -e did not fire) — the real cliff.** Almost everyone
  predicts the script dies at the first `false`. Let them be wrong first (ex 35
  asks for a written prediction on purpose). Then: *what is `if` doing with that
  exit status?* The rule is "untested commands only".
- **Ex 44 (`${VAR:-default}` under `set -u`).** If they claim it should fail,
  ask what `set -u` is protecting them from, and whether a supplied default is
  that thing.
- **Ex 46 (options do not reach a script).** Frequently mistaken for a bug in
  the exercise. Ask how many shells are involved when a script with a shebang
  runs. Mention `export SHELLOPTS` only after they have found `bash -u`, and
  mention the cost with it.
- **Ex 48 (the audit).** The gap between "every component succeeded" and "the
  answer is wrong" is the whole chapter's argument. Do not summarise it for
  them; ask for the exit status of each of `cat`, `wc`, and the pipeline,
  separately.
- **Ex 57 (nullglob).** Students rank `failglob` as the dangerous one because it
  errors. Ask what `cp $files /dest` does when `$files` vanishes.
- **Ex 60 (two HISTSIZE lines).** Some will argue the first wins. Ask them what
  a shell does with two assignments to the same variable in one file.

## Red herrings

- `rc/options.sh` includes `cdspell`, which nothing in the lesson tests. It is
  there because it is the option most likely to make a student say "wait, is my
  shell correcting me?" Leave them to discover it.
- `PROMPT_COUNT` in `rc/prompts.sh` runs `ls | wc -l` every prompt. It is not
  wrong. It is a reasonable thing that becomes unreasonable in a directory with
  200000 files, and that is worth a conversation if they raise it.
- `glob/notes.log` matches none of the exercises' patterns. It is there so that
  `*.txt` has something to *not* match.
- The two pages are genuinely unrelated. Do not let a student build a theory
  that connects them; ask what evidence connects them.

## Integrity check

    stat -c '%y' scripts/deck-audit.sh      -> 2186-04-18 10:05:00
    wc -l < data/decks                      -> 12
    ls /var/lib/kestrel                     -> No such file or directory

If a student has edited `scripts/deck-audit.sh` in place rather than copying it
to `scratch/`, that is worth naming — not as a rule violation, but because
exercise 5's timestamp evidence is now gone for everyone including them.

    kestrel reset 11/05
