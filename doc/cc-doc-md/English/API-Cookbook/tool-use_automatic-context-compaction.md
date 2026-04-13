# Cookbook / Tool-Use / Automatic-Context-Compaction

> 来源: claudecn.com

# Automatic context compaction

Demonstrates automatic context compaction for long-running workflows, using a beta tool runner with `compaction_control`.

- Upstream notebook: tool_use/automatic-context-compaction.ipynb
## What to focus on

- When to compact (token threshold)
- How compaction changes message history (summary insertion)
- Keeping behavior stable across long ticket queues / multi-step loops
## Run locally

```bash
make test-notebooks NOTEBOOK=tool_use/automatic-context-compaction.ipynb
```
