# 00/03 — Docker Engine

You need a container. Docker is how you get one.

## What a container actually is

Not a virtual machine. A VM boots its own kernel and emulates hardware; a container is just
**processes on the host kernel**, wearing a blindfold. The Linux kernel provides two features that
do all the work:

- **Namespaces** — the blindfold. A process in its own PID namespace sees itself as PID 1 and can't
  see the host's processes at all. Same for mount points, hostname, users, network.
- **cgroups** — the leash. Limits on CPU, memory, and I/O.

So the Kestrel container's `/etc/passwd` is genuinely a different file from your VM's, its process
list is genuinely separate, and `whoami` genuinely says `cadet` — but the kernel running it all is
your VM's kernel. That's why containers start in milliseconds and VMs take a minute.

You'll meet processes, users and mounts properly in Chapters 9, 10 and 2. Come back to this
paragraph then; it will read differently.

## The pieces

| Thing | What it is |
|---|---|
| **image** | a read-only filesystem template plus metadata. Built from a `Dockerfile`. |
| **container** | a running (or stopped) instance of an image, with a writable layer on top |
| **volume** | storage managed by Docker that outlives any container using it |
| **daemon** | `dockerd`, the background process that does everything. The `docker` command just talks to it. |

The daemon detail matters more than it looks. `docker` is a client that sends requests to a socket
at `/var/run/docker.sock`. That socket is owned by `root:docker`. Which is why the next section
exists.

## Installing

Ubuntu's own repositories carry an old `docker.io` package. Use Docker's repository instead, which
is what the official instructions do:

```bash
sudo apt update
sudo apt install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo $VERSION_CODENAME) stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

You are allowed to copy-paste this. It's the Chapter 0 exception described in 00/01. Every piece of
it gets taught properly later — `apt` in 13/01, the pipe and `>` in Chapter 8, `chmod` in 10/05.

But **read it before you run it.** That habit is worth more than any single command in this course.
Roughly: install prerequisites, fetch Docker's signing key, register their repository as a source
that must be signed by that key, refresh the package index, install.

Verify:

```bash
sudo docker run hello-world
```

That downloads a tiny image, runs it, prints a message, and exits.

## Getting rid of `sudo`

Every `docker` command needs write access to `/var/run/docker.sock`. Root has it. So does anyone in
the `docker` group.

```bash
sudo usermod -aG docker "$USER"
```

Then **log out and log back in.**

Not a new terminal. Not `su - $USER`. A full logout.

The reason is worth understanding now because it catches everyone: your group memberships are read
once, when your login session is created, and copied into every process that session spawns. Adding
you to a group edits `/etc/group` on disk — it does not reach into your already-running shell and
change its credentials. A new terminal is a child of that same session, so it inherits the same
stale set. Only a fresh login reads the file again.

You can prove it: run `id` before and after opening a new terminal (unchanged), then after a full
logout (changed). Chapter 10/02 does exactly this as an exercise.

Verify:

```bash
docker run hello-world     # no sudo
```

> **Worth knowing:** membership of `docker` is effectively root on the host. Anyone in that group
> can start a container that mounts the host's filesystem and edit anything. That's an acceptable
> tradeoff on a disposable VM. It would not be on a shared machine.

## Commands you'll use

```bash
docker ps                 # running containers
docker ps -a              # all containers, including stopped
docker images             # local images
docker volume ls          # volumes
docker logs <name>        # a container's output
docker system df          # what Docker is consuming
docker system prune -a    # reclaim it (destructive -- removes unused images)
```

You'll rarely call these directly; the `kestrel` helper wraps what you need. But when something is
broken, `docker ps -a` is the first thing to run.

## Before you move on

1. A container is namespaced processes on the **host kernel** — not a VM, no kernel of its own.
2. Image = template; container = running instance; volume = storage that outlives the container.
3. `docker` is a client talking to the `dockerd` daemon over `/var/run/docker.sock`.
4. Group membership is fixed at login. `usermod -aG` requires a **full logout**, not a new terminal.
5. Being in the `docker` group is equivalent to root on the host.
