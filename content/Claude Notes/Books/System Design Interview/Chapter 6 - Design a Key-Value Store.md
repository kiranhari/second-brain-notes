---
title: "Chapter 6: Design a Key-Value Store"
book: "[[System Design Interview - MOC|System Design Interview]]"
chapter: 6
tags: [book-notes, system-design, key-value-store, cap-theorem, distributed-systems]
status: done
---

# Chapter 6: Design a Key-Value Store

> [!cite] Book reference
> *System Design Interview: An Insider's Guide, Second Edition* by Alex Xu. Chapter 6: "Design a Key-Value Store." Source: the user's uploaded EPUB file.

> [!summary] One-line takeaway
> A distributed key-value store is built from a small set of composable techniques: consistent hashing for partitioning, quorum consensus (N, W, R) for tunable consistency, vector clocks for reconciling concurrent writes, gossip protocol plus hinted handoff and Merkle trees for failure handling, and a commit-log-then-SSTable write path borrowed from Cassandra.

## Why this chapter matters

This is the most mechanically dense chapter so far, and it directly reuses Chapter 5's consistent hashing ring for data partitioning. It is also the first chapter to name CAP theorem explicitly, a framework that recurs through the rest of the book whenever a design has to choose between consistency and availability under network partition.

## Direct quotes from the book

> [!quote] On what a key-value store is
> "A key-value store, also referred to as a key-value database, is a non-relational database. Each unique identifier is stored as a key with its associated value."

> [!quote] On CAP theorem
> "CAP theorem states it is impossible for a distributed system to simultaneously provide more than two of these three guarantees: consistency, availability, and partition tolerance."

> [!quote] On why CA systems cannot exist in practice
> "Since network failure is unavoidable, a distributed system must tolerate network partition. Thus, a CA system cannot exist in real-world applications."

> [!quote] On the consistency model the book recommends
> "Dynamo and Cassandra adopt eventual consistency, which is our recommended consistency model for our key-value store."

> [!quote] On vector clocks' real-world track record
> "Based on Dynamo paper, Amazon has not yet encountered this problem in production; therefore, it is probably an acceptable solution for most companies."

## The chapter in full (so you never need to re-read it)

### What a key-value store is

Each key is unique, and its paired value is retrieved through that key. Keys can be plain text (`last_logged_in_at`) or hashed values (`253DDEC4`); shorter keys perform better. Values are usually opaque to the store itself, strings, lists, or objects, exactly as in real systems like Amazon Dynamo,[^1] Memcached,[^2] and Redis.[^3] The chapter scopes the design around two operations: `put(key, value)` and `get(key)`.

### Step 1: understand the problem and establish design scope

The book states plainly that there is no perfect design; every key-value store balances read performance, write performance, and memory use against each other, plus a separate, harder tradeoff between consistency and availability. The target system for this chapter has these characteristics:

- Key-value pairs are small, under 10 KB.
- Ability to store large volumes of data.
- High availability: the system keeps responding quickly even during failures.
- High scalability: it supports a large and growing data set.
- Automatic scaling: servers are added or removed automatically based on traffic.
- Tunable consistency.
- Low latency.

### Single-server key-value store

The simplest implementation keeps all key-value pairs in an in-memory hash table. Memory access is fast, but fitting everything in memory eventually hits a hard space ceiling. Two optimizations extend a single server's capacity: compressing the stored data, and keeping only frequently accessed data in memory while the rest lives on disk. Even with both optimizations, a single server reaches capacity quickly, which is why a distributed key-value store becomes necessary for genuinely large data.

### CAP theorem

A distributed key-value store is also called a distributed hash table. CAP theorem states that a distributed system cannot simultaneously guarantee all three of consistency (every client sees the same data regardless of which node it connects to), availability (every request gets a response, even with some nodes down), and partition tolerance (the system keeps operating despite a communication break between nodes). Real systems classify by which two of the three they keep:

- **CP** systems keep consistency and partition tolerance, sacrificing availability.
- **AP** systems keep availability and partition tolerance, sacrificing consistency.
- **CA** systems would keep consistency and availability, sacrificing partition tolerance, but the book is explicit that CA cannot exist in practice, because network partitions are unavoidable in any real distributed system.

The book grounds this in a concrete example with three replicas n1, n2, and n3. In the ideal case with no partition, writes to n1 replicate automatically to n2 and n3, and both consistency and availability hold simultaneously. In the real-world case, if n3 loses contact with n1 and n2, you must choose: block writes to n1 and n2 to preserve consistency (a CP choice, the book's example here is a bank system, where displaying stale balance data is unacceptable and an error is preferable), or keep accepting reads and writes on n1 and n2 and sync to n3 once the partition heals (an AP choice, accepting temporarily stale reads in exchange for staying available). Choosing the right CAP tradeoff for your specific use case, in collaboration with your interviewer, is treated as a key early design decision.

### System components overview

The book structures the rest of the design around seven components: data partition, data replication, consistency, inconsistency resolution, handling failures, the system architecture diagram, and the write and read paths. It notes upfront that the content is largely drawn from three real systems: Dynamo,[^4] Cassandra,[^5] and BigTable.[^6]

### Data partition

Splitting data across multiple servers solves the single-server capacity ceiling, but introduces two challenges: distributing data evenly, and minimizing data movement when servers are added or removed, exactly the problem Chapter 5's consistent hashing solves. The book's example places 8 servers (s0 through s7) on a hash ring; key0 is hashed onto the same ring and lands on s1, the first server encountered clockwise. Using consistent hashing for partitioning yields two direct advantages: automatic scaling, since servers can be added or removed and the ring absorbs the change with minimal data movement, and heterogeneity support, since a server's virtual node count can scale with its actual capacity, letting more powerful servers take a proportionally larger share of the ring.

### Data replication

For high availability and reliability, data is asynchronously replicated across N servers, a configurable parameter. The servers are chosen by walking clockwise from a key's ring position and picking the first N distinct physical servers encountered. The book's example with N=3: key0 replicates to s1, s2, and s3. Because virtual nodes mean the first N ring positions might map back to fewer than N distinct physical servers, the walk specifically selects unique physical servers, not just unique ring positions. For better fault isolation, replicas are placed across distinct data centers connected by high-speed networks, since nodes within the same data center tend to fail together (shared power, shared network, shared exposure to natural disasters).

### Consistency: quorum consensus

Because data lives on multiple replicas, writes and reads need a synchronization rule. The book defines three parameters: N (replica count), W (write quorum size, the number of replicas that must acknowledge a write before it counts as successful), and R (read quorum size, the number of replicas that must respond before a read counts as successful). A subtlety worth noting explicitly: W = 1 does not mean data is written to only one server; it is still sent to all N replicas, but the coordinator only waits for one acknowledgment before declaring success.

This gives a direct, tunable latency-versus-consistency knob:

- W = 1 or R = 1 returns fast, since the coordinator only waits on the quickest replica.
- W > 1 or R > 1 improves consistency but slows down, since the coordinator waits on the slowest replica in the quorum.
- W + R > N guarantees strong consistency, because there must be at least one replica in common between every possible write quorum and every possible read quorum, ensuring a read always sees the latest acknowledged write.
- W + R <= N does not guarantee strong consistency.

Named configurations: R=1, W=N optimizes for fast reads; W=1, R=N optimizes for fast writes; W+R>N (commonly N=3, W=R=2) guarantees strong consistency; W+R<=N does not.

### Consistency models

Beyond the quorum math, the book names three points on a broader consistency spectrum: strong consistency (every read reflects the most recent write; a client never sees stale data), weak consistency (a subsequent read may not reflect the most recent write), and eventual consistency (a specific, weaker form, where given enough time all replicas converge). Strong consistency is usually enforced by blocking new reads and writes until every replica agrees on the latest write, which conflicts directly with high availability. The book recommends eventual consistency, following Dynamo's and Cassandra's own choice, accepting that concurrent writes can temporarily produce inconsistent values that must later be reconciled.

### Inconsistency resolution: versioning with vector clocks

Replication buys availability at the cost of inconsistency between replicas. Versioning treats every data modification as a new, immutable version. The book's own illustration: n1 and n2 start with the same value for `name`. Server 1 changes it to "johnSanFrancisco" and server 2 simultaneously changes it to "johnNewYork," producing two conflicting versions, v1 and v2, with no inherent way to tell which should win.

A vector clock resolves this by attaching a `[server, version]` pair per data item, written as `D([S1,v1],[S2,v2],...)`. On every write to server Si: increment vi if `[Si, vi]` already exists, otherwise create a new entry `[Si, 1]`. The book traces a full five-step example (see the worked-example note for the full diagram): D1 is written by server Sx, clock `[Sx,1]`. A later update produces D2, still through Sx, clock `[Sx,2]`. From D2, two different clients independently update to D3 (via server Sy, clock `[Sx,2],[Sy,1]`) and D4 (via server Sz, clock `[Sx,2],[Sz,1]`). A client reading both D3 and D4 detects a conflict, because D2 was independently modified by both Sy and Sz; the client reconciles the conflict and writes the result back through Sx as D5, clock `[Sx,3],[Sy,1],[Sz,1]`.

Two general rules follow from this mechanism: version Y descends from (is a true successor of, no conflict with) version X if every one of Y's per-server counters is greater than or equal to X's corresponding counter. The book's example: `D([s0,1],[s1,1])` is an ancestor of `D([s0,1],[s1,2])`. Conversely, X and Y are siblings, meaning a genuine conflict, if any participant's counter in Y is lower than its counter in X. The book's example: `D([s0,1],[s1,2])` and `D([s0,2],[s1,1])` conflict, since neither one dominates the other across every server.

Vector clocks carry two real downsides the book names directly: they push conflict-resolution complexity onto the client, which must implement that logic itself, and the list of `[server, version]` pairs can grow unbounded as more servers touch a given item. The standard fix is truncating the oldest pairs past a length threshold, which can make descendant relationships inaccurate after truncation. The book notes Amazon's own Dynamo paper reports not having hit this problem in production, treating it as an acceptable tradeoff for most companies.

### Handling failures

**Failure detection.** Trusting a single server's claim that another server is down is unsafe; detecting a real failure needs at least two independent sources of information. All-to-all multicasting is the naive approach, but it does not scale as the server count grows. The book's preferred alternative is a decentralized gossip protocol: each node keeps a membership list of member IDs and heartbeat counters, increments its own counter periodically, and periodically gossips its heartbeat state to a random set of peers, who propagate it further. If a given member's heartbeat counter has not advanced within a defined period, that member gets marked offline, and this information spreads through the same gossip mechanism.

**Handling temporary failures.** Strict quorum requirements can block operations when a replica is briefly unreachable. Sloppy quorum relaxes this: instead of enforcing the exact N-server quorum, the system picks the first W healthy servers for writes and first R healthy servers for reads while walking the ring, simply skipping offline servers. When the down server is unreachable, the next healthy server temporarily absorbs its reads and writes; this is called hinted handoff, and once the original server recovers, the standing-in server hands the accumulated data back to it.

**Handling permanent failures.** Hinted handoff only covers temporary outages. For a replica that never comes back, the system needs an anti-entropy protocol, comparing data across replicas and updating each to the newest version. A Merkle tree makes this efficient: a tree where every non-leaf node's label is the hash of its children's labels (quoted from Wikipedia[^7]), enabling efficient, minimal-data verification of large structures. The book's build process, over a toy key space from 1 to 12: divide the key space into buckets (4 in the example) as root-level nodes to bound the tree's depth; hash each key within a bucket; create one combined hash node per bucket; build upward to a single root hash from the children's hashes. Comparing two replicas' trees starts at the root: matching root hashes mean the replicas are identical; a mismatch means descending into left and right children to isolate exactly which buckets diverge, and resyncing only those. This makes the resync cost proportional to the actual difference between replicas, not to their total size. Real deployments use far coarser buckets than the toy example, for instance one million buckets across one billion keys, roughly 1,000 keys per bucket.

**Handling data center outage.** Power outages, network outages, and natural disasters can take an entire data center offline. Replicating data across multiple data centers means users retain access through the surviving data centers even if one goes fully offline.

### System architecture diagram

Pulling every component together: clients interact only through `get(key)` and `put(key, value)`; a coordinator node proxies between the client and the key-value store; nodes sit on a consistent-hashing ring; the system is fully decentralized, so nodes can be added or removed automatically; data is replicated across multiple nodes; and there is no single point of failure, since every node carries an identical set of responsibilities (no special "leader" node to lose).

### Write path

Modeled on Cassandra's architecture:[^8] a write request is first persisted to a commit log file (for durability and crash recovery), then saved into an in-memory cache. Once that cache fills or crosses a configured threshold, its contents flush to an SSTable on disk, a sorted list of key-value pairs.[^9]

### Read path

A read first checks the in-memory cache; a hit returns immediately. On a miss, the data must come from disk, and the system needs an efficient way to know which SSTable might contain the key, which is exactly what a Bloom filter provides.[^10] The full miss path: check memory (miss), check the Bloom filter to narrow down which SSTables could plausibly contain the key, read those candidate SSTables, and return the result to the client.

### Chapter summary

The book closes the chapter with a consolidated table mapping each target feature back to the specific technique that provides it (partitioning via consistent hashing, high availability via replication, inconsistency resolution via vector clocks, failure detection via gossip protocol, temporary failure handling via sloppy quorum and hinted handoff, permanent failure handling via Merkle trees, and so on), reinforcing that each requirement from Step 1 maps to a specific, named mechanism covered somewhere in the chapter.

## Core concepts (quick-scan version)

See the full CAP decision tree, quorum table, vector-clock trace, Merkle tree build, and write/read path diagrams in [[Chapter 6 - Key-Value Store Internals]].

| Requirement from Step 1 | Technique that provides it |
|---|---|
| Ability to store big data | Data partitioning via consistent hashing (Chapter 5) |
| High availability | Data replication across N servers, across data centers |
| Tunable consistency | Quorum consensus (N, W, R) |
| Automatic scaling | Consistent hashing ring absorbing server joins/leaves |
| Resolving concurrent write conflicts | Vector clocks |
| Detecting real failures | Gossip protocol |
| Staying available during a temporary failure | Sloppy quorum, hinted handoff |
| Staying consistent after a permanent failure | Anti-entropy via Merkle trees |
| Low-latency writes | Commit log plus in-memory cache, flushed to SSTable |
| Low-latency reads | In-memory cache first, Bloom filter to skip irrelevant SSTables |

## First-principles breakdown

Every mechanism in this chapter is a specific answer to the same root problem: once you replicate data for availability, you have created the possibility of disagreement, and every subsequent technique exists purely to manage that disagreement at a different timescale. Quorum consensus manages disagreement at write time (how many replicas must agree before you call a write done). Vector clocks manage disagreement after the fact, when concurrent writes already happened and need reconciling. Gossip protocol manages disagreement about membership itself (is this node even still part of the system). Merkle trees manage disagreement that has silently accumulated over time between two replicas that should be identical.

This reframes the book's quorum formula, W + R > N, as more than an arbitrary rule: it is the precise condition under which every possible read quorum and every possible write quorum are mathematically guaranteed to overlap in at least one replica. If they are guaranteed to overlap, a read is guaranteed to touch at least one replica that saw the latest acknowledged write, which is the entire mechanism behind "strong consistency" in this design. When W + R <= N, no such guaranteed overlap exists, and a read can legitimately miss every replica that has the newest value.

Where this chapter's specific choices stop being the only answer: vector clocks solve conflict detection generically, at the cost of pushing reconciliation logic onto the client and growing unboundedly with the number of distinct writers. The community research below shows CRDTs (conflict-free replicated data types) can sidestep this entirely for specific data shapes, for example a shopping cart, where concurrent operations are designed to be commutative and merge automatically with no reconciliation step needed at all. The tradeoff: CRDTs require modeling your actual data so that this commutative property holds, which the book's generic vector-clock approach never requires you to do.

## Visual representation

See the full diagram set, CAP decision tree, quorum table, vector-clock trace, Merkle tree build, write path, and read path, in [[Chapter 6 - Key-Value Store Internals]].

## Worked example, built directly in your vault

Built: [[Chapter 6 - Key-Value Store Internals]] in `Claude Notes/Books/System Design Interview/Examples/`, reproducing the book's CAP theorem decision tree, its full quorum configuration table, its five-step vector-clock trace with the ancestor and sibling rules worked out, its Merkle tree build sequence, and both the write path and read path as diagrams.

## What the book doesn't tell you, community perspective (2025-2026)

- **Vector clocks' single most common production bug** is reported as a client writing without the version context it originally read, often from a retry path that silently rebuilt the request from scratch; that write then looks concurrent with every stored version, triggering spurious conflicts the client never actually caused.
- **CRDTs (conflict-free replicated data types) are the cleaner alternative where your data shape allows it.** If concurrent operations can be modeled so that any merge order produces the same result, for example Amazon's own shopping cart as a set-union operation, conflicts resolve automatically with no client-side reconciliation logic at all. The tradeoff reported in practice: modeling arbitrary data as CRDTs is often genuinely hard, which is why vector clocks remain common despite the extra complexity they push to clients.
- **Hybrid Logical Clocks (HLCs)** are pitched in 2025-2026 sources as a middle ground: they combine physical, NTP-synced time with logical causality tracking, giving human-readable timestamps, bounded clock drift, and the same causal-ordering guarantees vector clocks provide, without the unbounded per-server growth problem.
- **Modern managed DynamoDB is architecturally different from the Dynamo paper this chapter draws on.** AWS's own 2022 DynamoDB paper states it shares the Dynamo name but little of the original architecture; current public DynamoDB documentation exposes scalar version attributes with conditional writes, not a Dynamo-style vector-clock or sibling-resolution API. Treat this chapter's design as historically accurate to the original Dynamo paper, not as a description of the AWS product sharing its name today.

## Deeper commentary, how this applies to your setup specifically

This chapter is the natural point to start a small cross-chapter glossary in your vault, since CAP theorem, quorum consensus, and eventual consistency are referenced again by name later in the book (Chapter 4 already pointed forward to this chapter's consistency section, and later chapters are likely to point back here the same way). Tracking each term's first full definition in one place will save you from re-deriving it from a partial, in-context mention in a later chapter.

## Practical and actionable takeaways

- [x] Extracted the full CAP framing, quorum formulas, vector-clock mechanics, failure-handling techniques, and write/read paths from the source EPUB.
- [x] Built a standalone worked-example note reproducing the book's own vector-clock trace and Merkle tree build step by step.
- [ ] Start a running glossary note for terms this chapter introduces (CAP theorem, quorum, eventual consistency, vector clock, gossip protocol, Merkle tree, SSTable, Bloom filter) that later chapters are likely to reference without redefining.
- [ ] When a later chapter mentions "eventual consistency" or "quorum" in passing, link back to this chapter's full treatment instead of letting the term pass unexamined.

## Questions and things to decide for your own vault

- Do you want to model one small example dataset as a CRDT yourself (the shopping-cart example is a good candidate), as a hands-on complement to this chapter's vector-clock approach?
- Should Bloom filters and SSTables get their own short standalone notes, since they are general-purpose storage-engine building blocks likely to reappear in later chapters (Chapter 9's web crawler and others touch large-scale storage again)?

## Video

[System Design Interview: Designing a Distributed Key-Value Store (Dynamo Style)](https://www.youtube.com/watch?v=j8iDY_RudJw) — directly matches this chapter's Dynamo-based design.

## Sources (external, beyond the book)

- [Vector Clocks and Conflicting Data](https://devmahmud.github.io/distributed-systems-field-guide/docs/dynamo/vector-clocks-and-conflicting-data) — Distributed Systems Field Guide
- [Hybrid Logical Clocks vs Vector Clocks: Event Ordering for Distributed IoT](https://iotdigitaltwinplm.com/hybrid-logical-clocks-vector-clocks-event-ordering-distributed-iot-2026/)
- [Vector Clocks in Depth: Tracking Causality, Detecting Concurrent Writes and Keeping the Metadata Bounded](https://aicassindra.com/blogs/distributed/dist_vector_clocks.html) — Belgavi.AI Lab

## Footnotes

[^1]: Amazon DynamoDB: https://aws.amazon.com/dynamodb/
[^2]: memcached: https://memcached.org/
[^3]: Redis: https://redis.io/
[^4]: Dynamo, Amazon's Highly Available Key-value Store: https://www.allthingsdistributed.com/files/amazon-dynamo-sosp2007.pdf
[^5]: Cassandra: https://cassandra.apache.org/
[^6]: Bigtable, A Distributed Storage System for Structured Data: https://static.googleusercontent.com/media/research.google.com/en//archive/bigtable-osdi06.pdf
[^7]: Merkle tree: https://en.wikipedia.org/wiki/Merkle_tree
[^8]: Cassandra architecture: https://cassandra.apache.org/doc/latest/architecture/
[^9]: SStable: https://www.igvita.com/2012/02/06/sstable-and-log-structured-storage-leveldb/
[^10]: Bloom filter: https://en.wikipedia.org/wiki/Bloom_filter

## Claude's pick, what I'd flag as most important

- W + R > N is the single formula worth memorizing from this entire chapter; it compresses the whole consistency-versus-availability tradeoff into one checkable condition.
- The Merkle tree's core property, comparison cost proportional to actual divergence rather than total data size, is a generally reusable idea well beyond key-value stores, worth remembering independent of this specific application.
- Vector clocks' production track record (Amazon reporting no real-world trouble despite truncation's theoretical imprecision) is a useful reminder that a technique's worst-case behavior and its practical track record can diverge; both are worth knowing.

## Related

- Previous: [[Chapter 5 - Design Consistent Hashing]]
- Next: [[Chapter 7 - Design a Unique ID Generator in Distributed Systems]]
- MOC: [[System Design Interview - MOC]]
- Worked example: [[Chapter 6 - Key-Value Store Internals]]
