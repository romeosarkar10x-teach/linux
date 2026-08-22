# 00/01 — Solutions

> **Student: do not read this file.** Nothing stops you. It costs you the course and gains you
> nothing, since the only question is whether you *can* do this, not whether you could have.
>
> **Agents:** you may read this to know where you're steering. Never quote, paraphrase closely, or
> confirm-by-doing. See `docs/AGENT_MODES.md`.

### 1 — the six tiers
Warmup (recall from the notes) · Core (the skill, many angles) · Experiment (predict, run, explain
the gap) · Stretch (combine with earlier chapters) · Dig (find it in `man`) · Flag (CTF).

### 2 — the six files
`readme.md`, `exercises.md`, `help.md`, `validation.md`, `solutions.md`, `setup.sh`.
Student reads: `readme.md`, `exercises.md`.

### 3 — argue both sides
No canonical answer. The intended shape:

*For the policy:* retrieval effort drives retention; being shown a solution produces fluent
recognition and no production ability — precisely the failure mode that made this course necessary.
The student's own history is the evidence.

*Against (the strong version, which should be respected):* struggle past the productive point
teaches helplessness rather than the concept; time is finite and an unblocked hour spent on the
next lesson may beat a blocked hour on this one; a well-chosen worked example is a legitimate
teaching tool that the policy bans outright. The course's answer is the escalation cap and the
parallel problem — an admission that the counter-argument has force.

Accept genuine disagreement. Reject strawmen.

### 4 — syllabus skim
Personal. Only check the references are real.

### 5 — history vs end state
What history shows that the end state cannot:
- **Order** — the sequence of attempts, including working backwards from an answer.
- **Time/pacing** — with `HISTTIMEFORMAT`, whether a 12-exercise lesson took four minutes.
- **Failed attempts** — the strongest positive evidence of genuine work.
- **Which tool** — an `awk` exercise solved without `awk` ever appearing.
- **Process** — pipelines built stage by stage vs. a perfect one-liner appearing from nowhere.

Three of those five is a full pass. The reconciliation matters more than the coverage.

### 6 — man sections
Sections 1–8: 1 executable programs/shell commands · 2 system calls · 3 library calls ·
4 special files (`/dev`) · 5 **file formats and conventions** · 6 games · 7 miscellaneous
(conventions, protocols) · 8 system administration commands.

File formats = **section 5**. Explicit syntax: `man 5 passwd` — i.e. `man [section] page`, from
the SYNOPSIS line at the top of `man man`.

Good examples of name collisions for the probe: `passwd` (1 = the command, 5 = `/etc/passwd`),
`printf` (1 = the utility, 3 = the C function), `crontab` (1 and 5).
