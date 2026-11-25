---
title: "Worked Example: Google Drive Upload and Sync Flows"
tags: [book-notes, worked-example, system-design, file-storage, delta-sync]
---

# Worked example: block servers, upload flow, and sync conflict resolution

## Capacity math, reproduced

- 50 million signed-up users, 10 million DAU, each with 10 GB free space.
- Total space allocated: 50,000,000 * 10 GB = 500 petabytes.
- Users upload 2 files per day, average 500 KB each; 1:1 read:write ratio.
- Upload QPS: 10,000,000 * 2 / 24 / 3600 = about 240.
- Peak QPS: 2 * 240 = about 480.

## The single-server-to-scaled-out journey, reproduced

```mermaid
flowchart LR
    A["Single server:<br/>web server + MySQL + 1TB disk"] --> B[Storage fills up]
    B --> C[Shard storage by user_id]
    C --> D[Still a data-loss risk<br/>on storage server outage]
    D --> E[Move files to Amazon S3,<br/>same-region + cross-region replication]
    E --> F[Add load balancer]
    F --> G[Scale web servers<br/>independently]
    G --> H[Move metadata DB out,<br/>replicate + shard it]
```

Each step solves exactly one concrete failure the previous step exposed, not a hypothetical one: this is the book's own "pull an all-nighter, fix the fire, worry about the next fire" narrative compressed into a diagram.

## Block servers: splitting, compressing, encrypting, reproduced

```mermaid
flowchart TD
    F[New file] --> Split[Split into blocks,<br/>max 4MB each]
    Split --> Compress[Compress each block<br/>, gzip/bzip2 for text,<br/>different algorithms for media]
    Compress --> Encrypt[Encrypt each block]
    Encrypt --> Upload[Upload to cloud storage]
```

## Delta sync, reproduced

```mermaid
flowchart LR
    V1["Original file:<br/>block1, block2, block3, block4, block5"] --> Edit[User edits file]
    Edit --> V2["New version:<br/>block1, block2', block3, block4, block5'"]
    V2 --> Diff{Only block2 and<br/>block5 changed}
    Diff --> Up[Upload only block2' and block5']
```

Only modified blocks transfer, not the whole file, directly cutting bandwidth for large, frequently edited files.

## Upload flow, both parallel requests reproduced

```mermaid
flowchart TD
    subgraph Meta [Add file metadata]
        M1[1. Client sends new-file metadata] --> M2[2. Store metadata,<br/>status = pending]
        M2 --> M3[3. Notify notification service]
        M3 --> M4[4. Notification service<br/>tells other clients]
    end
    subgraph Blocks [Upload file to cloud storage]
        B1[2.1 Client uploads content<br/>to block servers] --> B2[2.2 Split, compress,<br/>encrypt, upload blocks]
        B2 --> B3[2.3 Cloud storage triggers<br/>completion callback]
        B3 --> B4[2.4 Status changed<br/>to uploaded]
        B4 --> B5[2.5-2.6 Notification service<br/>tells other clients: fully uploaded]
    end
```

## Download flow, reproduced

```mermaid
flowchart TD
    A[1. Notification service tells<br/>client a file changed elsewhere] --> B[2. Client requests metadata]
    B --> C[3-4. API servers fetch metadata<br/>from metadata DB]
    C --> D[5. Client receives metadata]
    D --> E[6. Client requests blocks<br/>from block servers]
    E --> F[7-8. Block servers fetch blocks<br/>from cloud storage]
    F --> G[9. Client downloads blocks,<br/>reconstructs file]
```

## Sync conflict resolution, reproduced

```mermaid
flowchart TD
    U1[User 1 edits file] --> P{Processed first}
    U2[User 2 edits same file<br/>at the same time] --> P
    P -- User 1 processed first --> Win[User 1's update succeeds]
    P -.User 2's update.-> Conflict[User 2 gets a sync conflict]
    Conflict --> Present["Present both copies:<br/>User 2's local copy +<br/>latest server version"]
    Present --> Resolve[User 2 manually merges<br/>or chooses one version]
```

First-processed-wins is the rule; the loser never gets silently overwritten, they get a choice instead.

## Why long polling, not WebSocket, for notifications

| Factor | Long polling | WebSocket |
|---|---|---|
| Direction needed | Server to client only (file changed, go pull it) | Bidirectional |
| Frequency and burstiness | Infrequent, no bursts | Suited to frequent, bidirectional traffic (for example chat) |
| Book's choice | Chosen | Not chosen, deemed unnecessary complexity for this use case |

## Storage-saving techniques, reproduced

| Technique | How it saves space |
|---|---|
| De-duplicate blocks | Two blocks with the same hash are stored once, referenced by multiple files/versions |
| Cap version history | Keep only N most recent versions; oldest is evicted on overflow |
| Weight recent versions more | For heavily-edited files, skip saving every single edit; favor recent versions over an exhaustive history |
| Move cold data to cheaper storage | Infrequently accessed files move to a cold tier (for example Amazon S3 Glacier), far cheaper than active storage |

## Related
- Chapter note: [[Chapter 15 - Design Google Drive]]
- MOC, built once all chapters are done: [[System Design Interview - MOC]]
