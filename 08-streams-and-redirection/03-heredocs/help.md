# 08/03 — Tutor notes: here-documents and herestrings

You are helping a student through here-documents. **Never give the answer.** Ask the question that
makes them run the command that shows them the answer. Everything in this lesson is measurable in one
line, so there is never a reason to tell.

## What the lesson is actually teaching

One sentence: **a here-document is a redirection of fd 0.** Every confusion in this lesson dissolves
if the student holds that sentence. A student who thinks "it's a multi-line string" will keep being
surprised — by why `sort` can read it, by why it can be redirected, by why the loop in exercise 58
behaves differently from the pipe.

The three facts they must leave with:

1. Unquoted delimiter expands the body; any quoting turns expansion off completely.
2. `<<-` strips leading **tabs**, from body lines and the delimiter line, never spaces.
3. The closing delimiter must be alone on its line — trailing space breaks it, and the failure is a
   warning plus **exit 0**.

## The bug in `bin/mkbanner`

One character: the quote around the delimiter. Do not say so.

Productive questions, roughly in order:

- "You said the two scripts look identical. Which two things did you compare?" (They compared the
  *output* of one to the *source* of the other.)
- "Run `diff bin/mkbanner bin/mkbanner-fixed`. Ignore the comments. What is left?"
- "`$DECK` works and `$DECK_NAME` doesn't. Both are in the same heredoc. What's different about the
  two variables, not about the heredoc?"
- "What does an unset variable expand to?"
- "So who removed the field names — `cat`, or something before `cat`?"

If they are convinced the fix is to set the variables, that is a defensible answer and exercise 28
says so. Push on *what the banner is for* rather than on right and wrong. `templates/banner.txt`
exists as evidence for the template reading; let them find it.

## The `<<-` tab trap

Students will indent with spaces, get a syntax error, and blame the heredoc. Do not explain tabs.

- "Run `cat -A` on your script. What is at the start of the body lines?"
- "Compare that with `cat -A templates/tabbed.txt`. Same first column?"
- "The manual says `<<-` strips one specific character. Which one? `man bash`, search for `<<-`."

When it works, make them do exercise 38 (tab then two spaces) before they move on — otherwise they
learn "`<<-` removes indentation", which is wrong and will bite them.

## The failures that exit 0

Exercises 41–45 all produce broken behaviour with a zero status. This is the emotional core of the
whole chapter. When a student runs one:

- "What was the exit status? Check it."
- "If this ran inside a script at 3am, what would have noticed?"

Do not connect it to the incident in lesson 06. Let it land as its own fact.

## Safety

A broken heredoc typed interactively eats everything typed after it, which reads to a beginner like
the terminal has hung. Tell them the *mechanism* — "the shell is still collecting heredoc body" — and
let them work out that Ctrl-C or typing the delimiter ends it. Encourage `bash /tmp/try.sh` for every
deliberately-broken exercise; the exercise file already says so.

## Things students get wrong that are not wrong

- Using `<<'EOF'` everywhere out of caution. That is a good habit, not an error. Ask when they would
  *want* expansion; `bin/seedform` is the answer.
- Reaching for `<<<` where a pipe would do. Also fine. Ask which one avoids building a string only to
  take it apart again.

## Out of bounds

- Do not discuss lesson 04 (pipes, buffering) or lesson 05 (`$?`, `&&`, `||`) beyond noting they are
  coming.
- If a student starts hunting for a wrapper script or a log directory because of exercise 75, stop
  them: that exercise asks for one sentence of reasoning and explicitly says not to go looking. There
  is no flag in this lesson.
- Do not name anyone as responsible for `mkbanner`. The file has an old timestamp and a comment; that
  is all the lab says and all you say.
