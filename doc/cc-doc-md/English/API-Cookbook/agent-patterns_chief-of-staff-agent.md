# Cookbook / Agent-Patterns / Chief-Of-Staff-Agent

> 来源: claudecn.com

# Chief of staff agent

Use this example when you want an agent that does more than answer tasks. It helps when the agent also needs to operate within team conventions: output style, permission boundaries, hooks, and planning behavior.

This makes it a good bridge from “personal experiment” to “shared team workflow.”

## What to focus on

- Output styles (settings + setting_sources=["project"])
- Hook loading (setting_sources=["project","local"])
- Keeping tool permissions tight (allowed_tools=[...])
## When it works well

- A team wants more consistent output formatting
- Local automation or hooks need to shape agent behavior
- Permissions and review boundaries matter as much as prompt quality
## If you want to reproduce it locally

After your local Cookbook setup is ready, you can validate the matching example with:

```bash
make test-notebooks NOTEBOOK=claude_agent_sdk/01_The_chief_of_staff_agent.ipynb
```
