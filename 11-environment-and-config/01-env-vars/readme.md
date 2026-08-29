# 11/01 — Environment variables

> A variable your shell knows and a variable your programs know are two different things, and the
> gap between them explains most "it works when I type it" complaints.

You have been setting variables since chapter 1 and passing them to nothing. That was fine, because
everything you did with them happened inside the shell that held them. This chapter is about the
moment a variable has to leave — cross into another process — and about the fact that most of them
never do.

Here is the whole mechanism. Your shell keeps a table of **shell variables**. Some of them are
marked *exported*. When the shell starts a program, the kernel hands that program a copy of exactly
the exported ones, and nothing else. That copy is the program's **environment**. `DECK=05` puts a
name in the table. `export DECK=05` puts it in the table and marks it. The difference is one word
and it is invisible until something else tries to read it.

Three consequences follow, and they are the lesson:

**It is a copy.** The child can change its environment all it likes; the parent's table is
untouched, and there is no flag, option or trick that changes this in any Unix shell. When somebody
tells you a script "set a variable in my shell", they ran it with `source`, which starts no child at
all. You will prove both halves of this with `bin/set-station`.

**It is a snapshot.** The copy is made when the process starts. Exporting a variable afterwards does
not reach a program that is already running.

**It runs downward only.** Your shell was itself started by something, and the environment you are
reading right now is a copy of that thing's exports. This container hands your login shell eleven
variables. Your `.bashrc` adds two more, which is chapter 11's other half.

That gives you two different questions and two different tools. `set` asks *your shell* what it
knows — every variable, exported or not, plus every function, which is why the answer is over a
thousand lines. `env` is a separate program that prints what it *was handed*, so its answer is
short and its answer is evidence. Using `set` to reason about inheritance cannot work: it is asking
the wrong process.

The last piece is the one-shot prefix. `DECK=05 bin/deck-report` puts `DECK` in that one command's
environment and nowhere else — not in your shell before it, not in your shell after it. It is a
prefix on the command, not a statement of its own, and the difference between typing it with a space
and typing it with a newline is the difference between the report working and the report failing.
rhea's nightly job has failed three nights running for a reason from this paragraph.

## What you will be able to do

- [ ] State the difference between a shell variable and an environment variable in one sentence
- [ ] Use `export`, `export NAME`, `export -n` and `unset`, and say what distinguishes the last two
- [ ] Predict whether a child process will see a given variable, before running it
- [ ] Explain why a child can never set a variable in its parent, and what people mean when they claim it did
- [ ] Choose between `set`, `env`, `printenv` and `export -p` according to which process you are asking
- [ ] Test for a variable's existence with `printenv`'s exit status rather than an empty `echo`
- [ ] Distinguish unset from empty, and pick between `${x-d}` and `${x:-d}` deliberately
- [ ] Use `${x:?message}` to make a program refuse to run rather than run wrongly
- [ ] Use the `VAR=value command` prefix, and say what it leaves behind
- [ ] Use `env -i` and `env -u`, and say what `env -i` does to `PATH`
- [ ] Explain what a `( subshell )` sees and what it can change
- [ ] Explain why configuration files are sourced and not executed

## Files

```
bin/deck-report     reads DECK, CYCLE and REPORT_SOURCE from its environment
bin/show-inherited  prints five names and whether each one reached it
bin/count-env       prints the size of the environment it was handed
bin/set-station     exports STATION and prints it. Then look for it in your shell
logs/nightly.log    eleven months of success and three nights of the same error
logs/README         what you are and are not being asked to do about that
notes/variables.txt shell vs environment, the tools, and how to remove a variable
notes/inheritance.txt where a variable stops. Four ways to run something
notes/page.txt      rhea, and the sentence that precedes every wasted afternoon
scratch/            yours
```

The scripts in `bin/` are readable and you should read them, but you are not writing scripts in this
chapter — that is chapter 12. Here they are instruments. Each one answers exactly one question about
what crossed the boundary.

## Reset

`kestrel reset 11/01` rebuilds the lab. Nothing you set in your shell survives leaving it anyway,
which is itself worth noticing.
