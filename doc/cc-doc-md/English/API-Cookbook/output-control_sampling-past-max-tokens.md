# Cookbook / Output-Control / Sampling-Past-Max-Tokens

> 来源: claudecn.com

# Sampling past max tokens

Strategies for producing very long outputs beyond a single-call limit, while keeping the result coherent.

- Upstream notebook: misc/sampling_past_max_tokens.ipynb
## What to focus on

- Chunked generation plans (outline → sections)
- Continuation prompts that preserve structure
- How to stop safely (avoid runaway generation)
## Run locally

```bash
make test-notebooks NOTEBOOK=misc/sampling_past_max_tokens.ipynb
```
