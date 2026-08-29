#!/usr/bin/env bash
# setup.sh -- seeds /labs/09-processes-and-job-control/02-top-and-htop
#
# THE ANSWER KEY. Students are told not to open this.
#
# Teaches: reading top's five header lines, the difference between load average,
# %CPU and %MEM, sorting and filtering in top, top -b for scripts, and htop.
#
# The station-specific truth this lesson has to teach honestly: this container
# shares the host kernel, so top's load average, memory totals and CPU summary
# describe the HOST, while the process list describes the container. That is not
# a lab artefact -- it is true of every container anyone will ever hand them --
# so the lesson names it instead of pretending otherwise.
#
# Nothing here runs in the background. Load is produced by bin/load, which the
# student starts and which stops on its own.
#
# Idempotent: removes its own tree first, creates nothing outside LAB.
set -euo pipefail

LAB="/labs/09-processes-and-job-control/02-top-and-htop"
rm -rf "$LAB"
mkdir -p "$LAB"/{bin,notes,scratch}
cd "$LAB"

cat > bin/load <<'EOF'
#!/usr/bin/env bash
# load N SECONDS -- start N CPU burners for SECONDS seconds each, in parallel.
# Prints the pids so you can find them again. Waits, so Ctrl-C stops the lot.
n=${1:-1}
secs=${2:-30}
echo "load: pid $$ starting $n burner(s) for ${secs}s"
for i in $(seq 1 "$n"); do
  ( end=$(( $(date +%s) + secs ))
    while [ "$(date +%s)" -lt "$end" ]; do
      for _ in $(seq 1 20000); do :; done
    done ) &
  echo "  burner $i: pid $!"
done
wait
echo "load: done"
EOF

cat > bin/hog <<'EOF'
#!/usr/bin/env bash
# hog SECONDS [MB] -- holds MB megabytes of memory for SECONDS seconds.
# Built out of a bash string, which is a bad way to allocate memory and a very
# good way to watch RES climb in top.
secs=${1:-30}
mb=${2:-16}
echo "hog: pid $$ holding ${mb}MB for ${secs}s"
block=$(head -c $(( mb * 1024 * 1024 )) /dev/zero | tr '\0' 'x')
echo "hog: allocated ${#block} bytes"
sleep "$secs"
EOF

cat > bin/quiet <<'EOF'
#!/usr/bin/env bash
# quiet SECONDS -- old and idle. Large elapsed time, no CPU time at all.
secs=${1:-300}
echo "quiet: pid $$ idle for ${secs}s"
sleep "$secs"
EOF

chmod 755 bin/load bin/hog bin/quiet

cat > notes/top.txt <<'EOF'
Reading top's header
--------------------

Five lines, and they answer five different questions. Most people read the
process list and skip these, which is why most people misdiagnose load.

  line 1  uptime and load average
          Three numbers: the 1-, 5- and 15-minute averages of the number of
          processes that were runnable or waiting on disk. It is a QUEUE
          LENGTH, not a percentage. On a 24-core machine a load of 4 is quiet.
          On a 1-core machine a load of 4 means three things are waiting their
          turn at all times.
          Compare the three numbers to each other: 1min above 15min means the
          load is rising, below means it is falling. That comparison is usually
          worth more than any single value.

  line 2  Tasks: total, running, sleeping, stopped, zombie
          "running" is nearly always a small number. If total is large and
          running is 1, the machine is not busy, it is populated.

  line 3  %Cpu(s): us sy ni id wa hi si st
          us  user code            sy  kernel on your behalf
          ni  niced user code      id  idle
          wa  waiting for I/O      st  stolen by the hypervisor
          High wa with low us is a disk problem wearing a CPU problem's clothes.

  line 4  memory: total, free, used, buff/cache
  line 5  swap, and avail Mem
          "free" being small is normal and is not a problem. The kernel uses
          spare memory for cache and gives it back on demand. The number that
          means something is "avail Mem".

Then the process list, sorted by %CPU by default.

  PID USER PR NI VIRT RES SHR S %CPU %MEM TIME+ COMMAND

  VIRT  address space the process has mapped. Mostly meaningless on its own.
  RES   resident memory: actually in RAM, right now. This is the one to read.
  SHR   part of RES shared with other processes.
  S     state, same letters as ps: R running, S sleeping, Z zombie, T stopped.
  %CPU  share of ONE cpu, sampled since the last refresh. Can exceed 100 on a
        multi-core machine, because a process with four busy threads is using
        four cpus' worth.
  TIME+ total CPU time consumed since the process started.

%CPU and TIME+ answer different questions. %CPU is "is it busy now". TIME+ is
"how much of this machine has it eaten in total". A process at 0.3% %CPU with
nine hours of TIME+ has been quietly costing you something for a long time.
EOF

cat > notes/keys.txt <<'EOF'
top, interactively
------------------

  h or ?   help. Everything below is on that screen.
  q        quit.
  space    refresh now.
  d        change the refresh delay.

Sorting and filtering:
  P        sort by %CPU        M   sort by %MEM
  T        sort by TIME+       N   sort by PID
  R        reverse the sort
  u        filter to one user (blank clears it)
  o        filter by a field, e.g. COMMAND=sleep
  c        toggle COMMAND between the short name and the full command line
  V        forest view -- the tree, inside top
  1        expand the %Cpu line into one line per cpu
  H        show threads instead of processes
  W        write your current layout to ~/.config/procps/toprc

Acting:
  k        kill a process: it asks for a pid, then for a signal
  r        renice a process

From a script, do not use any of that. Use batch mode:

  top -b -n 1                 one snapshot, plain text, no terminal needed
  top -b -n 1 -o %MEM         snapshot sorted by memory
  top -b -n 1 -u cadet        one user
  top -b -n 1 -p 1234,1235    named pids only
  top -b -n 1 -w 200          wider output, so COMMAND is not truncated

htop is the same job with colour, mouse support and a pager. F6 sorts, F4
filters, F9 sends a signal, F5 draws the tree, and the three bars at the top
are per-cpu, memory and swap. It needs a terminal; it will not run in a pipe.
EOF

cat > notes/station.txt <<'EOF'
A caution about this station's numbers
--------------------------------------

Kestrel's habitat computing runs in a container on shared hardware. That has one
consequence you must know before you read top here, and it is true of nearly
every container you will ever be handed:

  the PROCESS LIST is the container's -- you see only our processes
  the LOAD AVERAGE, the MEMORY TOTALS and the %Cpu(s) LINE are the HOST's

So top can show you a load average of 4 while the container's own processes
account for none of it, and it can show tens of gigabytes of memory that nothing
here can use. The header describes a machine you are sharing. The list describes
the part of it you are responsible for.

Practically: on this station, judge our processes by their own %CPU, %MEM, RES
and TIME+ columns. Treat the load average as weather, not as evidence.
EOF

cat > notes/page.txt <<'EOF'
From: rhea
To: whoever is on shift

I looked at top. Load average 1.1 and there are six things running. Which of
those numbers is the one that means something? I have been told both.

Also somebody told me the memory is nearly full. It says free is small. Is that
bad or is that the thing everyone says is not bad.
EOF

printf 'Yours. Start load here and watch it.\n' > scratch/README

find . -exec touch -h -d '2187-06-14 08:00:00' {} +
touch -d '2186-04-02 11:20:00' notes/top.txt notes/keys.txt
touch -d '2186-11-30 09:00:00' notes/station.txt
touch -d '2187-06-14 06:10:00' notes/page.txt

echo "seeded $LAB"
