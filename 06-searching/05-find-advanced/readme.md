# 06/05 — `find`: Size, Time, Permission, and Doing Something About It

> The lesson the chapter's incident is solved with. Half of it is predicates that ask about metadata
> instead of names; the other half is `-exec`, `-delete` and `-print0`, which is where `find` stops
> being a query and starts being a command that runs on files you have not looked at.

## Metadata is the point

Lesson 04 asked about names and types. Everything here asks the kernel about the inode: how big,
how recently changed, what mode, whose. `find` still never opens a file — it `stat`s it — which is
why these predicates are fast and why none of them can tell you anything about content.

## `-size`, and its rounding

`-size n` takes a **unit suffix**, and the default is the one nobody wants:

| suffix | unit | notes |
|---|---|---|
| `c` | bytes | the one you almost always mean |
| `k`, `M`, `G` | KiB, MiB, GiB | 1024-based |
| `b` | 512-byte blocks | **the default when you give no suffix** |

And it **rounds up**. `-size 1k` is not "is 1024 bytes"; it is "rounds up to 1 KiB", which is true of
everything from 1 byte to 1024. In this lab `-size 1k` matches five files, only one of which is
actually 1024 bytes long. `-size -1k` means "rounds up to less than 1", which is only an empty file.

If you mean bytes, say `c`. If you mean "bigger than", `+` and a unit: `-size +32k`.

## Time

Three times per inode, from Chapter 3: **mtime** (contents changed), **atime** (read), **ctime**
(inode changed — mode, owner, link count, or contents). `find` has a predicate for each: `-mtime`,
`-atime`, `-ctime` in days, and `-mmin`, `-amin`, `-cmin` in minutes.

The arithmetic is the part that trips everyone. `-mtime n` means the age, **truncated to whole
days**, equals exactly *n*. So `-mtime 0` is "less than 24 hours old", `-mtime 1` is "between 24 and
48 hours", and `-mtime -7` is "newer than seven days". A file 25 hours old is not `-mtime 0`; it is
`-mtime 1`, and a rotation script written with `-mtime 7` instead of `-mtime +7` deletes a single
day's worth of files and nothing else.

`-daystart` measures from midnight rather than from now, which is what you want when the schedule is
"since the start of today" rather than "in the last 24 hours".

`-newer FILE` compares against another file's mtime — no arithmetic, no units, and it is **strict**:
newer than, not newer-or-equal. `-newermt 'DATE'` compares against a date string, which is the
predicate that answers "what changed between these two times":

```
find deck -newermt '2187-06-09 04:30' ! -newermt '2187-06-09 04:35'
```

Read that carefully. The left half is `> 04:30`. The right half negated is `<= 04:35`. The window is
half-open at one end and closed at the other, so a file stamped exactly `04:35` is **inside** it.
When a window returns one more file than you expected, that boundary is the first thing to check.

## `-perm`, in three flavours

- `-perm 644` — the mode is **exactly** 0644. Rare; usually not what you want.
- `-perm -644` — **all** of these bits are set, others may be too. "At least this permissive."
- `-perm /022` — **any** of these bits is set. This is the one for "who can write that shouldn't":
  `-perm /022` finds group- or world-writable files in one predicate.

Symbolic forms work too: `-perm -u=w`, `-perm /o=w`. The leading `-` and `/` are the whole of the
grammar and they are easy to mix up; when a `-perm` result surprises you, say the flavour out loud.

## Ownership, and what it can tell you here

`-user NAME`, `-group NAME`, `-uid`, `-gid`, and `-nouser`/`-nogroup` for entries whose owner no
longer exists in the passwd file. In *this* lab every entry is `cadet:crew`, because the harness
normalises ownership after every seed — so `! -user cadet` returns nothing, and the exercise is to
notice that a predicate which cannot discriminate is not evidence of anything.

## `-exec`, in two forms

```
find … -exec cmd {} \;      # one process per file
find … -exec cmd {} +       # as few processes as possible, many files each
```

`{}` is replaced by the path; `\;` and `+` terminate the command and must be protected from the
shell. The difference is not only speed. `+` batches, so the command sees several filenames at once —
which is why `-exec grep pattern {} +` prints filename prefixes and `-exec grep pattern {} \;` does
not, exactly as in lesson 02. It also means `+` cannot be used when the command must run once per
file, and that `{}` may only appear at the end of the command with `+`.

`-exec` is a **test**, not just an action: it is true when the command exits 0, so
`find . -type f -exec grep -q adjusted {} \; -print` prints the files that contain the word. That
composability is why `-exec` and not a pipe.

`-ok` is `-exec` with a per-file confirmation prompt, which answers "no" when there is no terminal.

## `-delete`, and the argument order that will hurt you

`-delete` removes what it matches, implies `-depth` (you cannot unlink a directory you are still
descending into), and refuses non-empty directories. It is also an **action**, and it is evaluated
in the order you wrote it:

```
find scratch/w -delete -name '*.log'
```

deletes **everything under `scratch/w` and `scratch/w` itself**, because `-delete` runs first and is
true, and `-name` is only consulted afterwards on files that no longer exist. There is no warning.
Write the filters first, run the command with `-print`, read the list, and only then swap in
`-delete`.

## Filenames are not lines

`find … | xargs` is broken for any name containing a space, a quote or a newline — `xargs` splits on
whitespace and treats quotes as special. This lab has all three:

```
find awkward -type f | xargs -n1 echo
xargs: unmatched single quote; by default quotes are special to xargs unless you use the -0 option
```

The fix is a NUL-separated stream, which cannot occur inside a filename: `find … -print0 | xargs -0
…`. `-exec … +` does the same job without a pipe at all and is usually the better answer.

`-printf` gives you the fields directly — `%p` path, `%f` base name, `%s` bytes, `%TY-%Tm-%Td` and
`%T@` for time — and is the right tool when you want to sort by something `find` knows.

## The shape of the lab

`sizes/` has nine files at the rounding boundaries. `spool/` has six run logs whose mtimes are
**relative to now** so `-mtime`/`-mmin` behave normally. `deck/` has nine files with **fixed 2187
stamps**, including a five-minute window with exactly one file in it. `perms/` covers the three
`-perm` flavours. `awkward/` has a space, a quote, a newline and a leading dash in filenames.
`notes/` has two files worth reading first. `scratch/` is where you are allowed to delete things.

## Rules of engagement

`-delete` only inside `scratch/`. Every destructive command gets run with `-print` first. `kestrel
reset 06/05` puts the lab back, and you will need it.

## What "solved" looks like

You can convert "over 32 kilobytes" and "older than a week" into predicates without looking them up,
say what `-size 1k` really matches, build a time window and know which end is open, name the three
`-perm` flavours, explain why `-exec grep {} +` prints filenames when `\;` does not, and demonstrate
the `-delete`-first disaster in a directory where it does not matter.

## Before you move on

One lesson left before the incident, and it is short: the tools that answer "where is that file"
without walking anything.
