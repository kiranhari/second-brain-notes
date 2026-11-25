---
tags: [dashboard]
---
# Reading Dashboard

Two implementations exist — pick whichever plugin you end up installing (see [[Chapter 5 - The 10 Essential Plugins]] and [[Bases vs Dataview - 2026 Decision Notes]] for the full comparison).

## Option A — Native Bases (recommended, no plugin install needed)
A companion file, **`Reading Dashboard.base`**, sits next to this note in the same folder. Open it directly in Obsidian (core **Bases** plugin, shipped since v1.9 — just needs enabling under Settings → Core Plugins if it isn't already) — no community plugin required. It reads the same `author`, `rating`, `date-read`, `status` frontmatter fields from `05-Templates/Book Note Template.md`.

## Option B — Dataview (community plugin, still more powerful for complex queries)
```dataview
TABLE author, rating, "date-read" AS "Date Read"
FROM #book
SORT rating DESC
```
Requires the **Dataview** community plugin (Chapter 5, Plugin 1) installed and enabled.

*(Both are empty until you create your first book note from the template — that's expected.)*
