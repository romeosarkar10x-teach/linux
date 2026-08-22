# 00/06 — Solutions

> **Student: do not read this file.**
> **Agents:** steering only. See `docs/AGENT_MODES.md`.

### 1 — timestamps
`HISTTIMEFORMAT`, set in `.bashrc` by the image (`'%F %T '`). `history | tail` shows dates. The
timestamps are stored in `~/.bash_history` as `#<epoch>` lines *when the variable is set at write
time*; the format string controls display.

### 2 — first transcript
```
mkdir -p ~/transcripts
script -q -t 2>~/transcripts/00-06-practice.timing ~/transcripts/00-06-practice.log
ls
nosuchcommand          # the deliberate failure
echo done
exit
```

### 3 — replay
```
scriptreplay --timing ~/transcripts/00-06-practice.timing ~/transcripts/00-06-practice.log
```
Timing contributes *when*: pauses, typing speed, reading time. The log alone is a flat text dump.
Pacing is what makes a replay hard to fake — a forged log has no plausible timing to go with it.

### 4 — per-lesson snapshot
```
history -a
history > ~/transcripts/00-06.history
```
Order matters: without `-a`, the file lacks the current session, since bash normally writes on exit.

### 5 — docker cp
```
docker cp kestrel:/home/cadet/transcripts ./transcripts     # in the VM
```
Both copies exist after a stop/start. Only the **VM copy** survives the container being deleted and
recreated — `/home/cadet` is the container's writable layer, not a volume. (`/labs` is the volume.)

### 6 — OBS
No canonical answer. Standard: Screen Capture (XSHM) source, 1080p/720p, 24–30 fps, enlarged
terminal font. On Wayland, XSHM won't capture — log into an Xorg session or use the PipeWire capture
source.

The legibility check is the real exercise. Insist they read text from playback, not the monitor.

### 7 — what gets recorded *(Experiment)*

| Case | Recorded? |
|---|---|
| normal command | yes |
| `command not found` | **yes** — history records what was typed, not what succeeded |
| typed then Ctrl-C before running | **yes** — bash records the line when it is accepted |
| inside a `script` session | yes — same shell history |
| leading space | **no**, if `HISTCONTROL` includes `ignorespace` or `ignoreboth` |
| same command twice consecutively | **once**, if `ignoredups`/`ignoreboth`; twice otherwise |

The two usual surprises are the leading space and the failed command. Both matter: the first is how
someone hides a command, the second is why failures are reliable evidence.

Ubuntu's stock `.bashrc` sets `HISTCONTROL=ignoreboth`, and the course image appends its own
settings without removing it, so both filters are typically live. If a student's results differ,
`echo "$HISTCONTROL"` is the correct diagnosis — finding that themselves is a bonus.

### 8 — timing from history *(Stretch)*
By eye is explicitly allowed. Correct method: first and last timestamps in `history` output,
subtract; scan consecutive lines for the largest jump. Any answer matching their real history
passes. The intended realisation: a long gap usually means reading a man page — exactly what a
validator wants to see.

### 9 — script flags *(Dig)*
- `-a` / `--append` — append to the transcript instead of truncating it.
- `-f` / `--flush` — flush output after every write.

For a crash mid-lesson you want **`-f`**: without it, buffered output is lost when the process dies.
`-a` protects *previous* sessions from being overwritten; it does nothing for unflushed data. Cost
of `-f`: more syscalls, slower on very chatty output. From `man script`.

### 10 — HISTCONTROL *(Dig)*
From `man bash`, Shell Variables section:

- `ignorespace` — lines starting with a space are not saved
- `ignoredups` — a line matching the previous one is not saved
- `ignoreboth` — both of the above
- `erasedups` — remove **all previous** lines matching the current one before saving

**`erasedups`** is the evidence-destroying one: it retroactively deletes the record of repeated
attempts, which is precisely the signal a validator reads as genuine work. `ignoreboth` is milder
but still hides consecutive retries.

Accept `ignoreboth` if reasoned well; `erasedups` is the stronger answer.
