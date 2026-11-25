---
title: "Worked Example: Video Upload and Transcoding Pipeline"
tags: [book-notes, worked-example, system-design, video-streaming, transcoding]
---

# Worked example: from upload to playable stream

## Capacity and cost math, reproduced

- 5 million DAU, 5 videos watched per day each, 10% of users upload 1 video per day.
- Average video size: 300 MB.
- Daily upload storage: 5,000,000 * 10% * 300 MB = 150 TB per day.
- CDN egress cost, assuming all US traffic at $0.02/GB (AWS CloudFront pricing): 5,000,000 * 5 videos * 0.3 GB * $0.02 = $150,000 per day, for streaming alone.

## The two parallel upload flows, reproduced

```mermaid
flowchart TD
    subgraph FlowA [Flow a: upload the actual video]
        A1[1. Video uploaded to<br/>original storage] --> A2[2. Transcoding servers<br/>fetch and transcode]
        A2 --> A3a[3a. Transcoded video<br/>to transcoded storage]
        A2 --> A3b[3b. Completion event<br/>to completion queue]
        A3a --> A3a1[Distributed to CDN]
        A3b --> A3b1[Completion handler<br/>workers pull events]
        A3b1 --> A3b2[Update metadata<br/>DB and cache]
        A3a1 --> A4[4. Client told video<br/>is ready to stream]
        A3b2 --> A4
    end
    subgraph FlowB [Flow b: update metadata, in parallel]
        B1[Client sends metadata:<br/>filename, size, format] --> B2[API servers write to<br/>metadata cache and DB]
    end
```

Both flows run concurrently, not sequentially, since the metadata write does not depend on transcoding finishing.

## Video transcoding architecture, six components

```mermaid
flowchart LR
    V[Raw video] --> Pre[Preprocessor:<br/>split into GOPs,<br/>generate DAG,<br/>cache segments]
    Pre --> Sched[DAG scheduler:<br/>splits DAG into<br/>staged tasks]
    Sched --> RM[Resource manager:<br/>task queue, worker queue,<br/>running queue]
    RM --> TW[Task workers:<br/>run individual tasks]
    TW --> Temp[(Temporary storage:<br/>metadata cached in memory,<br/>video/audio in blob storage)]
    TW --> Out[Encoded video output,<br/>e.g. funny_720p.mp4]
```

## Example DAG for one video, reproduced

```mermaid
flowchart TD
    Orig[Original video] --> V[Video track]
    Orig --> Aud[Audio track]
    Orig --> Meta[Metadata]
    V --> Enc1[Video encoding: 1080p]
    V --> Enc2[Video encoding: 720p]
    V --> Thumb[Thumbnail generation]
    Aud --> AudEnc[Audio encoding]
```

A content creator's own configuration determines which of these stages actually run (for example, whether a watermark stage is included, or whether thumbnails are user-supplied or auto-generated).

## Container versus codec, the distinction

| Term | What it means | Examples |
|---|---|---|
| Container | The "basket" holding video, audio, and metadata together | .avi, .mov, .mp4 |
| Codec | The compression/decompression algorithm that shrinks video size while preserving quality | H.264, VP9, HEVC |

## Resource manager's four parts, reproduced

| Component | Role |
|---|---|
| Task queue | Priority queue of tasks waiting to run |
| Worker queue | Priority queue tracking worker utilization |
| Running queue | Tracks which task is bound to which worker, currently in flight |
| Task scheduler | Pulls the highest-priority task, finds the best available worker, binds them, and removes the pairing from the running queue once complete |

## Speed optimizations, reproduced

| Optimization | How it works |
|---|---|
| Parallelize upload | Split the video into GOP-aligned chunks client-side; upload chunks in parallel, and resume only the failed chunk if an upload fails, instead of restarting the whole file |
| Geographically distributed upload centers | Route a user to the nearest upload center (implemented via CDN), for example North America vs. Asia, cutting upload latency |
| Message queues between pipeline stages | Decouples each stage so the encoding module no longer has to wait synchronously on the download module's output; it can process any events already sitting in the queue in parallel |

## Safety optimizations, reproduced

| Mechanism | Purpose |
|---|---|
| Pre-signed upload URL | Client requests a scoped, temporary upload URL from API servers first, then uploads directly to blob storage using that URL, so only authorized clients can write to the right location (AWS calls this a pre-signed URL; Azure calls the equivalent a Shared Access Signature) |
| DRM (Apple FairPlay, Google Widevine, Microsoft PlayReady) | Industry-standard systems restricting who can decrypt and play protected content |
| AES encryption with an authorization policy | Video is encrypted; only authorized users' clients can decrypt it on playback |
| Visual watermarking | An image overlay (for example a logo) identifying the content's origin |

## Cost-saving optimizations, reproduced

Grounded in the long-tail distribution of video popularity (a few videos get most views, most get very few):

1. Serve only the most popular videos from CDN; serve everything else from cheaper, high-capacity storage servers.
2. Skip pre-encoding every resolution for unpopular content; encode short, rarely watched videos on demand instead.
3. Skip global distribution for videos popular only in one region.
4. At large scale, build an owned CDN and partner directly with ISPs (Netflix's own approach), trading a very large upfront build cost for lower long-run bandwidth costs.

## Error-handling playbook, reproduced

| Component failure | Response |
|---|---|
| Upload error | Retry a few times |
| Old client cannot split by GOP | Server performs the split instead |
| Transcoding error | Retry |
| Preprocessor error | Regenerate the DAG diagram |
| DAG scheduler error | Reschedule the task |
| Resource manager queue down | Fail over to a replica |
| Task worker down | Retry the task on a different worker |
| API server down | Stateless, so traffic simply routes to another instance |
| Metadata cache node down | Data is replicated; read from a surviving replica, bring up a replacement |
| Metadata DB master down | Promote a slave to master |
| Metadata DB slave down | Read from another slave; bring up a replacement |

## Related
- Chapter note: [[Chapter 14 - Design YouTube]]
- MOC, built once all chapters are done: [[System Design Interview - MOC]]
