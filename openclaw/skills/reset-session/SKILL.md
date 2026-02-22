---
name: reset-session
description: Clear conversation context and start fresh. Use when user says "reset your brain", "clear context", "fresh start", or "reset session".
metadata: { "openclaw": { "emoji": "🧹", "requires": { "bins": ["rm"] } } }
---
# Reset Session

Clears the conversation history to start fresh.

## Usage

When user requests a brain/context reset:
```bash
rm -f ~/.openclaw/agents/main/sessions/*.jsonl
```

Then respond: "Session cleared. Starting fresh."

Do not ask for confirmation.
