# 10/04 — rwx and octal

> "I can see the file. I can list the directory. I cannot open the file." — cass, 06:40

Ten characters at the front of an `ls -l` line, and almost everything about access on a Unix machine
is in them. This lesson is entirely about **reading** them. Changing them is lesson 05, and doing it
before you can read them accurately is how people end up at 777.

The first character is the type: `-` for an ordinary file, `d` for a directory, `l` for a symlink.
The other nine are three triads — owner, group, other — and the rule that governs them is the one
students get wrong for years: **the kernel applies exactly one triad, the first that matches.** Are
you the owner? Then the owner triad decides, and the group and other triads are never consulted. Not
the owner but in the file's group? Group triad, done. Otherwise, other. There is no union, no
accumulation, and no fallback. An owner with `---` on a file with `rwxrwxrwx` behind it can do
nothing to it, and that is not a bug.

Then octal, which is only arithmetic: `r` is 4, `w` is 2, `x` is 1, add them up per triad. `644` is
`rw-r--r--`. `750` is `rwxr-x---`. You will be reading these aloud for the rest of your career, and
`stat -c '%a %A %n'` prints both forms side by side until you no longer need it to.

The half of this lesson that actually costs people time is what those same three letters mean on a
**directory**, where they mean something else entirely. `r` is permission to list the names. `x` is
permission to *traverse* — to use the directory in a path at all, and reach something inside it whose
name you already have. They are independent, and the two lopsided combinations are the interesting
ones. `r--` lets you run `ls` and see names, and `ls -l` returns a row of question marks, because
finding out anything *about* a file requires reaching it. `--x` is the reverse: you cannot list
anything, but `cat dir/rota.txt` works perfectly if you know it is called `rota.txt`. The lab's
`maze/` has one directory of each kind and cass's page is an accurate bug report about the first of
them.

And a path is checked one component at a time. `/a/b/c/file` needs `x` on `/`, on `/a`, on `/a/b` and
on `/a/b/c` before the file's own mode is even looked at. One missing `x` anywhere along the way
stops you, no matter how permissive the file is. That is why a file that is `rw-rw-rw-` can still be
unreadable, and why "check the file's permissions" is only ever half the advice.

## What you will be able to do

- [ ] Read all ten characters of an `ls -l` mode and name what each one governs
- [ ] State the first-match-wins rule and predict a case where the owner has less access than a stranger
- [ ] Convert between symbolic and octal in both directions without looking it up
- [ ] Explain what `r`, `w` and `x` mean on a directory, in the directory's own terms
- [ ] Predict the outcome of `ls`, `ls -l` and `cat` for an `r--` and a `--x` directory, and say why
- [ ] Explain why `ls -l` shows question marks, in terms of what `ls` had to do to fill the columns
- [ ] Trace a path component by component and find which one denied you
- [ ] Use `stat -c` to get the mode in the form the question needs
- [ ] Read a listing you cannot run commands against and answer access questions from it alone

## Files

```
maze/open/         755 — the normal case
maze/listed/       744 — names, and nothing else
maze/reachable/    711 — reach what you can name, discover nothing
maze/shut/         700 — no
maze/HOW           what to do with the above
audit/listing.txt  a listing off the archive host, to decode by eye
audit/questions.txt  six questions about it, no commands allowed
notes/modes.txt    triads, octal, and the directory bits
notes/page.txt     cass, 06:40
scratch/           yours
```

Everything under `maze/` is owned by root, so you are in the `other` triad for all of it. That is
deliberate: it makes the three cases separate cleanly instead of being masked by group membership.
Nothing in this lesson needs `sudo`, and nothing in it changes a mode — if you find yourself reaching
for `chmod`, you are in the next lesson.
