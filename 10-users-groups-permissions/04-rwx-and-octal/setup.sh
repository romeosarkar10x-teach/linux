#!/usr/bin/env bash
# kestrel: manages-ownership
# setup.sh -- seeds /labs/10-users-groups-permissions/04-rwx-and-octal
#
# THE ANSWER KEY. Students are told not to open this.
#
# Teaches: reading `ls -l`, the three triads, first-match-wins, octal, and the
# two directory bits that behave nothing like their file counterparts --
# r-without-x (you can list names and learn nothing else) and x-without-r (you
# can reach a file you already know the name of, and cannot discover it).
#
# No chmod here; that is lesson 05. This lesson is entirely about reading.
#
# The maze/ directories are root-owned with mode 700/744/711/755 so that the
# student, as cadet, lands in the `other` triad every time and the three cases
# separate cleanly. audit/ is a paper exercise: a listing to decode by eye.
#
# Idempotent: removes its own tree first, creates nothing outside LAB.
set -euo pipefail

LAB="/labs/10-users-groups-permissions/04-rwx-and-octal"
rm -rf "$LAB"
mkdir -p "$LAB"/{maze,audit,notes,scratch}
cd "$LAB"

cat > notes/modes.txt <<'EOF'
Reading a mode
--------------

    -rw-r--r--   ordinary file, owner may read and write, everyone may read
    drwxr-x---   directory
    lrwxrwxrwx   symlink (the mode is never consulted; the target's is)

Ten characters. The first is the file TYPE. The other nine are three triads:

    [type][ owner ][ group ][ other ]
      d     r w x    r - x    - - -

The kernel picks ONE triad and uses only that one:

    are you the owner?              -> owner triad, done
    else, is the file's group one
    of the groups your process has? -> group triad, done
    else                            -> other triad, done

First match wins. There is no union. An owner with `---` cannot read the file
even if `other` is `rwx`; the check stopped before it got there.

Octal
-----

Each triad is three bits, so it is a digit 0-7:

    r = 4     rwx = 7     rw- = 6     r-x = 5     r-- = 4
    w = 2     -wx = 3     -w- = 2     --x = 1     --- = 0
    x = 1

    644 = rw- r-- r--        755 = rwx r-x r-x
    640 = rw- r-- ---        750 = rwx r-x ---
    600 = rw- --- ---        700 = rwx --- ---

    stat -c '%a %A %n' FILE   prints both forms

There is a fourth digit in front for the special bits. That is lesson 08.

On directories
--------------

The letters mean different things on a directory, and this is where people
lose an afternoon:

    r   you may LIST THE NAMES in it
    w   you may CREATE and REMOVE names in it -- which is permission over
        the directory, not over the files. See lesson 05.
    x   you may TRAVERSE it: use it in a path, cd into it, and reach a
        file inside it whose name you already know. Sometimes called the
        "search" bit, which is a better name for it.

So the two odd combinations:

    r-x   normal. list, and reach.
    r--   you can list the names and NOTHING else. `ls` works; `ls -l` shows
          a row of question marks, because getting a file's details requires
          traversing the directory to reach it.
    --x   you can reach anything you can name, and cannot discover any name.
          `ls` is denied. `cat dir/known-file` works.

A path is checked one component at a time, and every directory along the way
needs x. /a/b/c/file needs x on /, /a, /a/b and /a/b/c -- and then the file's
own mode is consulted. One missing x anywhere stops you, whatever the file
says.
EOF

cat > notes/page.txt <<'EOF'
From: cass
To: cadet

I can see the file. I can list the directory. I cannot open the file. rhea
says that is not possible and I should check what I typed.

I did check. It is one directory down from the shift rota. I am not asking
you to fix it, I am asking you to tell me why it is not impossible, because
I would like to say something back.
EOF

cat > audit/listing.txt <<'EOF'
A listing taken off the archive host. Decode it by eye; nothing here exists
on this station.

drwxr-x---  2 rhea     engineering  4096 2187-06-13 09:12 strain/
-rw-r-----  1 rhea     engineering 20481 2187-06-13 09:14 strain/export.csv
-rw-rw-r--  1 rhea     engineering  1024 2187-06-02 11:00 strain/notes.txt
-rw-------  1 rhea     rhea          220 2187-05-30 22:41 strain/.private
drwxrwxr-x  2 cass     crew         4096 2187-06-14 06:02 galley/
-rw-rw-r--  1 cass     crew          880 2187-06-14 06:02 galley/rota.txt
-rw-r--r--  1 cass     crew         4400 2186-12-01 08:00 galley/inventory.csv
drwxr-xr-x  2 root     root         4096 2187-01-04 00:00 tools/
-rwxr-xr-x  1 root     root        18240 2187-01-04 00:00 tools/report
-rwx------  1 root     root         9112 2187-03-19 02:55 tools/adjust
drwx--x--x  2 dorn     ops          4096 2187-05-18 03:40 queue/
-rw-r--r--  1 dorn     ops           140 2187-05-18 03:40 queue/README
d---------  2 root     root         4096 2186-08-01 00:00 quarantine/
-rw-rw-rw-  1 ops-bot  ops           64  2187-06-14 07:55 heartbeat
EOF

cat > audit/questions.txt <<'EOF'
For the listing next door. Answer from the listing alone -- no commands.

Assume three people:
  rhea    groups: rhea, crew, engineering
  cass    groups: cass, crew
  kalvi   groups: kalvi, crew, hydroponics

1. Who can read strain/export.csv?
2. Who can write galley/rota.txt?
3. Can cass list tools/? Can she run tools/report? tools/adjust?
4. What can cass do with queue/README?
5. What is quarantine/ for, given its mode?
6. Which single file in this listing would you raise first, and why?
EOF

mkdir -p maze/open maze/listed maze/reachable maze/shut
printf 'The rota is one directory down from here.\n' > maze/README
printf 'shift rota, week 24\n' > maze/open/rota.txt
printf 'you found this by listing and then reading\n' > maze/open/note.txt
printf 'shift rota, week 24\n' > maze/listed/rota.txt
printf 'this file exists and you will not read it\n' > maze/listed/note.txt
printf 'shift rota, week 24\n' > maze/reachable/rota.txt
printf 'this one you can read, if you knew it was here\n' > maze/reachable/note.txt
printf 'nothing gets in\n' > maze/shut/rota.txt
mkdir -p maze/reachable/deeper
printf 'two levels of guessing\n' > maze/reachable/deeper/buried.txt

cat > maze/HOW <<'EOF'
Four directories. Same three files in three of them, near enough. The modes
are different and nothing else is.

Work out, for each one, which of `ls`, `ls -l` and `cat` succeed, and say why
before you run the next one.
EOF

printf 'Yours.\n' > scratch/README

chown -R root:root .
chown -R cadet:crew notes scratch audit
chmod 755 . notes scratch audit maze
chmod 644 maze/README maze/HOW
chmod 755 maze/open
chmod 744 maze/listed
chmod 711 maze/reachable
chmod 700 maze/shut
chmod 711 maze/reachable/deeper
chmod 644 maze/open/rota.txt maze/open/note.txt \
          maze/listed/rota.txt maze/listed/note.txt \
          maze/reachable/rota.txt maze/reachable/note.txt \
          maze/shut/rota.txt maze/reachable/deeper/buried.txt

find . -exec touch -h -d '2187-06-14 08:00:00' {} +
touch -d '2186-04-02 11:20:00' notes/modes.txt
touch -d '2187-06-13 09:12:00' audit/listing.txt audit/questions.txt
touch -d '2187-06-14 06:40:00' notes/page.txt

echo "seeded $LAB"
