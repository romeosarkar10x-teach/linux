# 08/03 — Here-documents and herestrings

Lesson 02 was about where output goes. This one is about where *input* comes from when there is no
file to point at.

You already know `cmd < file`: fd 0 is connected to a file. A **here-document** connects fd 0 to text
that the shell is holding. Nothing is on disk, nothing is named, and the text is written inline, in
the middle of the command:

```
sort <<EOF
c
a
b
EOF
```

`sort` cannot tell the difference. It reads fd 0 until end of file and prints `a b c`. That is the
entire idea: **a heredoc is a redirection of fd 0, not a string literal**. Everything else in this
lesson follows from that sentence.

## The shape

```
command <<DELIMITER
body line
body line
DELIMITER
```

`DELIMITER` is any word you like. `EOF` is a convention, not a keyword; `END`, `SQL`, `BANNER` all
work, and picking a distinctive one is how you keep nested heredocs readable. Three rules about the
closing line, and all three are places people lose an afternoon:

- it must contain the delimiter **and nothing else**
- it must start at column 1 (unless you use `<<-`, below)
- a **trailing space** after the delimiter means it does not match

Miss it and bash swallows the rest of your script as heredoc body and then says

```
warning: here-document at line 1 delimited by end-of-file (wanted `EOF')
```

Note that this is a *warning*, on fd 2, and the command may still exit 0. You will see this in the
exercises. It is one of the few places where the shell tells you something is badly wrong and then
carries on anyway.

## The one decision that matters: quote the delimiter or not

| written | body is | `$var` | `$(cmd)` and backticks | `\` escapes |
|---|---|---|---|---|
| `<<EOF` | expanded | yes | yes, **runs** | yes |
| `<<'EOF'` | literal | no | no | no |
| `<<"EOF"` | literal | no | no | no |
| `<<\EOF` | literal | no | no | no |

Any quoting of the delimiter — single, double, or a single backslash — turns expansion off entirely.
There is no half-on setting.

With an unquoted delimiter the body is treated almost exactly like the inside of a double-quoted
string. That is powerful and it is the source of every "why did my script eat the dollar signs" bug
there is. If the body contains shell syntax — a script you are generating, a config file, an `awk`
program, a regex, a template with `$FIELD` placeholders — quote the delimiter. If you want two values
interpolated and nothing else touched, unquote it and accept that you now have to escape every other
`$` in the body as `\$`.

This chapter's lab ships the bug. `bin/mkbanner` prints

```
 template fields:  and
```

where it should print two field names. The names were `$DECK_NAME` and `$SHIFT_LEAD`, the delimiter
was not quoted, neither variable was set, and an unset variable expands to nothing. The shell did not
fail, did not warn, and produced a line that is grammatically fine and missing its content.

## `<<-` strips tabs. Only tabs.

Inside an indented block a heredoc body normally has to be flattened against the left margin, because
leading whitespace is part of the text. `<<-` fixes that:

```
    cat <<-END
	the leading tabs on these lines are stripped
	  and these two spaces are not
	END
```

Leading **tab** characters are removed from every body line *and from the closing delimiter line*.
Spaces are not touched. If your editor inserts spaces when you press Tab — most do, by default —
`<<-` does nothing at all, silently, and if you indented the closing delimiter too, the delimiter no
longer matches and you get the end-of-file warning above. That combination is why so much shell code
in the wild has one heredoc jammed against column 1 in the middle of a neatly indented function.

Measure it rather than believing it. `cat -A` shows a tab as `^I`.

## Herestrings

```
command <<<"one line of text"
```

Same mechanism, one line, same quoting rules — but here the quoting is ordinary shell quoting on the
word, so `<<<"deck $d"` expands and `<<<'deck $d'` does not, exactly as you would expect from Chapter
5. A herestring **appends a newline**: `wc -c <<<'deck 05'` is 8, while `printf 'deck 05'` is 7.

It is the shortest way to feed a string to something that only reads stdin:

```
grep -c deck <<<"$text"
read -r deck shift <<<"05 beta"
```

Nothing is word-split or globbed on the way in; `<<<$t` with `t` holding three lines still delivers
three lines.

## Why it composes

Because it is fd 0 and nothing else, a heredoc goes anywhere a redirection goes, and combines with
the output redirections from lesson 02 in either order — these two are the same command:

```
cat > out.txt <<'EOF'
cat <<'EOF' > out.txt
```

The shell collects all the redirections before running anything, so their order on the line does not
matter here. (Order *does* matter when two redirections touch the same fd — that was lesson 02.)

A heredoc also survives into a loop in a way a pipe does not:

```
n=0; while read -r l; do n=$((n+1)); done <<'EOF'
one
two
EOF
echo $n        # 2

n=0; printf 'one\ntwo\n' | while read -r l; do n=$((n+1)); done
echo $n        # 0
```

The pipeline puts the `while` in a subshell, and the subshell's `n` dies with it. The heredoc form
redirects the loop itself, in this shell. That difference is worth more than it looks.

If you want to know what fd 0 actually is during a heredoc:

```
readlink /proc/self/fd/0 <<'EOF'
x
EOF
```

On this bash you get `pipe:[…]`. Older bash wrote a temporary file and deleted it. Either way it is
not something you can name, which is the point.

## What to take out of here

- A heredoc is a redirection of fd 0. It is not a string and not a file.
- Quote the delimiter unless you want expansion. Unset variables expand to nothing, quietly.
- `<<-` strips leading tabs, from the body and the delimiter, and never strips spaces.
- The closing delimiter must be alone on its line, with no trailing space.
- `<<<` is the one-line version and adds a newline.
- Redirecting a loop with `<<` keeps it in the current shell; piping into it does not.

Now: `exercises.md`.
