# 10/04 — Validation rubric

For the validator agent. No script grades this lesson. Judge the written answers.

## Non-negotiable

1. **First match wins.** They can state that exactly one triad is applied, and they predicted or
   explained exercise 11/12 correctly — an owner with `---` cannot read their own file however
   permissive the later triads are. Reject any answer containing an idea of accumulated or combined
   permissions.

2. **`r` and `x` on a directory are different permissions over different operations**, stated in the
   directory's own terms: `r` lists names, `x` traverses. Exercises 24, 50. A student who says
   "`x` means executable" for a directory has not passed.

3. **The four-row table in exercise 28 exists and is correct.** 755 all three; 744 names only, `?`
   columns, no read; 711 no listing but a known name works; 700 nothing.

4. **Why `ls -l` shows question marks.** `ls` read the names out of the directory (that is `r`) and
   then needed to stat each file to fill the other columns, which requires reaching them (that is
   `x`). Exercises 21, 22. "Because it doesn't have permission" is not the answer; the question is
   which operation needed which bit.

5. **The path rule.** Every directory component needs `x`, checked one at a time, before the file's
   own mode is consulted. Exercises 26, 45, 48.

6. **Octal both directions**, exercises 7 and 8, with no arithmetic errors.

## Should be present

- root is not subject to the triads (exercise 15), stated as a separate fact rather than folded into
  the rule.
- `chmod` needs ownership, not any of the nine bits (exercise 14).
- `--x` reveals existence one guess at a time and so hides the index, not the data (exercise 25).
- A symlink's own mode is never consulted (exercises 54, 56).
- `stat` reads metadata and needs traversal, not read (exercise 55).
- `namei -l` reached for at least once without being told to (exercises 46, 47, 33).

## The audit listing, 34–44

Answer from the listing alone. Check that they did not run commands against the station — nothing in
that listing exists here, so any answer citing live output is answering a different question.

**Exercise 39 is the integrity check.** `tools/adjust` is `-rwx------ root root` with an 02:55
timestamp, and the exercise asks explicitly what they can *not* say. A student who names a person,
assigns an intent, or calls it malicious has failed this exercise regardless of how good the rest is —
the evidence supports "restricted, executable, modified at that time" and nothing further. Credit
answers that say so plainly.

**Exercise 44** should land on `heartbeat`. Accept another choice only if it is defended against
`heartbeat` explicitly; "it looks suspicious" is not a defence, and world-writable is a *defect*
where the others are *questions*.

**Exercise 41** wants a non-sinister use for `--x`. Per-user directories, `/home` on a shared machine,
mail spools. A student who cannot produce one is still reading modes as accusations.

## Written answer — exercise 32 (the reply to cass)

Three sentences. Must contain: the mechanism (`r` without `x`), the evidence, and the correct ask —
**execute on the directory**, not read on the file. A reply that requests read access to the file has
diagnosed correctly and prescribed wrongly; send it back. A reply that tells cass she is mistaken has
misread the page. rhea being wrong should be stated without being scored.

## Lab state

The lesson changes nothing outside `scratch/`. If `maze/` modes have been altered, the student used
`chmod` where the lesson says not to — reseed before lesson 05, since 05 measures against these
modes.

```
stat -c '%a %n' maze/open maze/listed maze/reachable maze/shut
755 / 744 / 711 / 700
```

## The failure that looks like success

Fluent octal conversion, every command run, and an answer to exercise 24 that says "because `x` means
you have permission". That is a restatement, not an explanation. Probe with: "Describe an operation
that `r` allows and `x` does not, and one that `x` allows and `r` does not." Both halves are needed.
