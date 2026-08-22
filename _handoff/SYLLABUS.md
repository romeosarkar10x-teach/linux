# SYLLABUS.md — Approved table of contents

**16 chapters (0–15) · 102 lessons · ~630 exercises.**

`(review)` = covered by boot.dev, being re-drilled. `(review+)` = covered but extended here.
Unmarked = new to the student. Dependency rule: nothing may appear in an exercise before the
lesson that introduces it.

---

### Chapter 0 — Boarding the Kestrel (setup) · 6 lessons · ~12 exercises
1. `01-what-this-course-is` — how lessons, tiers, agents, and flags work
2. `02-vm-setup` — VirtualBox + Ubuntu guest, guest additions, snapshots (take one now)
3. `03-install-docker` — Docker Engine on Ubuntu, `docker` group, hello-world
4. `04-course-container` — build/run the Kestrel image, `kestrel` helper, lab dirs, reset
5. `05-getting-help` — how to ask the tutor agent; what it will and won't tell you
6. `06-recording-your-work` — `script`, `history -a`, asciinema, video expectations

### Chapter 1 — Shell & Terminal, Properly · 7 lessons · ~40 exercises
1. `01-terminal-vs-shell-vs-tty` **(review)** — emulator/shell/tty split, `tty`, `echo $$`, `ps -p $$`
2. `02-shells-on-the-box` **(review)** — `/etc/shells`, `sh` vs `bash` vs `dash` vs `zsh`, `$0`
3. `03-command-anatomy` — command/arg/flag parsing, `type`, `which`, builtin vs external vs alias
4. `04-variables` **(review)** — assignment, `$VAR` vs `${VAR}`, unset vs empty, `${VAR:-default}`
5. `05-readline` — Ctrl-A/E/W/U/K/R/L, Alt-. , tab completion, editing long commands
6. `06-history` **(review)** — `history`, `!!`, `!$`, `!n`, Ctrl-R, `HISTSIZE`, `HISTCONTROL`
7. `07-incident-01` — CTF: recover a mistyped command from history, first flag

### Chapter 2 — Navigating the Filesystem · 7 lessons · ~45 exercises
1. `01-filesystem-tree` **(review)** — `/`, `pwd`, working directory, absolute vs relative
2. `02-cd-and-ls-deep` **(review+)** — `cd -`, `~`, `ls -a -l -h -t -S -R -d --color`, sorting
3. `03-the-fhs-tour` — `/etc /var /usr /bin /opt /tmp /home /proc /dev /root`, what lives where
4. `04-proc-and-sys` — `/proc/cpuinfo`, `/proc/<pid>/`, why the kernel exposes files
5. `05-tree-and-stat` — `tree`, `stat`, `file`, `du -sh`, `df -h`
6. `06-paths-in-anger` — spaces, dashes, unicode, dotfiles, `--` end-of-options
7. `07-incident-02` — CTF: locate a stowaway file from a cryptic path hint

### Chapter 3 — Files, Links & Types · 6 lessons · ~40 exercises
1. `01-everything-is-a-file` — the 7 types in `ls -l` first column, `file`, `/dev/null`, `/dev/zero`
2. `02-inodes` — `ls -i`, `stat`, what a filename really is
3. `03-hard-vs-symlinks` **(symlinks: review)** — `ln`, `ln -s`, breaking, dangling, `readlink -f`
4. `04-timestamps` **(touch: review)** — atime/mtime/ctime, `touch -t`, `find -newer`
5. `05-devices-fifos-sockets` — `mkfifo` experiment across two terminals, `/dev/tty`
6. `06-incident-03` — CTF: a symlink maze; follow it to the flag

### Chapter 4 — Creating, Copying & Destroying · 5 lessons · ~35 exercises
1. `01-cat-and-friends` **(review+)** — `cat`, `tac`, `nl`, `head`, `tail`, `tail -f`, `less` navigation
2. `02-touch-mkdir` **(review)** — `mkdir -p`, `-m`, brace expansion for tree building
3. `03-cp-mv` **(review+)** — `-r -i -n -u -a -v`, trailing-slash gotchas, moving vs renaming
4. `04-rm-safely` **(review+)** — `-r -f -i`, `--`, `rm -rf /` folklore, `mktemp`, trash pattern
5. `05-incident-04` — CTF: rebuild a directory tree from a manifest file

### Chapter 5 — Globbing & Quoting · 5 lessons · ~45 exercises *(all new)*
1. `01-globs` — `*`, `?`, `[abc]`, `[a-z]`, `[!x]`, glob ≠ regex, `shopt -s dotglob nullglob globstar`
2. `02-brace-expansion` — `{a,b}`, `{1..10}`, `{01..10}`, nesting, expansion order
3. `03-quoting` — bare vs `'single'` vs `"double"`, backslash, what each disables
4. `04-word-splitting` — IFS, why `"$var"` matters, filenames with spaces, `set -x` to watch it
5. `05-incident-05` — CTF: adversarially-named files; select exactly the right set

### Chapter 6 — Searching: grep, regex & find · 7 lessons · ~50 exercises
1. `01-grep-basics` **(review)** — pattern, file, case sensitivity
2. `02-grep-flags` **(-R: review)** — `-i -v -n -c -l -L -w -x -o -A -B -C -r --include --exclude-dir`
3. `03-regex-bre-ere` — anchors, classes, quantifiers, groups, alternation, `grep -E`, `-P` note
4. `04-find-basics` **(review)** — `-name -iname -type -maxdepth`
5. `05-find-advanced` — `-size -mtime -mmin -perm -user -empty`, `-exec {} \;` vs `+`, `-delete`, `-print0`
6. `06-locate-which-type-whereis` — index vs walk, `updatedb`
7. `07-incident-06` — CTF: forensic sweep of the station logs, multi-flag

### Chapter 7 — Text Processing Pipelines · 8 lessons · ~50 exercises *(all new)*
1. `01-wc-sort-uniq` — `sort -n -r -k -t -u`, `uniq -c -d -u`, the `sort | uniq -c | sort -rn` idiom
2. `02-cut-and-paste` — `-d -f -c`, fixed vs delimited, `paste`, `column -t`
3. `03-tr` — squeeze, delete, complement, case folding
4. `04-sed-substitution` — `s///`, `g`, `-i`, delimiters, addresses, `-n p`, `d`
5. `05-awk-fields` — `$1 $NF NF NR`, `-F`, patterns, `BEGIN/END`, sums and counts
6. `06-tee-and-xargs` — `tee -a`, `xargs -n -I{} -0 -P`, pairing with `find -print0`
7. `07-building-a-pipeline` — method: build left-to-right, inspect at each stage
8. `08-incident-07` — CTF: turn a raw access log into a ranked report

### Chapter 8 — Streams, Redirection & Exit Codes · 6 lessons · ~45 exercises
1. `01-stdout-stderr` **(review)** — fd 0/1/2, why they're separate
2. `02-redirection` **(review+)** — `> >> < 2> 2>&1 &> /dev/null`, order matters, truncation
3. `03-heredocs` — `<<EOF`, `<<'EOF'`, `<<-`, `<<<` herestring
4. `04-pipes-deep` **(review+)** — `|`, `|&`, buffering, `head` + SIGPIPE, why `cat file |` is a smell
5. `05-exit-codes-and-chaining` **(review+)** — `$?`, `true`/`false`, `&&`, `||`, `;`, `!`, subshells `( )`
6. `06-incident-08` — CTF: capture a noisy program's stderr only, without losing stdout

### Chapter 9 — Processes & Job Control · 7 lessons · ~45 exercises
1. `01-what-is-a-process` — pid, ppid, fork/exec model, `ps -ef`, `ps aux`, `pstree`
2. `02-top-and-htop` **(top: review)** — load, %CPU vs %MEM, sorting, killing from top
3. `03-signals` **(SIGINT/SIGKILL: review+)** — signal table, `kill -l`, TERM vs KILL vs HUP vs STOP/CONT
4. `04-kill-pkill-pgrep` — by pid, by name, by user, `killall`, being precise
5. `05-job-control` — `&`, `jobs`, `fg`, `bg`, Ctrl-Z, `disown`, `nohup`, `&` + redirection
6. `06-process-inspection` — `/proc/<pid>/cmdline|environ|fd`, `lsof` intro, `nice`/`renice`
7. `07-incident-09` — CTF: a runaway process eating the station's CPU; identify, trace, stop it

### Chapter 10 — Users, Groups & Permissions · 8 lessons · ~50 exercises
1. `01-users-and-ids` **(review+)** — `/etc/passwd`, uid/gid, `id`, `whoami`, system vs human users
2. `02-groups` — `/etc/group`, primary vs supplementary, `groups`, `usermod -aG`, re-login gotcha
3. `03-managing-accounts` — `useradd`/`adduser`, `passwd`, `userdel`, `/etc/shadow` (read-only look)
4. `04-rwx-and-octal` **(review+)** — the 9 bits, `ls -l` decoding, octal ↔ symbolic, dir `x` = traverse
5. `05-chmod` **(review+)** — symbolic vs numeric, `-R`, `+X`, common patterns
6. `06-chown-chgrp-umask` **(chown: review)** — ownership, `-R`, default perms via `umask`
7. `07-sudo-and-root` **(review+)** — `su` vs `sudo`, `sudo -i`, `/etc/sudoers`, `visudo`, least privilege
8. `08-special-bits` — setuid, setgid on dirs, sticky bit on `/tmp`; CTF: find the setuid backdoor

### Chapter 11 — Environment & Shell Configuration · 6 lessons · ~40 exercises
1. `01-env-vars` **(review+)** — shell var vs env var, `export`, `env`, `printenv`, `unset`, subshell inheritance
2. `02-path` **(review+)** — lookup order, `which -a`, `hash`, adding a personal `~/bin`
3. `03-startup-files` **(bashrc: review+)** — login vs interactive vs non-interactive; `.bashrc`,
   `.bash_profile`, `.profile`, `/etc/profile`; experiments proving which runs when
4. `04-aliases-and-functions` **(alias: review+)** — `alias`, `unalias`, when a function is required, `\cmd`
5. `05-prompt-and-options` — `PS1`, colors, `shopt`, `set -o`, `HISTCONTROL`, making it persist
6. `06-incident-10` — CTF: a sabotaged `.bashrc`; diagnose and repair without deleting it

### Chapter 12 — Shell Scripting · 9 lessons · ~50 exercises
1. `01-first-script` **(shebang/chmod +x: review+)** — shebang, exec bit, `./` vs PATH, `bash script.sh`
2. `02-arguments` — `$0 $1 $# $@ $*`, `"$@"` vs `$@`, `shift`
3. `03-conditionals` — `test`, `[ ]`, `[[ ]]`, string/number/file tests, `if/elif/else`
4. `04-loops` — `for` over globs and lists, `while read -r line`, `until`, `break`/`continue`
5. `05-case-and-functions` — `case`, functions, `local`, return codes vs echo
6. `06-input-and-arithmetic` — `read`, `$(( ))`, `$( )` command substitution, arrays
7. `07-robust-scripts` — `set -euo pipefail`, quoting discipline, `trap`, `mktemp`, `shellcheck`
8. `08-ship-a-tool` — write `stationctl`, make it executable, put it on PATH, add a `--help`
9. `09-incident-11` — CTF: write a script that audits the station and prints the flag

### Chapter 13 — Packages, Docs & Editors · 6 lessons · ~30 exercises
1. `01-apt` **(review+)** — `update` vs `upgrade`, `install`, `remove` vs `purge`, `search`, `show`, `list --installed`
2. `02-dpkg-and-repos` — `dpkg -l/-L/-S`, `.deb` install, sources.list, PPAs, apt vs snap
3. `03-man-pages` **(review+)** — sections, `man 5 passwd`, `apropos`, `man -k`, `/` search, `info`, `tldr`
4. `04-installing-tools` — `htop tree jq ripgrep shellcheck ncdu` into the container; verifying installs
5. `05-editors` **(nvim: review+)** — `nano` survival, `vim` modes/motions/save-quit, `$EDITOR`
6. `06-incident-12` — CTF: a needed tool is missing; install it and use it to read the flag

### Chapter 14 — Archives, Disks & Integrity · 4 lessons · ~25 exercises *(all new)*
1. `01-tar` — `-c -x -t -z -j -f -v`, why `-f` last, extracting safely, `--strip-components`
2. `02-compression` — `gzip/gunzip`, `zip/unzip`, `zcat`, `zgrep`, size comparisons
3. `03-disk-usage` — `df -h`, `du -sh --max-depth`, `ncdu`, finding the space hog
4. `04-checksums` — `sha256sum`, `md5sum`, `-c` verification, tamper-detection exercise

### Chapter 15 — Final Capstone: The Kestrel Breach · 5 lessons · ~30 exercises
1. `01-the-briefing` — full incident scenario, rules of engagement
2. `02-triage` — processes, users, and open files: who is in the system
3. `03-forensics` — logs, timestamps, permissions: reconstruct the timeline
4. `04-remediation` — revoke access, fix permissions, restore config, verify
5. `05-report` — write the incident report + an automation script; final flag
