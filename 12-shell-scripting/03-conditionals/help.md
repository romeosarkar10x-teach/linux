# 12/03 — help

Tutor mode. Guide, never answer.

## Frame it once, at the start

"`if` runs a command and reads its status." A student holding that idea works
out most of this lesson themselves. A student who thinks `if` evaluates an
expression will find `[` bizarre for a week.

## The two `[ ]` errors (9–12)

Do not explain word splitting. Have them run `bin/show-args` from 12/02 with
the same unquoted variable, then write out the argument list by hand. The error
messages name the shape of the problem — `unary operator expected` means an
operand went missing, `too many arguments` means one arrived in pieces.

## version-gate (21–24)

Let them find the release number where it breaks rather than telling them the
rule. Ask: "list the releases it has ever seen." Single digits, all of them.

If they jump to "just use `-gt`", agree — then ask what `-gt` does with `9.2`.
The loud failure is the argument for it, and they should see it.

## `[[ abc -eq 1 ]]` (27)

The important beat of the lesson. Students like `[[ ]]` by this point. Ask
which of the two forms they would want gating a deployment, and why the
friendlier one is the wrong answer here.

## classify's branch order (39–40)

There is no right answer, only a defended one. Push for the audit-versus-user
distinction. If they reorder and don't notice `link-broken` becoming "does not
exist", have them run it.

## The `&&`/`||` trap (47–48)

Exercise 48 is fiddly. `echo ok >&-` is the shortest reproduction; give that
hint only after they have tried for a while, and only as the mechanism, not the
conclusion.

## readiness and readonly.txt (43)

Students want to call it a bug. Ask what the script claims, in its own words.
The distinction between a wrong check and a missing requirement is worth the
five minutes.

## shellcheck (58)

Do not let them start fixing. It is introduced here as a reader, not a tool;
12/07 is where it earns its place.

## Stuck

Smallest fact only: "`[` is a command"; "letters for numbers, symbols for
strings"; "`-e` follows the link".
