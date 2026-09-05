# Where the space went — Solutions

Measured on the station. coreutils 9.11. **`df` numbers move**: the volume is
shared with the host, so sizes and percentages will differ from the ones here.
The `du` numbers under `bay/` will not.

## A. df

1. `/dev/nvme2n1p2`, mounted on `/labs`. Free space was 70G at 80% used when
   this was written.
2. Five or so, including `overlay` on `/`, `tmpfs` on `/dev`, `shm` on
   `/dev/shm`, and a couple of `/proc` mounts.
3. 64M, 0% used.
4. They are different filesystems. `/dev/shm` is a tmpfs living in memory;
   `/labs` is on a disk. A path belongs to exactly one filesystem and `df`
   reports that one.
5. 1K blocks — the header says `1K-blocks`.
6. The `Filesystem` and `Mounted on` columns are still there because I asked
   for them; `--output` lets you drop `Used` or `Avail` or pick an order.
   Without it you take the default set.
7. About 2.6 million of 23.9 million, 11%.
8. No. Every new file needs an inode and there are none left, regardless of
   free bytes. The error is `No space left on device`, which is misleading.
9. Same numbers. `bay/media` is on the same filesystem as `/labs`; `df` reports
   the filesystem, not the directory.
10. Reserved blocks — ext4 keeps a percentage (5% by default) for root, so that
    a full disk does not stop root from logging in and fixing it. Ordinary
    users see it as missing.

## B. du

11. **5.0M**.
12. ```
    56K   bay/old-logs
    204K  bay/exports
    292K  bay/telemetry
    1.6M  bay/empty-run
    2.9M  bay/media
    ```
13. `bay/media`, at 2.9M — roughly twice `bay/empty-run`'s 1.6M.
14. `deck-09`, 184K against 52K for each of the others.
15. `du -a bay/telemetry/deck-09 | sort -rn | head` puts
    `bay/telemetry/deck-09/2187-06.log` at 136K on top; every other month is
    4K.
16. `bay` itself, at 5104. `du -a` still prints directory totals; only the
    lines beneath it are files.
17. `du -sh bay/*` omits the total for `bay` itself; `--max-depth=1` includes
    it as the last line. The glob also skips dotfiles, which `du` does not.
18. The second is faster because the kernel has the directory metadata cached.
    That says nothing about the numbers being stale — but the tree can change
    under you, so a `du` from an hour ago is a description of an hour ago.
19. 1K blocks. `du -s --block-size=1 bay/media` → 3006464 bytes; plain
    `du -s bay/media` → 2936.
20. 1.6M, from 400 files each holding under 10 bytes. Size on disk is rounded
    up to a whole block per file.

## C. Blocks, holes and links

21. 1.6M actual, **3.1K** apparent.
22. The 1.6M. Those blocks are allocated and no other file can use them.
23. 1.6M / 400 = 4096 bytes — the filesystem block size. Every file, however
    small, takes at least one.
24. Nothing. Each file goes from ~8 to ~16 bytes, still inside one 4 KB block.
    Disk usage is unchanged until a file crosses 4096.
25. `ls -lh` says **4.8M**; `du -h` says **0**.
26. The file is sparse: its length was set by seeking past the end, so the
    filesystem recorded a hole rather than allocating blocks for bytes nobody
    wrote.
27. `du --apparent-size` reports 4.8M and agrees with `ls`. Plain `du` reports
    what the filesystem allocated.
28. Still sparse — `cp` defaults to `--sparse=auto` and detects the holes; the
    copy is 0. `cp --sparse=never` writes every zero out and produces a 4.8M
    copy. That is how a "small" file becomes a large one by being copied wrong.
29. The link count. It is **3** for all three names: one inode, three names.
30. **One** line. `du` counts an inode the first time it sees it and stays
    silent for the rest, which is why the other two names print nothing.
31. `du -ch` → 52K total. `du -ch --count-links` → 156K total.
32. 52K. Deleting two of the three names frees nothing at all; the bytes go
    when the last name goes.
33. 3 — the number of hard links to the inode.
34. 56K vs 160K. The default is the honest answer for "space on disk"; the
    `--count-links` figure counts the same 52K three times.
35. No — the second tree's `du` would report 0 for the shared inode only if
    `du` saw it in the same run. Total two trees with a single command:
    `du -ch dir1 dir2 | tail -1`, so one process tracks the inodes it has
    already counted.

## D. ncdu and the gap

36. `dpkg -s ncdu` → `package 'ncdu' is not installed`. `command -v ncdu`
    prints nothing, but that answers a different question — it only tells you
    what is on `PATH`.
37. `apt-cache policy ncdu` → candidate **1.19-0.1**, from
    `noble/universe` on the snapshot mirror. Note `universe`, not `main`.
38. `sudo apt-get install -y ncdu`
39. Arrow keys or `j`/`k` to move, Enter or `l`/right to descend, `..` at the
    top of the listing or left arrow to go up. `q` quits.
40. It deletes on a single keystroke with one confirmation, from a listing you
    are navigating fast, with no path typed out. `rm` makes you name the file,
    and naming it is most of the safety.
41. `sudo apt-get purge -y ncdu`; `dpkg -s ncdu` reports not installed again.
42. 0, 0% of 64M.
43. Used jumps to 20M, 32%.
44. Yes — `du -sh /dev/shm` reports 20M. The file has a name and `du` can walk
    to it.
45. Gone. `ls /dev/shm` is empty.
46. **No.** Still 20M used.
47. **0.** `du` walks names, and the file no longer has one. It is not wrong;
    it cannot see the file at all.
48. NLINK is **0**, and NAME reads
    `/dev/shm/ghost.bin (deleted)`. That is exactly what `+L1` selects for:
    open files with fewer than one link.
49. `/dev/shm/ghost.bin (deleted)` — the kernel remembers the path the
    descriptor was opened on and marks it.
50. Back to 0. Closing the last descriptor released the blocks. Nothing was
    deleted at that moment; the deletion had already happened, and this was the
    filesystem finally acting on it.

## E. Judgement

51. `df -h` on the full filesystem to confirm which one it is, then
    `lsof +L1 <mountpoint>`. The `du` total was already the clue; do not spend
    more time on `du`.
52. `rm` removes the name. The service keeps its descriptor and keeps writing
    to a file that now has no name, so no space comes back, the log stops being
    readable, and the space is only freed when the service restarts. Truncating
    it — `: > /var/log/thing.log` — frees the space and keeps the descriptor
    valid.
53. Truncate it through its descriptor:
    `: > /proc/<pid>/fd/<n>`. The space comes back immediately and the process
    keeps running. The cost is that the contents are gone, and a process
    writing at an offset (rather than appending) will leave a sparse hole.
54. It walks every inode on the machine, which is slow and evicts useful cache.
    Run `du -h --max-depth=1 /` and descend into whichever child is large.
55. A large deleted-but-open file, a sparse file, or hard links across two
    measured trees. In all three `df` and `du` are each answering their own
    question correctly.
56. "Check `lsof +L1` before you check anything else — a file with no name
    still takes space, and `du` cannot see it."
