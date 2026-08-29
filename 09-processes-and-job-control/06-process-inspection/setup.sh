#!/usr/bin/env bash
# setup.sh -- seeds /labs/09-processes-and-job-control/06-process-inspection
#
# THE ANSWER KEY. Students are told not to open this.
#
# The hinge lesson. Everything before this asked "which processes are there";
# this asks "what is THIS process actually doing", and the answer comes from
# /proc, which is where lesson 07's flag lives.
#
# The load-bearing facts, all verified in the container:
#   * /proc/<pid>/cmdline is NUL-separated, so `cat` runs the arguments together
#     and `tr '\0' '\n'` is the read. This is the difference between ps output
#     (already mangled) and the truth.
#   * /proc/<pid>/environ is mode -r-------- : owner only. That is exactly why
#     incident 09 needs sudo, and why killing the process destroys the evidence
#     -- there is no other copy of a process's environment anywhere.
#   * /proc/<pid>/exe, cwd, root are symlinks that resolve even for a deleted
#     binary. exe names the INTERPRETER, not the script: a bash script's exe is
#     /usr/bin/bash, and `sleep`'s exe on this station is
#     /nix/store/...-coreutils-full-9.11/bin/coreutils -- a multicall binary.
#     So exe does not name the command you typed, in two different ways.
#   * /proc/<pid>/fd/N shows what a process has open, including pipes and
#     deleted files. A deleted-but-open file is recoverable through fd; that is
#     bin/holdopen's job.
#   * renice UP is allowed to a normal user, renice back DOWN is not:
#     "renice: failed to set priority ...: Permission denied". One way ratchet.
#   * `nice -n -5 cmd` as a normal user prints "nice: cannot set niceness:
#     Permission denied" AND RUNS THE COMMAND ANYWAY, exit status of the
#     command (0). A student who checks $? learns nothing. Exercise 45.
#
# bin/wanderer changes its own cwd while running, so /proc/<pid>/cwd is a live
# reading and not a start-time record. bin/holdopen deletes a file it is still
# writing. bin/tagged carries a distinctive environment variable, which is the
# rehearsal for incident 09.
#
# Idempotent: removes its own tree first, creates nothing outside LAB.
set -euo pipefail

LAB="/labs/09-processes-and-job-control/06-process-inspection"
rm -rf "$LAB"
mkdir -p "$LAB"/{bin,data,data/archive,notes,scratch}
cd "$LAB"

########## bin ##########

cat > bin/tagged <<'EOF'
#!/usr/bin/env bash
# tagged [seconds] -- ordinary sleeper with an unusual environment. Start it
# with extra variables set and read them back out of /proc/<pid>/environ.
secs=${1:-300}
end=$(( $(date +%s) + secs ))
while [ "$(date +%s)" -lt "$end" ]; do sleep 2 & wait $!; done
EOF

cat > bin/wanderer <<'EOF'
#!/usr/bin/env bash
# wanderer [seconds] -- changes its working directory every few seconds, so
# /proc/<pid>/cwd is a reading of NOW and not a record of where it started.
secs=${1:-300}
end=$(( $(date +%s) + secs ))
base=$(cd "$(dirname "$0")/.." && pwd)
while [ "$(date +%s)" -lt "$end" ]; do
  for d in data data/archive notes scratch; do
    cd "$base/$d" || exit 1
    sleep 4 & wait $!
    [ "$(date +%s)" -lt "$end" ] || break
  done
done
EOF

cat > bin/holdopen <<'EOF'
#!/usr/bin/env bash
# holdopen [seconds] -- creates a file, opens it for writing on fd 9, DELETES
# the name, and keeps writing. The bytes are still there; the only handle left
# in the universe is /proc/<pid>/fd/9.
secs=${1:-300}
f="${2:-scratch/vanishing.log}"
exec 9> "$f"
rm -f "$f"
i=0
end=$(( $(date +%s) + secs ))
while [ "$(date +%s)" -lt "$end" ]; do
  i=$(( i + 1 ))
  printf 'line %d written at %s by pid %d\n' "$i" "$(date +%H:%M:%S)" "$$" >&9
  sleep 1 & wait $!
done
EOF

cat > bin/reader-of <<'EOF'
#!/usr/bin/env bash
# reader-of FILE [seconds] -- holds FILE open for reading and does nothing
# else. For fuser and lsof: who has this file open?
f=$1; secs=${2:-300}
exec 7< "$f"
end=$(( $(date +%s) + secs ))
while [ "$(date +%s)" -lt "$end" ]; do sleep 2 & wait $!; done
EOF

cat > bin/spin <<'EOF'
#!/usr/bin/env bash
# spin [seconds] -- burns CPU on purpose, for nice and renice. Nothing else in
# this course does real work; this does, which is why it is the only script in
# the lab you should not leave running.
secs=${1:-30}
end=$(( $(date +%s) + secs ))
n=0
while [ "$(date +%s)" -lt "$end" ]; do n=$(( n + 1 )); done
echo "spin: $n iterations"
EOF

chmod 755 bin/*

########## data ##########

cat > data/panel-readings.csv <<'EOF'
ts,panel,reading,status
03:00:00,P-01,0.318,nominal
03:00:15,P-02,0.301,nominal
03:00:30,P-03,0.344,nominal
03:00:45,P-01,0.322,nominal
03:01:00,P-02,0.298,nominal
EOF

cat > data/archive/panel-readings-2187-06-01.csv <<'EOF'
ts,panel,reading,status
03:00:00,P-01,0.311,nominal
03:00:15,P-02,0.309,nominal
EOF

########## notes ##########

cat > notes/proc.txt <<'EOF'
/proc, and what a process will tell you about itself
-----------------------------------------------------

/proc/<pid>/ is not a directory of files. It is the kernel answering questions,
formatted as files. Every read is a fresh reading. Sizes are 0 and mean nothing.

  cmdline   the argv it was started with, NUL-separated.
              tr '\0' '\n' < /proc/PID/cmdline
            `cat` will run the arguments together with no separator, and that
            is not a bug, it is you reading NULs on a terminal.
  comm      the 15-character name the kernel calls it. See lesson 04.
  environ   the environment it was GIVEN, NUL-separated, same read as cmdline.
            Mode -r-------- : only the owner (and root) may read it.
  exe       symlink to the binary being executed. Note "binary": a shell
            script's exe is the SHELL, and on this station `sleep`'s exe is a
            multicall coreutils binary, not a file called sleep. It resolves
            even if the binary was deleted -- you get "-> /path (deleted)".
  cwd       symlink to its CURRENT working directory. Live, not start-time.
  root      symlink to its root directory. Usually /.
  fd/       one symlink per open file descriptor, numbered. Pipes, sockets,
            terminals and deleted files all show up here.
  status    human-readable summary: state, Pid, PPid, Uid, Gid, Groups,
            the signal masks from lesson 03, memory.
  stat      the same information as one machine-readable line. Field 3 is the
            state letter, field 4 is ppid, field 22 is start time in clock
            ticks since boot.
  limits    the resource limits it is running under.

Two things follow from all of this, and both matter more than the syntax:

1. None of it is written down anywhere else. A process's environment exists in
   that process and nowhere on disk. Kill the process and it is gone -- not
   deleted, never stored.
2. It is all readable while the process runs, by anybody with the right uid.
   "I could not find out what it was doing" and "I killed it first" are usually
   the same sentence.
EOF

cat > notes/open-files.txt <<'EOF'
Open files: lsof and fuser
---------------------------

  lsof -p PID          everything this process has open
  lsof PATH            every process that has this path open
  lsof +D DIR          ... anything under this directory (walks it, slow)
  lsof -u USER         everything this user has open
  lsof -c NAME         by command name

  fuser PATH           pids using this path, terse
  fuser -v PATH        the same with a readable table
  fuser -m MOUNT       everything using a filesystem

The FD column in lsof output is not only numbers:
  cwd  current directory        rtd  root directory
  txt  the program text itself  mem  a mapped file
  0u 1w 2u ...  a real descriptor, with r/w/u for the mode

The case that makes this worth knowing: a file that has been DELETED but is
still open. The name is gone from the directory; the bytes are not freed until
the last descriptor closes. `du` will not find it, `find` will not find it, and
`df` will insist the space is in use. lsof shows it as "(deleted)", and
/proc/PID/fd/N is a working handle to the contents.
EOF

cat > notes/priority.txt <<'EOF'
Niceness
--------

Every process has a nice value from -20 (greedy) to 19 (generous). Higher nice
means LOWER priority -- the name is from the process's point of view: a nice
process yields. Default is 0.

  nice -n 10 cmd       start cmd with nice 10
  renice 10 -p PID     change a running process's nice value
  renice 5 -u USER     everything owned by a user
  ps -o pid,ni,args    read it back

The ratchet: a normal user may only raise niceness, never lower it -- not even
back to where it started. `renice 0` on a process you niced to 5 yourself:

  renice: failed to set priority for 10451 (process ID): Permission denied

Only root goes down. Decide before you type.

And the trap that will bite you once: `nice -n -5 cmd` as a normal user prints
a permission error AND RUNS THE COMMAND ANYWAY, at the nice value it already
had, exiting with the command's own status. The error is on stderr and the
exit status is the command's. If you are scripting this, check the nice value
afterwards -- do not check $?.

Niceness is CPU only. It does nothing about disk (that is ionice) and nothing
about memory. Renicing a process that is slow because it is waiting on I/O
changes nothing at all, which is most of the times people reach for it.
EOF

cat > notes/page.txt <<'EOF'
From: rhea
To: whoever is on shift

Related to my last page and I am not dropping it.

There is something on this station using CPU that I did not start. I can see it
in top. What I want to know is what it thinks it is doing -- which directory,
which files, what it was told when it started. Not what it is called. I already
know what it is called and the name is useless.

Also, before somebody suggests it: do not just kill it. If you kill it, I lose
the only copy of the answer, and then we are exactly where we were except with
one fewer process to ask.
EOF

########## scratch ##########
printf 'Yours. bin/holdopen writes here, briefly.\n' > scratch/README

########## timestamps ##########
find . -exec touch -h -d '2187-06-14 09:00:00' {} +
touch -d '2186-11-02 10:00:00' notes/proc.txt notes/open-files.txt notes/priority.txt
touch -d '2187-06-14 10:05:00' notes/page.txt
touch -d '2187-06-01 06:00:00' data/archive/panel-readings-2187-06-01.csv

echo "seeded $LAB"
