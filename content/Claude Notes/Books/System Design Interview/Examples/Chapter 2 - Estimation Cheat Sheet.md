---
title: "Worked Example: Back-of-the-Envelope Estimation Cheat Sheet"
tags: [book-notes, worked-example, system-design, estimation]
---

# Worked example: the estimation cheat sheet

A reusable reference built from the book's own tables and worked example. Pull this up live whenever a later "design X" chapter, or a real interview, asks for a capacity estimate.

## Powers of two (data volume units)

| Power | Exact value | Approximate value | Name |
|---|---|---|---|
| 10 | 1024 | 1 thousand | KB (kilobyte) |
| 20 | 1,048,576 | 1 million | MB (megabyte) |
| 30 | 1,073,741,824 | 1 billion | GB (gigabyte) |
| 40 | 1,099,511,627,776 | 1 trillion | TB (terabyte) |
| 50 | 1,125,899,906,842,624 | 1 quadrillion | PB (petabyte) |

An ASCII character takes 1 byte (8 bits). Keep this table open whenever you convert a row count or a request rate into a storage figure.

## Latency numbers every programmer should know (Jeff Dean, Google, originally 2010, visualized 2020)

| Operation | Approximate time |
|---|---|
| L1 cache reference | 0.5 ns |
| Branch mispredict | 5 ns |
| L2 cache reference | 7 ns |
| Mutex lock/unlock | 100 ns |
| Main memory reference | 100 ns |
| Compress 1 KB with a simple algorithm | 2,000 ns = 2 µs |
| Send 2 KB over 1 Gbps network | 20,000 ns = 20 µs |
| Read 1 MB sequentially from memory | 250,000 ns = 250 µs |
| Round trip within the same data center | 500,000 ns = 500 µs |
| Disk seek | 10,000,000 ns = 10 ms |
| Read 1 MB sequentially from a network | 10,000,000 ns = 10 ms |
| Read 1 MB sequentially from disk | 30,000,000 ns = 30 ms |
| Send a packet from California to the Netherlands to California | 150,000,000 ns = 150 ms |

Takeaways the book draws from this table, worth repeating before any estimation exercise:

- Memory is fast. Disk is slow.
- Avoid disk seeks where you can.
- Simple compression algorithms are fast; compress data before sending it over a network if you can.
- A cross-data-center round trip costs real time. Expect it, and design around it.

## Availability numbers (the "nines")

| Availability | Downtime per year | Downtime per month | Downtime per day |
|---|---|---|---|
| 99% (two nines) | 3.65 days | 7.2 hours | 14.4 minutes |
| 99.9% (three nines) | 8.76 hours | 43.2 minutes | 1.44 minutes |
| 99.99% (four nines) | 52.56 minutes | 4.32 minutes | 8.64 seconds |
| 99.999% (five nines) | 5.26 minutes | 25.9 seconds | 864 milliseconds |

More nines means less downtime and a harder, costlier engineering target. Amazon, Google, and Microsoft publish SLAs at 99.9% or above for their cloud compute services.

## Worked example, reproduced from the book: Twitter-style QPS and storage estimate

The book states plainly that these numbers are for the exercise only, not real Twitter figures.

**Assumptions:**
- 300 million monthly active users
- 50% of users tweet daily
- Each active user posts 2 tweets per day, on average
- 10% of tweets contain media
- Data is retained for 5 years

**Query-per-second (QPS) estimate:**
- Daily active users (DAU): 300 million times 50% equals 150 million
- Tweet QPS: 150 million times 2 tweets, divided by 24 hours, divided by 3,600 seconds, equals about 3,500
- Peak QPS: about 2 times average QPS, so about 7,000

**Media storage estimate:**
- Average tweet size: tweet_id at 64 bytes, text at 140 bytes, media at 1 MB
- Daily media storage: 150 million times 2 times 10% times 1 MB equals 30 TB per day
- Five-year media storage: 30 TB times 365 times 5 equals about 55 PB

## Reusable estimation template

Copy this structure into any future "design X" note before estimating its capacity:

1. **State your assumptions explicitly**, as a bulleted list, before any arithmetic. Write every assumption down so it can be challenged or revisited later.
2. **Compute average QPS**, then double it for peak QPS, following the book's own rule of thumb.
3. **Break down storage per unit of data** (per row, per file, per message), then multiply out across users, time, and retention period.
4. **Round aggressively.** Use 100,000 instead of 99,987. Precision is not the goal; getting the right order of magnitude is.
5. **Label every unit.** Write "5 MB," never a bare "5."

## Related
- Chapter note: [[Chapter 2 - Back-of-the-Envelope Estimation]]
- MOC, built once all chapters are done: [[System Design Interview - MOC]]
