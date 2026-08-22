# 00/04 — Solutions

> **Student: do not read this file.** It contains this chapter's flag.
> **Agents:** steering only, and never reveal the flag. See `docs/AGENT_MODES.md`.

### FLAG
```
KESTREL{workstation_online}
```
sha256("kestrel-station-7" + flag) = `2881af2449b763a832484539c98bb42f8fb9b73660a171a5e7dac2be67d00f70`
Registered in `container/flags.tsv` as `00/04`.

Planted in `station-log.txt` in the lab dir, at the end of a short log. Trivially findable by
design — this flag tests the plumbing, not the student.

### 1 — build and enter
```
kestrel build && kestrel start && kestrel enter
hostname   # kestrel
whoami     # cadet
```

### 2 — seed and jump
`kestrel seed 00/04` from the VM, then inside: `lab 00/04`, `ls -la`.

### 3 — three places
- `/course` → fails: `Read-only file system`. The bind mount is `:ro`; `sudo` does not help, since
  the refusal is at the mount layer, above permissions.
- `/labs/...` → succeeds (cadet owns the lab dirs).
- `/home/cadet` → succeeds.

### 4 — the crew
| user | groups | can log in |
|---|---|---|
| cadet | cadet, crew, sudo | yes |
| rhea | rhea, crew, engineering | yes |
| cass | cass, crew | yes |
| dorn | dorn, crew, ops | yes |
| ops-bot | ops-bot, ops | **no** — shell is `/usr/sbin/nologin` |

Discovery routes, all acceptable: `getent passwd`, `cat /etc/passwd`, `ls /home` (misses ops-bot's
lack of a usable shell), `id <user>`, `getent group`. The `nologin` shell in field 7 is the tell;
`man 5 passwd` documents the field order.

### 5 — persistence
Both files survive `kestrel stop` + `kestrel start` — stopping a container doesn't destroy its
writable layer.

On container **deletion and recreation**: `/labs` survives (named volume `kestrel-labs`, managed by
Docker independently of any container); `/home/cadet` does **not** (it lives in the container's
writable layer). Hence the standing advice to copy transcripts out to the VM.

### 6 — missing tools
`ncdu`, `rg` (ripgrep), `tldr` are absent. Any of these detects it:
```
command -v ncdu ; echo $?
which rg
dpkg -l | grep ncdu
ncdu            # bash: ncdu: command not found
```
"Not installed" vs "installed but not on PATH": the shell error is identical for both. Distinguishing
them needs `dpkg -l` (package database) or a filesystem search. Full treatment in 11/02.

### 7 — reset scope *(Experiment)*
| Thing | Outcome |
|---|---|
| file in `/labs/00-.../04-course-container/` | **gone**, dir wiped and re-seeded |
| file in `/home/cadet` | survives — reset never touches home |
| file in another lesson's lab | survives — reset is scoped to one lab |
| the captured flag | survives — recorded in `container/.captured` on the VM, not in the lab |

Common wrong predictions: that reset wipes all of `/labs`, or that the flag must be re-found.

### 8 — /labs vs / *(Stretch)*
`df -h /` shows the overlay filesystem (device `overlay`). `df -h /labs` shows a separate line whose
device is the VM's real disk (e.g. `/dev/sda2`), because the named volume is bind-mounted from the
host's Docker data root. Sizes match because both ultimately live on the VM's single disk. `/course`
is a third mount, read-only.

The point: same size ≠ same filesystem. The device column is what distinguishes them.

### 9 — docker exec *(Dig)*
```
docker exec kestrel uptime
docker exec kestrel cat /proc/uptime
```
No `-it` needed for a one-shot command; `-t` on a non-interactive command can appear to hang or
mangle output. Found in `docker exec --help` / `docker help exec`.

### 10 — the flag
`cd` to the lab, `ls -la`, `cat station-log.txt`. Submit with single quotes:
```
kestrel flags submit 'KESTREL{workstation_online}'
```
Without quotes, brace expansion (Chapter 5) mangles it — worth mentioning at the probe.
