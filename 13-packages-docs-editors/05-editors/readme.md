# 13/05 — Editing a file where it lives

Everything you have changed so far, you changed with a command: `sed`, a
redirect, `printf` into a new file. That is the right instinct and it stays the
right instinct for anything you will do more than once.

But sometimes the change is a judgement call on one line of one file on one
machine, and the fastest correct thing is to open it and fix it. For that you
need an editor, and you need to be able to leave one.

## nano

`nano FILE`. The two lines at the bottom are the entire interface. `^` means
Ctrl.

```
^O  write out (save)      ^W  search
^X  exit                  ^\  search and replace
^K  cut line              ^G  help
^U  paste                 ^C  where am I
```

There is nothing else to learn. If you only ever learn one editor, this is a
defensible choice — it is on nearly every system and it tells you what its keys
do while you use it.

## vim

`vim FILE`. Vim starts in **normal mode**, where the letter keys are commands,
not text. `i` enters insert mode; `Esc` leaves it. Almost every bad experience
with vim is being in a mode you did not think you were in, and the fix is always
the same: press `Esc`.

```
:w   write        :q   quit       :wq  both      :q!  quit, discard changes
i    insert       Esc  normal     u    undo      Ctrl-r  redo

0 ^ $        line start / first non-blank / line end
gg G         top / bottom          NNgg   go to line NN
w b          word forward / back   dd     delete line
/word n N    search, next, prev    x      delete character
:%s/a/b/g    replace everywhere
:set number  :set list  :set paste
```

Learn vim because it is on machines where nano is not: rescue images, minimal
containers, someone else's server at three in the morning. You do not need to
be fast in it. You need to be able to open a file, change one line, save, and
leave — and to get out cleanly when you have made a mess (`Esc`, `:q!`).

`vimtutor` is installed on this station and takes half an hour. It is the best
half hour you will spend on this chapter.

## Which editor other programs use

Some programs open an editor for you. They decide which one from the
environment:

```
$VISUAL     preferred, for full-screen editors
$EDITOR     the fallback
```

Neither is set on this station, which means every program that opens an editor
here is falling back to whatever it was compiled to prefer — and different
programs prefer different things. Set them in `~/.bashrc` (chapter 10) and the
question stops arising.

## Editing a root-owned file

```
sudo -e /etc/something.conf      # same as: sudoedit /etc/something.conf
```

`sudo -e` copies the file somewhere you can write, runs **your** editor as
**you**, and copies the result back with the original owner and mode. Compare
with `sudo vim /etc/something.conf`, which runs an entire editor as root — your
configuration, your plugins, and vim's ability to run shell commands, all with
full privileges. Prefer `sudo -e`. It is the same amount of typing.

## What an editor shows you that `cat` does not

Whitespace and line endings are invisible in normal output and are a common
cause of "this file looks identical but does not work". `:set list` in vim
shows tabs as `^I` and line ends as `$`; `cat -A` does the same from outside.
This lab has one file with mixed tabs and spaces and one with Windows line
endings, and neither looks wrong until you make it look wrong.

## A note in the lab

`notes/page.txt` records an alarm threshold that is inverted — `fail` below
`warn` on one deck — and says plainly that nobody can tell whether it was a
typo or a deliberate change, because the file records what changed and never
why. Read it. It is a note about configuration hygiene, and it is also the
reason this chapter's incident is going to be harder than it looks.

## When you are done

You can edit a file in nano and in vim, leave both without damage, reach line
400 of a 600-line file without scrolling, see whitespace and line endings, and
edit a root-owned file without running an editor as root.
