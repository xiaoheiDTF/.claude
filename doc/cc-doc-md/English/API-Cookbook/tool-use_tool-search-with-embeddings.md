# Cookbook / Tool-Use / Tool-Search-With-Embeddings

> 来源: claudecn.com

# Tool search with embeddings

Scales tool use to large tool libraries by embedding tool descriptions and selecting tools by semantic similarity before calling them.

- Upstream notebook: tool_use/tool_search_with_embeddings.ipynb
## What to focus on

- Building a tool catalog (names + descriptions)
- Embedding + nearest-neighbor retrieval to shortlist tools
- Keeping a deterministic execution layer after the model selects tools
## Run locally

```bash
make test-notebooks NOTEBOOK=tool_use/tool_search_with_embeddings.ipynb
```
