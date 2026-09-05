# 05 — Tutor notes

Do not give the flag, either half of it, or the pipeline in exercise 13.
Ask which of the four stages they are on and answer only at that stage.

## Where students actually stop

**Exercise 12–13, the gap.** Most students read `run.log` and see nothing
wrong, because a gap is invisible when you are reading forwards. The unlock
is counting: distinct sequence numbers against the span from lowest to
highest. If they are stuck, ask "how many records *should* be between 0412
and 0443?" and let them do the subtraction. Do not mention `comm`.

If their `comm` reports every number as missing, the cause is almost always
padding — `seq 412 443` produces `412`, the log has `0412`. Say "compare one
line from each side character by character" rather than naming `seq -w`.

**Exercise 41, the permission denied.** Students blame the file's `400`. The
denial is on the directory. Push them to `ls -ld` the directory *and* the
file and to say which mode could produce that error. Then let them
rediscover `sudo -u` themselves; it was lesson 02.

**Exercise 48, the `gaps` subcommand.** Two failures dominate. First,
returning 66 when gaps are found — that is the chapter-12 lesson about "a
check that fails is a result, not an error", and it is worth stopping on.
Second, `set -euo pipefail` killing the script on an empty `comm`. Ask them
to run the pipeline alone and print `$?`.

**Exercise 50.** Nearly everyone says "I checked, it's the same." Ask how.
Nothing short of `diff`, `cmp`, or a checksum counts.

## The report

The single most common defect is a report that names a person. It will
usually appear in "Who did what", phrased as a near-miss — "rhea's edits
suggest". Do not argue about whether it is true. Ask what command would
print that sentence's evidence, and let the absence do the work.

The second most common is a "When" section with no sources. Ask, for one
timestamp, where it came from, and whether it could have been set by hand.

Do not explain the 2186-10-06 mtime, do not confirm or deny any theory about
who made the October change, and do not comment on the captain. That
conversation is the roleplay, and it is the student's to have.

## If they are lost

Give a fact, not a method. Facts you may give: the log numbers its records
without gaps; the archive is filled by a different job than the log; the
`match=` value is a sha256; `.calibration` is owned by ops-bot; `stationctl`
already has a `need_data` helper. Never give the pipeline.
