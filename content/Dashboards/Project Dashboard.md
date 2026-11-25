---
tags: [dashboard]
---
# Project Dashboard

Two implementations exist, reading the same `Status`/`Due`/`Client` frontmatter from `05-Templates/Project Note Template.md`:

## Option A — Native Bases (recommended — this use case is simple frontmatter filtering, squarely within what Bases covers)
A companion file, **`Project Dashboard.base`**, sits next to this note with all three views (Active / On Hold / Completed This Month) built in. Open it directly in Obsidian — core plugin, no install needed. See [[Bases vs Dataview - 2026 Decision Notes]] for why this is the recommended default for this particular dashboard.

## Option B — Dataview (community plugin)

### Active Projects
```dataview
TABLE
  Status,
  Due,
  Client
FROM "01-Projects"
WHERE Status = "Active"
SORT Due ASC
```

### On Hold
```dataview
TABLE
  Status,
  Due,
  Client
FROM "01-Projects"
WHERE Status = "On Hold"
SORT file.mtime DESC
```

### Completed This Month
```dataview
TABLE
  Due,
  Client
FROM "01-Projects"
WHERE Status = "Completed"
AND Due >= date(today) - dur(30 days)
SORT Due DESC
```

*(Note: path is `01-Projects`, matching this vault's PARA folder from Chapter 2 — the book's own example used a plain `Projects` folder name.)*
