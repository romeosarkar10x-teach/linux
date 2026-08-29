# 10/08 — Validation rubric

For the validator agent. No script grades this lesson. Judge the written answers and the lab state.

## Non-negotiable

1. **Real uid versus effective uid**, stated as two separate things, with the effective one named as
   what the kernel checks at `open()`. Exercises 12, 15. "It runs as root" without the mechanism does
   not pass.

2. **What setuid actually confers**: the owner's access applied to whatever the program is asked to
   do. Exercises 45, 62. A student who describes `bin/summarise-hash` as "a backdoor" or "gives root"
   has not read it — it gives *dorn*, and that is both narrower than they said and still the finding.

3. **`chown` clears setuid, and why it must.** Exercises 18, 19, 20, including the correct install
   order.

4. **Setuid is ignored on `#!` scripts.** Exercises 21, 22, with the sudoers line as the real-world
   answer.

5. **The five special-bit objects, correctly classified.** Exercise 29. `shared` and `shared/plans`
   and `dropbox` correct as they stand; `bin/summarise-hash` the finding; `bin/readas` a
   demonstration that would also be a finding on a real station. A student who reports the setgid
   directory as a hole, or who *changed* it and left it changed, has failed the audit.

6. **First match wins, applied to a file they own.** Exercise 46, and exercise 48's explanation of why
   `sudo -u rhea` failed where `sudo -u nobody` worked. This is the chapter's core rule reappearing
   where it hurts.

7. **A group is not a login.** Exercises 51, 52: the process group list is fixed at process creation.

8. **The fix is `chmod u-s`, or `rm` defended.** Exercise 64, 65. Any answer that "fixes" it by
   restricting the group, by moving the file, or by chowning it to cadet has not closed the hole —
   ask what a `chmod` puts back.

## Should be present

- Capital `S`/`T` means the special bit is set without the execute bit under it (7, 8, 9).
- `-perm -N`, `-perm /N` and `-perm N` distinguished precisely (23, 25, 26).
- `find` cannot descend into `dropbox` because listing and writing are different permissions (28).
- Setuid root is normal and necessary — `passwd` and `/etc/shadow`'s mode (30, 31, 32).
- Sticky described from the two `rm` results rather than from the notes (38, 39, 40).
- Setgid directory inheritance, including that new subdirectories inherit the bit (56, 58).
- `usermod -G` without `-a` would have cost them `sudo` (53).
- The access given back: `gpasswd -d cadet engineering`, with the reason stated as accountability
  rather than trust (66).

## The flag and stages

Four `STAGE{...}` receipts and one `KESTREL{...}`. The stage tokens do not register; a student who
tried to submit one has misread the readme, which is minor. The flag registers as `10/08`.

`grep -r KESTREL .` must not have found it, and cannot: the file is `0600 dorn:dorn`. A student who
claims to have grepped it out has either used the helper (fine, that is stage 4) or `sudo` (which
answers a different question — ask them which).

## The lab rule

**Exercise 68 is the enforcement.** They must say what they read while they had engineering. The
defensible list is `archive/README`, `stage3.txt`, `cycle-41.hash`, and — through the helper, as the
demonstration — a file of dorn's own. Anything of rhea's, cass's or the captain's read through the
setuid helper breaks the rule the readme states, and should be marked as such even though nothing
stopped them.

## The integrity check — exercise 69

The evidence is a mode, an owner, an mtime of **2187-05-18**, and one file recording two
disagreeing hashes. It supports: a setuid helper granting dorn's read access, disabled. It does not
support a motive, an author, an accusation, or a story about what the hashes mean. A student who
writes one has failed this exercise however clean the rest of the sheet is — same standard as 10/04
exercise 39, and this is the harder instance because the artefact really is deliberate.

## Lab state

```
ls -l bin/summarise-hash      # -rwxr-x--- dorn engineering, mtime May 18 2187  (u-s applied)
stat -c '%a %U:%G' shared     # 2775 root:engineering                           (untouched)
stat -c '%a %U:%G' dropbox    # 1733 root:crew                                  (untouched)
stat -c '%a' audit/stage2.txt # 4                                               (unchanged)
id cadet | grep -c engineering  # 0, if they gave the grant back
```

`bin/readas` may legitimately be `u-s` as well — credit a student who disabled it and said why.
`shared` at anything other than `2775`, or `dropbox` without its sticky bit, is a failed audit and
should be reseeded before chapter 11.

## The failure that looks like success

Flag submitted in fifteen minutes, every stage clean, and a report saying "found and removed a
malicious setuid backdoor left by the previous engineer". Three of those words are unsupported. Probe
with exercise 69 and with "what could it do that a shell could not?" — a student who cannot answer the
second one found the flag without ever understanding the file.
