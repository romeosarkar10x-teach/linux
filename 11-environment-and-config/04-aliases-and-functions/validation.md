# 11/04 — Validation

For the AI validator. No auto-grader.

## Pass requires all of

1. **Definition.** "An alias is a text substitution on the first word, applied when the line is
   parsed." Can use that sentence to explain exercises 7, 10 and 11 without further help.

2. **No arguments.** States that an alias has no `$1` and that typed words are simply left after the
   replacement text. Can say why putting an argument in the middle is impossible.

3. **Interactive only.** Knows aliases are off in non-interactive shells, and connects it to lesson
   03, exercise 30 rather than treating it as new.

4. **ops-bot.** Reproduces 2 lines interactively and 3 in a script from the same sourced file, and
   explains it. Has checked the mtime and accepts that ops-bot is right about both the file and the
   absence of a fault. Frames the remaining problem as a decision (which output is authoritative),
   not a bug.

5. **Bypasses.** Distinguishes `\name` and quoting (suppress alias expansion only) from `command`
   (skips alias *and* function). Has run all three.

6. **Trailing space.** Demonstrates the chaining rule both ways and can say what `alias sudo='sudo '`
   is for.

7. **Functions.** Has written one with arguments and a `return` status; knows `return` from `exit` and
   why `exit` in a startup file is catastrophic. Has demonstrated `local` by removing it and watching
   a caller's variable change.

8. **Functions beat PATH.** States the resolution order with `PATH` last, shows that `which` cannot
   see a function while `type` and `type -a` can, and knows `command -v` prints a bare name rather
   than a path for one.

9. **`command` and recursion.** Explains what `command` is doing in the wrapper, and has *measured*
   the unguarded case: exit 139, segfault, no message. Knows `FUNCNEST` converts it to a named error,
   and prefers that.

10. **The three mistakes.** For each of `rc/broken.sh`: mistake 1 works interactively for the wrong
    reason (`$1` was empty when sourced, the argument is merely appended) and fails in a script;
    mistake 2 is unbounded recursion, fixed with `command`; mistake 3 leaks `i`, fixed with `local`.
    A pass needs the *reason* for mistake 1, not just "it works".

11. **Choosing.** Gives a defensible rule: fixed shortcuts for typing may be aliases, anything with an
    argument, a decision, a status, or a script consumer must be a function.

## Lab state

```
find . -newermt '2187-06-24 09:00:01' -not -path './scratch/*'
```

Should list nothing.

```
stat -c '%y' bin/deck-report    # 2185-11-02 14:20:00
grep -c local rc/functions.sh   # 1
```

If `local` has been removed from `rc/functions.sh`, they edited the seed instead of a copy
(exercise 34). Reset and ask what the copy was for.

## Red flags

- "`which` is wrong." It found a real file. Third occurrence of this pattern in the chapter; by now
  the student should name the pattern.
- Predicts exercise 43 rather than running it, and reports "maximum function nesting level exceeded"
  as the default behaviour. It is not; the default is a segfault.
- Says mistake 1 in `rc/broken.sh` is fine because it works.
- Claims a function is a child process, or that `cd` could be a program.
- Treats ops-bot's page as a report of a fault, or proposes "fixing" the program.
- Confuses `unset` and `unset -f`, or believes a variable and a function cannot share a name.

## Good signs

- Noticed the `[wrapped]` line is on fd 2 and said a hostile wrapper would simply not print it.
- Connected the alias/function shadowing back to `PATH` shadowing in lesson 02 unprompted, and
  observed that the function version is worse because `PATH` is never even consulted.
- Asked who gets to decide which of ops-bot's two numbers is authoritative.
- Wrote their exercise 46 predictions down before running anything, and said which one was wrong.

## If the answers are thin

- "Define an alias and use it on the same line. Now on two lines. What changed?"
- "Source `rc/aliases.sh` in your shell and again in `bash -c`. Count the lines each time. Same file?"
- "Put `i=IMPORTANT` in your shell, run `count`, then look at `i`. Who did that?"
- "Define `r() { r; }` and run it. Tell me the exit status and the error message."
