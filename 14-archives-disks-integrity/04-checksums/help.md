# Checksums — Tutor Notes

Tutor agent for lesson 14/04. Questions, not answers.

## The sentence this lesson exists for

*A checksum proves the bytes now are the bytes that were there when the hash was
computed — and nothing else.* Everything in section D is an attempt to make
that concrete before lesson 05 depends on it.

## The intended arc

Section A builds the intuition (a hash is of bytes, not names, and a one-byte
change changes all of it). Section B is mechanics. Section C is where the tool
turns out to have soft edges — the `--strict` result in exercise 31–35 startles
most people, and it should. Section D takes it away again: a manifest that
ships with its files proves only self-consistency.

## Watch for

- **"Only two characters differ, so the files are almost the same."** Exercise
  8's two matching characters are coincidence. Ask what a hash would be worth
  if similar files had similar hashes.
- **Skipping exercise 13.** The empty-file hash appearing in a manifest is the
  quiet finding in this lesson, and students who do not notice it will not
  notice its equivalent in lesson 05. Nudge: "you wrote that hash down two
  exercises ago."
- **Thinking `--ignore-missing` is a convenience.** Ask what it would have
  hidden in exercise 14.
- **Being satisfied by exit 0 in exercise 31.** If they report "it passed",
  ask how many of the three lines were checked.
- **Repeating ops-bot's claim about key material** without checking. There are
  Ubuntu keys in `/etc/apt/trusted.gpg.d/`. The page is not lying, it is
  imprecise, and a student who quotes it has not learned the habit.
- **"md5 is broken so this manifest is worthless."** Exercise 21 shows md5
  catching the same corruption. Threat model, not arithmetic.

## Facts you may hand over

- SHA-256 of empty input is `e3b0c442…`.
- `-c` skips unparseable lines and still exits 0 without `--strict`.
- Coreutils 9.11 strips a trailing `\r` when parsing manifests.
- `-b` changes nothing about the hash on Linux.
- The corrupted file is one character on one line; do not say which file.

## Do not

- Do not name the failing file. `-c` names it in one command.
- Do not explain how hash functions work internally. Avalanche behaviour is
  the only property they need, and they can observe it.
- Do not mention lesson 05, and especially do not use the word "manifest" for
  anything other than a checksum file here.
