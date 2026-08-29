#!/usr/bin/env bash
# kestrel: manages-ownership
#
# setup.sh -- seeds /labs/10-users-groups-permissions/08-special-bits
#
# THE ANSWER KEY. Students are told not to open this.
#
# 10/08 -- special bits, and the chapter's incident. Carries the chapter flag
# KESTREL{he_needed_to_read_it} in engineering/archive/cycle-41.hash (0600
# dorn:dorn) and the four STAGE tokens, and plants trace 10: a setuid helper
# owned by dorn, mtime 2187-05-18. Nothing here attributes it to anybody.
#
# Idempotent: removes its own tree first, creates nothing outside LAB except
# the group membership it takes back off cadet.
#
# The harness's blanket `chown -R cadet:crew` would strip every setuid and
# setgid bit in this lab, so the marker on line 2 turns it off and this script
# owns every mode and every owner below. Anything the student must be able to
# write into is claimed for them explicitly at the bottom.
set -euo pipefail

LAB="/labs/10-users-groups-permissions/08-special-bits"
rm -rf "$LAB"
mkdir -p "$LAB"
cd "$LAB"

mkdir -p audit bin dropbox shared/plans engineering/archive notes scratch

# ---------------------------------------------------------------- helpers ---
# Setuid is ignored on interpreted scripts, so both helpers are real binaries:
# copies of /bin/cat, which is exactly what makes the second one dangerous.
cp /bin/cat bin/readas
cp /bin/cat bin/summarise-hash
cp /bin/id  bin/whoami-really

cat > bin/README <<'TXT'
readas           reads a file. setuid root. A demonstration, and a bad idea.
summarise-hash   dorn's. Not yours. Look at its mode before you run it.
whoami-really    prints the ids of the process it runs in, real and effective.
TXT

# --------------------------------------------------------------- the audit ---
cat > audit/README <<'TXT'
Permissions audit, deck 05 and the engineering tree.

Five objects under this lab carry a special bit. Find them by their bits, not
by their names -- a name can be anything, a mode cannot.

For each one, write down: which bit, who owns it, what it does, and whether it
is supposed to be there. One of the four is correct as it stands and breaking
it will break other people's work. At least one is not.

Do not chmod anything until you can say what it does.
TXT

cat > audit/stage1.txt <<'TXT'
STAGE{bits_not_names}

You read this by running a setuid-root copy of cat, which is the entire lesson
in one sentence: a setuid binary does not do a restricted thing with root's
privileges, it does its ordinary thing with root's privileges. cat's ordinary
thing is "read any file you name".

Next. There is a file in this directory you cannot read, and it is yours. Its
mode is 0004. Work out from the octal what that means before you try anything,
then get its contents without changing its mode and without using this helper.
TXT

cat > audit/stage2.txt <<'TXT'
STAGE{first_match_wins_even_for_you}

Owner triad, first match, no fallthrough -- 0004 grants read to everybody who
is not you and not in your group. Reading it as somebody else was the point.

dorn's helper is mode 4750, owner dorn, group engineering. The 4 is setuid: it
runs as dorn whoever starts it. The 750 is why you cannot start it at all --
you are neither dorn nor in engineering.

rhea's page (notes/page.txt) grants you engineering for the audit, in writing,
with an end date. Take it, and remember that a group you were given at login
is not a group you have until you log in again.
TXT

# ------------------------------------------------------- the shared tree ----
# Legitimately setgid. A student who "fixes" this breaks group collaboration
# for everyone in engineering; the audit README warns them, and the exercises
# make them argue for leaving it.
cat > shared/README <<'TXT'
engineering's working directory. Setgid on purpose: everything created here
belongs to group engineering whoever made it, which is the only reason two
people can hand a file back and forth without a chgrp every time.

This is not the hole. Leave it alone.
TXT
cat > shared/plans/deck-05.txt <<'TXT'
Deck 05 panel layout, revision 4. Nothing interesting.
TXT

cat > dropbox/README <<'TXT'
Drop box. Mode 1733: anybody may write, nobody may list, and the sticky bit
means you can only delete your own files. /tmp is the same shape and for the
same reason.
TXT
cat > dropbox/from-cass.txt <<'TXT'
cass: panel counts for the week, as promised.
TXT

# ------------------------------------------------------- the archive --------
cat > engineering/archive/stage3.txt <<'TXT'
STAGE{a_group_is_not_a_login}

You are in engineering now, and `id` told you so only after a new login shell.
newgrp, su - your own account, or a fresh session: the group list is built at
login and nothing rebuilds it in a shell that is already running.

The last file here is 0600 dorn:dorn. Being in engineering does not help; the
owner triad is dorn's and it is the only triad that will be consulted for him,
and you are not him.

There is a program in this lab that is him. That is what setuid means.
TXT

cat > engineering/archive/cycle-41.hash <<'TXT'
cycle-41 raw export, sha256 manifest, taken 2187-05-18.

  9f2c1a  cycle-41-strain.raw
  4be07d  cycle-41-strain.summary

KESTREL{he_needed_to_read_it}

These two do not describe the same numbers. I have checked it four times. I
cannot read the archive as myself and I have run out of polite ways to ask.
TXT

cat > engineering/archive/README <<'TXT'
Engineering archive, raw exports and manifests. Group engineering, read only.
TXT

# ------------------------------------------------------------- the notes ----
cat > notes/setuid.txt <<'TXT'
The special bits
================

Three bits sit above the nine you know. In octal they are the fourth digit,
which is why a mode you thought was three digits is sometimes four.

  4000  setuid   on a file: run as the file's owner, not as the caller
  2000  setgid   on a file: run as the file's group
                 on a directory: new entries inherit the directory's group
  1000  sticky   on a directory: you may only delete entries you own

In `ls -l` they replace an execute letter:

  -rwsr-xr-x   setuid, and the owner can execute      (4755)
  -rwSr--r--   setuid, and the owner cannot           (4644) -- capital S
  drwxrwsr-x   setgid directory                       (2775)
  drwxrwxrwt   sticky, and other can execute          (1777)

A capital letter means the special bit is set and the execute bit under it is
not. It is almost always a mistake, and it is always worth a second look.

What setuid actually does
-------------------------
A process has a real uid (who started it) and an effective uid (who the kernel
checks against when it opens a file). Normally they are the same. Executing a
setuid file sets the effective uid to the file's owner and leaves the real uid
alone. `id` prints both when they differ; so does bin/whoami-really.

The danger is not that a setuid program is powerful. It is that it is powerful
*for whatever you ask it to do*. A setuid copy of `cat` is not "a tool that
reads one file" -- it is "read any file on the station, as its owner".

Two things it is not
--------------------
The kernel ignores setuid on a `#!` script. Every attempt to make a setuid
shell script work is either a no-op or a hole; the answer is a small compiled
program or a sudoers line.

Setuid does not survive `chown`. Changing a file's owner clears both special
bits, and it has to: otherwise you could hand somebody a program that runs as
you by giving it away.

Finding them
------------
  find / -perm -4000 -type f          setuid, anywhere below /
  find . -perm -2000                  setgid
  find . -perm -1000 -type d          sticky
  find . -perm /6000                  setuid OR setgid
  find . -perm 4750                   exactly 4750, all bits, nothing else

The leading `-` means "at least these bits", `/` means "any of these bits",
and a bare number means "exactly this mode". Getting those three confused is
the usual reason an audit comes back empty.
TXT

cat > notes/groups.txt <<'TXT'
Groups, membership, and login
=============================

  id                          your uids and every group you are in
  groups rhea                 somebody else's groups
  getent group engineering    the group's member list

  sudo usermod -aG GROUP USER add USER to GROUP, keeping their other groups
  sudo gpasswd -d USER GROUP  remove them again
  newgrp GROUP                start a shell with GROUP as your primary group

-aG is `--append --groups`. Without -a, -G *replaces* the list, which is how
people remove themselves from sudo at four in the morning.

Your group list is read at login and copied into every process you start. Add
yourself to a group and nothing in your running shell changes -- not `id`, not
your permissions, nothing. You need a new login, or `newgrp`, which gives you
one shell that has it.
TXT

cat > notes/page.txt <<'TXT'
rhea, 2187-06-14 07:40

Audit approved. You asked properly, so here it is in writing:

  Who:      cadet
  What:     read the engineering archive tree, no writes
  Where:    this lab's engineering/ directory only
  As whom:  yourself, via membership of group engineering
  How long: today. Take yourself back out when you are done and tell me you
            have.
  Why:      permissions audit of deck 05.

Separately. There is a setuid binary in that tree owned by an account whose
holder left three weeks ago. I did not put it there and I did not approve it.
Find out what it does before you touch it, then tell me what you changed.
TXT

cat > notes/page-2.txt <<'TXT'
cass, 2187-06-14 09:05

Whatever you do, don't "tidy up" the engineering shared directory. Somebody
did that on my last station and every file the two of us made after that
landed in the wrong group. Took a month to notice.
TXT

cat > scratch/README <<'TXT'
Yours. Nothing here is checked.
TXT

# ------------------------------------------------------------ modes ---------
# Ownership first: chown clears setuid and setgid, so the bits go on last.
chown -R cadet:crew "$LAB"

chown root:root  bin/readas bin/whoami-really audit/stage1.txt
chown dorn:engineering bin/summarise-hash
chown cadet:crew audit/stage2.txt
chown root:engineering shared shared/README shared/plans shared/plans/deck-05.txt
chown dorn:engineering engineering engineering/archive \
      engineering/archive/README engineering/archive/stage3.txt
chown dorn:dorn engineering/archive/cycle-41.hash

chmod 755 "$LAB" audit bin notes scratch engineering
chmod 644 audit/README bin/README notes/*.txt scratch/README

chmod 4755 bin/readas          # setuid root: the demonstration
chmod 4750 bin/summarise-hash  # setuid dorn, group engineering: the hole
chmod 0755 bin/whoami-really

chmod 0400 audit/stage1.txt    # root's, and nobody else's
chmod 0004 audit/stage2.txt    # yours, and unreadable by you

chmod 2775 shared              # setgid, on purpose, correct as it stands
chmod 0644 shared/README
chmod 2775 shared/plans
chmod 0664 shared/plans/deck-05.txt

chmod 1733 dropbox             # sticky, write-only drop box
chmod 0644 dropbox/README dropbox/from-cass.txt
chown root:crew dropbox dropbox/README
chown rhea:crew dropbox/from-cass.txt

chmod 0750 engineering/archive
chmod 0644 engineering/archive/README
chmod 0640 engineering/archive/stage3.txt
chmod 0600 engineering/archive/cycle-41.hash

# The trace: 2187-05-18, the day he built it. Nothing here says who or why.
touch -d '2187-05-18 02:41:00' bin/summarise-hash engineering/archive/cycle-41.hash

# The student is granted engineering during the lesson and takes it back at the
# end; seeding must start from the state rhea's page describes.
gpasswd -d cadet engineering >/dev/null 2>&1 || true

chmod 755 scratch
chown cadet:crew scratch scratch/README audit audit/README notes notes/*.txt
