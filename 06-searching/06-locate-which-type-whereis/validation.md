# 06/06 — Validation

For the validator agent. Judge understanding, not recall. Never hand over an answer; ask the next
question instead.

## What this lesson is for

One idea: **a name does not identify a thing until you say who is resolving it.** `locate` resolves
against a stale database, `which` against `PATH` in a child process, `type` against the shell's own
five-layer order, `whereis` against a compiled-in idea of where Unix keeps things. All four can be
confidently wrong, in four different ways, and the student should be able to say which way.

## Must be able to do

- Explain why `locate` is fast, and name both failure directions: indexed-but-deleted (false
  positive) and exists-but-not-indexed (false negative).
- State that `locate` matches a substring of the **whole path**, and that `-b` changes that.
- Choose `find` over `locate` when the answer must be true *now*, and say so unprompted.
- Recite the five things a name can be — alias, keyword, function, builtin, file — and that they
  resolve in that order.
- Explain *why* `which` cannot see four of the five, in terms of processes and memory, not in terms
  of "it is old".
- Use `command -v` in a script and `type -a` at a prompt, and justify each choice.
- Recognise exit status 126 and say what it means.
- Debug "it is still running the old one" with `type -a`, `hash -r`, and `echo $PATH` in that shell.

## Should be able to do

- Read `locate -r` as BRE and adapt a lesson-03 ERE accordingly.
- Use `-e` and describe what it costs.
- Explain `whereis`'s rc 0 on failure and refuse to use it programmatically.
- Bypass an alias (`\name`), a function (`command name`), and a `PATH` shadow (absolute path) and
  keep the three straight.

## Nice to have

- The hash-table nuance: assigning `PATH` flushes it, so the stale-cache bug needs a new file in an
  already-earlier directory.
- `enable -n` as proof that resolution order is configuration, not architecture.
- Reading `/etc/updatedb.conf` where it exists, and noticing on this station that it does not.

## Common wrong answers, and the question to ask back

**"`locate` is a faster `find`."**
→ "Faster at what? Ask it about a file you created ten seconds ago."

**"`locate` did not find it, so it is not there."**
→ "What is the last thing `locate` knows about? What time was that?"

**"`which` told me, so that is what runs."**
→ "`which` is a program in its own process. Where does an alias live? Could that process see it?"

**"`command foo` runs the real `foo`."**
→ "Real in what sense? Try it against `scratch/ls` in exercise 53 and tell me what printed."

**"Builtins always win."**
→ "Run `enable -n echo` and then `echo hello`. Still always?"

**"`command -v foo` succeeded, so I can run `foo`."**
→ "Try `panel-check`. What was the exit status, and what does 126 mean?"

**"The newest version on `PATH` wins."**
→ "`stat` both `strain-report` files, then run it. Which won? What does `PATH` actually encode?"

**"I prepended the directory but it still ran the old one, so it must be the hash table."**
→ Good instinct, wrong here. "What does bash do to the hash table when you assign to `PATH`?
   Construct the case that really is a stale cache."

## Sign-off scenario

Read it out; do not let them run anything first.

> A deploy went out an hour ago. Someone says: "the new `deck-scan` is definitely installed — I ran
> `which deck-scan` and it points at the new path — but running it still prints the old version
> string. Also `locate deck-scan` shows a copy in a directory nobody has used for a year, so I think
> the deploy went to the wrong place."

A passing answer separates the three claims and does not accept the framing:

1. `which` pointing at the new path proves nothing about what runs — `type -a deck-scan` first,
   because a function or alias would beat any file, and `type` will also say `is hashed (…)` if the
   shell is holding an old path. `hash -r` and retry.
2. The old version string could equally mean the deploy overwrote the *wrong file*, or that the file
   they are running is not the file `which` found. Compare `type -P deck-scan` against the deploy's
   own record of where it wrote.
3. The `locate` hit is **not evidence of a wrong deploy**. It is an index entry, possibly from before
   the deploy, possibly for a file that no longer exists. `locate -e`, or just `ls -l` the path.

Full marks add: check `echo "$PATH"` in the shell that shows the problem rather than their own, and
notice that the whole report is three tools each answering a question nobody asked.

## Red flags

- Reaching for `locate` during an incident about something that happened last night.
- Using `whereis` in a conditional.
- Saying `which` is "deprecated" without being able to say what it structurally cannot do.
- Treating a `command -v` success as an executability check.
- Accepting the sign-off scenario's conclusion instead of its evidence.
