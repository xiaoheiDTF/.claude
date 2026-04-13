# Cookbook / Output-Control / Moderation-Filter

> 来源: claudecn.com

# Moderation filter

Builds a moderation filter with Claude and explores improvements (customization, examples, and “chain of thought” style approaches).

- Upstream notebook: misc/building_moderation_filter.ipynb
## What to focus on

- Defining policy categories and thresholds
- Separating “classify” from “act” (don’t auto-enforce blindly)
- Evaluating false positives/negatives with real data
## Run locally

```bash
make test-notebooks NOTEBOOK=misc/building_moderation_filter.ipynb
```
