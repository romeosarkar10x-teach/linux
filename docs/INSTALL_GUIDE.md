# INSTALL_GUIDE.md — installing things

Two machines to keep straight:

- **The VM** — your Ubuntu guest in VirtualBox. Docker lives here, and so do OBS and your files.
- **The container** — the Kestrel image, running inside the VM. **All lab work happens here.**

Rule of thumb: if a lesson asks you to install something, it means **in the container**. If it's a
tool for recording or running the course, it goes in the VM.

---

## In the VM

### Docker Engine (Chapter 0 walks through this; here for reference)

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

Then, so you don't need `sudo` for every docker command:

```bash
sudo usermod -aG docker "$USER"
```

**Log out and back in** for the group change to apply — a new terminal is not enough. (Chapter
10/02 explains exactly why.) Verify:

```bash
docker run hello-world
```

### Recording tools

```bash
sudo apt install -y obs-studio        # screen recording
sudo apt install -y asciinema         # optional terminal recording
```

`script` is already installed — it ships with `util-linux`.

---

## In the container

Get a shell first:

```bash
./container/bin/kestrel enter
```

Then `apt` works as usual. The image ships with `sudo` and `cadet` has it.

```bash
sudo apt update          # required after a fresh build, before any install
sudo apt install -y <package>
```

### Already in the image

`coreutils findutils grep sed gawk less tree file procps psmisc htop curl vim nano man-db manpages
bash-completion sudo shellcheck jq`

Man pages work. Ubuntu images normally strip them; this one un-strips them deliberately, because
the Dig tier of every lesson sends you to `man`.

### Deliberately *not* in the image

`ncdu`, `ripgrep`, `tldr`, and one more you'll meet in Chapter 13. They're missing on purpose —
Chapter 13 is about installing things, and 13/06 can't be solved without doing it.

Don't install them early. You'll spoil an exercise and gain nothing.

### Common installs by chapter

| Chapter | Package | Provides |
|---|---|---|
| 9 | `htop` (preinstalled) | interactive process viewer |
| 9 | `lsof` | list open files |
| 13 | `tldr` | short community man pages |
| 13 | `ripgrep` | `rg` |
| 14 | `ncdu` | interactive disk usage |
| 14 | `zip` / `unzip` | zip archives |

---

## Troubleshooting

**`Unable to locate package X`** — you haven't run `sudo apt update` since the container was built.
The image ships with the package index cleared to keep it small.

**`Temporary failure resolving 'archive.ubuntu.com'`** — the container has no network. Check the VM
itself has internet (`curl -I https://archive.ubuntu.com`). If the VM is fine and the container
isn't, restart Docker: `sudo systemctl restart docker`, then `kestrel start`.

**`permission denied while trying to connect to the Docker daemon socket`** — you're in the VM,
you added yourself to the `docker` group, and you didn't log out. Log out and back in.

**`man: command not found` or man pages empty** — you're not in the course container. Check with
`hostname`; it should be `kestrel`.

**Ran out of disk in the VM** — VirtualBox disks are usually 25 GB by default and Docker images
add up. `docker system prune -a` reclaims a lot. Chapter 14/03 teaches finding the actual hog.

**You broke the container badly** — that's what it's for. `kestrel reset <chapter>/<lesson>`
re-seeds one lab. A full rebuild (`kestrel build` plus dropping the `/labs` volume) resets
everything and **destroys all your lab work**, including work waiting to be validated.
