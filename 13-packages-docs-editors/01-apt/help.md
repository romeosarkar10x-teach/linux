# 13/01 — help

Questions, not answers.

## "apt says it cannot find the package, and I can see the file right there."

You are looking at the disk. `apt` is looking at its catalogue. Those are two
different things, and the command that copies information from the first to the
second is in `notes/apt.txt`.

Ask: has anything told `apt` that this repository exists? Where would that have
been written, and is the file you edited the file `apt` reads?

## "I copied station.list and apt still does not see it."

Two questions. Where did you copy it *to* — the exact directory? And what did
you run afterwards?

## "It says `Method gave a blank filename`."

Is that an error or a note? Check the exit status. Check whether the `Get:` line
for your repository appeared anyway.

## "I get `are you root?`"

Right — but read your whole error, not the last line. When a command fails for
two reasons, the first message you see may not be the interesting one. Run it
again with `sudo` and see whether the real complaint was something else.

## "I asked for one package and it installed two."

Read `apt show` on the one you asked for, and look for the field that lists what
it needs. Then ask yourself what you would want a package manager to do about
that field.

## "`apt remove` wants to remove things I did not name."

Do not answer `y` yet. Read the list. Then ask: which of these needs the thing
you are removing? The answer is in the same field as above, read backwards.

## "I removed it but `dpkg -l` still shows it."

Look at the first two characters of that line and compare them against a package
you have not touched. Then look at `/etc` for a file the package installed.
There is a second command in `notes/apt.txt` that finishes the job — the
difference between the two is the whole point of exercises 31–34.

## "`purge` deleted my edit."

Yes. Ask what dpkg would have to know in order not to. Then ask what you should
have done before running it, in one word.

## "Which do I use in a script?"

Run `apt list --installed | head -2` and read the first line it prints. It
answers this for you, in its own words.

## "The exercise wants a version table and I get four lines of numbers."

`apt-cache policy` prints, for each version, the sources that offer it and a
number. The number is not a version. Find what it is called in
`apt_preferences(5)` — you have `man` and lesson 03 is about using it.

## Commands worth having open

- `apt show`, `apt-cache policy`, `apt list -a`
- `dpkg -l`, `dpkg-query -W -f=...`
- `apt-mark showmanual`
- `--dry-run` before anything that changes the system
