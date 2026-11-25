---
tags: [resource, ai, checklist]
---
# AI Second Brain — Setup Checklist (from Chapter 8 + 2026 community research)

A reference checklist rather than a template — there's no file to generate, just plugin configuration inside the Obsidian app.

## Option A: Smart Connections + Copilot, fully local (recommended for privacy, matches [[Gloss Local]]'s philosophy)
- [ ] Install **Ollama** (already part of your [[Gloss Local]] stack — one less new thing to learn)
- [ ] Pull a local embedding model (`nomic-embed-text` or `mxbai-embed-large`) and a local chat model
- [ ] Install **Smart Connections** plugin → point it at the local Ollama endpoint instead of OpenAI
- [ ] Install **Copilot for Obsidian** plugin → point its backend at Ollama's OpenAI-compatible endpoint (`http://127.0.0.1:11434`)
- [ ] Disable optional telemetry in both plugins' settings
- [ ] For strict privacy, exclude sensitive folders (if any) from the Smart Connections index in its settings

## Option B: Smart Connections + Copilot via OpenAI API (book's default; simpler, costs a few cents/month, data leaves your machine)
- [ ] Install Smart Connections, add an OpenAI API key from platform.openai.com
- [ ] Install Copilot, same key or a different supported provider
- [ ] Enable "Smart View" sidebar for passive related-notes suggestions while writing

## Either way
- [ ] Open Smart Chat and ask a real question once you have ~20+ notes — semantic search needs *some* content to be useful
- [ ] Re-read [[Chapter 8 - AI Inside Your Second Brain#The Limits of AI in Your Second Brain]] before leaning on AI-generated permanent notes — the book's own warning is that writing *is* the thinking, not just the output

## Performance expectations (2026 community data, Smart Connections + nomic-embed-text, M3 Pro)
| Vault size | Initial indexing time |
|---|---|
| 1,000 notes | ~2 min |
| 5,000 notes | ~10 min |
| 10,000 notes | ~25 min |
| 20,000 notes | ~75 min |

This vault is nowhere near that scale yet — indexing will be near-instant for now.
