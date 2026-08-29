#!/usr/bin/env bash
# kestrel: manages-ownership
# setup.sh -- seeds /labs/10-users-groups-permissions/03-managing-accounts
#
# THE ANSWER KEY. Students are told not to open this.
#
# Teaches: useradd/usermod/userdel, /etc/shadow's fields, chage, account
# locking, and the two things that go wrong -- a home directory left behind
# with no owner, and a uid reused underneath it.
#
# The orphaned tree under homes/ is owned by uid/gid 4102, which is not an
# account on this station and is well outside UID_MAX. `find -nouser` finds it.
# Nothing here touches the real /home.
#
# The lab creates one throwaway account, `probe`, in the account database --
# the same one lesson 02 used, recreated here in the same shape so the two
# lessons do not fight. It is locked and has no home.
#
# Idempotent: removes its own tree first, and recreates probe from scratch.
set -euo pipefail

LAB="/labs/10-users-groups-permissions/03-managing-accounts"
rm -rf "$LAB"
mkdir -p "$LAB"/{roster,notes,homes,scratch}
cd "$LAB"

userdel -r probe >/dev/null 2>&1 || true
groupdel probe >/dev/null 2>&1 || true
groupadd -f hydroponics
useradd -M -s /usr/sbin/nologin -G crew,ops,hydroponics probe
passwd -l probe >/dev/null

cat > roster/arrivals.txt <<'EOF'
Rotation 7 arrivals -- accounts to be created before they dock
--------------------------------------------------------------

  Tulane, M.       hydroponics      needs a shell, needs crew
  Okonkwo, A.      hydroponics      needs a shell, needs crew
  survey-svc       (not a person)   runs the survey exporter, no login

Departed rotation 6, accounts still live:

  Merrick, D.      galley           left 2187-04-11
  Voss, K.         deck-03          left 2187-05-02

Do the arrivals first. The departures have been outstanding for two months
and one more day will not hurt; getting them wrong will.
EOF

cat > roster/offboarding.txt <<'EOF'
Offboarding, as it is actually done here
-----------------------------------------

1. Lock the account. This is reversible and takes one second, and it is the
   step that actually stops a login. Do it the day they leave.
2. Wait. Two weeks, by convention. People come back for one file.
3. Decide about the home directory before deleting the account, not after.
   Somebody has to say whether it is archived, handed to their replacement,
   or dropped. Nobody enjoys this step, which is why it is written down.
4. Then remove the account and its home together.

The step that gets skipped is 3, and skipping it is how you end up with a
directory owned by a number.
EOF

cat > roster/uid-policy.txt <<'EOF'
uid allocation
--------------

  0            root
  1-999        system accounts, allocated by packages
  1000-59999   people and service accounts on this station
  60000+       reserved

We do not reuse uids. The account database will happily hand out a number
that was in use last year -- it takes the lowest free one -- and the files
that number still owns become the new person's files without anybody
touching them. If an account is removed, its number is retired: write it in
retired-uids.txt and set the next arrival above it.

This policy is eleven years old and has been ignored at least once.
EOF

cat > roster/retired-uids.txt <<'EOF'
# uid   account     retired
4098    haldane     2181-02-18
4099    ferris      2183-09-04
4100    ncube       2185-01-30
4101    okere       2186-11-12
EOF

cat > notes/accounts.txt <<'EOF'
Creating and removing accounts
------------------------------

Everything here needs root, so everything here is `sudo`.

  useradd NAME              creates the account and nothing else. No home
                            directory. Shell from `useradd -D` -- on this
                            station that default is /bin/sh, not bash.
  useradd -m NAME           ...and create the home directory, populated from
                            /etc/skel.
  useradd -m -s /bin/bash -c "Name, N." -G crew NAME
                            the form you will actually type.
  useradd -D                show the defaults. Read it before your first
                            useradd on a machine you do not know.

  usermod -c "..."  NAME    change the gecos (the description field)
  usermod -s SHELL  NAME    change the login shell
  usermod -aG GRP   NAME    add a supplementary group (chapter lesson 02)
  usermod -L / -U   NAME    lock / unlock
  usermod -l NEW OLD        rename the login

  userdel NAME              remove the account. Leaves the home directory.
  userdel -r NAME           remove the account and its home directory.

`adduser` also exists. It is a Debian script that wraps useradd, asks
questions, and picks nicer defaults. It is pleasant and it is not portable;
`useradd` is on every Linux you will ever touch. Learn useradd, use adduser
when it is there and you are typing by hand.

A group with the same name as the account is created automatically. That is
`USERGROUPS_ENAB yes` in /etc/login.defs, and it is why every account here
has a gid nobody else is in.
EOF

cat > notes/shadow.txt <<'EOF'
/etc/shadow, field by field
---------------------------

Nine colon-separated fields. Only root can read it.

  1  name
  2  the hashed password, or a marker:
       *   no password will ever match -- a system account
       !   locked. A locked password is the real hash with `!` in front of
           it, or just `!` if there was never a hash. Unlocking puts the
           hash back.
       (empty)  no password at all. Anyone may log in as this account.
  3  date of the last password change, in days since 1970-01-01
  4  minimum days before the password may be changed again
  5  maximum days the password is good for
  6  days of warning before it expires
  7  days after expiry before the account is disabled
  8  the date the ACCOUNT expires, in days since 1970-01-01
  9  reserved

Fields 5 and 8 are different things and are confused constantly. Field 5
expires the PASSWORD: you are told to pick a new one and you carry on.
Field 8 expires the ACCOUNT: it stops working, and no password will fix it.

  chage -l NAME             read all of that in dates instead of day numbers
  chage -E YYYY-MM-DD NAME  set field 8
  chage -M DAYS NAME        set field 5
  chage -d 0 NAME           force a password change at the next login

`passwd -S NAME` gives the one-line version: name, status (P set, L locked,
NP none), last change, then min/max/warn/inactive.
EOF

cat > notes/page.txt <<'EOF'
From: rhea
To: cadet

Two arrivals on rotation 7 and two accounts from rotation 6 that should have
been closed in April. I would like the arrivals to exist and the departures
to be locked, and I would like to know what you intend to do about the home
directories before you do it.

Read roster/uid-policy.txt first. Then look at homes/ and tell me what you
find there, because I do not think it is what the policy says should happen.
EOF

cat > homes/README <<'EOF'
A copy of four home directories, taken off the archive host for review.
The permissions and ownership are as they were found.
EOF

mkdir -p homes/kalvi homes/haldane/logs homes/probe
printf 'shift notes, current\n' > homes/kalvi/notes.txt
printf 'hydroponics handover, 2187-06-02\n' > homes/kalvi/handover.txt
printf 'calibration log, cycle 41\n' > homes/haldane/logs/cal-41.txt
printf 'calibration log, cycle 42\n' > homes/haldane/logs/cal-42.txt
printf 'personal. do not archive.\n' > homes/haldane/private.txt
printf 'survey exporter working directory\n' > homes/probe/README

cat > homes/haldane/README <<'EOF'
Left the station 2181-02-18. Account removed the same week; nobody decided
what to do with this directory, so it is still here.
EOF

printf 'Yours. Nothing here is anyone else%s.\n' "'s" > scratch/README

chown -R root:root .
chown -R cadet:crew roster notes scratch homes/README
chown -R cadet:crew homes
chmod 755 homes
chown -R 4102:4102 homes/haldane
chmod 750 homes/haldane
chown -R 1001:1001 homes/kalvi
chmod 750 homes/kalvi
chown -R probe:probe homes/probe
chmod 750 homes/probe

find . -exec touch -h -d '2187-06-14 08:00:00' {} +
touch -d '2186-04-02 11:20:00' notes/accounts.txt notes/shadow.txt
touch -d '2187-06-10 09:00:00' roster/arrivals.txt roster/offboarding.txt \
      roster/uid-policy.txt roster/retired-uids.txt
touch -d '2181-02-18 16:05:00' homes/haldane/README homes/haldane/private.txt \
      homes/haldane/logs/cal-41.txt homes/haldane/logs/cal-42.txt
touch -d '2187-06-14 06:15:00' notes/page.txt

echo "seeded $LAB"
