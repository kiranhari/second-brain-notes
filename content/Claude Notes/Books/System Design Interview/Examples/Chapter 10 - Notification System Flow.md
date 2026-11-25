---
title: "Worked Example: Notification System Flow"
tags: [book-notes, worked-example, system-design, notifications]
---

# Worked example: from trigger to delivered notification

## Initial design and its three problems

```mermaid
flowchart LR
    S[Services 1 to N] --> N[Single notification server]
    N --> TP[Third-party services]
    TP --> Dev[iOS / Android / SMS / Email]
```

Problems: single point of failure, hard to scale database/cache/processing independently, and a performance bottleneck from handling everything in one server.

## Improved design, reproduced

```mermaid
flowchart LR
    S[Services 1 to N] --> NS[Notification servers<br/>stateless, horizontally scaled]
    NS --> Cache[(Cache:<br/>user info, device info, templates)]
    NS --> DB[(DB:<br/>user, notification, settings)]
    NS --> Q1[(iOS PN queue)]
    NS --> Q2[(Android PN queue)]
    NS --> Q3[(SMS queue)]
    NS --> Q4[(Email queue)]
    Q1 --> W1[Workers] --> APNS[APNs] --> iOSDev[iOS device]
    Q2 --> W2[Workers] --> FCM[FCM] --> AndroidDev[Android device]
    Q3 --> W3[Workers] --> SMSProvider[Twilio / Nexmo] --> Phone[Phone]
    Q4 --> W4[Workers] --> EmailProvider[Sendgrid / Mailchimp] --> Inbox[Email inbox]
```

A separate queue per notification type means an outage in one third-party service (for example FCM) never blocks SMS or email delivery.

## The six-step send flow, reproduced

1. A service calls the notification server's API to send a notification.
2. The notification server fetches metadata (user info, device token, settings) from cache or database.
3. A notification event is published to the matching queue (for example, an iOS push goes to the iOS PN queue).
4. Workers pull events from the queue.
5. Workers call the relevant third-party service.
6. The third-party service delivers to the user's device.

## Reliability: the dedupe check, reproduced

```mermaid
flowchart TD
    E[Notification event arrives] --> Seen{Event ID seen before?}
    Seen -- yes --> Discard[Discard, already sent]
    Seen -- no --> Send[Send notification]
```

The book is explicit that exactly-once delivery is not achievable in a distributed system; the dedupe check reduces, but does not eliminate, the chance of a duplicate.

## Final design, with every deep-dive component added

```mermaid
flowchart TD
    S[Services] --> NS["Notification servers<br/>(+ auth, + rate limiting)"]
    NS --> Cache[(Cache)]
    NS --> DB[(DB + notification log)]
    NS --> Queues[(Per-type message queues)]
    Queues --> Workers[Workers]
    Workers -->|on failure| Retry[Retry, bounded attempts]
    Retry --> Queues
    Workers --> TP[Third-party services]
    TP --> Devices[iOS / Android / SMS / Email]
    Workers --> Monitor[Queue depth monitoring]
    Devices --> Analytics[Event tracking:<br/>open rate, click rate]
```

## Notification settings table, reproduced

| Field | Type | Purpose |
|---|---|---|
| user_id | bigint | Which user this setting applies to |
| channel | varchar | push notification, email, or SMS |
| opt_in | boolean | Whether the user accepts this channel |

Checked before every send: a user who opted out of a channel should never receive a notification through it.

## Related
- Chapter note: [[Chapter 10 - Design a Notification System]]
- MOC, built once all chapters are done: [[System Design Interview - MOC]]
