# Cookbook / Agent-Patterns / Observability-Agent-Mcp

> 来源: claudecn.com

# Observability agent (MCP)

Use this example when an agent must work with real external systems and you need the integration to stay observable, reviewable, and tightly scoped.

It is especially useful once your challenge is no longer prompt design, but safe connection to tools and services.

## What to focus on

- MCP server wiring (git server via uv, GitHub via Docker)
- Token management (GITHUB_TOKEN → GITHUB_PERSONAL_ACCESS_TOKEN)
- Enforcing restrictions: disallowed_tools is required to truly limit tools
## When it works well

- The agent must read from or act on external systems
- You need clear permission boundaries around that access
- Operational safety matters more than adding more capabilities
## If you want to reproduce it locally

After your local Cookbook setup is ready, you can validate the matching example with:

```bash
make test-notebooks NOTEBOOK=claude_agent_sdk/02_The_observability_agent.ipynb
```
