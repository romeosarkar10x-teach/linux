# CHEATSHEET.md — cumulative command reference

Everything the course has formally taught, in syllabus order, with the flags the
lessons actually use. Nothing here appears before the chapter that teaches it, so
you can read down to where you are and stop.

This is a lookup for things you have already learned. It is not a substitute for
`man`, it does not list every flag any of these commands has, and a flag missing
from here is not a flag that does not exist.

Commands you find yourself in a Dig-tier exercise are yours to keep. They are not
listed here unless a later lesson teaches them properly.

---

## Ch 0 — Boarding

| | |
|---|---|
| `docker run` / `exec` / `ps` / `start` / `stop` | run and re-enter the course container |
| `kestrel start`, `kestrel shell`, `kestrel seed NN/NN` | the course's own wrapper |
| `kestrel flags submit 'KESTREL{...}'`, `kestrel status` | flag registry and progress |
| `script -q typescript` … `exit` | record a terminal session to a file |
| `man CMD`, `man -k WORD` | the manual, and searching its index |

## Ch 1 — Shell, terminal, history

| | |
|---|---|
| `echo`, `printf` | write to stdout; `printf` for anything with structure |
| `type NAME` | what will run: builtin, alias, function, file, keyword |
| `which NAME` | the file that would run — and only that |
| `tty` | which terminal device you are attached to |
| `ps`, `echo $$` | the shell you are in, and its pid |
| `bash`, `sh`, `dash`, `zsh`, `fish` | shells; `chsh` changes the login shell |
| `NAME=value` / `export NAME=value` | shell variable / exported to children |
| `$?`, `$$`, `$0`, `$HOME`, `$PATH` | the variables the shell sets for you |
| `history`, `!!`, `!N`, `Ctrl-r` | history list, re-run, reverse search |
| `HISTCONTROL=ignorespace` | a leading space keeps a line out of history |
| `clear`, `Ctrl-l` | clear the screen |
| `exit`, `Ctrl-d` | leave the shell |

Readline: `Ctrl-a` `Ctrl-e` line start/end · `Ctrl-w` kill word · `Ctrl-u` kill to
start · `Ctrl-k` kill to end · `Ctrl-y` yank · `Alt-.` last argument · Tab complete.

## Ch 2 — Navigating the filesystem

| | |
|---|---|
| `pwd`, `pwd -P` | where you are; `-P` resolves symlinks |
| `cd DIR`, `cd -`, `cd` | move; previous directory; home |
| `ls -l -a -h -t -r -d -i -R` | long, hidden, human sizes, by time, reverse, the directory itself, inode, recursive |
| `file PATH` | what a file is, by content and not by name |
| `stat PATH` | size, type, inode, links, owner, modes, timestamps |
| `tree -L N -a -d` | the tree, to a depth |
| `df -h`, `du -h --max-depth=1` | free space per filesystem; space per directory |
| `/proc/PID/`, `/proc/PID/cmdline` | live kernel state as files |

Paths: absolute starts at `/`; relative does not; `.` here, `..` up, `~` home.
The FHS directories the course uses: `/bin` `/etc` `/home` `/var` `/tmp` `/opt`
`/proc` `/sys` `/dev`.

## Ch 3 — Files, links, types

| | |
|---|---|
| `stat -c '%n %i %h %U %A %s'` | one line, the fields you choose |
| `ln TARGET NAME` | hard link — a second name for one inode |
| `ln -s TARGET NAME` | symlink — a file containing a path |
| `readlink`, `readlink -f` | what a symlink points at; the resolved path |
| `touch -d 'YYYY-MM-DD HH:MM'`, `touch -h`, `touch -a`, `touch -m` | set timestamps; `-h` acts on the link itself |
| `stat` timestamps | mtime content, ctime metadata, atime read, Birth creation |
| `mkfifo`, `/dev/null`, `/dev/zero`, `/dev/urandom` | fifos and the device files that matter |

File-type letters in `ls -l`: `-` regular · `d` directory · `l` symlink ·
`c` character device · `b` block · `p` fifo · `s` socket.

## Ch 4 — Creating, copying, destroying

| | |
|---|---|
| `cat`, `cat -A`, `cat -n` | show a file; show invisible characters; number lines |
| `head -n N`, `tail -n N`, `tail -f` | first, last, follow |
| `less` | page a file (`/` search, `n`, `q`) |
| `nl`, `wc -l -w -c` | number lines; count |
| `touch FILE`, `mkdir -p`, `rmdir` | create empty, create nested, remove empty |
| `cp`, `cp -r -a -i -n -v`, `cp --preserve=timestamps` | copy; recursive, archive, prompt, no-clobber, verbose |
| `mv -i -n -v` | move and rename |
| `rm`, `rm -r -f -i -v`, `rm -- -file` | remove; `--` ends option parsing |
| `mktemp`, `mktemp -d` | a temporary file or directory nobody else owns |

`cp` plain preserves nothing. `cp -a` preserves mode, owner, mtime and atime —
never ctime, never birth.

## Ch 5 — Globbing and quoting

| | |
|---|---|
| `*` `?` `[abc]` `[a-z]` `[!a]` | glob patterns — expanded by the shell, not the command |
| `{a,b}`, `{1..9}`, `{01..12}` | brace expansion, which happens before globbing |
| `'single'` | no expansion at all |
| `"double"` | `$VAR`, `` `cmd` ``, `\` still expand |
| `\c` | escape one character |
| `shopt -s nullglob failglob dotglob globstar` | what an unmatched or hidden glob does; `**` |
| `echo` before `rm` | run the glob through `echo` first, every time |

## Ch 6 — Searching

| | |
|---|---|
| `grep PATTERN FILE`, `-i -v -n -c -l -L -w -x -r -R` | match; ignore case, invert, line numbers, count, names only, names without, word, whole line, recursive |
| `grep -E`, `grep -F`, `grep -o`, `-A -B -C` | extended regex, fixed strings, matched part only, context |
| BRE vs ERE | `\+ \? \|` in BRE are `+ ? |` in ERE |
| Regex | `.` `*` `^` `$` `[]` `\<` `\>` `\{n,m\}` |
| `find PATH -name -iname -type -size -mtime -newer -perm -user -group` | select files |
| `find … -newermt 'DATE'`, `-newerct` | by mtime / ctime against a date |
| `find … -printf '%p %u %m %T@ %TY-%Tm-%Td\n'` | print exactly the fields you want |
| `find … -exec CMD {} \;` / `{} +` | run per file / batched |
| `find … -prune`, `-maxdepth`, `-mindepth` | control the walk |
| `locate`, `updatedb` | an index, and why it can be stale |
| `type`, `which`, `whereis`, `hash -r` | four different questions about a name |

## Ch 7 — Text processing

| | |
|---|---|
| `wc -l -w -c -L` | counts |
| `sort -n -r -u -k N -t CHAR -h` | numeric, reverse, unique, key, delimiter, human sizes |
| `uniq -c -d -u` | on **sorted** input: count, dupes only, singles only |
| `cut -d CHAR -f N,M`, `cut -c N-M` | fields by delimiter; characters |
| `paste -d`, `paste -s` | join files side by side; one line |
| `tr 'a' 'b'`, `tr -d`, `tr -s`, `tr -c` | translate, delete, squeeze, complement |
| `sed 's/a/b/'`, `s///g`, `s///N`, `-n 'Np'`, `Nd`, `-i`, `-E` | substitute, all, nth, print, delete, in place, ERE |
| `awk '{print $1, $NF}'`, `-F`, `NR`, `NF`, `$0`, `BEGIN`/`END`, patterns | fields, separator, line number, field count, whole line |
| `tee`, `tee -a` | write to a file *and* to stdout |
| `xargs`, `xargs -n N`, `-I{}`, `-0`, `find -print0` | build command lines from input, safely |
| `printf '%s %5.2f\n'` | formatted output |
| `basename`, `dirname` | split a path |

## Ch 8 — Streams and redirection

| | |
|---|---|
| `0` `1` `2` | stdin, stdout, stderr |
| `> FILE`, `>> FILE`, `< FILE` | overwrite, append, read |
| `2> FILE`, `2>&1`, `&> FILE` | stderr; stderr to wherever stdout is *now*; both |
| `cmd > f 2>&1` vs `cmd 2>&1 > f` | order matters, and this pair is why |
| `\|`, `\|&` | pipe stdout; pipe both |
| `/dev/null` | the sink |
| `exec 3> FILE`, `>&3`, `exec 3>&-` | open, use and close your own descriptor |
| `<<EOF`, `<<'EOF'`, `<<-EOF` | heredoc; unexpanded; leading tabs stripped |
| `<<<"string"` | herestring |
| `$?`, `&&`, `\|\|`, `!` | exit status and the operators built on it |
| `set -e`, `set -u`, `set -o pipefail`, `set -x` | fail on error, on unset, on any pipe stage, trace |
| `${PIPESTATUS[@]}` | every stage's exit status |

Convention: 0 success · 1 general failure · 2 usage · 126 not executable ·
127 not found · 128+N killed by signal N.

## Ch 9 — Processes and job control

| | |
|---|---|
| `ps`, `ps aux`, `ps -ef`, `ps -o pid,ppid,user,etimes,lstart,comm,args` | process listings; choose your own columns |
| `ps -p PID`, `ps --forest` | one process; the tree |
| `pgrep NAME`, `pgrep -f`, `pgrep -u`, `pgrep -a` | find pids; match the full command line |
| `pkill`, `pkill -f`, `pkill -SIGNAL` | signal by pattern |
| `kill PID`, `kill -TERM`, `kill -KILL`, `kill -HUP`, `kill -l` | signal by pid |
| `top`, `htop` | live view |
| `free -h`, `uptime` | memory; load |
| `jobs`, `bg`, `fg %1`, `Ctrl-z`, `Ctrl-c` | job control in one shell |
| `nohup`, `disown`, `setsid`, `&` | outliving the shell |
| `nice -n N`, `renice` | scheduling priority |
| `/proc/PID/` — `cmdline`, `environ`, `cwd`, `exe`, `fd/`, `status` | everything about a live process |
| `lsof -p PID`, `lsof FILE`, `lsof +L1`, `fuser` | open files; deleted-but-open files |
| `sleep`, `wait` | for scripts that have to pause |

`cmdline` and `environ` are NUL-separated: read them with `tr '\0' '\n' <`.

## Ch 10 — Users, groups, permissions

| | |
|---|---|
| `id`, `id -u`, `id -Gn`, `whoami`, `logname`, `groups` | who you are, and which groups |
| `/etc/passwd`, `/etc/group`, `/etc/shadow` | the account files, and who can read each |
| `getent passwd NAME` | look up an account properly (exit 2 if absent) |
| `last`, `lastlog` | login history |
| `useradd`, `usermod -aG`, `userdel`, `groupadd`, `passwd` | account management |
| `chown user:group`, `chown -R`, `chgrp`, `chown -h` | ownership |
| `chmod 644`, `chmod u+x,go-w`, `chmod -R`, `chmod a-x` | modes, octal and symbolic |
| `umask` | which bits new files do *not* get |
| `sudo`, `sudo -u USER`, `sudo -l`, `sudo -i`, `sudo -e` | run as someone else; what you may run; a root shell; edit a file |
| `/etc/sudoers`, `visudo`, `secure_path`, `env_reset` | how sudo is configured |
| `sg GROUP -c`, `newgrp` | run with a group you are in |

Special bits: **setuid** `4000` (`s` in the user `x` column) — ignored by Linux on
`#!` scripts · **setgid** `2000` — on a directory, new files inherit the group ·
**sticky** `1000` (`t`) — in a world-writable directory only the owner may delete.
`chmod 775` on a sticky directory silently drops the sticky bit; `chmod o-w` keeps it.

Directory bits: `r` list names · `w` create and delete entries · `x` traverse.
Without `x` on a directory you cannot reach anything inside it, whatever its own mode says.

## Ch 11 — Environment and shell config

| | |
|---|---|
| `env`, `printenv NAME`, `set` | exported environment; one variable; everything the shell has |
| `export`, `unset`, `VAR=x cmd` | export, remove, set for one command only |
| `$PATH`, `PATH="$PATH:/dir"` | where the shell looks, in order |
| `command -v`, `type -a`, `hash -r` | resolve a name; every match; forget the cache |
| `alias`, `unalias`, `\cmd` | aliases, and how to bypass one |
| `~/.bashrc`, `~/.profile`, `~/.bash_profile`, `/etc/profile` | interactive vs login startup files |
| `source FILE`, `. FILE` | run in the current shell, not a child |
| `shopt`, `set -o` | shell options |
| `$PS1`, `$EDITOR`, `$VISUAL`, `$LANG`, `$TZ` | the environment variables that change behaviour |

Login shell reads the profile files; interactive non-login reads `~/.bashrc`.
A variable that is not exported does not reach a child process.

## Ch 12 — Shell scripting

| | |
|---|---|
| `#!/usr/bin/env bash` | shebang, first line, no space before `#!` |
| `chmod +x`, `./script`, `bash script` | make it runnable, run it |
| `$0 $1 $@ $# "$@"` | script name, arguments, count — quote `"$@"` always |
| `shift`, `${1:-default}`, `${VAR:?message}` | consume arguments; defaults; require |
| `if … then … elif … else … fi` | conditionals |
| `[ -f -d -e -r -w -x -s -z -n ]`, `=`, `!=`, `-eq -ne -lt -le -gt -ge` | tests: files, strings, integers |
| `case … in PATTERN) … ;; esac` | dispatch |
| `for x in …; do … done`, `while …`, `until …` | loops |
| `while read -r line; do … done < FILE` | read a file line by line, safely |
| `break`, `continue`, `return`, `exit N` | control flow |
| `name() { … }`, `local` | functions, and keeping variables inside them |
| `$(cmd)`, `$(( arithmetic ))` | command substitution; integer arithmetic |
| `trap 'cleanup' EXIT INT TERM` | run something on the way out |
| `set -euo pipefail` | the four-word header for any script you keep |
| `shellcheck FILE` | read what it says before you argue with it |

Making a script a tool: shebang · executable bit · on `PATH` · `--help` ·
`--version` · a documented exit-code contract · configuration from the
environment with `: "${VAR:=default}"` · errors on stderr, results on stdout.

## Ch 13 — Packages, docs, editors

| | |
|---|---|
| `apt update`, `apt install`, `apt remove`, `apt purge`, `apt list --installed` | packages |
| `apt-get` vs `apt` | `apt-get` for scripts, `apt` for people |
| `apt show`, `apt search`, `apt-file` | before you install |
| `dpkg -l`, `dpkg -L PKG`, `dpkg -S FILE`, `dpkg -s PKG` | what is installed, what it put where, what owns a file |
| `/etc/apt/sources.list`, `/etc/apt/sources.list.d/` | where packages come from |
| `man N page`, `man -k`, `apropos`, `whatis`, `man -f` | the manual; sections 1 5 8 matter most |
| `info`, `CMD --help`, `/usr/share/doc/PKG/` | the other three places documentation hides |
| `nano` — `^O` write, `^X` exit, `^W` search, `^\` replace, `^K`/`^U` cut/paste | |
| `vim` — `i` insert, `Esc`, `:w` `:q` `:wq` `:q!` `:e!` | |
| `vim` movement — `0 ^ $`, `gg G`, `NNgg`, `w b`, `/word` `n` `N` | |
| `vim` editing — `dd`, `x`, `u`, `Ctrl-r`, `:%s/a/b/g`, `:%s/a/b/gc` | |
| `vim` display — `:set number`, `:set list`, `:set paste`, `:set ff=unix` | |
| `vim -R`, `vimtutor`, `~/.vimrc` | read-only, the tutorial, your config |
| `$EDITOR`, `$VISUAL`, `sudo -e` | which editor runs, and how to edit a root-owned file as yourself |

`sudo -e` runs *your* editor as *you* on a copy and writes it back with the
original owner and mode. `sudo vim` runs the whole editor — plugins, shell
escapes and all — as root.

## Ch 14 — Archives, disks, integrity

| | |
|---|---|
| `tar -tf`, `tar -tvf` | **list before you extract**, every time |
| `tar -cf`, `-czf`, `-xf`, `-xzf` | create, create compressed, extract |
| `tar -C DIR`, `--strip-components=N`, `--sort=name`, `--mtime` | extract elsewhere; drop leading path parts; reproducible archives |
| `gzip`, `gzip -k -d -t -l -9`, `gunzip` | compress (replaces the input unless `-k`), decompress, test, list |
| `zcat`, `zgrep`, `zless`, `zdiff` | read compressed files without decompressing them |
| `bzip2`, `xz`, `zip`, `unzip` | the others, and what `zip` does not preserve |
| `df -h`, `df -i` | space and inodes, as the filesystem sees them |
| `du -h --max-depth=1`, `du -sh`, `du --apparent-size` | space by name, and blocks vs bytes |
| `ncdu` | when `du` output is too big to read |
| `sha256sum`, `sha256sum -c`, `-c --strict`, `md5sum` | compute and verify |
| `cmp`, `cmp -l`, `diff`, `diff -u`, `diff -q` | are two files the same, and how they differ |
| `lsof +L1`, `/proc/PID/fd/` | space held by a deleted file that is still open |

A checksum proves the bytes are the ones the checksum was taken from. It does
not prove they are correct, that the file is complete as intended, that the
manifest is trustworthy, or that the checksum was taken before the damage.

## Ch 15 — Capstone

Nothing new. The capstone uses only what is above.

The method it asks for: **triage** (who, what is running, what is open) →
**timeline** (`find -printf` and `sort`, clustered by time and by owner) →
**remediate in order** (close, fix, stop, restore, prove) → **report** (what
happened, when, who did what, what you changed, what would have caught it).

Say what you measured. Label what you inferred. Leave out what you are
guessing. Stop where the evidence stops.
