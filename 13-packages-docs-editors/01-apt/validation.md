# 13/01 — validation

For the validating agent. No flag in this lesson. Do not give answers; ask.

## Hard gates

1. The lab's repository is registered: a `station.list` exists under
   `/etc/apt/sources.list.d/` and `apt-cache policy deck-audit` shows the
   `file:` source. If the student edited the lab's copy instead and expected it
   to work, that is exercise 12 and worth walking back through.
2. They can state, without looking it up, what `apt update` changes and what it
   does not.
3. They have installed `deck-report` and can say how many packages that
   installed and why.
4. They have seen the `rc` state: removed, config-files remaining. Ask them to
   produce it live.
5. They can distinguish `remove` from `purge` with reference to
   `/etc/deck-report.conf`.

## Understanding — ask these

6. "Which of the apt commands you ran today needed root, and why?" Wanted: the
   ones that change the system. A student who says "all of them, I used sudo
   for everything" gets sent to exercise 7.
7. "You asked for one package and got two. Which field caused that?" Wanted:
   `Depends:`.
8. "`apt remove deck-common` offers to remove `deck-report` too. Why?" Wanted:
   the dependency read in the other direction.
9. "What is `[trusted=yes]` doing in the source line?" A guess is acceptable
   here — this is lesson 02's material. What is *not* acceptable is not having
   noticed it.
10. "Where does `apt` keep the catalogue?" Wanted: `/var/lib/apt/lists/`. Bonus
    if they can say how to check when it was last refreshed.
11. "Which command would you put in a script, and how do you know?" Wanted:
    `apt-get` / `apt-cache` / `dpkg-query`, because `apt` prints a warning
    saying its interface is not stable. A student who quotes the warning from
    memory has read their own terminal, which is the skill.
12. "`apt show nosuchthing` exits with what?" Wanted: 100. If they say 1, have
    them run it — this is the lesson's small trap and it pays off in chapter 12
    scripting habits.
13. "Where did the station repository come from?" Correct answer today: they do
    not know, and nothing in this lab says. Push back on any invented answer,
    including a name. The chapter answers this in lesson 06 and not before.

## The script (exercises 48–50)

14. Uses `dpkg-query` or `apt-get`, not `apt`, with the reason in a comment.
15. Three states, three exit codes, documented in the header.
16. `--help` on stdout, exit 0.
17. `shellcheck` clean or every finding justified.
18. Handles a package that was never installed *and* one in `rc` state. Test
    both in front of them.

## Common failure modes

- Running everything under `sudo` and never noticing which commands needed it.
- Confusing `update` with `upgrade` — check by asking, not by watching.
- Answering `y` to a removal list without reading it. Watch for this directly;
  it is the habit this lesson exists to prevent.
- Concluding the repository is malicious. Nothing supports that yet. An
  unsigned local repository is normal on fleets without internet access.
