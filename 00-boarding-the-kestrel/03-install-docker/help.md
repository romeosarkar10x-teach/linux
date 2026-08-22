# 00/03 — Tutor hint ladder

Governed by [`docs/TUTOR_PROTOCOL.md`](../../docs/TUTOR_PROTOCOL.md). One rung per exchange.

Diagnose first: which machine are they on, and did they actually log out?

### Exercise 1 — install
- **L1 question:** What did the failing command print, exactly? (Get the real text.)
- **L2 locate:** Notes, "Installing". Also `docs/INSTALL_GUIDE.md` troubleshooting.
- **L3 concept:** The install is: prerequisites → key → repository → index refresh → install. A
  failure at any stage has a distinct signature — a key error looks nothing like a DNS error.
- **L4 decompose:** Does `curl -I https://download.docker.com` work? Does the keyring file exist?
  Does `apt update` mention docker.list? Then install.
- **L5 near-miss:** If `apt update` warns about a missing key, the `signed-by=` path and the actual
  file don't match — compare the two strings character by character.
- **Never say:** retype the command block for them; it's already in the notes.

### Exercise 2 — the docker group
- **L1 question:** Run `id`. Is `docker` in the list?
- **L2 locate:** Notes, "Getting rid of `sudo`", specifically the paragraph on why a new terminal
  isn't enough.
- **L3 concept:** Credentials are copied into a process at creation and never re-read. Different
  data: a printed guest list at a door — adding a name to the master list doesn't change the copy
  the doorman is holding.
- **L4 decompose:** Run `id`. Open a new terminal, run `id` again. Log out fully. Run `id` again.
- **L5 near-miss:** If they opened a new terminal and expected a change, ask whether that terminal
  is a new *login session* or a child of the old one.
- **Never say:** just tell them to log out — make them see it in `id` first. That observation is
  the exercise.

### Exercise 3 — counts
- **L1 question:** Does a container disappear when the program inside it exits?
- **L2 locate:** `docker ps` vs `docker ps -a` — run both and compare.
- **L3 concept:** Images are templates; containers are instances. Different data: one Ubuntu image
  can back fifty containers.
- **L4 decompose:** Count containers. Count images. Ask which one you created twice.
- **L5 near-miss:** If they got 1 container, they ran `docker ps` without `-a`.
- **Never say:** the numbers.

### Exercise 4 — the four steps
- **L1 question:** Where did the image come from the first time, and would it need to come from
  there again?
- **L2 locate:** The `hello-world` output itself — read it line by line.
- **L3 concept:** Docker caches images locally. Different data: `docker pull ubuntu:24.04` twice —
  watch what the second one says.
- **L4 decompose:** List the four steps. Then ask which involves the network.
- **L5 near-miss:** If they name a step that isn't in the output, send them back to the text.
- **Never say:** the four steps.

### Exercise 5 — cleanup
- **L1 question:** What identifies a container so you can remove a specific one?
- **L2 locate:** `docker ps -a` output columns; `docker rm --help`.
- **L3 concept:** Removing a container doesn't remove its image; that's `docker rmi`. Different
  data: deleting a document doesn't uninstall the word processor.
- **L4 decompose:** Get the IDs. Remove them. Verify with `ps -a`. Then check `images`.
- **L5 near-miss:** If `rm` complains the container is running, ask what state it's in.
- **Never say:** the `docker system df` command name if they haven't found it — point at
  `docker system --help`.

### Exercise 6 — namespaces *(Experiment)*
- Prediction must be written BEFORE running. Verify that first.
- **L1 question:** If a container is "just processes on the host kernel", why wouldn't it see the
  host's other processes?
- **L2 locate:** Notes, "What a container actually is", the namespaces bullet.
- **L3 concept:** Each namespace type is an independent blindfold. Different data: `docker run --rm
  --pid=host ubuntu:24.04 ps aux` shows what happens when you remove one — worth trying *after*
  they've predicted.
- **L4 decompose:** Predict each of the three separately, with a reason each. Then run each.
- **L5 near-miss:** If they expected to see the VM's processes, ask which namespace would have to
  be shared for that, and whether it is by default.
- **Never say:** the outputs.

### Exercise 7 — comparison *(Stretch)*
- **L1 question:** Which of the three values is a property of the *kernel*, and which of the
  *namespace*?
- **L2 locate:** Their own 00/02 answers; notes on namespaces.
- **L3 concept:** `df` reports the mount namespace's view; the bytes still live on the VM's disk.
- **L4 decompose:** Run all three. Tabulate. Explain each row separately.
- **L5 near-miss:** If they're surprised the disk sizes match, ask where the container's files are
  physically stored.
- **Never say:** the explanation for `df`.

### Exercise 8 — run flags *(Dig)*
- **L1 question:** In exercise 6 you used a flag without being told what it does. Which one?
- **L2 locate:** `docker run --help`, piped into `less`, search for `remove` and for `tty`.
- **L3 concept:** Interactive shells need two things: stdin kept open, and a pseudo-terminal
  allocated. They're separate flags for a reason. Different data: `docker exec` takes the same two.
- **L4 decompose:** Find the auto-remove flag. Find the interactive flags. Then combine with a
  shell as the command.
- **L5 near-miss:** If their container exits immediately, they have one of the two interactive
  flags, not both.
- **Never say:** the flag letters.
