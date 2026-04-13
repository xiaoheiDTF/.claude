# Cookbook / Evals-And-Testing / Tool-Evaluation

> 来源: claudecn.com

# Tool evaluation

Evaluates tool calling behavior using an agent loop plus prompts and helper functions.

- Upstream notebook: tool_evaluation/tool_evaluation.ipynb
## What to focus on

- What “good tool use” means (correct tool, correct args, correct order)
- Measuring failures (tool misuse, missing tool calls, bad arguments)
- Turning findings into tool schema / prompt improvements
## Run locally

```bash
make test-notebooks NOTEBOOK=tool_evaluation/tool_evaluation.ipynb
```
