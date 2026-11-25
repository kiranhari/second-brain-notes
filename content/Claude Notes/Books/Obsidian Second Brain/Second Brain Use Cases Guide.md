---
title: "Second Brain Use Cases Guide"
tags: [guide, obsidian, second-brain, use-cases]
---
# Second Brain Use Cases Guide

The book and the chapter notes in [[Obsidian Second Brain - MOC]] describe one general-purpose system. This guide adapts that same system — PARA + Zettelkasten + the daily/weekly/monthly loops — to six specific situations. Nothing here replaces the core system; each section is a set of adjustments, additions, and things to skip, layered on top of what's already built in this vault.

Read only the section(s) that match what you're actually trying to do. They're written to stand alone.

---

## 1. Student / Lifelong Learner

**What's different from the default system:** the Resources side of PARA dominates; there's rarely a real "Area" (you're not managing an ongoing responsibility, you're accumulating knowledge), and semesters/courses act as time-boxed Projects.

### Structure adjustments
- `01-Projects/` → one subfolder per course or certification with a real end date: `Linear Algebra - Fall 2026/`, not `Math` (too open-ended — that's a Resource).
- `03-Resources/` → one subfolder per subject area that outlives any single course: `Mathematics/`, `Economics/` — this is where permanent notes about concepts actually live, separate from the course logistics.
- Add `03-Resources/Exam Prep/` as a staging area during exam season — move/copy relevant permanent notes here temporarily rather than restructuring the whole vault.

### Note types specific to this use case
- **Lecture note** (a fleeting→literature note, captured live): date, course, topic, key points, and — critically — a "Questions I still have" section, processed during the weekly review the same way book captures are processed.
- **Concept note** (a permanent note, per [[Chapter 4 - The Zettelkasten Method]]'s formula): one concept, your own explanation, at least one worked example, linked to the course AND to the subject-area Resource folder.
- A **Spaced Repetition Dashboard**: since exam performance depends on repeated review, not just capture, add a Bases/Dataview view filtering concept notes by `last-reviewed` date, oldest first — review the top of the list each study session. This is a genuine gap in the book's own system (built for knowledge workers, not test-takers) worth adding deliberately.

### Rhythm adjustments
- Daily loop: same as default, but the evening reflection's "what should I do differently tomorrow" doubles as a study-gap tracker.
- Weekly review: add a fifth movement specific to students — "which concept notes haven't been touched in 2+ weeks?" (feeds the spaced-repetition dashboard above).
- Skip the Project Dashboard entirely during school breaks — there's nothing active to track.

### What to skip from the default system
- The n8n/CRM automation in [[Chapter 7 - Run Your Projects Inside Obsidian]] — irrelevant, no external systems to sync from.
- Heavy AI chat reliance (Ch.8) during actual exam study — the book's own warning (writing is the learning) applies with extra force here: summarizing a textbook with AI instead of writing your own concept notes defeats the actual purpose of studying.

---

## 2. Researcher / Academic Writer

**What's different:** this is the use case the book's Zettelkasten chapter is most directly built for (Luhmann was an academic) — lean into it fully rather than adapting it.

### Structure adjustments
- `03-Resources/Literature/` — one literature note per paper/book, using a stricter version of the book's Article/Book templates with a full citation field (not just a URL).
- `03-Resources/Ideas/` (already exists in this vault from Ch.4) becomes the actual slip-box — this is where the bulk of your vault's value accumulates over years, not in any single folder.
- `01-Projects/[Paper or Grant Title]/` — one per concrete output with a submission deadline.

### Note types specific to this use case
- **Literature note**, strict version: source, one-paragraph summary in your own words, 3-5 direct quotes (with page numbers, kept separate from your synthesis so you never accidentally plagiarize your own paraphrase), and a "why this matters to my work" line.
- **Permanent notes should visibly accumulate into MOCs faster here than any other use case** — if you're not creating a new MOC roughly every 15-20 permanent notes in a given area, your notes may be too scattered or too similar to be building real structure.
- A **Citation Dashboard** (Bases, frontmatter-only, matches this vault's Bases-first approach from [[Bases vs Dataview - 2026 Decision Notes]]): table of every literature note, filterable by `status: to-read / reading / cited`.

### Rhythm adjustments
- The "one permanent note per week" pace from Ch.4 is a floor, not a target, for active researchers — during a literature review phase, expect several permanent notes per week as you process papers.
- Monthly review's "what did I learn" question is the single most valuable use of this chapter for a researcher — it's effectively a running record of your own intellectual development, useful for grant reports and tenure files years later.

### What to skip
- Project Dashboard's `Client` field — irrelevant unless grant-funded with external stakeholders; drop or repurpose as `Funder`.
- The book's business-oriented Chapter 7 framing (CRM, client management) — swap mentally for "grant/journal submission," the underlying mechanics (status field, decisions log) transfer directly.

---

## 3. Project Manager / Knowledge Worker

**What's different:** this is the book's own default framing (Chapter 7 especially) — the main adaptation is *scale*: multiple concurrent projects, often with real stakeholders, not a solo hobby project.

### Structure adjustments
- Use `01-Projects/[Project]/` exactly as built in this vault's `Gloss Local` and `Second Brain Build-Out` folders — but at higher volume, be stricter about archiving. The book's "Mistake 3: Never archiving" (Ch.2) is the single most common real-world failure at this scale.
- Add a `02-Areas/Direct Reports/[Name]/` subfolder per person if you manage people — the book mentions this directly as an Areas example.
- Consider a `03-Resources/Stakeholders/` folder for recurring external contacts (clients, vendors) separate from your own team.

### Note types specific to this use case
- Lean hard on the **Decisions Made** section in every project note — at this scale, "why did we choose X" questions six months later are frequent and expensive to re-litigate without a written record.
- A genuinely useful addition the book doesn't build: a **Stakeholder Dashboard** — a Bases table over `03-Resources/Stakeholders/` filtered by `last-contact` date, surfacing anyone you haven't touched base with recently.

### Rhythm adjustments
- The weekly review's Movement 2 (Project Dashboard check) is the one that matters most at this scale — do not skip it even on busy weeks, since it's the only thing preventing silent project drift across a large portfolio.
- Consider a lightweight **daily** project-dashboard glance (not just weekly) if you're managing more than ~5 concurrent active projects.

### What to skip / be cautious about
- Per [[Chapter 7 - Run Your Projects Inside Obsidian]]'s own community research: if "projects" means *shared with a team*, Obsidian/Bases/Dataview has a real, documented ceiling — teammates can't easily co-edit a Dataview/Bases dashboard the way they could a Notion board. Know going in that this system is for *your* view of the projects, not a team's shared source of truth, unless everyone on the team is comfortable in a personal Obsidian vault too (uncommon).

---

## 4. Writer / Content Creator

**What's different:** the vault becomes a production pipeline (draft → publish) in addition to a thinking tool, covered briefly in [[Chapter 9 - Advanced Obsidian Tips and Customization]] but worth expanding.

### Structure adjustments
- A `Writing/` folder at vault root (same PARA exception pattern as `Dashboards/` — a legitimate cross-cutting utility, not a Project/Area/Resource):
  ```
  Writing/
    Drafts/
    Published/
    Research/        ← links out to 03-Resources permanent notes that fed each piece
  ```
- Each manuscript/article is its own note (or folder of chapter-notes for longer works, per Ch.9's book-manuscript structure).

### Note types specific to this use case
- A **Piece Note**: working title, target outlet/length, status (`idea / drafting / editing / published`), and a "Source Notes" section linking back to every permanent note the piece draws on — this is the direct payoff of having built a Zettelkasten in the first place: a new article often assembles itself from existing permanent notes rather than starting from a blank page.
- Use the **Pandoc + Pandoc Plugin** workflow (Ch.9) for anything that needs to leave the vault as a `.docx` for an editor.

### Rhythm adjustments
- Add a "what did I write and what's blocking the next piece" line to the weekly review — distinct from the default review's project-status focus.
- The monthly review's Start/Stop/Continue is especially suited to deciding which half-finished drafts in `Writing/Drafts/` to actually kill versus keep alive.

### What to skip
- Heavy plugin stacking (Tasks/Dataview dashboards) is less valuable here than for PM-style use cases — a writer's real bottleneck is usually the writing itself, not tracking metadata. Per this project's own research theme: don't let system-building substitute for the actual work.

---

## 5. Software Developer / Local-First Builder (closest to your own [[Gloss Local]] project)

**What's different:** the vault documents a *build*, not just ideas — architecture decisions, debugging notes, and a changelog-like history matter more than permanent notes about external reading.

### Structure adjustments
- `01-Projects/[Project Name]/` exactly as already built for Gloss Local — the Decisions Made section is the single highest-value addition for this use case specifically: six months from now, "why Ollama over a hosted API" or "why SQLite over Postgres" are exactly the questions a Decisions log answers instantly.
- Add a `Research/` subsection inside the project folder for technical comparisons (e.g. "Ollama vs. LM Studio" style notes) — these are literature notes about tools, not permanent ideas, and belong close to the project rather than in general `03-Resources`.
- Consider one `03-Resources/Dev Patterns/` folder for anything genuinely reusable across projects (a permanent note about a sync-conflict-resolution pattern you'd reuse beyond this one project, for instance).

### Note types specific to this use case
- A lightweight **ADR-style note** (Architecture Decision Record) — this is a well-known pattern from software engineering that maps almost exactly onto the book's "Decisions Made" section; worth formalizing with its own short template: Context / Decision / Alternatives Considered / Consequences.
- A **Changelog note** or a Daily-Note tag (`#gloss-local-update`) you can later query — useful for reconstructing what shipped when, without needing full git-commit archaeology.

### Rhythm adjustments
- Given this project's own no-subscription, local-first ethos, the AI layer from [[Chapter 8 - AI Inside Your Second Brain]] is genuinely free to run here: Ollama is already installed for Gloss Local itself, so Smart Connections/Copilot cost zero additional infrastructure — this is the one use case in this guide where the "AI layer" step is nearly frictionless rather than an extra decision.
- Weekly review's project-status check doubles as a lightweight stand-up with yourself — useful specifically because solo projects have no one else to report progress to, and silent stalling is easy to not notice without it.

### What to skip
- The book's CRM/client-automation framing (Ch.7's n8n examples) doesn't apply to a personal build — but the *general* n8n pattern (webhook → formatted vault note) could plausibly apply later if Gloss Local ever has its own webhook/event system worth logging into Obsidian automatically. Not needed now; worth remembering it's possible.

---

## 6. Personal Life Admin / General Everyday Second Brain

**What's different:** no "projects" in the professional sense — Areas dominate (Health, Finance, Home, Relationships), and the system's value is continuity over years, not output.

### Structure adjustments
- `02-Areas/` becomes the center of gravity: Health, Finance, Home, Relationships, Personal Growth — exactly the book's own examples, used literally rather than adapted.
- `01-Projects/` stays genuinely sparse — only real one-off efforts with an end date (a home renovation, a trip, a specific financial goal with a deadline) belong here; resist the temptation to make everything a "project."

### Note types specific to this use case
- A simple **Decision Log** per Area (e.g. `02-Areas/Finance/Decisions.md`) — same pattern as the project Decisions Made section, applied to ongoing life areas: "why we chose this insurance plan," "why we refinanced in X month" — genuinely useful when revisiting a decision years later and having forgotten the reasoning.
- Lean on the Daily Note's evening reflection far more heavily here than any other use case — over a year, it becomes a real record of patterns in mood, health, and relationships that no professional-focused use case captures as naturally.

### Rhythm adjustments
- Monthly review's "which areas need more attention" question is the single most valuable mechanism in this use case — it's specifically designed to catch the thing every other system misses: the Area with zero notes in two months that's quietly being neglected (the book's own example: "Health: No new notes. Need to start the running log again.").

### What to skip
- Nearly everything in Chapters 5, 7, and 8 beyond the Daily Note and basic linking — Dataview/Bases dashboards, project automation, and AI chat add very little value for a system that's mostly journaling + area notes + occasional reference material. Resist installing plugins "because the book has them" if your actual use case doesn't need them — this is the use case most vulnerable to the overengineering trap flagged repeatedly across this project's chapter research.

---

## Choosing between use cases (if more than one applies to you)
Most real second brains are a blend — you're plausibly both the "developer" use case (for Gloss Local) and the "personal life admin" use case (for everything else) at the same time, which this vault's existing structure already reflects: `01-Projects/Gloss Local` plus a general `02-Areas/Knowledge Management`. Don't force a single persona onto the whole vault — apply the relevant section's adjustments per *folder*, not per vault.

## Related
- [[Obsidian Second Brain - MOC]] — full chapter notes this guide builds on
- [[Practical Obsidian Setup Guide]] — the sequencing/action-plan companion to this guide
