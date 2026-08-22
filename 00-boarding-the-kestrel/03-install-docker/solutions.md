# 00/03 — Solutions

> **Student: do not read this file.**
> **Agents:** steering only. See `docs/AGENT_MODES.md`.

### 1 — install
The command block in the notes, verbatim. Verify: `docker --version`, `sudo docker run hello-world`.

### 2 — the docker group
`sudo usermod -aG docker "$USER"`, then a **full logout and login**. Verify with `id` (shows
`docker`) and `docker ps` without `sudo`.

`newgrp docker` also works for the current shell only, and is an acceptable demonstration but not a
substitute — subsequent terminals still need the logout. Unacceptable: `chmod 666
/var/run/docker.sock` (removes the protection entirely) or aliasing `docker` to `sudo docker`.

### 3 — counts
Two containers (one per `hello-world` run — containers persist after exit until removed), one
image. Images are templates; each `docker run` instantiates a new container from the same template.

### 4 — the four steps
From the `hello-world` output: (1) the client contacted the daemon; (2) the daemon pulled the
`hello-world` image from Docker Hub; (3) the daemon created a container from that image which ran
the executable producing the output; (4) the daemon streamed that output to the client, which sent
it to the terminal.

On a third run, **step 2 is skipped** — the image is already cached locally, so no network fetch.
Visible as the absence of the "Unable to find image locally / Pulling from" lines.

### 5 — cleanup
```
docker ps -a                       # get IDs
docker rm <id> <id>                # or: docker container prune
docker images                      # hello-world still listed
docker system df
```
`docker rm` removes containers; `docker rmi` removes images. `docker system df` reports images,
containers, volumes and build cache separately.

### 6 — namespaces *(Experiment)*
- `hostname` → a random 12-hex-character string (the container ID), because the UTS namespace is
  fresh and Docker sets the hostname to the container ID.
- `whoami` → `root`, because `ubuntu:24.04` has no `USER` directive and defaults to uid 0. Worth
  noting: that's root *in the container's user namespace*, mapped to real root by default.
- `ps aux` → **only one or two processes**: `ps` itself, as PID 1. It does **not** show the VM's
  processes. The PID namespace is separate.

The realisation: same kernel, different views. Nothing is being emulated; the kernel simply answers
`ps`'s questions differently depending on which namespace asked.

Contrast worth demonstrating *after* they've predicted: `docker run --rm --pid=host ubuntu:24.04 ps
aux` shows the host's process list, because that one namespace is now shared.

### 7 — comparison *(Stretch)*
| | VM | container |
|---|---|---|
| `hostname` | the VM's name | container ID (or `kestrel` for the course container) |
| `whoami` | their VM user | `root` (or `cadet` in the course image) |
| `df -h /` | VM root filesystem | **similar total and used** — it's the same physical disk, seen through the container's mount namespace via the overlay filesystem |

The `df` row is the point: filling the container's disk fills the VM's disk. Isolation of *view* is
not isolation of *resources* unless you add cgroup limits.

### 8 — run flags *(Dig)*
`--rm` removes the container when it exits. `-i` (`--interactive`) keeps stdin open; `-t`
(`--tty`) allocates a pseudo-terminal so line editing and job control work. They are separate
because non-interactive piping wants `-i` without `-t`.

```
docker run --rm -it ubuntu:24.04 bash
```
With only `-t`, typing does nothing useful (no stdin). With only `-i`, it works but with no prompt,
no line editing, and no colours. Found in `docker run --help`.
