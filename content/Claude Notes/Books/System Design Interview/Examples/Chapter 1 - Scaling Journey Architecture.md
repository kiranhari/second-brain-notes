---
title: "Worked Example: The Scaling Journey (Chapter 1)"
tags: [book-notes, worked-example, system-design, architecture-diagram]
---

# Worked example: the scaling journey, stage by stage

This note reproduces the book's own running example. The book scales one system from a single server to a multi-data-center, sharded, queue-backed architecture. This note redraws that progression as a set of diagrams.

You can reuse this set as a template for any later "design X" chapter in this book. Chapters on consistent hashing, key-value stores, and URL shorteners all assume this baseline architecture.

Each stage adds exactly one capability to the stage before it. This follows the book's own progression, shown in its Figures 1-1 through 1-23.

## Stage 1: single server

```mermaid
flowchart LR
    U[User] -->|DNS lookup, then HTTP| S[Single server<br/>web app + DB + cache]
```

Everything lives on one box. There is no failover. If this server goes down, the product goes down.

## Stage 2: separate web and data tiers

```mermaid
flowchart LR
    U[User] --> W[Web server]
    W --> D[(Database)]
```

Splitting web and data tiers lets each tier scale independently. At this point you must choose between a relational and a non-relational database. The chapter note has a decision table for this choice.

## Stage 3: load balancer and database replication

```mermaid
flowchart TD
    U[User] --> LB[Load balancer]
    LB --> W1[Web server 1]
    LB --> W2[Web server 2]
    W1 --> M[(Master DB<br/>writes)]
    W2 --> M
    M --> S1[(Slave DB 1<br/>reads)]
    M --> S2[(Slave DB 2<br/>reads)]
```

The load balancer removes the single point of failure in the web tier. Master and slave replication removes the single point of failure in the data tier. Writes go to the master. Reads spread across the slaves. If the master fails, the system promotes a slave.

## Stage 4: cache and CDN

```mermaid
flowchart TD
    U[User] --> CDN[CDN<br/>static JS/CSS/images]
    U --> LB[Load balancer]
    LB --> W1[Web server]
    W1 --> C{Cache hit?}
    C -- yes --> R1[Return cached data]
    C -- no --> M[(Master DB)]
    M --> CacheWrite[Store in cache] --> R2[Return data]
```

The cache absorbs read load before it reaches the database. This is the read-through strategy. The CDN removes static assets from the web tier entirely. It serves each asset from the location nearest the user.

## Stage 5: stateless web tier

```mermaid
flowchart LR
    subgraph Stateful [Stateful, avoid]
        UA[User A] --> SA[Server 1<br/>holds A's session]
        UB[User B] --> SB[Server 2<br/>holds B's session]
    end
```

```mermaid
flowchart LR
    subgraph Stateless [Stateless, prefer]
        U1[Any user] --> LB2[Load balancer]
        LB2 --> WA[Web server A]
        LB2 --> WB[Web server B]
        WA --> SS[(Shared session store<br/>Redis / NoSQL)]
        WB --> SS
    end
```

Moving session state out of the web server into a shared store means any server can answer any request. This property makes autoscaling possible. Autoscaling adds or removes servers on demand.

## Stage 6: multi-data-center

```mermaid
flowchart TD
    U1[US-East users] -->|geoDNS, x percent| DC1[Data center 1, US-East]
    U2[US-West users] -->|geoDNS, 100-x percent| DC2[Data center 2, US-West]
    DC1 <-->|data sync| DC2
```

If DC2 fails, geoDNS routes all traffic to DC1. The hard part is not the routing. The hard part is keeping data synchronized across regions, so a failover does not land users on stale data.

## Stage 7: message queue for decoupling

```mermaid
flowchart LR
    P[Producer<br/>web server] -->|publish job| Q[(Message queue)]
    Q -->|consume job| C1[Worker 1]
    Q -->|consume job| C2[Worker 2]
```

The producer and the consumer scale independently. They do not need to be online at the same time. Queue depth is the signal for adding or removing workers.

## Stage 8: sharded database

```mermaid
flowchart TD
    W[Web server] --> H{hash user_id % 4}
    H -- 0 --> Shard0[(Shard 0)]
    H -- 1 --> Shard1[(Shard 1)]
    H -- 2 --> Shard2[(Shard 2)]
    H -- 3 --> Shard3[(Shard 3)]
```

The sharding key decides where each row of data lands. This example uses `user_id`. A bad key choice causes the celebrity, or hotspot, problem. The chapter note's community research section explains how real systems patch around this problem.

## Full composite architecture (equivalent to the book's Figure 1-19)

```mermaid
flowchart TD
    U[Users] --> CDN[CDN, static assets]
    U --> LB[Load balancer]
    LB --> W1[Web server 1, stateless]
    LB --> W2[Web server 2, stateless]
    W1 --> SS[(Shared session store)]
    W2 --> SS
    W1 --> Cache{Cache}
    W2 --> Cache
    Cache --> M[(Master DB)]
    M --> Sl1[(Slave DB)]
    M --> Sl2[(Slave DB)]
    W1 -->|async jobs| Q[(Message queue)]
    Q --> Wk1[Worker]
    M -.sharded across.-> Shards[(Shard 0..N)]
    Mon[Logging, metrics, automation] -.observes.-> W1
    Mon -.observes.-> M
```

## How to reuse this template

Every later "design X" chapter in this book builds on some subset of this diagram. Each of those chapters adds one component specific to its own problem. Later chapters cover:

- A rate limiter
- A key-value store
- A URL shortener
- A web crawler
- A notification system
- A news feed
- A chat system
- An autocomplete system
- YouTube
- Google Drive

When you build those chapter notes, copy the relevant stage diagram above instead of drawing a new architecture from scratch. Link back to this note.

## Related
- Chapter note: [[Chapter 1 - Scale From Zero to Millions of Users]]
- MOC, built once all chapters are done: [[System Design Interview - MOC]]
