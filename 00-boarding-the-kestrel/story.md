# Chapter 0 — story

Scene text for this chapter's lessons. Continuity authority is `_handoff/SCENARIOS.md`; this file
expands it and never contradicts it.

**Chapter arc.** Arrival. The student has been aboard 22 days and has just been given the sysadmin
post nobody else wants. Nothing of the arc is visible yet — this chapter's only job is to get them
a working machine and a way to ask for help.

**Special constraint for this chapter** (`CONTEXT.md` §4.6(d)): the install steps are genuinely
fiddly and a student mid-VirtualBox is not in a position to enjoy a metaphor. **No framing may
obscure a literal instruction.** Where the two conflict, the instruction wins. The frame goes at the
top of a lesson and gets out of the way.

---

### `01-what-this-course-is`
> Twenty-two days aboard and the sysadmin post is yours, on the grounds that nobody else wanted it.
> There is no handover. There is a file called `notes.txt` containing the word `later`.

Also carries the out-of-story explanation of tiers, agents and flags — that part stays plain.

### `02-vm-setup`
> Your quarters first. Everything you are about to break, you will break in a room that can be
> restored from a snapshot, which is a luxury the station itself does not have.

The snapshot instruction is the point of the lesson. State it literally, then frame it.

### `03-install-docker`
> The workstation is not the room. You want a machine you can wreck on purpose, on a station where
> the machines have been running for eleven years and nobody remembers what half of them do.

### `04-course-container`
> Your terminal is the one with the cracked bezel. `/course` is the manual, bolted down and
> read-only. `/labs` is the bench — everything you build, break and rebuild happens there.

Carries the chapter's flag, `00/04`. Deliberately easy: it proves the chain works before Chapter 1,
where the flags start biting.

### `05-getting-help`
> There is one other sysadmin on this station and it is an agent that will not tell you the answer.
> It will ask what you tried. Have an answer ready.

### `06-recording-your-work`
> Nobody watched dorn work either. That is most of why you are in this situation, and it is why
> your shifts get recorded from here on.

First and only arc reference in the chapter, and it reads as ordinary process discipline. It is
not to be developed.
