# 12/02 — Arguments

> A script that only works on one file is a note to yourself. The difference is
> about four characters, and one of them is a quote mark.

`deck-count.sh` from lesson 01 counts one file, forever, because the file is
written into it. Take the filename from the caller instead and the same six
lines become a tool. That is the whole of this lesson — except that the way most
people take the filename is subtly wrong, and it stays wrong until somebody names
a deck "cargo hold".

## The positional parameters

```
$0    the name the script was invoked as
$1 $2 ... the arguments, in order.  ${10} needs braces — $10 is $1 then a 0
$#    how many there are ($0 not counted)
$@    all of them
$*    all of them, joined into one string with the first character of IFS
```

`$0` is a string the caller chose, not a location. `./bin/show-args` and
`/labs/.../bin/show-args` are the same file with two different `$0` values, which
is why usage messages say `$(basename "$0")`. Sourced, `$0` is the *shell's*
`$0` — the script never got one.

## `"$@"` versus `$@` versus `"$*"`

This is the lesson. One script, one argument list, three results:

```
$ show-args-loop "cargo hold" beta
--- "$@"     <cargo hold>  <beta>          two words, as given
--- $@       <cargo> <hold> <beta>         split on whitespace, then globbed
--- "$*"     <cargo hold beta>             one word
```

Unquoted, `$@` and `$*` are both subject to word splitting and then pathname
expansion — Chapter 5's expansion order, applied to arguments you did not
control. Quoted, `"$@"` is special-cased by the shell to expand to exactly one
word per argument, and to *nothing at all* when there are none. `"$*"` is one
word always, joined by `${IFS:0:1}` (a space by default; change `IFS` and the
joining changes with it).

Write `"$@"`. Every time. If you genuinely want one string, write `"$*"` and put
a comment next to it saying so, because the next reader will assume it is a typo.

The same rule applies to your own use of `$1`: `wc -l < $DECKS/$1` and
`wc -l < "$DECKS/$1"` differ by two characters, and the first one fails on a
deck with a space in its name — not with "no such file", which would at least be
honest, but with `ambiguous redirect`, and then exits 0 anyway because the last
command in the script was an `echo`. rhea has filed a page about exactly this.

## `shift`

`shift` drops `$1`; everything moves down; `$#` decreases. `shift N` drops N. And
`shift` with nothing left to drop **returns 1 and changes nothing** — which is
the loop you want:

```bash
while [ "$#" -gt 0 ]; do
    echo "handling $1"
    shift
done
```

`set -- a b c` replaces the positional parameters wholesale. That is how you
supply defaults: check `$#`, and if it is zero, `set --` your own list.

## Checking before using

A script that guesses will one day guess wrong on your data. Three obligations:
check `$#` before you touch `$1`, print usage to **stderr** (Chapter 8), and
exit **nonzero** so the caller's `if` can see it. `64` is the conventional
usage-error status; any nonzero will do, and consistency matters more than the
number.

Under `set -u`, an unset `$1` is a hard error — useful. `${1:-all}` gives a
default instead, and both are better than the third option, which is a script
that runs happily on an empty string.

## What you will do

Read `deck-report`, find both of its bugs, and prove which one `deck-report-2`
fixed. Trace an argument through two scripts and watch it split in the middle.
Then write the tool version of `deck-count.sh`.
