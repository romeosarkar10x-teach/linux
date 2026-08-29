#!/usr/bin/env bash
# kestrel: manages-ownership
# setup.sh -- seeds /labs/10-users-groups-permissions/06-chown-chgrp-umask
#
# THE ANSWER KEY. Students are told not to open this.
#
# Teaches: chown, chgrp, chown user:group, --reference, -R and what it does
# to symlinks, why chown needs root and chgrp usually does not, and umask --
# where a new file's mode actually comes from.
#
# The lab deliberately owns files as root, as rhea (1001:crew) and as an
# orphaned uid, so ownership is visible without the student being able to
# hand files away. Ownership is set here on purpose; the harness is told not
# to chown -R the tree afterwards by the marker on line 2.
#
# Idempotent: removes its own tree first, creates nothing outside LAB.
set -euo pipefail

LAB="/labs/10-users-groups-permissions/06-chown-chgrp-umask"
rm -rf "$LAB"
mkdir -p "$LAB"/{intake,handoff,mixed,notes,scratch}
cd "$LAB"

# --- intake/ : files that arrived owned by the wrong people -----------------
# The student cannot fix these without sudo, and that is the lesson: chown is
# root's, and the reason is not arbitrary.
printf 'cycle 41 raw counts, delivered by the survey rig.\n' > intake/cycle-41.raw
printf 'cycle 42 raw counts, delivered by the survey rig.\n' > intake/cycle-42.raw
printf 'delivered but never claimed.\n'                      > intake/unclaimed.raw
chown root:root  intake/cycle-41.raw
chown 1001:1001  intake/cycle-42.raw     # rhea:crew
chown 4102:4102  intake/unclaimed.raw    # nobody -- no such account
chmod 644 intake/*.raw
chown cadet:crew intake
chmod 755 intake

# --- handoff/ : yours, and the group is the whole question ------------------
mkdir -p handoff
printf 'Shift handover, week 24. Yours to edit.\n'  > handoff/week-24.txt
printf 'Shift handover, week 25. Yours to edit.\n'  > handoff/week-25.txt
printf 'Rota. Everyone reads this one.\n'           > handoff/rota.txt
chown cadet:cadet handoff/week-24.txt handoff/week-25.txt handoff/rota.txt
chmod 640 handoff/*.txt
chown cadet:crew handoff
chmod 775 handoff

# --- mixed/ : a tree with three owners and a symlink out of it --------------
mkdir -p mixed/logs mixed/data
printf 'log line one\n' > mixed/logs/alpha.log
printf 'log line two\n' > mixed/logs/beta.log
printf 'value,count\na,1\n' > mixed/data/counts.csv
printf 'top-level readme for mixed/\n' > mixed/README
ln -sfn ../intake/cycle-41.raw mixed/data/raw-link
chown -h cadet:cadet mixed/data/raw-link
chown cadet:cadet mixed/README mixed/logs/alpha.log
chown cadet:ops   mixed/logs/beta.log
chown cadet:crew  mixed/data/counts.csv
chown cadet:cadet mixed mixed/logs mixed/data
chmod 755 mixed mixed/logs mixed/data
chmod 644 mixed/README mixed/logs/*.log mixed/data/counts.csv

# --- notes ------------------------------------------------------------------
cat > notes/ownership.txt <<'EOF'
Owner, group, and who may change them
-------------------------------------

Every file has exactly one owning user and exactly one owning group. They are
stored in the inode, next to the mode. `ls -l` prints them as columns 3 and 4;
`stat -c '%U %G %u %g %n' FILE` prints both the names and the numbers.

  chown USER FILE          change the owner
  chgrp GROUP FILE         change the group
  chown USER:GROUP FILE    change both at once
  chown :GROUP FILE        change the group only (same as chgrp)
  chown USER: FILE         change owner, and set group to that user's
                           login group

Who may do it:

  chown  root only. Not the owner. Not with any combination of the nine
         permission bits.
  chgrp  the file's owner may change the group, but only TO a group they are
         a member of. root may set any group.

Both take numeric ids as well as names, and a numeric id always works even
when no account has that number:

  chown 4102:4102 FILE

Useful options, the same ones chmod has:

  -R                recurse into directories
  --reference=FILE  copy the owner and group from another file
  -c                report only files that actually changed
  -h                act on a symlink itself instead of its target
  --no-dereference  the same thing, spelled out

Note the difference from chmod: chmod has no -h and always follows symlinks,
while chown defaults to following them and can be told not to.
EOF

cat > notes/umask.txt <<'EOF'
Where a new file's mode comes from
----------------------------------

Nothing creates a file with mode 777. The program asks for a mode, and the
kernel removes the bits set in the process's umask before creating it.

  requested mode  AND NOT  umask   =   actual mode

The conventional requests are:

  0666  for ordinary files      -- note: no execute, ever
  0777  for directories

With the usual umask of 022:

  files        0666 minus 022  =  0644
  directories  0777 minus 022  =  0755

That is the entire mechanism. It explains why `touch` never makes an
executable file: nobody asks for one. It is not the umask stripping x, it is
that 0666 has no x to begin with.

  umask           print the current mask
  umask -S        print it as symbolic permissions (what is ALLOWED)
  umask 077       set it -- files 0600, directories 0700
  umask 002       set it -- files 0664, directories 0775

The umask belongs to a process. Changing it in your shell affects that shell
and anything it starts afterwards. It does not change any existing file, and
it is not stored on any file. A subshell inherits it; the parent does not see
a subshell's change.

umask is a mask of bits to REMOVE. `umask 077` is restrictive. `umask 000` is
not. This is backwards from every other permission number you will meet and
it is the reason people get it wrong.
EOF

cat > notes/page.txt <<'EOF'
From: rhea
To: cadet
Re: intake

Three files landed in intake and one of them is owned by nobody. Not by me,
not by you -- by a number with no account behind it.

Do not guess who it belonged to. Find out what you can actually establish
from the file itself, and tell me that.

While you are there: everything you write into handoff comes out with the
wrong group. Work out why before you fix it one file at a time for a year.
EOF

printf 'Yours. Nothing here is owned by anybody else.\n' > scratch/README

# The marker on line 2 turns off the harness's blanket chown, so everything
# the student must be able to write is claimed for them here, explicitly.
chown cadet:crew "$LAB" notes scratch scratch/README
chown cadet:crew notes/ownership.txt notes/umask.txt notes/page.txt
chmod 755 "$LAB" notes scratch
chmod 644 notes/*.txt scratch/README

find . -exec touch -h -d '2187-06-19 09:00:00' {} +
touch -h -d '2186-11-30 14:05:00' notes/ownership.txt notes/umask.txt
touch -h -d '2187-06-19 07:40:00' notes/page.txt
touch -h -d '2187-06-18 23:12:00' intake/unclaimed.raw

echo "seeded $LAB"
