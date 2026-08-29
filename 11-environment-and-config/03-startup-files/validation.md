# 11/03 — Validation

For the AI validator. No auto-grader. Judge by conversation and by inspecting the lab.

## Pass requires all of

1. **Two questions.** States that login and interactive are independent properties and that the
   combination decides what runs. Can say which flag controls which.

2. **The table.** Reproduces the four rows of solution 15 without help, including that a
   non-interactive non-login shell reads nothing.

3. **Login does not read `.bashrc`.** Says it plainly, and can explain why login shells on this
   station nevertheless have the aliases — a line in `~/.profile` that somebody wrote. Identifies it
   as a decision, not machinery.

4. **First match wins.** Has demonstrated by deletion (exercises 17–19) that only one of the three
   login files is read, and knows that having none of them is not an error. Connects the rule to
   `PATH` in lesson 02.

5. **The silent loss.** Explains what creating a one-line `~/.bash_profile` does to an existing
   `~/.profile`, and — this is the part that separates a pass — why nothing anywhere reports it.

6. **Alias versus function.** Has measured that `alias` lists `decks` while `type decks` says not
   found in the same non-interactive shell, names `expand_aliases` as the cause, and draws the
   practical rule: scripts get functions, not aliases.

7. **The complaint, mechanised.** Reproduces the `split/` behaviour and explains "works in some
   terminals, not others" as login versus non-login, with no file being broken. Gives a concrete
   configuration for the cass/rhea page in lesson 02.

8. **rhea's page.** Answers with a *difference*, not a fix: something about how the terminal started,
   plus a way to tell which kind of shell they are in. `shopt login_shell` is the strong answer;
   `$0` beginning with a dash is acceptable only if they also note that it depends on how the shell
   was launched.

9. **Breaking and recovering.** Has run the `exit 1` startup file, seen the login fail with rc 1, and
   recovered with `bash --noprofile -l` rather than by deleting anything. Can say why the quiet
   failure (exercise 46) is the more dangerous one.

10. **`BASH_ENV` and reload.** Knows `BASH_ENV` is the one exception to "scripts read nothing" and
    that it does not apply to interactive shells. States that `source` adds and never removes, and
    gives one thing it cannot undo.

## Lab state

```
find . -newermt '2187-06-22 09:00:01' -not -path './scratch/*'
```

Should list nothing.

```
stat -c '%y' homes/station/.bashrc   # 2186-08-14 16:02:00
ls -a homes/full                     # five dotfiles, all present
ls -a homes/split                    # .bash_profile, .profile, .bashrc
```

If `homes/full` is missing `.bash_profile`, they did exercises 17–19 in place instead of on a copy —
exercise 16 told them not to. Reset, and ask what the copy was protecting.

Also check the student's own dotfiles:

```
stat -c '%y' ~/.bashrc ~/.profile
```

Neither should be modified during this lesson. Editing them is not a failure of understanding, but it
is a failure of the habit the lesson is teaching, and it should be raised.

## Red flags

- "`.bashrc` runs for every shell." The single most important misconception in the chapter; a pass is
  not possible with it intact.
- Claims `~/.bash_profile` and `~/.profile` are both read, or "merged".
- Says `alias` or `type` is buggy in exercise 30 rather than that they answer different questions.
- Proposes fixing rhea's terminal, or asks what she changed after she has said she changed nothing —
  she is right, and it is checkable (exercise 29).
- Recovered from exercise 44 by deleting the home directory or by `rm .profile`.
- Believes `source ~/.bashrc` is equivalent to a fresh login.
- Answers exercises 9–14 without having run them. The predicted answers and the measured ones differ
  for at least exercise 14, so a confident un-run answer is usually wrong there.

## Good signs

- Asked why `homes/station/.profile` guards the source line with `[ -n "$BASH_VERSION" ]`.
- Noticed unprompted that "first match wins" is the same rule as `PATH`, applied to files.
- Went and looked at their own account's arrangement without being asked.
- Said that a startup file is just a script, and therefore inherits every failure mode a script has.

## If the answers are thin

- "Put a marker in all five files in a copy of `homes/full`. Now start four different kinds of shell.
  Which markers surprised you?"
- "Create a `.bash_profile` in a copy of `homes/station` containing one `export`. Log in. What did
  you just lose, and what error told you?"
- "In `homes/station`, run `alias` and then `type decks` in the same login shell. Both are correct.
  What different question is each one answering?"
