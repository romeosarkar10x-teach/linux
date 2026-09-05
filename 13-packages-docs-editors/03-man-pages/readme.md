# 13/03 — The manual is on the station

Lesson 01 and 02 were about getting software onto a machine. This one is about
answering questions about software already on it, without a network and without
asking anyone.

Every station this course has touched ships its documentation with it. That is
not a courtesy — it is the reason a crew can work three light-hours from the
nearest person who wrote any of it.

## Sections

`man` does not have one manual. It has eight, and the number in parentheses
after a name tells you which one a page belongs to:

```
1  commands you can run              5  file formats and configuration files
2  system calls                      6  games
3  library functions                 7  conventions and overviews
4  device files                      8  administrator commands
```

The same word lives in several sections and means different things in each.
`passwd(1)` is the command that changes your password. `passwd(5)` is the
format of `/etc/passwd` — the file you read in chapter 6. Plain `man passwd`
gives you the first match in section order, which is the command, which is
usually not what you wanted when you were staring at a colon-separated line.

```
man 5 passwd     the file
man -a printf    every printf page, one after another
```

Section 5 is the one people forget exists, and it is the one that answers
"what is this configuration file allowed to contain".

## Finding a page when you do not know the name

```
whatis NAME      the one-line description, exact name only
apropos WORD     every one-line description containing WORD
man -k WORD      the same command
man -K WORD      search the full text of every page
```

`apropos` and `whatis` do not read manual pages. They read an index built by
`mandb`. This matters more than it sounds: a page `man` will happily display
can be completely invisible to `apropos`, because the index is built by
extracting the `NAME` line, and a page without a usable `NAME` line has nothing
to extract. You have one such page in this lab.

`man -K` skips the index and greps the pages themselves. It is the one to reach
for when you remember a phrase and nothing else.

## Where pages come from

```
manpath          the directories man searches, in order
man -w NAME      the exact file it would open
```

Run `man -w ls` on this station and you will see something odd: the page is not
in `/usr/share/man` at all, it is under `/nix/store`. Several of the tools here
are installed by a different packaging system than the one lesson 01 and 02
covered, and they bring their own manual pages with them. `manpath` shows you
that as an ordered list, and order decides who wins.

Setting `MANPATH` in front of a command points `man` somewhere else for that
one command:

```
MANPATH=/labs/13-packages-docs-editors/03-man-pages/man man deck-cycle
```

That is how you read documentation that is not installed — someone's tarball,
a page you are writing, a lab.

## What has no man page

Shell builtins do not. `man cd` fails, because `cd` is not a program; it is
part of `bash`. The answer is `help cd`, and `type` will tell you which case
you are in. Many programs ship a `--help` that is shorter and more current than
their page. Neither is a substitute for the other: `--help` reminds you of a
flag you have used before, and the page explains one you have not.

## Reading a page

`man` displays through `less`, so everything you learned about `less` in
chapter 2 applies: `/word` to search, `n` for the next hit, `g` and `G` for the
ends, `q` to quit. Long pages are searched, not read. Nobody reads `man bash`.

## A note in the lab

`notes/page.txt` records something a station engineer noticed and did not
resolve: `deck-audit`'s manual page names a configuration file that the package
installing `deck-audit` does not ship. That is an ordinary kind of documentation
rot, and it may be nothing. Read it, and do not draw a conclusion from it yet.

## When you are done

You can find a page by description rather than name, read the right section
rather than the first one, point `man` at documentation that is not installed,
and say why a page can exist and still not be findable.
