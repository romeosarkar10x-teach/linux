# Chapter 4 — story

**Chapter arc.** A manifest for a tree that no longer exists. **Trace 4** — dorn wrote down what he
copied on 2187-05-17; somebody wiped the source a week later. The manifest outlived it.

---

### `01-cat-and-friends`
> Most of what you will do on this station is read a file somebody else wrote at four in the
> morning. There are better ways to do that than opening it and scrolling.

### `02-touch-mkdir`
> You are about to rebuild a directory tree from a piece of paper. Forty `mkdir` calls is one way.
> It is not the way anybody does it twice.

### `03-cp-mv`
> Copying is not moving and neither of them is what the trailing slash makes you think. This is
> where most people's first destructive mistake happens.

### `04-rm-safely`
> `rm` has no undo, no confirmation you can rely on, and a folklore problem. Everything here lives
> in a lab directory and `kestrel reset` puts it back, so make the mistake now.

### `05-incident-04` — the incident
> There is a manifest. There is no tree. Rebuild what the manifest describes.

Brace expansion and `mkdir -p`, not forty `mkdir` calls — the validator counts. The `.bak` manifest
is older and disagrees; students who trust it rebuild the wrong tree.
