# 00/02 — Tutor hint ladder

Governed by [`docs/TUTOR_PROTOCOL.md`](../../docs/TUTOR_PROTOCOL.md). One rung per exchange.

Most failures here are environmental, not conceptual. Diagnose before laddering: ask which machine
they're typing on. Roughly half of Chapter 0 problems are "wrong shell".

### Exercise 1 — Guest Additions
- **L1 question:** Does the *window* resize, or does the *desktop inside it* resize? Which one are
  you seeing?
- **L2 locate:** Notes, "Guest Additions". Also VirtualBox menu → Devices.
- **L3 concept:** Guest Additions is a driver package installed inside the guest that lets the
  guest OS talk to the hypervisor. Without it the guest has no idea the window changed.
- **L4 decompose:** Did the install finish without errors? Did you reboot? Is the clipboard set to
  Bidirectional in the host menu?
- **L5 near-miss:** If clipboard is one-directional, it's a menu setting, not a package problem.
- **Never say:** the apt line; it's in the notes and they should find it there.

### Exercise 2 — hostname/whoami/df
- Mechanical. If stuck, they aren't in a terminal. Point at it.

### Exercise 3 — the canary
- **L1 question:** What does a snapshot capture — a moment, or a moment plus everything since?
- **L2 locate:** Notes, "Snapshots", the bullet about discarding.
- **L3 concept:** Restoring rewinds the disk to the snapshot instant. Different data: it's a save
  file in a game, not a backup folder — loading the save loses the last hour.
- **L4 decompose:** Create the file. Verify it exists. Restore. Look again.
- **L5 near-miss:** If they think the file should survive, ask them what "restore" would mean if it
  did.
- **Never say:** whether the canary survives. They must observe it.

### Exercise 4 — dynamic disk
- **L1 question:** Your VM says the disk is 40 GB. How much did your host's free space actually
  drop when you made it?
- **L2 locate:** VirtualBox → File → Virtual Media Manager; or `ls -lh` the `.vdi` on the host.
- **L3 concept:** Dynamic allocation grows on demand. Different data: a spreadsheet with a million
  empty rows is not a million rows' worth of bytes on disk.
- **L4 decompose:** Find the `.vdi` size on the host. Find used space in the VM. Compare.
- **L5 near-miss:** If they compared `.vdi` size to the *total* rather than the *used*, point at
  which `df` column they read.
- **Never say:** the explanation for the gap.

### Exercise 5 — recovery plan
- **L1 question:** If `sudo` stops working, what's still true about the machine?
- **L2 locate:** Notes, snapshot rules.
- **L3 concept:** Recovery has tiers: fix in place, restore snapshot, reinstall. Each costs more.
- **L4 decompose:** What breaks? What do you lose restoring? What would you save first?
- **L5 near-miss:** If their plan doesn't mention saving coursework first, ask what's in `/labs`.
- **Never say:** write the procedure for them.

### Exercise 6 — snapshot tree *(Experiment)*
- Ensure the prediction is written BEFORE they touch anything. If they've already done it, ask what
  they expected beforehand and take the honest answer.
- **L1 question:** Are snapshots a list, or a tree? What would each imply here?
- **L2 locate:** VirtualBox Snapshots pane — look at the indentation.
- **L3 concept:** Snapshots form a tree of states with a "current state" pointer. Restoring moves
  the pointer; it doesn't delete other branches.
- **L4 decompose:** Predict A. Do A. Predict B. Do B. Compare each separately.
- **L5 near-miss:** If they expected `docker-ready` to be destroyed by restoring its parent, ask
  what the pane still shows.
- **Never say:** the outcome before they've observed it.

### Exercise 7 — VBoxManage *(Dig)*
- **L1 question:** The GUI shows you a VM list and a snapshot tree. What would a CLI call those?
- **L2 locate:** Run `VBoxManage` with no arguments and search the usage output; or the VirtualBox
  manual's "VBoxManage" chapter.
- **L3 concept:** `VBoxManage <subcommand> [args]`. Different data: `VBoxManage showvminfo <name>`
  prints one VM's settings — same shape, different subcommand.
- **L4 decompose:** Find the subcommand that lists things. Find its argument for VMs. Then find the
  snapshot subcommand and its `list` action.
- **L5 near-miss:** If they have the right subcommand but wrong argument, say so and point at the
  usage line's alternatives.
- **Never say:** either full command.
