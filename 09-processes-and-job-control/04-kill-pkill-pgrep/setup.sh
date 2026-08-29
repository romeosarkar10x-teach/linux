#!/usr/bin/env bash
# setup.sh -- seeds /labs/09-processes-and-job-control/04-kill-pkill-pgrep
#
# THE ANSWER KEY. Students are told not to open this.
#
# Lesson: selecting the right processes, then signalling them. pgrep is the
# safe half and pkill is the same selection with a signal attached, which is
# why every exercise here runs pgrep first.
#
# The traps this lab is built around, all verified in the container:
#   * pgrep matches the COMMAND NAME (comm, 15 chars) unless you use -f.
#     bin/panelctl is a bash script, so its comm is "bash" -- pgrep panelctl
#     finds NOTHING and pgrep -f panelctl finds it. Students meet this first.
#   * -f matches the whole command line, INCLUDING YOUR OWN pgrep, when the
#     pattern is typed at a prompt inside a pipeline. Also matches the shell
#     running a wrapper script whose argv contains the pattern.
#   * the pattern is an ERE, not a glob. `pgrep -f 'panel*'` matches "pane",
#     "panel", "panells" -- and NOT what the student expects.
#   * two programs whose names differ only by a suffix: panel-mon and
#     panel-monitor. pkill -f panel-mon hits both. Anchors are the fix.
#   * pgrep -u / -U, -n / -o, -c, -l, -a, -x, -P and --signal.
#   * killall matches exactly, pkill matches substrings. Different defaults.
#
# Naming is the whole point: the decoys are named so that a lazy pattern is
# wrong in a way that is visible in one command and expensive in real life.
#
# Idempotent: removes its own tree first, creates nothing outside LAB.
set -euo pipefail

LAB="/labs/09-processes-and-job-control/04-kill-pkill-pgrep"
rm -rf "$LAB"
mkdir -p "$LAB"/{bin,notes,scratch}
cd "$LAB"

########## bin ##########

cat > bin/panel-mon <<'EOF'
#!/usr/bin/env bash
# panel-mon [seconds] -- pretends to watch a panel. Harmless.
secs=${1:-120}
echo "panel-mon: pid $$, watching panel 03, up for ${secs}s"
end=$(( $(date +%s) + secs ))
while [ "$(date +%s)" -lt "$end" ]; do sleep 1 & wait $!; done
echo "panel-mon: done"
EOF

cat > bin/panel-monitor <<'EOF'
#!/usr/bin/env bash
# panel-monitor [seconds] -- a DIFFERENT program. Its name contains the other
# one's name, which is the entire trap in this lesson.
secs=${1:-120}
echo "panel-monitor: pid $$, THIS IS THE ONE THAT MATTERS, up for ${secs}s"
end=$(( $(date +%s) + secs ))
while [ "$(date +%s)" -lt "$end" ]; do sleep 1 & wait $!; done
echo "panel-monitor: done"
EOF

cat > bin/panelctl <<'EOF'
#!/usr/bin/env bash
# panelctl [seconds] -- a bash script, so its comm is "bash", not "panelctl".
# `pgrep panelctl` finds nothing. `pgrep -f panelctl` finds it.
secs=${1:-120}
echo "panelctl: pid $$, comm is $(ps -p $$ -o comm=), args are what you would grep"
end=$(( $(date +%s) + secs ))
while [ "$(date +%s)" -lt "$end" ]; do sleep 1 & wait $!; done
echo "panelctl: done"
EOF

cat > bin/crew-report <<'EOF'
#!/usr/bin/env bash
# crew-report [seconds] -- innocent bystander with a common word in its name.
secs=${1:-120}
echo "crew-report: pid $$, nothing to do with panels, up for ${secs}s"
end=$(( $(date +%s) + secs ))
while [ "$(date +%s)" -lt "$end" ]; do sleep 1 & wait $!; done
echo "crew-report: done"
EOF

cat > bin/pane <<'EOF'
#!/usr/bin/env bash
# pane [seconds] -- four letters. `pgrep -f 'panel*'` matches this, because the
# pattern is a regular expression: "pane" followed by zero or more "l".
secs=${1:-120}
echo "pane: pid $$, four letters, up for ${secs}s"
end=$(( $(date +%s) + secs ))
while [ "$(date +%s)" -lt "$end" ]; do sleep 1 & wait $!; done
echo "pane: done"
EOF

cat > bin/fleet <<'EOF'
#!/usr/bin/env bash
# fleet N SECS -- starts N panel-mon children and waits. Gives you a parent
# with known children, for pgrep -P and for "kill the parent, what survives".
n=${1:-3}; secs=${2:-120}
echo "fleet: pid $$, starting $n children"
for i in $(seq 1 "$n"); do
  "$(dirname "$0")/panel-mon" "$secs" >/dev/null &
  echo "  child $i is $!"
done
wait
EOF

cat > bin/named <<'EOF'
#!/usr/bin/env bash
# named LABEL SECS -- a long command line with a label in it. The comm is bash
# for all of them; only -f can tell them apart.
label=${1:-alpha}; secs=${2:-120}
echo "named: pid $$, label=$label"
end=$(( $(date +%s) + secs ))
while [ "$(date +%s)" -lt "$end" ]; do sleep 1 & wait $!; done
EOF

cat > bin/deckwatch <<'EOF'
#!/usr/bin/env bash
# deckwatch [seconds] -- execs bin/panelwatch, which is a symlink to perl.
# So its comm is "panelwatch": not the script you typed, not bash. comm is the
# basename of the file that is actually executing.
secs=${1:-120}
echo "deckwatch: pid $$, about to exec panelwatch for ${secs}s"
exec "$(dirname "$0")/panelwatch" -e "sleep $secs"
EOF

cat > bin/deckwatch-long <<'EOF'
#!/usr/bin/env bash
# deckwatch-long [seconds] -- same, via a symlink whose name is 24 characters.
# comm is 15 characters wide. Watch what happens to the name.
secs=${1:-120}
echo "deckwatch-long: pid $$, exec'ing a very long program name"
exec "$(dirname "$0")/panel-watchdog-daemon" -e "sleep $secs"
EOF

chmod 755 bin/*

# Two symlinks to perl. Executing through them sets comm to the LINK's name,
# which is how this lab gets a process whose comm is not "bash".
ln -sf "$(command -v perl)" bin/panelwatch
ln -sf "$(command -v perl)" bin/panel-watchdog-daemon

########## notes ##########

cat > notes/select.txt <<'EOF'
Selecting processes before you signal them
------------------------------------------

pgrep prints pids. pkill sends a signal to the same set. They take the same
options, they use the same matching, and the ONLY difference is what happens to
the processes they find. So the rule is one line long:

  run pgrep first. Read the list. Then run the same thing as pkill.

If you cannot be bothered to run it twice, you have decided that a list of pids
you have not read is close enough to a list of pids you meant. It usually is.

What is being matched
---------------------

By default, pgrep matches the process NAME -- the `comm` field, which is the
executable's basename, truncated to 15 characters. Not the arguments. Not the
path.

  pgrep panel-mon        matches on comm
  pgrep -f panel-mon     matches on the full command line, /proc/<pid>/cmdline

comm is 15 characters wide and it is the basename of the file that is actually
executing -- which is not always the name you typed. Run bin/deckwatch and look:
it execs a symlink called panelwatch, so its comm is `panelwatch`. Run
bin/deckwatch-long and the comm is `panel-watchdog-`, cut off mid-word at 15.

This matters more than it sounds, because a shell script's comm is not the
script's name. It is `bash`. Every script on this station is invisible to a
plain pgrep and findable with -f.

The pattern is a regular expression
-----------------------------------

An ERE, the dialect from Chapter 6, not a glob. So:

  pgrep -f 'panel*'      "pane" then zero or more "l" -- matches "pane" too
  pgrep -f 'panel.*'     "panel" then anything
  pgrep -x panel-mon     the WHOLE name must match, nothing else
  pgrep -f 'bin/panel-mon 90$'  anchored at the end

Anchoring with -f is fiddly, because the string you are anchoring to is the WHOLE
command line and it usually starts with the interpreter: `bash bin/panel-mon 90`,
not `bin/panel-mon 90`. Print it with `pgrep -af` before you try to anchor to it.

And an unanchored pattern matches anywhere in the string, so `panel-mon` also
matches `panel-monitor`. There is no warning. There is no error. There is a
second process in the list, and if you piped it to pkill you have already
stopped it.

Useful options
--------------

  -l    print the name next to the pid
  -a    print the full command line next to the pid  (use this one)
  -c    count only
  -n    newest match only        -o   oldest match only
  -u    effective user id        -U   real user id
  -r    match by run state -- `-r Z` is every zombie, `-r S,R` every live one
  -x    exact match on the whole name (or whole line, with -f)
  -P    children of this ppid
  -v    invert -- everything that does NOT match

  pkill --signal HUP PATTERN     pick the signal. Default is TERM.
  pkill -e PATTERN               say what it killed. Always worth it.

killall is a different program with different defaults: it matches names
exactly, not as substrings, and it is not the same tool with a shorter name.
EOF

cat > notes/incident-log.txt <<'EOF'
deck 05 shift log -- extract

  2187-02-11  panel-mon restarted after deck power cycle. Fine.
  2187-03-02  "cleaned up stray panel processes" -- panel readings stopped for
              41 minutes and nobody could say why. See below.
  2187-03-02  found: panel-monitor had also been stopped. It was not stray.
              The command used was `pkill -f panel-mon`.
  2187-04-19  panel-mon restarted after deck power cycle. Fine.

Note added by the deck lead: the command that did it was not wrong about what it
matched. It matched exactly what it said it would.
EOF

cat > notes/page.txt <<'EOF'
From: rhea
To: whoever is on shift

Before you go anywhere near pkill on this deck, read the March entry in the
shift log. Forty-one minutes of no panel readings, and the person who did it is
a better admin than either of us.

I am not saying do not use it. I am saying show me the pgrep first.
EOF

########## scratch ##########
printf 'Yours. Nothing here is watched.\n' > scratch/README

########## timestamps ##########
find . -exec touch -h -d '2187-06-14 08:00:00' {} +
touch -d '2186-11-02 09:00:00' notes/select.txt
touch -d '2187-04-19 17:30:00' notes/incident-log.txt
touch -d '2187-06-14 08:40:00' notes/page.txt

echo "seeded $LAB"
