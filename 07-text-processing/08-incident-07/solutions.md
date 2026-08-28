# 07/08 — Solutions: the tail of the report

**Flag: `KESTREL{eng_svc_logged_in_once}`**

Every number below was measured in the container.

## Warmup (1–8)

**1.** One ranked table, by account, for the quarter, with counts, readable, today. Not the log.

**2.** **AC-3** is the report. **AC-9** is the finding, and an AC-9 is the flag.

**3.** One row per account; account, count and share to one decimal; ordered by count descending; a
header row **and** the period stated on the report itself.

**4.** "Rank the report, read the top three, move on. It has never been wrong."

**5.** Three files, named `access-2187-01.log` through `-03`. January to March 2187 — the filenames
say so, which is why logs are named that way.

**6.**
```
$ wc -l logs/*.log
  861 logs/access-2187-01.log
  786 logs/access-2187-02.log
  788 logs/access-2187-03.log
 2435 total
```
The `total` line is `wc`'s own summary, not a file. `wc -l logs/*.log | tail -1` will bite you.

**7.** date, time, account, action, deck.

**8.** `grep -vc '^2187' logs/*.log` prints `0` for all three: no comments, no blanks, no trailer.
These logs are clean, unlike lesson 07's dump. Proving it costs one command; assuming it costs a
wrong count.

## The report (9–20)

**9.** `awk '{print $3}' logs/*.log | head -3` → `bex`, `cass`, `maintenance` — the logs are sorted
by time and the first second of the quarter has several accounts in it.

**10.** `awk '{print $3}' logs/*.log | sort | uniq -c | sort -rn` → **8 rows**.

**11.** `awk '{print $3}' logs/*.log | sort -u | wc -l` → `8`. Matches.

**12.** Sum the count column: `… | awk '{s += $1} END {print s}'` → `2435`. Matches exercise 6.

**13.–17.**
```
$ { printf 'ACCESS SUMMARY (form AC-3)\n'
    awk 'NR==1 {first = $1} {last = $1} END {printf "period: %s to %s\n", first, last}' logs/*.log
    printf '%-12s %6s %6s\n' ACCOUNT COUNT SHARE
    awk '{c[$3]++; t++} END {for (k in c) printf "%-12s %6d %5.1f%%\n", k, c[k], 100*c[k]/t}' logs/*.log |
      sort -k2,2rn ; }
ACCESS SUMMARY (form AC-3)
period: 2187-01-01 to 2187-03-31
ACCOUNT       COUNT  SHARE
ops-bot        1800  73.9%
rhea            300  12.3%
cass            180   7.4%
vint             90   3.7%
orla             40   1.6%
bex              18   0.7%
maintenance       6   0.2%
eng-svc           1   0.0%
```
The period comes from the data — the logs are sorted, so the first line of the first file and the
last line of the last file bracket the quarter. Typing "January to March" from the filenames is a
guess that happens to be right; computing it stays right when a file is missing.

**18.** Append `| tee reports/access-q1.txt` to the closing `}`.

**19.–20.** Eight rows. Read all eight. If you read three, you did what the handover told you to and
you have not finished the exercise.

## Reading the whole report (21–30)

**21.** `ops-bot` is 73.9%. Top three (`ops-bot`, `rhea`, `cass`) are 2280 of 2435 = **93.6%**.

**22.** It is uninteresting for a reason you can measure: 1800 events over 90 days is 20 a day, every
day, and the per-month counts are 640 / 580 / 580 — flat. A poller that polls is not news. That is an
argument from the data. The handover note is an argument from habit, and the two happen to agree
today about `ops-bot` and disagree about everything below row three.

**23.** `eng-svc          1   0.0%`. Count of **one**.

**24.** Not an account anyone on this watch can name, and one event in ninety days is not a rate — it
is an occurrence. Every other account in the table has a rhythm. This one has a moment.

**25.**
```
$ grep -h ' maintenance ' logs/*.log
2187-01-01 00:00:00 maintenance read deck-01
2187-01-14 00:04:41 maintenance write deck-01
2187-02-01 01:00:07 maintenance read deck-01
2187-02-14 01:04:48 maintenance write deck-01
2187-03-01 02:00:11 maintenance read deck-01
2187-03-14 02:04:52 maintenance write deck-01
```
Two per month, on the 1st and the 14th, always deck-01, read then write. Six is a schedule. It is
explainable, and checking it is what makes the next row's unexplainability mean something.

**26.**
```
$ grep -h eng-svc logs/*.log
2187-01-18 04:14:22 eng-svc login deck-02
```
**One line.** In three months.

**27.** 2187-01-18, 04:14:22, action `login`, deck-02.

**28.**
```
$ grep -c eng-svc logs/*.log
logs/access-2187-01.log:1
logs/access-2187-02.log:0
logs/access-2187-03.log:0
```
With more than one file, `grep -c` prints a count **per file**, prefixed with the filename — it does
not total them. The two zeros are as informative as the one: the account did not come back.

**29.** `awk '{print $3}' logs/*.log | sort | uniq -c | sort -n | head -1` — rank ascending and take
the rarest. Or compare against the account snapshot directly (exercise 37).

**30.** Honestly: neither, most days. Nobody runs `sort -n | head -1` on a log unless they already
suspect something, and the report you built yourself is the one you skim. Which is exactly why the
finding was allowed to sit in a file for months. The fix is not cleverness, it is a habit: **read the
last row of every table you produce.**

## Corroboration (31–40)

**31.** `records/accounts-2187-01.txt` taken 2187-01-31; `records/accounts-2187-06.txt` taken
2187-06-30.

**32.** Seven each: `ops-bot`, `rhea`, `cass`, `vint`, `orla`, `bex`, `maintenance`.

**33.** No. `grep -c eng-svc records/accounts-2187-01.txt` → `0`.

**34.** No. Also `0`. The January snapshot was taken thirteen days after the login and does not have
it; the June snapshot, five months later, does not have it either.

**35.** `awk '{print $3}' logs/*.log | sort -u > scratch/log-accounts.txt` — eight lines.

**36.** `awk -F: '/^[a-z]/ {print $1}' records/accounts-2187-01.txt | sort > scratch/snap-accounts.txt`
— seven lines. The `/^[a-z]/` guard drops the two `#` comment lines; without it you get two junk rows
and the comparison in the next exercise produces noise.

**37.**
```
$ comm -23 scratch/log-accounts.txt scratch/snap-accounts.txt
eng-svc
```
(`comm` needs both inputs sorted, which is why exercise 35 and 36 both sort.) `grep -vxFf` does the
same job with chapter 6 tools.

**38.** *An account named `eng-svc` logged in once, at 04:14:22 on 2187-01-18, from deck-02, and does
not appear in the station account snapshots taken thirteen days later or five months later.*
Everything in that sentence is a thing a file says.

**39.** Who created it, who used it, what it did while logged in, why it never returned, and whether
it still exists. None of that is in this lab, and an answer to any of it would be invention.

**40.** No. Nothing in `logs/`, `records/` or `notes/` names a person in connection with it. The
session record in `records/console-d.txt` gives a seat and a terminal, not a person. If you found
yourself about to write a name, that name came from you, not from the evidence.

## The red herring (41–45)

**41.**
```
$ awk '$4 == "login" {print $3}' logs/*.log | sort | uniq -c | sort -rn
    360 ops-bot
     58 rhea
     34 cass
     17 vint
      6 orla
      3 bex
      1 eng-svc
```
`ops-bot` again, by six to one.

**42.** Slightly easier — the table is shorter and `maintenance` drops out, so the interesting row is
one from the bottom instead of two. But not much: `ops-bot` still dominates and the eye still stops at
the top. Filtering to the event you care about does not fix the habit of not reading down.

**43.** `grep login logs/*.log | wc -l` → `479`, one number, the total. `grep -c login logs/*.log` →
three lines, `filename:count`, one per file. The first answers "how many logins in the quarter"; the
second answers "how were they distributed across the files". They are different questions and the
second is the one that told you `eng-svc` never came back.

**44.** No. Decks run 638 / 615 / 594 / 588 and actions run 983 / 491 / 482 / 479 — both flat, both
boring, neither has a tail. The finding is only visible in the account dimension because it is a fact
about an account.

**45.** The advice optimised for the common case and the common case is 93.6% of the file; today's
finding was in the 0.04% that no rule of thumb built on volume will ever reach.

## The finding (46–50)

**46.** f1 account (dashes as underscores), f2 event (from the vocabulary table), f3 frequency word
(from the frequency table).

**47.** `eng-svc` → `eng_svc`.

**48.** The action was `login`; the vocabulary table gives `login -> logged_in`.

**49.** The count was 1; the frequency table gives `1 -> once`.

**50.** `eng_svc` + `logged_in` + `once`:

```
$ kestrel flags submit 07/08 'KESTREL{eng_svc_logged_in_once}'
```

The string appears in no file in the lab. It is one part identifier, one part table lookup, one part
a number you had to compute correctly — get the count wrong and you submit `twice` and it fails
loudly, which is the intended feedback.

## Reporting (51–55)

**51.** Fair objections: the share column's `%` is glued to a right-aligned number so it jitters; the
period line is buried under the title instead of beside it; `0.0%` is printed for a row that is not
zero; nothing marks which rows are automation and which are people; and the widest column is the one
carrying the least information. Any three of those.

**52.** Widen the account column to the longest name plus two, put the `%` in the header instead of
on every row, and drop to `%5.2f` only where it changes meaning. The mechanics are lesson 05's
`printf`; the judgement is yours.

**53.** Both, and they are different documents. The AC-3 is a periodic report that must look the same
every quarter so that changes are visible; burying a finding in it means next quarter's reader has to
re-derive it. The AC-9 is the thing that gets acted on. Cross-reference them.

**54.** Something like: *"Access is normal and dominated by ops-bot as usual, with one exception: an
account called `eng-svc`, which is in no account snapshot, logged in once on 2187-01-18 and never
again."* One sentence, the boring part first so the exception lands last.

**55.** `0.0%` is arithmetically right and editorially wrong: it reads as "nothing" for the one row
that is not nothing. Print the count without a share, or print `<0.1%`, or drop the share column for
rows below a threshold and say so in the header. The row should read as *rare*, not as *zero*.

## Experiment (56–60)

**56.** `sort -k2,2n` puts `eng-svc` first. The argument for ascending as the incident default: a
ranked-descending report answers "what is our load", which you already know, while ascending answers
"what is unusual", which is the question you opened the log for. The argument against is that
everyone expects descending and a report nobody reads correctly is worse than one that buries the
answer.

**57.**
```
$ awk '{ if (!(f[$3])) f[$3] = $1 " " $2; l[$3] = $1 " " $2; c[$3]++ }
       END { for (k in c) printf "%-12s %5d  %s  %s\n", k, c[k], f[k], l[k] }' logs/*.log |
  sort -k2,2rn
```
```
ops-bot       1800  2187-01-01 00:00:00  2187-03-31 23:02:28
...
maintenance      6  2187-01-01 00:00:00  2187-03-14 02:04:52
eng-svc          1  2187-01-18 04:14:22  2187-01-18 04:14:22
```
Every other account's first and last appearance are months apart. `eng-svc`'s are the same instant,
to the second. A span of zero in a ninety-day window is a shape no legitimate account has. (The
identical `2187-01-01 00:00:00` in every other row is an artefact of how this lab's logs were
generated, not a fact about the station — worth noticing, and worth not building an argument on.)

**58.** Per account per month, using a composite key as in lesson 06:
```
$ awk '{ split($1, d, "-"); c[$3 " " d[2]]++; t[$3]++ }
       END { for (k in t) printf "%-12s %5d %5d %5d %6d\n",
                          k, c[k " 01"], c[k " 02"], c[k " 03"], t[k] }' logs/*.log |
  sort -k5,5rn
```
Seven accounts appear in all three months. `eng-svc` appears in one, with zeros either side — and the
zeros are printed rather than missing, which is the lesson-06 point about a zero beating a gap.

**59.** Two events in different months would have moved it above `maintenance`'s six? No — it would
still be last but one, and the frequency word would be `twice`. You would probably have noticed
**later**, not sooner: two occurrences look like a pattern, and a pattern looks like something with a
reason, so the eye files it as explained. A single event is the one that cannot be rationalised.

**60.** Best answer: require the report to state the number of accounts appearing fewer than N times
in the period, as a line of its own. It costs one line, it is computable from the same table, and it
makes "somebody was here once" a first-class fact instead of a row you have to scroll to. The
objection — longer reports — is answered by the fact that it is one line, and that a report nobody
reads to the bottom is already too long.

## Stretch (61–64)

**61.** One `awk` program can hold the header, the period, the counts and the shares, emitting the
rows in `END` and piping only into `sort`. It is faster and it is one file to change. It is also
harder for a colleague to modify without understanding all of it, where a pipeline can be edited one
stage at a time. File the `awk` if the report runs every quarter; keep the pipeline if it is going to
be argued about.

**62.** `sort -k1,1` gives the same eight rows alphabetically. File the alphabetical one — it diffs
cleanly against next quarter, because the rows do not move when counts change. Send the ranked one,
because the reader wants an order, not a diff.

**63.** `awk '{...}' logs/*.log` opens each file once and streams it once; the counting all happens in
memory in a single pass. You can see it: `FNR` restarts at 1 three times while `NR` runs to 2435. A
version that ran `grep -c <account> logs/*.log` in a loop over eight accounts would open the files
twenty-four times, and would still be correct — which is why "it works" is not the same as "it is one
pass".

**64.** For: 74% of the lines carry no information about people, dropping them makes every subsequent
stage faster to run and to read, and it makes the tail of the table visible on one screen. Against:
the filter encodes an assumption — that `ops-bot` is always noise — into the tool, so the day
`ops-bot` is the story, the pipeline is silent about it, and nobody will remember the filter is
there. Filter in the report, not in the pipeline; or filter and say so on the report.

## Dig — the four stages

**Stage 1** (`sort`, `uniq -c` — lesson 01):
```
$ grep -v '^#' records/tally.txt | sort | uniq -c | sort -rn
      8 console-a
      5 console-b
      3 console-c
      1 console-d
```
`console-d`, once, at the bottom — the chain's shape is the incident's shape. Open
`records/console-d.txt`:
`STAGE{tally_read_to_the_end}`

**Stage 2** (`awk` fields — lesson 05). The session table lists five accounts; four are in the
snapshots and one is not:
```
$ awk 'NR == FNR { if ($0 ~ /^[a-z]/) { split($0, a, ":"); known[a[1]] = 1 } ; next }
       /^s-/ && !($2 in known) { print $2 }' records/accounts-2187-01.txt records/console-d.txt
eng-svc
```
Field 2 of that row is `eng-svc`, so the next file is `records/eng-svc.txt`:
`STAGE{account_named_by_a_field}`

**Stage 3** (`cut`, `paste` — lesson 02):
```
$ cut -d: -f3 records/left.txt  > scratch/l.txt
$ cut -d: -f1 records/right.txt > scratch/r.txt
$ paste -d: scratch/l.txt scratch/r.txt
bapr:pbhagf
gjvpr:vtaberq
ercrngrqyl:ybttrq
ebhgvaryl:cbyyrq
```
The line number is the count from exercise 26: **1**. So `bapr:pbhagf`.

**Stage 4** (`tr`, `sed` — lesson 03 and 04). `records/cipher.txt` says rot13:
```
$ paste -d: scratch/l.txt scratch/r.txt | sed -n 1p | tr 'A-Za-z' 'N-ZA-Mn-za-m' | sed 's/:/_/'
once_counts
```
`STAGE{once_counts}`

**69.** The four skills: `sort`/`uniq -c` ranking (01), `awk` field selection with a condition (05),
`cut`/`paste` column surgery (02), `tr`/`sed` transformation (03/04). The chapter skill the chain
never used is `tee`/`xargs` (06) — every stage is a single transformation of a stream into a shorter
stream, and neither saving a copy nor turning a stream into command arguments would have moved any
stage forward.

**70.** Because the whole incident is a count of one that was true and was not read. `once_counts` is
both halves: the occurrence happened exactly once, and once is a count that counts.

## Authoring notes

- Verified before shipping: the literal flag string does not appear anywhere in the lab tree
  (`grep -ric kestrel .` returns zero on every file), and no `KESTREL{...}` decoy is planted. The
  only bracketed tokens in `records/` are `STAGE{...}`, which do not register.
- `ops-bot` is 1800 of 2435 (73.9%) and the top three are 93.6%. Those shares were measured, not
  designed backwards from a target — the per-account counts were chosen first and the shares fell
  out.
- `grep -c eng-svc logs/*.log` printing three prefixed counts rather than a total is the behaviour
  exercise 28 is built on; it was confirmed in the container rather than remembered.
- `maintenance`'s six events are a real schedule (1st and 14th of each month, deck-01, read then
  write) so that exercise 25 can be *answered*, not just noticed. A tail row that is explainable is
  what makes the next tail row's unexplainability evidence.
- The chain deliberately re-uses the incident's own count (1) as the line number in stage 3, so a
  student who miscounted `eng-svc` fails stage 3 loudly instead of submitting a wrong flag.
- Nothing in the lab names a person in connection with `eng-svc`. Exercise 40 exists to make a
  student check that before they write a name down.
