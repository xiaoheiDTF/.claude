# Cookbook / Tool-Use / Extracting-Structured-Json

> 来源: claudecn.com

# Extracting structured JSON (via tool use)

Shows how to enforce structured outputs by defining a tool whose `input_schema` is the contract for extracted fields (summaries, entities, sentiment, etc.).

- Upstream notebook: tool_use/extracting_structured_json.ipynb
## What to focus on

- Use tools as a schema contract (instead of “hope the model outputs JSON”)
- Validate required fields early (schema + app-side validation)
- Handling unknown keys / unexpected shapes defensively
## Run locally

```bash
make test-notebooks NOTEBOOK=tool_use/extracting_structured_json.ipynb
```

## Related

- JSON mode (prompting): ../output-control/json-mode
