---
title: "Worked Example: News Feed Fanout Flows"
tags: [book-notes, worked-example, system-design, news-feed, fanout]
---

# Worked example: publishing and retrieving a feed post

## Feed publishing flow, reproduced

```mermaid
flowchart TD
    U[User posts Hello] --> LB[Load balancer] --> WS[Web servers]
    WS --> PS["Post service<br/>(persist to DB + cache)"]
    PS --> FO[Fanout service]
    FO --> NC[(News feed cache,<br/>per-friend)]
    PS --> Notif[Notification service<br/>alerts friends]
```

## Fanout service, internal steps

```mermaid
flowchart TD
    A[1. Fetch friend IDs<br/>from graph database] --> B[2. Get friend info from<br/>user cache, filter by<br/>mute/privacy settings]
    B --> C[3. Send friend list +<br/>new post ID to message queue]
    C --> D[4. Fanout workers consume<br/>from queue]
    D --> E["5. Store <post_id, user_id><br/>in news feed cache"]
```

The news feed cache stores only IDs, never full post or user objects, specifically to keep memory consumption bounded. A configurable size limit per user further caps memory use, since most users only ever look at their most recent feed content.

## Fanout on write vs fanout on read, compared

| | Fanout on write (push) | Fanout on read (pull) |
|---|---|---|
| When work happens | At post time, pre-computed per friend | At read time, on demand |
| Read speed | Fast, feed is already assembled | Slow, feed is assembled live |
| Cost for inactive users | Wasted, pre-computes feeds nobody reads | None, nothing computed until they log in |
| Cost for a user with huge follower count | Very high, the hotkey problem: fanning out to millions of followers on every post | Low, no fanout cost regardless of follower count |
| Book's verdict | Use for the majority of users | Use specifically for celebrities / huge-follower accounts |

## The hybrid model, reproduced

```mermaid
flowchart TD
    Post[New post] --> Check{Author has<br/>a huge follower count?}
    Check -- no, normal user --> Push[Fanout on write:<br/>push to every follower's cache now]
    Check -- yes, celebrity --> Pull[Fanout on read:<br/>followers pull this post at read time]
    Push --> Merge[Follower's feed]
    Pull --> Merge
```

Consistent hashing (Chapter 5) helps distribute the resulting read/write load more evenly once this split is in place.

## News feed retrieval flow, reproduced

```mermaid
flowchart TD
    A[1. User requests /v1/me/feed] --> B[2. Load balancer]
    B --> C[3. Web servers call<br/>news feed service]
    C --> D[4. Fetch post ID list<br/>from news feed cache]
    D --> E["5. Hydrate full objects<br/>(user cache + post cache)"]
    E --> F[6. Return fully hydrated<br/>JSON feed to client]
```

Media content (images, video) is served from a CDN, not rebuilt on every request, consistent with Chapter 1's CDN pattern.

## The five-layer cache architecture, reproduced

| Cache layer | What it stores |
|---|---|
| News Feed | IDs of posts in each user's feed |
| Content | Full post data; popular content promoted to a hot cache |
| Social Graph | User relationship (friend/follow) data |
| Action | Whether a user liked, replied to, or otherwise acted on a post |
| Counters | Like counts, reply counts, follower/following counts |

## Related
- Chapter note: [[Chapter 11 - Design a News Feed System]]
- Reuses: [[Chapter 5 - Consistent Hashing Ring Walkthrough]] (distributing fanout load), [[Chapter 10 - Notification System Flow]] (notifying friends of new posts)
- MOC, built once all chapters are done: [[System Design Interview - MOC]]
