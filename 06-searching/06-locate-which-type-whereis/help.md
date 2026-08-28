# 06/06 — Help

Stuck, not beaten. Read only the heading you need.

**`locate: command not found`**
Your container predates this lesson. `kestrel stop && kestrel start` to pick up the current image.

**`locate` returns nothing / returns nonsense**
That is the lesson, not a fault. The index was built when this image was built, before `/labs`
existed. Exercises 1–8 are supposed to be done in that broken state. Do not run `updatedb` early.

**`updatedb: /var/cache/: Permission denied`**
Expected — exercise 8 asks you to quote it. Building the index needs to read directories you cannot.
`sudo updatedb` when you reach exercise 9.

**`locate` finds nothing for a pattern with a `*` in it**
`locate` matches a plain substring of the whole path. `strain*.log` matches nothing because no path
contains those characters literally. `-b` restricts to the basename, `-r` takes a regex.

**The regex in `-r` is not matching**
It is BRE, like `grep` with no flags (lesson 03). `|` is a literal; you want `\|`. `+` and `?` are
literals too.

**`which` and `type` disagree and you cannot tell which to believe**
Always `type`. `which` is a separate program and cannot see aliases, functions, builtins or keywords,
because those exist only inside your shell's memory. Ask "would this survive being handed to a child
process?" — if not, `which` cannot know about it.

**`PATH` change had no effect**
Two candidates. You set it in a subshell or with a one-command prefix (`PATH=… cmd`), which does not
persist. Or you edited it in a way bash never saw — check with `echo "$PATH" | tr ':' '\n'` in the
shell you are actually typing in.

**A command still runs the old copy**
`type NAME`. If it says `is hashed (…)`, that is bash's cache; `hash -r` clears it. Note that
*assigning* to `PATH` clears the cache by itself, so this only bites when the file moved or a new
file appeared in a directory already earlier on `PATH`.

**`Permission denied` when running something `type` just found**
Exit status 126: the shell resolved the name to a file and the kernel refused to execute it. `ls -l`
it and look for the execute bit. `type` answers "what does this name resolve to", not "can I run it".

**You lost your `PATH` and now nothing works**
`exec bash -l` gives you a clean login shell. If even that fails, `/usr/bin/env bash -l`, using the
absolute path deliberately.

**An alias or function is in the way and you want it gone**
`unalias NAME`, `unset -f NAME`. To bypass for one command: `\NAME` skips the alias only,
`command NAME` skips alias and function, an absolute path skips everything.

**Exercise 53 is impossible**
It is not, but three of the four things you will try do not work. `command`, `\`, and `type -P` all
bypass *shell* lookup, not `PATH` order. You need something that does not consult your `PATH` at all.

**`whereis` says nothing and exits 0**
That is its behaviour on failure and it is exercise 50's whole point. Never test `whereis` in an
`if`; use `command -v`.

**How much of this do I need to remember?**
`type -a` interactively, `command -v` in scripts. Everything else you can look up. The idea you must
keep is that a name resolves through five layers and only the shell can see all five.
