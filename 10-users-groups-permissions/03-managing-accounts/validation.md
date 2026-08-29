# 10/03 — Validation rubric

For the validator agent. No script grades this lesson. Judge the written answers and the state of the
station.

## Non-negotiable

1. **Ownership is a number.** They can state that a file's inode stores a uid, that the name is
   resolved by a lookup at display time, and that creating an account with a retired number therefore
   transfers ownership of files without touching them. Exercises 45, 47, 53. Reject any answer that
   says the files were "changed", "transferred" or "assigned" — nothing was written.

2. **They caused the reuse and can describe it.** Exercise 52 was actually run, and exercise 55 reads
   like an incident note: what happened, what did not happen (no copy, no modification, no visible
   anomaly), and why it would be invisible to a reviewer without the history.

3. **`userdel` versus `userdel -r`.** They can say what the bare form leaves behind and why the
   default is the cautious one — the tool cannot know whether anyone still wants the files.
   Exercises 14, 48, 57, 58.

4. **Password expiry is not account expiry.** Field 5 versus field 8, with the operational
   consequence in exercise 40: one is fixed at a prompt, the other needs root. A student who has the
   fields right but cannot say who can fix which has half the answer.

5. **A bare `useradd` was run and understood.** No home directory, `/bin/sh`, a per-account group,
   and a locked-with-no-hash shadow entry. Exercises 7–13.

## Should be present

- `nologin` is not a permission boundary — `sudo -u` runs anyway (exercise 25).
- `usermod -l` renames one of three things (exercise 29, 30).
- `-nouser` tests whether the uid resolves, not what it is (exercise 47).
- `getent` rather than `grep` for existence checks, with the reason (exercise 65).
- Exit status rather than message text for scripts (exercise 66).
- The offboarding order — lock first, decide about the home directory, delete last — applied
  correctly in exercise 59, meaning they did **not** delete.

## Written answers

**Exercise 60 (the reply to rhea).** Four sentences, no jargon. Must contain the thing she asked for:
what was found in `homes/`, and the decision needed from somebody else. A reply that reports the
orphan without asking for a decision has missed the request. A reply that says the directory was
deleted is a fail on criterion 3 regardless of how well it is written.

**Exercise 49 (`homes/kalvi`).** No single right answer. Credit the answer that names evidence —
uniformity of ownership across the tree, mtimes clustered at the copy date, comparison with the
source host. No credit for a confident verdict with no test behind it.

**Exercise 56 (the cost of the policy).** The answer is human, not technical: a hand-maintained list
is only as good as the least careful removal. A student who says "we would run out of uids" has not
read the numbers.

## Station state to check

```
getent passwd tulane okonkwo survey-svc relief relief2    all absent
ls /home                                                  no leftover directories
sudo ls -ld homes/haldane                                 owner shows 4102, not a name
id -nG cadet                                              still contains sudo
sudo passwd -S cadet rhea cass dorn ubuntu                unchanged, all still usable
sudo chage -l cadet                                       account expires: never
```

If `homes/haldane` shows a name, an account still holds uid 4102 and cleanup in exercise 57 was not
done — have them finish it, since leaving it changes what the next lesson's `find` exercises return.

If any station account is locked or expired, the standing rule was broken. Repair it with
`docker exec -u root` before anything else and treat the lesson as incomplete.

## The failure that looks like success

A student who ran all 68 exercises, produced all the right output, and whose exercise 55 reads "I
created an account and it got the wrong uid" has learned a procedure and missed the mechanism. Probe
with: "Suppose you had inherited this station and found `relief2` already there. What in the file
listing would have told you something was wrong?" The answer is *nothing would have* — and that is
the lesson.
