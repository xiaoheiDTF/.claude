# Cookbook / Tool-Use / Parallel-Tools

> 来源: claudecn.com

# Parallel tool calls

Shows patterns for handling multiple tool calls in a single turn, and introduces a “batch tool” wrapper idea.

- Upstream notebook: tool_use/parallel_tools.ipynb
## What to focus on

- Iterating response.content and handling multiple tool_use blocks
- Returning tool_result with correct tool_use_id
- Batch tool pattern: bundling multiple invocations to reduce turns
## Run locally

```bash
make test-notebooks NOTEBOOK=tool_use/parallel_tools.ipynb
```
