---
title: "Building a Second Brain — Use Cases Guide"
tags: [guide, pkm, second-brain, use-cases]
book: "[[Building a Second Brain - MOC|Building a Second Brain]]"
---

# Building a Second Brain — Use Cases Guide

*Building a Second Brain*'s system (CODE + PARA + Progressive Summarization) is intentionally tool-agnostic and domain-agnostic — the book itself gives examples from a startup designer, an oncologist, a pastor, and a professor. This guide adapts it to a few concrete situations relevant to you specifically, rather than restating the general method (see the chapter notes and [[Practical Setup Guide]] for that).

## Use case 1 — Building Gloss Local (a solo software side project)

**The situation:** a local-first, no-subscription reading app, built in scattered free time, with real risk of losing track of decisions between sessions (per project memory: "tested only against a mock Ollama in the sandbox; real-model behaviour on the Mac has not been verified yet").

**What to actually do:**
- Treat `01-Projects/Gloss Local/` as the project's single PARA home — everything (design notes, decisions, research on Ollama/SQLite options, bug findings) goes there, per [[Chapter 5 - Organize - Save for Actionability]].
- End every work session with a **Hemingway Bridge** note (per [[Chapter 8 - The Art of Creative Execution]]): what you tested, what's still unverified, what to try next. This directly addresses the "not yet verified on real hardware" risk — a session-ending note turns an implicit, easily-forgotten caveat into an explicit, resurfaceable one.
- When facing a build decision (e.g. "Ollama model choice," "how to handle Drive backup conflicts"), build a quick **Archipelago of Ideas** note first — gather relevant past notes/constraints, then sequence a decision — rather than deciding from scratch each time.
- Apply **Dial Down the Scope** explicitly whenever ambitions creep (the project has already shown this discipline once, per memory: LlamaParse and painted covers were removed) — keep a "someday/maybe" section in the project folder for cut features, rather than silently dropping them.
- Run a lightweight **Project Completion Checklist** (per [[Chapter 9 - The Essential Habits of Digital Organizers]]) once a milestone (e.g. "stable on Mac") is reached — salvage reusable config/scripts/decisions as Intermediate Packets before considering that phase done.

## Use case 2 — This Obsidian vault itself (general reading, research, book notes)

**The situation:** you're actively building a multi-book knowledge base (this very project), reading non-fiction and wanting to retain and apply it, not just archive it.

**What to actually do:**
- The **Favorite Problems** list ([[Favorite Problems]]) is your filter for what's worth capturing across any book or article, not just this one — revisit and refine it periodically (per [[Chapter 4 - Capture - Keep What Resonates]]).
- When reading a new book (the next one you add per [[Books - Index]]), apply **Progressive Summarization** to your own reading highlights the same way the demo in [[Example - Progressive Summarization (4 Layers)]] shows — most won't need Layer 4, only the ideas you expect to revisit often.
- Use the **"Claude's pick"** sections already built into every chapter note in this vault as a fast way to recall a book's most important ideas without re-reading full chapter notes — this is effectively already a Layer 3/4 distillation, done for you.
- For any future "what did book X actually argue" question, start with that book's MOC (e.g. [[Building a Second Brain - MOC]]) — treat MOCs as the book-level executive summary, per [[Chapter 6 - Distill - Find the Essence]]'s zoom-in/zoom-out framing.

## Use case 3 — A non-software, non-reading example (for breadth, per the book's own range of case studies)

**The situation:** a one-off creative or logistical project with real deadline pressure — e.g. planning a trip, preparing a talk, or organizing a family event.

**What to actually do:**
- Create one project folder (even temporarily) rather than scattering notes across messages, email, and memory.
- Capture opportunistically as ideas occur (per [[Chapter 4]]'s "what would this look like if it was easy?") — a venue idea while scrolling Instagram, a packing reminder while showering.
- Build an Archipelago of Ideas outline early (per [[Chapter 8]]) — this is literally Forte's own garage-remodel example, which followed this exact pattern.
- When the plan balloons in ambition (it will), Dial Down the Scope deliberately rather than letting the deadline force a panicked cut later.

## Choosing where to start
If you're unsure which use case to practice the system on first: **Gloss Local is the highest-value target**, since it already has a real, demonstrated risk (unverified real-hardware behavior) that a Hemingway Bridge habit directly mitigates, and it's a project you're actively returning to in scattered sessions — exactly the condition this book's checklists and bridges are designed for.

## Related
- [[Building a Second Brain - MOC]]
- [[Practical Setup Guide]]
- [[Project Overview|Gloss Local Project Overview]]
