# Checksums — Validation Rubric

Agent rubric only.

## Pass requires all of

1. **States what a checksum proves,** in a form equivalent to: the bytes now
   are the bytes present when the hash was computed. Any answer implying it
   proves origin, authorship, timeliness or correctness fails.
2. **Identified all three outcomes** of `sha256sum -c SHA256SUMS`: six OK, one
   FAILED (`strain-2187-05.log`), one FAILED-open-or-read
   (`strain-2187-07.log`) — and can say why the last two are different kinds of
   problem.
3. **Found the empty-file hash** in the manifest (ex 12–13) and can say what it
   implies: the manifest records a zero-byte file as correct.
4. **`--strict`.** They ran exercises 31–33 and can state that an unparseable
   line is skipped and exits 0 by default. A student who has not internalised
   this fails — it is the lesson's sharpest edge.
5. **Self-consistency (ex 38–39).** They altered a file, regenerated the
   manifest, watched it pass, and can say that a co-shipped manifest proves
   nothing about provenance.
6. **The blind spot (ex 43–44).** A file in neither the directory nor the
   manifest produces no output at all.
7. **Checked for key material rather than quoting ops-bot.** Full credit
   requires noting `/etc/apt/trusted.gpg.d/` exists and that `gpg` does not.

## Fail on any of

- "md5 is broken, so the MD5SUMS result is meaningless." It caught the
  corruption.
- Claiming CRLF manifests always fail. They pass here; the honest answer is
  tool-dependent.
- Claiming similar files produce similar hashes.
- Any modification to `dist/` or `copies/`.
- Reporting a passing `-c` as evidence the export is correct.

## Partial credit

49–56 are judgement. Ex 52 has several right answers; accept any that names
something cheap to compute and is honest about what it misses. Ex 53 must
acknowledge that "broken" depends on the threat model, whichever side they
argue.

## Closing note to the student

Ask them to say, without looking, the difference between `FAILED` and
`FAILED open or read`. If they can, they are ready for the next lesson.
