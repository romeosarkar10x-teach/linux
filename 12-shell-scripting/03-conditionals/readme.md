# 12/03 — Conditionals

> Three ways to test the same thing, one of which is a builtin that behaves
> differently, and the station's older scripts use all three.

`if` does not test a value. It runs a command and reads its exit status: `0` is
true, anything else is false. That is the whole grammar, and it explains why
`if grep -q nominal decks` needs no brackets at all — `grep` *is* the test.

## The three forms

```
test EXPR       a shell builtin (and also a real program, /usr/bin/test)
[ EXPR ]        the same builtin under another name
[[ EXPR ]]      a bash keyword — parsed by the shell, not run as a command
```

`[` is a **command**. The `]` is an argument to it, which is why it must be
there and why every operator needs spaces around it: `[ "$a"="$b" ]` is one
argument, not three, and is always true.

Because `[` is a command, its arguments go through word splitting and globbing
first, like any other command's:

```
v=""       [ $v = x ]   →  [ = x ]      →  bash: [: =: unary operator expected
v="a b"    [ $v = x ]   →  [ a b = x ]  →  bash: [: too many arguments
```

Both errors go to stderr and both leave status **2**. And if the `if` is the
second-to-last thing in a script, the script still exits 0 — which is exactly
what `bin/gate` has been doing since 2186.

`[[ ]]` is parsed by the shell before any of that happens, so no splitting and
no globbing occur inside it and the unquoted form works. That is why `[[ ]]` is
friendlier — and why people who learn only `[[ ]]` write `[ ]` wrong. Use `[[ ]]`
in bash scripts, `[ ]` when the script must run under `sh`. Quote either way.

## The operators are backwards from what you expect

```
strings:  =  ==  !=  -z (empty)  -n (non-empty)
numbers:  -eq -ne -lt -le -gt -ge
files:    -e -f -d -L -r -w -x -s -nt -ot
```

Numbers get the letters; strings get the symbols. Ten seconds of memorising now
saves you the following:

```
[[ 10 > 9 ]]        FALSE   — string comparison; "1" sorts before "9"
[ 10 -gt 9 ]        TRUE    — arithmetic
```

`bin/version-gate` uses the first. It was written when the newest toolchain
release was 9, and it has been correct for every release since. Release 10
published this morning and ops-bot is holding the deployment.

`[[ ]]` also *hides* the mirror-image mistake: `[ abc -eq 1 ]` says
`integer expression expected` and returns 2, while `[[ abc -eq 1 ]]` evaluates
`abc` as arithmetic, gets 0, and quietly returns false. The friendlier form is
friendlier about your bugs too.

## Two things `[[ ]]` can do that `[ ]` cannot

```
[[ $name == deck-* ]]     glob matching (unquoted right side, deliberately)
[[ $name =~ ^deck-[0-9]+$ ]]   regex, ERE, with captures in ${BASH_REMATCH[@]}
```

Quote the right-hand side and it becomes a literal again — `[[ $n == "deck-*" ]]`
matches one specific weird filename. That quoting rule is the opposite of
everywhere else, so say it out loud once.

## Combining

`&&` and `||` chain on status, and inside `[[ ]]` they are operators:

```bash
if [ -e "$f" ] && [ -r "$f" ]; then ...     # two commands, portable
if [[ -e $f && -r $f ]]; then ...           # one keyword
```

`[ a -a b ]` is legal, deprecated, and ambiguous with filenames. Don't.

And `cmd && echo ok || echo failed` is **not** an if/else: if `echo ok` fails,
`echo failed` runs too. It reads like if/else nine times out of ten and is
wrong on the tenth. When you mean if/else, write if/else.

## What you will do

Reproduce both of `[ ]`'s classic errors on purpose. Work out why
`version-gate` was right for four years and is wrong today, and fix it in one
character class. Then build a file classifier and argue about the order of its
branches.
