# 07/08 — Incident: the tail of the report

> "The captain wants the access log as a ranked report by account. Top talkers, counts, readable.
> By the end of the shift."

## The page

`notes/page.txt`, 08:05:

> **From:** the captain
> **Subject:** access numbers
>
> I want the access log as a ranked report by account for the quarter. Top talkers, counts,
> readable. By the end of the shift.
>
> Do not send me the log.

That is the whole brief. It is not a trick and it is not vague on purpose — it is what a request from
a busy person actually looks like. "Readable" is doing a lot of work in that sentence and she will
not define it for you until you show her something.

## What this lesson is

Every command in chapter 7, against three months of access log, to produce one table. The table is
the assignment. **The finding is in the table**, and it is not at the top.

`notes/handover.txt` will tell you, in writing, from three watches' worth of accumulated experience,
to rank the report, read the top three and move on. That advice is correct about the top three. It
has never been wrong before. It is wrong today.

## The shape of it

```
$ cd /labs/07-text-processing/08-incident-07
$ ls -F
logs/  notes/  records/  reports/  scratch/
```

- `logs/` — `access-2187-01.log`, `-02`, `-03`. One event per line, same five fields as the whole
  chapter: date, time, account, action, deck.
- `notes/page.txt` — the captain's request.
- `notes/handover.txt` — the night watch's standing advice. Read it. Then decide what to do with it.
- `notes/forms.txt` — two station forms. **AC-3** is the report she asked for. **AC-9** is the
  finding, and an AC-9 is what you submit as the flag.
- `records/` — account snapshots, and the four stages of the Dig.
- `reports/` — where your report goes.
- `scratch/` — yours.

## The method

1. **Build the report she asked for.** One row per account, count, share of the total, ranked, with a
   header and the period it covers. Form AC-3 in `notes/forms.txt` spells out the columns. Build it
   the lesson-07 way: one stage at a time, checking counts.
2. **Read all of it.** Every row. The top three account for 93% of the file and they are all boring.
3. **Ask of the last row the same question you asked of the first.** Who is this, and is that number
   normal?
4. **Check the account against `records/`.** There are two account snapshots, five months apart.
5. **Fill in form AC-9** from what you counted and what the vocabulary table says.

## The thing that makes it hard

`ops-bot` is 1800 of 2435 events. Anything you sort by count puts it first, and it is first by a
factor of six. Every instinct you have built in this chapter — rank it, look at the top — is exactly
the instinct that hides this. The whole quarter's finding is a row with a count of **one**, at the
bottom, below an account that logged twice.

A report you built yourself is the report you are least likely to read.

## Rules

- No `sudo`. Nothing outside the lab directory.
- Nothing in `logs/` is modified. If you need to change something, copy it to `scratch/`.
- The flag is **not in any file**. It is assembled from a count you compute and a table you read.
  `grep -r KESTREL .` returns nothing, and that is not a bug.
- `records/` holds a four-stage chain with `STAGE{...}` tokens. Those do **not** register with
  `kestrel flags` and are not the answer. They are practice.

## Submitting

```
$ kestrel flags submit 07/08 'KESTREL{...}'
```

One finding, form AC-9, three fields, lowercase, joined with underscores.
