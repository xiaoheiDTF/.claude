# Cookbook / Tool-Use / Session-Memory-Compaction

> 来源: claudecn.com

# Session memory compaction

This notebook focuses on **manual, proactive session memory management** for conversational applications: build a compact “session memory” in the background so you can compact instantly when context starts getting tight.

- Upstream notebook: misc/session_memory_compaction.ipynb
## When to use this

- You run a long-lived chat experience (coding assistant, support agent, writing tool).
- You want compaction to feel instant (no “please wait while we summarize” moment).
- You need more control than “automatic compaction” (what gets preserved, what gets dropped, when it runs).
## What to focus on

- Session memory prompt design: preserve goals, constraints, decisions, and “known facts”
- Background memory refresh (threading) so compaction is ready on demand
- Prompt caching to reduce background update cost
## Related notebooks

- Automatic compaction in agentic workflows: tool_use/automatic-context-compaction.ipynb
- Memory patterns and safety boundaries: tool_use/memory_cookbook.ipynb
## Run locally

```bash
make test-notebooks NOTEBOOK=misc/session_memory_compaction.ipynb
```
