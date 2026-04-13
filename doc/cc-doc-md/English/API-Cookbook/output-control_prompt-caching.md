# Cookbook / Output-Control / Prompt-Caching

> 来源: claudecn.com

# Prompt caching

Demonstrates prompt caching through the Claude API, including baseline vs cached calls and cache hit behavior.

- Upstream notebook: misc/prompt_caching.ipynb
## What to focus on

- What should be in the cacheable prefix (stable context)
- How to measure savings (tokens/latency) vs complexity
- Combining caching with retrieval (document context as a cached block)
## Run locally

```bash
make test-notebooks NOTEBOOK=misc/prompt_caching.ipynb
```
