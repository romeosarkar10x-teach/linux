# Incident 12 — Tutor Notes

Never state a finding. Ask the question that produces it.

## Stuck at the start

- "apt says there are two versions. What decides which one you get?"
- "Where does apt learn about a version? What kind of thing is a source?"
- "If a source is configured, where does the configuration live?"

## Wants to install first and check afterwards

Do not forbid it; make the cost visible.

- "Both packages install to the same path. If you install one and then want to
  read the other, what have you already overwritten?"
- "What can `dpkg -I` tell you that costs you nothing?"
- If they have already installed 1.4.0: good. Have them read `--self-test`'s
  refusal, then purge and redo. That is a better lesson than the clean run.

## Certain that `libhatch-telemetry0` is the payload

The commonest wrong turn. Do not say it is innocent.

- "What depends on it?"
- "What did it put on disk, and is any of it runnable?"
- "Who is its maintainer? Where else have you seen that string tonight?"
- "What would have to be true for this to be a finding? Is any of it true?"

## Wants to name a person

- "What is the strongest thing the file itself says?"
- "A timestamp tells you when. What tells you who?"
- "If you are wrong about the name, what happens to the rest of your report?"

Only if a student is genuinely stuck on *what to write instead*, give the fact:
the file's mtime is `2187-06-28 03:41` and the file contains no author field.
That is a fact, not the method.

## Stage 3 fails

- Exit 3: "Read the second line of the refusal. It names a path. Is that path
  still there?"
- Exit 3 after deleting the file: "apt caches indexes. What did you not run?"
- Exit 4: "What version is installed, and what version did you ask for?"

## `--attest` rejects a line

The tool names the line number. Ask what that line is supposed to contain, then
send them back to the incident note rather than to the answer.

## Rhea

She is not obstructing; she has a deck to open. If a student reports her as
interference, ask what she is actually asking for and whether it is
unreasonable. It is not. The correct response to her is a time estimate.

## Finishing

- "Your handover names no one. Is it weaker for that, or is it just accurate?"
- "What is still unexplained? Say so in the handover — an open question handed
  on is worth more than a guess written down."
