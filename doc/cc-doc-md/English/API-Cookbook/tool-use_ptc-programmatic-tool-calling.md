# Cookbook / Tool-Use / Ptc-Programmatic-Tool-Calling

> 来源: claudecn.com

# Programmatic tool calling (PTC)

Introduces PTC: letting code call tools programmatically inside a controlled code execution environment.

- Upstream notebook: tool_use/programmatic_tool_calling_ptc.ipynb
## What to focus on

- Traditional tool loop vs PTC performance tradeoffs
- Restricting tool callers (example uses allowed_callers)
- Treating code execution as a capability that must be permissioned and audited
## Run locally

```bash
make test-notebooks NOTEBOOK=tool_use/programmatic_tool_calling_ptc.ipynb
```
