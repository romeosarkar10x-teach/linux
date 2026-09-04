#!/usr/bin/env bash
# Lab setup — 12/01 first-script
set -euo pipefail

LAB="/labs/12-shell-scripting/01-first-script"
rm -rf "$LAB"
mkdir -p "$LAB"/{bin,broken,notes,scratch,ops}

# --- working examples -------------------------------------------------------
cat > "$LAB/bin/deck-count.sh" <<'SH'
#!/usr/bin/env bash
# Counts the deck records in the ops tree. The first script anybody on this
# station writes, and the one they keep.
wc -l < /labs/12-shell-scripting/01-first-script/ops/decks
SH

cat > "$LAB/bin/greet" <<'SH'
#!/usr/bin/env bash
echo "kestrel station, deck operations"
echo "shell: $BASH_VERSION"
SH

cat > "$LAB/bin/exit-three" <<'SH'
#!/usr/bin/env bash
echo "doing the thing"
exit 3
echo "this line does not run"
SH

cat > "$LAB/bin/last-command-wins" <<'SH'
#!/usr/bin/env bash
echo "checkpoint"
false
SH

# --- the broken ones, one failure shape each --------------------------------

# 1. no exec bit
cat > "$LAB/broken/no-bit.sh" <<'SH'
#!/usr/bin/env bash
echo "I run fine. Getting me to run is the problem."
SH

# 2. no shebang at all
cat > "$LAB/broken/no-shebang.sh" <<'SH'
echo "no first line here"
SH

# 3. shebang naming an interpreter that does not exist
cat > "$LAB/broken/bad-interpreter.sh" <<'SH'
#!/usr/local/bin/bash
echo "the path in my first line is a guess"
SH

# 4. sh shebang, bash-only syntax inside
cat > "$LAB/broken/wrong-shell.sh" <<'SH'
#!/bin/sh
decks=(alpha beta gamma)
echo "second deck: ${decks[1]}"
SH

# 5. CRLF line endings (written from a station terminal that was not one)
printf '#!/usr/bin/env bash\r\necho "my line endings came from somewhere else"\r\n' \
    > "$LAB/broken/crlf.sh"

chmod 755 "$LAB"/bin/* "$LAB"/broken/*.sh
chmod 644 "$LAB/broken/no-bit.sh"

# --- data -------------------------------------------------------------------
seq -w 1 14 | sed 's/^/deck-/; s/$/ nominal/' > "$LAB/ops/decks"

cat > "$LAB/ops/tidy.sh" <<'SH'
#!/usr/bin/env bash
# Housekeeping. Runs nightly. Do not edit without filing.
echo "cleanup complete, 0 files removed"
SH
chmod 755 "$LAB/ops/tidy.sh"

# --- notes ------------------------------------------------------------------
cat > "$LAB/notes/shebang.txt" <<'TXT'
The first line is not a comment. It looks like one, and the shell treats it
like one, but the kernel reads the first two bytes of a file before it will
execute it. If those bytes are #! it takes the rest of the line as the program
to run, and hands it the script's path as an argument.

    ./deck-count.sh          becomes      /usr/bin/env bash ./deck-count.sh

Which means:
  - the path in the shebang must be a real, executable file
  - it is a path, not a command name; PATH is not searched
  - #!/usr/bin/env bash searches PATH, because env does, and env's own path
    is stable across systems in a way that bash's is not
  - the kernel only cares if you execute the file. `bash script.sh` never
    looks at the first line at all -- you named the interpreter yourself.
TXT

cat > "$LAB/notes/three-ways.txt" <<'TXT'
Three ways to run the same file, and they are not the same.

  ./script.sh    executes the file. Needs the exec bit. Kernel reads the
                 shebang. Runs in a NEW shell -- variables set inside do not
                 come back.

  bash script.sh executes bash, and hands it the file to read. No exec bit
                 needed. Shebang ignored. Still a new shell.

  . ./script.sh  ("source") reads the lines into the shell you are already in.
                 No new process. No exec bit. Shebang ignored. Variables,
                 cd, aliases -- all of it stays.

The first two answer "run this program". The third answers "become this".
Startup files are sourced. Tools are executed. Confusing them is how somebody
writes a script to cd somewhere and then wonders why they are still here.
TXT

cat > "$LAB/notes/status.txt" <<'TXT'
A script's exit status is the status of the last command it ran, unless it
says otherwise with `exit N`.

That is a default, not a decision. A script whose last line is an echo exits
0 no matter what happened three lines earlier, and every caller believes it.

Chapter 11 lesson 05 showed you a script that reported a wrong answer and
exited 0. This chapter is where you stop writing those.
TXT

cat > "$LAB/notes/page.txt" <<'TXT'
ops-bot -- 2187-06-29 04:12

Automated notice. Script /ops/tidy.sh completed. Log line: "cleanup complete,
0 files removed". Exit status 0. No action required.
TXT

# --- dates ------------------------------------------------------------------
find "$LAB" -exec touch -d '2187-06-29 09:00:00' {} +
touch -d '2186-08-02 11:45:00' "$LAB"/notes/shebang.txt "$LAB"/notes/three-ways.txt "$LAB"/notes/status.txt
touch -d '2187-06-29 04:12:00' "$LAB/notes/page.txt"
touch -d '2186-01-11 08:00:00' "$LAB/ops/tidy.sh" "$LAB/ops/decks"
