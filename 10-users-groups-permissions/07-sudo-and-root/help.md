# 10/07 — Tutor notes

For the tutor agent. Not for the student. **Never give an answer.** Ask the question.

## What this lesson is actually about

Three things, and none of them is "how to use sudo":

1. **Root is exempt from the permission check, not permitted by it.** Everything else in the lesson
   is downstream of that sentence.
2. **`sudo` is a setuid-root program that reads a policy.** The privilege is unconditional; the
   authorisation is a decision made by a program that is already root.
3. **A grant is a sentence somebody has to be able to defend later.** This is what the chapter is
   for, and it is why the lesson ends in a written request rather than a command.

Students arrive believing `sudo` is a magic word. The measure of the lesson is whether they leave
able to say what `sudo` *is* — a file, with a mode, running a check.

## The exempt/permitted distinction — exercises 2, 3

Exercise 3 is the one that separates a student who has memorised from one who understands. If they
answer "same thing, different words", do not correct it. Ask:

- "Root's group list is `groups=0(root)` and nothing else. If root were *permitted* rather than
  *exempt*, what would that list have to look like?"
- "Write a mode that keeps root out."

The second question has no answer, and finding that out for themselves is the lesson.

## The PATH hijack — exercises 21 to 24

Every student enjoys this and about half of them draw the wrong conclusion: "so `sudo` is safe". It
is not the point. Push with:

- "Your `PATH` is hijacked right now. What happens the next time you type `ls`?"
- "`secure_path` protected the command `sudo` ran. What did it not protect?"
- "Who can write to the directories in `secure_path`?"

If they leave with "sudo has its own PATH" they have the fact. If they leave with "the fake was
never in the list sudo searched, and a policy is a list somebody maintains", they have the lesson.

Watch for a stale `bash` hash after they delete `scratch/bin/id` — `hash -r` fixes it and the
confusion is worth thirty seconds.

## Redirection — exercises 26 to 29

Some students will have hit `sudo echo x > /etc/y` before and know the workaround without knowing
the reason. Do not accept "you need tee". Ask which process opened the file, and when.

Exercise 29 is the one to spend time on: `tee` versus `sh -c` is the first time in the course they
are asked to prefer a form because of what it does to *somebody else's* review, not because of what
it does to their own machine. If they pick `sh -c` because it is shorter, ask what happens when the
value being echoed comes from a filename.

## The four grants — 49 to 56

The trap is that all four look reasonable. Order matters less than the reasoning; a student who
ranks A and D differently but argues it is doing better than one who matches the key by instinct.

- On grant A: ask what the grantee types, not what the grant says.
- On grant B: they will get `vi` immediately. Ask them for three more programs with the same problem
  before moving on (exercise 48). If they cannot get to three, they will grant one next year.
- On grant D: make them count. `ls /opt/kestrel/bin | wc -l` is 215 and the number does the arguing.
  Then ask the second question: who can write into that directory *tomorrow*.

**Exercise 56 is the integrity check.** The reviewer notes in `grants.txt` are unattributed. A
student who says who wrote them, or who infers a person from "somebody was in a hurry", has failed
that exercise however good the rest is. Ask which line supports the name. None does. Same discipline
as 10/04 exercise 39 and the whole of chapter 15.

## The script — 57 to 64

The wrong instinct is `sudo ./jobs/collect-counts.sh`, and most students will have it. Do not say no.
Ask them to run it that way and then `ls -l` the output file. Root-owned output in their own
directory does the teaching.

Exercise 63 (`rm -rf "${TARGET}"/*`) reliably produces "but it's quoted". That is the point — the
`/` is outside the quotes. Ask them to type out what the line becomes with `TARGET` empty, character
by character, rather than describing it.

For 64, `set -u` is not the answer and students reach for it. Ask whether the variable is unset or
empty; the script's own `TARGET="${TARGET:-}"` makes it set-and-empty, which `set -u` never fires on.

## The written request — 65 to 69

This is the centrepiece and it is not a writing exercise. Refuse vagueness the way rhea does, with
the same question each time: **what, where, as whom, how long, why not the ordinary route.**

Common failures:

- A path that does not exist and was never going to. Fine — the scenario is hypothetical — but the
  path must be *specific*. "the engineering directory" is not a path.
- No duration. Ask when they will hand it back. If the answer is "I won't need to", ask who revokes
  it and how they will know.
- Asking for root when the need is one user's read access. Ask what they would do with the other
  nine-tenths of root.
- "Why not" answered as "because it's denied". Ask what they ran to establish that.

If a student produces a request that offers the alternative — *if you would rather run it yourself,
here are the two commands* — say so. That is the difference between a request somebody grants and a
request somebody has to think about.

## Frequent wrong turns

**"sudo means I'm allowed to do it."** No — `sudo` means a policy says you may ask. Ask what the
policy is a file called and who can change it.

**Editing `/etc/sudoers`.** Out of bounds and the readme says so. If a student has tried, ask them
what happens to a station whose sudoers file no longer parses, and introduce `visudo -c` as the
reason `visudo` exists at all. `visudo -c` against `policy/sudoers.example` is safe and worth doing.

**Believing sudo use is auditable here.** Nothing runs syslog in this container, so there is no
`/var/log/auth.log` to inspect. Say that plainly if it comes up — the logging is real on a real
station, and this one cannot demonstrate it. Do not let a student write an answer claiming to have
read a log they did not read.

**Reaching for `su`.** It fails: root has no password. Worth two minutes on *why that is the
default*, not a bug — attributability. It sets up the roleplay directly.
