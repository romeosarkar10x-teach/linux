# 13/02 — help

Questions, not answers.

## "Someone handed me a `.deb`. How do I know what is in it?"

Two commands in `notes/dpkg.txt` read a `.deb` and install nothing. One shows
the files, one shows the metadata. Neither needs `sudo` — ask yourself why, and
you will remember which is which.

## "`dpkg -i` failed and I do not understand the error."

Read the middle of it, not the last line. It names a package and says something
about that package's state. Then ask: does this machine have anywhere to *get*
that package from, and does `dpkg` know about such places at all?

## "The package failed to install but the command works."

Good. That is the exercise. `dpkg -l` will show you a state that is not `ii`.
Look up the two letters in `notes/dpkg.txt`, then ask which of the two phases
in exercise 19's output completed and which did not.

## "`apt -f install` removed my package instead of fixing it."

It had two options. Ask what the other one would have required, and whether this
station has it. Then ask whether apt's job is to keep your package or to leave
the system consistent.

## "I installed the missing dependency and the package is still not `ii`."

Right. What state is it in now, and what does that state mean happened to it
earlier? A dependency being present does not undo a removal — you will have to
do something about the package itself.

## "`dpkg -S` cannot find a file I am looking at."

`dpkg -S` searches a list of files that packages installed. Where did *this*
file come from? If the answer is "a setup script" or "I made it", ask what that
implies about auditing a machine with `dpkg -S` alone.

## "`apt update` says `does not have a Release file`."

Compare the source line you are using now against the one you started with,
character by character. Then read `notes/repos.txt` on what the bracket was
doing. This is exercise 40 working as designed — do not forget exercise 42.

## "`dpkg -V` printed a line but succeeded."

Yes. Check `$?` and believe it. Then ask what your script would have to test
instead, and write that down; it is the useful half of the exercise.

## "`dpkg -V` with no arguments prints hundreds of `missing` lines."

Look at what is missing. Is it programs, or is it something a container image
would deliberately not ship? Then ask what that does to anyone's habit of
reading verification output.

## "How do I find out when a package was installed?"

There is a log. It is not in `/var/lib`. It has a timestamp on every line and it
rotates.

## Commands worth having open

- `dpkg -c`, `dpkg -I` — read a file
- `dpkg -l`, `dpkg -L`, `dpkg -S`, `dpkg -s` — read the machine
- `dpkg -V`, `dpkg --audit` — check the machine
- `apt-cache policy` — where things come from
