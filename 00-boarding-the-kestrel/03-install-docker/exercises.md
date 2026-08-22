# 00/03 — Exercises

All in the VM. Answers in `~/00-03-answers.md`.

---

## Warmup

**1.** Install Docker and run `sudo docker run hello-world`. Record the output.

*Done looks like:* the "Hello from Docker!" message in your answers file.

**2.** Add yourself to the `docker` group, log out, log back in, and run `docker run hello-world`
without `sudo`.

*Done looks like:* it works without `sudo`.

---

## Core

**3.** After running `hello-world` twice, list all containers including stopped ones, and list your
images. How many containers exist? How many images?

*Done looks like:* both counts, and one sentence explaining why the two numbers differ.

**4.** Read the `hello-world` output properly. It describes the four steps Docker took. Write them
out in your own words, and say which step would be skipped if you ran it a third time, and why.

*Done looks like:* four steps, plus the identified step with a reason.

**5.** Clean up: remove the stopped `hello-world` containers, then check that the image is still
there. Then find how much disk Docker is using in total.

*Done looks like:* `docker ps -a` shows no hello-world containers, `docker images` still lists the
image, and you have a disk figure.

---

## Experiment

**6.** **Predict in writing first.** You're about to run:

```bash
docker run --rm ubuntu:24.04 hostname
docker run --rm ubuntu:24.04 whoami
docker run --rm ubuntu:24.04 ps aux
```

Before running any of them, write down what you expect each to print, and specifically: will the
third one show the processes running in your VM? Justify each prediction with one sentence.

Then run them.

*Done looks like:* three predictions, three actual outputs, and a paragraph on the third one — what
it shows, what it doesn't, and what that tells you about namespaces. If your prediction was wrong,
say what you believed and what corrected it.

---

## Stretch

**7.** In 00/02 you recorded `hostname`, `whoami` and `df -h /` in the VM. Run the same three
inside a throwaway Ubuntu container and put the two sets side by side. Which values changed, which
didn't, and why?

*Done looks like:* a comparison table and an explanation. The `df` result is the interesting one —
think about where the container's filesystem physically lives.

---

## Dig

**8.** `docker run` has a flag that removes the container automatically when it exits (used above
without explanation), and another that gives you an interactive terminal.

Find both in the documentation, explain what each does, and then run an Ubuntu container that drops
you into a shell and disappears when you leave it.

*Done looks like:* both flags named and explained, plus the command you used. Say where you found
them.

> Technique: `docker run --help` is long. Pipe it into `less` and search with `/`. There is also a
> `docker help run`.
