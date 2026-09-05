# 13/05 — help

Questions, not answers.

## "I am in vim and I cannot get out."

`Esc`, then `:q!`, then Enter. `Esc` works from any mode, including one you did
not know you were in. Learn that sequence before anything else in this lesson.

## "I typed and nothing appeared."

Which mode are you in? Vim starts in one where letters are commands. Which key
enters the other one, and which key comes back?

## "`:q` will not let me quit."

Read what it says. It is telling you something is unsaved and offering you the
override in the message itself.

## "My file has `:wq` in the middle of it now."

You were in insert mode. Undo is one key. Then ask what you would press to be
certain you are in normal mode before typing a colon.

## "Vim printed a wall of text about a swap file."

Read all of it — it names a file and lists numbered options. Two questions
answer it: is anyone else editing this file right now, and did an editor here
die recently? The safe options are the ones that change nothing.

## "How do I get to line 402 without scrolling?"

Two ways, both short. One starts with the number; one starts with a colon.
`notes/editors.txt` has one of them.

## "The two files look identical but one does not work."

Then the difference is not printable. There is a vim setting that draws tabs
and line ends, and a `cat` flag that does the same from outside. What would a
tab look like if you could see it? What about a carriage return?

## "`file` says the CSV is fine."

`file` guesses from content and reports what it recognises. Check the bytes
yourself and see whether you agree with it.

## "Which editor will `sudo -e` open?"

Two environment variables decide. Print both. If both are empty, the program
falls back to something of its own choosing — and its manual page says what.

## "Why not just `sudo vim`?"

Ask what is running as root in each case. Then ask what vim can do with `:!`,
and whose configuration file it reads on start-up.

## Escape hatches

- nano: `^X`, answer `N` to discard.
- vim: `Esc` `Esc` `:q!`
- Either: `cp` the file into `scratch/` first and edit that.
