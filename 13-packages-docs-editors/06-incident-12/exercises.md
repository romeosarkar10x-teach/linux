# Incident 12 — Exercises

Lab: `/labs/13-packages-docs-editors/06-incident-12`

Do section A before you install anything. That is the point of the lesson.

## A. Look before you touch (1–12)

1. Read `notes/incident.txt`. Write down, in your own words, the three things
   the previous shift wants back.
2. Run `apt-cache policy deck-verify`. How many versions are on offer?
3. What is the **candidate** version — the one a plain `apt install` would give
   you?
4. Which source does the candidate come from? Copy the line exactly.
5. Which source offers the other version?
6. Is the candidate the highest version number, or the one from the station's
   own source? Say which rule apt is following.
7. Run `apt list -a deck-verify`. Same information, different shape. Which of
   the two would you paste into a handover note, and why?
8. List `/etc/apt/sources.list.d/`. How many files are there?
9. Which of those files configures the source the candidate came from? Name it.
10. `ls -l` that directory. What is the modification time of that file, and how
    does it compare to the others?
11. Does the file record who created it? Say what it does and does not contain.
12. Is `deck-verify` currently installed? Show the command that answers it
    without guessing from `which`.

## B. Reading a package you have not installed (13–24)

13. The two `.deb` files are in `repo-station/` and `repo-unknown/`. List both
    with sizes.
14. Run `dpkg -I` on the station's `deck-verify_1.0.0_all.deb`. Who is the
    maintainer?
15. Run `dpkg -I` on `repo-unknown/deck-verify_1.4.0_all.deb`. Who is the
    maintainer there?
16. Compare the two `Description:` fields. What is the same, and what is
    missing from one of them?
17. The station's package has a control field that is not one of the standard
    ones. Find it. Field names starting `X-` are custom. **Its value is
    stage 1.**
18. The unknown package has a field with the same name and a different value.
    **That value is stage 2.**
19. Which package declares a `Depends:` line, and on what?
20. Which one declares no dependencies at all? Is that reassuring or not — say
    what it actually tells you.
21. Run `dpkg -c` on both. How many files would each put on disk?
22. Does either package ship a man page? Does either ship documentation under
    `/usr/share/doc`?
23. Nothing in exercises 13–22 installed anything. Confirm that: is
    `/usr/bin/deck-verify` present yet?
24. Write one sentence saying which of the two packages you intend to install
    and why, using only evidence from this section.

## C. The package that was already there (25–34)

25. `dpkg -s libhatch-telemetry0`. Is it installed, and at what version?
26. What does its own `Description:` say it is?
27. Who is its maintainer? Compare with the maintainer of the station's
    `deck-verify`.
28. `apt-cache rdepends libhatch-telemetry0`. What depends on it?
29. `dpkg -L libhatch-telemetry0`. How many real files (not directories) did it
    put on disk?
30. Is any of those files a program you could run? Say how you checked.
31. `dpkg -V libhatch-telemetry0`. What does silence mean here?
32. Does this package come from either of tonight's two sources, or from
    somewhere else? Show how you decided.
33. On the evidence in 25–32, is `libhatch-telemetry0` a finding or not? Answer
    in one sentence, and say what would have to be true for it to be one.
34. The previous shift said "it may be nothing." Was that the right way to
    write it down? Say why.

## D. Installing the version you chose (35–44)

35. Remove the source you did not expect. Which command, and does removing the
    file alone finish the job?
36. Run `sudo apt update`. Does `deck-verify` still appear in
    `apt-cache policy`?
37. What is the candidate now?
38. Install `deck-verify` at the version the station should be running. Use the
    `package=version` form even though you no longer strictly need to, and say
    why that is a good habit.
39. Which other package did apt pull in, or did it already have what it needed?
40. `deck-verify --version`. Does it match what you asked for?
41. `deck-verify --self-test`. What does it print, and what is its exit status?
    **The token it prints is stage 3.**
42. Suppose you had run `--self-test` before removing the source file. Put the
    source file back, run it, read the refusal, and then remove the file again.
    What exit status did the refusal use?
43. Suppose you had installed 1.4.0 by accident. Without doing it, say what
    `--self-test` would complain about, based on its refusal messages.
44. `dpkg -L deck-verify`. What did the station build put on disk that the
    other one did not?

## E. The attestation (45–50)

45. Write your three findings into a file, one per line, in the order the
    incident note asks for.
46. Run `deck-verify --attest` on it. If it rejects a line, it says which. Fix
    and re-run.
47. **The flag is what a successful attestation prints.** Submit it with
    `kestrel flags submit`.
48. `--attest` re-checks the station even after your three lines are correct.
    Why would a tool do that, rather than trusting the write-up?
49. Write the handover for the next shift: five lines, no more. What happened,
    what you did, what is still unexplained.
50. Your handover names no person. Say, in one sentence, what a reader would be
    entitled to conclude from it — and what they would not.

## F. Going further (51–56)

51. `grep -r . /etc/apt/sources.list.d/` prints every configured source in one
    go. Why is this a better first move than `cat`-ing files one at a time?
52. The unexpected source used `[trusted=yes]`. Look at lesson 02's notes:
    what does that option switch off?
53. If the source had been signed and legitimate, which of your findings would
    change and which would stay the same?
54. `apt-cache policy` with no arguments prints every source and its priority.
    Run it. Which sources are at priority 500?
55. A package appearing on your station is a fact. A package being *installed*
    on your station is a different fact. Which one did tonight actually
    involve, for `deck-verify` and for `libhatch-telemetry0`?
56. Put the station back: is anything left on this machine that was not here
    when the incident opened? Check, and say how you checked.
