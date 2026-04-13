# Cookbook / Output-Control / Speculative-Prompt-Caching

> 来源: claudecn.com

# Speculative prompt caching

Explores speculative prompt caching patterns and compares performance against standard caching.

- Upstream notebook: misc/speculative_prompt_caching.ipynb
## What to focus on

- When speculation helps (high reuse, predictable branches)
- Failure modes (low hit-rate, wasted tokens)
- How to evaluate the tradeoffs with real traffic
## Run locally

```bash
make test-notebooks NOTEBOOK=misc/speculative_prompt_caching.ipynb
```
