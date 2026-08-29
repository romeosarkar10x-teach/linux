#!/usr/bin/env bash
# setup.sh -- seeds /labs/09-processes-and-job-control/01-what-is-a-process
#
# THE ANSWER KEY. Students are told not to open this.
#
# Teaches: pid, ppid, the fork/exec model, ps -ef vs ps aux, pstree, and the
# fact that a process is a running thing while a program is a file.
#
# Nothing here runs in the background. Every process the student meets in this
# lesson is one they start themselves, so nothing survives a container restart
# and nothing needs cleaning up. Later lessons in this chapter do start jobs.
#
# Idempotent: removes its own tree first, creates nothing outside LAB.
set -euo pipefail

LAB="/labs/09-processes-and-job-control/01-what-is-a-process"
rm -rf "$LAB"
mkdir -p "$LAB"/{bin,notes,scratch}
cd "$LAB"

cat > bin/whoami-really <<'EOF'
#!/usr/bin/env bash
# whoami-really -- prints its own identity as the kernel sees it.
echo "pid ....... $$"
echo "ppid ...... $PPID"
echo "user ...... $(id -un)"
echo "argv0 ..... $0"
echo "cwd ....... $PWD"
EOF

cat > bin/sleeper <<'EOF'
#!/usr/bin/env bash
# sleeper [seconds] [label] -- sits still so you can look at it.
# Does NOT exec: the script stays alive as the parent of its own sleep, so you
# get a two-process family to look at instead of one process.
secs=${1:-60}
label=${2:-sleeper}
echo "$label: pid $$ ppid $PPID, sleeping ${secs}s" >&2
sleep "$secs"
EOF

cat > bin/nest <<'EOF'
#!/usr/bin/env bash
# nest N -- calls itself N times, then sleeps. Builds a chain of parents.
n=${1:-3}
echo "nest level $n: pid $$ ppid $PPID"
if [ "$n" -gt 1 ]; then
  exec "$0" $(( n - 1 ))
fi
sleep 45
EOF

cat > bin/forker <<'EOF'
#!/usr/bin/env bash
# forker N -- starts N background children and reports their pids, then waits.
n=${1:-3}
echo "forker: pid $$"
for i in $(seq 1 "$n"); do
  sleep 40 &
  echo "  child $i: pid $!"
done
wait
EOF

cat > bin/spin <<'EOF'
#!/usr/bin/env bash
# spin [seconds] -- burns CPU in a loop. Used in lesson 02.
# The deadline is computed from whole seconds, so a `spin 3` started part-way
# through a second runs for between 2 and 3 seconds. Close enough to watch;
# not close enough to measure anything with.
secs=${1:-10}
end=$(( $(date +%s) + secs ))
while [ "$(date +%s)" -lt "$end" ]; do
  for _ in $(seq 1 20000); do :; done
done
EOF

chmod 755 bin/whoami-really bin/sleeper bin/nest bin/forker bin/spin

cat > notes/process.txt <<'EOF'
A process, as the kernel keeps it
---------------------------------

A program is a file on disk. A process is one running instance of one. The same
program can be running six times; that is six processes and one file.

Every process has:

  pid    its number. Unique while it lives. Reused after it dies.
  ppid   the pid of the process that created it.
  user   the account whose permissions it runs with.
  cwd    a current directory of its own.
  env    a copy of its parent's environment, taken at start.
  argv   the command line it was started with.

New processes are made in two steps, and the two steps are separate on purpose:

  fork()  the process duplicates itself. Both copies continue from the same
          place, with the same open files. They differ in one thing: their pid.
  exec()  a process replaces its own program with a different one. Same pid,
          same ppid, new code. Nothing is created and nothing is destroyed.

So `ls` at a prompt is: the shell forks, and the copy execs /usr/bin/ls. The
shell itself is untouched. A builtin like `cd` does neither -- there is nothing
to run, so nothing is forked, which is why `cd` cannot be a separate program.

Process 1 is the exception: it is started by the kernel and has no parent it
forked from. Everything else on the station is a descendant of it.
EOF

cat > notes/ps.txt <<'EOF'
Reading ps
----------

ps has two argument styles, from two different Unix lineages, and both work:

  ps -ef        the "standard" style. UID PID PPID C STIME TTY TIME CMD
  ps aux        the "BSD" style. USER PID %CPU %MEM VSZ RSS TTY STAT START
                TIME COMMAND

Same processes, different columns. -ef gives you the parent; aux gives you the
resource numbers. Neither is more correct; pick by which column you need.

  ps            with no arguments: only your own processes, on your terminal.
                This is almost never what you want and it is the default.
  ps -e         every process.
  ps -o         choose your own columns, e.g. ps -eo pid,ppid,user,etime,comm
  ps -p PID     one process by number.
  pstree -p     the whole tree, with pids.

The CMD column is the process's argv, which is set by whoever started it and is
not necessarily the name of the program on disk.
EOF

cat > notes/page.txt <<'EOF'
From: rhea
To: whoever is on shift

Something on this station is awake at four in the morning and it is not me.

Load never drops to zero any more. I do not want a report, I want you to know
how to find out what is running before you need to. Learn it on something
harmless.
EOF

printf 'Yours. Start things here and let them run.\n' > scratch/README

find . -exec touch -h -d '2187-06-14 08:00:00' {} +
touch -d '2186-04-02 11:20:00' notes/process.txt notes/ps.txt
touch -d '2187-06-14 04:30:00' notes/page.txt

echo "seeded $LAB"
