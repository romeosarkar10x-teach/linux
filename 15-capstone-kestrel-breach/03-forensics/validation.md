# Validation — Forensics

Judged by an agent reading the student's case file and terminal history. No
script, no score, no flag in this lesson.

The timeline first. They must be able to produce, on request and from a
command rather than from notes, all fourteen evidential artefacts in mtime
order with owner. Ask them to regenerate it in front of you. A timeline that
includes the three scaffolding files stamped 2187-06-14, or that presents them
as evidence, fails.

They can state what mtime, ctime, atime and birth each mean, and — this is the
one — why every ctime in the lab is today's date. If they think that makes the
evidence fake, correct it: they are working on a copy, ctime cannot survive a
copy, and that is a limitation of the material, not a finding about the
station. If they had never noticed, ask them to `stat` a file now.

Both clusters identified by date range and by the accounts in them: 05-15 22:40
to 05-17 23:51, and 05-19 23:58 to 05-20 01:31, roughly 48 hours apart. They
must characterise each cluster by the **kind** of activity — setting up versus
checking — without asserting anyone's purpose. A claim file containing a motive
fails this item outright, no matter how good the rest of the work is.

`checksums-2186.recheck.txt` is recorded as written by a different account from
everything else in that directory, and stated as a lead rather than a finding.

The `.bashrc` anomaly is written down and **not** explained. A student who has
already decided what it means has run ahead of their evidence; that is a fail
on this item even if the guess is right, and you should say so in exactly those
terms.

The two checksum files are diffed, with the two changed entries distinguished:
one hash wholly different, one differing by a single character at position 3.
They can say why a one-character difference is far more likely to be a
transcription error than a data change, and they know they cannot settle it
because the `.dat` files do not exist here.

The summariser diff is done and stated behaviourally: values above 6 are
reported as 6.0. Their sentence about `deck3-report.txt` must be the careful
one — that `exceedances 0` is consistent with both no exceedances and with
clamped exceedances, and the report cannot tell you which. "The report is
falsified" fails.

The dangling symlink is claimed correctly: what is on disk, its own mtime of
2187-05-22 21:40, and no assertion about whether the target ever existed. They
know why `bin/timeline` omitted it and can point at the line.

`home/cass/rota.txt` appears in their work as considered and rejected, with the
reason. If nothing has been rejected, ask them what in this lab is not
evidence.

At least five claim files, six fields each, hashes matching what is on disk
now. Re-hash two of them yourself.

Close with one question: *"Name the artefact you would most want that you do
not have, and say what it would settle."* A strong answer names the 2186 raw
files or the archive summary directory, and says it would settle whether the
q3 hash difference is a data change or a typo. A student who cannot name a
missing artefact has been reading the evidence as complete.
