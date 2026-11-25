---
tags: [resource, obsidian, bases, dataview]
---
# Bases vs. Dataview — 2026 Decision Notes

Flagged across [[Chapter 5 - The 10 Essential Plugins]] and [[Chapter 7 - Run Your Projects Inside Obsidian]] as the one real update the book doesn't know about. Researched properly here since it affects which plugin(s) you actually install, and both Dashboards in this vault now have two implementations because of it.

## What Bases actually is
A **core plugin** (built into Obsidian since v1.9, enabled under Settings → Core Plugins — no community install needed) that creates database-like Table / List / Cards / Kanban / Map views of your notes, filtered and sorted from frontmatter properties. Defined in `.base` files (plain YAML, syncs with your vault, visible in Git diffs) or embedded directly in a note as a ` ```base ` code block.

Minimal real example (confirmed against Obsidian's own documentation):
```yaml
filters:
  and:
    - file.hasTag("book")
views:
  - type: table
    name: By Rating
    order:
      - file.name
      - note.author
      - note.rating
```
Property access: `note.author` (frontmatter) or `file.ext` (file-level). Properties with characters that break dot-notation (like the hyphen in `date-read`) use bracket form: `note["date-read"]`.

## What Bases can do (confirmed, as of late 2026)
- Table, List, Cards, Kanban, and Map (via the separate Maps plugin) views
- Filtering by frontmatter property, tag, folder, and file metadata (`file.ctime`, `file.mtime`, `file.ext`, etc.)
- Formulas — calculated display fields using arithmetic, date math, and built-in functions (e.g. `(price / age).toFixed(2)`)
- Summaries — aggregations (Average, Min, Max, Sum, Median, etc.) across a column
- Grouping, with manual control over group order and visibility (`groupOrder`)
- GUI-editable — most of the above can be configured by clicking, not writing YAML, then saved back to the `.base` file automatically

## What Bases genuinely cannot do yet (confirmed across multiple 2026 sources, consistent picture)
1. **Inline fields.** Bases only reads YAML frontmatter. Dataview's `rating:: 3` written inline in a note's body is invisible to Bases — tested directly by one source: the same note showed `3` in Dataview and an empty cell in Bases.
2. **Task-level queries.** Bases rows are always whole files — it cannot collect individual checkboxes/tasks scattered across many notes into one list the way Dataview's `TASK` queries (or the dedicated Tasks plugin) do. Checking a task in a Dataview task-query result checks the box in the source note; Bases has no equivalent, because it doesn't operate below the file level.
3. **DataviewJS / scripting.** No arbitrary JavaScript escape hatch. Complex custom logic that reaches into inline fields or does multi-step processing has no Bases equivalent yet.
4. **Inline queries in prose.** Printing a computed value mid-sentence in a note (a common small Dataview trick) has no Bases equivalent.
5. **Deeper calculated/rollup fields.** Simple formulas work; things like "count of linked tasks across N notes" or multi-hop rollups are cited as still exceeding what Bases formulas can express.

## What this means concretely for *this vault*
- **`Reading Dashboard`** and **`Project Dashboard`** both read plain YAML frontmatter (`author`/`rating`/`date-read`/`status`, and `Status`/`Due`/`Client` respectively) — exactly the case Bases handles natively. Both now have a `.base` file as the recommended default, with the original Dataview block kept as Option B.
- **`Today's Tasks`** and **`Upcoming Tasks`** use the separate **Tasks plugin**, not Dataview — unaffected by this comparison either way, since Bases' task-level gap is specifically about Dataview's `TASK` query type, and the Tasks plugin is its own thing that both Bases and Dataview users would install for that purpose.
- If you later want a dashboard that does something Bases can't (e.g., a live rollup of every `due::` inline task across every project note, or a computed "days since created" style stat on a note that needs an inline field), that's exactly the 20% where Dataview still wins — install it then, not preemptively.

## Ecosystem context worth knowing
Dataview itself is effectively in **maintenance mode**: its most recent release shipped well over a year ago with hundreds of open issues, and its original author's attention has reportedly shifted to a different, early-stage successor project (Datacore). This doesn't mean Dataview stops working — it's stable and widely used — but it's a data point against defaulting to it for new, simple use cases Bases already covers, and a mild argument for treating Bases as the long-term native direction.

## Recommendation for this vault
1. Enable the core **Bases** plugin (Settings → Core Plugins) — likely already available, no install needed.
2. Use the `.base` files for Reading Dashboard and Project Dashboard as the default.
3. Only install the community **Dataview** plugin if you hit one of the five confirmed gaps above — most likely the inline-field or task-level-query gap, if your project notes' `due::` task syntax ever needs to be rolled up across all projects into a single Dataview-style `TASK` view (the Tasks plugin alone already covers simple due-date queries, which is most of what you'll need).
4. There's a documented Dataview-to-Bases converter tool if you ever want to migrate an existing Dataview query — worth knowing it exists rather than manually rewriting queries by hand.

## Sources
- [Introduction to Bases — Obsidian Help (official)](https://obsidian.md/help/bases)
- [Bases syntax — Obsidian Help (official)](https://obsidian.md/help/bases/syntax)
- [Views — Obsidian Help (official)](https://obsidian.md/help/bases)
- [Create a base — Obsidian Help (official)](https://obsidian.md/help/bases/create-base)
- [Obsidian Bases: The Complete Guide to Native Database Views and Dataview Migration — Obsidian Mate](https://obsidianmate.com/article/obsidian-bases-complete-guide)
- [Obsidian Bases vs Dataview: Should You Switch? (2026) — VaultPicks](https://vaultpicks.net/obsidian-bases-vs-dataview/)
- [How to Migrate to Obsidian Bases from Dataview — Practical PKM](https://practicalpkm.com/moving-to-obsidian-bases-from-dataview/)
- [Obsidian Bases vs Dataview (2026): Which Should You Use? — Locul](https://locul.ai/blog/obsidian-bases-plugin)
- [Obsidian finally fixed the one thing Notion always did better — MakeUseOf](https://www.makeuseof.com/obsidian-bases-notion-database/)

## Related
- [[Chapter 5 - The 10 Essential Plugins]]
- [[Chapter 7 - Run Your Projects Inside Obsidian]]
- `Dashboards/Reading Dashboard.base`, `Dashboards/Project Dashboard.base`
