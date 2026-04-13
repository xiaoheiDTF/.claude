# Cookbook / Agent-Patterns / One-Liner-Research-Agent

> 来源: claudecn.com

# One-liner research agent

Use this example when you want the smallest possible research workflow with a narrow tool boundary and a stable citation rule.

Its strength is not feature breadth. Its strength is auditability: one clear tool, one clear output contract, and an easy path to inspect what the agent is allowed to do.

## What to focus on

- allowed_tools=["WebSearch"] for a narrow, auditable agent
- System prompt contracts for citations and “Sources:” sections
- When to upgrade from a one-liner to an SDK client with state
## When it works well

- You need quick external research, but still want traceable sources
- You want the simplest possible agent before adding state or more tools
- You care more about reliability and reviewability than broad capability
## If you want to reproduce it locally

After your local Cookbook setup is ready, you can validate the matching example with:

```bash
make test-notebooks NOTEBOOK=claude_agent_sdk/00_The_one_liner_research_agent.ipynb
```
