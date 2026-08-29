#!/usr/bin/env bash
# setup.sh -- seeds /labs/09-processes-and-job-control/03-signals
#
# THE ANSWER KEY. Students are told not to open this.
#
# Teaches: what a signal is, the numbers and names, `kill -l`, trap, the
# difference between TERM (askable, catchable), KILL (not askable, not
# catchable), HUP, INT, QUIT and the STOP/CONT pair; exit status 128+N; what
# happens to children when a parent dies; and zombies.
#
# Station-specific truth this lesson must not hide: pid 1 in this container is
# `sleep infinity`, which is not an init and never reaps. So an orphan that
# exits stays a zombie forever, which is exactly the wrong-pid-1 problem real
# containers have. bin/orphan-demo makes that visible on purpose.
#
# Nothing runs in the background from setup. Every process is student-started.
#
# Idempotent: removes its own tree first, creates nothing outside LAB.
set -euo pipefail

LAB="/labs/09-processes-and-job-control/03-signals"
rm -rf "$LAB"
mkdir -p "$LAB"/{bin,notes,scratch}
cd "$LAB"

cat > bin/catcher <<'EOF'
#!/usr/bin/env bash
# catcher [seconds] -- catches TERM, INT and HUP and says so, then keeps going.
# Cannot catch KILL. Nothing can.
secs=${1:-120}
trap 'echo "catcher: caught TERM, ignoring it"' TERM
trap 'echo "catcher: caught INT, ignoring it"'  INT
trap 'echo "catcher: caught HUP, ignoring it"'  HUP
echo "catcher: pid $$ up for ${secs}s. Try TERM, INT, HUP. Then try KILL."
end=$(( $(date +%s) + secs ))
while [ "$(date +%s)" -lt "$end" ]; do
  sleep 1 &
  wait $!
done
echo "catcher: timer expired, exiting cleanly"
EOF

cat > bin/tidy <<'EOF'
#!/usr/bin/env bash
# tidy [seconds] -- the polite kind. Catches TERM, cleans up, exits.
# This is what TERM is FOR and why you send it first.
secs=${1:-120}
work="$PWD/scratch/tidy-$$.work"
cleanup() {
  echo "tidy: caught TERM, removing $work and exiting"
  rm -f "$work"
  exit 0
}
trap cleanup TERM
: > "$work"
echo "tidy: pid $$ working, state file is $work"
end=$(( $(date +%s) + secs ))
while [ "$(date +%s)" -lt "$end" ]; do
  echo "$(date +%s)" >> "$work"
  sleep 1 &
  wait $!
done
rm -f "$work"
echo "tidy: finished normally"
EOF

cat > bin/plain <<'EOF'
#!/usr/bin/env bash
# plain [seconds] -- no traps at all. The default behaviour, for comparison.
secs=${1:-120}
echo "plain: pid $$, no traps, up for ${secs}s"
sleep "$secs"
echo "plain: finished normally"
EOF

cat > bin/orphan-demo <<'EOF'
#!/usr/bin/env bash
# orphan-demo [seconds] -- starts a child that outlives it, then exits at once.
# Watch the child's ppid change to 1. Then watch what happens when the child
# itself exits, on a station whose pid 1 does not reap anything.
secs=${1:-25}
echo "orphan-demo: pid $$"
(
  # $$ inside a subshell is still the PARENT's pid. BASHPID is this process.
  echo "  child: pid $BASHPID ppid $PPID"
  sleep "$secs"
  echo "  child: exiting after ${secs}s"
) &
echo "orphan-demo: child is $!, and I am leaving now"
EOF

cat > bin/signal-report <<'EOF'
#!/usr/bin/env bash
# signal-report CMD... -- runs a command, then reports how it ended.
"$@"
rc=$?
if [ "$rc" -gt 128 ] && [ "$rc" -lt 192 ]; then
  n=$(( rc - 128 ))
  printf 'exit %d = 128 + %d = killed by SIG%s\n' "$rc" "$n" "$(kill -l "$n")"
else
  printf 'exit %d (not a signal death)\n' "$rc"
fi
EOF

chmod 755 bin/catcher bin/tidy bin/plain bin/orphan-demo bin/signal-report

cat > notes/signals.txt <<'EOF'
Signals
-------

A signal is a one-bit message the kernel delivers to a process: a number, no
payload, no reply. You cannot send data with one and you cannot get an answer
back. Everything a signal can express is in the choice of which one you send.

For each signal a process has one of three dispositions:

  default   the kernel's built-in action -- usually terminate, sometimes stop,
            sometimes nothing at all
  ignored   delivered and discarded
  handled   the process installed a handler and runs it instead

Two signals cannot be handled or ignored by anybody, ever: KILL (9) and STOP
(19). The kernel acts on those without consulting the process. That is the whole
reason they exist.

The ones you will use:

  TERM 15  "please stop". The default for `kill`. Catchable, so a program can
           finish a write, remove a lock file and exit tidily. This is the one
           you send first, always.
  INT   2  what Ctrl-C sends. Also catchable. Conventionally means "the person
           at the keyboard changed their mind".
  HUP   1  originally "the terminal went away". Now, by convention, many
           long-running programs treat it as "re-read your configuration".
           Convention only -- the kernel attaches no such meaning.
  QUIT  3  what Ctrl-\ sends. Terminates AND writes a core dump, if enabled.
  KILL  9  not deliverable to a handler. The process does not run any code. It
           does not clean up, close files, flush buffers or remove locks. There
           is no "please" in this signal and no way to be polite about it.
  STOP 19  freeze. Not catchable. The process stays in memory, holding
           everything it holds, doing nothing.
  CONT 18  unfreeze.
  TSTP 20  what Ctrl-Z sends: like STOP, but catchable, so a program can save
           its screen state first.
  CHLD 17  "a child of yours changed state". Default is to ignore it. This is
           how a parent learns it has something to reap.
  USR1 10  and USR2 12: no kernel meaning at all. Reserved for whatever a
  USR2 12  program decides. Useful precisely because they mean nothing.
  PIPE 13  "you wrote to a pipe nobody is reading". Chapter 8's status 141.

`kill -l` lists them all. `kill -l 15` gives the name for a number; `kill -l TERM`
gives the number for a name.

How a death is reported
-----------------------

A process killed by signal N exits with status 128+N. So:

  TERM 15 -> 143      INT 2 -> 130      KILL 9 -> 137      QUIT 3 -> 131

You met 130 and 143 in Chapter 8 without being told where they came from.

The order to try
----------------

  1  TERM. Wait. Actually wait -- most programs take a moment to clean up.
  2  TERM again, if you believe it was missed.
  3  KILL, and accept that you have lost whatever it was in the middle of.

Reaching for KILL first is not decisive, it is expensive. It skips the code the
author wrote for exactly this moment.

The disposition you did not choose
----------------------------------

A process inherits its dispositions from its parent, and there is one case that
surprises everybody. When a NON-INTERACTIVE shell starts a command in the
background, POSIX requires it to set SIGINT and SIGQUIT to IGNORED in that child
-- so that a Ctrl-C aimed at the script does not also flatten the background job.

And a shell will not install a trap for a signal it inherited as ignored. It
accepts the `trap` line without complaint and does nothing with it.

So a script that traps INT works when you run it from your prompt, and silently
does not when a wrapper backgrounds it. You can see it rather than argue about
it -- every process publishes its masks:

  grep -E 'SigIgn|SigCgt' /proc/<pid>/status

Both are hexadecimal bitmasks, one bit per signal, bit 0 = signal 1.
SigIgn 0000000000000006 is bits 1 and 2: signals 2 and 3, INT and QUIT.

And one signal has no disposition anywhere: pid 1. The kernel will not deliver a
signal to pid 1 unless pid 1 installed a handler for it. `kill -TERM 1` returns 0
and does nothing at all.
EOF

cat > notes/family.txt <<'EOF'
Signals and families
--------------------

A signal goes to the process you name. Not to its children.

Kill a parent and its children keep running. They are re-parented -- their ppid
becomes 1 -- and they carry on doing whatever they were doing, now with no one
watching. This surprises everybody once, and it is the reason "I killed it" and
"it stopped" are different claims.

To signal a family you have to say so:
  kill -TERM -PGID     a negative number means the whole process group
  pkill -P PPID        every child of that parent
Both are 09/04.

Zombies
-------

When a process exits, the kernel keeps one thing: its exit status. It is waiting
for the parent to ask, which the parent does with wait(). Until the parent asks,
the dead process has no memory, no cpu, no open files -- and one line in the
process table, marked Z, `<defunct>`.

A zombie cannot be killed. It is already dead. Signals to it go nowhere. The way
to clear one is to make its parent reap it, or to end the parent -- at which
point the zombie is re-parented to pid 1, and pid 1's job is to reap orphans it
never asked for.

On this station, that last step does not happen. Our pid 1 is `sleep infinity`,
a placeholder that keeps the container alive and does nothing else. It never
calls wait(). So an orphan that exits here stays a zombie until the container
restarts.

That is not a fault in the lab. It is the normal behaviour of a container whose
pid 1 was chosen for convenience, and it is why you will meet machines with
thousands of zombies and a perfectly healthy load average. A few zombies cost
nothing but a row each. Enough of them exhaust the pid table.
EOF

cat > notes/page.txt <<'EOF'
From: rhea
To: whoever is on shift

I have been told to use kill -9 by three different people and told not to by two
others. I would like to know which of them is wrong before I use it on anything
that writes to the panel records.

What I was actually told, as close to their words as I can get it:

  "-9 is just the strong version of kill, use it when you mean it"
  "-9 always works"
  "-9 leaves things behind"
  "never use -9"
  "if you have to use -9, something else is wrong"

Two of those cannot both be right and I suspect more than two are wrong. I do not
want a rule, I want to know what the machine actually does.
EOF

printf 'Yours. bin/tidy writes its state file here.\n' > scratch/README

find . -exec touch -h -d '2187-06-14 08:00:00' {} +
touch -d '2186-04-02 11:20:00' notes/signals.txt notes/family.txt
touch -d '2187-06-14 07:05:00' notes/page.txt

echo "seeded $LAB"
