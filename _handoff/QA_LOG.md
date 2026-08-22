# QA_LOG.md — The user's decisions, verbatim

Preserved as written so a future agent can re-derive intent rather than trusting my paraphrase.

## Original brief (opening message, condensed to its requirements)

- "We need to create a course! This will be a fully interactive course… notes teaching concepts,
  and then proper exercises to do! Currently we will be learning linux."
- "The student / user has already done the boot.dev linux course. But it's not enough! The student
  needs more practice."
- Source: `/home/romeo/github/romeosarkar10x_hack/boot_dev_course_scraper/courses/learn-linux`
- "For checking of the assignments, we will ask the student / user to record a video of him/her
  solving the entire course. But we can also use AI agents to validate."
- "You can create a note for agents, on how to evaluate how an assignment can be validated. Also,
  you should have note for the user too to validate, but still having another agent validate would
  be outstanding."
- "It should be mostly the same concepts but with more exercies. You can also extra things for each
  thing."
- "There should also be a help file, which will have instructions for ai-agents on how to help the
  user if the user is stuck in a lesson."
- "Let's create the same hierarchy as the boot.dev course! We will have chapters and lessons. You
  are free to create whatever chapters and lessons you want."
- **"Just know that, the student only knows whatever was in the boot.dev course. So teaching new
  concepts should be in a systematic way."**
- **"For the instructions of the ai-agents, know that, the agents not simply tell the user the
  solution. It should guide the user towards the solution. It should ask questions to the user,
  etc. trying to understand what the user knows, etc. It should never tell the answer directly to
  the user!"**
- "Also, for the agent validation thing, it should be done properly."

## Q1 — Scope

> "Yes, actually option 1 is correct. We don't need to go to full sys-admin thing. We should more on
> understanding things like users, groups, processes, etc. Different kind of files, and another
> things. Basically, the user should be able to navigate through linux properly. You can also cover
> shell scripts, .bashrc or other related things, environment variables, etc. There should be lots
> of experiments, etc. It should be fun! We can also include ctf type challenges in certain cases,
> if possible. The user should get familiar with piping in shell, redirecting to files, and
> different things. And yes, about the package manager. So, the user will be given a oracle virtual
> machine with ubuntu running on it. So, there should be docs to guide the user to install things
> if required too!"

(Option 1 = drill + moderate extension: same 7 chapters re-taught with 4–8× more exercises, plus new
chapters on text processing, quoting/globbing, archives, job control, and shell scripting.)

## Q2 — Grading

> "Agent rubric only. Because things cannot be that deterministic. The agent can run history
> command, and others to to see what commands the user did, etc."

## Q3 — Sandbox

> "Yes I think the docker approach would be very cool! We are giving a vm to the user. We can first
> ask the user to setup docker in it, and then run docker containers, etc."

## Q4 — Teaching depth

> "Teach then stretch (Recommended)" — notes explain the concept fully, exercises graded easy-to-hard,
> last 1–2 per lesson require reading man pages for flags never shown in the notes.

## Q5 — Build order

> "Can you first produce a detailed table of contents first! write it in some file here"

## Q6 — Lesson size

> "Many exercises should be there. we can have upto 50 exercises. Let' the student practice hard!"

(Interpreted as up to ~50 exercises **per chapter**.)

## Q7 — Container model

> "One long-lived container, reset per lesson (Recommended)"

## Q8 — Scenario

> "Story-driven CTF world (Recommended)"

## Q9 — Handoff docs (this set)

> "Please summarize [everything] into a CONTEXT.md file. Put every import piece of information. I
> should be able to handoff this task to another agent. Also, mention whatever you have done till
> now in DONE.md file. You can also create TODO.md file. Create AGENT.md as the main entrypoint
> file, and link these other files there accordingly. Feel free to split the information in
> multiple markdown files! Again, add every single detail / decision taken. Don't miss anything!"

## Q10 — Filename standard (correction to Q9)

> "We should use AGENTS.md; Please use the standard filenames. I am sorry for guiding you incorrect
> here. Please search in the internet and use whatever the current standard is, so we don't have
> problems switching!"

Researched and applied: **`AGENTS.md`** at repo root is the current standard — open spec originated
by OpenAI with Google, Cursor and Factory (Aug 2025), donated to the Linux Foundation's Agentic AI
Foundation (Dec 2025), 60k+ repos and 20+ tools supporting it. Plain Markdown, no required fields;
nested `AGENTS.md` files give directory-scoped rules with nearest-wins precedence. Claude Code reads
`CLAUDE.md`, so `CLAUDE.md` is kept as a one-line pointer to `AGENTS.md`.

Sources:
- [AGENTS.md spec guide (2026)](https://www.morphllm.com/agents-md-guide)
- [How to Build Your AGENTS.md (2026) — Augment Code](https://www.augmentcode.com/guides/how-to-build-agents-md)
- [Best AGENTS.md examples and templates (2026)](https://promptessor.com/blog/best-agentsmd-examples-for-codex-cursor-and-ai-coding-agents-in-2026)

## Q11 — Richer challenges (mid-Phase-1)

> "You can add more things whatever you want. Maybe more exercises / challenges. Better CTF / story
> based / role play type challenges! Create interesting scenarios, etc."

Applied as: `_handoff/CHALLENGE_DESIGN.md` (Incident format, chained `STAGE{...}` CTFs, roleplay
scenes, flag-planting rules, the 16-chapter sabotage arc) and `docs/GAMEMASTER_PROTOCOL.md` (a third
agent mode where the agent plays a crew member — bound by the same never-give-the-answer rules).
Build rule 7 in `AGENTS.md` now makes this mandatory per chapter.
