# 11/03 — Tutor notes

For the AI tutor. Never give the answer. Ask the question that makes them run something.

## The one thing they must leave with

Which files run is decided by two independent properties of the shell, and **a login shell does not
read `~/.bashrc`**. A student who has that can derive everything else, including the chapter incident.
A student who has memorised the file list but still says "bashrc runs everywhere" has not got it, and
the incident will defeat them.

## The shape of the lesson

Exercises 9–14 are pure measurement and almost nobody gets them wrong. 16–22 are where the idea lands.
34–43 are where it becomes a story. 44–49 are where it becomes a habit. Do not let a student skip
16–22 because "first match wins, I did that in lesson 02" — the point is that the same rule governs a
different thing, and the consequence (exercise 21) is one of the two or three most common real
configuration losses there is.

## Where they get stuck

**Exercise 9.** Some students expect two or three markers. Ask what the notes said the word "first"
meant, then ask them to remove a file and run it again — 17 and 18 do this deliberately.

**Exercise 12.** "Nothing?" Yes, nothing. Ask what would go wrong if a script *did* inherit your
aliases. Let them arrive at "then my script would behave differently on your machine".

**Exercise 14 vs 13.** Subtle and easy to hand-wave. Insist they run both. The fact that
`bash -li -c cmd` skips `.bash_logout` was measured, not reasoned; a student who says "it should run,
it's a login shell" is reasoning, and the whole method of this course is to check.

**Exercise 22 — the real cliff.** They can state that `.bash_profile` shadows `.profile` but cannot
say why nobody notices. Push: "Your `.profile` is unchanged. What test would fail? What error would
print?" The answer is none, and that is the answer.

**Exercise 30.** `alias` lists it, `type` says not found. Students want one of them declared buggy.
Same move as lesson 02's `type` versus `which`: ask what question each one answers. Then ask what
`shopt expand_aliases` says, and let them connect "off" to "non-interactive".

**Exercises 40 and 41.** These ask for a *mechanism*, not a fix. If they propose fixing rhea's
terminal, stop them and re-read her last paragraph with them. She is explicit that she does not want
the fix. This is also a rhea-updates moment: she is right that nothing changed, and right that the
question is the difference.

**Exercise 44.** Some will do this to their own home directory. If they do, do not panic them —
`bash --noprofile -l` is the recovery and exercise 48 teaches it. Make them find it rather than
handing it over; it is the most portable thing in this lesson.

**Exercise 53.** Many students believe `source ~/.bashrc` is a reload. Have them define `zz` by hand
first, then source, then look. The persistence of `zz` is the proof, and it is one command.

## Red herrings

- `homes/split/.profile` contains a line saying "if you are seeing this, something took priority away
  from .bash_profile". It never prints. Students sometimes decide it is broken. It is a marker: its
  silence *is* the result.
- `notes/startup.txt` and `notes/order.txt` are correct and complete for this machine. They do not
  mention `expand_aliases` (exercise 30) or `shopt login_shell` (exercise 58). Silent, not wrong.
- The `if [ -n "$BASH_VERSION" ]` guard in `homes/station/.profile` looks like defensive noise.
  Exercise 24 rewards a student who asks why it is there.

## Integrity check

`stat -c '%y' homes/station/.bashrc` must read `2186-08-14 16:02:00` — rhea's claim depends on it,
and a student who edited the seeded home instead of a copy has destroyed the evidence for exercise 29.
Also confirm their own `~/.bashrc` is untouched: this lesson never requires editing it.

## If they finish early

Ask them to open `container/bashrc-seed`'s equivalent on their own laptop and find out, for their own
account, whether their terminal starts a login shell — and whether their `.profile` sources their
`.bashrc`. Most people have never looked. Then ask what would break tomorrow if they created a
`~/.bash_profile` tonight.
