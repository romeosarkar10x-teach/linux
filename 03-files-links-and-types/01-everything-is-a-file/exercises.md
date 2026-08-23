# 03/01 — Exercises

**Lab:** `/labs/03-files-links-and-types/01-everything-is-a-file`
Seed it with `kestrel seed 03/01`. Reset with `kestrel reset 03/01`.

Tools: `ls`, `stat`, `file`, `cat`, `head`, `wc`, `od`, `test`, plus everything from Chapters 1–2.

One exercise below will make your terminal appear to hang. That is the point of it; do not reboot
anything. `Ctrl-C` returns you.

---

## Warmup

**1.** `cd` into `types/`. Run `ls -l` and copy the seven first-column characters into your notes,
one per line, each with the name of the entry it belongs to.

**2.** Without looking at the readme table again, write down what each of the seven characters
means. Then check yourself. Record which ones you got wrong — those are the ones to re-read.

**3.** Run `ls -F types` from the lab root. List which entries got a marker and which did not. State
the rule that explains the ones that did not.

## Core

**4.** For every entry in `types/`, print its type as a word using one `stat` command with a format
string. One command, seven lines of output, each line showing the name and the type.

**5.** Now run `file` on the same seven. Put the `stat` wording and the `file` wording side by side
in a two-column table. Three of the seven are worded differently. Name them.

**6.** `types/void` is a character device. Read from it: `head -c 10 types/void | wc -c`. Report the
number. Explain what the device did with your read request.

**7.** Write something to `types/void` — `echo hello > types/void` — then read it back. Report both
results. What happened to "hello"?

**8.** Compare `ls -l /dev/null` with `ls -l types/void`. The names differ and one field is
identical. Name the field, give its value, and state what that identity means.

**9.** `types/pointer` is a symlink. Report its size in bytes from `ls -l`, then report the length of
the string it points at. Explain the relationship in one sentence.

**10.** Run `ls -l types/pointer` and `ls -lL types/pointer`. Both describe something. Say precisely
what each one describes, and account for every difference between the two lines — type character,
size, and the arrow.

**11.** `manifest/` holds seven files. Run `file` on all of them at once. For each, write the name,
what the extension suggests, and what `file` says. Mark the two where those disagree.

**12.** `manifest/empty` is zero bytes. What does `file` call it? What would you have predicted?
Explain why `empty` is a more useful answer than `ASCII text` would have been.

**13.** `manifest/latin1.txt` and `manifest/utf8.txt` both contain one accented character. `file`
gives them different answers. Report both answers, then use `od -c` (or `xxd`) on each to show the
bytes that caused the difference. State how many bytes each accented character occupies.

**14.** Run `file -i` on `manifest/survey.txt` and `manifest/panel.png`. Report the MIME types. State
one situation in which you would want `-i` rather than the default prose.

## Experiment

**15.** **Write your prediction down before running anything.** You are going to `cat` two things:
`types/pipeline` (a FIFO) and `types/control.sock` (a socket). Predict, for each, whether it
succeeds, fails, or does something else — and say what you expect to appear on screen.

Then run `cat types/control.sock`, record the exact error. Then run `cat types/pipeline` and wait
five seconds before pressing `Ctrl-C`. Record what happened.

Where your prediction was wrong, write down what you had assumed a "file" guarantees that these two
do not.

**16.** **Predict first.** `types/scratch-disk` is a block device. Try `head -c 10
types/scratch-disk`. Predict the outcome — success, empty, or an error, and which error. Run it.
Then run `stat -c '%s %b' types/scratch-disk` and `file -s types/scratch-disk`. Reconcile all three
outputs into one explanation of what a device node with nothing behind it actually is.

## Stretch

**17.** Using only the `test` builtin (`test -f`, `-d`, `-L`, `-p`, `-S`, `-b`, `-c`), write a
one-line `for` loop that prints each entry in `types/` followed by its type word. Your output should
match exercise 4's. Then say why exercise 4's single `stat` call is the better tool, in one sentence.

**18.** `sizes/four-k.txt` is 4096 bytes and `sizes/nothing.txt` is 0. Report `stat -c '%s %b %B'`
for both, and for `types/void`. Explain why one of these three has size 0 for a completely different
reason than the other one does.

**19.** `manifest/panelcheck` and `manifest/hull-log` are both executable-ish. `file` describes them
very differently. Report both, and explain the difference in terms of what is in the first two bytes
of each. Use `od -c | head -1` to show those bytes.

## Dig

**20.** `man 1 file` documents an option that stops `file` from following symbolic links, and
another that forces it to. Find both, and explain why `file` needs *two* options for this when there
is only one behaviour to toggle. (Read the paragraph about `POSIXLY_CORRECT`.)

**21.** `types/void` was created with `mknod`. Read `man 1 mknod` and answer: what would
`mknod x c 1 5` produce, and what is already on this system that it would duplicate? Do not run it —
you do not have the privileges, and that is exercise 22.

**22.** As `cadet`, try `mknod /labs/03-files-links-and-types/01-everything-is-a-file/mine c 1 3`.
Record the exact error. Then state, in one sentence, why the kernel restricts this operation
specifically, given what a device node with major 1 minor 3 lets its owner do.
