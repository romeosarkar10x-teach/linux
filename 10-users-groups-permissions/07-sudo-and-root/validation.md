# 10/07 — Validation rubric

For the validator agent. No script grades this lesson. Judge the written answers.

## Non-negotiable

1. **Root is exempt from the permission check, not maximally permitted.** Exercises 2 and 3. The
   student must state this as a property of the check itself, and must be able to say why root's
   group list is short and still sufficient. An answer of the form "root has all permissions" has
   not passed, even though it predicts the same outcomes.

2. **`sudo` is a setuid-root binary that consults a policy.** Exercises 10–13. Both halves: the mode
   (`4755`, owner root, `s` in the owner's execute position) *and* the check. A student who says
   "sudo elevates you" has described nothing. `sudo` is root before it decides anything.

3. **`env_reset` and `secure_path`, demonstrated.** Exercises 18–23. They must have run the PATH
   hijack and be able to say why the fake `id` won for their shell and lost for `sudo`, in terms of
   which `PATH` each one searched.

4. **Redirection belongs to the shell.** Exercises 26–28. The failing process is their own shell, and
   it fails before `sudo` runs. "You need `tee`" without the mechanism does not pass.

5. **A grant of a program that can run other programs is a grant of a root shell.** Exercises 47, 48,
   51. At least three examples beyond `vi`.

6. **The written request (67) has all six elements**: who, what, where (a concrete path), as whom,
   how long, and why the ordinary route does not work. A missing duration is a fail; so is a request
   for root where `sudo -u` would do.

## Should be present

- `id -u` as the way a script tests for root, not `whoami` (exercise 6).
- Root has no password here and `su -` therefore cannot succeed; that this is the default rather than
  a defect (exercise 8).
- `sudo -v` demands a password despite `NOPASSWD`, and why (exercise 17).
- `sudo -i` versus `sudo -s`, distinguished by working directory and login shell rather than by
  `HOME` — both give `HOME=/root` (exercises 31, 32).
- `SUDO_USER` survives `env_reset` and is how a root-run script learns who invoked it (exercise 19).
- `tee` preferred over `sh -c` for reviewability, with the injection reason (exercise 29).
- `sudo -u rhea` preferred over `sudo` for a question about rhea's access, because failure is
  informative (exercises 36, 37).

## The grants, 49 to 56

Ranking need not match the key. **C first and B last** are required; A and D may be swapped if the
swap is argued — a student who counted `/opt/kestrel/bin` (215) and reasoned about future contents
has earned D's placement either way.

Grant A's flaw must be stated as **unpinned arguments**, with a concrete exploitation
(`sudo tail /etc/shadow`). "It's too broad" is not the answer.

Exercise 55's wrapper must take **no arguments** and hardcode the path. A wrapper that accepts a
filename has reproduced grant A with extra steps.

**Exercise 56 is the integrity check.** The reviewer notes in `grants.txt` are unattributed. Any
answer that names a person, or that treats "somebody was in a hurry" as evidence about a person, fails
that exercise regardless of the rest. The defensible statements are about the *grants*: what they
permit, and that a glob was used.

## The script, 57 to 64

- 59 must mention that the **output file becomes root-owned**, not only that the script runs as root.
- 61's rewrite must put `sudo` on the `head` line only, and must not wrap the redirection in it.
- 63 must identify the `/` outside the quotes. "It's not quoted properly" is wrong and should be sent
  back — it *is* quoted, and quoting is not the defence.
- 64 must reject `set -u` with the set-versus-empty distinction, and use `${TARGET:?}` or an explicit
  emptiness test.

## Lab state

The lesson writes only in `scratch/`, and exercises 26–27 create and remove `/etc/zz-test`. Check it
is gone:

```
ls /etc/zz-test        # should be: No such file or directory
stat -c '%a %U:%G' scratch    # should be: 755 cadet:crew
ls scratch/bin         # should not exist
```

If `scratch` is still `775`, the student did exercise 39 and did not put it back — minor, mention it.
If `/etc/sudoers` or anything in `/etc/sudoers.d/` has been modified, that is out of bounds and the
station should be reseeded before lesson 08, which depends on the policy being intact.

## Not demonstrable here

Nothing runs syslog in this container, so there is **no `/var/log/auth.log`**. Any answer claiming to
have inspected sudo's logging has fabricated it. The correct statement is that sudo logs each
invocation on a real station and that this one cannot show it.

## The failure that looks like success

Every command run, every result correct, and a request in 67 that reads: *"Please grant cadet sudo
access to the engineering archive."* That is draft 1 with better manners. Probe with the four
questions from rhea's reply and see whether the student can answer them without going back to the
lab. If they cannot, the lesson has not landed, whatever the rest of the sheet looks like.
