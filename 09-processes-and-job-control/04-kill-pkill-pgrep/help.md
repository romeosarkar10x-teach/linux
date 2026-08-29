# 09/04 — Help: kill, pkill and pgrep

For the tutor agent. The student must reach the conclusions themselves; every one of them is one
command away.

## The shape of this lesson

Two ideas, and the second one is the whole lesson. First: `pgrep` selects and `pkill` selects and
acts. Second: selection is harder than it looks, and it fails silently in the direction of *more*.

`notes/incident-log.txt` is the emotional core — a competent person ran a correct command and stopped
the wrong thing. Point the student at it early if they are treating this as a lesson about flags.

## Where they get stuck

**"`pgrep panelctl` finds nothing but it's running."** Do not say "use `-f`". Ask: `ps -p <pid> -o
pid,comm,args` — three columns, which one has the word `panelctl` in it? Let them find that `comm` is
`bash`.

**"So `comm` is always bash for scripts?"** `bin/deckwatch` breaks that too, and it is worth breaking:
`comm` is the basename of the executing file, which for a script is the interpreter, and for
`deckwatch` is the symlink it exec'd. Ask them to read the script.

**"Why is the name cut off?"** Fifteen characters. Ask them to count. `pgrep` is unusually helpful
here — it warns rather than silently returning nothing — and a student who reads that message has
found the answer without help.

**"`panel*` matched `pane`, that's a bug."** Chapter 6. Ask them what `*` quantifies in an ERE. If they
say "anything", ask them to write `panel*` as words: "p, a, n, e, then l how many times?"

**"I ran `pkill -f panel-mon` and it killed two things."** This is the lesson landing. Do not console
them. Ask what the shift log says, and then ask what they would write in it.

**Anchoring with `-f`.** Students try `'^bin/panel-mon'` and get nothing, because the command line
starts with `bash`. Ask them to run `pgrep -af` and *read the string they are anchoring to*. Almost
nobody does this before trying to anchor.

**Process groups (37, 37a, 37b).** Confusing and worth the time. The key question is "who decided
which group these are in", and the answer is the shell that started them. The script version killing
itself is the memorable part — let them run it rather than warning them, it is safe and it is only a
scratch script.

## Things not to say

Do not give them the `preview` function (48). Ask what would make the pattern in the preview and the
pattern in the action impossible to get out of sync.

Do not tell them `-e` reports `comm` (exercise 22). Ask them what name it printed and whether that is
the name they searched for.

Do not answer 54. It is a question about what a person in their position can change, and the honest
answer — the cheap fix is the only one available to you, so log the expensive one — is worth arriving
at.

## Common wrong answers worth engaging

- *"`killall` is the dangerous one."* It has the alarming name and the more conservative default.
  Exercise 35 is the demonstration. Ask which of the two would have caused the March incident.
- *"`-c` is safer, it doesn't kill anything."* Ask what they would do with the number. `-c` used
  instead of `-a` is how you learn there were two matches after you have killed both.
- *"rc 1 means it failed."* Chapter 6's convention. Ask what question the rc is answering.
- *"I'll just always use `-x`."* Fine until an argument changes. Ask them what `-xf` matches after
  somebody adds a flag to the command line.

## Scope

Job control — `bg`, `fg`, `jobs`, `disown` — is lesson 05. Exercise 37b touches process groups because
they are what a negative pid means; do not let it turn into a job-control lesson.

`/proc/<pid>/environ`, `lsof` and `nice` are lesson 06. Exercise 55 points at the environment
deliberately: the answer "write the preview to a file before you kill it" is the incident's rule
arriving early, and a student who states it here will have an easier lesson 07.

Do not mention the incident. The `notes/incident-log.txt` entry is a different, smaller event and it
is fine to discuss at length.
