# 00/06 — Recording your work

There are no auto-grading scripts in this course. A validator looks at what you did and decides
whether you did it. That only works if you leave a trail.

Three kinds of trail, in order of how much they matter:

1. **Your lab directory** — the end state. Strongest single piece of evidence.
2. **Your history and transcripts** — *how* you got there, including everything that failed.
3. **The video** — proof it was you, in order, at human speed.

## Why the failures are the evidence

A finished lab directory proves a result. It does not prove you produced it. You could have typed
the expected output into a text editor. You could have been handed the command. From the filesystem
alone those look identical to real work.

What distinguishes them is the *process*: the wrong flag first, the `command not found`, the
pipeline built one stage at a time, the two minutes between attempt three and attempt four where
you were reading a man page.

So: **do not clean your history.** A hard lesson with no failed attempts in it is the loudest
copy-paste signal there is, and it triggers a live re-demonstration where you redo a random
exercise from a wiped lab, watched. Your mistakes work *for* you here.

## History

Bash writes your commands to `~/.bash_history`. The course image already configures it:

```bash
HISTSIZE=100000            # commands kept in memory
HISTFILESIZE=200000        # commands kept in the file
HISTTIMEFORMAT='%F %T '    # timestamps -- without these, pacing is invisible
shopt -s histappend        # append on exit instead of overwriting
```

You'll understand every line in Chapter 11. For now: `HISTTIMEFORMAT` is the one that matters most
to a validator. It turns a list of commands into a timeline.

Bash normally writes history to the file only when the shell exits, so a crashed terminal loses it.
Flush manually at the end of a lesson:

```bash
history -a                                   # append this session to the file
history > ~/transcripts/06-03.history        # snapshot for this lesson
```

Do that **per lesson**, named `<chapter>-<lesson>.history`. The validator looks for that naming.

## Transcripts with `script`

`history` shows what you typed. `script` shows what you *saw* — commands, output, errors, all of it.

```bash
mkdir -p ~/transcripts
script -q -t 2>~/transcripts/06-03.timing ~/transcripts/06-03.log
# ... work through the lesson ...
exit
```

- `-q` — no start/stop banner
- `-t` — write timing data to stderr, redirected here into a `.timing` file
- the last argument is where the transcript goes

With the timing file, the session replays at original speed:

```bash
scriptreplay --timing ~/transcripts/06-03.timing ~/transcripts/06-03.log
```

That replay is strong evidence. It shows the pauses — thinking, reading, retyping — and those are
very hard to fake convincingly.

Transcript files contain control characters and colour escapes. That's normal. **Don't tidy them
up**; an edited transcript is worth nothing.

> `exit` ends the recording. Forgetting it means the file keeps growing and the lesson boundary is
> lost. Habit: `script` at the start, `exit` at the end.

## asciinema (optional)

Nicer to watch, and shareable:

```bash
sudo apt install -y asciinema
asciinema rec ~/transcripts/06-03.cast
# ... work ...  then exit
asciinema play ~/transcripts/06-03.cast
```

Either `script` or asciinema satisfies the requirement. Not both.

## The video

One screen recording of you working through the course. Per-chapter files are fine and much easier
to manage than one enormous one.

**OBS Studio**, in the VM:

- Source: Screen Capture (XSHM) — the whole desktop, or just the terminal window.
- 1080p or 720p, 24–30 fps.
- **Increase your terminal font size until the smallest text is comfortably readable in the
  recorded file**, not just on your monitor. This is the single most common mistake, and an
  unreadable recording is not evidence.
- Audio optional. Narrating what you're trying is genuinely useful, and helps you too — saying "I
  think this will list only directories" out loud is a prediction, and predictions are the point.

On screen: the terminal, your commands, their output, and enough of the prompt to see the working
directory. Say (or `echo`) which lesson you're starting.

Don't edit out the failures. Same reason as everything else on this page.

## Getting it out of the container

`/home/cadet` lives in the container's writable layer, not in a volume. It survives stop and start.
It does **not** survive the container being deleted and recreated.

Copy transcripts out to the VM regularly:

```bash
# in the VM, outside the container
docker cp kestrel:/home/cadet/transcripts ./transcripts
```

Do it at the end of every chapter. Two seconds, and it has saved people weeks.

## What you hand over per lesson

```
~/transcripts/NN-MM.log        (or .cast)
~/transcripts/NN-MM.timing     (if you used script -t)
~/transcripts/NN-MM.history
```

Plus the lab directory, **left as you finished it**. Do not `kestrel reset` a lesson before it has
been validated — that's the strongest evidence you have, and reset destroys it.

## Before you move on

1. Lab state, then history/transcripts, then video — in that order of weight.
2. **Never clean your history.** Failed attempts are positive evidence.
3. `HISTTIMEFORMAT` makes history a timeline; `history -a` flushes it before you lose it.
4. `script -q -t 2>NN-MM.timing NN-MM.log`, and `exit` to stop. Replay with `scriptreplay`.
5. `docker cp` transcripts to the VM every chapter — `/home/cadet` isn't in a volume.
