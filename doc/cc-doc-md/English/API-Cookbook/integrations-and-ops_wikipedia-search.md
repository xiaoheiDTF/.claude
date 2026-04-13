# Cookbook / Integrations-And-Ops / Wikipedia-Search

> 来源: claudecn.com

# Iterative Wikipedia search

Demonstrates iterative searching over Wikipedia content, useful as a lightweight external knowledge source.

- Upstream notebook: third_party/Wikipedia/wikipedia-search-cookbook.ipynb
## What to focus on

- Iterative search loops (search → read → refine)
- Keeping citations aligned with retrieved passages
- When to upgrade to a proper indexed RAG system
## Run locally

```bash
make test-notebooks NOTEBOOK=third_party/Wikipedia/wikipedia-search-cookbook.ipynb
```
