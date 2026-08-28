# 07/06 — Exercises: `tee` and `xargs`

Work in `/labs/07-text-processing/06-tee-and-xargs`. Never point `tee` at a file that is also the
pipeline's input; every exercise here that writes uses `reports/` or `scratch/`.

## `tee`

1. Build the account frequency table from `logs/access-2187-06-10.log`, save it to
   `reports/top-2187-06-10.txt`, and show only the first three lines on screen. One pipeline.
2. Check the file has all seven lines. Where did the other four go, and how many times was the log
   read?
3. Do the same job without `tee`, twice: once with a temporary file, once by running the pipeline
   twice. Say what each costs.
4. `echo one | tee scratch/a.txt`; then `echo two | tee scratch/a.txt`. Now `cat scratch/a.txt`. What
   happened to `one`?
5. Repeat with `tee -a`. State the rule.
6. `echo x | tee scratch/b1.txt scratch/b2.txt`. How many places did `x` go?
7. `echo x | tee /etc/nope.txt` — read the error, then answer: did `x` reach the terminal, and what
   was the exit status?
8. Why is that the right design for a command whose job is to be in the middle of a pipeline?
9. `echo hi | tee /dev/null`. What is the point of writing to `/dev/null` deliberately?
10. Explain, without running it, what `cat logs/access-2187-06-10.log | tee logs/access-2187-06-10.log`
    risks. Which part of the command truncates the file, and when?
11. Copy the log to `scratch/`, then use `sed -i` from lesson 04 to change it in place. That is the
    supported way to edit a file. Say why `tee` is not.
12. Save both the counts **and** the sorted account list from one pass over the log using two `tee`s.

## `xargs`: the basics

13. `cat data/accounts.txt | xargs echo`. How many times did `echo` run?
14. `xargs -n1 echo < data/accounts.txt`. Now how many? Note the `<` — no `cat` needed.
15. `xargs -n2 echo < data/accounts.txt`. Account for the last line of output.
16. `xargs -n3 -t echo < data/accounts.txt`. What does `-t` show you that you were guessing at
    before?
17. `xargs -I{} echo "account: {}" < data/accounts.txt`. Where can `{}` go, and how many times may it
    appear?
18. Write one command that turns `data/accounts.txt` into seven lines of the form
    `ops-bot -> reports/ops-bot.txt`.
19. `xargs -I{} -n2 echo {} < data/accounts.txt`. Read the warning. Which flag won?
20. `printf 'one\ntwo\n' | xargs` with **no command at all**. What is the default command?
21. `xargs echo hello < data/empty.txt` — the input file is empty. Did `echo` run?
22. Add `-r` and try again. When does that difference matter in a script?
23. `xargs -a data/accounts.txt -n2 echo`. What does `-a` save you?
24. `printf 'a,b,c' | xargs -d, -n1 echo`. What did `-d` change, and what happened to the missing
    trailing newline?
25. `xargs -n1 echo < data/accounts.txt | head -3`. Read the message on stderr. What is signal 13, and
    is anything wrong?

## Which commands need `xargs`

26. `grep -rl rhea logs | xargs -n1 basename`. Now try it without `xargs`. What does `basename` do
    with its standard input?
27. Name three commands from chapters 1–6 that need `xargs` and three that do not. What is the test?
28. `wc -l` takes both — it reads stdin *and* accepts filenames. Show both forms against the two logs
    and say which output you prefer and why.
29. Use `xargs` to run `wc -l` on both logs from a list in a file. Where did the `total` line come
    from?
30. `printf 'nosuchfile\n' | xargs wc -l; echo $?`. What is exit status 123?

## The whitespace edge

31. `ls data/awkward`. Read the four names carefully and predict which will break a naive pipeline.
32. `ls data/awkward | xargs -n1 echo`. Read the error message. Which file caused it?
33. `find data/awkward -type f | wc -l`. Count the files with `ls -1` too. Explain the discrepancy.
34. `find data/awkward -type f -print0 | xargs -0 -n1 echo`. All four, correct. What is the only
    character that cannot appear in a filename?
35. Why can `find` and `xargs` agree on NUL but not on any other separator?
36. `printf -- '-n\nhello\n' | xargs echo`. Where did the newline go?
37. Try to fix 36 with `xargs echo --`. Read the output. Did it work, and whose fault is that?
38. Suppose the file list came from an untrusted place and contained `-rf`. What would
    `xargs rm` do? (Do not run it. `ls` the directory and reason.)
39. Write the safe form of "delete every `.tmp` file under `scratch/`" as you would actually type it.
    Do not run it on anything you want.
40. State the rule you will follow for the rest of the course about streams that carry filenames.

## Combining them

41. Save the account table to `reports/` and, in the same pipeline, pass it on to `head`. Then run
    `wc -l` on the saved file to prove nothing was lost to the `head`.
42. `printf 'logs/access-2187-06-10.log\n' | tee scratch/list.txt | xargs wc -l`. Describe the flow in
    one sentence.
43. Use `xargs -I{}` with `sh -c` to print `rhea has 96 lines` and `cass has 54 lines` from the log.
    Why is `sh -c` needed at all?
44. That command puts `{}` inside a shell string. Say what would happen if an account were named
    `; rm -rf ~`. What does that tell you about `-I{}` plus `sh -c`?
45. Build `reports/` files one per account: each named `reports/<account>.txt`, each containing that
    account's log lines. Do it with `xargs`, then do it with one `awk` (lesson 05, exercise 52).
    Which is better here?
46. Compare `find data/awkward -type f -exec echo {} \;` with the `xargs` version. How many processes
    did each start, and when does that matter?
47. `xargs --show-limits < /dev/null`. What is the largest command line this system will take, and why
    does `xargs` exist at all given that number?
48. Build a pipeline that counts accounts across **both** logs and writes the result to
    `reports/top-both.txt` while showing you the top three.

## The report

49. `notes` are not provided this lesson on purpose. From the two logs, produce a report that shows,
    per account, the count for each day and the total. Any tool from this chapter.
50. Save it to `reports/access-summary.txt` with `tee` while checking it on screen.
51. The 2187-06-09 log has an account missing entirely from one day. Which, and how does your report
    show that — as a zero, a blank, or a missing row?
52. Make the missing case show as `0`. Which tool did you need, and is it worth it?
53. Read your report as the captain would. Is the biggest number at the top? Are the columns aligned?
    Does it say which days it covers?
54. Add a header line with the date range, after sorting. Which lesson-05 exercise is this?

## Stretch

55. Write a one-line pipeline that produces the table, saves it, saves a NUL-separated copy of just
    the account names, and prints the count of accounts. Explain why this is a bad idea even though it
    works.
56. `xargs` with `-n1` runs one process per line. Time it against a single `awk` over the same 600
    lines. State the general rule about loops made of processes.
57. Which of `tee`, `xargs`, `awk` and `sed` would you use to append one line to a file that fifty
    other scripts also append to? Say what could go wrong with each.
58. `tee` writes as it goes. What does that mean for a pipeline whose last command exits early, like
    `head`? Test it with a long input and check the saved file.
