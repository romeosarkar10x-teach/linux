# SOURCE_COURSE.md — boot.dev *Learn Linux*, fully mapped

This is the **exact ceiling of the student's prior knowledge**. Anything not on this page must be
taught systematically by this course before it appears in an exercise.

Source on disk:
`/home/romeo/github/romeosarkar10x_hack/boot_dev_course_scraper/courses/learn-linux`

Layout: `metadata.json` at root; each lesson is `NN-chapter/NN-lesson/{readme.md, response.json}`.
`readme.md` is the lesson prose plus its `## Assignment`. `response.json` holds the lesson type and,
for shell lessons, the checks.

Totals: **7 chapters, 66 lessons, 133 files.**

## Lesson types found

| Type | Count-ish | Mechanism |
|---|---|---|
| `type_shell` | most of ch 1–4 | Auto-checked. `ShellData.Checks[]` with either `RunCommand` (run a command, compare output) or `MatchCommand.LastContains` (the student's last command must contain given substrings). |
| `type_choice` | ~17 | `LessonDataMultipleChoice.Questions[]` — question, answers, correct answer. |
| `type_text_input` | all of ch 5–7 | `LessonDataTextInput` — student self-reports; effectively unverified. |

Shell lessons run with `Cwd: /home/user`, `StarterFilesRoot: /home/user`. Scenario data is the
fictional bank **worldbanc**, fetched with `curl` in chapter 2 and re-downloaded locally in
chapter 5 (`05-local-cli/04-download-worldbanc`).

## Complete lesson list

### 1. The Command Line (7)
| # | Slug | Title | Type | Topics |
|---|---|---|---|---|
| 1 | 1-welcome | Welcome to Learn Linux | shell | terminal emulator, bash, CLI |
| 2 | 2-terminals | What Is a Terminal? | choice | terminal emulator, TTY, terminal hardware |
| 3 | 3-shells | What Is a Shell? | shell | shell, REPL, bash, `expr` |
| 4 | 4-text-vs-gui | Command Line vs. GUI | choice | CLI vs GUI, `whoami`, shell automation |
| 5 | 5-variables | Variables | shell | shell variables, bash syntax, `echo`, string interpolation |
| 6 | 6-history | History | shell | `history`, shell history |
| 7 | 7-nav-history | Navigate History | choice | arrow keys, `clear` |

### 2. Filesystems (17)
| # | Slug | Title | Type | Topics |
|---|---|---|---|---|
| 1 | 1-filesystem | What Is a Filesystem? | shell | filesystem, `pwd`, root dir, working dir |
| 2 | 2-filepaths | Filepaths | shell | paths, `ls`, `cd`, `curl` |
| 3 | 3-navigation | Parent Directories | shell | `..`, `cd`, `ls` |
| 4 | 4-absolute-relative | Absolute vs. Relative Paths | choice | absolute/relative paths |
| 5 | 5-files | Files | shell | `cat`, file contents |
| 6 | 6-tab-completion | Tab Completion | shell | tab completion |
| 7 | 7-head-tail | head and tail | shell | `head`, `tail` |
| 8 | 8-more-less | More and Less | choice | `less`, `more`, paging |
| 9 | 9-touch | Touch | shell | `touch`, file creation, timestamps |
| 10 | 10-directories | Directories | shell | `mkdir` |
| 11 | 11-mv | Move | shell | `mv`, renaming |
| 12 | 12-rm | Remove | shell | `rm`, recursive deletion |
| 13 | 13-copy | Copy | shell | `cp`, recursive copy |
| 14 | 14-home | Home | choice | home dir, `~` |
| 15 | 15-grep | Grep | shell | `grep`, pattern matching |
| 16 | 16-grepfiles | grep Multiple Files | shell | `grep -R` |
| 17 | 17-find | Find | shell | `find`, wildcard patterns |

### 3. Programs (7)
| # | Slug | Title | Type | Topics |
|---|---|---|---|---|
| 1 | 1-compiled-vs-interpreted | Compiled vs. Interpreted | choice | program execution |
| 2 | 2-executables | Executables | shell | executable files, `chmod`, execute permission |
| 3 | 3-shebang | Shebang | shell | shebang, script execution |
| 4 | 4-bourne | Bourne Shell | choice | `sh`, bash, zsh |
| 5 | 5-env-vars | Environment Variables | shell | `export`, `printenv` |
| 6 | 6-path | PATH | shell | PATH, command search |
| 7 | 7-change-path | Change Your PATH | shell | `export`, `which` |

### 4. Input/Output (9)
| # | Slug | Title | Type | Topics |
|---|---|---|---|---|
| 1 | 1-help | Help | shell | `--help` |
| 2 | 2-flags | Flags | shell | flag syntax, `ls` |
| 3 | 3-positional-args | Positional Arguments | shell | args, `grep` |
| 4 | 4-exit-codes | Exit Codes | shell | exit codes, `$?` |
| 5 | 5-stdout | Standard Output | shell | stdout, output streams |
| 6 | 6-stderr | Standard Error | shell | stderr, stream redirection |
| 7 | 7-stdin | Standard In | shell | stdin, `wc` |
| 8 | 8-pipe | Piping | shell | `|`, `grep`, `wc`, `--exclude-dir` |
| 9 | 9-unix-philosophy | Unix Philosophy | choice | modularity, composability |

### 5. Local CLI (12) — all `type_text_input` or `type_choice`, i.e. unverified
| # | Slug | Title | Type | Topics |
|---|---|---|---|---|
| 1 | 1-open-terminal | Open a Terminal | text_input | terminal emulator |
| 2 | 2-wsl | Installing WSL | choice | WSL 2, Ubuntu |
| 3 | 3-terminals-local | Terminal Alternatives | choice | Ghostty, Alacritty, Windows Terminal |
| 4 | 4-download-worldbanc | Download Worldbanc | text_input | `curl`, local env |
| 5 | 5-shell-config | Shell Configuration | choice | `.bashrc`, `.zshrc`, dotfiles |
| 6 | 6-config-path | PATH Config | choice | `.bashrc`, PATH |
| 7 | 7-shell-aliases | Shell Aliases | text_input | `alias`, `unalias` |
| 8 | 8-man | Man | choice | `man`, man pages |
| 9 | 9-symlinks | Symbolic Links | text_input | `ln -s`, symlinks |
| 10 | 10-top | Top | text_input | `top`, process monitoring |
| 11 | 11-sigint | Interrupt | text_input | SIGINT, Ctrl+C |
| 12 | 12-sigkill | Kill | text_input | SIGKILL, `kill`, `ps` |

### 6. Permissions (8)
| # | Slug | Title | Type | Topics |
|---|---|---|---|---|
| 1 | 1-users | Users | choice | `whoami`, Linux users |
| 2 | 2-whoami-sudo | Whoami and sudo | text_input | `whoami`, `sudo`, root |
| 3 | 3-permissions | Permissions | choice | rwx notation, `ls -l` |
| 4 | 4-chmod | Changing Permissions | text_input | `chmod`, `-R`, `u=rwx,g=,o=` |
| 5 | 5-execute-permission | Making a Script Executable | text_input | execute permission |
| 6 | 6-root | Root User | choice | root, superuser |
| 7 | 7-chown | Chown | text_input | `chown`, ownership |
| 8 | 8-using-sudo | Using sudo | text_input | `sudo`, `apt` |

### 7. Editors and Packages (6)
| # | Slug | Title | Type | Topics |
|---|---|---|---|---|
| 1 | 1-package-managers | Package Managers | text_input | `apt`, `brew`, Neovim |
| 2 | 2-use-nvim | Using Neovim | text_input | Neovim, modal editing |
| 3 | 3-package-manager-review | Package Manager Review | choice | `sudo apt update` |
| 4 | 4-webi | Webi | text_input | Webi, `curl` |
| 5 | 5-vscode | Code Editors | choice | Zed, VS Code |
| 6 | 6-vscode-wsl | Code Editors on WSL | choice | WSL 2, remote dev |

## The knowledge ceiling, condensed

**Commands the student has seen:** `echo whoami expr history clear pwd ls cd cat head tail less
more touch mkdir mv rm cp grep find chmod chown curl export printenv which wc man top ps kill ln
alias unalias sudo apt brew nvim`

**Concepts the student has seen:** terminal vs shell, REPL, shell variables and interpolation,
absolute vs relative paths, `~`, `..`, tab completion, compiled vs interpreted, shebang, exec
permission, env vars, PATH, `--help`, flags vs positional args, exit codes and `$?`, stdout/stderr,
basic redirection, stdin, single pipes, Unix philosophy, `.bashrc`/`.zshrc`, aliases, symlinks,
SIGINT/SIGKILL, users, rwx, `chmod` symbolic form, root, `sudo`, apt/brew.

## Gaps — everything the student has NEVER seen

`sed awk cut sort uniq tr xargs tee paste column nl tac split tree stat file du df ncdu lsof pstree
htop pgrep pkill killall nohup disown jobs fg bg nice renice mkfifo readlink mktemp id groups
useradd usermod groupadd passwd userdel visudo umask getfacl tar gzip zip sha256sum md5sum locate
type whereis hash shopt apropos tldr dpkg shellcheck`

Concepts never seen: globbing rules and `shopt` glob options, brace expansion, quoting semantics and
word splitting/IFS, regex (BRE vs ERE), `find` beyond `-name`, inodes, hard links, file types
beyond regular/dir/symlink, atime/mtime/ctime, `/proc` and `/sys`, the FHS as a whole, heredocs and
herestrings, `2>&1` ordering, `&&`/`||`/`;` chaining, subshells, process substitution, job control,
signals beyond INT/KILL, groups and supplementary groups, `/etc/passwd`+`/etc/group`+`/etc/shadow`,
octal permissions, `umask`, setuid/setgid/sticky, login vs interactive vs non-interactive shells and
startup file order, shell functions, `PS1`, script arguments, `if`/`for`/`while`/`case`/`test`,
arrays, arithmetic expansion, command substitution, `set -euo pipefail`, `trap`, `dpkg`, man page
sections, archives, checksums.
