# 13/04 — help

Questions, not answers.

## "The list says `plocate` but that command does not exist."

A package's name and the command it gives you are not required to match. What
commands does that package install? Lesson 02 had a flag for listing a
package's files.

## "`apt` says `htop` is not installed but `htop` runs."

Both are true. Run `man -w htop` and `command -v htop` and look at where those
paths go. Then ask: is apt the only thing on this machine that can install
software?

## "How do I find a tool when I do not know its name?"

Same shape as lesson 03's problem: search descriptions, not names. `apt search`
takes words.

## "Should I extract this tarball?"

Not yet. There is a `tar` flag that lists an archive without extracting it. Look
at how many top-level entries come out. What would happen to your current
directory if there were forty?

## "Where do I put a program I installed by hand?"

`notes/tools.txt` names four directories and says who owns each. The question to
ask about a candidate is: will the package manager ever write here? You want the
answer to be no.

## "I copied it but the command is not found."

`echo "$PATH" | tr ':' '\n'`. Is the directory you copied into on that list? If
not, you have two choices — move the file, or change the list — and one of them
is much easier to explain to the next person.

## "`man` finds my page but `whatis` does not."

You solved this in lesson 03. The only new thing is who owns the directory this
time, which changes one word of the command.

## "`dpkg -S` cannot find the thing I just installed."

Correct. Ask which of the three routes you took, and what `notes/tools.txt` says
that route does not give you. This is the point of the exercise, not a mistake.

## "How do I uninstall the tarball?"

What is the command that lists what a package installed? Now ask whether
anything on this station will answer that question for files you copied
yourself. Then go and read the README again.

## Worth having open

- `command -v` and `type -a` — what runs
- `apt search` / `apt show` — before installing
- `tar -tzf` — before extracting
- `dpkg -S` — who owns a file, when anyone does
