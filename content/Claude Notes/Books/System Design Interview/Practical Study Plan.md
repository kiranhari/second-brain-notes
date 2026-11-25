---
title: "Practical Study Plan — System Design Interview"
tags: [book-notes, study-plan, system-design]
---

# Practical study plan

A phased plan for turning these 16 chapters of notes into actual interview readiness, sequenced so earlier phases build the vocabulary later phases assume.

```mermaid
flowchart LR
    P1[Phase 1: Foundations<br/>Ch 1-3] --> P2[Phase 2: Building blocks<br/>Ch 4-7]
    P2 --> P3[Phase 3: Full systems<br/>Ch 8-15]
    P3 --> P4[Phase 4: Mock interviews<br/>and gap-filling]
```

## Phase 1: foundations (Chapters 1-3)

Goal: internalize the shared vocabulary every later chapter assumes.

- Read [[Chapter 1 - Scale From Zero to Millions of Users]] and [[Chapter 1 - Scaling Journey Architecture]] together; redraw the final composite architecture from memory.
- Memorize [[Chapter 2 - Back-of-the-Envelope Estimation]]'s five-step estimation template; practice it on three unrelated made-up scenarios (not from this book) until the rounding and unit-labeling habits feel automatic.
- Internalize [[Chapter 3 - A Framework for System Design Interviews]]'s 4-step process and time budget. Time yourself narrating a design for any familiar app (not from this book) for 45 minutes, sticking to the budget in [[Where Does This Go - Quick Reference]].

## Phase 2: building blocks (Chapters 4-7)

Goal: these four chapters are reused as components inside nearly every later "design X" chapter; know them cold before moving on.

- [[Chapter 4 - Design a Rate Limiter]]: be able to state, from memory, which of the five algorithms fits a bursty-traffic client versus a strict-rate client.
- [[Chapter 5 - Design Consistent Hashing]]: be able to draw the ring, add a server, remove a server, and explain virtual nodes without looking at notes.
- [[Chapter 6 - Design a Key-Value Store]]: be able to state the quorum formula (W + R > N) and explain, in one sentence each, what vector clocks, gossip protocol, and Merkle trees are each for.
- [[Chapter 7 - Design a Unique ID Generator in Distributed Systems]]: be able to draw the snowflake bit layout from memory.

## Phase 3: full systems (Chapters 8-15)

Goal: practice composing Phase 1 and 2 building blocks into complete designs, the way the book itself does.

For each chapter, in order:

1. Before reading the chapter note, write your own answers to its Step 1 clarifying questions (scope, scale, constraints), exactly as practiced in Chapter 3.
2. Read the chapter note's "chapter in full" section, and compare your own assumptions against the book's.
3. Redraw the chapter's own high-level design from memory, then check it against the worked-example note.
4. Explicitly name which earlier chapters this one reuses (the chapter notes' "Related" sections name these directly: Chapter 8 reuses 7, Chapter 9 reuses 5, Chapter 11 reuses 5 and 10, Chapter 12 reuses 7 and 10, Chapter 14 and 15 reuse 1).

## Phase 4: mock interviews and gap-filling

- Run at least 3 full, timed, 45-minute mock interviews using prompts you have not specifically memorized answers for (for example, designing a different product in the same category as one of this book's chapters: a ride-sharing dispatch system instead of Uber, a photo-sharing feed instead of a news feed).
- For each mock interview, write a short retro note: which step (1-4) you spent too long or too little time on, and which earlier chapter's building block you reached for.
- Revisit [[Chapter 16 - The Learning Continues]] and read at least 2-3 of the primary-source architecture writeups it links to, specifically ones tied to chapters you found hardest.

## How to know you are actually ready

- You can state the quorum formula, the snowflake bit layout, and the 4-step time budget without looking anything up.
- Given an unfamiliar "design X" prompt, you default to Chapter 3's process (clarify, then design, then deep dive, then wrap up) without having to consciously remind yourself to do so.
- You can explain, for at least 3 chapters, exactly which earlier chapter's technique they reused and why that reuse made sense, not just that it happened.

## Related
- MOC: [[System Design Interview - MOC]]
- Quick reference: [[Where Does This Go - Quick Reference]]
