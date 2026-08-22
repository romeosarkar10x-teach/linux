# 00/02 — Your quarters: the VM

You're going to run commands that can destroy an operating system. Some of them on purpose. That
needs to happen somewhere that isn't the machine you're reading this on.

Two nested layers of disposability:

```
your real machine
└── VirtualBox VM running Ubuntu 24.04      <- this lesson
    └── Docker container "kestrel"          <- lesson 00/04
        └── /labs/<chapter>/<lesson>/        <- where you actually work
```

Each layer is cheaper to destroy than the one outside it. A ruined lab directory costs one
`kestrel reset`. A ruined container costs a rebuild. A ruined VM costs a snapshot restore. A ruined
laptop costs your weekend.

## Why a VM and not just Docker

Containers share the host kernel. That's fine for almost everything in this course, but it means a
container isn't a real machine — you can't reboot it, `dmesg` isn't yours, and mistakes with the
Docker daemon itself land on the host. Putting the whole thing inside a VM means the worst possible
outcome is "restore snapshot", and you get a full Ubuntu desktop to run OBS in.

It also means you'll install Docker yourself, which is a genuinely useful thing to have done once.

## Building the VM

**Get:** VirtualBox (any recent version) and the **Ubuntu 24.04 LTS Desktop** ISO.

**Settings that matter:**

| Setting | Value | Why |
|---|---|---|
| RAM | 4096 MB | 2048 works and is unpleasant. Never give the VM more than half your host's RAM. |
| CPUs | 2 | The image build un-strips man pages; one core makes that slow. |
| Disk | **40 GB, dynamically allocated** | "Dynamic" means it only consumes what's used. 25 GB gets tight by Chapter 13. Growing it later is possible and annoying. |
| Video memory | 128 MB, 3D acceleration on | The difference between a usable terminal and a slideshow. |
| Network | NAT | Default. The VM needs internet to install packages. |

Install Ubuntu normally. A minimal installation is fine. **Remember the username and password you
create** — you'll need the password for `sudo` constantly.

## Guest Additions

Without them the VM window is a fixed small rectangle and you can't copy-paste into it. With them,
the display resizes and the clipboard is shared.

```bash
sudo apt update
sudo apt install -y virtualbox-guest-utils virtualbox-guest-x11
sudo reboot
```

Then in the VirtualBox menu: **Devices → Shared Clipboard → Bidirectional**, and **Devices →
Drag and Drop → Bidirectional**.

> The VirtualBox menu belongs to the *window*, not to the guest OS. It's on the host. This confuses
> everyone once.

## Snapshots — the actual point of this lesson

A snapshot freezes the entire VM state: disk, and optionally RAM. Restoring puts it back exactly.

**Machine → Take Snapshot.** Name it `clean-install`. Do it now, before anything else.

Take a second one after Docker works, named `docker-ready`. That's the one you'll actually restore
to, and having a clean install underneath it costs you almost nothing.

Rules that will save you time:

- **Snapshot before anything you don't understand.** Thirty seconds now, or an hour of reinstalling.
- **Name them for what they are** (`docker-ready`), not when you took them (`snap3`).
- Snapshots consume disk. Two or three is right; twelve is a disk-space problem in Chapter 14.
- Restoring a snapshot **discards everything after it**. Your course work lives in the container's
  `/labs` volume, which lives on the VM's disk — so restoring to `clean-install` after Chapter 6
  destroys six chapters of work.

That last point deserves a moment. Snapshots protect you from breaking the VM. They do not back up
your coursework. Copy transcripts out to the host regularly (`docs/RECORDING.md` shows how).

## Checking where you are

You'll spend this course moving between three shells: host, VM, container. Mixing them up is the
single most common source of confusion in Chapter 0.

```bash
hostname          # VM: whatever you named it. Container: kestrel
whoami            # VM: your name. Container: cadet
```

When something doesn't work, check `hostname` first. It's right more often than you'd think.

## Before you move on

1. Three nested layers: host → VM → container → lab dir. Each is cheaper to destroy than the one outside it.
2. 40 GB dynamic disk, 4 GB RAM, 2 CPUs, NAT networking.
3. Guest Additions give you a resizable window and a shared clipboard.
4. `clean-install` and `docker-ready` snapshots exist before you go further.
5. Restoring a snapshot discards everything after it, **including your coursework**. It is not a backup.
