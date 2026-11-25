---
title: "Practical Obsidian Setup Guide — Your Second Brain, Action Plan"
tags: [guide, obsidian, second-brain, setup]
---
# Practical Obsidian Setup Guide

This is the action plan, not the explanation — for the reasoning behind any step, follow the link to the relevant chapter note in [[Obsidian Second Brain - MOC]]. Everything referenced here (templates, dashboards, folders) already exists in this vault; this guide is the order to actually *use* it in.

> [!summary] The one rule that matters more than anything else in this guide
> Consistency beats architecture. Every chapter's community research converged on the same failure mode: building more system instead of writing more notes. If you only do one thing from this entire guide, make it the Week 1 daily habit below — everything else is optional until that sticks.

---

## Phase 0 — Already done (nothing to do here)
Built during this project, verify it exists rather than redo it:
- [x] Vault at `SecondBrain/`, PARA folders (`00-Inbox` through `07-Periodic-Notes`), `Dashboards/`
- [x] Templates: Daily Note, Book Note, Meeting Note, Article Summary, Weekly Review, Monthly Review, Project Note
- [x] Two dashboards, each with a working native-Bases version: `Reading Dashboard`, `Project Dashboard`
- [x] One real project tracked properly: `01-Projects/Gloss Local`
- [x] A CSS snippet ready (not yet enabled): `.obsidian/snippets/second-brain-starter.css`
- [x] Nine chapter notes + Conclusion + MOC in `Claude Notes/`, with every open decision logged in one place

---

## Phase 1 — Week 1: habit only, zero plugins
**Goal: prove the daily loop sticks before installing anything.**

1. Enable the core **Daily Notes** plugin (Settings → Core Plugins) — already built into Obsidian, nothing to download.
   - New file location: `06-Daily-Notes/`
   - Template file location: `05-Templates/Daily Note Template`
2. Every morning: open today's note (`Cmd+D` once configured), write 3 priorities (outcomes, not tasks).
3. During the day: capture anything via the Inbox — don't worry about a shortcut yet, just open the Daily Note and type.
4. Every evening: 3-line reflection (what worked / what was hard / what to carry forward).
5. Delete the example note at `06-Daily-Notes/2026-11-18.md` once your own habit has replaced it as the reference point.

**Do not install any community plugin this week.** (See [[Chapter 1 - Setting Up Obsidian]], [[Chapter 3 - The Daily Capture]] — community research was unusually consistent on this specific point: a blank vault with zero plugins for the first two weeks is the most common piece of advice found across every source checked.)

---

## Phase 2 — Weeks 2–4: minimum viable plugin stack + sync decision
**Goal: three plugins, installed with real gaps between them, plus one infrastructure decision.**

### Plugins, in this order (not all at once):
1. **Bases** — enable under Settings → Core Plugins. Already ships with Obsidian; this unlocks both dashboards (`Dashboards/Reading Dashboard.base`, `Project Dashboard.base`) with zero community install. Do this first — it's free and instant.
2. **Templater** — install, point its template folder at `05-Templates/`, enable "Trigger on new file creation."
3. **Tasks** — install, this powers `Dashboards/Today's Tasks.md` and `Upcoming Tasks.md`.
4. **Stop here for two weeks.** Actually use these three. Resist adding more.

### The sync decision (make it once, deliberately)
Given your Mac + Windows + phone setup and the existing [[Gloss Local]] pattern (no-subscription, Google Drive backups):
- **Default recommendation**: place the vault inside your existing Drive-synced folder. Free, matches your established pattern, works across all three devices.
- **Alternative**: Obsidian Git, if you want full version history and already lean on Git for Gloss Local — but this is more setup, not less, so only choose it if the version-history benefit specifically matters to you.
- Either way: **do not use Obsidian Sync** ($10/mo) — it contradicts the no-subscription philosophy already established elsewhere in your setup, and there's no capability gap it closes that Drive doesn't already cover for a single user.

(Full reasoning: [[Chapter 1 - Setting Up Obsidian]])

---

## Phase 3 — Month 2: review habit + plugins round two
**Goal: only add the weekly review once the daily loop has survived a full month unattended.**

1. Start the weekly review, but **trim it** before you start: the book's four-movement, 30-minute version is the ceiling, not the floor. A documented, common failure pattern is a review "sized for a week that rarely exists." Start with just movements 1 and 3 (review the week + plan next week's 3 outcomes) — add movements 2 and 4 only once the shorter version has stuck for a few weeks.
2. Install **QuickAdd** — set up one global-hotkey capture action appending to today's Daily Note. This is the single highest-leverage plugin for the capture habit specifically.
3. Install **Obsidian Git** now if you decided on it in Phase 2, or **Calendar** + **Periodic Notes** if you want visual navigation of your growing Daily Notes.
4. Decide on the AI layer (see `03-Resources/Obsidian and PKM/AI Second Brain Setup Checklist.md`): given Ollama already runs for Gloss Local, Smart Connections + Copilot pointed at your existing local Ollama instance is the natural default — no new infrastructure, stays consistent with your no-subscription stance.

---

## Phase 4 — Ongoing (month 3+)
- Monthly review (per [[Chapter 6 - Complete Obsidian Workflows]]) — the Start/Stop/Continue check. Use it specifically to decide when `01-Projects/Second Brain Build-Out` should move to `04-Archive`.
- Only install **Dataview** if you hit one of its five confirmed gaps over Bases (inline fields, task-level rollups, scripting, inline prose queries, deep calculated rollups) — see [[Bases vs Dataview - 2026 Decision Notes]]. Don't install it preemptively.
- Only explore Canvas, Publishing, or the Writers' workflow (Ch.9) if a concrete need shows up — they're reference material, not a checklist.
- Write at least one genuine permanent note per week (Ch.4's formula: one idea, your own words, always link, claim-as-title). This is the one piece of the whole system that nothing built so far has done for you, and it's the part that actually matters.

---

## Quick reference

### Folder map
```
00-Inbox/        01-Projects/      02-Areas/       03-Resources/
04-Archive/      05-Templates/     06-Daily-Notes/ 07-Periodic-Notes/
Dashboards/      Claude Notes/     .obsidian/snippets/
```

### Install order, summarized
Bases (core, enable only) → Templater → Tasks → [2-week pause] → QuickAdd → Obsidian Git or Calendar/Periodic Notes → AI layer (Smart Connections + Copilot, local Ollama) → Dataview only if needed.

### Essential shortcuts (memorize these two first)
`Cmd+O` (quick switcher), `Cmd+P` (command palette) — per the book and this project's own Chapter 1 note, these two alone are the highest-leverage habit in the entire system.

### Where every open decision lives
All flagged decisions across every chapter (sync method, note pipeline depth, review scope, AI backend, vault appearance) are consolidated in one place: [[Obsidian Second Brain - MOC]] → "Running list of open decisions."

---

## What this guide deliberately does not repeat
Full explanations, direct quotes from the book, and community research/sources live in the individual chapter notes — this guide only sequences the *doing*. If a step here doesn't make sense, the "why" is one click away via the linked chapter.
