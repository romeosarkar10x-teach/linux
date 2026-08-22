# Orbital Station Kestrel

## Your posting

Kestrel is a long-haul research station: sixty-odd people, four decks, and a rack of Linux machines
that have been running continuously for eleven years. Nobody reboots them. Nobody is entirely sure
what half of them do.

You are the new junior systems administrator. You are also, at present, the *only* systems
administrator.

Your predecessor — **dorn** — left three weeks ago. The official log says "personal leave,
indefinite." The handover documentation is a single file called `notes.txt` containing the word
`later`. The systems he left behind are a museum of half-finished work: configs edited at 04:00 and
never tested, logs written to directories that no longer exist, permissions set by someone who was
in a hurry, cron-shaped scars where automation used to be, and processes running under accounts
that shouldn't have accounts.

Some of it is neglect. Some of it isn't. That distinction is the through-line of this course, and
it resolves in Chapter 15.

## The crew you'll deal with

| | |
|---|---|
| **you** — `cadet` | junior sysadmin, three weeks in, sole survivor of the IT department |
| **rhea** | chief engineer. Precise, impatient, correct. Owns the engineering data and will notice if you touch it. |
| **cass** | comms officer. Generates a genuinely absurd volume of log traffic and would like it if you made sense of it. |
| **dorn** | your predecessor. Gone. His fingerprints are on everything. |
| **ops-bot** | an automation account. Runs jobs. Runs them badly. Nobody remembers configuring it. |

Groups: `crew` (everyone), `engineering` (rhea's people), `ops` (station automation).

## How the story works

Every chapter is an **incident** — something broke, or somebody broke it — and the chapter teaches
exactly the tools that incident needs. The final lesson in most chapters is the incident itself,
and it hides a **flag**: a string shaped like

```
KESTREL{something_like_this}
```

Flags are planted so that only that chapter's skill reaches them. You can't shortcut a Chapter 12
flag with a Chapter 6 one-liner; it's been checked. When you find one:

```bash
kestrel flags submit 'KESTREL{...}'
```

The helper verifies it against a hash — it never stores or shows the answer, and neither will any
agent you ask.

## A note on the frame

The story is here because it's more fun to trace a runaway process that's melting the station's CPU
than to trace `process_3` in `test_dir_2`, and because a real incident gives every command a reason
to exist. It never replaces the explanation. The notes are the course; the station is the room it
happens in.

Deck plans are on the wall by the galley. Your terminal is the one with the cracked bezel.

Welcome aboard, cadet.
