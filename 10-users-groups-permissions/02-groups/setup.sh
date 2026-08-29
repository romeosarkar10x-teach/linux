#!/usr/bin/env bash
# setup.sh -- seeds /labs/10-users-groups-permissions/02-groups
# kestrel: manages-ownership
#
# THE ANSWER KEY. Students are told not to open this.
#
# Teaches: /etc/group, primary versus supplementary groups, groups/id -nG,
# usermod -aG, the re-login gotcha, newgrp and sg, gpasswd -d, and the
# `usermod -G` foot-gun.
#
# This setup TOUCHES THE ACCOUNT DATABASE, which no earlier lesson does:
#   * it removes cadet from `engineering` if a previous run or a previous
#     lesson left them in it, so the lesson's central demonstration -- being
#     denied, then joining, then still being denied in the same shell -- works
#     on a re-seed.
#   * it creates a throwaway account `probe` (no password, nologin) whose only
#     purpose is to be the victim of exercise 40, where `usermod -G` without
#     `-a` destroys a membership list. The student must NOT practise that on
#     their own account: cadet is in `sudo`, and wiping that membership ends
#     the course until somebody with docker access fixes it. exercises.md,
#     help.md and validation.md all say so.
#
# The engineering tree is mode 0640 / 0750 owned rhea:engineering. cadet is in
# crew, not engineering, so it is unreadable until they join -- and it stays
# unreadable in the shell they were already in, which is the lesson.
#
# Idempotent: removes its own tree, resets both group memberships, recreates
# `probe` from scratch. Creates nothing outside LAB and those two accounts.
set -euo pipefail

LAB="/labs/10-users-groups-permissions/02-groups"

########## account state this lesson depends on ##########

gpasswd -d cadet engineering >/dev/null 2>&1 || true
userdel -r probe >/dev/null 2>&1 || true
groupdel probe >/dev/null 2>&1 || true
groupadd -f hydroponics
useradd -M -s /usr/sbin/nologin -G crew,ops,hydroponics probe
passwd -l probe >/dev/null

rm -rf "$LAB"
mkdir -p "$LAB"/{shared,engineering,notes,roster,scratch}
cd "$LAB"

########## the crew-shared tree: you are in this group ##########

cat > shared/handover.txt <<'EOF'
Deck 05 handover board. Anybody in `crew` may read and write this file.

  2187-06-12  panel 07 reseated. Rebuild times still climbing.
  2187-06-13  strain export taken for the week. Nothing unusual in it.
  2187-06-14  cadet aboard. Berth 12. Access: crew.
EOF

cat > shared/rota.txt <<'EOF'
Deck 05 rota, week of 2187-06-14

  night   cass
  early   novak
  late    mbeki
  relief  (the cadet, supervised)
EOF

########## the engineering tree: you are not in this group ##########

cat > engineering/strain-export-2187-06-13.csv <<'EOF'
seq,time,sampler,raw,reported
0001,03:00:00,1,0.287,0.287
0002,03:00:15,2,0.294,0.294
0003,03:00:30,3,0.301,0.301
0004,03:00:45,4,0.312,0.312
0005,03:01:00,1,0.409,0.400
0006,03:01:15,2,0.298,0.298
EOF

cat > engineering/README <<'EOF'
Engineering working data. Group `engineering` only.

This is not secret. It is restricted because it is raw: the numbers in here have
not been through the summariser and reading them without knowing that is how
people end up reporting a fault that does not exist.

If you need access, ask. The request is routine and it is still a request.
EOF

cat > engineering/access.txt <<'EOF'
Who is in `engineering`, and why

  rhea       engineering lead
  okonkwo    engineering

Additions go through the lead. There is no self-service, which is the point:
the group is not a lock, it is a record of who was asked.
EOF

########## roster ##########

cat > roster/group.export <<'EOF'
root:x:0:
adm:x:4:syslog
tty:x:5:
disk:x:6:
sudo:x:27:kalvi,dorn
www-data:x:33:
staff:x:50:
station-log:x:181:
hullmon:x:182:
doormon:x:183:
ops:x:184:ops-bot,dorn
strain-svc:x:185:
crew:x:1000:kalvi,rhea,cass,dorn,petrova,oyelaran,sant,iversen,mbeki,tanaka,ferreira,okonkwo,lindqvist,haddad,novak,ashworth,delacroix,rahimi
engineering:x:1002:rhea,okonkwo
medical:x:1003:petrova,haddad
galley:x:1004:oyelaran,ashworth
hydroponics:x:1005:iversen,rahimi
deck-02:x:1006:lindqvist,delacroix
deck-03:x:1007:sant,ferreira
deck-05:x:1008:cass,mbeki,novak
comms:x:1009:tanaka
archive-ro:x:1041:rhea,dorn
EOF

cat > roster/README <<'EOF'
Export of the station group database, 2187-06-10. A copy. The live file is
/etc/group; do not edit either one.
EOF

########## notes ##########

cat > notes/groups.txt <<'EOF'
Groups
------

A group is a number with a list of names attached, and it exists so that
permission can be granted to a set of people without naming each of them.

/etc/group is world-readable, one line per group, four colon-separated fields:

  name : x : gid : member,member,member
   1     2    3     4

  1 name     what people call it.
  2 x        the group password. Almost always `x`, meaning "in /etc/gshadow".
             Group passwords exist, are used by newgrp, and are a bad idea.
  3 gid      the number the kernel checks.
  4 members  comma-separated login names. Note what is NOT here: anybody whose
             PRIMARY group this is. They are members and their name does not
             appear. There is no third place to look -- field 4 of /etc/passwd
             is the other half of the answer.

Primary versus supplementary
----------------------------

  primary        one per account, from field 4 of /etc/passwd. This is the
                 group a new file you create is given. Change it and you change
                 what your work belongs to.
  supplementary  as many as you like, from field 4 of /etc/group. These grant
                 access and nothing else -- they do not affect what group your
                 new files get.

  id -gn         your primary group, name
  id -nG         every group you are in, primary first
  groups         the same list, from a different code path
  id -nG NAME    somebody else's

Joining a group
---------------

  sudo usermod -aG GROUP USER    add to a supplementary group
  sudo gpasswd -a USER GROUP     the same thing, said the other way
  sudo gpasswd -d USER GROUP     remove

  usermod -G GROUP USER          WITHOUT -a. This SETS the whole list, so it
                                 removes every group not named. This is the
                                 classic way to lock yourself out of sudo.

And then the thing that surprises everybody:

  Your groups were decided when your session started. The kernel gave your
  shell a set of credentials at exec time and copies them to every child.
  Editing /etc/group does not reach into a running process. `id` will show the
  new group for the ACCOUNT and `id` with no argument will not, because those
  are two different questions.

  Log out and back in, or start a session that re-reads them:

  newgrp GROUP     starts a new shell with GROUP as your PRIMARY group
  sg GROUP -c CMD  runs one command that way, without a new shell
EOF

cat > notes/page.txt <<'EOF'
From: rhea
To: whoever is on shift

You will be told at some point that you "have access" to the engineering data,
and then you will find that you do not, and then somebody will tell you to log
out and back in and it will work. I would rather you understood that than
learned it as a superstition.

The other thing. You have sudo, so you can add yourself to `engineering` in one
command without asking me. Please read engineering/access.txt first and then
decide whether you want to.
EOF

printf 'Yours.\n' > scratch/README

########## ownership and modes ##########

chown -R root:root .
chown -R cadet:crew shared notes scratch roster
chmod 775 shared
chmod 664 shared/handover.txt shared/rota.txt

chown -R rhea:engineering engineering
chmod 750 engineering
chmod 640 engineering/strain-export-2187-06-13.csv engineering/README engineering/access.txt

find . -exec touch -h -d '2187-06-14 08:00:00' {} +
touch -d '2186-04-02 11:20:00' notes/groups.txt
touch -d '2187-06-10 09:00:00' roster/group.export roster/README
touch -d '2187-06-13 22:10:00' engineering/strain-export-2187-06-13.csv
touch -d '2187-06-14 07:55:00' notes/page.txt

echo "seeded $LAB"
