# Cookbook / Tool-Use / Tool-Choice

> 来源: claudecn.com

# Tool choice (Auto / Any / Force)

Covers how to configure tool selection, and why prompt design matters as much as `tool_choice` itself.

- Upstream notebook: tool_use/tool_choice.ipynb
## What to focus on

- tool_choice={"type":"auto"} for selective usage
- Forcing a specific tool when you need deterministic behavior
- “Any” mode tradeoffs (more freedom, more risk)
## Run locally

```bash
make test-notebooks NOTEBOOK=tool_use/tool_choice.ipynb
```
