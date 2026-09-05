# Exercises — Incident 13

Work in `/labs/14-archives-disks-integrity/05-incident-13`.
**Do not modify anything in `export/`.** Use `scratch/`.

## A. Establish the baseline

1. `sha256sum export/strain-archive-2187-06.tar.gz`. Write the first eight
    characters somewhere you will still have them in an hour.
2. `cd export && sha256sum -c SHA256SUMS`. Does it pass? What is the exit
   status?
3. Run the same `-c` from the lab root instead of from `export/`. What happens,
   and why?
4. What exactly did that check prove? Answer in one sentence, using lesson 04's
   wording.
5. `bin/manifest-audit` with no arguments. What are the three commands and the
   four non-zero exit codes?
6. `bin/manifest-audit verify`. What does it print?
7. Record the first `STAGE{...}` token. Try submitting it with
   `kestrel flags submit`. What happens, and what does that tell you about
   stage tokens?
8. What would `verify` do if you had recompressed the archive? Do not do it —
   read the tool's source and say which exit code you would get.

## B. Look without touching

9. `tar -tzf export/strain-archive-2187-06.tar.gz | head`. How many members,
   and what is the top-level directory?
10. `tar -tvzf` the same. What are the owner and mtime on the members, and what
    does that tell you about how the archive was built?
11. Does listing the archive change it? Re-run exercise 1's `sha256sum` and
    say.
12. `zcat export/console-note.txt.gz`. What error do you get, exactly?
13. `file export/console-note.txt.gz`. What is the file actually?
14. Read it with the right tool. What does it say?
15. Is that a finding? Write one sentence for the report, or say why it does
    not belong there.
16. `cat export/MANIFEST.txt | head -5`. What are the three columns, and what
    does the header say the expected sample interval is?
17. 144 samples a day at that interval — check the arithmetic. Does it work
    out?

## C. The audit

18. `bin/manifest-audit shortfall scratch`. What exit code, and what does the
    message tell you to do?
19. Extract the archive into `scratch/`. Write the command. Which lesson-01
    flag were you careful about, and why does it matter here?
20. Re-run exercise 1's `sha256sum` on the archive. Unchanged?
21. `bin/manifest-audit shortfall scratch/<yourdir>`. How many day files, how
    many short, and what is the second `STAGE{...}`?
22. Now do it yourself without the tool: for each of the twenty files, compare
    `wc -l` against the manifest's count column. Write the loop.
23. Which days are short, and how many lines does each have?
24. `144 - 97`. How many samples are missing per short day, and how many hours
    is that at the stated interval?
25. Do the short files stop early, or are they missing samples from the middle?
    Show how you checked.
26. Now compare the manifest's *hash* column against the extracted files. Which
    file's hash does not match?
27. Do the five short days' hashes match the manifest?
28. Sit with 26 and 27 for a moment. The manifest's hashes agree with the files
    that were delivered, including the short ones. What does that tell you
    about *when* the hash column was written relative to the line-count column?
29. Look closely at the manifest's hash for `strain-2187-06-13.log` next to the
    real one. What is the difference, character by character?
30. Is `strain-2187-06-13.log` short? Is it damaged in any way you can detect?
31. So: was throwing out the whole manifest on the strength of line 16 the
    right call? Write the sentence you would say to someone who did.
32. `bin/manifest-audit shortfall export`. What happens, and why does the tool
    refuse?

## D. The correlation

33. `cat readings/deck-04-daily-max.csv`. What are the columns, and where did
    this file come from relative to the export?
34. What is the clamp threshold?
35. Which days have a maximum at or above the threshold? List them.
36. Compare that list with your answer to 23. State the relationship in one
    sentence.
37. How many days are in the month's export, how many are short, and how many
    are at or above the threshold? Are those last two the same set, or does one
    contain the other?
38. What is the probability of five specific days out of twenty coinciding by
    chance? You do not need the exact number — say whether it is the kind of
    number you would build a conclusion on.
39. Does the archive itself contain the strain readings that exceeded the
    threshold on those days? Check one short day directly.
40. So what happened to those samples — were they recorded and removed, or
    never written? Say which of those two your evidence supports, and which it
    does not.
41. Write your attestation into `scratch/`: the five dates and the threshold.
42. `bin/manifest-audit attest scratch/<file>`. What is the flag?
43. Submit it with `kestrel flags submit`.
44. Deliberately break it: attest four of the five dates. What exit code, and
    what is the message?
45. Attest the five dates with no threshold. What exit code?

## E. Close it out

46. Re-run exercise 1's `sha256sum` one final time, and `cd export &&
    sha256sum -c SHA256SUMS`. State the two results.
47. Why is that final check the most important command in this lesson?
48. Delete your extracted copy from `scratch/`. Confirm `export/` is untouched.
49. `ops-bot`'s page says "verified against SHA256SUMS. Result: pass. No
    further checks configured." Which part of that is false?
50. Write the report. Facts only, no names. Include: what you verified, what
    the manifest said, what the archive contained, what the readings file
    showed, and what you did not establish.
51. Your report will be read by someone who wants to sign the export off today.
    What is the one sentence at the top?
52. Someone asks whether the export was tampered with. Answer precisely.
53. Someone asks who did it. Answer precisely.
54. What is the *next* thing you would ask for, and who would you ask? (Name a
    record, not a person.)
55. If the export had shipped without `MANIFEST.txt`, would anything in this
    lesson have been findable? Which artefact was actually load-bearing?
56. Write the runbook line: "before signing off an export, ..."
