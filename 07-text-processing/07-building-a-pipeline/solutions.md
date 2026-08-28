# 07 — Solutions: building a pipeline

Every output below was produced in the container. Where a command lies, the lie is shown, not fixed
silently.

## Looking at the input (1–8)

**1.** `2187-06-10T00:00:00Z  [INFO ] panel=deck-01/p-a actor=ops-bot action=read dur=12ms` — an
ISO timestamp, a bracketed severity, then four `key=value` fields.

**2.** `128`.

**3.**
```
$ grep -c '^$' logs/maint-raw.txt      # 4
$ grep -c '^#' logs/maint-raw.txt      # 3
$ grep -c '^2187' logs/maint-raw.txt   # 120
```

**4.** 4 + 3 + 120 = 127, and the file has 128 lines. The leftover is `dump complete: rc=0`. It is not
blank, not a comment, and not a record — the exact class of line that survives a subtractive filter.

**5.** Because `grep -v '^#' | grep -v '^$'` describes the junk you have already seen. `grep '^2187'`
describes the records, and records are a fixed shape while junk is not. Proof:
`grep -v '^#' logs/maint-raw.txt | grep -v '^$' | grep -vc '^2187'` prints `1`.

**6.** `dump complete: rc=0` survives it. The `# end of dump` line does not.

**7.** `wc -l logs/access-2187-06-10.log` is `600`, and every one of those lines is a record. The
access log is the clean one; that is why the chapter started there.

**8.** **120.**

## Growing a pipeline (9–20)

**9.**
```
$ grep '^2187' logs/maint-raw.txt | head -3
2187-06-10T00:00:00Z  [INFO ] panel=deck-01/p-a actor=ops-bot action=read dur=12ms
2187-06-10T00:11:50Z  [INFO ] panel=deck-04/p-c actor=ops-bot action=read dur=362ms
2187-06-10T00:23:25Z  [WARN ] panel=deck-02/p-b actor=ops-bot action=write dur=187ms
```

**10.** `… | awk '{print $4}' | head -3` prints `panel=deck-01/p-a`, `panel=deck-04/p-c`,
`panel=deck-02/p-b`. Not actors. If you looked, you caught it here, three seconds in.

**11.**
```
     11 panel=deck-04/p-c
     11 panel=deck-02/p-d
     10 panel=deck-04/p-b
     ...
      9 actor=ops-bot
     ...
      2 actor=rhea
      1 actor=vint
      1 actor=cass
```
Two kinds of thing in one table. Mostly panels, and thirteen actors mixed in among them. Worse than
being entirely wrong, because the actor rows look like a correct answer.

**12.** The counts still sum to 120 — the stage dropped nothing, it just extracted the wrong thing.
A count check does not catch this bug. That is why it is not the only check.

**13.**
```
$ awk '/^2187/{print NF}' logs/maint-raw.txt | sort -u
6
7
```
The records do not all have the same number of fields, so no single field number means the same thing
on every line.

**14.** `[INFO ]` and `[WARN ]` contain a space inside the brackets, so `awk` splits them into `[INFO`
and `]` — seven fields. `[ERROR]` has no space — six fields. The severity column is padded to a fixed
*width*, and width is not fields.

**15.** The six-field lines are exactly the ERROR lines: 9 + 2 + 1 + 1 = 13 actor rows in exercise 11,
and `grep -c ERROR logs/maint-raw.txt` is `13`. On those thirteen lines field 4 is the actor. On the
other 107 it is the panel.

**16.**
```
$ sed -n 's/.*actor=\([^ ]*\).*/\1/p' logs/maint-raw.txt | sort | uniq -c | sort -rn
     83 ops-bot
     19 rhea
     11 cass
      4 vint
      2 orla
      1 bex
```

**17.** 83 + 19 + 11 + 4 + 2 + 1 = **120**. Matches exercise 8.

**18.**
```
$ awk -F'actor=' '/^2187/{split($2, a, " "); print a[1]}' logs/maint-raw.txt | sort | uniq -c | sort -rn
```
Same six rows, same counts.

**19.** Either defence is fine if it is a defence. The `sed` version is one expression and works on
any line containing `actor=`; the `awk` version splits twice and needs the `/^2187/` guard to avoid
choking on the comment lines. Most people find the `sed` easier to re-read; the `awk` is easier to
extend when you want a second field too.

**20.** **When a field's position is not stable, extract by the field's name, not its number.**

## Counts as tests (21–30)

**21.** `awk '{s += $1} END {print s}'`

**22.** Both print `120`.

**23.**
```
$ sed -n 's#.*/\(p-[a-d]\).*#\1#p' logs/maint-raw.txt | sort | uniq -c
     29 p-a
     30 p-b
     31 p-c
     30 p-d
```
29 + 30 + 31 + 30 = 120. Note the `#` delimiter — the pattern contains a `/`.

**24.** `6`. Six distinct accounts touched a panel that day.

**25.**
```
$ grep -o '\[[A-Z ]*\]' logs/maint-raw.txt | sort | uniq -c
     13 [ERROR]
     80 [INFO ]
     27 [WARN ]
```
13 + 80 + 27 = 120. Yes.

**26.**
```
$ sed -n 's/.*\[\([A-Z]*\) *\].*actor=\([^ ]*\).*/\1 \2/p' logs/maint-raw.txt | sort | uniq -c | sort -k1,1rn
     55 INFO ops-bot
     19 WARN ops-bot
     13 INFO rhea
      9 ERROR ops-bot
      7 INFO cass
      4 WARN rhea
      3 INFO vint
      3 WARN cass
      2 ERROR rhea
      1 ERROR cass
      1 ERROR vint
      1 INFO bex
      1 INFO orla
      1 WARN orla
```
The ` *` inside the pattern eats the padding space so the severity comes out clean.

**27.** 14, against a possible 18. Fewer, because not every account produced every severity — real
data is sparse. A table built from `for` loops over both dimensions would have shown four rows of
zero that never happened; a table built from the data shows only what occurred. Both are defensible;
they answer different questions.

**28.** `ops-bot`, `rhea` and `cass` appear as all three.

**29.** `bex` only ever appears as `INFO`.

**30.** Benign: the `grep` matched every line, because the thing you filtered for is present on all of
them. Bug: the `grep` matched nothing and the count you are reading comes from a later stage that
produces output regardless — a `wc -l` printing `0`, or a `uniq -c` on an empty stream printing
nothing while the surrounding `printf` still prints a header.

## The broken five (31–40)

**31.** Prediction is usually "counts of error types". Actual:
```
      1 2187-06-10T22:38:10Z  [ERROR] panel=deck-01/p-c actor=ops-bot action=read dur=82ms
      1 2187-06-10T20:52:55Z  [ERROR] panel=deck-04/p-d actor=vint action=exec dur=397ms
      ...
```
Thirteen lines, every count `1`.

**32.** The bug is `uniq -c` on lines that are all distinct — every record has a unique timestamp, so
nothing is adjacent-duplicate and nothing collapses. The one-word fix is to count the lines instead:
`grep ERROR logs/maint-raw.txt | wc -l` → `13`. (If the author actually wanted a *ranking*, they
needed a stage that extracts a repeated field first. `uniq -c` on raw records is almost always this
bug.)

**33.**
```
$ awk '{print $3}' logs/maint-raw.txt | sort | uniq -c | sort -n | head -5
      1 are
      1 daemon
      1 of
      1 rc=0
      3 panel=deck-02/p-b
```
`are` is field 3 of the comment line `# fields are key=value, order is not guaranteed`. There is no
stage-one filter, so the header comments are being processed as data. And `sort -n` sorts *ascending*,
so `head -5` shows the rarest.

**34.**
```
$ sed -n 's/.*actor=\([^ ]*\).*/\1/p' logs/maint-raw.txt | sort | uniq -c | sort -rn | head -5
     83 ops-bot
     19 rhea
     11 cass
      4 vint
      2 orla
```
Two fixes: filter to records (here, implicit — `actor=` only appears on records), and `-rn` not `-n`.

**35.** `cat logs/access-2187-06-10.log | grep rhea | wc -l` prints `96`, which is right. Wrong
anyway: the `cat` is a pointless process (`grep` opens files), and the `wc -l` duplicates something
`grep` already does.

**36.** `grep -c rhea logs/access-2187-06-10.log` → `96`. One process instead of three.

**37.**
```
$ awk '{print $5}' logs/access-2187-06-10.log | sort -u | wc -l > reports/decks.txt | cat
$ echo $?      # 0
$ cat reports/decks.txt
4
```
`cat` printed nothing. The redirection binds to `wc`, so `wc`'s stdout goes to the file and the pipe
into `cat` receives end-of-file immediately. `cat` reads an empty stream and prints nothing, then
exits 0 — so the whole pipeline reports success while producing no visible output at all. The file
does get the `4`.

**38.** That is what `tee` is for:
```
$ awk '{print $5}' logs/access-2187-06-10.log | sort -u | wc -l | tee reports/decks.txt
4
```

**39.**
```
$ grep -c write logs/access-2187-06-10.log | sort | uniq -c
      1 150
```
`grep -c` emits **one line containing a number**. Sorting one line and counting duplicates of it can
only ever produce `1 <number>`. The author wanted to count something per-group and reached for `-c`,
which collapses the stream to a single number before the grouping stages ever see it.

**40.** Defensible answers: A, because thirteen rows of `1` look like a plausible histogram of rare
events; or D, because the pipeline exits 0, prints nothing, and writes a correct file — nothing about
it looks like a failure until someone asks why the terminal was silent. C is the one you *would*
catch, and it is the only one of the five that is not actually wrong.

## Exit status and pipes (41–47)

**41.**
```
$ grep nosuch logs/maint-raw.txt | wc -l
0
$ echo $?
0
```
The pipeline's status is `wc`'s status, and `wc` succeeded at counting zero lines.

**42.**
```
$ grep nosuch logs/maint-raw.txt | wc -l ; echo "${PIPESTATUS[@]}"
0
1 0
```
`grep` returned 1 (no match), `wc` returned 0.

**43.** `PIPESTATUS` is rewritten by every command the shell runs, including the plain one. It is only
meaningful on the line immediately after the pipeline — capture it into a variable if you need it
later.

**44.**
```
$ set -o pipefail
$ grep nosuch logs/maint-raw.txt | wc -l ; echo $?
0
1
$ set +o pipefail
```

**45.** Because failing stages are routine and often intended. From lesson 06: `seq 1 100000 | head -2`
kills `seq` with SIGPIPE, so under `pipefail` that pipeline "fails" every time even though it did
exactly what was asked. `pipefail` in a script is good discipline; `pipefail` around a deliberate
early exit is a false alarm.

**46.** `grep -c` exits 1 when the count is zero, even though it printed a number:
```
$ grep '^2187' logs/maint-raw.txt | grep -c FATAL
0
$ echo $?
1
```
A command that prints `0` and fails is the whole reason to check status rather than output.

**47.** Believe a zero from a pipeline when you have checked that every stage before the last one
succeeded — `PIPESTATUS` or `pipefail` — or when you have separately confirmed the stream reaching
the last stage was non-empty. A zero produced by an empty stream and a zero produced by counting are
indistinguishable in the output.

## The report (48–56)

**48.** `grep -c ERROR logs/maint-raw.txt` → `13`.

**49.**
```
$ grep ERROR logs/maint-raw.txt | sed -n 's#.*/\(p-[a-d]\).*#\1#p' | sort | uniq -c | sort -rn
      4 p-c
      3 p-d
      3 p-b
      3 p-a
```
4 + 3 + 3 + 3 = 13. Checks against exercise 48.

**50.** `panel,criticality,owner` — criticality is column 2. The incomplete row is `p-d,critical,`:
its **owner** is empty. Its criticality is present, which matters in the next exercise.

**51.**
```
$ awk -F, 'NR > 1 { crit[$1] = $2 } END { for (k in crit) print k, crit[k] }' data/panels.csv | sort
p-a low
p-b high
p-c low
p-d critical
```
`NR > 1` skips the CSV header. Printing the array before using it is step 3 of the method.

**52.** The obvious version is wrong:
```
$ … | uniq -c | awk -F, 'NR==FNR{c[$1]=$2;next}{print "[" $1 "][" $2 "]"}' data/panels.csv -
[      3 p-a][]
[      3 p-b][]
```
`-F,` applies to **every** input file. The `uniq -c` output has no commas, so the whole line lands in
`$1` and `$2` is empty. Set the separator per file instead — split the CSV by hand and leave the
default whitespace `FS` in place for the counts:
```
$ grep ERROR logs/maint-raw.txt | sed -n 's#.*/\(p-[a-d]\).*#\1#p' | sort | uniq -c |
  awk 'NR==FNR { split($0, a, ","); if (FNR > 1) crit[a[1]] = a[2]; next }
       { printf "%-5s %-9s %s\n", $2, (($2 in crit) ? crit[$2] : "unknown"), $1 }' data/panels.csv -
p-a   low       3
p-b   high      3
p-c   low       4
p-d   critical  3
```
The trailing `-` is the standard-input stream as a second file argument.

**53.** It prints `p-d critical 3` — the blank field in the CSV is `owner`, and this report never
reads `owner`. That is the point: the incomplete data was not in the column being used, so nothing
went wrong. Missing data only matters where it is read. The `($2 in crit)` guard still earns its
place, because a panel letter that appears in the log and *not* in the CSV would otherwise print an
empty column that reads as a value.

**54.**
```
$ sort -k3,3rn      # by error count
p-c   low       4
p-a   low       3
p-b   high      3
p-d   critical  3

$ sort -k2,2        # by criticality, alphabetically
p-d   critical  3
p-b   high      3
p-a   low       3
p-c   low       4
```
By count, `p-c` leads with four low-criticality errors. By criticality, the critical panel is at the
top with three. The chief is deciding what to fix first, so criticality first, count as the
tiebreaker — but "alphabetically" only puts `critical` above `high` above `low` by luck, and that
luck will not survive a fourth severity being added. The question is about the reader because the
data does not know which column matters; the person acting on it does.

**55.** Print the header outside the sorted pipeline, in a group:
```
$ { printf '%-5s %-9s %s\n' PANEL CRITICALITY ERRORS
    grep ERROR logs/maint-raw.txt | sed -n 's#.*/\(p-[a-d]\).*#\1#p' | sort | uniq -c |
    awk 'NR==FNR { split($0, a, ","); if (FNR > 1) crit[a[1]] = a[2]; next }
         { printf "%-5s %-9s %s\n", $2, (($2 in crit) ? crit[$2] : "unknown"), $1 }' data/panels.csv - |
    sort -k3,3rn ; }
PANEL CRITICALITY ERRORS
p-c   low       4
p-a   low       3
p-b   high      3
p-d   critical  3
```
Same shape as lesson 05: sorting happens inside, the header is added outside.

**56.** Append `| tee reports/panel-errors.txt` to the closing `}`. Five lines saved, five lines
shown, one read of the log.

## Judgement (57–62)

**57.** Stage by stage:
```
$ sed -n 's/.*\[\([A-Z]*\) *\].*dur=\([0-9]*\)ms/\1 \2/p' logs/maint-raw.txt | head -3
INFO 12
INFO 362
WARN 187

$ … | wc -l
120

$ … | awk '{ s[$1] += $2; n[$1]++ } END { for (k in s) printf "%-6s %3d %7.1f\n", k, n[k], s[k]/n[k] }' | sort
ERROR   13   227.4
INFO    80   188.4
WARN    27   239.6
```
13 + 80 + 27 = 120, and the per-severity counts match exercise 25 exactly. Two independent checks on
one table.

**58.**
```
$ awk '/^2187/{ if (match($0,/dur=[0-9]+/)) s += substr($0,RSTART+4,RLENGTH-4) } END {print s, NR}' logs/maint-raw.txt
24498 128
```
The sum is right — it only accumulated inside the `/^2187/` block. `NR` is not: `NR` counts every
line `awk` **read**, not every line a pattern matched. The comments and blanks were read and skipped.
To count matches, increment your own variable in the block. Same shape of bug as field 4: a builtin
that means something close to what you wanted.

**59.** Re-run the pipeline truncated after stage one and look; then after stage two; and so on, or
insert `| tee scratch/sN.txt` between stages and diff the counts. The guilty stage is the first one
whose output does not contain what its name says it contains — you do not need to understand the
whole pipeline, only to find the first place the stream stops matching your description of it.

**60.** Replace it when the stages are all doing field-level work on the same records: one `awk` pass
is fewer processes, one read of the input, and one place to look. Leave the pipeline alone when the
stages are genuinely different tools — `sort` in the middle cannot be folded into `awk` without
reimplementing sorting — or when the pipeline is going into a report that other people have to read
and modify.

**61.** Self-assessment; the honest answers are step 1 and step 3. In this lesson, step 1 (`head -5`)
would have shown the padded severity column before `awk '{print $4}'` was ever written, and step 3
(look after every stage) catches it three seconds later at exercise 10. Skipping step 5 gets you
exercise 12, where the count check passes and the answer is still wrong.

**62.**
```
$ { printf '%-5s %-9s %s\n' PANEL CRITICALITY ERRORS; grep ERROR logs/maint-raw.txt | sed -n 's#.*/\(p-[a-d]\).*#\1#p' | sort | uniq -c | awk 'NR==FNR { split($0, a, ","); if (FNR > 1) crit[a[1]] = a[2]; next } { printf "%-5s %-9s %s\n", $2, (($2 in crit) ? crit[$2] : "unknown"), $1 }' data/panels.csv - | sort -k3,3rn ; } | tee reports/panel-errors.txt
```
against the multi-line form in exercise 55. The multi-line form goes in the report: a trailing pipe
tells the shell the command continues, each line is one stage, and a reviewer can point at the line
they doubt. The one-liner is for the prompt, where it is about to be replaced anyway.

## Authoring notes

- The field-count trap in this lesson is not contrived. `[INFO ]` is padded to the width of `[ERROR]`
  by the generator exactly the way real log formatters pad severity columns, and the consequence —
  `NF` differing by severity — was measured, not assumed: `awk '/^2187/{print NF}' | sort -u` really
  does print `6` and `7`, and the thirteen "actor" rows in exercise 11 really are the thirteen ERROR
  records.
- Exercise 52's `-F,` bug was hit while writing this lesson, not invented for it. The first draft of
  the join printed `[      3 p-a][]` and the fix — set the separator per file — became the exercise.
- Exercise 12 exists because a count check passes on a wrong answer here. Teaching counts as a test
  without showing a case they miss would be teaching a superstition.
- `maint-raw.txt` is generated from the access log by a fixed rule (every fifth record, severity by
  position), so every count in this file can be re-derived from the access log rather than trusted.
