# Solutions — 11/05 prompt and options

Everything below was measured in the container.

## Reading the pages (1–6)

1. Exit status 0; `decks audited: 0`. Forty previous cycles said 12.
2. Non-zero exit status. It did not occur — that is why nothing was raised.
3. (a) The prompt redraws over itself when she edits a long, wrapped command.
   (b) The audit reports zero and the scheduler calls that success.
4. Both answers are acceptable here; the point is committing before knowing.
   She is right — see 23 and 48.
5. `2186-04-18 10:05:00`. The script has not been touched in over a year, so
   "it changed" is not available as an explanation. The *data* moved.
6. `ls: cannot access '/var/lib/kestrel': No such file or directory`. So the
   script's `cat` failed with the same error, printed nothing to stdout, and
   `wc -l` counted the nothing.

## The prompt as a string (7–16)

7. Under `kestrel enter` (`TERM=xterm`):
   `\[\e]0;\u@\h: \w\a\]${debian_chroot:+($debian_chroot)}\u@\h:\w\$ ` — the
   leading `\[...\]` block sets the terminal's title bar, and note that it is
   already wrapped in `\[ \]` because it prints nothing. On a dumb terminal
   Debian's `.bashrc` omits that block and `PS1` is just
   `${debian_chroot:+($debian_chroot)}\u@\h:\w\$ `.
8. `\u`, `\h`, `\w`, `\$`.
9. Nothing expands them any more; the prompt is now the literal text `hello$ `.
   `PS1` is only a string — nothing in it is mandatory.
10. `\W` is the basename: `[etc]` then `[/]`. In `/` both forms agree.
11. `\w` is the whole path (with `~` for home), `\W` the last component only.
12. The history number — it increments once per command you enter.
13. Yes, the time is current at each prompt. `PS1` is expanded *every time the
    prompt is drawn*, not once when it is assigned.
14. `date` runs once per prompt, forever. A command in `PS1` is a command you
    have agreed to run before every single thing you type.
15. Gone. Assignments live in one shell (11/01); a new shell reads the startup
    files (11/03), and your `PS1` was never written into one.
16. `PS2` is `> `. The unterminated quote gives you `> ` until you close it.

## Colour, and rhea's bug (17–24)

17. No. `rc/prompts.sh` only defines variables — `PROMPT_COLOUR` and friends.
    Nothing assigns `PS1`. Sourcing a file does exactly what the file says.
18. Green `user@host`, blue path.
19. It looks identical. Every visible character is the same.
20. The line wraps in the wrong column: readline believes the prompt is about
    twenty characters wider than it is, so its idea of where the cursor sits
    drifts, and moving to the start of the line redraws text over the prompt.
21. Correct behaviour — the line wraps where it should and Ctrl-A goes to the
    first character of your command.
22. Only the `\[` and `\]` pairs. The escape sequences are character for
    character identical, exactly as she said.
23. `\[` and `\]` mark a run of characters that occupies **zero** screen
    columns. Readline counts columns to place the cursor; without the markers
    it counts the eleven-odd invisible characters as visible. It only shows on
    long lines because that is the first time the count is used for anything —
    deciding where to wrap and where to redraw.
24. "It is not the terminal — your `PS1` is missing the `\[ \]` markers around
    the colour escapes, so readline thinks the prompt is wider than it is."

## PROMPT_COMMAND (25–28)

25. Unset — `[]`.
26. One `TICK`, immediately. Setting the variable does not run it; the shell
    then goes to draw the next prompt, and running `PROMPT_COMMAND` is the
    first thing it does.
27. After the command's output, before the prompt. That is the ordering that
    makes `PROMPT_COMMAND` useful for things like writing history to disk.
28. It would run before *every* prompt, so you could never stay in a directory
    — every command would be run from `/tmp` whatever you typed.

## Reading the switches (29–34)

29. 27 options; 6 are `on` in an interactive shell here.
30. 57.
31. `-p` prints reusable commands: `shopt -u globstar`. You can paste the output
    back in to restore state, which the `on`/`off` listing cannot do.
32. Not the same: `on` interactively, `off` in `bash -c`. Debian's interactive
    setup enables `extglob` (programmable completion needs it); a script gets
    the shipped default. A script that relies on `!(x)` without
    `shopt -s extglob` works when you paste it and fails when it runs.
33. `hiBHs`. `i` is interactive.
34. All four off: `errexit`, `nounset`, `pipefail`, `noclobber`.

## errexit (35–41)

36. `checkpoint 1`, `handled`, `checkpoint 2`, `checkpoint 3`, then exit **1**.
    `checkpoint 4` never prints.
37. Only the bare `false` before checkpoint 4.
38. A command whose status is being *tested* is exempt. `if`, `while`, `until`
    and `!` all consume the status themselves, so `set -e` never sees a failure.
39. Same rule: the left side of `||` (or `&&`) is being tested by the operator.
40. Without `pipefail` the pipeline's status is `true`'s — zero. With
    `set -o pipefail` the pipeline reports the failure and `set -e` stops the
    script at that line; `checkpoint 3` no longer prints and the status is 1.
41. `set -e` fires when a *simple, untested* command fails: not in a condition,
    not on the left of `&&`/`||`, not `!`-negated, and — unless `pipefail` is
    on — only if it is the last stage of a pipeline.

## nounset (42–46)

42. An empty string: `greetings, ` with nothing after the comma. That is the
    default and it is why the audit class of bug exists at all.
43. `scripts/greet.sh: line 5: OPERATOR: unbound variable`, exit **1**.
    (`bash -c 'set -u; echo $NOPE'` exits **127** instead — the "command not
    found" code, reused. Worth knowing before you write a status check.)
44. `${VAR:-default}` is a *defaulted* expansion. `set -u` objects to reading an
    unset variable with no fallback; supplying a fallback is exactly the
    remedy, so it is not an error.
45. Yes: `greetings, rhea`, exit 0. `SHIFT_NAME` still defaults.
46. The script has a shebang, so it runs in its own new shell with its own
    options — yours do not travel. Two ways to make it fail: run it as
    `bash -u scripts/greet.sh`, or put `set -u` inside the script. (A third
    exists: `export SHELLOPTS`, which pushes your `set` options into every
    child. It works. It also means every script you run changes behaviour
    because of your shell, which is a good way to make bugs unreproducible.)

## The audit (47–52)

47. `cat: /var/lib/kestrel/decks: No such file or directory` on stderr,
    `decks audited: 0` on stdout, exit 0.
48. `cat` failed with status 1. `wc -l` succeeded — counting zero lines is a
    success. A pipeline's status is its **last** stage's, so the pipeline was 0,
    the assignment was 0, and the script ran to the end and exited 0. Every
    component behaved correctly and the result is a wrong number reported as
    fact.
49. Nothing on stdout and exit **1**. `pipefail` is doing the work: it makes the
    pipeline report `cat`'s failure, and `errexit` then stops the script. `-u`
    is not involved here.
50. 12.
51. Point it at `data/decks` (absolute, or relative to a directory the script
    computes — a script that depends on your `cd` is a later chapter's problem):

        count=$(wc -l < /labs/11-environment-and-config/05-prompt-and-options/data/decks)
        echo "decks audited: $count"

    Note `wc -l < file` beats `cat file | wc -l` here for a second reason: with
    no pipeline there is no pipefail question, and a missing file makes the
    redirection itself fail.
52. Yes — but only because the script now *reports* failure. The scheduler
    configuration never changed and was never wrong. The script was.

## Glob options (53–57)

53. `report.txt` only. `REPORT.TXT` is the wrong case, `.hidden.txt` starts with
    a dot, `notes.log` is the wrong extension, and the two under `deck/` are in
    subdirectories.
54. `dotglob` adds `.hidden.txt`; `nocaseglob` adds `REPORT.TXT`; `globstar`
    with `**/*.txt` gives `deck/e/deep.txt deck/mid.txt report.txt`.
55. It prints `*.zzz` — the pattern itself, unexpanded. A glob that matches
    nothing is passed through literally. This is why `rm *.zzz` in an empty
    directory tries to delete a file called `*.zzz`.
56. `nullglob`: the word disappears entirely (`start end`). `failglob`:
    `bash: line 2: no match: *.zzz`, and the command does not run.
57. Default: `rm` is called with the literal `*.zzz` and reports it cannot find
    it — noisy, harmless. `failglob`: the command never runs and the shell says
    why — usually what you want in a script. `nullglob`: `rm` is called **with
    no arguments at all**. `rm` with no arguments is harmless; `rm -rf` with a
    prefix path, or `cp $files /dest`, or anything where the missing word turns
    a two-argument command into a one-argument one, is not. `nullglob` turns a
    visible failure into a silently different command.

## History and debrief (58–64)

58. `ignoreboth` = `ignoredups` + `ignorespace`. `HISTSIZE` is 100000 here and
    `HISTFILE` is `~/.bash_history`.
59. Only the first `echo alpha` and `history 5` are recorded — the duplicate is
    dropped by `ignoredups`, the space-prefixed one by `ignorespace`.
60. Two lines: `HISTSIZE=1000` (line 19, Debian's default block) and
    `HISTSIZE=100000` (line 122, added for this course). The file is read top to
    bottom, so the last assignment wins: 100000.
61. On. With it off, each shell *overwrites* the history file when it exits, so
    with two terminals open the last one to exit erases everything the other
    one did.
62. Nothing survives. Every `PS1`, `set`, `shopt` and variable in this lesson
    lived in one shell. `kestrel enter` starts a fresh login shell that reads
    the startup files, and none of your changes are in them. That is lesson 03's
    point, and lesson 06 is where it stops being harmless.
63. `pipefail` first — it changes whether wrong answers are reported as
    failures, which is the audit bug and can go unnoticed for forty cycles.
    `nocaseglob` second: it silently widens which files a command touches.
    `PS1` last: a broken prompt is annoying, visible, and hurts nobody's data.
    (Accept a defended ordering that puts `pipefail` first.)
64. Something like: "Your prompt is missing `\[ \]` around the colour escapes —
    readline is counting invisible characters as visible, which is why it only
    shows on wrapped lines. Separately, the audit reads
    `/var/lib/kestrel/decks`, which no longer exists; `cat` failed, `wc` counted
    zero successfully, and without `pipefail` the script exited 0 with a wrong
    number." No verdict on her guess; she gets the two mechanisms and can score
    herself.
