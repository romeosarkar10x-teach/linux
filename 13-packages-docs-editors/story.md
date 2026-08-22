# Chapter 13 — story

**Chapter arc.** **Trace 13** — a package from a repository nobody added. dorn needed an
archive-diff tool the station image does not ship, added the repo himself on 2187-05-16, and left it
configured because he expected to be back on Monday.

Roleplay: **rhea**, who wants a tool installed station-wide and considers supply-chain caution
pedantry.

---

### `01-apt`
> Installing software is easy. Knowing what you installed, where it came from, and how to take it
> off again is the part that separates a sysadmin from somebody with a keyboard.

### `02-dpkg-and-repos`
> Every package on this station came from somewhere that a file says is trustworthy. Somebody edited
> that file three weeks ago.

The chapter's most direct arc reference. It is a statement of fact and goes no further.

### `03-man-pages`
> The answer is on this machine. It has been on every machine you have ever used. This is the lesson
> where you stop needing anybody else for it.

### `04-installing-tools`
> The image you are running was built deliberately short of a few tools, on the grounds that
> installing them yourself is the lesson.

### `05-editors`
> Two editors, one of which you will meet on every machine you ever touch, whether or not you like
> it. Learn enough to leave.

### `06-incident-12` — the incident
> A tool you need is not installed. Also, something on this station is installed that did not come
> from anywhere the station configures.

Find where the stray package came from *before* installing anything, so the "before" state is
recorded. The exotic-looking package is an ordinary dependency.
