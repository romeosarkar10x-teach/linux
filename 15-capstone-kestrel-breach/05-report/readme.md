# 05 — The report

You have the facts. This lesson is about what you do with them.

An incident report is not a story and it is not an accusation. It is a
document that a person who was not there can read in five minutes and act on.
It has five beats, and they go in this order:

1. **What happened.** One paragraph. The mechanism, not the drama.
2. **When.** Timestamps, oldest first, with their source named.
3. **Who did what.** Accounts and actions. An account is not a person, and
   you say so where you cannot close that gap.
4. **What you changed.** Every remediation from lesson 04, and anything you
   deliberately left alone.
5. **What would have caught this in October.** The control that was missing.

## Say what you can support

Every sentence in a report is one of three things: something you measured,
something you inferred, or something you are guessing. Only the first two
belong in the report, and the second kind has to be labelled.

"`deck3-report.txt` reports a peak of 6.0; the raw sample's peak is 7.3"
is measured. "The figures in the report match the clamped output and not the
raw data" is measured too — it is arithmetic on things you can print.

"The ceiling was applied before the report was generated" is an inference,
and a sound one, because the numbers cannot be produced in the other order.
Write it as an inference.

"Someone wanted the figures to look lower" is a guess about a state of mind.
It does not go in the report. Not because it is impossible, but because
nothing in the filesystem can support or refute it, and a report that mixes
the two kinds teaches its reader to trust neither.

The same rule kills the sentence you most want to write: the one with a name
in it. You have accounts, and you have login records that put an account and
a session together. That is as far as the evidence reaches. Where a report
needs to go further, it says what would be needed to get there — a shift
rota, an interview, a badge log — and stops.

## Timestamps have sources

A timestamp in a report is worthless without the thing it came from. Two
kinds appear in this case and they are not equally strong:

- **Filesystem mtimes** were all set by whoever wrote the files, and can be
  set to anything by anyone who can write the file. They cluster honestly
  when nobody has tampered with them, and you have seen a whole tree where
  they were plainly set deliberately.
- **Append-only logs** — the summariser's `run.log`, `last`'s records — are
  written by a program, one line at a time, and are harder to edit
  convincingly. Their strength is that they have *shape*: a run log that
  numbers its records without gaps will show you a gap.

When the two disagree, say so in the report rather than picking one.

## Gaps are evidence

`run.log` numbers each nightly record. If the numbers run 0412, 0413, …,
0431, 0438, …, then six records were produced and did not reach this file.
That is a positive finding, not a hole in your work. You can state it
exactly:

```
$ cut -d' ' -f1 run.log | sort -u | wc -l
```

and you can name the missing range without guessing at it. What produced the
gap is a separate question, and the archive answers part of it.

## Extending a tool instead of writing a script

In chapter 12 you shipped `stationctl` — a script with a shebang, an
executable bit, a `--help`, a data directory it reads from the environment,
and an exit-code contract:

```
0   ok
1   check failed -- a result, not an error
64  usage error
66  data missing
```

There is a copy of it at `bin/stationctl` in this lab. This lesson's last
task is to add a subcommand to it, and the reason it is the last task is
that adding to a tool is a different discipline from writing one. You must:

- keep the existing exit codes meaning what they meant;
- add your command to `usage()`, because a command absent from `--help`
  does not exist;
- use `need_data` rather than inventing a second way to fail on missing
  files;
- leave every other subcommand's output byte-for-byte unchanged.

That last one is what separates a tool from a script. Someone else's
pipeline is reading `stationctl faults`. If your change alters its output,
you have broken a caller you cannot see.

## The chain

There is a four-stage chain in this lab, and it is the case in miniature: an
incomplete handover, a gap in a log, a hash that points at exactly one file,
and a tool you have to extend to finish. Each stage tells you plainly when
you have got it wrong. The final answer is not written down anywhere in the
lab — you assemble it from two words in two places, and you already know the
format.

## What this lesson does not tell you

The report has a section for who did what. When you have written it, you
will notice that it stops short of the thing everybody actually wants to
know. That is correct. Nothing in this course will tell you what to conclude
about it, and the last thing you do in this chapter is talk to the captain,
who will not tell you either.
