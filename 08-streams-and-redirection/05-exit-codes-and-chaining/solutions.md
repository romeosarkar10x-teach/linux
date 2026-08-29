# 08/05 — Solutions: exit codes and chaining

Every number here was measured in the container. Where an answer surprised me while writing this, it
says so.

---

## Warmup

**1.** `notes/status.txt` is the reference table (0 success, 1 general, 2 usage, 126 not executable,
127 not found, 128+N killed by signal N) plus the two chaining rules. `notes/page.txt` is cass:
*"I do not think the walk is lying. I think it is not being asked the question."* Exercise 60.

**2.** `0` and `1`. `type -t true` prints `builtin` — `true` is a shell builtin, not `/usr/bin/true`
(both exist; the builtin wins).

**3.** `3`, then `0`. `bin/rc 3 >/dev/null 2>/dev/null; echo $?` still 3 — nothing on either fd.

**4.** `3`, then `0`. The second `echo $?` reports the status of the **first `echo`**, which succeeded.
`$?` is not a variable holding a history; it is "the status of the last command completed", and `echo`
was a command.

**5.** Because anything you do between the command and the read — an `echo`, an `if`, a `[`, a pipe —
replaces `$?`. Capture it on the very next line or you do not have it.

**6.** `0`. You printed the status of the `if`, which is the status of its last executed command
(`:`). The `3` was gone before you looked.

**7.** No history. Each completed command overwrites `$?`.

**8.** `0` (match), `1` (no match), `2` (could not read the file). One means "the answer is no", two
means "there was no answer".

**9.** `if grep -q PATTERN file` treats 2 exactly like 1: a missing or unreadable file becomes
"pattern not present". Try `if grep -q p-01 /nope; then echo found; else echo "not found"; fi` — it
prints `not found` about a file that does not exist (the `grep: /nope: No such file or directory` on
fd 2 is the only warning, and `-q` users usually discard fd 2 too). Test `$? -eq 1` explicitly, or check the file
first.

**10.** Yes. `diff` gives 0 identical, 1 differing, 2 trouble. Same three-way shape as `grep`, and
it is the common convention for tools that answer a question.

**11.** `127`. The **shell** produced it — no such program was ever started, so nothing else could
have. The message `bash: nosuchcommand: command not found` is also the shell's, on fd 2.

**12.** `126`. `ls -l bin/notexec` shows `-rw-r--r--`. The file was found; the kernel refused to
execute it. 126 is "found it, could not run it", 127 is "did not find it".

**13.** `126`. A directory is found and is not executable as a program — same category exactly.

**14.** `130` and `143`. 128+2 (SIGINT) and 128+15 (SIGTERM). The shell reports a signalled child as
128 plus the signal number.

**15.** `141` = 128+13 = SIGPIPE. `head` exited after one line and `seq` was killed writing to a pipe
with no reader.

**16.** `bin/rc 300` gives **44**; 300 mod 256 = 44. `bin/rc 256` gives **0** — a failure that
reports success. That is the danger: any computed exit code must be clamped, not passed through.

**17.** `255`. −1 mod 256. Exit status is a single unsigned byte: only 0–255 exist, and everything
else wraps.

**18.** `grep` documents 2 for trouble; `diff` the same; `sort` documents 2 as well. The one people
do not guess is `diff`'s 1 — it means "the files differ", which is a *normal* outcome, not an error,
so `diff a b && echo same` is the correct idiom and `set -e` will kill a script that runs a bare
`diff`.

## Chaining

**19.** `yes`, nothing, nothing, `no`. `a && b` runs `b` only if `a` succeeded; `a || b` runs `b`
only if `a` failed. Each operator also *is* a command with a status.

**20.** `A` prints on the first, not the second. `$?` at the end of line 1 is 0 (the `echo`); at the
end of line 2 it is 7 — the `&&` short-circuited, so the last command that ran was `rc`.

**21.** `1`, then `0`. `||` ran `true`, and the status of the whole list is the last command's. This
is the standard trick for stopping `set -e` killing a script on an expected failure — and also the
standard way to lose a status by accident.

**22.** `B`, `C`, and then **`C` again**. `&&` and `||` have equal precedence and associate left to
right: `(true && false) || echo C`. The left group ran `false`, so it failed, so `||` fired. This is
the classic bug in "ternary" shell one-liners — the `B` branch failing silently triggers the `C`
branch too.

**23.**
```bash
if true; then echo B; else echo C; fi
```
Now `C` runs only for a failing condition, whatever `echo B` does.

**24.** `fallback`. The braces group both echoes into the `&&` branch, which never ran. Without
braces, `false && echo b; echo c || echo fallback` is three separate commands: `c` prints
unconditionally and `fallback` never does, because `echo c` succeeded.

**25.** Yes, `ok` prints. `&&` tests the status of the **group**, which is the status of its last
command (`true`). The 3 is discarded inside the braces.

**26.** `a && b && c || d` — but it is wrong: if `b` or `c` fails, `d` runs too, and `d` was supposed
to mean "a failed". Exercise 22's trap. Use `if a; then b; c; else d; fi`.

**27.** `0` and `1`. `!` maps any non-zero to 0 and 0 to 1 — the original number is **destroyed**.
If you need the number, capture it first: `bin/rc 3; rc=$?; if [ "$rc" -ne 0 ]; then …`.

**28.** Prints `1 3 0`. `!` inverted the status of the *whole pipeline* (which was `cat`'s 0). The
individual stage statuses survive in `PIPESTATUS`, which `!` does not touch.

**29.** `cd /some/dir; rm -f *.tmp` — if the `cd` fails, the `rm` runs in whatever directory you were
already in. With `&&` the `rm` cannot run at all.

**30.** With `;`, `cd` fails, prints to fd 2, and `rm -rf ./*` then runs in the current directory,
deleting it. The fix is `&&` instead of `;`. (Better still, `set -u; cd "$d" || exit 1`.)

## Statuses that get lost

**31.** `4`. A command substitution's status becomes the status of the assignment, as long as the
assignment is the whole command.

**32.** `0`, then `7`. `local v=$(cmd)` is a **`local` command** with an argument; its status is
`local`'s, and `local` succeeds. Splitting the declaration from the assignment restores it, because
the assignment is then a command of its own.

**33.** *A declaration keyword swallows the status of a command substitution in its argument.* It
applies to `local`, `declare`, `typeset`, `export` and `readonly` — all of them. Declare on one line,
assign on the next.

**34.**
```bash
cat > scratch/f.sh <<'EOF'
#!/usr/bin/env bash
bin/rc 3
echo done
EOF
bash scratch/f.sh; echo $?
```
`0`. The script's status is its last command's, and the last command was a successful `echo`.

**35.** Either `rc=$?` after the failing command and `exit "$rc"` at the end, or move the `echo`
before the failing command. Prefer the explicit `exit "$rc"`: it survives someone appending a line to
the bottom of the script, which the other version does not.

**36.** `0` both times. A script that runs nothing succeeded; a bare `exit` exits with the current
`$?`, which was 0.

**37.** `0`. The `while` succeeded — it correctly evaluated its condition and correctly ran the body
zero times. Loop status is not "did the body run".

**38.** `6`. `time` is a keyword wrapping the pipeline; it reports timings on fd 2 and passes the
status through untouched.

## The bank walk

**39.** `bank A: ok` on fd 1, status `0`.

**40.**
```
checkbank: bank B did not answer      <- fd 2
bank B: check incomplete              <- fd 1
checkbank: done                       <- fd 1
```
Status `0`. Check the fds with `bin/checkbank B 2>/dev/null` and `1>/dev/null`.

**41.** The output says the bank did not answer; the status says the command succeeded.

**42.** `2`. The Z path is a usage error and the script was written with an explicit `exit 2` there.
The author handled the *argument* mistake and not the *result*.

**43.** The last command on the B path is `echo "checkbank: done"`, which succeeds. There is no
`exit` on that path, so the script's status is that echo's: 0.

**44.** `bin/checkbank-fixed B` exits `1`. `diff bin/checkbank bin/checkbank-fixed` shows an `rc=0`
initialisation, an `rc=1` on the failure path, and a final `exit "$rc"`. Only the last one changes
behaviour — setting `rc` matters solely because something reads it.

**45.** Nothing prints from the tool (both fds are discarded) and `ok` prints. This is exactly what
the nightly walk does, which is why the log is full of `ok`.

**46.** `if bin/checkbank "$b" >/dev/null 2>&1; then … else … fi` — it decides on exit status alone,
which is the right design. The tool is the part that is wrong.

**47.** 20 lines before. After the run, 24, and `tail -4` shows `2187-06-14 bank A ok` through
`bank D ok` — including **`bank B ok`**, on a night when bank B did not answer.

**48.**
```bash
cp bin/deckcheck scratch/deckcheck
sed -i 's|bin/checkbank|bin/checkbank-fixed|' scratch/deckcheck
bash scratch/deckcheck; tail -4 logs/deckcheck.log
```
Now `2187-06-14 bank B FAILED`. Nothing about the walk changed; the tool started answering.

**49.** The log is not wrong. It is a true record of what `checkbank` returned. It is a false record
of whether the banks answered, because the two stopped being the same thing.

**50.** Believe the people. The walk only ever tested "did the script finish", and a script that ends
in `echo` always finishes. Seeing `bin/checkbank B; echo $?` print an error message and then `0` is
what changes your mind — one command, ten seconds.

## `set -e`

**51.** It aborts: nothing prints and the shell exits 3. `bin/rc 3` is a plain simple command whose status is not tested,
so `set -e` fires and `still here` never prints. This is the one case `set -e` handles well.

**52.** Prints `still running`. `bin/rc 3 && echo yes` is a command *on the left of `&&`*, and
`set -e` never fires on a command whose status is being tested by `&&`, `||`, `!`, `if`, `while` or
`until`. The failure is expected by construction, so bash ignores it.

**53.** Prints `unreachable`, then `f ok`, then `end` — all three. Because `f` is used as the left
side of `&&`, `set -e` is disabled **throughout the entire function body**, so the line after the
failing command runs, the function returns 0 (its last command's status), and `f ok` prints. A
function called in a condition is not protected by `set -e` at all.

**54.** Same exception: the status of an `if` condition is being tested by definition.

**55.** No — from lesson 04, `bin/rc 3 | cat` has status 0, so there is nothing for `set -e` to
catch. Add `set -o pipefail`.

**56.**
```
set -e does not fire when the status is being tested:
  left of && or ||, or under !
  the condition of if / while / until
  any command inside a function or subshell used in one of those positions
  a non-final pipeline stage, unless pipefail is set
```

**57.**
```bash
rc=0
for b in A B C D; do
  if bin/checkbank-fixed "$b" >/dev/null 2>&1; then
    echo "$STATION_DATE bank $b ok" >> logs/deckcheck.log
  else
    echo "$STATION_DATE bank $b FAILED" >> logs/deckcheck.log
    rc=1
  fi
done
echo "deckcheck: 4 banks walked"
exit "$rc"
```
Every bank is still checked; the walk itself now fails when any bank did.

## Reporting

**58.** *The nightly walk decides ok or FAILED from `checkbank`'s exit status. `checkbank` ends with
an `echo`, so it exits 0 on every path except an unknown bank name, and the walk records ok whatever
the bank did. Adding `exit "$rc"` to the end of `checkbank` makes the walk's answer real.*

**59.** No — it is an accurate record of what the tool returned, so it is still evidence about the
tool; it is simply not evidence about the banks.

**60.** The walk asked `checkbank` "did you finish?", and `checkbank` answered truthfully: yes. Nobody
ever asked "did the bank answer?", because that answer was printed on fd 1 and fd 2 and thrown away
while only the exit status was read.

**61.** Exercise 53: `checkbank` is invoked as the condition of an `if`, and `set -e` is disabled
inside functions and scripts used as conditions. Adding `set -e` to `checkbank` would change nothing
here at all, so the fix would look applied and not be.

**62.** Have the walk verify the tool, not just call it — a self-test line that runs the tool against
a bank known to be down and asserts a non-zero status:
```bash
if bin/checkbank __down__ >/dev/null 2>&1; then
  echo "$STATION_DATE deckcheck: SELF-TEST FAILED, checkbank reports success for a dead bank" \
    >> logs/deckcheck.log
  exit 1
fi
```

## Experiment

**63.**
```bash
retry() { local n=$1; shift; local i rc
  for (( i=1; i<=n; i++ )); do "$@" && return 0; rc=$?; done
  return "$rc"; }
```
`retry 3 bin/slowfail` takes three seconds and returns 5; `retry 3 bin/rc 0` returns 0 immediately.
Note `local rc` is declared separately — exercise 32.

**64.**
```bash
try() { "$@"; local rc=$?
  if [ "$rc" -eq 0 ]; then echo "ok"; else echo "FAILED (status $rc)"; fi
  return "$rc"; }
```
`local rc=$?` is safe here only because `$?` is not a command substitution; still, `local rc; rc=$?`
is the habit worth keeping. Gives 0, 2, 127, 126.

**65.** `try … 2>&1 | tee log` returns `tee`'s status, always 0. Either read `${PIPESTATUS[0]}`
immediately, or `set -o pipefail` around it. Lesson 04.

**66.** `bin/rc 130; echo $?` prints 130, identical to a SIGINT death. `$?` alone cannot distinguish
them — the byte is the same. You need `wait -n`'s reporting, a job-control message, or the tool's
own output to tell "exited with 130" from "killed by signal 2".

**67.**
```bash
start=$SECONDS
bin/slowfail; rc=$?
echo "slowfail took $(( SECONDS - start ))s, status $rc"
[ "$rc" -eq 0 ] || echo "slowfail: FAILED ($rc)"
exit "$rc"
```
1s, status 5. Capturing `$?` before the `echo` is the whole trick.

**68.** `true && false || echo C`: `C` prints. `if true; then false; else echo C; fi`: nothing
prints. Same three commands, different answer — exercise 22, now demonstrated.

## Stretch

**69.** Worth distinguishing: 2 usage (wrong bank name), 1 bank did not answer, 3 bank answered with
a fault, 4 could not reach the bus at all. Stop there. Beyond four or five, callers stop switching on
the number and start grepping the message, and you have paid the cost of a scheme nobody uses. Anything
above 125 is off limits — 126, 127 and 128+N are already spoken for.

**70.**
```bash
run() { "$@" >>/var/log/x 2>&1
  [ $? -eq 0 ] || echo "$(date): $* failed" >>/var/log/x
  return 0; }
```
Every caller sees success forever. It should have returned the status and *also* logged — logging and
reporting are not alternatives.

**71.** A backup job that logs "backup completed" after `tar` exits non-zero mid-archive; a health
dashboard that records "probe ran" rather than "probe passed". Both are true records of the wrong
predicate.

**72.**
```bash
[ "$errors" -gt 255 ] && errors=255
exit "$errors"
```
Better: stop reporting a count as a status and report a boolean — `exit $(( errors > 0 ))`, which is
`1` for `errors=3` and `0` for none. Put the count in the output, where it cannot wrap.

**73.**
- The script's last command was an `echo` and nobody wrote an `exit`.
- The failing command was a non-final pipeline stage and `pipefail` was off.
- The failing command was on the left of `&&` or under `!`.
- The status was captured into a `local v=$(…)` declaration and thrown away.
- The computed code was a multiple of 256.
- The failure was reported on fd 2 and the caller discarded fd 2.
- The tool never checked the thing the caller assumed it checked.
