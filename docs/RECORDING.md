# RECORDING.md — capturing your work

Two kinds of evidence are expected: **terminal transcripts** (cheap, precise, per-lesson) and a
**screen recording** (slower, proves authorship). Transcripts are what the validator actually reads.
Do both.

---

## 1. Terminal transcripts with `script`

`script` records everything your terminal shows into a file. Run it **inside the container**, at the
start of each lesson.

```bash
# inside the container
mkdir -p ~/transcripts
script -q -t 2>~/transcripts/06-03.timing ~/transcripts/06-03.log
# ... do the lesson ...
exit          # ends the recording
```

- `-q` suppresses the start/stop banner.
- `-t` writes timing data to stderr, here redirected to a `.timing` file. With it, the session can
  be replayed at original speed — timing is strong evidence of real work.
- Name the file `<chapter>-<lesson>`, e.g. `06-03.log`. The validator looks for that.

Replay one to check it captured:

```bash
scriptreplay --timing ~/transcripts/06-03.timing ~/transcripts/06-03.log
```

`script` files contain control characters and colour escapes. That's fine — the validator expects
it. Don't clean them up; edited transcripts are worth nothing.

## 2. asciinema (nicer, optional)

If you want something you can watch and share:

```bash
sudo apt install -y asciinema        # inside the container
asciinema rec ~/transcripts/06-03.cast
# ... do the lesson ...  exit
asciinema play ~/transcripts/06-03.cast
```

Either `script` or asciinema satisfies the transcript requirement. Not both.

## 3. Keep your history intact

`history` is a primary evidence source. Protect it:

```bash
# add to ~/.bashrc  (you'll understand every line of this after Chapter 11)
HISTSIZE=100000
HISTFILESIZE=200000
HISTTIMEFORMAT='%F %T '        # timestamps -- the validator needs these
shopt -s histappend            # append instead of overwriting on exit
```

`HISTTIMEFORMAT` is the important one: without timestamps the validator can't check pacing.

Snapshot your history at the end of each lesson:

```bash
history -a                              # flush the current session to the file
history > ~/transcripts/06-03.history
```

**Do not clean your history.** Failed attempts are the most valuable thing in it. A history with no
mistakes reads as copy-paste and will trigger a live re-demonstration.

## 4. The screen recording

One recording of you working through the course. It doesn't need to be one file — per-chapter is
fine and much easier to manage.

**OBS Studio** works well on the Ubuntu VM:

- Source: Screen Capture (XSHM), the whole desktop or just the terminal window.
- 1080p or 720p, 24–30 fps. Text legibility matters far more than resolution — bump the terminal
  font size until the smallest text is comfortably readable in the recorded file, not just on your
  monitor.
- Audio optional. Narrating what you're trying is genuinely useful evidence, but not required.

Must be visible on screen:

- The terminal, with your commands and their output.
- Enough of the prompt to see the working directory.
- The lesson you're on — say it out loud or `echo` it before starting.

Don't cut failures out. They're the point.

## 5. What to hand the validator

Per lesson:

```
~/transcripts/NN-MM.log        (or .cast)
~/transcripts/NN-MM.timing     (if you used script -t)
~/transcripts/NN-MM.history
```

Plus the lab directory left in its finished state — **do not `kestrel reset` a lesson before it's
validated.** The filesystem state is the strongest evidence there is, and reset destroys it.

Copy transcripts out of the container so they survive a rebuild:

```bash
# from the VM, outside the container
docker cp kestrel:/home/cadet/transcripts ./transcripts
```
