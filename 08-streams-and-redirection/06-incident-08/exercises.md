# 08/06 — Exercises: Incident, fourteen months of nominal

```
cd /labs/08-streams-and-redirection/06-incident-08
ls -F
```

Chapters 1–8 tools. Wrecked the lab? `kestrel reset 08/06`. Do not edit anything under `logs/` or
`data/`. Work in `scratch/`.

---

## Warmup — read before you run

**1.** `cat notes/page.txt`. cass makes one complaint and one request, and they are not the same
thing. Write both down in your own words.

**2.** Her last line is "I want to know whether the summary is the whole of what the tool says."
Before touching anything: name the two things a command can say, and which one a `.log` file usually
contains.

**3.** `ls -F` and `ls -l logs`. Five nights of reports. `wc -l logs/*.log` — all the same length.
What does a constant line count suggest, and what does it not prove?

**4.** `head -6 logs/summarise-2187-06-13.log` and `tail -3`. Describe the report's shape. Is there
anything in it that could carry bad news?

**5.** `grep -ci 'error\|warn\|fail\|clamp' logs/*.log`. All zero. Write one sentence about what a
clean grep over a log file establishes, and one about what it cannot.

**6.** `cat notes/wrapper.txt`. Copy out the redirection line by hand. Which fd goes where, and which
of the two destinations still exists?

**7.** `cat bin/nightly`. Same line. Does the file agree with the note?

**8.** `cat notes/clamping.txt`. Which panels clamp routinely, and which sentence in that file is the
one you will come back to at exercise 30?

## Running the tool

**9.** `bin/summarise | head -20`. Only the report appeared — or did it? Run it again with
`bin/summarise 2>/dev/null | wc -l` and note the number.

**10.** Now `bin/summarise >/dev/null`. Watch what happens. What is on your terminal, and which fd is
it on? (`docker exec` will not interleave the two reliably, so do not draw conclusions about order.)

**11.** `bin/summarise 2>&1 >/dev/null | wc -l`. Write the number down; it is the number that answers
cass. Then explain, in terms of lesson 02's ordering rule, why the redirections must be in that
order.

**12.** Write the same command with the redirections swapped — `bin/summarise >/dev/null 2>&1 | wc -l`
— run it, and explain the number you get. Which stream reached `wc`?

**13.** `bin/summarise 2>/dev/null | wc -l` and `bin/summarise 2>&1 | wc -l`. Three numbers now.
Confirm the arithmetic.

**14.** Save the discarded stream properly: `bin/summarise > scratch/report.txt 2> scratch/err.txt`.
`wc -l scratch/*`. This is the run the wrapper should have been doing for fourteen months.

**15.** `head -3 scratch/err.txt` and `tail -1`. Describe the format of a warning line: how many
fields, and which of them is a key=value.

**16.** How many nights of this exist? The tool reads `data/readings.txt`; `wc -l data/readings.txt`
and `head -3`. Over what span of dates?

## What it was complaining about

**17.** `cut -d' ' -f3 scratch/err.txt | sort | uniq -c | sort -rn` — the panels, by clamp count.
Which panels dominate?

**18.** Compare that list with `notes/clamping.txt`. Which of the clamping panels is expected, and
which entry in your list is not in that note?

**19.** How many times does the unexpected panel appear? Show the command and the number.

**20.** Print those lines. Give the two dates.

**21.** `grep 'p-07' data/readings.txt | head -40`. What is p-07's normal value range, and how far
outside it are the two clamped readings?

**22.** Are those two dates adjacent? Does p-07 clamp before them, or after them, ever again? Prove
both with one command each.

**23.** Now read the last paragraph of `notes/clamping.txt` again. What does a clamp on p-07 change,
beyond the panel summary?

**24.** State the finding as a fact about the data, with no interpretation: one sentence, two dates,
one panel.

## The flag

**25.** Every warning ends with `note=<word>`. `grep -o 'note=[a-z]*' scratch/err.txt | sort | uniq -c`.
How many distinct words, and what does the count of each tell you?

**26.** The order that matters is order of **first appearance**, not alphabetical and not by count.
Get it. `awk '!seen[$0]++'` is the shortest way; `sort` is the wrong tool here and you should be able
to say why.

**27.** Four words. Read them as a sentence. Whose sentence is it — cass's, the tool's, or yours?

**28.** Assemble and submit:
`kestrel flags submit 'KESTREL{...}'` — four words, underscores between them.

**29.** `grep -r KESTREL .` and then grep for each of the four words separately. Where does each one
appear, and why is that not the flag? Say precisely why `grep` could never have found this.

## Reporting

**30.** Write cass her answer in three sentences. It must say what the summary omits, how much of it
there is, and why `logs/` cannot contain it. Do not use the word "bug".

**31.** She will ask "so how long has this been happening?". Answer with a number and say exactly
what the number is a count of — not what you would like it to be.

**32.** Write the one-line change to `bin/nightly` that fixes this going forward, and say what it
costs in disk per night. Use `wc -c scratch/err.txt` for the estimate.

**33.** Someone will suggest sending the warnings to the report instead — `2>&1` into the same file.
Give one good argument for and one against, in the terms lesson 01 gave you.

**34.** Separately from cass's answer, write two sentences for the deck log about p-07 on
2187-05-13 and 2187-05-14. State what the readings were, what the clamp did, and stop. The evidence
does not support a third sentence, and you are not to write one.

**35.** What would you have needed, tonight, to know whether p-07's two clamps mattered? Name the
file that would have told you and say where it went.

## Experiment

**36.** In `scratch/`, write a wrapper that runs the summariser, keeps both streams separately, and
exits non-zero if there were any clamps at all. Lesson 05 has the trap; name it before you fall in.

**37.** Make your wrapper exit non-zero only for clamps on panels *other* than p-03 and p-11.

**38.** Now make it print the clean report to the terminal and copy both streams into dated files, in
one pipeline. `tee` is in lesson 04.

**39.** `bin/summarise > /dev/full 2>scratch/e2.txt; echo $?` — a disk that is always full. Does the
tool notice? What does that tell you about how much you can trust an exit status of 0 from a tool
that does not check its writes?

**40.** Run the summariser and drop the first 200 warnings: `2>&1 >/dev/null | tail -n +201`. Is the
last line still there? Why does that matter for the Dig?

**41.** Time it: `time bin/summarise >/dev/null 2>&1`. Now time it with the stderr going through a
pipe to `wc -l`. Is either meaningfully slower?

## Stretch

**42.** `logs/` has five nights and the tool has fourteen months of warnings. Explain why those two
facts are not in conflict — what exactly is stored per night, and what is not.

**43.** Rewrite `bin/summarise` in `scratch/` so that the clamp count appears in the *report*, on fd
1, without removing the per-clamp warnings from fd 2. Which line of the report did you add, and where
does it go so that an existing reader of the log does not break?

**44.** cass has fourteen months of reports and cannot reconstruct one clamp from them. Name two
other places on a station where the interesting stream is the discarded one.

**45.** A tool that has never had anything to say on standard error is indistinguishable, from the
wrapper's point of view, from a tool whose standard error is being thrown away. Design the check that
distinguishes them, and say why it has to be done deliberately rather than noticed.

**46.** The `/tmp/summarise.err` path was a reasonable choice in 2186 for a tool that was not expected
to complain. Write the sentence you would put in a review of that line today — fair to the person who
wrote it, and clear about what changed.

## Dig

Four receipts in the lab. Tokens are `STAGE{...}` and do not register.

**47.** Stage 1. `cat notes/dig.txt`. The token is on the last line of the tool's complaint. One
command.

**48.** Stage 2. Run the tool keeping **both** streams together and count every line it produced.
That number is a line number in `records/index-c.txt`. If you land on a line that says it is not the
total, you counted one stream.

**49.** Stage 3. `bin/decode` reads one line on standard input and accepts one phrase. Feed it with a
here-string — no pipe, no file — and note which of lesson 03's tools you used and why the others
would also have worked.

**50.** Stage 4. `bin/verify` takes one argument and answers with its exit status as well as its
output. Chain it so the token only appears on success, then run it against a wrong panel and show
that the chain stays quiet.

**51.** Name the four skills the four stages used, one each. Then name the Chapter 8 skill the chain
did not use, and say why it would have been the wrong tool at every stage.

---

## Dig — fixing the wrapper

**52.** `bin/nightly` has three separate faults in one line, and you have now met all of them.
Copy the wrapper into `scratch/` and work on the copy.

First, name them. The destination for fd 2 is a single fixed path — say what happens to last night's
warnings when tonight's run starts, and check it in `scratch/` with two `echo`s. Then say why that
path being under `/tmp` makes it worse than the same mistake made anywhere else. Third, the report
path carries the date and the error path does not: say what you can and cannot reconstruct from a
directory of files named that way.

Second, prove the failure mode nobody plans for. Make the error destination unwritable —
`mkdir scratch/ro; chmod 500 scratch/ro` — and run something that writes to both streams with its
fd 2 redirected into `scratch/ro/x.err`. Quote the message and the status, and answer the question
that matters: **did the command run at all?** Say what fourteen months of that would have produced in
`logs/`, and why nobody would have noticed.

Third, rewrite the line so that both streams are kept, per night, in a way that survives a reboot and
lets you match a report to its warnings. State whether you kept them in one file or two and defend
the choice against the other one — the argument about interleaving from exercise 11 is the one to
make. If you use `&>` or `&>>`, say what you would write instead in a script that must run under
`dash`.

*Done looks like:* three faults named with evidence, the unwritable-destination run quoted with its
status and the answer to "did it run", and the rewritten line with its defence.
