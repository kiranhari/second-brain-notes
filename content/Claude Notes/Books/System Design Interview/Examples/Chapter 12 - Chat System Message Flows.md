---
title: "Worked Example: Chat System Message Flows"
tags: [book-notes, worked-example, system-design, chat-system, websocket]
---

# Worked example: connecting, messaging, and presence

## Why WebSocket wins over polling and long polling

| Technique | How it works | Main weakness |
|---|---|---|
| Polling | Client asks the server "anything new?" on a fixed interval | Wastes server resources; most polls return nothing |
| Long polling | Client holds a request open until a message arrives or it times out | Sender/receiver may land on different stateless servers; server cannot reliably detect disconnects; still inefficient for quiet users |
| WebSocket | One persistent, bidirectional connection, upgraded from an initial HTTP handshake | Requires careful persistent-connection management server-side, but solves every problem above at once |

WebSocket works through most firewalls because it reuses ports 80/443, the same ports HTTP/HTTPS already use.

## Service discovery (login), reproduced

```mermaid
flowchart TD
    A[1. User A logs in] --> B[2. Load balancer -> API servers]
    B --> C[3. API servers authenticate,<br/>then ask service discovery<br/>for the best chat server]
    C --> D[Service discovery returns:<br/>chat server 2]
    D --> E[4. User A opens a<br/>WebSocket to chat server 2]
```

Service discovery (Zookeeper in the book's example) picks a server based on criteria like geographic location and current server capacity, and coordinates with the chat service to avoid overloading any one server.

## One-on-one message flow, reproduced

```mermaid
flowchart TD
    A[1. User A sends message<br/>to chat server 1] --> B[2. Chat server 1 gets<br/>a message ID from ID generator]
    B --> C[3. Message sent to<br/>message sync queue]
    C --> D[4. Message persisted<br/>to key-value store]
    D --> E{User B online?}
    E -- yes --> F[5a. Forwarded to chat server 2,<br/>where User B is connected]
    E -- no --> G[5b. Push notification sent<br/>via PN servers]
    F --> H[6. Delivered to User B<br/>over persistent WebSocket]
```

## Multi-device sync, reproduced

Each device tracks its own `cur_max_message_id`. A message counts as new for a given device if:

1. Its recipient ID matches the currently logged-in user.
2. Its message ID (from the key-value store) is greater than that device's `cur_max_message_id`.

Because each device keeps its own counter, a phone and a laptop can be at different points in the same conversation and each independently catches up by querying the key-value store for anything newer than its own counter.

## Small group chat flow, reproduced

```mermaid
flowchart TD
    A[User A sends message<br/>to a 3-person group] --> B["Copied into each<br/>member's own message<br/>sync queue (inbox)"]
    B --> C[User B's inbox]
    B --> D[User C's inbox]
    C --> E[User B's client checks<br/>only its own inbox]
    D --> F[User C's client checks<br/>only its own inbox]
```

This "one copy per recipient's inbox" design is deliberately simple and only works because group size is capped (100 in this chapter's scope, WeChat caps at 500). At much larger group sizes, copying a message into every member's inbox becomes prohibitively expensive.

## Message ID generation strategies, compared

| Strategy | Uniqueness scope | Pros | Cons |
|---|---|---|---|
| Database auto_increment | Global | Simple, built into relational DBs | Not available in most NoSQL stores |
| Global 64-bit sequence (snowflake) | Global | Strong ordering guarantee across the whole system | More complex to implement and operate |
| Local sequence number | Per-conversation (1-on-1 or group) | Simple; ordering within a conversation is all that is actually required | Does not provide a global total ordering across unrelated conversations |

The book notes local IDs are sufficient, since the only ordering guarantee a user actually needs is "within this conversation," not "across the entire system."

## Online presence: heartbeat mechanism, reproduced

```mermaid
flowchart TD
    C[Client] -->|heartbeat every 5s| P[Presence server]
    P --> Check{Heartbeat received<br/>within x = 30s?}
    Check -- yes --> Online[Status: online]
    Check -- no --> Offline[Status: offline]
```

Why not just mark a user offline the instant their connection drops: real connections flap (for example, a phone losing signal briefly in a tunnel), and naive instant status flips would make the presence indicator flicker constantly, a poor experience. The heartbeat's timeout window absorbs brief, harmless disconnects.

## Online status fanout, reproduced

```mermaid
flowchart LR
    A[User A comes online] --> Pub[Publish to pub/sub channels:<br/>A-B, A-C, A-D]
    Pub --> B[User B, subscribed to A-B]
    Pub --> C[User C, subscribed to A-C]
    Pub --> D[User D, subscribed to A-D]
```

This per-friend-pair channel design works at small scale (WeChat caps groups at 500 for this reason). At real scale, for example a 100,000-member group, broadcasting every status change to every member would generate 100,000 events per change; the practical fix is fetching presence only on demand (when a user opens a group or manually refreshes), not proactively.

## Related
- Chapter note: [[Chapter 12 - Design a Chat System]]
- Reuses: [[Chapter 7 - Snowflake ID Bit Layout]] (message ID generation), [[Chapter 10 - Notification System Flow]] (offline push notifications)
- MOC, built once all chapters are done: [[System Design Interview - MOC]]
