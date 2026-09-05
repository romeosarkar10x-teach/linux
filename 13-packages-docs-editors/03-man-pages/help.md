# 13/03 — help

Questions, not answers.

## "`man X` gives me the wrong thing."

The wrong thing is section 1 and you wanted a file format. What number is that,
and where does the number go in the command? `man -f X` will show you every
section X lives in before you commit.

## "I do not know the name of the command I want."

Then do not search by name. There is a command that searches the one-line
descriptions instead, and `notes/man.txt` names it twice under two spellings.
Describe what the thing does, in the words a manual page author would use.

## "`man deck-cycle` says no manual entry, but the file is right there."

`man` searches a list of directories. Which list? What is the command that
prints it, and is your lab in it? Then: how do you tell one command to look
somewhere else without changing anything permanently?

## "apropos cannot find my page but man displays it fine."

Right — those two use different machinery. One reads the page. The other reads
something that has to be built first. Read `notes/mandb.txt`, build it, and see
whether the count it prints matches the pages you know are there.

## "I built the index and one page still is not found."

Compare the top of that page against the top of one that *was* found. The index
is built by extracting one specific thing from a page. Which thing is missing?
`lexgrog` will tell you outright.

## "My fixed copy still is not indexed."

Look at where you put it. `mandb` indexes a *manpath*, and a manpath has a
particular shape — the same shape you saw in `ls man/`.

## "`man -w ls` shows a path that is not in `manpath`."

Both are telling the truth. Try `ls -l` on the manpath entry that ought to have
matched, and see what it actually is.

## "`man nosuchpage | head` succeeded but the page does not exist."

You measured the exit status of the last command in a pipeline. Which command
was that? Chapter 8 gave you the array that has the other one.

## "`man cd` fails."

What kind of thing is `cd`? `type` will say. Then ask who would be responsible
for documenting it, and what command reads *that* documentation.

## Worth knowing

- `q` quits a page; `/word` searches; `n` repeats.
- `man -w` never displays anything, so it is safe to use in scripts and loops.
- Exit status 16 means "no such page".
