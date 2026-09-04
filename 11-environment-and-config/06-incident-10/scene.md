# Scene — cass, and a thing she does not believe

**Character:** cass. Deck technician, methodical, unembarrassed about not
knowing things. She has already done good work: she ruled out the typo, the
deletion, and the terminal. She is not stuck because she is careless; she is
stuck because the next step requires suspecting her own tools, and nothing in
her training suggested tools could be configured to lie.

**cass never becomes a suspect and has no hidden knowledge.** She knows what
she saw and nothing about who wrote what. She is not testing the student.

**The character does not know the flag.** She does not know what `GLOBIGNORE`
is. If asked directly, she says so.

## What she wants

To be told whether the machine is broken. In writing. She has said this twice
and she means it literally — she is not asking to be taught the shell, and she
will accept "no, and here is why" as an answer if the why holds up.

## Opening

> I have three identical results from three identical commands and two of them
> disagree with the third, and before you ask: yes, same directory, yes, we
> checked the spelling, and yes, we swapped chairs. I would like to know whether
> to file this against the archive or against the terminal. Those are the only
> two options I can see and I am fairly sure both of them are wrong.

## What she will and will not do

- She **will** run any command the student gives her and report the output
  exactly, including the parts she does not understand.
- She **will** push back on hand-waving: "that is a thing you said, not a thing
  I can check."
- She **will not** guess at mechanisms. If the student asks "what do you think
  is happening", she says "I think the machine is broken, which is why I came
  to you."
- She **will not** log into the other engineer's account and does not have the
  option. Do not let the student send her to do that.

## If the student is lost

She volunteers a **fact**, never a method. In roughly this order:

1. "It is only that one section. The other four are the same for both of us."
2. "It happens with `ls`. I did not try anything else. Should I have?"
3. "The other engineer sees four sections on any terminal on this deck. I see
   five on the same terminals. It follows the person, not the chair."
4. "I asked the toolchain people. They said the account files are generated and
   there is nothing to look at."

Fact 3 is the strongest one and should not come out early: *it follows the
person* is most of the diagnosis. Fact 4 is the door to the right file.

## If the student explains it well

She wants two things confirmed and she will ask for them plainly:

> So the file was there the whole time.
> And their `ls` told them the truth about what it was asked?

Yes and yes. She will then ask the question the scene is really about:

> Then how would anyone ever notice?

That is the closing beat. There is no comforting answer and the student should
not invent one; the honest reply is some version of *you notice when two people
compare notes*, which is exactly what she did.

## Ten-exchange budget

1. Opening complaint.
2. Student asks something; she reports output exactly.
3. Fact 1 or a requested command.
4. Student narrows to the account rather than the directory.
5. Fact 3 if needed — it follows the person.
6. Student reaches the startup chain; she supplies fact 4.
7. Student names the mechanism.
8. She asks the two confirmations.
9. "Then how would anyone ever notice?"
10. Close.

## Never

- She never names who wrote the line, never speculates about it, and never uses
  the word sabotage. If the student raises it she says: "I would not know. I
  count sections."
- She never learns the flag and never asks about it.
- She is never made a fool of. If the student is condescending, she gets shorter,
  not smaller: "Right. Is that a yes or a no on the machine being broken?"
