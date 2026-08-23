#!/usr/bin/env bash
# setup.sh -- seeds /labs/03-files-links-and-types/01-everything-is-a-file
#
# Artifacts -> exercises:
#   types/                -> ex 1-9  (one of each of the seven types, in one directory, so a
#                            single `ls -l` shows all seven first characters at once)
#   types/void            -> character device, major 1 minor 3 -- a second /dev/null. Readable by
#                            cadet, returns EOF immediately (ex 6, 15)
#   types/scratch-disk    -> block device, major 7 minor 200. No loop driver is attached, so
#                            reading it fails -- that failure is ex 16
#   types/pipeline        -> FIFO. Opening it for reading blocks; ex 17 is about why
#   types/control.sock    -> AF_UNIX socket, created by perl(1). Nothing listens on it
#   types/pointer         -> symlink to regular.txt (ex 4, 8: ls -l shows l, file follows it)
#   manifest/             -> ex 10-14 (file(1) against lying extensions and no extensions)
#   manifest/hull-log     -> ELF binary, no extension
#   manifest/survey.txt   -> gzip data with a .txt name
#   manifest/panel.png    -> ASCII text with a .png name
#   manifest/empty        -> zero bytes: file(1) says "empty", not "text"
#   manifest/utf8.txt     -> UTF-8 with a non-ASCII byte, so file(1) names the encoding
#   manifest/latin1.txt   -> ISO-8859-1 byte 0xE9, which is NOT valid UTF-8 (ex 13)
#   sizes/                -> ex 18-20 (/proc-style zero sizes vs real ones is chapter 2 revision;
#                            here it is device size vs file size)
#
# Idempotent: removes its own tree first, creates nothing outside LAB.
# Requires root for mknod (kestrel seed runs setup.sh as root).
set -euo pipefail

LAB="/labs/03-files-links-and-types/01-everything-is-a-file"
rm -rf "$LAB"
mkdir -p "$LAB"
cd "$LAB"

# ---- types/ : all seven, in one listing ------------------------------------
mkdir -p types/deck-3
printf 'maintenance deck 3, panel inventory\n' > types/regular.txt
ln -sfn regular.txt types/pointer
mknod types/void c 1 3            # character device: a second /dev/null
mknod types/scratch-disk b 7 200  # block device: no backing store attached
mkfifo types/pipeline
perl -e 'use Socket; socket(S, AF_UNIX, SOCK_STREAM, 0) or die "socket: $!";
         unlink "types/control.sock";
         bind(S, sockaddr_un("types/control.sock")) or die "bind: $!";'
chmod 666 types/void types/pipeline
chmod 660 types/scratch-disk

# ---- manifest/ : file(1) targets -------------------------------------------
mkdir -p manifest
cp /bin/true manifest/hull-log                                  # ELF, no extension
printf 'deck 3 hull survey, 2187-06-02\n' | gzip -c > manifest/survey.txt   # gzip, .txt
printf 'panel 07 seated\npanel 08 seated\n' > manifest/panel.png            # text, .png
: > manifest/empty
printf 'sensor drift \xe2\x80\x94 deck 3\n' > manifest/utf8.txt             # UTF-8 em dash
printf 'r\xe9paration panneau 07\n' > manifest/latin1.txt                   # ISO-8859-1 e-acute
printf '#!/usr/bin/env bash\necho panel ok\n' > manifest/panelcheck
chmod +x manifest/panelcheck

# ---- sizes/ : what "size" means for something that is not storage ---------
mkdir -p sizes
head -c 4096 /dev/zero | tr '\0' 'p' > sizes/four-k.txt
: > sizes/nothing.txt

chown -R cadet:crew "$LAB"
echo "seeded $LAB"
