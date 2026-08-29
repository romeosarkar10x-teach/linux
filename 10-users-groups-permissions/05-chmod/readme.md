# 10/05 — chmod

> "Smallest change that works. Not 777, and not a `-R` that lands on every file in the tree." — rhea

Lesson 04 was reading. This one is writing, and it comes with a standing question you should ask
before every `chmod` you ever type: *what is the smallest change that makes this work?* Almost every
bad mode on every machine you will ever inherit was somebody making the problem go away rather than
solving it, and `777` is what that looks like.

There are two syntaxes. Numeric — `chmod 644 file` — sets all nine bits at once from the arithmetic
you learned last lesson. It is absolute, which means every bit you were not thinking about is being
set to zero. Symbolic — `chmod u+x`, `chmod go-w`, `chmod a=r` — names *who*, an *operator* and
*what*, and changes only what it names. `+` and `-` are relative; `=` is absolute for the triads it
mentions and leaves the rest alone. Neither is better. Numeric is right when you know exactly what the
file should be; symbolic is right when you want to change one thing and are not prepared to assert the
other eight.

Recursion is where the damage happens. `chmod -R a+rx tree` sounds like "make the tree usable" and
means "make every CSV in it executable", which is wrong, is invisible in `ls`, and will be copied
along by whoever tars it next. `X` — the capital one — is the fix: execute for directories, and for
files that *already* have an execute bit somewhere. `chmod -R a+rX` does what people mean when they
type `-R a+rx`. Learn it now and never type the lower-case one recursively again.

The other half of this lesson is a fact that upsets everybody, and which lesson 04 walked you up to:
**deleting a file is a write to the directory, not to the file.** A directory is a list of names, and
creating, removing and renaming all edit that list. So you can delete a file you cannot read — `rm`
will *ask* you first when it is talking to a terminal, and that is `rm` being polite, not the kernel
refusing — and you cannot delete your own file if you cannot write the directory it sits in. To
protect a file from deletion, look at the mode of its directory. Nothing you do to the file itself
will help.

Two smaller rules that will save you an afternoon each. `chmod` requires that you **own** the file, or
are root — read and write on the file are irrelevant, and you cannot chmod your way into somebody
else's file. And `chmod` **follows symlinks**: `chmod 777 link` changes the target. A symlink's own
mode is always `lrwxrwxrwx` and nothing ever consults it.

## What you will be able to do

- [ ] Change a mode numerically and symbolically, and say when each is the right choice
- [ ] Predict the result of a symbolic clause before running it, including `=` and comma-separated clauses
- [ ] Explain what a numeric `chmod` does to the bits you did not mention
- [ ] Use `chmod -R` with `X` and say precisely what `X` does that `x` does not
- [ ] Copy a mode with `--reference` and say when that is better than typing three digits
- [ ] Explain why deleting a file is governed by the directory's mode
- [ ] Delete a file you cannot write, and fail to delete a file you can
- [ ] Say what `chmod` needs from you, and why it is not one of the nine bits
- [ ] Predict what `chmod` on a symlink does
- [ ] Repair four wrong modes with the smallest change each one needs, and justify each

## Files

```
repair/collect.sh       a script nobody can run
repair/id_station       a private key everybody can read
repair/handover/        a shared directory nobody can write
repair/exporter.conf    a config that was "fixed" with 777
repair/NOTES            what each of the four is for
drop/theirs.txt         444, not yours, in a directory that is
drop/yours.txt          yours
tree/                   every mode 600, including the directories
notes/chmod.txt         both syntaxes, and X
notes/deletion.txt      why rm is a directory operation
notes/page.txt          rhea, 07:05
scratch/                yours
```

Nothing in this lesson needs `sudo`, and nothing needs you to change a mode outside this lab. If you
find yourself typing `chmod` on a path that does not start with the lab directory, stop.
