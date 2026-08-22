# STORY.md — Narrative bible

The user chose a **story-driven CTF world** over neutral technical labs. Fun is a stated
requirement of the course, and the story is the mechanism.

## Premise

The student is the newly posted **junior systems administrator aboard Orbital Station Kestrel** — a
long-haul research station whose previous sysadmin left abruptly, badly, and possibly on purpose.
The station's Linux systems are a mess of half-finished configs, mislabeled logs, orphaned
processes, and permissions nobody has audited in years.

Each chapter is an **incident**. The student fixes it with exactly the tools that chapter teaches.
A thread of sabotage runs underneath, resolving in the Chapter 15 capstone.

## Cast

| Name | Role | Used in |
|---|---|---|
| **cadet** | the student's own account | everywhere |
| **rhea** | station chief engineer, owns `/labs`-adjacent engineering files | ch 9–10 |
| **cass** | comms officer, generates the log traffic | ch 6–7 |
| **dorn** | the previous sysadmin — departed, left the mess | ch 11, 15 |
| **ops-bot** | an automation account that runs scheduled jobs badly | ch 9, 12, 15 |
| groups | `crew`, `engineering`, `ops` | ch 10 |

## Chapter incidents

| Ch | Incident |
|---|---|
| 0 | Boarding: get your quarters (VM), your workstation (container), your ID |
| 1 | Somebody typed a command that broke the console — recover it from history |
| 2 | A stowaway file is somewhere in the station's filesystem |
| 3 | A symlink maze in the maintenance deck |
| 4 | Rebuild a wiped directory tree from a paper manifest |
| 5 | Files named to defeat you — select exactly the right set |
| 6 | Forensic sweep of the station logs |
| 7 | Turn a raw access log into a ranked report for the captain |
| 8 | A noisy diagnostic program: capture its errors without losing its output |
| 9 | A runaway process is eating the station's CPU |
| 10 | Permissions audit — and a setuid backdoor someone left behind |
| 11 | Somebody sabotaged `.bashrc`; repair it without deleting it |
| 12 | Automate the audit: ship a real tool, `stationctl` |
| 13 | The tool you need isn't installed |
| 14 | The archives are corrupt and the disk is full |
| 15 | **The Kestrel Breach** — triage, forensics, remediation, report |

## Flags

Format: `KESTREL{lowercase_words_with_underscores}`

- Appear in Flag-tier exercises, at least one per chapter, normally in the chapter's
  `incident-NN` lesson.
- A flag must be **unobtainable without the chapter's skill** — planted so that only the right
  tool, pipeline, or permission move reveals it.
- Plaintext lives **only** in that lesson's `solutions.md`. Everywhere else, salted hashes.
- `kestrel flags` verifies a submitted flag by hash and tracks progress.
- Agents must never reveal a flag, and must refuse requests to.

## Challenge formats

Scenario construction, chained CTFs, roleplay scenes, flag-planting rules and the sabotage arc are
specified in **[CHALLENGE_DESIGN.md](CHALLENGE_DESIGN.md)**. That document is binding on every
chapter; this one is the world it happens in.

## Tone

Dry, competent, a little gallows-humored — the voice of a station log, not a fantasy novel. The
narrative sets up each task in a sentence or two and then gets out of the way. Never let story
prose crowd out the technical explanation; the notes are the product, the story is the frame.
