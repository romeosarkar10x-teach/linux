#!/usr/bin/env bash
# setup.sh — seeds /labs/03-files-links-and-types/05-devices-fifos-sockets
#
# Runs as root inside the container: mknod needs CAP_MKNOD, which cadet does not
# have. That inability is itself exercises 27-28, so do not "fix" it by relaxing
# anything. cadet owns everything here, device nodes included -- see the ownership
# stanza for why that does not weaken exercise 30.
#
# Artifacts -> exercises:
#   zoo/          all seven file types, one each          -> 5-8, 29-30, 36-37, 40, 51
#   pipe/         a pre-made FIFO plus room to make more  -> 17-27, 33-34, 38-40, 45
#   salvage/feed/ the recovered feed directory            -> 47-49
#   console/      scratch space for /dev/tty work         -> 23, 31, 39, 44
#
# Idempotent: the lab is torn down and rebuilt from nothing on every run.
set -euo pipefail
LAB="/labs/03-files-links-and-types/05-devices-fifos-sockets"

# Special files ignore normal rm ordering problems, but a read-only dir does not.
[ -d "$LAB" ] && chmod -R u+w "$LAB"
rm -rf "$LAB"
mkdir -p "$LAB"
cd "$LAB"

# ---------------------------------------------------------------- zoo/
# One of each of the seven types. Names are deliberately unhelpful: nothing here
# can be identified from its name, only from its metadata.
mkdir -p zoo/bay
printf 'panel 07 maintenance manifest\nbolt torque 41Nm\n' > zoo/manifest.txt
printf 'spare seals: 4\n' > zoo/bay/inventory.txt
ln -s manifest.txt zoo/alias
mkfifo zoo/relay
mknod zoo/null-clone c 1 3      # same major/minor as /dev/null: it IS /dev/null
mknod zoo/dev-sensor b 7 200    # a loop device number; nothing is attached
perl -e 'use IO::Socket::UNIX; IO::Socket::UNIX->new(Local => "zoo/telemetry.sock", Listen => 1) or die $!;'

# ---------------------------------------------------------------- pipe/
mkdir -p pipe
mkfifo pipe/inbox
printf 'Anything written into inbox is read once, by whoever is listening.\n' > pipe/README.txt

# ---------------------------------------------------------------- salvage/feed/
# Recovered from the maintenance deck. The summariser's input is not a file.
mkdir -p salvage/feed
mkfifo salvage/feed/strain-input
printf '2187-05-21 mean 0.42 max 0.51 n=1440\n' > salvage/feed/strain-summary
printf 'feed rebuilt after the deck work. summariser still not producing.\nlooked at the log dir, everything is there. later\n' > salvage/feed/notes.txt

# ---------------------------------------------------------------- console/
mkdir -p console
printf 'scratch space\n' > console/scratch.txt

# ------------------------------------------------------------- ownership
# cadet owns everything. The device nodes stay cadet-owned on purpose: the point
# of exercises 27-28 is that cadet cannot CREATE one, not that cadet cannot own one.
# (A chown to root here does not stick in this container anyway.) Reading the
# block node is refused by the container device policy, not by these bits --
# that is exercise 30.
chown -R cadet:crew "$LAB"
chmod 644 zoo/null-clone
chmod 660 zoo/dev-sensor

# ------------------------------------------------------------- timestamps
# Set last, after every chmod/chown, so nothing overwrites them.
touch -d "2187-05-21 09:31:00" salvage/feed/strain-input
touch -d "2187-05-21 09:30:00" salvage/feed/strain-summary
touch -d "2187-05-23 16:02:00" salvage/feed/notes.txt
touch -h -d "2187-05-18 11:00:00" zoo/alias
touch -d "2187-05-18 11:00:00" zoo/manifest.txt zoo/relay zoo/bay
