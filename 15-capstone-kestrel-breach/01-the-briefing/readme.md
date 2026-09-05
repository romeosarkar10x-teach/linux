# 01 — The briefing

Deck 3 recertifies in September. You have been aboard twenty-two days, you are
the only sysadmin, and across fourteen chapters you have found fourteen things
that each looked, on its own, like ordinary neglect.

Nobody has asked you for a report. You are going to write one anyway, because
the next person in this chair will otherwise start where you started.

This lesson is not about a new command. It is about the standard the report is
held to, and about building the case file you will fill for the rest of the
chapter.

## The standard

Read `brief/rules-of-engagement.txt`. All eight rules, properly. The one that
does the work is rule 7:

> A conclusion you cannot source is struck from the report, however correct it
> happens to be.

That is harsher than it sounds. It means a finding you are certain of, that
happens to be true, gets deleted if you cannot name the file it rests on. Not
because certainty is bad, but because a reviewer who cannot re-check your work
has to take your word for it, and "take my word for it" is not a finding.

## What sourcing an artefact means

Four facts, taken **before you touch anything**:

```
$ stat -c '%n  %s bytes  %y' station/summariser/run.log
station/summariser/run.log  2145 bytes  2187-05-24 02:00:00.000000000 +0000
$ sha256sum station/summariser/run.log
ac781cb71c8e614f6ce42f8881d1a75a0361ae3e81248dc199f039334f565ea9  station/...
```

Path, size, mtime, hash. `stat -c` takes a format string: `%n` name, `%s` size
in bytes, `%y` human-readable mtime, `%Y` mtime as a Unix timestamp, `%U` owner,
`%a` permission bits in octal. You met `stat` in chapter 2 and again in 3; here
it stops being a curiosity and becomes the thing that makes a claim checkable.

The hash matters for a reason chapter 14 already made concrete: it is the only
part of that list that changes if the bytes change. Size and mtime can both be
made to lie, and mtime can be set with `touch -d` by anyone who can write the
file.

> **Take the hash first.** A hash taken after your first edit is a hash of your
> edit. There is no way to recover the original number afterwards, and a claim
> whose hash was taken late is a claim a careful reviewer will reject.

## Says, then means

Rule 4 splits every claim in two:

- **says** — what is literally in the file. Somebody else reading the same file
  must be able to agree with this sentence without knowing anything about you.
- **means** — what you take from it. This is allowed to be wrong. It is your
  reading, it is labelled as your reading, and a reviewer can reject it without
  rejecting the evidence.

Wrong:

> The run log was tampered with to hide manual runs.

Right:

> **says:** `station/summariser/run.log` has 26 lines with unbroken daily
> timestamps from 2187-05-12 to 2187-05-24, and sequence numbers that run
> 0412–0431 then resume at 0438.
> **means:** six numbered records that once existed between those two lines are
> not in this file.

The second version survives a reviewer who disagrees with you. The first does
not survive a reviewer at all.

## The case file

`case/` is yours. One claim per file, `case/artefacts/claim-NN.md`, built from
`case/TEMPLATE.md`. It will look like over-formalising for the first three
claims and then it will start paying for itself, because by lesson 05 you will
have more claims than you can hold in your head.

`bin/roe-check FILE` reads one claim and tells you what is wrong with it:

| exit | meaning |
|---|---|
| 0 | well formed |
| 2 | file missing or unreadable |
| 3 | a required field is absent |
| 4 | a field still holds its `<placeholder>` |
| 5 | the `sha256` field is not 64 hex characters |
| 6 | the path in `artefact:` does not exist |

It checks *form*, not truth. A perfectly formatted claim about the wrong file
exits 0. That is the limit of every checker you will ever write and it is worth
sitting with for a second.

## Naming people

Rule 6. `dorn` is a username. A file owned by uid 1003 is a fact about a uid.
"dorn wrote this" is a conclusion that needs the same sourcing as any other —
and in most cases the honest sentence is the narrow one:

> **says:** owner is `dorn`, mtime 2187-05-19 22:04.
> **means:** written by something running as `dorn` on that date.

Something running as an account is not the same as a person sitting at a
keyboard, and the difference is going to matter in lesson 02.

## Three artefacts to practise on

`station/` holds three of the fourteen, chosen because each fails a different
way:

- `station/summariser/run.log` — a file with something missing from the middle.
- `station/mounts/raw-strain` — a symlink whose target is gone. The link is
  honest; the thing it pointed at left.
- `station/audit/MANIFEST.txt` — a list of files, and no files.

You have solved all three shapes before, in chapters 6, 3 and 4. What is new is
writing each one down so that somebody who was not there can check it.

## Before you move on

- `stat -c '%n %s %y'` and `sha256sum` are how an artefact gets sourced, and
  the hash is taken before anything else.
- **says** is the file's content; **means** is your reading, labelled.
- `roe-check` validates form, never truth.
- A username in a file is evidence about an account, not about a person.
- An unsourced conclusion is struck even when it is right.
