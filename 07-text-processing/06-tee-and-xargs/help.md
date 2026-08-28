# 07/06 — Tutor guide: `tee` and `xargs`

Small lesson, two commands, one real idea in each:

- `tee`: you do not have to choose between seeing output and keeping it.
- `xargs`: some commands take arguments, not streams — and turning a stream into arguments is where
  filenames get you hurt.

The whitespace half is the part that matters. A student can leave here fuzzy on `-n2` and be fine.
A student who leaves writing `ls | xargs rm` will eventually delete something.

## Where students stall, and what to ask

**Exercise 3.** Some will say `tee` is just a nicer temporary file. Ask what happens if the log is
still being written while they run the pipeline twice. Two different answers, no error.

**Exercise 10** (`cat f | tee f`). Do not let them run it, and do not let them off with "it is
dangerous". Ask: *which process truncates the file, and when relative to `cat` opening it?* The answer
— the shell, before either command starts — is the whole explanation. Then tell them it survived
intact when this lesson was written, and ask why that is worse than losing it.

**Exercise 21** (`xargs` on empty input). They will assume nothing runs. Let it print `hello`. Then
ask what `find … | xargs tar -cf backup.tar` would do on a day when `find` matched nothing.

**Exercise 25** (SIGPIPE). Students think they broke something. Ask which command exited first, and
what happens to a writer when the reader closes the pipe. Then ask whether they should redirect
stderr to hide it. The answer is: only once you know why it is there.

**Exercises 31–35** (awkward names). Do the whole run in order and do not skip 33. The count that
disagrees with reality — five lines, four files — is the one people remember. If they suggest fixing
it with quoting or a smarter separator, ask them to name a character that cannot appear in a filename.
Let them work down to NUL themselves.

**Exercise 37** (`--`). They will expect `--` to fix it and it does not, because `echo` is not a
command that implements the convention. Do not present this as a trick: ask who parses `--`, `xargs`
or the command. This is the difference between a shell convention and a guarantee.

**Exercise 38.** No running. Ask them to say out loud what `rm -rf a b c` does when `-rf` arrived as
data. If they are unmoved, ask what the file `data/awkward/-n` is called and how it got there.

**Exercise 44** (`sh -c` with `{}`). If they do not see the injection, give them the account name
`; rm -rf ~` and ask them to write out the command `xargs` would build. Then show the `_ {}`
positional form and ask what changed.

**Exercise 45.** Both work. Push for the comparison, not the answer: how many passes over the log, how
many processes, and what each does with an account name containing a space.

**Exercise 53.** Students say the report is fine. Ask them to imagine reading it in three months with
no memory of running it. The missing date range is the point, and it sets up lesson 08.

## Questions that work when they are stuck

- "Does that command read standard input? How would you check?"
- "What did `xargs` actually run? Add `-t`."
- "What is in that stream — filenames, or words?"
- "Who truncates the file, and when?"
- "How many processes did that start?"

## Do not

- Do not teach `xargs -P` (parallelism). Out of scope, and it makes output interleave in ways that
  hide bugs.
- Do not let a student leave with `ls | xargs` in their fingers. Make them type
  `find … -print0 | xargs -0` at least three times.
- Do not explain SIGPIPE before exercise 25 produces it.
- Do not defend the one-liner in exercise 55. Agree it works and ask who maintains it.
