# Tutor notes — Forensics

**Never give an answer.** One fact, or one question, then stop.

This is the hardest lesson in the chapter and the one students most want to
rush, because the shape of a story appears about twenty minutes in and the
remaining thirty exercises feel like paperwork. They are not. The paperwork is
the lesson.

The first thing that will happen is that a student notices every ctime is
today, panics, and concludes the evidence is fabricated. Confirm the
observation — it is a good one — and then ask what `cp -a` does to ctime. The
readme covers it. This is the moment to say plainly that they are working on a
copy, that a copy cannot carry ctime, and that this is why real forensic work
images disks instead of copying files.

The second thing is the two clusters, and they will find them quickly. What
they will not do is separate the cluster from the story. Watch every sentence
for a purpose smuggled in as an observation: "rhea set up the audit so that" is
a `means` line pretending to be a `says` line. The four artefacts of cluster 1
are the biggest trap in the chapter — everything visible points one way, one
account owns nearly all of it, and the student who writes a name into a
conclusion here will carry that error through lessons 04 and 05. Do not warn
them off it. Ask what would have to be true for the other reading.

Exercise 29 — `.bashrc` owned by an account nobody logs in as, modified at
23:58 — is the pivot of the whole chapter, and it is deliberately not
explained here. If a student asks what it means, the answer is "write it down;
lesson 04 tells you what reads that file." Nothing more.

Exercise 40 is the one to spend real time on. `exceedances 0` is true. The
summariser clamps. Both facts sit in front of them and the temptation is to
write "the report is false". It is not false; it is uninformative, and the
difference between those two sentences is the difference between a report that
survives review and one that does not.

Exercise 28 — `rota.txt` — exists so that something can be correctly
**rejected**. A student whose case file has no rejected artefacts has not been
selecting, only collecting.

On naming: the accounts `rhea`, `dorn`, `cass` and `ops-bot` may be named as
accounts, because a username is a fact about a file. No sentence in any claim
file should attribute an intention to any of them. Rule 4 and rule 6 from
lesson 01 are the whole standard, and you should be quoting them by number.

If they get stuck on the manifest arithmetic (43), the fact they are missing is
usually the sample rate — ask what one sample looks like in bytes.
