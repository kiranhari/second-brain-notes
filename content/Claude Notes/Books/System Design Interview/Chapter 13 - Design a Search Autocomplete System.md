---
title: "Chapter 13: Design a Search Autocomplete System"
book: "[[System Design Interview - MOC|System Design Interview]]"
chapter: 13
tags: [book-notes, system-design, trie, autocomplete, top-k]
status: done
---

# Chapter 13: Design a Search Autocomplete System

> [!cite] Book reference
> *System Design Interview: An Insider's Guide, Second Edition* by Alex Xu. Chapter 13: "Design a Search Autocomplete System." Source: the user's uploaded EPUB file.

> [!summary] One-line takeaway
> A naive trie lookup for the top-k matches of a prefix costs O(p) + O(c) + O(c log c); capping prefix length and caching each node's own top-k answer collapses that to O(1), at the deliberate cost of extra memory, and the harder problem turns out to be feeding that trie fresh data at scale, not querying it.

## Why this chapter matters

This chapter is the book's clearest demonstration of the space-for-time tradeoff as a deliberate design choice, not an afterthought: both of its core optimizations exist purely to trade memory for speed. It also explicitly reuses Chapter 6's key-value store (one of two storage options for the trie) and sets up an honest limitation, no real solution for genuinely real-time trending queries, that the book flags rather than glosses over.

## Direct quotes from the book

> [!quote] On what this interview question is also called
> "This leads us to the interview question: design a search autocomplete system, also called 'design top k' or 'design top k most searched queries'."

> [!quote] On the latency bar
> "An article about Facebook's autocomplete system reveals that the system needs to return results within 100 milliseconds. Otherwise it will cause stuttering."[^1]

> [!quote] On the space-for-time tradeoff
> "By caching top search queries at every node, we significantly reduce the time complexity to retrieve the top 5 queries. However, this design requires a lot of space to store top queries at every node. Trading space for time is well worth it as fast response time is very important."

> [!quote] On the honest limitation
> "Building a real-time search autocomplete is complicated and is beyond the scope of this book so we will only give a few ideas."

## The chapter in full (so you never need to re-read it)

### Step 1: understand the problem and establish design scope

The interviewer exchange locks down a fairly narrow, tractable scope: matching only applies at the start of a query, not mid-string; the system returns 5 suggestions; ranking is based purely on historical query frequency (popularity), not any more sophisticated relevance model; spell check and autocorrect are explicitly out of scope; queries are English only, with multi-language support deferred to the end if time allows; all queries are assumed lowercase alphabetic, no capitalization or special characters; and the target scale is 10 million DAU.

**Requirements summary:**

- Fast response time, with the book citing a 100ms bar from Facebook's own typeahead engineering writeup,[^1] past which perceived stuttering sets in.
- Relevant results, matched to the actual search term.
- Sorted output, ranked by popularity or another ranking model.
- Scalable to high traffic volume.
- Highly available, continuing to function when parts of the system degrade or fail.

**Back-of-the-envelope estimation**: at 10 million DAU, 10 searches per user per day, 20 bytes per query (4 words averaging 5 characters each, 1 byte per ASCII character), and roughly 20 backend requests sent per completed search (one per keystroke, the book's own example walking through typing "dinner" character by character), QPS comes out to about 24,000, with peak QPS around 48,000. Assuming 20% of daily queries are genuinely new, roughly 0.4 GB of new data accumulates per day.

### Step 2: propose a high-level design

The system splits into two halves: a **data gathering service**, aggregating user queries in real time as a starting point (acknowledged upfront as impractical at true scale, with a more realistic version coming in the deep dive), and a **query service**, which, given a query or prefix, returns the 5 most frequently searched matching terms.

**Data gathering service, simplified.** A frequency table maps query strings to their search counts, starting empty and updating as users type queries like "twitch," "twitter," "twitter" again, and "twillo" in sequence, incrementing each string's stored count.

**Query service, simplified.** Given that same frequency table, a prefix like "tw" resolves to its top 5 matches via a straightforward SQL query sorted by frequency. The book is explicit that this is acceptable only while the dataset stays small; at real scale, hitting the database directly on every keystroke becomes the bottleneck, which the deep dive addresses directly.

### Step 3: design deep dive

**The trie data structure.** A relational database is simply the wrong tool for fetching top-k prefix matches efficiently at scale; a trie (prefix tree) is the standard fix. The book deliberately keeps its own explanation of basic trie mechanics brief, noting plenty of other material already covers it, and spends its real effort on optimizing a basic trie for this specific use case. Core mechanics: the root represents an empty string; each node holds a character and up to 26 children (one per possible next letter, with empty links omitted for space); and each node along a root-to-node path represents a specific word or prefix. To support frequency-based ranking, each node additionally stores the frequency of the query it represents.

**Basic top-k algorithm**, using p for prefix length, n for total trie nodes, and c for the number of children at a given node:

1. Find the prefix node: O(p).
2. Traverse the subtree from that node to collect every valid completion (a child is valid if it forms a real, complete query string): O(c).
3. Sort those candidates and take the top k: O(c log c).

The book's own worked trace, for k=2 and the typed prefix "tr": locate node "tr"; its valid children are tree (frequency 10), true (frequency 35), and try (frequency 29); sorted, the top 2 are true and try. Total complexity: O(p) + O(c) + O(c log c), which the book flags as too slow in the worst case, since it can require traversing the entire relevant subtree.

**Two optimizations fix this:**

1. **Cap the maximum prefix length** (the book's own illustrative value: 50). Since users rarely type extremely long queries, p stays a small, effectively constant number, collapsing the find-prefix step from O(p) to O(1).
2. **Cache the top-k queries directly at every node.** Since only 5-10 suggestions are ever shown, k stays small, so storing the top-k list redundantly at every single node is cheap per-node but adds up across the whole trie. This eliminates both the subtree traversal and the sort at query time entirely, since the answer is already sitting at the node. The book's own example: the node for prefix "be" directly stores `[best: 35, bet: 29, bee: 20, be: 15, beer: 10]`.

With both optimizations applied, every step of the algorithm runs in O(1), so fetching the top-k results for any prefix is O(1) overall, an explicit space-for-time trade the book considers clearly worth making given how much response latency matters here.

**Redesigning the data gathering service.** Updating the trie on every single keystroke, in real time, fails for two reasons: at billions of queries per day, constant updates would slow the query path down significantly, and top suggestions rarely shift meaningfully minute to minute anyway, making constant updates mostly wasted work. The book notes that use cases genuinely differ (Twitter-style real-time relevance versus Google-style queries that barely change day to day), but the underlying pipeline shape stays the same regardless, since the data ultimately comes from analytics or logging services either way. The redesigned pipeline: **analytics logs** (raw, append-only, unindexed data) feed **aggregators**, which batch and reformat the data (at whatever cadence the use case actually needs, real-time for something like Twitter, weekly for most other cases, the book's own working assumption is a weekly rebuild); aggregated data (the book's example schema: a week-start timestamp plus a summed frequency per query for that week) feeds **workers**, asynchronous jobs running on a schedule that rebuild the trie and persist it to **Trie DB**; and a **Trie Cache**, a distributed in-memory cache holding a periodic (weekly, matching the rebuild cadence) snapshot of the trie for fast reads.

**Trie DB storage options:**

1. **Document store** (the book's example: MongoDB).[^4] Since a fresh trie is built on a fixed schedule, serialize the whole structure as a snapshot and store that blob directly.
2. **Key-value store.** Represent the trie as a hash table: every prefix in the trie maps to a key, and each node's data maps to a value. The book explicitly points back to Chapter 6's key-value store design for readers unclear on the underlying mechanics.

**Query service, redesigned.** A search query hits the load balancer, which routes to API servers; API servers fetch data from the Trie Cache to build the autocomplete suggestions; on a cache miss (which can happen if a cache server runs out of memory or goes offline), the system replenishes the cache from the underlying data, so subsequent requests for that same prefix hit the cache directly going forward. Three further speed optimizations: **AJAX requests**, so fetching suggestions never triggers a full page reload; **browser caching**, since suggestions often barely change over short windows, the book's own example shows Google itself caching autocomplete responses for an hour (`private, max-age=3600`, where `private` means the response is for one specific user and must not be cached by a shared cache); and **data sampling**, logging only 1 out of every N search requests, since logging every single request at this scale would demand excessive processing power and storage.

**Trie operations.** Create: workers build a fresh trie from aggregated analytics data. Update: two options, either rebuilding the entire trie on a schedule and swapping it in wholesale (the book's preferred default), or updating a single node directly, which the book recommends avoiding in general since it is slow, specifically because updating one node's frequency also requires updating every ancestor up the tree to the root, since ancestors cache their descendants' top queries; this direct-update approach is only acceptable when the trie is small. Delete: since some autocomplete suggestions need removing for being hateful, violent, sexually explicit, or otherwise dangerous, a filter layer sits in front of the Trie Cache specifically to block unwanted suggestions immediately, with the flexibility to apply different filter rules; the underlying bad data is removed from the database asynchronously, so it is simply absent from the next scheduled rebuild.

**Scaling the storage.** Once the trie outgrows a single server, the book's first instinct is naive first-letter sharding: with 2 servers, split 'a' through 'm' and 'n' through 'z'; with 3, split into three roughly equal letter ranges; up to a theoretical maximum of 26 servers, one per letter, with further subdivision (for example splitting 'a' itself into four sub-ranges like "aa-ag," "ah-an," "ao-au," "av-az") needed beyond that. This naive approach has an immediate, real flaw: letter frequency in actual language is wildly uneven (far more real words and queries start with 'c' than with 'x'), producing badly unbalanced shards. The fix is a shard map manager that consults actual historical query-volume data and groups letters into shards with comparable real traffic volume, for example pairing a high-volume single letter against several much lower-volume letters combined, rather than assuming every letter of the alphabet carries equal weight.

### Step 4: wrap-up and follow-up questions

Three follow-up questions the book addresses directly:

- **Multi-language support.** Store Unicode characters in trie nodes instead of assuming plain ASCII, with the book quoting Unicode's own definition as an encoding standard covering every writing system, modern and ancient.[^5]
- **Country-specific differences in top queries.** Build separate tries per country or region, and serve them from CDNs to keep response time low regardless of the user's location.
- **Real-time (trending) query support.** The book is candid that the existing design genuinely breaks here: scheduled weekly rebuilds will not have run yet when a sudden news event spikes a query's popularity, and even if a rebuild were triggered immediately, building a fresh trie simply takes too long to reflect truly real-time shifts. The book offers only directional ideas rather than a full solution: reduce the active working data set via sharding; change the ranking model to weight recent queries more heavily; and recognize that true real-time data typically arrives as a continuous stream rather than a static batch, which demands an entirely different class of tooling, naming Apache Hadoop MapReduce,[^6] Spark Streaming,[^7] Apache Storm,[^8] and Apache Kafka[^9] as examples, while explicitly declining to go deeper since each requires its own specialized domain knowledge beyond this chapter's scope.

## Core concepts (quick-scan version)

See the full trie diagrams, complexity breakdown, data-gathering pipeline, and sharding pitfall in [[Chapter 13 - Autocomplete Trie Walkthrough]].

| Design question | The book's answer |
|---|---|
| Why not just query a relational database directly? | Fetching top-k prefix matches does not fit relational access patterns efficiently at scale |
| How is O(p) + O(c) + O(c log c) reduced to O(1)? | Cap prefix length (fixes the p term); cache top-k per node (fixes the c and c log c terms) |
| How is the trie kept fresh without slowing every keystroke? | A batch pipeline (logs, aggregation, scheduled worker rebuilds), not real-time per-query updates |
| Where does the trie actually live? | Persisted in Trie DB (document store or key-value store), served from an in-memory Trie Cache |
| How is unwanted content removed? | A filter layer in front of the cache, for immediate effect, plus asynchronous removal from the underlying data for the next rebuild |
| How does sharding avoid lopsided shards? | A shard map manager informed by real historical query-volume distribution, not naive equal letter ranges |

## First-principles breakdown

The chapter's two trie optimizations are really one single idea applied twice: move cost from query time to a time you control (a scheduled rebuild), because query-time latency is the thing users actually feel, while rebuild-time cost is invisible to them as long as it finishes before the next scheduled rebuild is due. Capping prefix length bounds the cost of the "find the node" step; caching top-k per node moves the cost of "compute the answer" entirely out of the read path and into the (infrequent) write path. Both trades are only worth making because the chapter's own requirements explicitly rank fast response time above nearly everything else, a priority this book has made explicit in exactly the terms it uses here: trading space for time is worth it specifically because the problem has decided speed matters more than memory efficiency.

This reframes "building a real-time version is out of scope" as more than a cop-out: the entire architecture, scheduled batch rebuilds feeding an immutable cached snapshot, is structurally opposed to real-time freshness. A rebuild-and-swap design is fast to read precisely because it never has to reconcile concurrent updates against live reads; a design that updated the trie live, on every query, would reintroduce exactly the synchronization costs this chapter spent its whole optimization effort removing. The honest admission that real-time autocomplete needs a genuinely different architecture (streaming systems like Kafka or Spark Streaming) is the book correctly recognizing that it cannot have both properties, read-time O(1) simplicity and write-time real-time freshness, from the same design simultaneously.

## Visual representation

See the full basic and optimized trie diagrams, the data-gathering pipeline, the query-service flow, and the sharding diagrams in [[Chapter 13 - Autocomplete Trie Walkthrough]].

```mermaid
flowchart TD
    A[Naive trie:<br/>O(p) + O(c) + O(c log c)] --> B{Cap prefix length}
    B --> C[Find-prefix step: O(1)]
    A --> D{Cache top-k per node}
    D --> E[Traverse + sort steps: O(1)]
    C --> F[Total lookup: O(1)]
    E --> F
```

## Worked example, built directly in your vault

Built: [[Chapter 13 - Autocomplete Trie Walkthrough]] in `Claude Notes/Books/System Design Interview/Examples/`, reproducing the capacity math, the basic and optimized trie diagrams with full complexity analysis, the data-gathering pipeline, the improved query service flow, all three trie operations (create, update, delete), and the sharding pitfall with its shard-map-manager fix, cross-linked to Chapter 6's key-value store.

## What the book doesn't tell you, community perspective (2025-2026)

- **Real production systems increasingly favor Elasticsearch's completion suggester, built on a finite state transducer, over a hand-built trie service**, for exactly the freshness reasons this chapter's own wrap-up admits: it moves heavy computation to index time rather than query time, and it natively supports near-real-time updates without this chapter's scheduled-rebuild constraint, at the cost of being a heavier, more general-purpose system than a lean custom trie.
- **A hybrid approach is reported as the most common real-world compromise**: a trie or flat prefix table holding the most popular roughly ten million queries, covering the large majority of real traffic at pure in-memory speed, with the long tail of rarer queries falling through to a slower general search backend rather than living in the trie at all.
- **Radix trees (compressed tries, collapsing single-child chains into one node) are the reported practical choice for custom production trie implementations**, delivering roughly 10x memory savings over the book's plain character-per-node trie, directly addressing the "this requires a lot of space" tradeoff the chapter names but does not optimize further.
- **Published real-world latency numbers go beyond this chapter's 100ms bar.** LinkedIn's own typeahead system (Cleo) reportedly serves generic suggestions in under 1 millisecond within a single cluster, and personalized, network-aware suggestions in under 15 milliseconds, with a separate aggregation layer adding up to about 25 milliseconds end to end, giving a concrete sense of how far beyond "not stuttering" real systems actually push.
- **Elasticsearch's completion suggester has a known freshness caveat worth knowing if you ever reach for it over a custom trie**: its underlying FST structure is built per Lucene segment and is not updated until segments merge, so deleted or edited documents can keep appearing in suggestions until an explicit forcemerge runs, a subtlety this chapter's own document-store option does not need to worry about, since it simply replaces the whole structure on each scheduled rebuild.

## Deeper commentary, how this applies to your setup specifically

The space-for-time tradeoff this chapter makes so explicit is worth treating as a reusable mental test for any future design question in this book, or elsewhere: identify which side of a system actually feels latency (usually the read/query path) and which side can tolerate being slower as long as it eventually finishes (usually a background job or scheduled rebuild), then deliberately push cost toward the side that can absorb it.

## Practical and actionable takeaways

- [x] Extracted the full basic and optimized trie algorithms with complete complexity analysis, the redesigned data-gathering pipeline, the improved query service, all three trie operations, and the sharding pitfall from the source EPUB.
- [x] Built a standalone worked-example note with every diagram and the full complexity breakdown, cross-linked to Chapter 6's key-value store.
- [ ] Compare this chapter's custom-trie approach against Elasticsearch's completion suggester for a hypothetical project of your own, using the hybrid "trie for the head, search backend for the tail" pattern from the community research as the deciding framework.
- [ ] Revisit this chapter once you have more exposure to streaming systems (Kafka, Spark Streaming), specifically to understand why they are structurally necessary for the real-time case this chapter explicitly declines to solve.

## Questions and things to decide for your own vault

- Do you want a standalone note on "space-for-time tradeoffs across this book" tracking every chapter that makes this trade explicitly (this chapter's per-node caching, Chapter 6's Merkle trees, Chapter 9's Bloom filters), since the pattern keeps recurring under different names?
- Should streaming systems (Kafka, Spark Streaming, Storm) get their own placeholder note now, flagged as "referenced but not explained" in this book, to revisit once you study them properly elsewhere?

## Sources (external, beyond the book)

- [System Design: Search Autocomplete/Typeahead, Trie, Elasticsearch, Ranking, Debouncing, Personalization, Trending](https://www.techinterview.org/post/3233474192/system-design-search-autocomplete-typeahead-trie-elasticsearch-ranking-debouncing-personalization-trending-queries/)
- [Search Autocomplete System Design: Tries, Caching, and Sub-100ms Scale](https://singhajit.com/search-autocomplete-system-design/) — Ajit Singh
- [Design Search Autocomplete: Prefix Matching at Scale](https://sujeet.pro/articles/design-search-autocomplete) — Sujeet Jaiswal

## Footnotes

[^1]: The Life of a Typeahead Query: https://www.facebook.com/notes/facebook-engineering/the-life-of-a-typeahead-query/389105248919/
[^2]: How We Built Prefixy, A Scalable Prefix Search Service for Powering Autocomplete: https://medium.com/@prefixyteam/how-we-built-prefixy-a-scalable-prefix-search-service-for-powering-autocomplete-c20f98e2eff1
[^3]: Prefix Hash Tree, An Indexing Data Structure over Distributed Hash Tables: https://people.eecs.berkeley.edu/~sylvia/papers/pht.pdf
[^4]: MongoDB (Wikipedia): https://en.wikipedia.org/wiki/MongoDB
[^5]: Unicode frequently asked questions: https://www.unicode.org/faq/basic_q.html
[^6]: Apache Hadoop: https://hadoop.apache.org/
[^7]: Spark Streaming: https://spark.apache.org/streaming/
[^8]: Apache Storm: https://storm.apache.org/
[^9]: Apache Kafka: https://kafka.apache.org/documentation/

## Claude's pick, what I'd flag as most important

- The space-for-time trade this chapter makes explicitly (cache top-k at every node) is worth remembering as a named, deliberate design pattern, not just a clever trick specific to tries; it is a lens worth applying to future chapters too.
- The sharding pitfall (naive letter-range sharding assumes uniform distribution that does not exist in real language) is a small, concrete, memorable example of a mistake that is easy to make anywhere you shard by a natural-seeming key without checking its actual distribution first.
- The chapter's honest admission that real-time autocomplete needs a structurally different architecture is a good model of intellectual honesty worth emulating: naming exactly where a design's assumptions break, rather than implying it scales to every case, is itself a skill worth practicing.

## Related

- Previous: [[Chapter 12 - Design a Chat System]]
- Next: [[Chapter 14 - Design YouTube]]
- MOC: [[System Design Interview - MOC]]
- Worked example: [[Chapter 13 - Autocomplete Trie Walkthrough]]
