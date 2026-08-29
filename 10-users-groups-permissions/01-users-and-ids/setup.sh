#!/usr/bin/env bash
# setup.sh -- seeds /labs/10-users-groups-permissions/01-users-and-ids
#
# THE ANSWER KEY. Students are told not to open this.
#
# Teaches: /etc/passwd and its seven fields, uid vs gid, the id/whoami/getent
# family, system accounts versus human ones, and the fact that an account is a
# number -- the name is a lookup, and the lookup can fail or be missing.
#
# The lab has TWO sources of truth on purpose:
#   * the container's real /etc/passwd, which the student reads with id, getent
#     and cut, and which is small enough to hold in the head (24 lines).
#   * roster/passwd.export, a captured station export with 34 accounts, which is
#     big enough that the questions have to be answered with tools.
#
# THE CALLBACK, not a flag and not gated: roster/passwd.export contains
# eng-svc, uid 1207, /usr/sbin/nologin, and no matching line in
# roster/crew-list.txt. That is the same account chapter 7 found one login for,
# on 2187-01-18. Nothing in this lesson names it or points at it; a student who
# does exercise 33 finds it, and a student who does not still passes.
# Do NOT let any agent attribute it to a person. It predates dorn.
#
# Idempotent: removes its own tree first, creates nothing outside LAB.
set -euo pipefail

LAB="/labs/10-users-groups-permissions/01-users-and-ids"
rm -rf "$LAB"
mkdir -p "$LAB"/{roster,notes,scratch}
cd "$LAB"

########## the station account export ##########
# Seven colon-separated fields, same format as /etc/passwd:
#   name : password-placeholder : uid : gid : gecos : home : shell
# System accounts below 1000, humans and services above.

cat > roster/passwd.export <<'EOF'
root:x:0:0:root:/root:/bin/bash
daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
bin:x:2:2:bin:/bin:/usr/sbin/nologin
sys:x:3:3:sys:/dev:/usr/sbin/nologin
sync:x:4:65534:sync:/bin:/bin/sync
man:x:6:12:man:/var/cache/man:/usr/sbin/nologin
mail:x:8:8:mail:/var/mail:/usr/sbin/nologin
backup:x:34:34:backup:/var/backups:/usr/sbin/nologin
nobody:x:65534:65534:nobody:/nonexistent:/usr/sbin/nologin
station-log:x:181:181:station logging daemon:/var/log/station:/usr/sbin/nologin
hullmon:x:182:182:hull monitor:/var/lib/hullmon:/usr/sbin/nologin
doormon:x:183:183:door log daemon:/var/lib/doormon:/usr/sbin/nologin
ops-bot:x:184:184:operations automation:/var/lib/ops-bot:/usr/sbin/nologin
strain-svc:x:185:185:strain sampler service:/var/lib/strain:/usr/sbin/nologin
kalvi:x:1001:1001:Kalvi, T. -- captain:/home/kalvi:/bin/bash
rhea:x:1002:1002:Rhea, M. -- engineering lead:/home/rhea:/bin/bash
cass:x:1003:1003:Cass, O. -- deck 05:/home/cass:/bin/bash
dorn:x:1004:1004:Dorn, J. -- systems:/home/dorn:/bin/bash
petrova:x:1005:1005:Petrova, L. -- medical:/home/petrova:/bin/bash
oyelaran:x:1006:1006:Oyelaran, B. -- galley:/home/oyelaran:/bin/bash
sant:x:1007:1007:Sant, R. -- deck 03:/home/sant:/bin/bash
iversen:x:1008:1008:Iversen, K. -- hydroponics:/home/iversen:/bin/bash
mbeki:x:1009:1009:Mbeki, N. -- deck 05:/home/mbeki:/bin/bash
tanaka:x:1010:1010:Tanaka, H. -- comms:/home/tanaka:/bin/bash
ferreira:x:1011:1011:Ferreira, A. -- deck 03:/home/ferreira:/bin/bash
okonkwo:x:1012:1012:Okonkwo, C. -- engineering:/home/okonkwo:/bin/bash
lindqvist:x:1013:1013:Lindqvist, S. -- deck 02:/home/lindqvist:/bin/bash
haddad:x:1014:1014:Haddad, Y. -- medical:/home/haddad:/bin/bash
novak:x:1015:1015:Novak, P. -- deck 05:/home/novak:/bin/bash
ashworth:x:1016:1016:Ashworth, D. -- galley:/home/ashworth:/bin/bash
delacroix:x:1017:1017:Delacroix, M. -- deck 02:/home/delacroix:/bin/bash
rahimi:x:1018:1018:Rahimi, F. -- hydroponics:/home/rahimi:/bin/bash
eng-svc:x:1207:1207::/var/lib/eng-svc:/usr/sbin/nologin
cadet:x:1500:1500:cadet -- training berth:/home/cadet:/bin/bash
EOF

cat > roster/crew-list.txt <<'EOF'
Kestrel crew list -- current, 2187-06-10
Personnel office. One line per person aboard. Not an account list.

  Kalvi, T.        captain
  Rhea, M.         engineering lead
  Cass, O.         deck 05
  Petrova, L.      medical
  Oyelaran, B.     galley
  Sant, R.         deck 03
  Iversen, K.      hydroponics
  Mbeki, N.        deck 05
  Tanaka, H.       comms
  Ferreira, A.     deck 03
  Okonkwo, C.      engineering
  Lindqvist, S.    deck 02
  Haddad, Y.       medical
  Novak, P.        deck 05
  Ashworth, D.     galley
  Delacroix, M.    deck 02
  Rahimi, F.       hydroponics

Departed, account not yet removed:
  Dorn, J.         systems -- left 2187-05-24

Aboard on a training berth, not established crew:
  (the cadet)
EOF

cat > roster/README <<'EOF'
Exports taken 2187-06-10 from the station account database. Read-only copies.
The live files are /etc/passwd and /etc/group; do not edit either of them, and
do not edit these -- if you break one, `kestrel reset 10/01`.
EOF

########## notes ##########

cat > notes/accounts.txt <<'EOF'
What an account actually is
---------------------------

To the kernel, you are a number. A uid. Every check the kernel makes -- can this
process open this file, can it signal that process -- compares numbers. Names
exist for people, and they are looked up in a file.

The file is /etc/passwd. It is world-readable, one line per account, seven
fields separated by colons:

  name : x : uid : gid : gecos : home : shell
   1     2    3     4      5      6      7

  1 name    the login name. What you type. What `ls -l` prints.
  2 x       historically the hashed password. It is now always `x`, meaning
            "the hash is in /etc/shadow", which is not world-readable.
  3 uid     the number that actually matters.
  4 gid     the account's PRIMARY group, by number. Not the same number as
            the uid, and assuming it is will bite you.
  5 gecos   free text: real name, room, phone. Comma-separated by convention,
            enforced by nothing.
  6 home    the directory the account starts in.
  7 shell   the program run on login. /usr/sbin/nologin means "no login" and is
            how a service account is stopped from being one.

uid 0 is root, and root is not special because of its name -- it is special
because of the number. An account named `root` with uid 1000 is an ordinary
user; an account named `harmless` with uid 0 is root.

By convention on this system, uids below 1000 are system accounts created by
packages, and 1000 and up are accounts somebody asked for. The boundary is
written in /etc/login.defs as UID_MIN. It is a convention, not a rule.

Asking who you are
------------------

  whoami        your effective username, one word
  id            uid, primary gid, and every group you are in
  id -u         just the number
  id -un        just the name
  id -G         every group's number
  id -nG        every group's name
  id NAME       the same, for somebody else -- no privilege needed

  getent passwd NAME   look up one account properly. Exit 0 if found, 2 if not.
  getent passwd UID    the same lookup by number.

Use `getent` rather than `grep` on /etc/passwd. grep matches substrings: the
pattern `cass` also matches an account called `cassette`, and the pattern `1001`
matches a uid of 1001, a gid of 1001, and any home directory with 1001 in the
path. getent asks the lookup service the same question the kernel would.

Two things that look like `whoami` and are not:

  $USER, $LOGNAME   environment variables. Set by the login program, copied to
                    every child. Nothing keeps them true. A shell started
                    another way may not have them at all.
  logname           reads the login record, not the process. It fails outright
                    if there is no login record for the session.
EOF

cat > notes/page.txt <<'EOF'
From: rhea
To: whoever is on shift

Sixty-one people aboard. The account database has rather more than sixty-one
accounts in it, which is normal -- services get accounts, and nobody has ever
finished a tidy-up of one of these.

I want you to be able to answer a question I get asked twice a year and have
never enjoyed: which of these accounts belongs to a person. Not "which ones
look official". Which ones belong to a person.

Export is in roster/. It is a copy. Nothing you do to it matters, which is the
point of giving it to you.
EOF

printf 'Yours. Copy things here before you experiment on them.\n' > scratch/README

find . -exec touch -h -d '2187-06-14 08:00:00' {} +
touch -d '2186-04-02 11:20:00' notes/accounts.txt
touch -d '2187-06-10 09:00:00' roster/passwd.export roster/crew-list.txt roster/README
touch -d '2187-06-14 07:40:00' notes/page.txt

echo "seeded $LAB"
