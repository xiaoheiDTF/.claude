# Cookbook / Tool-Use / Customer-Service-Agent

> 来源: claudecn.com

# Customer service agent (client-side tools)

Demonstrates a customer support workflow where tools are executed client-side, including a pattern for **simulating tool responses** during development.

- Upstream notebook: tool_use/customer_service_agent.ipynb
## What to focus on

- Designing “safe” client-side tools (no hidden side effects)
- Using synthetic tool outputs to validate the conversation loop
- Keeping tool inputs/outputs auditable and testable
## Run locally

```bash
make test-notebooks NOTEBOOK=tool_use/customer_service_agent.ipynb
```
