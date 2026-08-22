# Chapter 14 — story

**Chapter arc.** **Trace 14** — the proof, and the only artefact belonging to both hands. dorn's
handwritten manifest against an archive the adjustment produced. The failing files are exactly the
days the strain readings exceeded the clamp threshold; the student should be able to state that the
failing set is date-correlated without yet knowing what clamped it.

Roleplay: **the captain**, who gives the first plausible explanation for the discrepancy — a bad
export — does not lie, and is satisfied. The whole arc in miniature.

---

### `01-tar`
> Eleven years of station data lives in archives nobody has opened. You are going to open one, and
> the flag order matters more than it should.

### `02-compression`
> Reading a compressed file without decompressing it first is a small trick that turns "I need four
> gigabytes free" into "I have the answer."

### `03-disk-usage`
> The disk is full. `du` says it is not. Both tools are working correctly and one of them is
> counting something that no longer has a name.

Genuine Chapter 14 surprise — a deleted-but-open file — and deliberately *not* part of the incident.
It stays here so the incident has one answer instead of two.

### `04-checksums`
> A checksum proves a file has not changed since somebody computed the checksum. Read that sentence
> again, because it is a much weaker claim than the one people rely on.

The sentence the incident turns on.

### `05-incident-13` — the incident
> The archive checks out against its own checksum file. It does not check out against a manifest
> somebody wrote by hand at the time. Both cannot be right.

Verify in a scratch directory; the original is hashed before and after and must be bit-identical.
One manifest line has a genuine human typo, which tempts students into dismissing the whole document.
