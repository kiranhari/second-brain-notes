---
title: "PARA Use Cases Guide"
tags: [guide, para, use-cases, tiago-forte]
---

# PARA Use Cases Guide

*The PARA Method* describes one general-purpose system. This guide adapts it to five specific situations, layered on top of the core four categories rather than replacing them. Read only the section(s) that match what you're actually doing — each stands alone. Companion to [[Second Brain Use Cases Guide]] (from *Obsidian Second Brain*), which covers different personas with a Zettelkasten/note-taking lean; this guide stays closer to PARA's own organizing-for-action focus.

---

## 1. Solo indie developer (your own Gloss Local situation)

**What's different from the default:** almost everything is Project-shaped at first (build the thing), with Areas only emerging once something is stable and running rather than being actively built — exactly the Project→Area transition flagged repeatedly across the chapter notes for [[Gloss Local]].

### Structure adjustments
- `01-Projects/Gloss Local/` stays a Project for as long as there's a concrete, unfinished goal (per [[Chapter 6 - How to Distinguish between Projects and Areas]]'s two-part test) — don't rename it to an Area just because it's long-running; long-running and open-ended are not the same thing.
- The moment it's "stable and just running" rather than "actively being built," move it to a new Area — something like `02-Areas/Personal Software/` or `02-Areas/Home Lab/` (still an open decision per the MOC's running list).
- Keep build-decision logs (what you tried, what worked, what you reversed) as a Resource, not buried inside the Project folder — per [[Chapter 1 - Where It All Started]]'s notes (*Building a Second Brain*), this is the same move Forte made with his own medical records, just applied to software.

### What to apply from this book specifically
- [[Chapter 3 - The Sixty-Second PARA Setup Guide]]'s offline-mode tip matters literally here, not just as an Obsidian nicety — a local-first app benefits from the same "make active work available without a network connection" principle the book recommends for Project folders.
- [[Chapter 9 - Keep Information Flowing]]: expect architecture notes to migrate from Resource (general learning about local-first design) to Project (a specific decision for Gloss Local) and back — that's the system working as intended, not disorganization.
- [[Chapter 12 - The Three Core Habits of Organization]]'s "organize just in time" habit is the single most relevant one for a solo dev — don't pre-build an Area or folder structure for a feature that doesn't exist yet.

### What to skip
- [[Chapter 10 - Using PARA with a Team]]'s playbook/training apparatus — irrelevant solo, revisit only if Gloss Local gets a second contributor.

---

## 2. Freelancer / consultant juggling multiple clients

**What's different:** Projects multiply fast (one or more per client) and the Projects/Areas line gets genuinely harder to hold, since an ongoing client relationship is an Area but each piece of billable work for them is a Project.

### Structure adjustments
- `02-Areas/[Client Name]/` for the ongoing relationship (communication history, standing preferences, retainer terms) — no end date.
- `01-Projects/[Client Name] - [Specific Deliverable]/` for each discrete, billable piece of work with its own goal and deadline, nested conceptually under the client Area per [[Chapter 6 - How to Distinguish between Projects and Areas]]'s nesting pattern.
- Apply [[Chapter 11 - Creating a Project List]]'s "10 to 15" range per active client relationship, not just vault-wide — a freelancer easily blows past a single global cap.

### What to apply from this book specifically
- [[Chapter 8 - Extending PARA across Multiple Platforms]] matters a lot here — client-facing deliverables often live in the client's own tools (their Slack, their Drive), while your own tracking lives in your vault; replicate the same category names across both rather than inventing client-specific terminology.
- [[Chapter 5 - How to Maintain Your PARA System]]'s weekly ritual becomes higher-stakes: an unarchived finished client Project is a real risk (billing confusion, scope creep) not just vault clutter.

### What to skip
- Heavy use of [[Chapter 13 - Using PARA to Enhance Focus, Creativity, and Perspective]]'s "secluded workspace" framing during active client work — client work often requires rapid context-switching between Areas by design; the focus-tool framing applies more to your own internal/creative Projects.

---

## 3. Team lead / manager

**What's different:** this is the exact use case [[Chapter 10 - Using PARA with a Team]] was written for — lean on that chapter directly rather than improvising.

### Structure adjustments
- Build a "PARA Playbook" (the chapter's own term) before rolling anything out — a short, concrete doc defining what counts as a Project vs. an Area *for this specific team*, since the ambiguity is worse at team scale than solo.
- Keep genuinely shared material (team Areas, active cross-functional Projects) on shared platforms; leave individual Resources and personal Archives on each person's own system — don't force everything into one shared PARA instance.

### What to apply from this book specifically
- [[Chapter 10 - Using PARA with a Team]]'s warning against top-down mandates applies directly: don't require full PARA adoption by decree — train, scope deliberately, and let bottom-up usage prove the system before mandating it further.
- [[Chapter 9 - Keep Information Flowing]]'s migration logic gets a team dimension: who has permission to move something from a shared Area into Archive, and does that need a lighter-weight convention than individual use?

### What to skip
- Nothing from this book is irrelevant to this persona — it's the most directly-targeted use case in the whole text.

---

## 4. Personal life admin (non-work PARA)

**What's different:** Areas dominate over Projects — health, finances, home, relationships are mostly ongoing standards to maintain, not goals with deadlines, and the temptation to list them as Projects is exactly the failure mode the community research flagged repeatedly (see [[Chapter 1 - Introducing PARA]] and [[Chapter 6 - How to Distinguish between Projects and Areas]]).

### Structure adjustments
- Resist creating Projects for "Health," "Finances," "Home" directly — these are Areas. Projects nest underneath them: "Run a half marathon by June" under Health; "Save 3 months' expenses" under Finances; "Renovate the bathroom" under Home.
- Keep the Project List (per [[Chapter 11 - Creating a Project List]]) honest about the difference between a "dream" (no project attached yet) and a "hobby" (a project with no real goal attached) — both are fine, just name them correctly rather than inflating the Projects count.

### What to apply from this book specifically
- [[Chapter 13 - Using PARA to Enhance Focus, Creativity, and Perspective]]'s "time horizons" framing (Resources = long-term/years, Areas = medium-term/ongoing, Projects = short-term/weeks-months) is the most useful mental model for personal admin specifically, since it maps directly onto life-planning horizons people already think in.
- [[Chapter 14 - When in Doubt, Start Over]]'s "digital bankruptcy" permission matters more here than anywhere else — personal admin systems accumulate guilt (unfinished goals sitting visibly in a Projects list) faster than work systems do; the reset is a legitimate response to that, not giving up.

### What to skip
- [[Chapter 10 - Using PARA with a Team]] entirely, obviously, unless running shared household admin with a partner — in which case treat the household as the "team."

---

## 5. Content creator / writer

**What's different:** Resources (raw material, research, inspiration) vastly outnumber Projects, and the Resources→Project migration (per [[Chapter 9 - Keep Information Flowing]]) is the core daily mechanic rather than an occasional event.

### Structure adjustments
- `03-Resources/[Topic]/` as the primary home for ongoing research/inspiration capture — this is where the volume lives.
- `01-Projects/[Specific Piece]/` only created once a specific deliverable (an article, an episode, a book chapter) has a real deadline — resist creating a Project folder for "ideas I might write about someday," which is a Resource, not a Project, per the exact failure mode [[Chapter 2 - The Power of Organizing by Project]] and [[Chapter 6 - How to Distinguish between Projects and Areas]] both warn about.

### What to apply from this book specifically
- [[Chapter 13 - Using PARA to Enhance Focus, Creativity, and Perspective]]'s "curated raw-material pile" framing for creativity is the most directly relevant section in the whole book for this persona — Resources aren't just reference material, they're the deliberate seed-pile for new work.
- [[Chapter 9 - Keep Information Flowing]]'s migration logic is the actual daily workflow here: capture to Resources, promote to a Project the moment there's a real deadline, archive the Project (and any Resources that are now fully "used up") the moment it's published.

### What to skip
- Nothing structural — this persona maps closely to the book's own default framing (Forte himself is, among other things, a working writer).

---

## Related
- [[The PARA Method - MOC]]
- [[Second Brain Use Cases Guide]] (companion, from *Obsidian Second Brain*)
- [[Practical PARA Action Plan]]
- [[Where Does This Go - Quick Reference]]
