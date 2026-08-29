# 09/02 — Validation

For the AI tutor. Judgement only; no grading script, and there must not be one. Every value in this
lab moves — never check a number, check an interpretation.

## Passing this lesson

The student can:

1. **Read the header before the list.** Names all five lines and what each answers, without being
   walked through them.
2. **Interpret load correctly.** Says it is a queue length, not a percentage; divides by `nproc`
   before judging; reads 1/5/15 as a trend. Rejects "load 4 is bad" as unanswerable without the CPU
   count.
3. **Separate rate from total.** Explains `%CPU` versus `TIME+` and can describe the process that is
   quiet now and has been expensive for months. This is the load-bearing objective of the lesson;
   the incident is unfindable without it.
4. **Sort deliberately.** Uses `P`, `M`, `T` for different questions rather than reading the default
   view harder.
5. **Read memory honestly.** Says small `free` is normal, quotes `avail Mem`, uses `RES` over `%MEM`
   *and knows why on this station specifically*.
6. **Know which numbers are the container's.** States that the process list is ours and the load,
   memory and CPU summary are the host's. A student who reports the host's 31 GB as the station's
   memory has missed something the rest of the chapter depends on.
7. **Use batch mode properly.** `top -b -n 1` with `-w`, and knows it exits 0 on no match, so `ps`
   goes in scripts.
8. **Know `top`'s blind spots.** Long refresh misses short processes; the first iteration's `%CPU` is
   a lifetime average; watching and seeing nothing is not evidence.

## Signals the student is not there yet

- Treating the load average as a percentage, or as a verdict without the CPU count.
- Reporting the host's memory total as the station's.
- Alarm at small `free`.
- Only ever using the default sort. Ask: "what would a process that is not busy but has been running
  since last October look like in this view?" That question is the lesson.
- Parsing `top -b` output by column number in a script when `ps -eo` would give the same data
  cleanly.
- Using `top -b -n 1 -p PID` as a liveness test. It exits 0 either way; measured.
- Quoting a `top` number in a report with no timestamp.

## Roleplay and tutoring notes

- rhea's page contains two questions she has been given contradictory answers to. She is not being
  slow; both answers she was given are commonly repeated and one of them is wrong. Do not mock the
  question.
- Do not tell the student what is running on this station. They will find it in 09/06–09/07, and
  finding it early by being told costs them the chapter.
- If a student sorts by `TIME+` here and notices something, let them notice. Do not confirm, do not
  expand, and do not steer them away either. Ask what they would check next.
- Never hand over the interactive key. Ask what they want to sort by and let `h` tell them.

## Not required here

Signals, `kill` semantics beyond "k killed it and the children survived", `/proc`, `nice`/`renice`
beyond noticing the `NI` column exists. All later in the chapter.

## Flag

None in this lesson.
