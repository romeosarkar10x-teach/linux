# Exercises — Checksums

Work in `/labs/14-archives-disks-integrity/04-checksums`. Do not modify
anything in `dist/` or `copies/`; use `scratch/` for anything you create.

## A. Computing

1. `sha256sum dist/strain-2187-04.log`. How many hex characters is the hash,
   and how many bits is that?
2. `md5sum` the same file. How many hex characters now?
3. Run `sha256sum` on the same file twice. Same answer? Should it be?
4. Copy it to `scratch/`, then hash the copy. Same or different, and why?
5. `sha256sum dist/handover.txt dist/handover-copy.txt`. Compare the two
   hashes.
6. `cmp` the same two files. Does `cmp` agree with the hashes?
7. Two files with the same hash and different names. What does the hash tell
   you about the *name*?
8. `sha256sum copies/full.log copies/truncated.log`. How many characters of
   the two hashes are the same?
9. `ls -l copies/full.log copies/truncated.log`. How many bytes differ between
   the files, and how much of the hash changed as a result?
10. Take a copy of `dist/calibration.csv` into `scratch/`, change exactly one
    character with `sed`, and hash both. State what fraction of the hash you
    would have to inspect to notice.
11. `sha256sum < dist/calibration.csv`. What appears where the filename
    usually is, and why?
12. `printf '' | sha256sum`. Write the first eight characters down — you will
    recognise this hash for the rest of your career.
13. Search `dist/SHA256SUMS` for that hash. Is it in there? What does its
    presence there mean about the file it names?

## B. Verifying

14. `cd dist` and run `sha256sum -c SHA256SUMS`. How many `OK`, how many
    `FAILED`, and what is the exit status?
15. Which file failed?
16. Which file could not be read at all? Is that the same kind of problem?
17. Run it again with `--quiet`. What is suppressed and what is not?
18. Run it with `--status`. What is the output, and how do you find out the
    result?
19. `--ignore-missing`. Which of the two problems does that hide?
20. Given exercises 15–19, write the single command you would put in a script
    that must fail loudly on either problem.
21. `md5sum -c MD5SUMS`. Does md5 catch the same corruption sha256 did?
22. What does that tell you about "md5 is broken" as a reason not to use it
    for this particular job?
23. In `scratch/`, copy `dist/strain-2187-05.log` and the manifest line for it.
    Fix the file's single wrong character (line 150 says `strian`), and verify.
    What is the exit status now?
24. You now know the manifest was written before the corruption. Could you have
    concluded that from `-c` output alone? What told you?

## C. Manifest edges

25. `cat copies/BINARY-SUMS`. What character sits between the hash and the
    name, and how many spaces?
26. `sha256sum -c copies/BINARY-SUMS` from inside `copies/`. Does it pass?
27. `sha256sum -b copies/full.log`. Same format? What does `-b` mean, and does
    it change the hash on Linux?
28. `cat -A copies/CRLF-SUMS | head -1`. What is at the end of each line?
29. `sha256sum -c copies/CRLF-SUMS` from inside `copies/`. Pass or fail?
30. Many people will tell you CRLF manifests always fail. Given 29, what is the
    accurate version of that claim?
31. In `scratch/`, make a manifest with two valid lines and one line of prose.
    Run `sha256sum -c` on it. What is the exit status?
32. Add `--warn`. What is printed, and what is the exit status?
33. Add `--strict` instead. Now what is the exit status?
34. A manifest arrives with 200 lines, of which 195 are wrapped by an email
    client and unparseable. `sha256sum -c` exits 0. Explain, in one sentence,
    what was actually verified.
35. Which flag would have caught that, and why is it not the default?
36. `grep 'sensor log' dist/SHA256SUMS`. How is the space in the filename
    handled?
37. Does `sha256sum -c` verify that file successfully? What is different about
    how its result line is printed?

## D. What it does not prove

38. In `scratch/`, copy `dist/calibration.csv`, alter it, and then write a
    fresh `SHA256SUMS` for the altered file. Does `-c` pass?
39. Given 38: if a manifest ships in the same directory as the files it
    describes, what does a passing `-c` prove about where the files came from?
40. Name the thing a checksum cannot supply that would fix 39, and name the
    tool category that supplies it.
41. Is there any key material on this station? Say how you checked, and be
    precise about what you found — `ops-bot`'s page makes a claim you should
    test rather than repeat.
42. `dist/SHA256SUMS` lists eight files. How many files are actually in
    `dist/`? Account for the difference.
43. Suppose the exporter had dropped a file entirely — never written it, never
    listed it. Would `sha256sum -c` report anything at all?
44. So `-c` answers "do the listed files match". Write down the question it
    does *not* answer, in your own words.
45. `wc -l dist/*.log`. All three logs are 300 lines. If the exporter had been
    told to export 400, would any checksum in this lab have noticed?
46. What kind of file would have noticed? (You are describing the thing lesson
    05 is about; you do not need to name it.)
47. A colleague says "the export passed its checksums, so the data is good."
    Separate that sentence into the part that is true and the part that is
    an assumption.
48. Under what circumstances would a *failing* checksum be the reassuring
    result?

## E. Judgement

49. You download an ISO and its `SHA256SUMS` from the same server. The
    checksum matches. What attack does that defeat, and what attack does it
    not?
50. The same ISO, with the checksum published on a different site you trust
    independently. What changed?
51. You are writing a nightly backup verifier. Which of `--quiet`, `--status`
    and `--strict` do you use, and what does your script do on non-zero exit?
52. Hashing a 900 GB archive takes hours. Give one thing you could hash
    instead that would still catch a truncated transfer, and say what it would
    miss.
53. Someone proposes md5 for the backup verifier "because it is twice as
    fast". Argue the technical case either way in two sentences.
54. You are handed a manifest and a directory and told they came from
    different people. What do you check first?
55. Write the sentence you would put in a runbook under "sha256sum -c passed".
56. Write the one-line note you would leave for whoever wrote
    `dist/SHA256SUMS`.
