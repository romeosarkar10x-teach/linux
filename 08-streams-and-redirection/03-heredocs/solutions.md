# 08/03 — Solutions: here-documents and herestrings

Answer key and authoring notes. Every number here was measured in the container. Students should not
read this file.

---

## Warmup — the shape

**1.** The two decisions: **quoted versus unquoted delimiter** (does the body expand), and
**`<<` versus `<<-`** (are leading tabs stripped). Everything else in the lesson is consequence.

**2.**
```
sort <<EOF
c
a
b
EOF
```
prints `a b c`. `sort` read from fd 0. It cannot tell the difference from `sort < afile` — that is
the point of the abstraction. A process reads a file descriptor; what is on the other end is the
shell's business, not the program's.

**3.** Identical. `EOF` is a word chosen by the writer, not a token the shell knows. Any word works.

**4.** Three-line body: `wc -l` = 3. `wc -c` = the bytes of the three lines including their three
newlines. The heredoc supplies exactly the body, terminated; nothing extra is added and nothing is
trimmed.

**5.** `sort < scratch/thatfile` gives the same output. The heredoc version does not need **a file**
— no name, no directory, no cleanup, no permission to write anywhere.

**6.** Empty body prints nothing, exit status 0. `cat <<EOF | wc -c` with an empty body is **0**
bytes. An empty heredoc is a legitimate empty stdin, not an error.

**7.** `2`. And yes — a heredoc appeared where `grep` would normally take a filename argument. It did
not: it appeared as a *redirection*, and `grep` with no file argument reads fd 0.

**8.** Because the body is a redirection of fd 0, not a file operation: the shell holds the text and
connects the command's standard input to it.

## Quoted versus unquoted

**9.** Measured:
```
cat <<EOF    ->  1 05
cat <<"EOF"  ->  2 $v
cat <<\EOF   ->  3 $v
```

**10.** Two behaviours, four spellings. `<<EOF` expands. `<<"EOF"`, `<<\EOF` and `<<'EOF'` are all
the same thing: literal.

**11.** `<<'EOF'` is in the literal group. Any quoting at all — single quotes, double quotes, one
backslash — disables expansion completely. There is no partial setting.

**12.** Unquoted, body `tick: $(id -un)` prints `tick: cadet`. The command substitution ran, in the
current shell, at the moment the command was executed — before `cat` produced any output. This is the
security-relevant one: an unquoted heredoc body is executable text.

**13.** Quoted delimiter: `` `id -un` and $(id -un) `` comes out verbatim, both forms, nothing runs.

**14.** Unquoted:
```
dollar: $HOME     <- \$ became a literal $, the backslash was consumed
back: \           <- \\ became one backslash
```
The shell consumed one backslash in each case. Inside an unquoted heredoc, `\` is an escape
character, exactly as in a double-quoted string.

**15.** Body `$((6*7))` prints `42`. Active inside an unquoted heredoc: parameter expansion (`$var`,
`${var}`), command substitution (`$(…)` and backticks), arithmetic expansion (`$((…))`), and
backslash escapes. **Not** active: word splitting and globbing — the body is not a word list.

**16.**
```
cat <<'EOF' > f            cat <<EOF > f
PATH=$PATH:/opt/bin        PATH=\$PATH:/opt/bin
EOF                        EOF
```
Put the quoted one in a script somebody else maintains. It has one rule ("nothing in here is shell")
instead of a per-character audit, and adding a line to it later cannot break it.

**17.** `field: .` — the variable expanded to nothing. No error, no warning, exit status 0.

**18.** Because a failure stops and says so; this produces a well-formed, plausible, wrong result that
can survive for years. (In this lab: since 2186.)

## The broken banner

**19.** Observed: the banner prints field *names* instead of values — actually it prints neither, but
that is what cass has been told. Also observed: the two scripts in `bin/` look identical. Concluded:
that there is no difference, which is the wrong conclusion; they compared different things.

**20.** Line 3: `template fields:  and` — both field names are gone, leaving two spaces and a
dangling `and`.

**21.** Five lines, all on fd 1. Check: `bin/mkbanner 2>/dev/null | wc -l` is still 5, and
`bin/mkbanner 1>/dev/null` prints nothing.

**22.** `cat -A` gives ` template fields:  and $` — two spaces between the colon and `and`, then
end-of-line. The expansions produced empty strings; the literal spaces around them remain.

**23.** `diff <(bin/mkbanner) <(bin/mkbanner-fixed)` is **8 lines** (three changed output lines plus
diff's own markers).

**24.** Ignoring comments, the only code difference:
```
6c5
< cat <<EOF
---
> cat <<'EOF'
```

**25.** The quote. One character — a `'` — is the entire bug.

**26.** `DECK` and `SHIFT` are set by the script; `DECK_NAME` and `SHIFT_LEAD` are not set at all.
Same heredoc, same expansion, different variables. Unset expands to empty.

**27.** `DECK=05; echo "$DECK_NAME"` prints an empty line; `echo "${DECK}_NAME"` prints `05_NAME`.
A variable name is the longest run of letters, digits and underscores, so `$DECK_NAME` is one name,
not `$DECK` plus text. Braces are how you say where the name ends.

**28.** Either fix works mechanically; they mean different things. If the banner is a **template**
that another tool fills in later, quote the delimiter — the `$FIELD` placeholders are supposed to
survive. If the banner is the **final output**, the placeholders were meant to be values, so set the
variables (and consider `set -u` so an unset one is an error next time). State your assumption. The
lab's `templates/banner.txt` holds the same text with the `$` fields intact, which is evidence for
the template reading.

**29.**
```
cp bin/mkbanner scratch/mkbanner
sed -i "s/cat <<EOF/cat <<'EOF'/" scratch/mkbanner
bash scratch/mkbanner
```

**30.** `seedform` *wants* expansion: `$form` and `$deck` are the whole point. Quoting the delimiter
would print the literal text `form $form -- deck $deck`. Unquoted is correct here — and note the body
contains no other `$`, which is what makes it safe.

**31.** `${1:?usage: seedform FORM DECK}` — the Chapter-5 "error if unset or null" expansion. It
prints on **fd 2** (`bin/seedform: line 3: 1: usage: seedform FORM DECK`) and exits 1. Confirm the fd
with `bin/seedform 2>/dev/null` (silent) versus `bin/seedform 2>&1 >/dev/null` (message survives).

## `<<-` and the tab rule

**32.** `cat -A` shows `^I` at the start of every line of `tabbed.txt` and four literal spaces at the
start of every line of `spaced.txt`. Identical to the eye, different bytes.

**33.** Different md5. Each line differs by the leading whitespace: one tab (1 byte) versus four
spaces (4 bytes), and the nested lines likewise.

**34.** With real tabs, `<<-END` strips them: the body prints flush left, and any *spaces* after the
tabs survive. The closing `END`, tab-indented, still matches.

**35.** With four spaces, nothing is stripped and the closing delimiter never matches:
```
/tmp/f.sh: line 6: warning: here-document at line 2 delimited by end-of-file (wanted `END')
/tmp/f.sh: line 7: syntax error: unexpected end of file
```
Exit status **2**.

**36.** Two things: (a) the body was not de-indented — silent, no message; (b) the closing delimiter
did not match, which is what produced the warning and then the syntax error at end of file. Only (b)
is loud.

**37.** Body tab-indented, delimiter space-indented: the body de-indents fine, the delimiter still
does not match, and you get the same end-of-file warning. Tabs on the delimiter line are part of the
deal.

**38.** A tab then two spaces: the tab goes, the two spaces stay. Rule: **`<<-` removes leading tab
characters — all of them — from the start of each body line and from the delimiter line, and stops at
the first character that is not a tab.**

**39.** Historical: it comes from an era where a tab *was* indentation and code was written in `ed`
and `vi` with tab stops. Practical: whitespace inside the body is often significant, and a tab is a
character you can promise never to start a data line with, whereas leading spaces frequently *are*
the data.

**40.** Something like: "If you use `<<-`, your editor must insert real tabs inside heredoc bodies —
set `expandtab` off for shell files, or don't use `<<-`. There is no way to make it strip spaces."

## Delimiter accidents

**41.** Trailing space after `EOF`:
```
/tmp/t41.sh: line 4: warning: here-document at line 1 delimited by end-of-file (wanted `EOF')
```
and the rest of the script — including the `EOF ` line and the `echo after` — is printed as heredoc
body. **Exit status 0.**

**42.** Because exit 0 is the signal every wrapper, every `&&` chain and every CI job checks. A loud
warning on fd 2 plus a success status means the failure is invisible to automation and visible only
to a human who happened to be watching the terminal. (You will meet this again in lesson 05.)

**43.** Yes, same failure. A plain `<<` requires the delimiter at column 1; one leading space is
enough to break it, with the same warning and exit 0.

**44.** `EOF done` also does not match — the closing line must contain the delimiter *and nothing
else*. Same warning, same body-swallowing, exit 0.

**45.** The heredoc ends at the **first** matching line. The remainder of your intended body then
becomes shell commands. Measured, with body `line` / `E` / `E`:
```
line
/tmp/t45.sh: line 4: E: command not found
```
rc 127. Rule: pick a delimiter that cannot occur as a whole line in the body — that is why people use
`EOF`, `__END__`, or something with the file's purpose in it.

**46.** `cat <<'A' <<'B'` prints `second doc`. Both heredocs are set up, both are attached to fd 0,
and the last one wins — exactly lesson 02's rule that the final assignment to an fd is the one in
effect when the command runs. The first body is read and discarded.

**47.** It works:
```
paste <(cat <<'A'
1
2
A
) <(cat <<'B'
x
y
B
)
```
gives `1<TAB>x` / `2<TAB>y`. No collision because each heredoc is fd 0 of a *different* process, and
`paste` receives two filenames (`/dev/fd/…`) as arguments rather than anything on its own stdin.

## Herestrings

**48.** `wc -c <<<'deck 05'` = **8**; `printf 'deck 05' | wc -c` = **7**. `<<<` appends a newline.

**49.** Ordinary Chapter-5 quoting rules, applied to the word: `<<<"deck $d"` gives `deck 05`,
`<<<'deck $d'` gives `deck $d`. There is no delimiter to quote — the quoting is on the string itself.

**50.** `deck=05 / shift=beta`. You avoided the subshell: `echo … | read` runs `read` in a subshell,
so the variables are gone by the time the next command runs. Same trap as exercise 58.

**51.** All three answers are 3, including unquoted `<<<$t`. A herestring is not word-split or
globbed, so the newlines survive. Quote it anyway as a habit; the habit is right everywhere else.

**52.** `wc -c <<<""` = 1: the newline `<<<` appends. There is no way to make `<<<` produce zero
bytes.

**53.** `grep -c deck <<<"$(< data/decks.txt)"` = **4**. (`$(< file)` is a bash shortcut for
`$(cat file)` that forks nothing.)

**54.** `<<<` for a single line, especially feeding `read`, `grep`, `jq`-style tools that insist on
stdin. `<<` for multi-line literal text. A **pipe** is better whenever the data is already coming out
of another command — building a string just to herestring it back in is a round trip for nothing.

## Composition

**55.** Same command. Prove it by writing the same body both ways to two files and `cmp`:
```
cat > scratch/z1.txt <<'EOS'
a
EOS
cat <<'EOS' > scratch/z2.txt
a
EOS
cmp scratch/z1.txt scratch/z2.txt && echo same
```
The shell collects every redirection on the line before executing anything, so their order is
irrelevant *when they touch different fds*. (When they touch the same fd, order decides — lesson 02.)

**56.**
```
bash <<'EOF' 2>/tmp/e
echo out; echo err >&2
EOF
```
`out` appears on the terminal, `err` lands in `/tmp/e`. The heredoc is `bash`'s stdin — that is, its
*script* — while the `2>` applies to the same `bash` process. Note the delimiter is quoted; unquoted,
the outer shell would expand the script before the inner one ever saw it.

**57.** `readlink /proc/self/fd/0 <<'EOF'` prints `pipe:[…]` for a short body. Not openable by name.
For a large body bash switches to a temp file (see exercise 67), which is also not usefully openable
because it is already unlinked.

**58.** Heredoc form: `n=2`. Pipe form: `n=0`. The pipeline runs each stage in a subshell, so the
`while` loop's `n` is incremented in a child process and discarded when it exits. The heredoc form
redirects the loop itself, which runs in the current shell.

**59.** Use the redirected form when you need state after the loop. If the input really is another
command's stdout, your options are: process substitution — `while read …; done < <(cmd)` — which
keeps the loop in this shell; `shopt -s lastpipe` (non-interactive shells only); or accept the
subshell and have the loop print its result for the caller to capture.

**60.**
```
sort -k2 -n > scratch/sorted.txt 2>/dev/null <<'EOF'
p-a 41
p-c 44
p-d 39
EOF
```
Three redirections on one command: fd 1 to a file, fd 2 to `/dev/null`, fd 0 from the heredoc. Order
among them does not matter.

## Reporting

**61.** Model answer: "The banner's here-document uses an unquoted delimiter, so the shell expands
`$DECK_NAME` and `$SHIFT_LEAD` — which are never set — to nothing before `cat` runs. The two scripts
differ by one character, a quote around the delimiter, which is invisible in the output and easy to
miss in the source. Either quote the delimiter, if the fields are meant to be filled in downstream,
or set the two variables in the script."

**62.** `grep -rn '<<[A-Za-z_]' /usr/local/bin` — heredocs whose delimiter starts with a bare word.
False positives: `<<` as a left-shift in arithmetic, `<<<` herestrings, delimiters that legitimately
want expansion (like `seedform`), and matches inside comments or quoted strings.

**63.** (a) Nothing checks it — no exit status changes, no log line appears, so no alarm exists to
ignore. (b) The output still *reads* like a banner, and a human skimming a header they have seen
2,000 times sees the shape, not the content.

## Experiment

**64.** Unquoted with `$1` in the body: the `$1` is expanded by the *generating* shell (to empty, or
to the generator's own first argument), so the generated script ignores its arguments. Quoted: `$1`
survives into the file and the generated script works. Generating code is the canonical case for a
quoted delimiter.

**65.** Outer quoted, inner whatever you need — and the two delimiters must be **different words**,
because the outer heredoc ends at the first line equal to its delimiter and would otherwise stop at
the inner one. Convention: `OUTER`/`EOF`, or name them after their contents.

**66.** Use a different delimiter (`<<'DONE'`, body containing a bare `EOF` line). Second way: with
`<<-DONE` you can indent the body line `EOF` with a tab — but then the tab is stripped and the line
becomes `EOF` in the output while never having been at column 0 in the source. Only the second trick
lets you keep `EOF` as the delimiter *and* have `EOF` in the body.

**67.** Measured with a 100,000-line body:
```
/tmp/sh-thd.HOPPq2 (deleted)
```
Bash uses a **pipe** for a small heredoc and switches to an unlinked **temporary file** for a large
one, because a pipe's buffer would fill and deadlock — the shell writes the whole body before the
command starts reading. The file is already unlinked, so it has no usable name.

**68.** The body's *text* is read at parse time; its *expansions* happen when the command runs.
Measured:
```
echo A; cat <<EOF
$(echo B >&2)
EOF
```
prints `A` then `B`. The substitution had not run when `echo A` executed.

**69.** `cat <<EOF` with `$(sleep 3; echo done)` takes the full sleep before `cat` produces anything —
measured 2.005s for a 2-second sleep. The shell must finish building the body before it can hand it
over, so a slow substitution inside a heredoc delays the command, not the other way round.

## Stretch

**70.** Every `$` in the body needs a decision. The two you want expanded stay bare; every other one
is `\$` (or you split the heredoc: a quoted one for the literal block, an unquoted one for the two
lines that need values). The second approach is usually better because the rule per block is simple.

**71.** The deployment script writes the config with `${PORT}` already expanded — to empty, because
`PORT` is not set at deploy time — so the downstream tool finds nothing to substitute and the service
comes up bound to whatever an empty port string means to it. The fix is two characters: `<<'EOF'`.

**72.** A heredoc renderer has to `eval` or re-source the template to get expansion, which means any
`$(…)` in the template is executed with your privileges. `envsubst` substitutes only named variables
and executes nothing; a `sed` pass with explicit `s/\$FIELD/value/` is even narrower. Prefer the tool
that cannot run code.

**73.**
```
banner_ok() {
  bin/mkbanner | grep -q 'fields: [^ ].* and [^ ]' || return 1
}
```
Assert on the one line whose content is derived, not on the whole output: the rules and the deck line
are literal text that will change for cosmetic reasons and would make the test noisy.

**74.** A triple-quoted string is a value your program holds; a heredoc is a **file descriptor** your
program reads. The Python analogue is not `"""…"""` — it is `io.StringIO` passed as the child's
stdin. That is why a heredoc can feed `sort`, `bash`, or anything else that never learned about
strings.

**75.** One sentence, and no searching: if that path were built inside an unquoted heredoc, an unset
variable in it would expand to nothing and the path would silently collapse to something shorter than
intended. (Lesson 06 is where this gets chased. Do not chase it now.)

---

## Authoring notes

- `bin/mkbanner` and `bin/mkbanner-fixed` differ in exactly one code character plus their comment
  headers. Exercise 24's diff is the payoff; do not let a tutor hand it over early.
- The `<<-`-with-spaces failure was measured, not assumed: warning at line 6, syntax error at line 7,
  **exit 2**. Run it in a subshell — in an interactive shell it eats everything typed after it.
- Exercise 41's trailing-space case exits **0**. That is the fact worth the exercise; it sets up
  lesson 05's whole subject.
- Exercise 67's pipe-versus-temp-file switch is bash-version-specific in its threshold but not in its
  existence. Do not quote a byte count; have the student measure.
- Nothing in this lab contains the string `KESTREL`. There is no flag in this lesson.
