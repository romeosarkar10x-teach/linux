#!/usr/bin/env bash
# setup.sh -- seeds /labs/05-globbing-and-quoting/05-incident-05
#
# THE ANSWER KEY. Students are told not to open this.
#
# Incident: housekeeping swept deck-05/ on 2187-06-01 03:00 with sweep.sh.
# Seven files survived. Five of them survived BY DESIGN, one per mechanism
# from this chapter, and each carries a `# tag:` line. Read in glob order
# (which is C collation order here) the five tags read:
#     named to survive the sweep
# -> KESTREL{named_to_survive_the_sweep}
#
# The five survivors and why each one survived sweep.sh:
#   -strain-05.log      leading dash   rm read it as options; that one rm failed
#   .handover-05.log    leading dot    `*` does not match dotfiles without dotglob
#   05 readings.log      embedded space unquoted $f split into two nonexistent names
#   panel-03.log~       trailing tilde `*.log` does not match `*.log~`
#   panel-09.log~       trailing tilde same
#
# The two red herrings survived by ACCIDENT and carry no tag:
#   .bay-06-notes       leading dot,   mtime 2187-05-12
#   spare parts.txt     embedded space, mtime 2187-05-20
# The five designed files all carry mtime 2187-06-01 02:58 -- two minutes
# before the sweep. That is the discriminator, and it is a Chapter 2/3 skill.
#
# The one glob that selects exactly the five (with dotglob on):
#   shopt -s dotglob; cat -- *.log*
# It needs dotglob (ch5 L1), `--` (ch5 L3), and the fact that glob results
# are not word split (ch5 L4). With dotglob off you get four files and a
# sentence that is missing a word -- a loud failure, not a silent one.
#
# Chained CTF (the Dig), four stages, STAGE{} tokens, none registered:
#   1 globs          records/bay-0[13579]-*.tar -> exactly one file
#   2 brace          expand the given brace expression; one path exists
#   3 quoting        count asterisks in notice.txt; only works quoted (answer 3)
#   4 word splitting read field 6 of a colon record with an empty field
#
# Idempotent: removes its own tree first, creates nothing outside LAB.
set -euo pipefail

LAB="/labs/05-globbing-and-quoting/05-incident-05"
rm -rf "$LAB"
mkdir -p "$LAB"/{deck-05,housekeeping,records,scratch}
cd "$LAB"

########## deck-05: the swept directory ##########

cat > 'deck-05/-strain-05.log' <<'EOF'
2187-05-29 14:02  bay-01  strain 0.41
2187-05-29 14:02  bay-02  strain 0.44
2187-05-30 06:11  bay-01  strain 0.52
2187-05-30 06:11  bay-02  strain 0.47
# tag: named
EOF

cat > 'deck-05/.handover-05.log' <<'EOF'
2187-05-30 handover, deck 05.
Bays 01 through 07 walked. Bay 06 still not fitted.
Panel 03 reading high since the 28th. Panel 09 unchanged.
# tag: to
EOF

cat > 'deck-05/05 readings.log' <<'EOF'
2187-05-31 02:00  panel-03  0.71
2187-05-31 02:00  panel-05  0.44
2187-05-31 02:00  panel-09  0.43
# tag: survive
EOF

cat > 'deck-05/panel-03.log~' <<'EOF'
panel-03, previous revision. Superseded 2187-05-31.
Reading trend: 0.44 0.51 0.63 0.71
# tag: the
EOF

cat > 'deck-05/panel-09.log~' <<'EOF'
panel-09, previous revision. Superseded 2187-05-31.
Reading trend: 0.43 0.43 0.43 0.43
# tag: sweep
EOF

cat > 'deck-05/.bay-06-notes' <<'EOF'
bay 06 checklist, not finished
- fitting: no
- readings: n/a
- handover: no
checked
EOF

cat > 'deck-05/spare parts.txt' <<'EOF'
spares held for deck 05, as of 2187-05-20
strain gauge x2
panel cover x1
pending
EOF

########## housekeeping ##########

cat > housekeeping/notice.txt <<'EOF'
HOUSEKEEPING NOTICE -- posted 2187-05-28, deck 05

Storage on deck 05 is at 94%. A sweep will run at 0300 on 2187-06-01 and
will remove log, text and backup files from deck-05/.

The patterns are published below so that nobody is surprised:

    *.log
    *.txt
    *.bak

Anything you need kept, move it off deck-05/ before the sweep runs.
The sweep script is in this directory. Read it if you want to know
exactly what it does; nobody is hiding anything.

Records of what deck-05/ held before the sweep are in records/, indexed
by bay. The index files are named bay-NN-<something>.tar.
EOF

cat > housekeeping/sweep.sh <<'EOF'
#!/usr/bin/env bash
# deck-05 housekeeping sweep. Runs 0300.
cd /deck-05 || exit 1
for f in *.log *.txt *.bak; do
    rm -f $f
done
EOF
chmod 644 housekeeping/sweep.sh

cat > housekeeping/sweep-2187-06-01.log <<'EOF'
2187-06-01 03:00:00  sweep start, target deck-05
2187-06-01 03:00:00  patterns: *.log *.txt *.bak
2187-06-01 03:00:01  removed 41 files
2187-06-01 03:00:01  rm reported 1 failure, continuing
2187-06-01 03:00:01  sweep end
EOF

########## records ##########

cat > records/manifest-2187-05-28.txt <<'EOF'
deck-05 contents, taken 2187-05-28 09:00

48 entries. 41 were removed by the sweep of 2187-06-01. Seven were not.

This manifest records names and nothing else. It does not record which
files anybody cared about, and it was not written with the sweep in mind.
EOF

cat > records/naming-convention.txt <<'EOF'
Engineering naming convention, deck logs.

A file that belongs to a set carries a tag line as its last line:

    # tag: <one word>

The tags of a set, read in the order the files sort, form one phrase.
The convention exists so that a set can be checked for completeness
without a manifest: if the phrase does not read, a file is missing.

Files that are not part of a set do not carry a tag line.
EOF

# --- CTF stage 1: exactly one file matches records/bay-0[13579]-*.tar
for n in 02 04 06 08 10 12; do
    printf 'index placeholder, bay %s\n' "$n" > "records/bay-${n}-index.tar"
done
for n in 01 03 05 07 09; do
    printf 'index placeholder, bay %s\n' "$n" > "records/bay-${n}-index.txt"
done
printf 'index placeholder\n' > records/bay-index.tar
printf 'index placeholder\n' > records/bay-0x-index.tar
cat > 'records/bay-07-sequence.tar' <<'EOF'
STAGE{first_pattern_holds}

Stage 2. The path below was written as a brace expression because the
person writing it did not know which of the expansions existed. Exactly
one of them does. Expand it, find the one that is there, and read it.

    ../records/{old,new,draft}/panel-{03,05,09}-{a,b}.note
EOF

# --- CTF stage 2: exactly one of the 18 expansions exists
mkdir -p records/old records/new records/draft
printf 'empty\n' > records/old/panel-11-a.note
printf 'empty\n' > records/new/panel-07-b.note
cat > records/draft/panel-05-b.note <<'EOF'
STAGE{eighteen_names_one_file}

Stage 3. Count the lines of ../../housekeeping/notice.txt that contain a
literal asterisk. Most people get this wrong on the first try, because
the shell eats the pattern before grep ever sees it, and the wrong answer
does not look like an error.

Then read stage-3.txt in this directory and take the record on the line
whose first field is that count.
EOF

cat > records/draft/stage-3.txt <<'EOF'
1:STAGE{wrong_line_try_again}:deck-05::no:STAGE{that_was_the_unquoted_answer}
2:STAGE{wrong_line_try_again}:deck-05::no:STAGE{that_was_a_guess}
3:STAGE{quote_it_or_lose_it}:deck-05::yes:STAGE{fourth_field_is_empty}
4:STAGE{wrong_line_try_again}:deck-05::no:STAGE{off_by_one}
EOF

cat > records/draft/stage-4.txt <<'EOF'
Stage 4. The record you took is colon separated. It has six fields and
one of them is empty. Read it with a single `read`, without cutting it up
by eye, and report field 6.

That token is the last one. It is also the answer to the question this
chapter has been circling: a set of files does not survive a published
pattern by luck. Somebody read the notice, and then named things.

Nothing in this lab records who. Do not invent it.
EOF

########## timestamps ##########

# the five designed survivors: two minutes before the sweep
touch -d '2187-06-01 02:58:00' \
    'deck-05/-strain-05.log' 'deck-05/.handover-05.log' \
    'deck-05/05 readings.log' 'deck-05/panel-03.log~' 'deck-05/panel-09.log~'
# the two accidents: weeks old
touch -d '2187-05-12 11:40:00' 'deck-05/.bay-06-notes'
touch -d '2187-05-20 16:05:00' 'deck-05/spare parts.txt'

touch -d '2187-05-28 07:30:00' housekeeping/notice.txt housekeeping/sweep.sh
touch -d '2187-06-01 03:00:01' housekeeping/sweep-2187-06-01.log
touch -d '2187-05-28 09:00:00' records/manifest-2187-05-28.txt
touch -d '2186-08-14 10:00:00' records/naming-convention.txt
touch -d '2187-05-28 09:00:00' records/*.tar records/*.txt
touch -d '2187-05-28 09:00:00' records/old/* records/new/* records/draft/*

echo "seeded $LAB"
