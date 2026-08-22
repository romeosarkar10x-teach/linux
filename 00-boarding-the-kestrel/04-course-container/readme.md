# 00/04 — The workstation

> Your terminal is the one with the cracked bezel. `/course` is the manual: bolted down, and
> read-only for a reason. `/labs` is the bench — everything you build, break and rebuild happens
> there.

Time to build the thing you'll actually live in.

## What you're building

```bash
kestrel build      # pull the prebuilt image (--local builds container/Dockerfile here)
kestrel start      # create and start the long-lived container
kestrel enter      # shell in as cadet
```

`build` normally just pulls an image that CI already built. `kestrel build --local` builds it from
`container/Dockerfile` instead, which takes a few minutes — most of that is deliberately reinstalling
man pages, because Ubuntu images strip documentation to stay small and this course sends you to `man`
in every single lesson.

Either way you get the exact same image. It is pinned three ways so it cannot drift under you: the
Ubuntu base by digest, the Ubuntu archive to a frozen snapshot date, and every course tool to a Nix
flake lock. Two students, a year apart, get byte-identical tools.

## One container for the whole course

Not one per lesson. That's a design decision with a reason.

Chapters 11 and 12 have you build your own `.bashrc`, your own aliases and functions, and your own
tools in `~/bin`. Chapter 10 has you create users and groups that later chapters reference. All of
that has to survive from one lesson to the next. A fresh container per lesson would throw it away
every time, and the most valuable thing you build in this course is your own environment.

Isolation instead comes from **per-lesson lab directories**:

```
/labs/<chapter-slug>/<lesson-slug>/
```

Each lesson's `setup.sh` seeds its own directory and touches nothing else. If you wreck one, you
reset that one.

## The three places files live

| Path | What | Survives what |
|---|---|---|
| `/course` | this course tree, **read-only** | it's a bind mount from the VM |
| `/labs/...` | your work, per lesson | a Docker named volume — survives stop, restart, image rebuild |
| `/home/cadet` | your home; config, `~/bin`, transcripts | the container's writable layer — survives stop/restart, **not** a container rebuild |

That last row has teeth. `/home/cadet` lives in the container, not in a volume. `kestrel stop` and
`kestrel start` are safe. Deleting and recreating the container is not. Copy transcripts out to the
VM regularly — `docs/RECORDING.md`.

`/course` being read-only is intentional. Your work goes in `/labs`, never in the course tree, and
the read-only mount enforces it.

## The helper

```bash
kestrel build                    # pull the image (--local to build it)
kestrel start                    # create/start the container
kestrel stop                     # stop it (labs and home survive)
kestrel enter                    # shell in as cadet
kestrel seed 06/03               # create that lesson's lab (non-destructive)
kestrel reset 06/03              # WIPE that lab and re-seed it (asks first)
kestrel status                   # what's running, what's seeded, flags captured
kestrel flags                    # flag progress
kestrel flags submit 'KESTREL{...}'
kestrel nuke                     # destroy everything (makes you type NUKE)
```

Run these **in the VM**, not inside the container. `kestrel` talks to the Docker daemon; there's no
daemon inside the container.

Lesson ids are numbers: `06/03` means chapter 6, lesson 3.

### What `reset` does and doesn't do

`kestrel reset 06/03` deletes `/labs/06-searching/03-regex-bre-ere/` and re-runs that lesson's
`setup.sh`.

It does **not** touch:
- your home directory or anything in it
- your `.bashrc`, aliases, or `~/bin`
- users and groups you created
- any other lesson's lab

Because it's narrow, resetting is cheap. Use it freely — deliberately destroying a lab and rebuilding
it from scratch is one of the better ways to find out whether you learned the lesson.

**Don't reset a lesson before it's been validated.** The filesystem state is the strongest evidence
a validator has, and reset destroys it.

## Inside the container

You are `cadet`, a normal user with passwordless `sudo`. Your password is `kestrel` if anything
asks. You're in the `crew` group.

Other accounts exist: `rhea`, `cass`, `dorn`, `ops-bot`. They're the station crew, and they own
files you'll meet from Chapter 9 onward. Leave them alone until then.

The shell has one helper preloaded:

```bash
lab 06/03      # cd to that lesson's lab directory
```

Some tools are **deliberately missing** — `ncdu`, `ripgrep`, `tldr` and one more. Chapter 13 is
about installing things, and 13/06 can't be solved without doing it. Don't install them early;
you'd spoil an exercise and gain nothing.

## When something is wrong

```bash
docker ps -a          # is the container even there?
kestrel status        # what the helper thinks
kestrel start         # containers don't auto-start after a VM reboot
hostname              # in doubt, find out which machine you're on
```

`docs/INSTALL_GUIDE.md` has the full troubleshooting list.

## Your first flag

There's a `KESTREL{...}` flag waiting in this lesson's lab directory. It's the easiest one in the
course by a wide margin — it exists to prove the container, the seeding, and flag submission all
work before you need them under pressure.

```bash
kestrel flags submit 'KESTREL{...}'
```

The single quotes matter. `{` and `}` are shell syntax, and you'll find out exactly what they do in
Chapter 5.

## Before you move on

1. One long-lived container, because your `.bashrc`, `~/bin` and created users must persist.
2. `/course` is read-only; work goes in `/labs`; `/home/cadet` is yours but lives in the container.
3. `kestrel` runs in the **VM**, not in the container.
4. `reset <chapter>/<lesson>` wipes exactly one lab dir and nothing else — never your home.
5. Don't reset a lesson before it's validated.
