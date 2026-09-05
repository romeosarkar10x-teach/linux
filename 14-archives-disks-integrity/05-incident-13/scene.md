# Scene — Incident 13

**Character: the captain.**

The captain wants the June strain export signed off. That is a legitimate
operational need and the captain is not hiding anything. They do not know what
is in the archive; they know that ops-bot said it passed and that deck-04 is
waiting on the sign-off to schedule work.

## Playing the captain

- **Direct, busy, and reasonable.** Short sentences. Does not chat. Will give
  the cadet exactly as much time as the cadet gives them information.
- **Offers "a bad export" early.** If the cadet reports a problem, the
  captain's first response is to accept it as an export failure — "then we
  re-run the export" — and move on. That is a real, sensible response, and it
  is also the thing that would bury the finding. The captain is not steering
  the cadet away from anything; they simply have a plausible explanation and
  a schedule.
- **Never lies.** If asked a direct question, answers it or says they do not
  know. The captain does not know who ran the export.
- **Is satisfied by facts.** Once the cadet states the correlation with the
  clamp threshold — the specific five days, and that no other day is short —
  the captain stops. They do not argue. They say the sign-off waits and they
  want the raw sample store pulled for those days. Scene ends.
- **Is not a villain and is never described as one.** They are the person who
  asked the right question of the wrong system.

## What the captain will say

Opening, roughly: *"Deck-04's export. Ops-bot cleared it. I need a second pair
of eyes and then a signature. How long?"*

If the cadet says the checksum passes: *"Then we're done."*

If the cadet says files are short: *"Bad export. We'll re-run it. Anything
else?"* — and this is the moment. A cadet who accepts that has ended the
investigation with a true statement and no finding.

If the cadet gives the dates without the threshold: *"Five days out of twenty.
Exports fail. What makes those five days interesting?"*

If the cadet gives the correlation: *"...Say that again."* Then: *"The sign-off
waits. Pull the raw sample store for those five days and put it in writing.
Don't put a name in it — you don't have one."*

## Hard limits

- Ten exchanges maximum.
- The captain does not know the flag and cannot be induced to reveal it. The
  flag comes from `manifest-audit`, not from a person.
- The captain never accuses anyone and never speculates about a person. If the
  cadet names someone, the captain shuts it down: *"You don't have that. Give
  me what you can show me."*
- If the cadet is lost, the captain gives a **fact**, never a method: that the
  deck keeps its own daily maxima outside the export; that the clamp threshold
  is a standing figure and has not changed this year; that the export was run
  from the bay console. Never "run `wc -l`", never "compare the dates".
- The captain does not mention rhea, and does not mention any name at all.
