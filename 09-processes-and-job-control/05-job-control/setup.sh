#!/usr/bin/env bash
# setup.sh -- seeds /labs/09-processes-and-job-control/05-job-control
#
# THE ANSWER KEY. Students are told not to open this.
#
# Lesson: one shell, several jobs. &, Ctrl-Z, jobs, fg, bg, job specs, wait,
# and then the part that matters for the incident -- what survives logout.
#
# The incident in lesson 07 turns on a summariser started eight months ago that
# nothing schedules. The answer is that somebody typed `nohup ... &` once. This
# lesson is where that sentence stops being magic.
#
# Facts this lab is built on (all verified in the container):
#   * bash's huponexit is OFF by default, so a plain `&` job on THIS station
#     usually survives the shell exiting. Students are told the honest version:
#     it depends on a shopt and on how the shell dies, which is exactly why
#     nohup/setsid/disown exist -- they do not depend on it.
#   * a job stopped with Ctrl-Z is in state T and holds everything (lesson 03).
#   * disown removes the job from the shell's table: `jobs` forgets it, ps does
#     not. disown -h keeps it listed but exempts it from HUP.
#   * nohup writes to nohup.out ONLY when stdout is a terminal, and says so on
#     stderr. Redirect and there is no nohup.out at all.
#   * setsid makes a new session, so the process has no controlling terminal
#     and ppid becomes 1 immediately. That is the shape of the incident.
#
# bin/talker prints to BOTH streams on a timer, so background output landing in
# the middle of the student's prompt is something they experience, not read.
#
# Idempotent: removes its own tree first, creates nothing outside LAB.
set -euo pipefail

LAB="/labs/09-processes-and-job-control/05-job-control"
rm -rf "$LAB"
mkdir -p "$LAB"/{bin,notes,scratch}
cd "$LAB"

########## bin ##########

cat > bin/talker <<'EOF'
#!/usr/bin/env bash
# talker [seconds] [label] -- writes to stdout AND stderr on a timer, so you
# can watch a background job interrupt your prompt.
secs=${1:-60}; label=${2:-talker}
i=0
end=$(( $(date +%s) + secs ))
while [ "$(date +%s)" -lt "$end" ]; do
  i=$(( i + 1 ))
  echo "$label: tick $i (stdout)"
  echo "$label: tick $i (stderr)" >&2
  sleep 3 & wait $!
done
echo "$label: finished"
EOF

cat > bin/quiet-work <<'EOF'
#!/usr/bin/env bash
# quiet-work [seconds] -- says nothing until it is done. The kind of job you
# background and forget, which is the kind this chapter is about.
secs=${1:-60}
end=$(( $(date +%s) + secs ))
while [ "$(date +%s)" -lt "$end" ]; do sleep 1 & wait $!; done
echo "quiet-work: finished after ${secs}s"
EOF

cat > bin/reader <<'EOF'
#!/usr/bin/env bash
# reader -- wants a line from standard input. Background it and watch what
# happens to a job that tries to read from a terminal it does not own.
echo "reader: pid $$, waiting for a line"
read -r line
echo "reader: got [$line]"
EOF

cat > bin/counter <<'EOF'
#!/usr/bin/env bash
# counter [seconds] [file] -- appends a line per second to a file, so you can
# tell from outside whether it is running, stopped, or gone.
secs=${1:-120}; out=${2:-scratch/counter.log}
i=0
end=$(( $(date +%s) + secs ))
while [ "$(date +%s)" -lt "$end" ]; do
  i=$(( i + 1 ))
  printf '%s tick %d pid %d\n' "$(date +%H:%M:%S)" "$i" "$$" >> "$out"
  sleep 1 & wait $!
done
EOF

cat > bin/hupper <<'EOF'
#!/usr/bin/env bash
# hupper [seconds] [file] -- records the fact that it got HUP, then exits.
# Gives you evidence after the shell that started it is gone.
secs=${1:-300}; out=${2:-scratch/hupper.log}
echo "hupper: pid $$ started $(date +%H:%M:%S), logging to $out" | tee -a "$out"
trap 'echo "hupper: pid $$ caught HUP at $(date +%H:%M:%S)" >> "$out"; exit 129' HUP
end=$(( $(date +%s) + secs ))
while [ "$(date +%s)" -lt "$end" ]; do sleep 1 & wait $!; done
echo "hupper: pid $$ finished normally" >> "$out"
EOF

chmod 755 bin/*

########## notes ##########

cat > notes/jobs.txt <<'EOF'
Job control -- one shell, several things
-----------------------------------------

A JOB is the shell's word for a pipeline you started. Not a process: `a | b | c`
is three processes and one job. The shell numbers jobs per shell, starting at 1,
and reuses the numbers as jobs finish.

  cmd &            start it in the background
  Ctrl-Z           stop the foreground job (sends TSTP)
  jobs             list this shell's jobs
  jobs -l          ... with pids
  fg %2            bring job 2 to the foreground
  bg %2            let stopped job 2 continue, in the background
  kill %2          signal a job by job spec
  wait             wait for all of them
  wait %2          wait for one

Job specs, because %2 is not the only one:

  %2      job number 2
  %%  %+  the current job (the one fg with no argument picks)
  %-      the previous job
  %talk   the job whose command STARTS WITH "talk"
  %?alk   the job whose command CONTAINS "alk"

If a prefix matches more than one job the shell refuses: `ambiguous job spec`.
And the prefix is matched against the command AS YOU TYPED IT, so a job started
as `bin/quiet-work` answers to `%bin`, not to `%quiet` -- and `%bin` is ambiguous
the moment you have two jobs out of the same directory.

`jobs` marks the current job with + and the previous with -. Those two move as
jobs start and finish, which is why `fg` with no argument is convenient and
`fg %2` is what you write in anything you will read again.

Three states, in the jobs output: Running, Stopped, Done. A Stopped job is state
T from lesson 03 -- it is holding its memory, its files and its terminal.

Background output
-----------------

A background job still has your terminal. It writes into whatever you are typing
and there is no rule that says it will wait for a good moment. What it CANNOT do
is read: a background job that tries to read from the terminal is stopped by the
kernel with SIGTTIN, and shows up as `Stopped (tty input)`.
EOF

cat > notes/survival.txt <<'EOF'
What survives the shell going away
-----------------------------------

When a shell that owns jobs exits, the honest answer is "it depends", and the
whole reason nohup, setsid and disown exist is to stop it depending.

The rules, in the order they apply:

1. If the terminal itself goes away -- the connection drops, the window closes --
   the kernel sends SIGHUP to the session's foreground process group. HUP's
   default action is terminate.

2. When bash EXITS deliberately, it sends SIGHUP to its jobs only if the
   `huponexit` shell option is set AND the shell is an interactive LOGIN shell.
   Both halves are load-bearing. Check the option:

     shopt huponexit

   On this station it is off, so a plain `cmd &` survives `exit`. Turn it on in
   a non-login interactive shell and the job STILL survives, because the option
   is only consulted by a login shell. Turn it on in a login shell and the job
   dies. You can prove all three of those in this lab, and you should, because
   "it depends on a shell option and on how you logged in" is not a thing to
   build on. Rule 1 applies regardless of the option.

3. Anything that has arranged not to receive HUP survives both:

     nohup cmd &      run with HUP ignored -- SigIgn in /proc/<pid>/status gains
                      bit 1. Also redirects stdout to nohup.out
                      IF stdout is a terminal, and says so on stderr.
     setsid cmd       run in a NEW SESSION with no controlling terminal. Nothing
                      can HUP it, because it is not attached to anything.
     disown %1        remove the job from this shell's table. The shell will not
                      HUP what it does not remember it has.
     disown -h %1     keep it listed, but exempt it from HUP.

The difference that matters: nohup and disown change what happens on HUP. setsid
changes what the process IS -- a new session, ppid 1, no terminal, invisible to
`jobs` in any shell because no shell owns it.

A process started with setsid, or with nohup and then abandoned, has no record
of who started it or when, beyond its own start time. It does not appear in any
schedule, because nothing scheduled it. It appears in `ps`, and nowhere else.
EOF

cat > notes/page.txt <<'EOF'
From: rhea
To: whoever is on shift

Two questions, because I have been arguing with the handbook.

One: I start something with & and then I log out. Is it still running? The
handbook says no. Last Tuesday it was.

Two: if it IS still running, how would anybody know it was me who started it?

I am asking the second one for a reason and I would rather you told me the
answer is "nobody would" than have you tell me it does not matter.
EOF

########## scratch ##########
printf 'Yours. bin/counter and bin/hupper write here.\n' > scratch/README

########## timestamps ##########
find . -exec touch -h -d '2187-06-14 09:00:00' {} +
touch -d '2186-09-30 14:00:00' notes/jobs.txt notes/survival.txt
touch -d '2187-06-14 09:35:00' notes/page.txt

echo "seeded $LAB"
