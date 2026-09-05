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

---

## Core — the seven types, drilled

**23.** Print all seven entries in `types/` with their type word, their permission string, and their
inode number, in one `stat` command. Report the two entries whose permission string begins with a
character that is not `-` or `d`, and say what each of those characters is.

**24.** `ls -l types` shows a **size** column for five entries and something else for two. Report
what appears in that column for `void` and `scratch-disk`, and say what the two numbers are.

**25.** Get the same two numbers out of `stat`. The format codes give them in hexadecimal. Report
`stat -c '%n %t %T' types/void types/scratch-disk` and convert `scratch-disk`'s to decimal by hand.
State why `stat` chose hex here when `ls` chose decimal.

**26.** `stat -c '%s' types/void` reports 0. So does `stat -c '%s' sizes/nothing.txt`. Explain, in
two sentences, why these two zeros mean entirely different things.

**27.** Report the link count (`%h`) of every entry in `types/`. Six are 1 and one is 2. Name the
one, and say what the second link is.

**28.** Run `file -h types/pointer` and `file -L types/pointer`. Report both. Then run `stat` and
`stat -L` on it and report the type and size from each. Line the four answers up and state the single
rule that predicts all of them.

**29.** Write the `test`-builtin loop from exercise 17 again, but this time have it print the entry
name and the *first* test that matched, in the order `-L -d -p -S -b -c -f`. Then swap `-L` to the end
of the order and re-run it. `pointer`'s answer changes — explain why, using exercise 28's rule.

---

## Core — `file` and the evidence it uses

**30.** Run `od -c … | head -1` on `manifest/hull-log`, `manifest/panelcheck` and
`manifest/survey.txt`. Report the first few bytes of each. For each, name the signature `file`
matched: the ELF magic, the shebang, and the gzip magic. Give the gzip one in octal as `od` printed
it.

**31.** Run `file -b` on all of `manifest`. Say what `-b` removed and give one concrete reason a
script would want it.

**32.** Run `file --mime-encoding manifest/*`. Report all seven answers. Three come back `binary` —
name them, and explain why `manifest/empty`, which contains no bytes at all, is one of them.

**33.** `manifest/latin1.txt` comes back `iso-8859-1` and `manifest/utf8.txt` comes back `utf-8`.
Show the deciding byte in each with `od -An -tx1 … | head -1`. State the rule that makes `0xe9`
standing alone impossible in UTF-8.

**34.** Run `file -z manifest/survey.txt`. Report the output and compare it to plain `file`. Say what
`-z` did, and what it would have cost you had the file been a 40 MB archive.

**35.** `manifest/panel.png` is ASCII text. Say what `file` would have needed to see in the first
eight bytes to call it a PNG, and state in one sentence why `file` ignoring the extension entirely is
the correct design rather than a limitation.

**36.** `file -s types/scratch-disk` reports `no read permission` rather than describing a device.
Report the exact output, and explain what `-s` was *trying* to do that plain `file` does not.

---

## Experiment — predict before you run

**37.** **Predict first, in writing.** Predict the result of each `test` on `types/pointer` and on
`types/void`: `-f`, `-L`, `-e`, `-c`. Then run all eight. Report which predictions were wrong.
`test -f types/pointer` is true — say what that proves about which of the two files `test` looked at.

**38.** **Predict first.** Predict what `wc -c < types/void` prints, and what
`head -c 10 types/void | wc -c` prints. Run both. Both are 0 — say what the character device did with
each request, and why "reads return end-of-file immediately" is a *behaviour*, not a size.

**39.** **Predict first.** Predict what happens to the byte count of `types/void` after
`echo hello > types/void`. Run it, then `wc -c < types/void` again. Explain where the six bytes went,
and name the one thing in the whole system that decided their fate.

**40.** **Predict first.** `ls -l /dev/null` and `ls -l types/void` show different owners and the same
major/minor pair. Predict whether writing to one could ever be observed through the other. Then run
`stat -c '%t %T' /dev/null types/void` and confirm the pair. Explain your answer in terms of what the
numbers select.

**41.** **Predict first.** Predict what `head -c 10 types/scratch-disk` does. Run it and quote the
exact error. It is not "No such device" and not "Input/output error" — say what it actually is and
what that tells you about where the refusal came from.

**42.** **Predict first.** Predict the output of `stat -c '%s %b %B' sizes/four-k.txt`,
`sizes/nothing.txt` and `types/void` before running. Run them. Report all three lines, and put the
three zeros that appear into two different categories.

---

## Stretch

**43.** `types/pointer` is 11 bytes and points at `regular.txt`, which is 11 characters. Copy the
symlink to your home directory with `cp -P` (which does not follow it) and confirm the copy is also
11 bytes. Then say what a symlink's "contents" are and where they are stored for a name this short.

**44.** Working entirely in your home directory — do not modify the lab — create a symlink to a name
that does not exist. Report what `ls -l`, `file`, `stat`, and `test -e` each say about it. State
which of the four told you most clearly that the target is missing.

**45.** Report `ls -F types` and account for the marker on every entry: `/`, `@`, `|`, `=`, and the
entries with none. Then say which type in this directory `-F` gives no marker for at all, and whether
that is a gap.

**46.** Run `od -c sizes/four-k.txt`. It prints three lines for a 4096-byte file. Report them, explain
the `*`, and name the option that would have printed all 256 lines instead. Then say what the final
line's number is and in which base.

**47.** Compare `stat -c '%F'` against `file` for all seven entries in `types/`. Build the two-column
table again and this time state, for each of the three that disagree, which tool's wording you would
put in a bug report and why.

---

## Dig

**48.** `file` reads its signatures from a compiled magic database. Find where it lives on this
system (`man 5 magic` names the path; `file -C` and the `MAGIC` variable are relevant). Report the
path and say what would happen to exercise 30's answers if the file were removed.

**49.** `man 2 stat` documents the `st_mode` field as holding both the permission bits and the file
type. Report `stat -c '%f'` for `types/void` and `types/regular.txt` — the raw mode in hex — and
identify which hex digits carry the type. Check your reading against `%A`.

**50.** A character device and a block device with the same major and minor are different devices.
Explain why, in terms of what the kernel does with the type character before it looks at the numbers.

**51.** `types/control.sock` exists as a name in the filesystem but nothing is listening on it.
Explain what `cat` actually failed to do — name the syscall — and why a socket file is the one type
here whose name is *only* a rendezvous point and never a channel.

**52.** State, in three sentences, what "everything is a file" actually claims. Your answer must
account for the fact that four of the seven entries in `types/` cannot be read with `cat`, and must
say what the seven do have in common — the answer is about the interface, not about storage.
