# 11/01 — Validation

For the validator agent. Rubric only; there is no script and there will not be one.

## Pass requires all of

1. **The rule, stated.** A child receives a *copy* of the *exported* variables, taken when it
   *starts*. All three words matter and a student missing "copy" will get exercise 29 wrong later.
2. **Exercise 23 explained** — the same characters, one line versus two, and why the two-line form
   leaves the variable unexported. A student who cannot explain this has not understood the prefix.
3. **`set` versus `env` as a question about which process.** Not "one is longer".
4. **`printenv`'s exit status** offered as the way to test for a variable, with the reason `echo`
   cannot do it (unset and empty print the same thing).
5. **Unset versus empty**, with `${x-d}` and `${x:-d}` used correctly in both directions.
6. **`source` versus `./`** — one process versus two — and the subshell result in exercise 31.
   Getting 29 and 30 right while failing 31 is a partial pass on this item only if they can say what
   `( )` does when asked.
7. **Exercise 62** names a class of thing, names no person, and does not propose a fix rhea did not
   ask for.
8. **Exercise 59's timestamp** is present: `2186-07-19 04:31:00`. Its absence means they took rhea's
   word for it.

## Lab-state checks

Nothing in this lesson writes to the lab, so the tree should be untouched:

```
cd /labs/11-environment-and-config/01-env-vars
find . -newermt '2187-06-18 09:00:01' -not -path './scratch/*'   # should list nothing
stat -c '%y' bin/deck-report                                 # 2186-07-19 04:31:00
```

Files in `scratch/` are fine and expected. A modified `bin/deck-report` is not: the student was asked
to read it, not to fix it, and a student who "fixed" the `:?` line into a default has removed the one
safety feature the lesson is about. Ask them what exercise 47 was for.

## Red flags

- Claiming a child *can* set a variable in the parent, or that some flag makes it possible. It
  cannot, and a student holding this belief will write a broken script in chapter 12.
- Using double quotes in exercise 1, getting `[05]`, and reporting that unexported variables are
  inherited. Check specifically for this; the answer looks confident and is exactly backwards.
- Saying `export -n` and `unset` are the same. Ask for the command that distinguishes them.
- Explaining `env -i env`'s empty output as "env is broken" or "the environment was already empty".
  The right answer names the missing shell.
- Naming a person, an account, or a deliberate act in exercise 62. There is no evidence in the lab
  for any of them and rhea asked for the opposite.
- Proposing to fix the nightly job. It is not in this lab. A student who has "fixed" something has
  fixed a thing they cannot see.
- Recording exercise 40 as a success because rc was 0.

## Good signs

- Predicts exercise 23's failure before running it, having got exercise 1 right.
- Notices unprompted that `COURSE` and `LABS` are in `env` but were not in the image's list, and asks
  where they came from — that is lesson 03 arriving on its own.
- Reaches exercise 61 with "reproduce the job's environment" rather than "read the script again".
- Notices that exercises 21 and 54 give the identical message and says why that is correct behaviour
  rather than a shortcoming.
- Asks what happens to a program that is already running when you `unset` a variable it was given.

## Questions to ask if the written answers are thin

- "Set a variable so that exactly one command sees it and nothing else does."
- "`echo $X` printed an empty line. Give me two different states that produces, and the command that
  tells them apart."
- "Your `PATH` starts with `/opt/kestrel/bin`. `env -i bash -c 'echo $PATH'` does not. Why?"
- "How many processes run when I type `source ./bin/set-station`?"
