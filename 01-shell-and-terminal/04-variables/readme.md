# 01/04 — Variables

> Everything the station's tooling knows about you, it knows because something set a variable.
> Including the things that are wrong.

A shell variable is a name with a string in it. That is the entire data model. There are no
numbers, no booleans, no objects — there are strings, and things that look like other types are
strings that some program agreed to interpret.

## Assignment: the whitespace rule

```bash
$ deck=3
$ echo $deck
3
```

**No spaces around the `=`.** This is not a style preference, it is the parser:

```bash
$ deck = 3
bash: deck: command not found
```

Read that error with lesson 01/03 in hand and it explains itself. The shell split the line into
three words, took the first as a command word, and went looking for a program called `deck`. The
`=` was just an argument.

```bash
$ deck =3
bash: deck: command not found
$ deck= 3
bash: 3: command not found
```

That last one is subtler: `deck=` assigned an empty string, and then `3` was treated as the command
to run with that assignment in effect. Chapter 11 explains why that is a real feature and not a
bug.

## Reading a variable

`$name` substitutes the value. So does `${name}`, and the braces are not decoration:

```bash
$ deck=3
$ echo "$deck"
3
$ echo "deck$deck"
deck3
$ echo "$deckplating"        # WRONG: asks for a variable called deckplating
$ echo "${deck}plating"      # RIGHT
3plating
```

The braces mark where the name ends. Without them the shell reads as far as it can — letters,
digits and underscores — and takes all of it as the name.

> **Habit worth forming now:** always quote variable expansions — `"$deck"`, not `$deck`. The
> reason is Chapter 5's whole subject, and until then "always quote" is a rule that costs you
> nothing and will save you repeatedly.

## Unset is not empty

Three distinct states, and tools that conflate them cause real bugs:

```bash
$ unset colour            # the name does not exist
$ colour=                 # exists, value is the empty string
$ colour=red              # exists, has a value
```

`echo "$colour"` prints a blank line for the first two. They look identical and are not:

```bash
$ unset colour
$ echo "${colour:-none}"
none
$ colour=
$ echo "${colour:-none}"
none
$ echo "${colour-none}"
                          # <- blank. Note: no colon.
```

The **colon** is the difference. `${x:-d}` means "if unset *or empty*, use `d`". `${x-d}` means "if
unset, use `d`" — an empty value is a real value and is kept.

You will meet the colon rule again in `:=`, `:+` and `:?`. It always means the same thing.

## Default-value expansions

```bash
$ echo "${editor:-nano}"      # use nano if editor is unset/empty. Does NOT assign.
nano
$ echo "$editor"
                              # still unset
```

`:-` substitutes a fallback without changing anything. That makes it the right tool for "use this
unless the caller told me otherwise", which is most of what a configurable script does.

There is a family:

| Form | Meaning |
|---|---|
| `${x:-d}` | use `d` if `x` is unset or empty; leave `x` alone |
| `${x:=d}` | use `d`, **and assign it to `x`** |
| `${x:?msg}` | use `x`, or fail with `msg` if it is unset or empty |
| `${x:+d}` | use `d` **only if `x` has a value** — the reverse of `:-` |

`${x:?}` is the one to remember for scripts. It turns a silent misconfiguration into a loud
failure at the top of the file rather than a confusing one somewhere in the middle. Chapter 12
uses it in anger.

## Variables the shell sets for you

You have already met some:

```bash
$ echo $$          # this shell's PID          (01/01)
$ echo $0          # how this shell was invoked (01/02)
$ echo $?          # exit status of the last command
$ echo $HOME
/home/cadet
$ echo $PWD
/labs/01-shell-and-terminal/04-variables
```

`$?` is worth dwelling on. Every command sets it: `0` means success, anything else means failure,
and the specific non-zero value is the program's own business.

```bash
$ ls /nonexistent
ls: cannot access '/nonexistent': No such file or directory
$ echo $?
2
$ echo $?
0
```

Note the second reading. `$?` reports the *previous* command — and the previous command was the
first `echo`, which succeeded. Read it once, or store it.

## Naming

By convention: lowercase for your own variables, UPPERCASE for exported environment variables. The
shell does not enforce this and neither does anything else, but everyone follows it, and breaking
it is a good way to accidentally clobber something like `PATH`.

Legal names are letters, digits and underscores, not starting with a digit.

> **A word about `export`.** You will have seen `export VAR=value` in tutorials. That is about
> making a variable visible to *child processes*, and it is Chapter 11's subject. Everything in
> this lesson is about variables inside your own shell, which is a smaller and more immediate
> thing. Ignore `export` for now.

## Before you move on

- Why `deck = 3` is a `command not found` and not a syntax error.
- When `${name}` is required rather than optional.
- The difference between unset and empty, and which form of `:-` distinguishes them.
- What `$?` holds, and why reading it twice gives two different answers.
- Which of `:-` and `:=` changes the variable.
