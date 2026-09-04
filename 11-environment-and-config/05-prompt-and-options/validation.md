# Validation — 11/05 prompt and options

Agent rubric. No script grades this lesson.

## Pass requires all of

1. Can state that `PS1` is expanded before **every** prompt, with evidence
   (`\t` or `$(date)` changing between prompts), not just asserted.
2. Distinguishes `\w` from `\W` and `PS1` from `PS2`/`PS4`/`PROMPT_COMMAND`,
   with `PROMPT_COMMAND` correctly described as a command, not a prompt.
3. Explains `\[ \]` as zero-width markers for readline's column count, and uses
   that to diagnose rhea's prompt without blaming the terminal.
4. Knows the sign convention: `set -u` on / `set +u` off, `shopt -s` on /
   `shopt -u` off — and does not mix them up when asked to turn something off.
5. Predicted the `checks.sh` output before running it, then correctly explains
   why `if`, `||` and the mid-pipeline failure are exempt from `set -e`.
6. Demonstrates `pipefail` changing a pipeline's exit status, on `checks.sh` or
   on the audit.
7. Explains the audit bug in terms of exit statuses — `cat` 1, `wc` 0,
   pipeline 0 — and not as "the script is broken".
8. Produces a working audit in `scratch/` that prints `decks audited: 12` and
   exits non-zero when its input is missing.
9. Says why `${SHIFT_NAME:-unassigned}` survives `set -u`, and knows options do
   not propagate into a script with a shebang.
10. Can name what each of `dotglob`, `nocaseglob`, `globstar`, `nullglob`,
    `failglob` changed in `glob/`, and argues why `nullglob` is the dangerous
    one in a script.
11. Found both `HISTSIZE` lines in `~/.bashrc` and gave "last assignment wins"
    as the reason, not a guess.
12. States that none of this lesson's changes survive a new shell, and connects
    that to lesson 03.

## Lab state

The lab should be unchanged apart from `scratch/`:

    cd /labs/11-environment-and-config/05-prompt-and-options
    find . -newermt '2187-06-26 09:00:01' -not -path './scratch/*'

Expect no output. Also:

    stat -c '%a' scripts/deck-audit.sh scripts/deck-audit-strict.sh   -> 755 755
    stat -c '%y' scripts/deck-audit.sh                                -> 2186-04-18 10:05:00
    wc -l < data/decks                                                -> 12

A modified `rc/prompts.sh` is a fail for exercise 22 specifically — the point of
that exercise is that the two strings differ only in `\[ \]`, and a student who
"fixed" the broken one has erased the evidence.

## Red flags

- "It's the terminal" survives into their final answer to rhea.
- Claims `set -e` would have caught the audit bug on its own. It would not —
  without `pipefail` the pipeline succeeded.
- Claims the audit script was modified or sabotaged. It was not; check the
  timestamp. A student who reaches for sabotage before reading exit statuses is
  guessing.
- Edits a startup file to make a prompt persist. Nothing in this lesson asks for
  that, and lesson 06 is about what happens when someone does.
- Turns options off with the wrong sign and does not notice the shell said
  nothing.

## Good signs

- Ran `set -o` and `shopt -p` *before* changing anything, and can restore state.
- Noticed `extglob` differs between interactive and script shells and connected
  it to 11/03's `expand_aliases` without being prompted.
- Chose `wc -l < file` over `cat file | wc -l` and can say why in terms of
  exit statuses rather than style.
- Refused to connect the two pages, and said what evidence would be needed.

## If the answers are thin

- "Set `PS1='\t \$ '` and press Enter three times. Now explain when `PS1` is
  expanded."
- "Run `checks.sh`. Which of the four `false`s stopped it? Why only that one?"
- "What exit status did `wc -l` return when its input was empty?"
- "Turn on `nullglob` and run `echo start *.zzz end`. Now imagine that command
  was `cp start *.zzz end`."
