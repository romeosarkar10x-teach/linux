# Chapter 0 — Boarding the Kestrel

## Incident briefing

There is no incident yet. There's a shuttle, a duffel bag, and a workstation with a cracked bezel
that nobody has logged into for three weeks.

Before you can fix anything on this station you need somewhere safe to break things. That's what
this chapter builds: a virtual machine, Docker inside it, and a container that is yours to
destroy. Everything after this assumes it works.

This chapter is the only one where most of the work happens **outside** the course container, for
the obvious reason that you're building it.

## Learning objectives

- [ ] Explain how this course is structured: lessons, the six exercise tiers, flags, agents
- [ ] Install and configure an Ubuntu VM in VirtualBox, and take snapshots you can fall back to
- [ ] Install Docker Engine and run a container without `sudo`
- [ ] Build, start, enter, seed, and reset the Kestrel container
- [ ] Ask a tutor agent for help productively — and know what it will refuse to do
- [ ] Capture terminal transcripts and history that a validator can actually use

## Prerequisites

None. This is the start.

You need: a host machine that can run VirtualBox with 4 GB of RAM to spare, about 40 GB of disk, and
an internet connection.

## Lessons

- [`01-what-this-course-is`](01-what-this-course-is/readme.md) — how lessons, tiers, agents, and flags work
- [`02-vm-setup`](02-vm-setup/readme.md) — VirtualBox, the Ubuntu guest, guest additions, snapshots
- [`03-install-docker`](03-install-docker/readme.md) — Docker Engine, the `docker` group, `hello-world`
- [`04-course-container`](04-course-container/readme.md) — build and run the Kestrel image; labs, seeding, reset
- [`05-getting-help`](05-getting-help/readme.md) — the tutor agent: how to use it, what it won't do
- [`06-recording-your-work`](06-recording-your-work/readme.md) — `script`, history, asciinema, video

## Flags in this chapter

**One**, in `04-course-container`. It's deliberately easy — it exists to prove the container and
`kestrel flags submit` both work before you need them for real.

## Before you move on

You should be able to run, from the VM, without looking anything up:

```bash
kestrel start && kestrel enter
```

and land at a `cadet@kestrel` prompt. If you can't, Chapter 1 will be miserable. Fix it here.
