# 03/01 — Help

Five rungs. Climb one at a time. Stop as soon as the student is moving again.

---

## Exercise 3 — `ls -F` markers

- **L1.** Which entries in your `-F` output have no character after the name? Is that all of them,
  or a specific group?
- **L2.** Compare your `-F` output to your `-l` output from exercise 1, name by name.
- **L3.** In `/dev`, `ls -F null zero sda` decorates none of them. In `/etc`, `ls -F` puts `/` after
  every directory. What do the undecorated ones have in common?
- **L4.** Split it into two questions: (a) which of the seven types *did* get a marker, (b) does the
  set of markers `-F` uses have a member for the ones that did not?
- **L5.** `-F` has markers for directory, symlink, FIFO, socket and executable. There are seven
  types. Two of them are ___ and ___, and `-F` has nothing to say about either.
- **Never say:** "device nodes get no marker" as a bare fact. The student must read it off their own
  two listings.

## Exercise 6 / 7 — reading and writing `types/void`

- **L1.** What number did `wc -c` print? Is that "nothing was there" or "the read did not happen"?
- **L2.** Look again at the major and minor numbers `ls -l` prints for `types/void`.
- **L3.** `head -c 10 /dev/null | wc -c` prints `0` too. And `echo hi > /dev/null` succeeds, and then
  `/dev/null` is still empty. Does that pattern look familiar?
- **L4.** Two questions: (a) what does a read from this device return, (b) where do the bytes you
  wrote go? Answer them separately — they are two different behaviours of one driver.
- **L5.** The device with major 1 minor 3 discards every write and returns end-of-file on every
  read. You created a second one under a different name; the driver does not know or care what it is
  called.
- **Never say:** "it is /dev/null". That is the finding.

## Exercise 9 / 10 — symlink size and `-L`

- **L1.** How many characters are in the text after the arrow? How many bytes does `ls -l` report?
- **L2.** Run `stat types/pointer` and `stat -L types/pointer` and put them side by side.
- **L3.** A symlink to `/very/long/path/somewhere` has size 26. A symlink to `x` has size 1. What is
  the file *storing*?
- **L4.** For exercise 10, work one field at a time: does the type character change, does the size
  change, does the arrow appear? For each, ask which object that field belongs to.
- **L5.** A symlink's contents are the target path, as a string, and nothing else. `-L` makes the
  tool resolve the link and report the object at the other end instead of the link itself.
- **Never say:** the number 11, or that `regular.txt` is eleven characters.

## Exercise 15 — the FIFO that hangs

- **L1.** Before you run it: how many programs are involved when you `cat` a regular file? How many
  does a pipe need?
- **L2.** Re-read the readme's one-line description of type `p`.
- **L3.** `ls | wc -l` — the shell creates an anonymous pipe and starts *both* ends at once. What
  would happen if it started only `wc`?
- **L4.** Two questions: (a) what is `cat` waiting for, (b) is anything in the system going to
  provide it? Answer (b) by asking what else you have running.
- **L5.** Opening a FIFO for reading blocks until some process opens the same FIFO for writing. You
  have one terminal and one process. Lesson 5 gives you the second one.
- **Never say:** "it is waiting for a writer" before the student has sat through the hang.

## Exercise 16 — the block device that fails

- **L1.** Read your error message out loud. Is it about permission, or about existence, or about
  something else?
- **L2.** What do the two numbers in the `ls -l` size column mean? Which one selects the driver?
- **L3.** `/dev/sda1` on a machine with no second disk gives the same class of failure. The node
  exists; the file in `/dev` is fine.
- **L4.** Three separate questions: (a) does the file exist, (b) may you open it, (c) does the
  driver have a device behind it? Your three commands answer one each.
- **L5.** A device node is a *name for a driver plus an instance number*. Creating the name does not
  create the device. Nothing is attached at minor 200.
- **Never say:** what `mknod` did or did not attach.

## Exercise 22 — `mknod` as `cadet`

- **L1.** Read the error verbatim. Which of the two words is doing the work: "operation" or
  "permitted"?
- **L2.** You own the directory and can write to it. So the refusal is not about *this* directory.
- **L3.** `useradd` also fails for you, and for the same category of reason, though a different
  mechanism.
- **L4.** Ask: if you *could* run this command, what could you then read that you cannot read now?
  Think about what a block device node for the root disk would let you open.
- **L5.** A device node is an access route to a driver, and drivers see raw hardware. Creating one
  would let any user hand themselves a path to any device, bypassing the permissions on the real
  node in `/dev`.
- **Never say:** "it needs root" and stop. That names the rule, not the reason.
