# CONTAINER.md — Sandbox design

## Why Docker

The student runs an **Oracle VirtualBox VM with Ubuntu**. Docker is installed **inside that VM**,
and all labs run in a course container. Reasons, per the user's decision:

- `sudo`, `apt`, `chown`, `useradd`, `visudo`, setuid and sticky-bit experiments are all safe —
  worst case the student destroys a disposable container, not their VM.
- Reproducible: every student session starts from the same image, so exercises and validation
  rubrics can assume exact state.
- The VM stays clean; the VM snapshot is the outer safety net (Chapter 0 makes the student take one).

## Model: one long-lived container

**Not** one container per lesson. Rationale: chapters 11 and 12 build the student's own `.bashrc`,
aliases, functions, `~/bin` tools, and PATH — that work must survive across lessons. Chapter 10
creates users and groups that later chapters reference.

Isolation instead comes from **per-lesson lab directories** plus a targeted reset.

```
/labs/<chapter-slug>/<lesson-slug>/     # the student's work area for one lesson
```

`/labs` is a **named Docker volume**, so work survives `docker stop` / `docker restart` and image
rebuilds.

## Image

`container/Dockerfile`, a two-stage build.

### Reproducibility: three pins, no floating references

| What | Pinned by |
|---|---|
| Base image | `ubuntu:24.04@sha256:33ceb719...` — a digest, not the moving tag |
| Ubuntu archive | `snapshot.ubuntu.com/ubuntu/<TIMESTAMP>` via the `UBUNTU_SNAPSHOT` build arg |
| Course tools | `container/nix/flake.lock` — a pinned nixpkgs revision |

The snapshot pin matters twice over: the image is reproducible, *and* the `apt-get install` the
student runs live in Chapter 13 resolves against the same frozen index, so the lesson text can name
exact versions and still be correct a year later.

### Split: what comes from Nix, what stays on apt

Stage 1 (`nixos/nix`, digest-pinned) builds a `buildEnv` from `container/nix/flake.nix` and exports
its closure. Stage 2 copies `/nix` in and symlinks the environment to `/opt/kestrel`, which goes
**first** on `PATH`, in `/etc/environment`, and in sudo's `secure_path`.

From Nix (`/opt/kestrel/bin`):
`coreutils findutils grep sed gawk diffutils less tree file procps psmisc htop lsof curl vim nano
jq shellcheck tar gzip bzip2 xz`, plus `cacert` — the Ubuntu base ships no CA bundle and the
snapshot archive is HTTPS-only, so apt borrows the Nix bundle to bootstrap itself.

Still apt, deliberately:
`man-db manpages manpages-dev bash-completion sudo util-linux bsdextrautils passwd adduser
ca-certificates`. Chapter 10 manages accounts and Chapter 13 teaches apt and dpkg; both must be the
real Debian tooling a student would meet on any Ubuntu box. Nix supplies packages only — it never
touches `/etc/passwd`, `/etc/shadow` or `/etc/sudoers`, so the fixture cast is unaffected.

> Chapter 13 deliberately leaves some tools *uninstalled* so the student installs them:
> `ncdu`, `ripgrep`, `tldr`, `ncal`.

### Man pages — two problems, both solved in the Dockerfile

1. **The base image is minimized.** `/etc/dpkg/dpkg.cfg.d/excludes` is removed, the dpkg diversion
   of `/usr/bin/man` to a "run unminimize" stub is undone, and the packages whose pages were
   stripped are reinstalled (`bash`, `passwd`, `login`, `util-linux`, `sudo`, …). Without this
   `man bash` and `man 8 useradd` are simply absent.
2. **Nix does not populate a shared `/usr/share/man`.** The flake sets
   `extraOutputsToInstall = [ "man" "doc" ]` so the merged tree has the pages, and
   `/etc/manpath.config` gets three lines: a `MANDATORY_MANPATH` (makes `man jq` work), a
   `MANPATH_MAP`, and a **`MANDB_MAP`** pointing at `/var/cache/man/kestrel`. The `MANDB_MAP` is the
   non-obvious one — without it `mandb` skips the tree entirely and `apropos`/`whatis` find nothing,
   even though `man` works. The Nix store is read-only, hence the separate cache directory.

### Distribution

CI (`.github/workflows/image.yml`) builds and pushes to
`ghcr.io/romeosarkar10x-teach/linux/kestrel-course:latest` on every push to `main` that touches
`container/`, and runs the acceptance checks against the pushed image. `kestrel build` pulls that
image; `kestrel build --local` builds from the Dockerfile, and a failed pull falls back to it
automatically.

Fixture cast baked into the image, used by chapters 9–10 and the capstone:
- users: `rhea`, `cass`, `dorn`, `ops-bot`
- groups: `crew`, `engineering`, `ops`
- the student's own account: **`cadet`** — a normal user with `sudo` rights, the account they log
  in as. Chapter 10 has them escalate, manage others, and lock things down.

## `container/bin/kestrel` — the helper

```
kestrel build            # pull the prebuilt image (--local builds it here)
kestrel start            # create/start the long-lived container
kestrel enter            # open a shell inside it as cadet
kestrel reset <lesson>   # wipe ONLY that lesson's lab dir and re-run its setup.sh
kestrel status           # which lessons are seeded / attempted
kestrel flags            # flags captured so far
```

### Flag verification without leaking answers
`kestrel flags` stores **salted hashes** of each `KESTREL{...}` flag. The student submits a flag,
the helper hashes and compares. Plaintext flags exist only in each lesson's `solutions.md`, which
the student is told not to open and which agents must never quote.

### Reset semantics
`kestrel reset <lesson>` removes `/labs/<chapter>/<lesson>/` and re-runs that lesson's `setup.sh`.
It does **not** touch the student's home directory, their `.bashrc`, their `~/bin`, or users and
groups they created — those are cumulative course state by design.

For a true clean slate the student rebuilds the image and drops the `/labs` volume; Chapter 0
documents this and warns what it costs them.

## Requirements on `setup.sh` scripts

See `_handoff/LESSON_SPEC.md`. Summary: idempotent, confined to the lesson's lab dir, no network,
uses only tools present in the image, plants every artifact the exercises reference — including the
deliberately broken ones.

## Things Chapter 0 must cover

1. VirtualBox + Ubuntu guest install, guest additions, **take a snapshot before proceeding**
2. Docker Engine install on Ubuntu, adding `cadet` to the `docker` group, `docker run hello-world`
3. `kestrel build` / `start` / `enter`, the `/labs` layout, and what `reset` does and doesn't wipe
4. How to install extra tools later (`docs/INSTALL_GUIDE.md`)
5. How to capture terminal transcripts for the validator (`docs/RECORDING.md`)
