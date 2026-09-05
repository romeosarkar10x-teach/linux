# Remediation — close, fix, stop, restore, prove

Three lessons of looking. Now you change something, and every change you make
is a change to a system somebody else depends on.

There are five things wrong in this lab. You will find all five in about ten
minutes. The lesson is not finding them; it is the order you fix them in, the
record you keep, and the difference between "I fixed it" and "here is the
command that shows it is fixed".

## The order

**Close** what is still open. If something can still be used against the
system, that comes first, before anything you find interesting.

**Fix** what is wrong. Restore correct behaviour, from a known-good copy if you
have one.

**Stop** what is running. A process started before your fix is still running
the old code; it read the file into memory at exec time and will not notice
your edit.

**Restore** what was lost, if it can be recovered. Some of it cannot.

**Prove** it. Every one of the above gets a command whose output you can paste,
run *after* the change, showing the new state.

That order has a reason. Fixing a file while an exploitable hole is still open
means you may be fixing it twice. Stopping a service before you have fixed its
code means restarting it into the same fault. And proving before you have
finished means proving the wrong thing.

## Permissions you will meet

```
$ stat -c '%a %U:%G %n' station/var
1777 ops-bot:ops station/var
```

Four digits. The leading `1` is the **sticky bit** on a directory: anyone may
create files, but only a file's owner (or the directory's owner, or root) may
delete or rename it. That is what makes `/tmp` survivable. The `777` is the
real problem — every account on the station can write here.

```
$ stat -c '%a %U:%G %n' bin/eng-scan
4755 root:root bin/eng-scan
```

The leading `4` is **setuid**. On an executable binary it means the program
runs with the *file owner's* effective user id rather than the caller's, which
is how `passwd` edits `/etc/shadow` when you are not root. `find / -perm -4000`
lists every one on a system, and reviewing that list is standard practice.

Set the bits with symbolic modes, which are far harder to get wrong than
octal:

```
chmod u-s FILE          # clear setuid
chmod o-w DIR           # remove write for others
chmod g+rwX,o-rwx DIR   # capital X: directories and already-executable files only
```

`chmod 755` sets every bit at once and silently wipes anything you did not
think about, including the sticky bit. Prefer `u-s`, `o-w`, `g+w`.

## Software sources

An apt source marked `[trusted=yes]` tells the package manager to install from
it without verifying any signature. Whoever controls that mirror, or anything
on the path to it, controls what gets installed. Removing the line closes it;
the packages already installed from it stay installed, and that is a separate
question you should write down rather than solve today.

## Editing what is running

A running program does not re-read its own file. Change
`station/summariser/strain-summary` on disk and the process that is already
running keeps producing old output until it is stopped and started again. This
is why "stop" is its own step, and why the check for it belongs in your proof.

Stop things the ordinary way first:

```
pkill -f summariser/loop        # SIGTERM: asks the process to exit
pkill -9 -f summariser/loop     # SIGKILL: last resort, no cleanup, buffers lost
```

`-9` skips the program's own shutdown, so anything it was buffering is gone.
On a machine you are investigating that can destroy evidence — lesson 02 showed
you exactly how. Reach for it only when `SIGTERM` has visibly failed.

## Restoring

`backup/strain-summary.orig` is a known-good copy. Copying it back over the
live file is a change like any other: `cp` it, then diff it, then say in your
record which direction the copy went.

Some things do not come back. `station/var/deck3-report.txt` was produced by
the faulty program from data you still have in `station/var/raw-sample.txt`.
Regenerating it is honest work. What you cannot do is recover the reports from
weeks whose raw data is gone, and your record should say so plainly.

## Proving

`bin/postcheck` runs six checks and prints `PASS` or `FAIL` for each, exiting
non-zero if any failed. Read it before you trust it. It checks **state** — a
mode, a string in a file, whether a process is running. It cannot tell whether
you understood anything, it cannot tell whether your fix was the right fix, and
a green run is the beginning of your report rather than the end of it.

Record every change in `case/TEMPLATE.md`'s six fields: what you changed, why,
the before state, the after state, the command that verified it, and whether it
can be undone.

## Before you move on

- All five faults found, and fixed in the order above.
- `./bin/postcheck` exits 0.
- Six change records, one per change, each with a verification command.
- A regenerated report, and a sentence about what could not be regenerated.
- One thing you decided *not* to change, with the reason.
