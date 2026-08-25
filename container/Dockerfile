# syntax=docker/dockerfile:1
#
# Kestrel Linux course image.
#
# One long-lived container per student. Lab work lives in /labs (a named volume);
# the course tree is bind-mounted read-only at /course.
#
# Reproducibility model -- three pins, no floating references anywhere:
#   1. the base image is pinned by digest, not by the ubuntu:24.04 tag
#   2. apt reads from snapshot.ubuntu.com at a frozen timestamp, so `apt-get
#      install` resolves the same package versions today and in a year
#   3. every course tool that is not part of Debian's account/doc plumbing comes
#      from a flake-pinned Nix closure (container/nix/flake.lock)
#
# Deliberately still installed from apt, and deliberately left alone:
#   apt/dpkg itself, man-db, passwd/adduser/util-linux, sudo -- Chapter 10
#   manages accounts and Chapter 13 teaches apt, so both must be the real
#   Debian tooling the student would meet on any Ubuntu box.


# --- Stage 1: build the pinned Nix closure ----------------------------------
FROM nixos/nix:latest@sha256:7a007c766426c1877758ddc5cb87a965ac131fc78c582ce0083d922d51ae945c AS nixenv

RUN mkdir -p /etc/nix && printf 'experimental-features = nix-command flakes\nfilter-syscalls = false\n' >> /etc/nix/nix.conf

COPY nix/flake.nix nix/flake.lock /flake/
WORKDIR /flake

# Build the merged tool environment, then export its complete closure so the
# final image can carry the store without needing Nix installed at runtime.
RUN nix build --no-write-lock-file .#default --out-link /tmp/kestrel-env \
 && mkdir -p /output/nix/store \
 && readlink -f /tmp/kestrel-env > /output/kestrel-env-path \
 && nix-store -qR "$(readlink -f /tmp/kestrel-env)" \
      | xargs -I{} cp -a {} /output/nix/store/


# --- Stage 2: the course image ----------------------------------------------
FROM ubuntu:24.04@sha256:33ceb71981b602c1a7443a53469e4dba065f7503eab3078a2d7a57a2ab987517

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8

# --- The pinned tool closure ------------------------------------------------
COPY --from=nixenv /output/nix /nix
COPY --from=nixenv /output/kestrel-env-path /nix/.kestrel-env-path
RUN ln -s "$(cat /nix/.kestrel-env-path)" /opt/kestrel

# Freeze apt to a snapshot of the Ubuntu archive. Any `apt-get install` the
# student runs in Chapter 13 resolves against this same frozen index, so the
# lesson text can name exact versions and still be right later.
ARG UBUNTU_SNAPSHOT=20260801T000000Z
RUN set -eux; \
    printf 'Types: deb\nURIs: https://snapshot.ubuntu.com/ubuntu/%s\nSuites: noble noble-updates noble-security\nComponents: main restricted universe multiverse\nSigned-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg\n' \
      "$UBUNTU_SNAPSHOT" > /etc/apt/sources.list.d/ubuntu.sources; \
    printf 'Acquire::Check-Valid-Until "false";\n' > /etc/apt/apt.conf.d/99no-check-valid-until; \
    printf 'Acquire::https::CaInfo "/opt/kestrel/etc/ssl/certs/ca-bundle.crt";\n' > /etc/apt/apt.conf.d/99kestrel-cacert

# Ubuntu images ship with man pages, docs and locales stripped by dpkg excludes.
# The Dig tier of every lesson depends on `man` actually working, so undo that
# BEFORE installing anything, then reinstall the packages that were gutted.
RUN rm -f /etc/dpkg/dpkg.cfg.d/excludes

# Only the Debian-side plumbing lives here now; the course tools come from Nix.
RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates \
      man-db manpages manpages-dev bash-completion \
      sudo \
      util-linux bsdextrautils \
      passwd adduser \
# The minimized base image diverts /usr/bin/man to a stub that just tells you
# to run `unminimize` (which this image does not carry). Undo the diversion so
# the real man-db binary is back in place before its man pages are restored.
    && rm -f /usr/bin/man \
    && dpkg-divert --quiet --remove --rename /usr/bin/man \
# The base image was built with those dpkg excludes in force, so the man pages
# of packages that were ALREADY installed are gone from disk even though dpkg
# lists them. Reinstalling is the only way to get them back.
    && apt-get install -y --reinstall \
         man-db manpages bash dash coreutils \
         passwd login adduser util-linux sudo ncurses-bin grep sed gzip tar \
    && rm -rf /var/lib/apt/lists/*

# Deliberately NOT installed -- Chapter 13 is about installing things, and 13/06
# cannot be solved without doing it:  ncdu  ripgrep  tldr  ncal

# Nix puts its man pages under its own prefix. man-db only indexes what
# manpath.config lists, so register the merged tree explicitly and build the
# index over it -- otherwise `man jq` fails and every Dig tier breaks.
# MANDATORY_MANPATH alone only makes `man jq` work. `mandb`/`apropos`/`whatis`
# additionally need a MANDB_MAP, which is what tells mandb the tree is a global
# manpath and where to keep its (writable) index -- the Nix store is read-only.
RUN printf 'MANDATORY_MANPATH\t/opt/kestrel/share/man\nMANPATH_MAP\t/opt/kestrel/bin\t/opt/kestrel/share/man\nMANDB_MAP\t/opt/kestrel/share/man\t/var/cache/man/kestrel\n' \
      >> /etc/manpath.config \
 && mandb -q

ENV PATH=/opt/kestrel/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Login shells and `sudo` both reset PATH from their own config, not from ENV.
RUN printf 'PATH=/opt/kestrel/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin\n' > /etc/environment \
 && printf 'Defaults secure_path="/opt/kestrel/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"\n' > /etc/sudoers.d/10-kestrel-path \
 && chmod 0440 /etc/sudoers.d/10-kestrel-path

# --- Fixture cast (chapters 9, 10, 15) -------------------------------------
# plocate ships as `plocate` with no `locate` name, and its updatedb wants a
# `plocate` group to own the database. Provide both, so `locate` is the command
# a student expects and `sudo updatedb` works without further setup.
RUN groupadd -r plocate \
 && ln -s /opt/kestrel/bin/plocate /usr/local/bin/locate

RUN groupadd crew \
 && groupadd engineering \
 && groupadd ops \
 && useradd -m -s /bin/bash -G crew,engineering rhea \
 && useradd -m -s /bin/bash -G crew            cass \
 && useradd -m -s /bin/bash -G crew,ops        dorn \
 && useradd -m -s /usr/sbin/nologin -G ops     ops-bot

# --- The student ------------------------------------------------------------
RUN useradd -m -s /bin/bash -G crew,sudo,plocate cadet \
 && echo 'cadet:kestrel' | chpasswd \
 && echo 'cadet ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/90-cadet \
 && chmod 0440 /etc/sudoers.d/90-cadet

# Passwords for the fixture cast -- chapter 10 has the student manage these.
RUN echo 'rhea:orbit' | chpasswd \
 && echo 'cass:orbit' | chpasswd \
 && echo 'dorn:orbit' | chpasswd

# Build the locate database now, at image build time. /labs is a volume and is
# empty here, so a fresh container's index is genuinely stale with respect to
# every lab -- which is the whole point of lesson 06/06.
RUN updatedb

RUN mkdir -p /labs && chown cadet:crew /labs && chmod 0775 /labs
RUN mkdir -p /course

COPY --chown=root:root bashrc-seed /etc/skel/.kestrel-bashrc-seed
RUN cat /etc/skel/.kestrel-bashrc-seed >> /home/cadet/.bashrc \
 && chown cadet:cadet /home/cadet/.bashrc

USER cadet
WORKDIR /home/cadet
CMD ["sleep", "infinity"]
