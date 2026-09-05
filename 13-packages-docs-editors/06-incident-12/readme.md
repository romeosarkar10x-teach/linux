# Incident 12 — The Package Nobody Added

Deck 09 does not get signed off tonight until `deck-verify` has run against it.
`deck-verify` is not installed. `apt` can see it. That is a two-minute job.

It is not a two-minute job, because the officer on the previous shift ran
`apt-cache policy deck-verify`, saw a version number they did not recognise
coming from somewhere they did not put, and stopped. Their note is in
`notes/incident.txt`. Read it before you touch anything.

## What this lesson is

Everything in chapters 13's first five lessons, used at once and under time
pressure. `apt-cache policy` to see what is on offer and from where. The
`sources.list.d` directory to find out how it got on offer. `dpkg -I` to read a
package without installing it. `dpkg -s`, `apt-cache rdepends` and `dpkg -L` to
establish what an already-installed package actually is. And `apt install
package=version` to take the version you decided on rather than the one apt
picked for you.

## The two questions

They are different questions and they have different answers.

**Where is this version coming from?** `apt` does not invent packages. Every
candidate it offers comes from a source, and every source is configured in a
file. If a version you do not recognise is on offer, some file put it there,
and that file has a name and a modification time. Find the file. That is
evidence. Who wrote the file is not something the file can tell you.

**Is this other package suspicious?** A package with a name like
`libhatch-telemetry0` looks like something when you are already looking for
something. Before it becomes a finding, ask what depends on it, what it put on
disk, and what its own description says it is. Most packages on any machine got
there because something else needed them. That is the boring answer, and it is
usually the true one.

## The rule for tonight

**Establish provenance before you install.** Not after. Once a package is
unpacked its files are on your disk, and "I'll check afterwards" means checking
a system that has already changed. Reading a `.deb` costs you nothing:

```
dpkg -I file.deb        # control fields — who, what version, what it depends on
dpkg -c file.deb        # every path it would create
```

Neither of those installs anything.

## What apt gives you by default

`apt install deck-verify` installs the **candidate**, and by default the
candidate is the highest version available from any configured source. Higher
version wins, regardless of which source it came from and regardless of whether
anyone signed it. That is not a bug; it is what a version number is for. It is
also exactly why an unexpected source is worth caring about: adding one file
to `sources.list.d` is enough to change what a plain `apt install` gives you.

To take a specific version instead:

```
sudo apt install deck-verify=1.0.0
```

## Deliverable

Three lines, in this order, in a file:

1. the file that configured the source you did not expect
2. the version of `deck-verify` this station should be running
3. the package you were asked about that turned out to be an ordinary dependency

Then:

```
deck-verify --self-test
deck-verify --attest yourfile
```

`--self-test` refuses to run while the station is still in a state it does not
like, and tells you what it does not like. `--attest` checks your three lines
and then checks the station again. It will not produce an attestation for a
correct write-up on a station you have not actually put right.

## One thing you will not write down

Nothing in this incident requires you to name a person, and nothing in it
supports naming one. A file appeared. Its timestamp says when. That is the
whole of what the evidence says. A write-up that goes further than that is a
worse write-up, not a braver one — see `validation.md`.

## Files

- `notes/incident.txt` — the handover, and the three questions
- `notes/checklist.txt` — the commands, grouped by what they are for
- `notes/rhea.txt` — the deck officer, who wants deck 09 open by 22:00
- `notes/station-source.txt` — the station's own source, for comparison
- `repo-station/`, `repo-unknown/` — the two package sources on disk
