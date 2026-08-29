#!/usr/bin/env bash
# kestrel: manages-ownership
# setup.sh -- seeds /labs/10-users-groups-permissions/05-chmod
#
# THE ANSWER KEY. Students are told not to open this.
#
# Teaches: chmod numeric and symbolic, -R and why +X exists, --reference, and
# the two facts that make permissions make sense --
#   * deleting a file is a write to the DIRECTORY, not to the file
#   * chmod follows symlinks and a symlink's own mode is inert
#
# repair/ is a set of small, real mistakes to fix with the smallest change
# that works: a script nobody can run, a key everybody can read, a shared
# directory nobody can write, a config that was fixed with 777.
#
# drop/ is the delete-what-you-cannot-write demonstration: a 777 directory
# owned by cadet containing a 444 file owned by root.
#
# Idempotent: removes its own tree first, creates nothing outside LAB.
set -euo pipefail

LAB="/labs/10-users-groups-permissions/05-chmod"
rm -rf "$LAB"
mkdir -p "$LAB"/{repair,drop,tree,notes,scratch}
cd "$LAB"

cat > notes/chmod.txt <<'EOF'
chmod
-----

Two ways to say the same thing.

NUMERIC. Three digits, one per triad, each the sum of r=4 w=2 x=1.

    chmod 644 file          rw- r-- r--
    chmod 750 dir           rwx r-x ---
    chmod 600 secret        rw- --- ---

Numeric is absolute: it sets all nine bits at once. Every bit you did not
think about is being set to zero, and that is the danger and the value.

SYMBOLIC. who, operator, what.

    who:  u  owner        g  group       o  other      a  all (default)
    op:   +  add          -  remove      =  set exactly
    what: r w x  and  X (see below)

    chmod u+x script            add execute for the owner
    chmod go-w file             take write away from group and other
    chmod a=r file              everybody gets exactly r, nobody gets w or x
    chmod u+rwx,go-rwx secret   two clauses, comma separated

Symbolic is relative except for `=`, which is absolute for the triads it
names and leaves the others alone.

    -R          recurse
    --reference=OTHER   copy another file's mode
    -v / -c     print what changed (-c prints only actual changes)

X, the capital one
------------------

    chmod -R a+rX tree

`X` means "execute, but only for directories, and for files that ALREADY
have an execute bit somewhere". It exists because `chmod -R a+rx` makes every
text file in the tree executable, which is wrong and looks fine. Lower-case x
on a recursive chmod is nearly always a mistake.

What chmod needs
----------------

You must OWN the file, or be root. Read and write on the file are irrelevant.
You cannot chmod your way into somebody else's file.

chmod follows symlinks
----------------------

`chmod 777 link` changes the TARGET. A symlink's own mode is always
lrwxrwxrwx and is never consulted by anything.
EOF

cat > notes/deletion.txt <<'EOF'
Deleting is not writing
-----------------------

A directory is a list of names. Creating a file, removing a file, and
renaming a file all edit that list -- so all three are governed by `w` on
the DIRECTORY, and none of them consult the file's own mode.

That gives two results people find outrageous, in opposite directions:

  * You can delete a file you cannot read or write, if you can write the
    directory it is in. `rm` will ask "remove write-protected file?" when it
    is talking to a terminal -- that is rm being polite, not the kernel
    stopping you. Answer y and it goes.

  * You cannot delete a file you own and can write, if you cannot write the
    directory it is in. Your own file, your own bits, and the answer is no.

So: to protect a file from deletion, the mode to look at is its directory's.
To let somebody edit a file without being able to remove it, put it in a
directory they cannot write.

Every world-writable directory has this problem, which is why /tmp needs the
extra bit you have seen in its mode and have not been told about yet.
EOF

cat > notes/page.txt <<'EOF'
From: rhea
To: cadet

Four things in repair/ are set wrong. I know they are wrong; I do not want
them fixed with 777 and I do not want a chmod -R that lands on every file in
the tree.

Smallest change that works, and tell me what each one was for. One of the
four was already "fixed" once by somebody in a hurry -- that is the one I
care about.
EOF

# --- repair/: four real mistakes -------------------------------------------
mkdir -p repair
cat > repair/collect.sh <<'EOF'
#!/usr/bin/env bash
# collect.sh -- gathers the daily numbers. Run by whoever is on shift.
echo "collected $(date +%F)"
EOF

cat > repair/id_station <<'EOF'
-----BEGIN EXAMPLE KEY-----
this is not a real key. it is the shape of one, so that its mode matters.
-----END EXAMPLE KEY-----
EOF

mkdir -p repair/handover
printf 'shift handover, week 24\n' > repair/handover/week-24.txt
printf 'shift handover, week 23\n' > repair/handover/week-23.txt

cat > repair/exporter.conf <<'EOF'
# exporter.conf -- read at start by the survey exporter.
# Contains the archive endpoint and the token it authenticates with.
endpoint = archive.internal:9411
token    = not-a-real-token-but-treat-it-like-one
EOF

cat > repair/NOTES <<'EOF'
collect.sh      the daily collection script. On shift, anyone runs it.
id_station      a private key. Nobody but its owner, ever.
handover/       the shift handover directory. Crew write in it every day.
exporter.conf   config with a token in it. The exporter runs as its owner;
                nobody else has any business reading it.

"exporter.conf stopped being readable after the move so I opened it up
 to get the run out. Somebody should tidy that." -- undated
EOF

# --- drop/: delete what you cannot write -----------------------------------
printf 'You did not write this and you may not write it now.\n' > drop/theirs.txt
printf 'This one is yours.\n' > drop/yours.txt
cat > drop/README <<'EOF'
One of these two files is not yours and is read-only. Try to change it, then
try to remove it, and reconcile the two answers.
EOF

# --- tree/: the -R and +X demonstration ------------------------------------
mkdir -p tree/bin tree/data tree/data/archive
cat > tree/bin/run <<'EOF'
#!/usr/bin/env bash
echo "ran"
EOF
cat > tree/bin/helper <<'EOF'
#!/usr/bin/env bash
echo "helped"
EOF
printf 'readings, cycle 41\n' > tree/data/cycle-41.csv
printf 'readings, cycle 42\n' > tree/data/cycle-42.csv
printf 'readings, cycle 40\n' > tree/data/archive/cycle-40.csv
cat > tree/README <<'EOF'
A tree that came off the archive host with every mode set to 600, including
the directories. Two of the files are scripts and are meant to be runnable.
Make the whole tree readable and traversable in one command without making
the CSVs executable.
EOF

printf 'Yours.\n' > scratch/README

chown -R cadet:crew .
chown root:root drop/theirs.txt
chmod 755 . notes scratch repair drop
chmod 644 notes/chmod.txt notes/deletion.txt notes/page.txt scratch/README
chmod 644 repair/NOTES

chmod 644 repair/collect.sh          # mistake 1: not executable
chmod 644 repair/id_station          # mistake 2: world-readable key
chmod 755 repair/handover            # mistake 3: crew cannot write
chmod 644 repair/handover/week-24.txt repair/handover/week-23.txt
chmod 777 repair/exporter.conf       # mistake 4: "fixed" in a hurry

chmod 777 drop
chmod 444 drop/theirs.txt
chmod 644 drop/yours.txt drop/README

chmod 600 tree/README
chmod 600 tree/data/cycle-41.csv tree/data/cycle-42.csv tree/data/archive/cycle-40.csv
chmod 700 tree/bin/run tree/bin/helper
chmod 600 tree tree/bin tree/data tree/data/archive

find . -exec touch -h -d '2187-06-14 08:00:00' {} +
touch -d '2186-04-02 11:20:00' notes/chmod.txt notes/deletion.txt
touch -d '2187-06-14 07:05:00' notes/page.txt

echo "seeded $LAB"
