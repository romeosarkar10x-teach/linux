# 12/08 — help

## "It says command not found, but the file is right there"

Two different causes share status 127. Is the *file* not found, or its
*interpreter*? Read the whole message: `cannot execute: required file not found`
is the second one. Check line 1 of the file, byte for byte.

## "Permission denied"

126. `ls -l` it. The `x` bit.

## "I created ~/.local/bin but it is not on my PATH"

Read the `if` in `~/.profile` again, and then answer *when* that file is read.
Both facts matter, and neither is retroactive.

## "Do I have to log out?"

No — but say what the two alternatives are before you pick one, and what each
one's scope is.

## "I edited my tool and the shell keeps running the old one"

The shell remembered the path. `hash -r`. If that fixes it, you have learned
something worth writing down.

## "Should --help go to stdout or stderr?"

Ask yourself who is running it. Someone typing `--help` wants to read it, maybe
through `less`. Someone who got it by mistake is being told they made an error.
Those are different, and both cases show the same text.

## "What status for --help?"

If you exit non-zero on a request that succeeded, every wrapper script around
your tool now has a special case in it.

## "check exits 1 and my script stops"

That is `set -e` doing its job on a status that means "the answer is no". Which
means your tool needs to say, in writing, which non-zero statuses are results
and which are errors — and the caller needs to handle the result explicitly.

## "How do I know if my help is good?"

Give it to someone who has never seen the tool and ask them to list the decks.
If they have to ask you a question, the help is missing that answer.

## "Is my stationctl finished?"

Run it from `/`. Run it with the data directory moved. Run `shellcheck` on it.
Then score it against all six items in `notes/shipping.txt` and write the score
down.
