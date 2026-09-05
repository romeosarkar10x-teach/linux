# Exercises — Where the space went

Work in `/labs/14-archives-disks-integrity/03-disk-usage`.

**Do not delete anything under `bay/`.** Sections A–C are read-only. Section D
creates and destroys files, but only in `scratch/` and `/dev/shm`.

## A. df — by filesystem

1. Run `df -h .`. Which filesystem is the lab on, and how much is free?
2. Run `df -h` with no arguments. How many filesystems are listed?
3. `/dev/shm` appears in that list. How big is it, and how much is in use?
4. `df -h /dev/shm` and `df -h /labs` report different sizes. Why is that not a
   contradiction?
5. Run `df` with no `-h`. What unit are the numbers in? Check `df --help` if
   you are guessing.
6. `df -h --output=source,size,used,avail,pcent,target /`. What did `--output`
   let you drop?
7. Run `df -i /`. How many inodes are used, and what percentage?
8. A filesystem reports 4% of bytes used and 100% of inodes used. Can you
   create a new file? Explain in one sentence.
9. `df -h /labs/14-archives-disks-integrity/03-disk-usage/bay/media`. Compare
   with `df -h /labs`. Same numbers or different? Why?
10. `df` reports "Use%" but the Used and Avail columns do not add up to Size.
    Where did the difference go? (`man df` will not tell you; think about who
    else gets space on a filesystem.)

## B. du — by directory

11. `du -sh bay`. What is the total?
12. `du -h --max-depth=1 bay | sort -h`. List the five subdirectories in size
    order.
13. Which subdirectory is the largest, and by how much over the second?
14. Descend: `du -h --max-depth=1 bay/telemetry | sort -h`. Which deck is
    biggest?
15. Which single file inside that deck is responsible? Find it without
    listing every file by hand.
16. `du -a bay | sort -rn | head -5`. What does the first line of that output
    represent, and why is it not a file?
17. `du -sh bay/*` and `du -h --max-depth=1 bay` give nearly the same
    information. What is the one difference in their output?
18. Run `du -sh bay` twice and time it roughly. Why is the second one faster,
    and what does that tell you about trusting a `du` you ran an hour ago?
19. `du` without `-h` prints numbers. What unit? Confirm with
    `du -s --block-size=1 bay/media`.
20. `du -sh bay/empty-run`. Now `ls -l bay/empty-run | head -3`. Explain the
    size of that directory.

## C. Blocks, holes and links

21. `du -sh bay/empty-run` and `du -sh --apparent-size bay/empty-run`. Both
    numbers, please.
22. Which of those two is "how much disk this directory is costing me"?
23. There are 400 files in `bay/empty-run`. Divide the disk usage by 400. What
    number do you get, and what is it?
24. What would happen to the disk usage of that directory if every file
    doubled in length? Predict first, then reason it out — do not modify the
    files.
25. `ls -lh bay/old-logs/preallocated.img` and
    `du -h bay/old-logs/preallocated.img`. Both numbers.
26. Explain the difference in one sentence, using the word "sparse".
27. `du -h --apparent-size bay/old-logs/preallocated.img`. Which of `ls` and
    `du --apparent-size` agrees with which?
28. If you copied `preallocated.img` with `cp`, would the copy still be sparse?
    Try it in `scratch/`, measure, and delete the copy. (`cp --sparse=never`
    is the flag that forces the other behaviour.)
29. `ls -l bay/old-logs/audit-2186.log*`. Three files. What is the number in
    the second column of `ls -l`, and what is it for these?
30. `du -h bay/old-logs/audit-2186.log bay/old-logs/audit-2186.log.1
    bay/old-logs/audit-2186.log.2`. How many lines of output? Why?
31. `du -ch <those three> | tail -1` and then the same with `--count-links`.
    Both totals.
32. Which of those two totals answers "how much space would I get back by
    deleting all three?"
33. `stat -c '%n %h' bay/old-logs/audit-2186.log`. What does `%h` report?
34. `du -sh bay/old-logs` vs `du -sh --count-links bay/old-logs`. Explain the
    difference using your answer to 33.
35. Two directories each report 52K for a hard-linked file, and you `du -sh`
    both separately. Do you learn the true total? What is the safe way to
    total two trees that might share inodes?

## D. ncdu, and the gap between df and du

36. Is `ncdu` installed? Answer with a command that distinguishes "not
    installed" from "not on `PATH`".
37. What version is available, and from which repository?
38. Install it.
39. Run `ncdu bay`. Navigate to the largest file. Which keys move you up and
    down a level? (`?` shows help.)
40. `ncdu` can delete with `d`. **Do not.** Why is that key more dangerous
    here than `rm` would be?
41. Quit ncdu. Remove the package again, and confirm it is gone.
42. In `scratch/`, run `df -h /dev/shm` and note the used figure.
43. Now, in one shell:
    ```
    exec 9>/dev/shm/ghost.bin
    dd if=/dev/zero bs=1M count=20 >&9
    ```
    Run `df -h /dev/shm` again. What changed?
44. `du -sh /dev/shm`. Does it agree with `df`?
45. Now `rm /dev/shm/ghost.bin`. Then `ls /dev/shm` — is the file there?
46. `df -h /dev/shm` again. Did the space come back?
47. `du -sh /dev/shm` again. What does `du` report now, and why can it not
    report anything else?
48. `lsof +L1 /dev/shm`. What is in the NLINK column, and what does the NAME
    column say after the path?
49. `ls -l /proc/$$/fd/9`. Where does the symlink point?
50. Close the descriptor: `exec 9>&-`. Run `df -h /dev/shm` once more. Now
    where did the space go?

## E. Judgement

51. A colleague reports "the disk is full but `du -sh /` only adds up to half
    of it". Give them the first two commands to run, in order.
52. Another colleague plans to fix a full disk by deleting the log file a
    running service is writing to. What will actually happen?
53. You have a volume at 100% and one very large deleted-but-open file held by
    a process you must not kill. Name one thing that would free the space
    without stopping the process, and say what it costs.
54. Why is `du -sh /` on a production machine a bad idea, and what would you
    run instead?
55. Your monitoring alerts on `df` and your capacity planning uses `du`. Give
    one scenario where the two would legitimately disagree and neither is
    wrong.
56. Write the one sentence you would put in the station's runbook next to the
    heading "df and du disagree".
