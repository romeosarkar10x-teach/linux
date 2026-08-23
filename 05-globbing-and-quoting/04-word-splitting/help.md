# 05/04 — Help

Ladder. Stop climbing the moment it clicks.

## Three facts to hold on to

- Splitting happens to **unquoted expansions**, after the value is substituted and before globbing.
- `IFS` whitespace collapses; `IFS` non-whitespace does not.
- `count.sh` answers every "how many arguments" question experimentally. Do not guess.

## Level 1 — the instrument

You have a script that tells you exactly what the shell handed to a command:

```
bash scripts/count.sh whatever you like
```

and a second instrument that shows you the command line *after* expansion:

```
set -x
your command here
set +x
```

`set -x` requotes what it prints, so a traced line shows you where the argument boundaries fell.
Between the two of them, nothing in this lesson has to be a matter of opinion.

## Level 2 — what to look at

- Anything about `IFS` collapsing: build the string with `printf` so you are certain how many
  separators are in it, then `set -- $string; echo $#`.
- Anything about `read`: the three pieces are `IFS=`, `-r`, and the redirect. Turn them off one at a
  time and see which behaviour changes.
- Anything about `$@`: it only means something inside a script or function. Write the script.
- `man bash`, and search for `Word Splitting` — it is four paragraphs and it is the whole subject.
  `IFS` is defined a little earlier under `Shell Variables`.

## Level 3 — pointed questions

- If `a   b` gives two fields and `a:::b` with `IFS=:` gives four, what is the rule that produces
  both answers? It is one rule, not two.
- `read -r l` on a line with leading spaces loses them. Which of `IFS` and `-r` is responsible?
  You can find out by changing one at a time.
- The four `$@`/`$*` forms give you three different answers on `'a b' c`. Two of the four give the
  same answer as each other — which two, and what do they have in common?
- `for p in $(cat data/paths.txt)` gives nine iterations for a five-line file. Splitting explains
  some of them. What explains the rest? Look at what is in the paths.
- `[ $v = 'a b' ]` fails when `v='a b'` **and** fails when `v` is unset, with two different
  messages. Write out the command line the shell actually built in each case.

## Level 4 — nearly the answer

- `IFS` is space, tab, newline: `printf '%q\n' "$IFS"` shows `$' \t\n'`.
- The rule: a run of `IFS` **whitespace** is one separator and leading/trailing runs are discarded;
  every other `IFS` character is a separator on its own, so two of them delimit an empty field.
- `read` strips leading and trailing `IFS` whitespace from the line. `IFS= read -r l` stops it,
  because with `IFS` empty there is no whitespace to strip. `-r` is a separate job: without it,
  backslash is an escape and a line ending in `\` continues onto the next one.
- `"$@"` preserves boundaries. `$@` and `$*` both split and give identical results. `"$*"` joins
  everything into one argument using the first character of `IFS`.
- The safe loop:
  ```
  while IFS= read -r line; do
      printf '[%s]\n' "$line"
  done < data/paths.txt
  ```
- `[[ ]]`, `case`, `$(( ))` and the right-hand side of an assignment do not word split. `[ ]` does,
  because `[` is an ordinary command that receives ordinary arguments.

## Level 5 — the near-miss

The wrong loop, so you can see exactly what is wrong with it:

```
for p in $(cat data/paths.txt); do
    cp -r $p /somewhere/
done
```

Two failures stacked. The substitution's output is split on whitespace — so a path containing a
space becomes several arguments — and then each resulting word is a candidate for pathname
expansion. Replace the `for` with the three-part `while read` above and quote `"$p"`, and both
failures go away. Then ask yourself what is still wrong if a path begins with a dash.

## Never say

- The count for exercise 39 (`$(cat data/paths.txt)`), or the second cause behind it.
- Which of `deploy.sh`'s four bugs is the one that is not about quoting.
- The one-character fix for `tally.sh`.
- The answer to exercise 55 — let them be surprised by `printf`.
- Anything from the Dig section.
