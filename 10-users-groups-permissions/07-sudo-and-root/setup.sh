#!/usr/bin/env bash
# setup.sh -- seeds /labs/10-users-groups-permissions/07-sudo-and-root
#
# THE ANSWER KEY. Students are told not to open this.
#
# Teaches: what sudo is (a setuid program that consults a policy), what root
# actually is (uid 0, exempt from the permission checks rather than granted
# everything), env_reset and secure_path, the redirection trap, sudo -u,
# sudo -i vs -s, and how to write an access request that can be granted.
#
# Nothing here modifies the real sudo policy. policy/ contains PAPER copies
# for reading; the exercises are explicit that editing /etc/sudoers is out of
# bounds and that this lab's copies are not live.
#
# Idempotent: removes its own tree first, creates nothing outside LAB.
set -euo pipefail

LAB="/labs/10-users-groups-permissions/07-sudo-and-root"
rm -rf "$LAB"
mkdir -p "$LAB"/{policy,requests,jobs,notes,scratch}
cd "$LAB"

# --- policy/ : paper copies, not live --------------------------------------
cat > policy/README <<'EOF'
Paper copies. Nothing in this directory is read by sudo. Editing these files
changes nothing on the station and editing /etc/sudoers is out of bounds for
this lesson -- a broken sudoers file locks everybody out, including the person
who broke it, and there is no second way in on a station.
EOF

cat > policy/sudoers.example <<'EOF'
# An example policy. Read it; do not copy it anywhere.

Defaults        env_reset
Defaults        mail_badpass
Defaults        secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
Defaults        use_pty

# user  host = (runas_user:runas_group) commands
root    ALL=(ALL:ALL) ALL
%sudo   ALL=(ALL:ALL) ALL

# Narrower grants, of the kind an access request should ask for.
cass    kestrel=(root) NOPASSWD: /usr/bin/systemctl restart hydroponics
dorn    kestrel=(rhea) /opt/kestrel/bin/summarise
%ops    kestrel=(root) /usr/sbin/service, /usr/bin/journalctl

# What NOT to grant, and why it is worse than it looks:
#   probe  kestrel=(root) /usr/bin/find
# find can run arbitrary commands with -exec. Granting find is granting a
# shell. The same is true of anything with an editor, a pager, or -exec.
EOF

cat > policy/grants.txt <<'EOF'
Four grants, as they were actually requested. Two are fine. Two are not.

  A) haldane  kestrel=(root) /usr/bin/tail -f /var/log/exporter.log
  B) probe    kestrel=(root) /usr/bin/vi
  C) cass     kestrel=(root) NOPASSWD: /usr/bin/systemctl restart hydroponics
  D) survey   kestrel=(root) /opt/kestrel/bin/*

Notes taken during review, unattributed:

  "A looks narrow but the argument list is not fixed."
  "B was granted on a Tuesday and nobody asked what vi can do."
  "C is the only one anybody has ever had to use twice."
  "D was written by somebody in a hurry, and the star is doing the work."
EOF

# --- requests/ : the thing the roleplay is about ---------------------------
cat > requests/draft-1.txt <<'EOF'
To: rhea
From: cadet

I need access to engineering.

Thanks.
EOF

cat > requests/reply-1.txt <<'EOF'
From: rhea

No.

That is not a request, it is a category. Tell me:

  what you need to do,
  to which path,
  for how long,
  and why the thing you actually need cannot be done another way.

If the answer to the last one is "it can", do that instead. I am not being
difficult. I have to be able to say, later, exactly what I granted and to
whom, and "access to engineering" is not a sentence I can defend.
EOF

cat > requests/template.txt <<'EOF'
An access request that can be granted
-------------------------------------

  Who:      the account, not the person's job title.
  What:     the exact operation. Read? Write? Run?
  Where:    the exact path or paths. Not "the archive" -- the path.
  As whom:  root, or a service account? Often you do not need root.
  How long: an afternoon, a shift, permanent. Say which.
  Why not:  what you tried, and why the ordinary route did not work.

The last line is the one people skip, and it is the one that gets requests
granted, because it is the only line that shows the request is necessary.
EOF

# --- jobs/ : scripts where exactly one line needs privilege ----------------
cat > jobs/collect-counts.sh <<'EOF'
#!/usr/bin/env bash
# Reads two files and writes a summary. One line of this needs root and the
# rest does not. Find it before you reach for sudo.
set -euo pipefail
out=${1:-/tmp/counts-summary.txt}
echo "run at $(date -Is)"          >  "$out"
echo "uptime: $(uptime)"           >> "$out"
wc -l < /etc/passwd                >> "$out"
head -1 /etc/shadow                >> "$out"   # <-- this one
echo "done"                        >> "$out"
EOF

cat > jobs/tidy.sh <<'EOF'
#!/usr/bin/env bash
# Somebody's tidy script. Read it before you run anything, and note what it
# would do if the variable were empty.
set -eu
TARGET="${TARGET:-}"
echo "would remove: ${TARGET}/*"
# rm -rf "${TARGET}"/*     <-- commented out on purpose. Leave it that way.
EOF

chmod 755 jobs/collect-counts.sh jobs/tidy.sh

# --- notes ------------------------------------------------------------------
cat > notes/sudo.txt <<'EOF'
What sudo is
------------

sudo is an ordinary program with the setuid bit set and root as its owner, so
it starts running as root no matter who launched it. The first thing it does
is consult a policy -- /etc/sudoers and the files in /etc/sudoers.d -- to
decide whether you were allowed to ask.

  sudo CMD              run CMD as root
  sudo -u USER CMD      run CMD as USER instead
  sudo -l               list what the policy permits you to run
  sudo -i               a login shell as root: root's environment, root's HOME
  sudo -s               a shell as root, keeping most of your environment
  sudo -v               refresh the timestamp without running anything
  sudo -k               forget the timestamp

Two things about the environment, both deliberate:

  env_reset     sudo throws away most of your environment before running the
                command. Variables you exported are not there.
  secure_path   sudo replaces PATH with a fixed list from the policy, so that
                a program you put earlier in your own PATH is not what runs.

Both exist because the command runs as root, and the environment is the
easiest thing for an attacker to control.

Two things sudo cannot do, and the reason is the same for both:

  sudo echo hi > /root/f    the redirection is done by YOUR shell, before sudo
                            runs at all. Your shell is not root.
  sudo cd /root             cd is a shell builtin. There is no program to run.

For the first, the fixes are `sudo tee`, or `sudo sh -c '...'` -- and both
mean thinking about what you are handing to a root shell.
EOF

cat > notes/root.txt <<'EOF'
What root is
------------

root is uid 0. That is the whole definition. The name is a convention in
/etc/passwd; the kernel checks the number.

uid 0 is not "granted every permission". It is **exempt from the permission
check** -- the kernel skips the owner/group/other comparison for uid 0
entirely. The distinction matters: root does not appear in any group, does not
need the file's mode to say anything, and cannot be locked out by a mode.

There is a short list of things only uid 0 may do, and you have met two:

  chown a file to another user
  bind a port below 1024 (chapter 13 territory, not ours)
  read any file regardless of mode
  kill any process regardless of owner

A file owned by root with mode 000 is readable by root. A directory root
cannot enter does not exist.

su vs sudo
----------

  su -        become root by typing ROOT's password.
  sudo CMD    run one command as root, authorised by a policy, using YOUR
              password (or none, if the policy says so).

sudo is preferred not because it is safer to use, but because it is
attributable and revocable: the policy names the account, and the log names
the account. Nobody has to share a root password, and removing somebody's
access does not mean changing everybody's.

On this station root has no password set at all, so `su` cannot succeed. That
is normal on modern systems and it is on purpose.
EOF

cat > notes/page.txt <<'EOF'
From: rhea
To: cadet
Re: your request

I have your note. "I need access to engineering" is not a request.

I am not asking you to justify yourself to me personally. I am asking because
in six months somebody will ask me what I granted and to whom, and I would
like to be able to answer with a path and a date instead of a shrug.

Read requests/template.txt. Send me the second draft.
EOF

printf 'Yours.\n' > scratch/README

chown -R cadet:crew "$LAB"
find . -type d -exec chmod 755 {} +
find . -type f ! -name '*.sh' -exec chmod 644 {} +
chmod 755 jobs/collect-counts.sh jobs/tidy.sh

find . -exec touch -h -d '2187-06-21 10:00:00' {} +
touch -h -d '2186-08-14 09:30:00' notes/sudo.txt notes/root.txt
touch -h -d '2187-06-21 08:15:00' notes/page.txt requests/reply-1.txt
touch -h -d '2187-06-21 08:02:00' requests/draft-1.txt

echo "seeded $LAB"
