# Cookbook / Tool-Use / Calculator-Tool

> 来源: claudecn.com

# Calculator tool

Implements a minimal “tool loop” using a [ calculator](#) tool, showing how `tools` + `tool_use` blocks connect to real code execution.

- Upstream notebook: tool_use/calculator_tool.ipynb
## What to focus on

- Tool schema shape: name / description / input_schema
- Tool execution in your app (not inside the model)
- Returning results back as tool_result linked by tool_use_id
## Run locally

```bash
make test-notebooks NOTEBOOK=tool_use/calculator_tool.ipynb
```

## Next

- If tool selection matters, continue with ../tool-choice
- If you need multiple tools per turn, continue with ../parallel-tools
