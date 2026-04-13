# Cookbook / Tool-Use / Memory-And-Context-Management

> 来源: claudecn.com

# Memory & context management

Explores memory patterns for long-running agents, including context editing strategies and best practices for security.

- Upstream notebook: tool_use/memory_cookbook.ipynb
## What to focus on

- What should be persisted vs summarized vs discarded
- Safe “memory” boundaries (avoid storing secrets/PII)
- Keeping long workflows stable without ballooning context
## Run locally

```bash
make test-notebooks NOTEBOOK=tool_use/memory_cookbook.ipynb
```
