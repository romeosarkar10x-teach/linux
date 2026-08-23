# SETUP.md — getting the workstation online

Three layers, and it helps to keep them straight:

```
your real machine  ->  VirtualBox VM (Ubuntu)  ->  Docker container (Kestrel)
                       you install Docker here     all lab work happens here
```

Chapter 0 walks through all of this at a slower pace with exercises. This file is the condensed
reference and the troubleshooting list.

---

## 1. The VM

Any recent VirtualBox and **Ubuntu 24.04 LTS Desktop**.

Recommended, not minimum:

| | |
|---|---|
| RAM | 4 GB (2 GB works, painfully) |
| CPUs | 2 |
| Disk | **40 GB** — dynamically allocated. Docker images grow; 25 GB gets tight around Chapter 13. |
| Video memory | 128 MB, enable 3D acceleration — makes the terminal usable |

After the guest boots, install Guest Additions so you get a resizable window and clipboard sharing:

```bash
sudo apt update
sudo apt install -y virtualbox-guest-utils virtualbox-guest-x11
sudo reboot
```

### Take a snapshot. Now.

VirtualBox → Machine → Take Snapshot → name it `clean-install`.

This course has you edit `/etc/sudoers`, create and delete users, and change permissions on things
that matter. Inside the container that's all disposable. But you'll be running commands in the VM
too, and a snapshot is thirty seconds of insurance against an afternoon of reinstalling.

Take another after Docker is working. Call it `docker-ready`.

## 2. Docker in the VM

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

Verify:

```bash
sudo docker run hello-world
```

Then drop the `sudo` requirement:

```bash
sudo usermod -aG docker "$USER"
```

**Log out and log back in.** A new terminal window is not enough — group membership is fixed when
your login session starts. (Chapter 10/02 explains exactly why, and it's one of the more useful
things in that chapter.) Verify without `sudo`:

```bash
docker run hello-world
```

## 3. The course

Get the course tree into the VM (clone it, or use a VirtualBox shared folder), then:

```bash
cd /path/to/linux
./container/bin/kestrel build      # pulls the prebuilt image (--local to build it here)
./container/bin/kestrel start
./container/bin/kestrel enter
```

You should land at a `cadet@kestrel` prompt with a short banner. That's the workstation.

Put `kestrel` on your PATH so you can call it from anywhere in the VM:

```bash
mkdir -p ~/bin
ln -s /path/to/linux/container/bin/kestrel ~/bin/kestrel
```

`~/bin` is on your PATH by default on Ubuntu, **if it exists at login**. If `kestrel` isn't found,
log out and back in. (Chapter 11/02.)

### The layout inside the container

| Path | What |
|---|---|
| `/course` | the course material, **read-only** — notes and exercises |
| `/labs/<chapter>/<lesson>/` | your work area for one lesson |
| `/home/cadet` | your home. Yours to modify; survives everything except `kestrel nuke`. |

`/labs` is a Docker named volume, so your work survives `docker stop`, restarts, and image
rebuilds.

`/course` is **not** the whole repository. `kestrel start` stages a student view of it — each
lesson's `readme.md` and `exercises.md`, the chapter READMEs, and the shared docs — and mounts only
that. The hint ladders, rubrics, reference answers, lab setup scripts and story bible stay on the
VM, out of the container, where a stray `grep -r` cannot reach them.

The view also holds only the chapters you have reached: a chapter opens once you have captured every
flag in the one before it. To look ahead or revisit anyway:

```bash
kestrel unlock 06       # force chapter 06 open in /course
kestrel status          # shows which chapters are visible
```

### Seeding and resetting

```bash
kestrel seed 01/03      # create that lesson's lab (does not wipe)
kestrel reset 01/03     # WIPE that lab and re-seed it -- asks first
```

`reset` touches **only** that one lab directory. It does not touch your home directory, your
`.bashrc`, your `~/bin`, or users and groups you created — those are cumulative course state, and
later chapters depend on them.

`kestrel nuke` destroys everything including the `/labs` volume. It asks you to type `NUKE`. Don't,
unless you mean it — it takes work waiting to be validated with it.

---

## Troubleshooting

**`permission denied ... /var/run/docker.sock`**
You added yourself to the `docker` group and didn't log out. Log out, log back in.

**`kestrel: no image yet -- run: kestrel build`**
Exactly what it says.

**`kestrel build` can't reach the registry**
It falls back to building locally and tells you so. If that fails too the VM has no internet — check
with `curl -I https://ghcr.io`. In VirtualBox, the network adapter should be NAT and "Cable
Connected" ticked.

**`kestrel build --local` is very slow**
A local build fetches a pinned Nix closure, un-strips the Ubuntu man pages and rebuilds the `man`
index — the course sends you to `man` constantly. Give the VM 2 CPUs. Plain `kestrel build` pulls
the same image already built by CI and skips all of it.

**`lab 06/03` says no lab seeded**
Run `kestrel seed 06/03` from the VM, outside the container.

**Container won't start after a VM reboot**
`kestrel start`. Docker doesn't auto-start containers unless told to.

**Out of disk in the VM**
`docker system prune -a` reclaims a lot. Chapter 14/03 teaches you to find the real hog.

**Everything is broken and I don't know why**
`kestrel reset <chapter>/<lesson>` for a bad lab. Restore the `docker-ready` VM snapshot for a bad
VM. Both are meant to be used.
