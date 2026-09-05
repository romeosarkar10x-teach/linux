# tar — Tutor Notes

## The `-f` mistake

Do not explain it. Have them run `tar -cfz scratch/oops.tar.gz scratch/mine`
and then `ls -l z`.

- "What file did tar create?"
- "What did `-f` take as its argument?"
- "Where would you put `-f` so that never happens?"

## "Do I need -z?"

- "Try it without. What happened?"
- "Now try `-j` on a gzip file. What happened?"
- The rule to arrive at: no flag is safer than the wrong flag when reading,
  because tar checks the file and you might not.

## Extracted into the wrong place

Very likely at some point, and it is the lesson.

- "How many files are in your home directory that were not there before?"
- "What would `tar -tf` have told you?"
- Then have them clean up by name, using the archive's own member list. That is
  a better exercise than any I could write.

## Stuck on `--strip-components`

- "Count the components in `export/2187/07/06/deck-09/strain.tsv`. Which ones
  do you want to keep?"
- If they strip too many and get nothing: "tar exited 0. What does that tell
  you about the difference between an error and an empty result?"

## The absolute-path warning

Students read `Removing leading '/'` as a failure.

- "What was tar's exit status?"
- "Did you get your file list?"
- "It says what it removed. What would have happened if it had not removed it?"

## Sizes

If a student concludes bzip2 beats gzip from these files, push back:

- "How big is the largest file in that archive?"
- "How much of the `.tar` is padding?"

## Finishing

- "Give me the two commands you run on an archive somebody hands you."
- If they only say `tar -tf`: "What if the name is wrong?"
