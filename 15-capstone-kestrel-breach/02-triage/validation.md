# Validation — Triage

Judged by an agent reading the student's work and asking questions. No script,
no score. There is no flag in this lesson.

Ask the student to show their case file and their terminal history, then check
the following. Every one of these is a hard requirement.

The account inventory is right and drawn from the system, not from memory: six
accounts at uid 1000–1005, `ops-bot` at 1004 with `/usr/sbin/nologin`, `crew`
holding rhea/cass/dorn/cadet, `ops` holding dorn/ops-bot, `engineering`
holding rhea alone. A student who lists these without a command that produced
them has not done the exercise.

They can state what a locked password field means and, in the same breath, that
it does not stop `sudo -u` from running a program as that account. If they
cannot separate those, they will misread the whole chapter.

They ran the summariser, found it, and described its process tree — parent
`sudo` owned by root, child `sleep` respawned each cycle — and can say why a
root parent can produce a non-root child.

They hit the `sudo` redirection failure and can explain it correctly: the
shell, running as cadet, opens the file before sudo is executed. "sudo didn't
have permission" is wrong and must be corrected.

They found `var/summary.err` and the clamp lines, and reported that the
warnings existed all along in a file nobody reads. A student who reports only
`summary.log` missed the point of the lesson.

They deleted `summary.log`, found it still open with `(deleted)` and NLINK 0,
recovered it through `/proc/PID/fd/3`, and can state what would have been lost
had the process been restarted first.

At least three claim files, six fields each, hashes matching what is on disk
right now. Re-hash one of them yourself and compare.

No claim contains a statement about anyone's intent, and no person is named.
Accounts may be named. If a `says` line reads as motive, the claim fails.

The `eng-svc` entries are recorded as an open question — appears in
`eng-access.log` on 2187-01-18, absent from `/etc/passwd`, absent from
`crew-shell.log` — with no conclusion attached. A student who has decided what
`eng-svc` was has failed this item, however plausible the theory.

The out-of-order line in `crew-shell.log` is identified as their own arrival
and dismissed with a reason, not carried forward as a finding.

The `dorn` logout at 2187-05-24 04:12:38 is recorded, and they noticed it lands
in the same minute as `notes.txt` from lesson 01. Corroboration across two
artefacts, stated as corroboration and nothing more.

Ask one closing question: *"Which of your findings would survive if the
summariser process were killed right now?"* The expected answer is that the
files survive and everything read out of `/proc` does not — which is why they
were written down when they were seen.
