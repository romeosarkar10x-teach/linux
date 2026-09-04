#!/usr/bin/env bash
# Lab setup — 12/03 conditionals
set -euo pipefail

LAB="/labs/12-shell-scripting/03-conditionals"
rm -rf "$LAB"
mkdir -p "$LAB"/{bin,tree,notes,scratch}

# --- a small tree with one of every file test's answer ----------------------
cd "$LAB/tree"
printf 'deck-01 nominal\n' > regular.txt
: > empty.txt
mkdir subdir
ln -s regular.txt link-ok
ln -s nowhere link-broken
printf '#!/usr/bin/env bash\necho ran\n' > runnable.sh
chmod 755 runnable.sh
printf 'no exec bit here\n' > not-runnable.txt
chmod 444 readonly.txt 2>/dev/null || { printf 'read only\n' > readonly.txt; chmod 444 readonly.txt; }
cd - >/dev/null

# --- scripts ----------------------------------------------------------------
cat > "$LAB/bin/three-ways" <<'SH'
#!/usr/bin/env bash
# The same question asked three ways. All three are correct here. That is the
# point: they stop agreeing later.
word="$1"
if test "$word" = deck;    then echo "test:   yes"; else echo "test:   no"; fi
if [ "$word" = deck ];     then echo "[ ]:    yes"; else echo "[ ]:    no"; fi
if [[ "$word" = deck ]];   then echo "[[ ]]:  yes"; else echo "[[ ]]:  no"; fi
SH

cat > "$LAB/bin/gate" <<'SH'
#!/usr/bin/env bash
# rhea's, 2186. Checks whether a deck name matches the expected one.
# It has run on every shift since and been right every time.
expected=deck
if [ $1 = $expected ]; then
    echo "match"
else
    echo "no match"
fi
SH

cat > "$LAB/bin/version-gate" <<'SH'
#!/usr/bin/env bash
# Refuses to run against a toolchain older than release 9.
# Written in 2186, when 9 was the newest release there was.
have="$1"
if [[ $have > 8 ]]; then
    echo "toolchain $have: new enough"
else
    echo "toolchain $have: TOO OLD, refusing" >&2
    exit 1
fi
SH

cat > "$LAB/bin/count-gate" <<'SH'
#!/usr/bin/env bash
# Same comparison, done as arithmetic instead of as text.
have="$1"
if [ "$have" -gt 8 ]; then
    echo "toolchain $have: new enough"
else
    echo "toolchain $have: TOO OLD, refusing" >&2
    exit 1
fi
SH

cat > "$LAB/bin/classify" <<'SH'
#!/usr/bin/env bash
# Names what a path is. Order matters here in a way worth arguing about.
p="$1"
if   [ -L "$p" ];  then echo "symlink"
elif [ -d "$p" ];  then echo "directory"
elif [ -f "$p" ];  then echo "regular file"
elif [ -e "$p" ];  then echo "exists, none of the above"
else                    echo "does not exist"
fi
SH

cat > "$LAB/bin/readiness" <<'SH'
#!/usr/bin/env bash
# Four conditions, one report. Read it before you trust it.
DECK="$1"
TREE=/labs/12-shell-scripting/03-conditionals/tree
if [ -e "$TREE/$DECK" ] && [ -r "$TREE/$DECK" ] && [ -s "$TREE/$DECK" ]; then
    echo "$DECK: ready"
else
    echo "$DECK: not ready"
fi
SH

chmod 755 "$LAB"/bin/*

# --- notes ------------------------------------------------------------------
cat > "$LAB/notes/three-forms.txt" <<'TXT'
test EXPR      a builtin. Also a real program at /usr/bin/test.
[ EXPR ]       the same builtin under a different name. The ] is an ARGUMENT,
               which is why it must be there and why spaces matter.
[[ EXPR ]]     a bash KEYWORD, not a command. The shell parses it specially.

Because [ ] is a command, its arguments go through word splitting and globbing
first, like any other command's. That is the whole source of its surprises:

    v=""      [ $v = x ]      becomes  [ = x ]       -> unary operator expected
    v="a b"   [ $v = x ]      becomes  [ a b = x ]   -> too many arguments

Quote and both go away. Inside [[ ]] no splitting happens, so the unquoted
form works -- which is why [[ ]] is the friendlier one and also why people who
learn only [[ ]] write [ ] wrong.

Use [[ ]] in bash scripts. Use [ ] when the script must run under sh.
TXT

cat > "$LAB/notes/operators.txt" <<'TXT'
Strings:   =  ==  !=  -z (empty)  -n (non-empty)
Numbers:   -eq -ne -lt -le -gt -ge
Files:     -e exists      -f regular file   -d directory   -L symlink
           -r readable    -w writable       -x executable
           -s non-empty   -nt newer than    -ot older than
Logic:     && ||  between two [ ] commands, or inside [[ ]]
           -a -o inside [ ] -- legal, deprecated, and ambiguous. Avoid.

The numeric operators are spelled with letters and the string operators are
spelled with symbols. This is backwards from every other language you will
meet, and it is worth ten seconds of memorising now:

    [ "$a" -gt "$b" ]     compares two NUMBERS
    [[ $a > $b ]]         compares two STRINGS, in collation order

"10" > "9" is FALSE as text, because 1 sorts before 9. It is TRUE as
arithmetic. A gate written with the wrong one is right for nine releases.
TXT

cat > "$LAB/notes/exit-status.txt" <<'TXT'
`if` does not test a value. It runs a command and looks at its exit status.
0 is true. Anything else is false.

    if grep -q nominal decks; then ...      no [ ] anywhere; grep IS the test
    if [ -f x ]; then ...                   [ is a command too

So `if [ $(wc -l < f) ]` is almost always a mistake: it tests whether the
NUMBER is a non-empty string, which it always is.

&& and || chain on status:
    cmd && echo ok || echo failed

That last line is not an if/else. If `echo ok` itself fails, `echo failed`
runs as well. Use if/else when you mean if/else.
TXT

cat > "$LAB/notes/page.txt" <<'TXT'
ops-bot -- 2187-07-01 03:05

Automated notice. Toolchain release 10 published. Gate script version-gate
reports: "toolchain 10: TOO OLD, refusing". Exit status 1. Deployment held.

Gate script has not been modified since 2186-02-19. No action available.
TXT

find "$LAB" -exec touch -h -d '2187-07-01 09:00:00' {} +
chmod 444 "$LAB/tree/readonly.txt"
touch -d '2186-08-02 11:55:00' "$LAB"/notes/three-forms.txt "$LAB"/notes/operators.txt "$LAB"/notes/exit-status.txt
touch -d '2187-07-01 03:05:00' "$LAB/notes/page.txt"
touch -d '2186-02-19 10:30:00' "$LAB/bin/gate" "$LAB/bin/version-gate"
touch -d '2187-06-30 12:00:00' "$LAB/tree/regular.txt"
touch -d '2186-01-01 12:00:00' "$LAB/tree/empty.txt"
