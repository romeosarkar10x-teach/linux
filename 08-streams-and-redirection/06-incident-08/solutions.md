# 08/06 — Solutions: Incident, fourteen months of nominal

Every number measured in the container. **Flag: `KESTREL{it_complained_for_months}`** — registered as
`08/06`, and written in no file in the lab.

---

## Warmup

**1.** Complaint: fourteen months of reports all say `nominal`, on a deck where she has personally
replaced two panels. Request: not "read the logs again" — *is the summary the whole of what the tool
says?* The second is the one that can be answered tonight.

**2.** Standard output and standard error. A `.log` file written by a wrapper almost always contains
fd 1 only, because the redirection that made it named fd 1 and said nothing about fd 2.

**3.** Five files, `18` lines each. Constant length suggests a fixed-shape report — no per-event
lines at all, so nothing bad could ever lengthen it. It does not prove the runs were identical.

**4.** Header, `readings`, `months`, one mean line per month, `status ... nominal`. Nothing in that
shape can carry bad news: there is no field for it. The only number that could move is a mean, and a
clamped reading has already been pulled into range before the mean is computed.

**5.** A clean `grep` establishes that those words are not in *the file*. It cannot establish that
the program never said them — only that nothing wrote them here.

**6.** `bin/summarise > "logs/summarise-$DATE.log" 2>/tmp/summarise.err`. fd 1 to `logs/`, fd 2 to
`/tmp`. Only `logs/` still exists; `/tmp` is recycled.

**7.** Yes — `cat bin/nightly` shows the same line. Worth checking; notes drift from code.

**8.** p-03 and p-11 clamp routinely. The sentence to remember: *"p-07 in particular feeds the
door-log summariser, so a clamp there changes what the door log records for that day."*

## Running the tool

**9.** `18`. The report only.

**10.** 284 clamp warnings plus a summary line, all on fd 2. Do not read anything into the ordering
relative to fd 1 — `docker exec` demultiplexes the two.

**11.** `285`. The order matters because redirections are applied **left to right**: `2>&1` first
points fd 2 at wherever fd 1 currently goes — the pipe — and only then does `>/dev/null` move fd 1.
fd 2 keeps the pipe. Writing them the other way sends fd 2 to `/dev/null` along with fd 1.

**12.** `0`. `>/dev/null` moves fd 1 first, then `2>&1` aims fd 2 at the same `/dev/null`. Nothing
reaches `wc`, and `wc` counts an empty stream. This is the mistake that makes a loud tool look silent.

**13.** `18`, `303`, and 18 + 285 = 303. The arithmetic closes.

**14.** `scratch/report.txt` 18 lines, `scratch/err.txt` 285.

**15.** `summarise: clamp p-11 2186-05-01 value=1.100 -> 1.000 note=it` (the first line) — six space-separated fields
plus the leading `summarise:`; `value=` and `note=` are key=value. The last line is a total, not a
clamp.

**16.** `data/readings.txt` is 2354 lines (2352 readings plus two comment lines), 2186-05-01 through
2187-06-28 — fourteen months.

## What it was complaining about

**17.**
```
    181 p-03
    101 p-11
      2 p-07
```

**18.** p-03 and p-11 are exactly the two `notes/clamping.txt` names. **p-07 is not in that note** —
except in the sentence saying it should not clamp at all.

**19.** `grep -c 'p-07' scratch/err.txt` → `2`.

**20.**
```
summarise: clamp p-07 2187-05-13 value=1.184 -> 1.000 note=it
summarise: clamp p-07 2187-05-14 value=1.203 -> 1.000 note=months
```

**21.** p-07 runs between 0.198 and about 0.9 for the whole fourteen months. 1.184 and 1.203 are the
only two readings it has ever had above 1.000.

**22.** Adjacent days. `grep ' p-07 ' data/readings.txt | awk '$3 > 1.000'` returns those two lines
and nothing else; there is no p-07 clamp before 2187-05-13 and none after 2187-05-14.

**23.** A clamp on p-07 changes what the **door log** records for that day — so the two nights are not
only a panel anomaly, they are two days on which a different record was affected.

**24.** *Panel p-07 exceeded range on 2187-05-13 and 2187-05-14, twice, and on no other day in the
fourteen months of data.*

## The flag

**25.** Four distinct words, 71 occurrences each (284 clamps, cycled). The equal counts say the word
is a rotating label, not a classification of the clamp — it carries no information about which panel
or which day.

**26.**
```bash
bin/summarise 2>&1 >/dev/null | grep -o 'note=[a-z]*' | awk '!seen[$0]++'
note=it
note=complained
note=for
note=months
```
`sort` is wrong because it destroys the order that carries the meaning; `sort -u` would give
`complained for it months`.

**27.** The tool's. It has been saying it every night for fourteen months.

**28.** `kestrel flags submit 'KESTREL{it_complained_for_months}'`

**29.** `grep -r KESTREL .` returns nothing. `months` appears in the report's `months ...........  14`
line and in `notes/page.txt`; `complained`, `for` and `it` appear nowhere as note values. None of that
is the flag, because the flag is not text stored anywhere — it is produced at run time, on a channel,
and `grep` reads files. A stream that is never written to a file cannot be searched afterwards. That
is the lesson.

## Reporting

**30.** *The nightly log is standard output only. The summariser also writes one line to standard
error every time it clamps a reading, and there are 284 of them across the fourteen months in the
data — including two on a panel that is not supposed to clamp. `logs/` cannot contain any of that,
because the wrapper sends standard error to `/tmp`, which is recycled.*

**31.** 284 — and it is a count of **clamps in the data file the tool reads today**, not a count of
nights, not a count of incidents, and not a count of what was actually emitted on any particular
night. Say so; the honest number is smaller than the impressive one.

**32.** `bin/summarise > "$OUT" 2> "logs/summarise-$1.err"`. Cost: `wc -c` on the stderr stream is
18595 bytes for the whole fourteen months — under 19 KB total, so a fraction of a kilobyte a night.
There was never a storage argument for throwing it away.

**33.** For: one file, and nothing can be kept while the other is lost — the failure in front of you
is impossible. Against: it destroys the separation lesson 01 was about. The report becomes
unparseable by anything that expects a fixed 18-line shape, and a reader can no longer tell the
report from the commentary. Two files, both kept, is the answer.

**34.** *Panel p-07 reported 1.184 on 2187-05-13 and 1.203 on 2187-05-14. Both readings were clamped
to 1.000 by the summariser before the daily mean was computed.* Stop. The lab supports no third
sentence, and any agent that supplies a name is wrong.

**35.** `/tmp/summarise.err` for those two nights, which would have shown whether the clamps were
isolated or part of a burst, and what else the tool said around them. It went to a recycled path and
no longer exists.

## Experiment

**36.**
```bash
run() {
  bin/summarise > scratch/r.txt 2> scratch/e.txt
  local n; n=$(grep -c '^summarise: clamp' scratch/e.txt)
  echo "$n clamps"
  [ "$n" -eq 0 ]
}
```
The trap is lesson 05's `local n=$(…)`, which would swallow the status; and a wrapper that ends in
`echo` would exit 0 whatever it found. Both are the same mistake as `bin/checkbank`.

**37.** `grep '^summarise: clamp' scratch/e.txt | grep -vc ' p-03 \| p-11 '` → 2, so the wrapper exits
non-zero, which is the behaviour cass wanted fourteen months ago.

**38.**
```bash
bin/summarise 2> >(tee "scratch/$(date +%s).err" >/dev/null) | tee scratch/report.txt
```
or, without process substitution, two runs or a `tee` on each stream separately. Any answer that
keeps both and shows the report is right.

**39.** `rc=0`. The tool never checks whether its writes succeeded, so a full disk produces a
successful exit and an empty report. An exit status of 0 from a tool that does not check its own
writes means "I reached the end of my code", not "the output exists".

**40.** Yes — `tail -n +201` drops the first 200 warnings and the final summary line, which carries
stage 1's token, is still the last line. That is why stage 1 is safe to solve with `tail -1` even if
you are truncating the stream.

**41.** About 0.04s real either way; the pipe costs nothing measurable. Redirection is a couple of
`dup2` calls at start-up, not per-line work.

## Stretch

**42.** `logs/` stores one 18-line report per night. The per-clamp lines are not stored at all, on any
night. Five nights of reports and fourteen months of warnings are both true because they are counts
of different things: the reports were kept, the warnings were produced and discarded.

**43.** Add `  clamped .......... $clamped` immediately after the `readings` line, before the per-month
block — an existing reader that reads the header and then the month lines by pattern still works,
while one that assumes exactly 18 lines breaks. Say which kind of reader you are protecting.

**44.** A backup job whose per-file errors go to a pipe nobody reads while the "completed" line is
logged; a health probe whose diagnostic output is discarded and only its exit status recorded. In
both, the kept channel is the one that cannot express the problem.

**45.** The check is: run the tool deliberately with fd 2 preserved and look at it — a one-line
audit, done on purpose, per tool. It cannot be *noticed*, because from the wrapper's side both cases
produce exactly the same evidence: a report file and an exit status of 0. Nothing about the kept data
distinguishes them, which is the point of the whole chapter.

**46.** *"`2>/tmp/summarise.err` was a reasonable choice for a tool that had nothing to say on
standard error, and it was true when this was written. The tool acquired a diagnostic path later and
this line was never revisited. The fix is to write the error file next to the report."*

## Dig

**47.** Stage 1:
```
bin/summarise 2>&1 >/dev/null | tail -1
summarise: 284 readings clamped. STAGE{it_told_you_every_night}
```

**48.** Stage 2: `bin/summarise 2>&1 | wc -l` → `303`. `sed -n '303p' records/index-c.txt` gives
`STAGE{second_stage_you_counted_both}` and the instruction for stage 3. Counting one stream gives 18
or 285, both of which land on `STAGE{that_is_not_the_total}`.

**49.** Stage 3: `bin/decode <<< "the stream nobody kept"` →
`STAGE{third_stage_you_fed_it_on_stdin}`. A here-document (`bin/decode <<'EOF'` …) works too, and so
would `< file`; the point of the here-string is that no file and no second process is involved. A
pipe would also work, but the stage asked for the tool that does not need one.

**50.** Stage 4:
```
bin/verify p-07 && echo "confirmed"
STAGE{fourth_stage_two_nights_in_may}
confirmed
bin/verify p-03 >/dev/null 2>&1 && echo "confirmed"   # silent, and $? is 1
```

**51.** Stage 1 used the `2>&1 >/dev/null` split; stage 2 used combining both streams (`2>&1` /
`&>`); stage 3 used standard input, here-strings and here-documents; stage 4 used exit status with
`&&`. The Chapter 8 skill the chain never used is `tee` — every stage wanted one destination, and
`tee` exists to give a stream two. Adding it anywhere would have been an extra copy of something
already in front of you.
