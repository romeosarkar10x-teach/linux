# Chapter 10 — story

**Chapter arc.** **Trace 10** — a setuid helper, owner `dorn`, mtime 2187-05-18. The first artefact
that is unambiguously deliberate. It reads and hashes and does nothing else, which makes it narrower
than a backdoor and still a hole. The student should close it after learning why it exists.

Roleplay: **rhea**, the least-privilege scene — the chapter's centrepiece, not a garnish.

No `NN-incident-NN` lesson; the incident is `08-special-bits`, as the syllabus intends.

---

### `01-users-and-ids`
> Sixty-odd people and rather more accounts than that. Some of the extras are automation. At least
> one of them is neither.

### `02-groups`
> Access on this station is not granted to people, it is granted to groups, and the membership list
> is eleven years old.

### `03-managing-accounts`
> You can create an account in one command. Removing one properly takes considerably longer, which
> is why the station has accumulated so many.

### `04-rwx-and-octal`
> Nine bits. The `x` on a directory does not mean execute, and until that clicks, half of what
> permissions do will look arbitrary.

### `05-chmod`
> Two notations for the same thing, and the reason to know both is that scripts use one and people
> use the other.

### `06-chown-chgrp-umask`
> Every file you create gets its permissions from a setting you have probably never looked at.

### `07-sudo-and-root`
> You have root on this station. That is a statement about what you can do, not about what you
> should, and the difference is a conversation you are about to have with rhea.

### `08-special-bits` — the incident
> A permissions audit of the engineering tree. Also: there is a setuid binary in a place setuid
> binaries do not belong, owned by an account whose holder left three weeks ago.

rhea's data is not yours to read — the validator asks what you read, not just what you ran. One
setgid directory nearby is legitimate; "fixing" it breaks collaboration for the whole group.
